USE [$(FS_CUSTOM)]
GO
-- Mode is by using a combination of keys ALT+Q+M

/****** Object:  StoredProcedure [dbo].[CheckRecAndEmlActivity2]    Script Date: 27. 8. 2019 12:54:19 ******/
-- Rekonfigurace EventLog:

/****** Object:  Table [dbo].[Eventlog]    Script Date: 28. 6. 2016 12:12:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID (N'Eventlog', N'U') IS NULL 
CREATE TABLE [dbo].[Eventlog](
	[DatumCas] [datetime] NULL,
	[Procedura] [nchar](20) NULL,
	[Popis] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/*
DROP TABLE [dbo].[Eventlog]  -- 
GO

CREATE TABLE [dbo].[Eventlog](
	[DatumCas] [datetime] NOT NULL,
	[Procedura] [nchar](20) NULL,
	[Popis] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

-- Nelze použít Clustered index, jelikož časy nejsou unikátní
ALTER TABLE [dbo].[Eventlog] ADD  CONSTRAINT [PK_Eventlog] PRIMARY KEY CLUSTERED 
(
	[DatumCas] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
*/

IF eXISTS(SELECT *  FROM sys.indexes  WHERE object_id = OBJECT_ID('$(FS_CUSTOM).DBO.Eventlog') AND name='PK_Eventlog')
  ALTER TABLE [dbo].[Eventlog] DROP CONSTRAINT [PK_Eventlog]

/****** Object:  Index [NonClusteredIndex-20200127-093242]    Script Date: 27. 1. 2020 9:34:28 ******/
IF NOT eXISTS(SELECT *  FROM sys.indexes  WHERE object_id = OBJECT_ID('$(FS_CUSTOM).DBO.Eventlog') AND name='CX_DatumCas')
  BEGIN
	CREATE NONCLUSTERED INDEX [CX_DatumCas] ON [dbo].[Eventlog]
	(
		[DatumCas] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	--GO
   END
GO




/* ===================================  S T A R T    O F   M A I N   P R O C E D U R E  ============================= */


-- Upravil ZbH 17.7.2018
-- Nyní probíhá stálé zdokonalování funkce
--CREATE
ALTER
 PROCEDURE [dbo].[CheckRecAndEmlActivity2] 
AS
BEGIN
  	declare @ProcVer as nvarchar(35) = ' Verze kontrolní funkce: 5.3.2020'
	declare @Today as datetime = GETDATE()
	/* Tuto část bude možno vypustit : ---------------------------------------------------------------------------------------*/
	declare @TGT as nvarchar(200) = 'servis@atlantis.cz'
	declare @TOCC as nvarchar(200) =.dbo.GiveParam('TOCC')
	IF @TOCC IS NULL
	     BEGIN
		   SET @TOCC  = 'homolka@atlantis.cz'
		   EXEC [dbo].[WriteParam] 'TOCC', @TOCC, 'Mailové adresy, kam se mají posílat zaznamenané problémy'
		 END
	declare @MessageId as uniqueidentifier =
	(SELECT TOP 1 MessageId FROM [$(ICC)].[dbo].[Message]
	   WHERE Direction='O' AND MessageType='Email' AND ReceivedSentTime IS NOT NULL AND GatewayId IS NOT NULL ORDER BY ReceivedSentTime DESC)
	 declare @GW as uniqueidentifier = (SELECT TOP 1 [GatewayId] FROM [$(ICC)].[dbo].[Message] WHERE MessageId=@MessageId)
	 declare @GWN as nvarchar(150) = (SELECT TOP 1 PilotAddress FROM [$(ICC)].[dbo].[Gateway] WHERE GatewayId=@GW)
	 declare @Company as nvarchar(200) =.dbo.GiveParam('Company')
	 IF @Company IS NULL
	     BEGIN
		    EXEC [dbo].[WriteParam] 'Company', @GWN, 'Jméno firmy'
		 END

     DECLARE @AgentName AS NVARCHAR(50)
	 DECLARE @String1 AS NVARCHAR(50)
	 DECLARE @String2 AS NVARCHAR(50)
   --------------------------------------------------------------------------------------------------------------------------
    declare @EmlMsg as nvarchar(300)
	declare @Subject as nvarchar(200)
	declare @Specif as nvarchar(200)
	declare @Holiday as nvarchar(40) =.dbo.GiveParam('Holiday')
	IF @Holiday IS NULL
	     BEGIN
		   SET @Holiday  = 'OUT_OF_OFFICE'
		   EXEC [dbo].[WriteParam] 'Holiday', @Holiday, 'Název skupiny svátků'
		 END


	--declare @TOCC as nvarchar(200) = 'kubat@atlantis.cz;homolka@atlantis.cz;roman.dolezal@digi2go.cz'
	declare @Mark as int = 77
	/*IF (NOT EXISTS(SELECT TOP 1 1 FROM $(ICC).dbo.Holiday as H where H.HolidayGroupName='INSPECTION' AND H.TimeMode='SingleDay' ))
	  insert into $(ICC).dbo.Holiday([DisplayName],[HolidayGroupName],[TimeMode],[TimeFrom],[TimeTo])
		values('CheckRecAndEml','INSPECTION','SingleDay',CONVERT(DateTime,'2018.08.01 8:00'),CONVERT(DateTime,'2018.08.01 17:00')) */


	--IF(EXISTS(SELECT * FROM $(ICC).dbo.Holiday as H where H.HolidayGroupName='INSPECTION' AND H.TimeMode='SingleDay' AND (.dbo.TimeCompare2(H.TimeFrom,'>',GETDATE())=1 OR .dbo.TimeCompare2(H.TimeTo,'<',GETDATE())=1))) RETURN
	IF(EXISTS(SELECT * FROM $(ICC).dbo.Holiday as H where H.HolidayGroupName=@Holiday AND H.TimeMode='SingleDay' AND CAST(H.TimeFrom as DATE)=CAST(@Today AS DATE))) RETURN
	IF(EXISTS(SELECT * FROM $(ICC).dbo.Holiday as H where H.HolidayGroupName=@Holiday AND H.TimeMode='DayInYear' AND DATEPART(DAY,H.TimeFrom)=DATEPART(DAY,@Today) AND DATEPART(MONTH,H.TimeFrom)=DATEPART(MONTH,@Today))) RETURN
	-- Pokud tam jsou mé neodeslané maily mladší 24hodin, neodesílám další
	IF(EXISTS(SELECT * FROM $(ICC).dbo.Message as M where M.Messagetype='Email' AND MessagePhase='Scheduled' AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE()))) RETURN


	declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Today )	-- Před 15 min

	declare @Interval as int = 30;
	declare @Debug as bit = 0

	declare @Now as datetime = GETUTCDATE()
	declare @Last as datetime = DATEADD(MINUTE, -@Interval, @Now ) -- Posledních 30minut
	declare @WeekAgo as datetime = DATEADD(DAY, -7, @Now )
	declare @DayAgo as datetime = DATEADD(DAY, -2, @Now )
	declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
	declare @LastWeekAgo as datetime = DATEADD(DAY, -7, @Last )
	declare @OneHourAgo as datetime = DATEADD(Hour, -1, @Now )

IF db_id('SREC') IS NOT NULL 
  BEGIN
	declare @RecNow as int = (select count(*) from SRec.dbo.VoiceRecord as R where R.EndTimeUtc<=@Now AND R.EndTimeUtc>=@Last) -- Počet nahrávek za posledních 30 minut
	declare @RecWeekAgo as int = (select count(*) from SRec.dbo.VoiceRecord as R where R.EndTimeUtc<=@WeekAgo AND R.EndTimeUtc>=@LastWeekAgo) -- Počet nahrávek za 30 minut před týdnem
	IF ISNULL(@RecWeekAgo,0)=0
	  BEGIN
	    SET @RecWeekAgo=5
	  END
   --  SET @RecNow=0 -- Pro ladění
	declare @InCalls as int = (SELECT Count(*) FROM $(ICC).dbo.InboundCall as I WITH(NOLOCK) WHERE I.TimeUtc>=@Last AND I.TimeUtc<=@Now AND I.CallDuration>1 AND CallResult='Served')
	--                                                                                                                                                                                 Odchozí hovory automatu nejsou nahrávány
	declare @OutCalls as int = (SELECT Count(*) FROM $(ICC).dbo.OutboundCall as O WITH(NOLOCK) WHERE O.ScheduleTime>=@Pred15min AND O.ScheduleTime<=@Today AND O.CallDuration>1 AND CallResult<>'Active' AND O.AgentId IS NOT NULL)

	declare @Last10 as datetime = DATEADD(MINUTE, -10, @Now )

	declare @Predist30Now as int = (select count(*) from $(ICC).dbo.OutboundCall as O where O.TimeUtc<=@Now AND O.TimeUtc>=@Last10 AND Predistributed=1 AND DATEDIFF(ss,O.EnqueueingTime,O.DistributionTime)>30)
	declare @Predist10Now as int = (select count(*) from $(ICC).dbo.OutboundCall as O where O.TimeUtc<=@Now AND O.TimeUtc>=@Last10 AND Predistributed=1 AND DATEDIFF(ss,O.EnqueueingTime,O.DistributionTime)>10)

	declare @T as nvarchar(120) = CONVERT(nvarchar(20), DATEADD(MINUTE, -@Interval, @Today), 20) + ' - ' + CONVERT(nvarchar(20), @Today, 8)

    -- Kontrola nahrávek:
	IF @Debug=1 OR @GW IS NOT NULL AND (((@RecNow<@RecWeekAgo/5 OR @RecNow=0) AND @RecWeekAgo>0)  AND (@InCalls+@OutCalls>0) AND ((@InCalls+@OutCalls)>@RecNow))
	BEGIN
	  IF (@InCalls>0 AND .dbo.CustomCheck('IC',@Last)=1) OR (@OutCalls>0 AND .dbo.CustomCheck('OC',@Last)=1)
	   BEGIN
		SET @EmlMsg = 'T=' + @T + ' R- for last ' + CONVERT(nvarchar(10),@Interval) + ' min ='+ CONVERT(nvarchar(10),@RecNow) + ' R-weekago this time =' + CONVERT(nvarchar(10),@RecWeekAgo)
		SET @Specif = CONVERT(nvarchar(10),@RecNow)
		EXEC [dbo].[ErrorLogProc] 'Varování: nízký počet nahrávek',@Specif,@ProcVer,@EmlMsg,10,5
		/*
		insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,'Email','Scheduled','Active', @GWN, @TGT,@TGT,  @TOCC ,@GW,99,'O',
		'Varování: nízký počet nahrávek ' + CONVERT(nvarchar(10),@RecNow)+@ProcVer, @EmlMsg, @EmlMsg, @Mark )*/
       END
	END
  END
	------------------------------------------------------------------------------------
	-- Kontrola mailů:
	declare @EmlNow as int = (select count(*) from $(ICC).dbo.Message as M where M.Direction='I' AND M.MessageType='Email' AND M.TimeUtc<=@Now AND M.TimeUtc>=@Last)
	declare @EmlWeekAgo as int = (select count(*) from $(ICC).dbo.Message as M where M.Direction='I' AND M.MessageType='Email' AND  M.TimeUtc<=@WeekAgo AND M.TimeUtc>=@LastWeekAgo)


	IF @Debug=1 OR (@GW IS NOT NULL AND (@EmlNow<@EmlWeekAgo/5 AND @EmlNow<@EmlWeekAgo-10) AND @EmlWeekAgo>1) 
	 BEGIN
	    SET @EmlMsg = 'T=' + @T + ' E-now='+ CONVERT(nvarchar(10),@EmlNow) + ' E-weekago=' + CONVERT(nvarchar(10),@EmlWeekAgo)
		-- Možná byl minulý týden výjimečný - tak porovnám ještě údaje před dvěma týdny
		declare @Eml2WeeksAgo as int = (select count(*) from $(ICC).dbo.Message as M where M.Direction='I' AND M.MessageType='Email' 
		  AND  M.TimeUtc<=DATEADD(Day,-7,@WeekAgo) AND M.TimeUtc>=DATEADD(Day,-7,@LastWeekAgo))
		IF (@EmlNow<@Eml2WeeksAgo/5 AND @EmlNow<@Eml2WeeksAgo-10 AND @Eml2WeeksAgo>1)
		  BEGIN		 
		    SET @Specif = CONVERT(nvarchar(10),@EmlNow)
		    EXEC [dbo].[ErrorLogProc] 'Varování: nízký počet příchozích emailů',@Specif,@ProcVer,@EmlMsg,2,60
		  END
		  -- Kontrola chyb v MessageEvent
		  SET @EmlMsg = (SELECT TOP 1 [ResultData] FROM $(ICC).[dbo].[MessageEvent] WHERE EventType='Failure' AND TimeLocal>@OneHourAgo)
		  IF (@EmlMsg IS NOT NULL)
		    BEGIN		 
		      SET @Specif = ''
			  SET @EmlMsg = 'Varování - Maily: '+@EmlMsg 
		      EXEC [dbo].[ErrorLogProc] @EmlMsg,@Specif,@ProcVer,@EmlMsg,0,60
		    END

		 END
    IF @GW IS NOT NULL  
	 BEGIN
	   DECLARE @NoSent as int = (select count(*) from $(ICC).dbo.Message as M where M.Direction='O' AND (MessagePhase='Scheduled' OR MessagePhase='Failed') AND M.MessageType='Email' AND M.TimeUtc<=@Last AND M.TimeUtc>=@DayAgo
	   AND RemoteAddress IS NOT NULL -- 28.5.2019 Odfiltrování chybných mailů z webu
	   and (ISNULL(ScheduledTime,.dbo.TimeUTC_Local(TimeUTC))  < dateadd (minute,-15,GETDATE ()))--Kubat, podminka pro naplanovane maily a jejich zpozdene odeslani
	   --and MessageResult = 'Active' -- ZbH 27.3.2019
	   )
	   DECLARE @NoSentTreshold AS Integer=.dbo.GiveParam('NoSentTreshold')
	   IF @NoSentTreshold IS NULL
	     BEGIN
		   SET @NoSentTreshold=10
		   EXEC [dbo].[WriteParam] 'NoSentTreshold', @NoSentTreshold, 'Hranice, při níž se nahlašuje počet neodeslaných mailů (Scheduled, Failed)'
		 END
	   IF @NoSent>@NoSentTreshold
	    BEGIN
			SET @Specif = ', počet='+ CONVERT(nvarchar(10),@NoSent)
		    EXEC [dbo].[ErrorLogProc] 'Varování: neodeslané emaily',@Specif,@ProcVer,@EmlMsg,2,60
			-- Pokusím se problém vyřešit
			UPDATE iCC.[dbo].[Message] SET MessageResult='Active'
             WHERE  TimeUtc>@Yesterday AND Direction='O' AND MessagePhase='Scheduled' AND MessageResult='Closed' -- Pokud agent zadal odeslání uzavřeného mailu

          END
		-- Kontrola zapomenutých mailů
        IF (.dbo.CustomCheck('MN',@WeekAgo)>0)
		 BEGIN
	      SET  @EmlMsg='Prosím o kontrolu'
	      insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		  values(@Now,'Email','Scheduled','Active', @GWN, @TOCC,@TOCC,@GW,99,'O',
		  ' Varování: nepřijaté příchozí emaily' + @ProcVer, @EmlMsg, @EmlMsg, @Mark )
        END
		-- Kontrola mailů přodělených agentům, kteří nejsou v práci
        IF (.dbo.CustomCheck('NV',@WeekAgo)>0)
		 BEGIN
	      SET  @EmlMsg='Prosím o kontrolu'
	      insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		  values(@Now,'Email','Scheduled','Active', @GWN, @TOCC,@TOCC,@GW,99,'O',
		  ' Varování: maily přidělené agentům, kteří nejsou v práci' + @ProcVer, @EmlMsg, @EmlMsg, @Mark )
        END


	 END
	------------------------------------------------------------------------------------
	-- Kontrola přiřazování mailů do případů (AssignMailOfIssue):
   IF EXISTS(SELECT 1 FROM [$(ICC)].[dbo].[ActionTrigger] WHERE Suspended=0 AND Deleted=0 AND CommandText LIKE 'AssignMailOfIssue')
    AND @GW IS NOT NULL  
	 BEGIN
	   DECLARE @IssueIds TABLE (IssueId  UNIQUEIDENTIFIER)
       INSERT INTO @IssueIds select M.IssueId from $(ICC).dbo.Message as M WITH (NOLOCK)
                            INNER JOIN $(ICC).dbo.Message as M2 WITH (NOLOCK) ON M.RelatedMessageId=M2.MessageId AND M2.IssueId IS NOT NULL
                           where M.Direction='I' AND M.MessageType='Email' AND M.ReceivedSentTime>@Last
       IF EXISTS(SELECT * FROM @IssueIds) AND NOT EXISTS(SELECT * FROM @IssueIds WHERE IssueId IS NOT NULL)
         BEGIN
  	      SET  @EmlMsg='Prosím o kontrolu'
	      insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		  values(@Now,'Email','Scheduled','Active', @GWN, @TOCC,@TOCC,@GW,99,'O',
		  ' Nepřiřazují se příchozí maily do případů (AssignMailOfIssue)'+@ProcVer , @EmlMsg, @EmlMsg, @Mark )
         END
		-- Tady by mohla být ještě kontrola příchozí pošty na jednotlivých branách
      END
	  	------------------------------------------------------------------------------------
	-- Kontrola místa na discích:
	DECLARE @DiskName AS NVARCHAR(10)=(SELECT TOP 1 volume_mount_point FROM sys.master_files AS f 
	  CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
        WHERE ( (available_bytes/1048576* 1.0)/(total_bytes/1048576* 1.0) *100)<10 AND available_bytes/1048576000<15)

   IF  @DiskName IS NOT NULL
	 BEGIN
  	      SET  @EmlMsg='Prosím o kontrolu'
/*	   insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,'Email','Scheduled','Active', @GWN, @TGT,@TGT,  @TOCC ,@GW,99,'O',
		  ' Na disku '+@DiskName+' je méně než 10% místa'+@ProcVer , @EmlMsg, @EmlMsg, @Mark ) */
		SET @Specif = ' Na disku '+@DiskName+' je méně než 15GB volného místa'
		EXEC [dbo].[ErrorLogProc] 'Dochází místo na disku',@Specif,@ProcVer,@EmlMsg,10,120

     END
	 	-- Kontrola duplicit na ProServeru:
	DECLARE @DuplicExt AS NVARCHAR(10)=(SELECT TOP 1 ProServer_Extension FROM
(SELECT 
      [Number] AS ProServer_Extension
      ,COUNT(1) AS Pocet
  FROM [ProServer].[dbo].[Extension]
  WHERE Deleted=0
  GROUP BY Number) AS Phase1
  WHERE Pocet>1)

   IF  @DuplicExt IS NOT NULL
	 BEGIN
  	      SET  @EmlMsg='Prosím o kontrolu'
	   insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,'Email','Scheduled','Active', @GWN, @TGT,@TGT,  @TOCC ,@GW,99,'O',
		  ' Na proServeru je duplicitní linka '+@DuplicExt+' Toto způsobí jeho nefunkčnost'+@ProcVer , @EmlMsg, @EmlMsg, @Mark )
     END

	 	-- Kontrola nefunkčních linek na ProServeru:
DECLARE @Number AS varchar(16)
DECLARE My_cursor CURSOR FOR   
 SELECT  [Number] FROM [ProServer].[dbo].[Extension]
  WHERE OnLineStatus<>0 AND Deleted=0 AND Suspended=0
   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @Number   
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @Number IS NOT NULL
		BEGIN
			  SET @EmlMsg='Prosím o kontrolu'
			  SET @Subject='Varování: linka '+@Number+' není ve stavu OK na ProServeru'
			  SET @Specif = ''
			  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,1000
		END
		FETCH NEXT FROM My_cursor INTO @Number  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;
--------------------------------------------------------------------------------------------------------------------------------------
	 -- Kontrola linek/pracovišť
    DECLARE @WPOK AS Integer=(SELECT TOP 1 1 FROM [$(ICC)].[dbo].[Workplace] WITH (NOLOCK) WHERE State<>'OutOfOrder')

   IF  @WPOK IS NULL
	 BEGIN
	     SET  @EmlMsg='Prosím o kontrolu'
 	   insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,'Email','Scheduled','Active', @GWN, @TGT,@TGT,  @TOCC ,@GW,99,'O',
		'Všechna pracoviště jsou mimo provoz ' + CONVERT(nvarchar(10),@RecNow)+@ProcVer, @EmlMsg, @EmlMsg, @Mark )
     END

  -- Kontrola blokace agentského pracoviště Adminem
  DECLARE @AgentId as uniqueidentifier=(SELECT TOP 1 AgentId FROM $(ICC).[dbo].[Agent] where TeamName='ADMIN' AND WorkplaceId IS NOT NULL AND DATEDIFF(Hour,LastRefreshUtc,GETUTCDATE())>4)
  IF @AgentId IS NOT NULL
   BEGIN
    DECLARE @WorkplaceId as uniqueidentifier=(SELECT TOP 1 WorkPlaceId FROM [$(ICC)].[dbo].[Agent] where AgentId=@AgentId)
    DECLARE @TimeUTC as Datetime = (SELECT TOP 1 TimeUTC FROM [$(ICC)].[dbo].[AgentEvent] where EventType='AgentStatus' AND AgentId=@AgentId ORDER BY EventType,AgentId,TimeUTC DESC)
	IF DATEDIFF(Hour,@TimeUTC,GETUTCDATE())>4 AND EXISTS (SELECT TOP 1  AG.[AgentId] FROM [$(ICC)].[dbo].[Seating] AS SEA WITH (NOLOCK) 
      INNER JOIN [$(ICC)].[dbo].[Agent] AS AG WITH (NOLOCK) ON SEA.AgentId=AG.AgentId WHERE SEA.WorkPlaceId=@WorkplaceId AND AG.TeamName<>'ADMIN')
	    BEGIN
		  SET @AgentName = RTRIM((SELECT TOP 1 DisplayName FROM [$(ICC)].[dbo].[Agent] where AgentId=@AgentId))
		  SET @EmlMsg='Prosím o kontrolu'
		  SET @Subject='Varování: Admin '+@AgentName+' je přihlášen a blokuje agentům pracoviště.'
		  SET @Specif = ISNULL((SELECT Displayname FROM iCC.dbo.Workplace WHERE WorkplaceId=@WorkplaceId),'')
		  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,180
		END	  
   END

   -- Kontrola odhlašování agenta díky poruše pracoviště 
  SET @AgentName =(SELECT TOP (1)  AG.DisplayName AS AgentName FROM $(ICC).[dbo].[AgentEvent] AE LEFT JOIN [$(ICC)].[dbo].[Agent] AG ON AG.AgentId=AE.AgentId
    WHERE TimeLocal > DATEADD(Hour,-3,GETDATE())  AND ReferenceData='Logoff' AND Actor='Distribution' AND AE.ResultData='Phone')
  IF @AgentName IS NOT NULL
   BEGIN
      SET @WorkplaceId =(SELECT TOP 1 WorkPlaceId FROM [$(ICC)].[dbo].[Agent] where DisplayName=@AgentName)
 		  SET @EmlMsg='Prosím o kontrolu'
		  SET @Subject='Varování: Agent '+@AgentName+' je odhlašován. Jeho pracoviště má zřejmě poruchu.'
		  SET @Specif = ISNULL((SELECT Displayname FROM iCC.dbo.Workplace WHERE WorkplaceId=@WorkplaceId),'')
		  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,220
   END

    -- Kontrola chyb v IssueCondition:
	
SELECT TOP 1 @String1=ISUC.[DisplayName],@String2=TPC.DisplayName FROM $(ICC).[dbo].[IssueCondition] ISUC
  LEFT JOIN $(ICC).[dbo].[Topic] TPC ON TPC.TopicId=ISUC.NormalTopicId
  WHERE ISUC.NormalTopicId IS NOT NULL AND TPC.TopicId IS  NULL OR TPC.Deleted=1

  IF @String2 IS NOT NULL
   BEGIN
  		  SET @EmlMsg='Prosím o kontrolu'
		  SET @Subject='Varování: Pravidlo případu '+@String1+' používá chybné/smazané téma '+@String2
		  SET @Specif = ''
		  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,600
   END

  -- Kontrola synchronizačních procedur atd.
  DECLARE @Procedura AS NVARCHAR(50)
  DECLARE @Popis AS NVARCHAR(900)
DECLARE My_cursor CURSOR FOR   
 SELECT DISTINCT TOP 10 Procedura,Popis  FROM .[dbo].[Eventlog] WITH (NOLOCK) WHERE DatumCas>@Yesterday AND (Popis='Vstupní bod' OR Procedura='SystemTests')
   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @Procedura,@Popis    
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @Procedura  IS NOT NULL
		BEGIN
	       IF @Procedura='SystemTests' OR
		   NOT EXISTS(SELECT TOP 1 Procedura  FROM .[dbo].[Eventlog] WITH (NOLOCK) WHERE DatumCas>@Yesterday AND Popis='Konec procedury' AND Procedura=@Procedura)
		     BEGIN
			  SET @EmlMsg='Prosím o kontrolu'
			  SET @Subject='Varování:'+IIF(@Procedura='SystemTests',@Popis,' Procedura: '+RTRIM(@Procedura)+' neprobíhá do konce.')
			  SET @Specif = ''
			  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,1000
			   --SELECT 'Procedura: '+RTRIM(@Procedura)+' neprobíhá do konce.'
			 END
		END
		FETCH NEXT FROM My_cursor INTO @Procedura,@Popis  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;

	 /*
	IF @Debug=1 OR ( @Predist30Now>1 OR @Predist10Now>5) 
	BEGIN
		declare @OutMsg as nvarchar(300) = 'T=' + @T + ' O-late30='+ CONVERT(nvarchar(10),@Predist30Now) + ' O-late10=' + CONVERT(nvarchar(10),@Predist10Now)
		insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText)
		values(@Now,'Email','Scheduled','Active', @GWN, @TGT,@TGT,@GW,99,'O',
		'Varování: zpožděná distribuce přímých hovorů ' + CONVERT(nvarchar(10),@Predist10Now), @OutMsg, @OutMsg )
	END

	IF @Debug=1 OR ( DATEPART(HOUR,@Today)=9 AND (DATEPART(MINUTE,@Today) BETWEEN 0 AND 4) )
	BEGIN
		declare @InfMsg as nvarchar(300) = 'T=' + @T + ' E-now='+ CONVERT(nvarchar(10),@EmlNow) + ' R-now=' + CONVERT(nvarchar(10),@RecNow) + ' O-late10=' + CONVERT(nvarchar(10),@Predist10Now)
		insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText)
		values(@Now,'Email','Scheduled','Active', @GWN, @TGT,@TGT,@GW,99,'O',
		'Informace: kontrola nahrávek a emailů ' + CONVERT(nvarchar(10),@Today,120), @InfMsg, @InfMsg )
	END
	*/
END
GO
--------------------- Pomocná tabulka   ---------------------
IF object_id('Errorlog') IS NULL
  BEGIN
	CREATE TABLE [dbo].[ErrorLog](
		[Timelocal] [datetime] NULL,
		[RepeatAfter] [int] NULL,
		[Message] [nvarchar](500) NULL
	) ON [PRIMARY]
	--GO
	/****** Object:  Index [TimeLocal]    Script Date: 11/21/2019 11:26:01 ******/
	CREATE CLUSTERED INDEX [TimeLocal] ON [dbo].[ErrorLog]
	(
		[Timelocal] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	--GO
  END
--------------------- Podpůrné procedury --------------------
IF object_id('GiveParam') IS NOT NULL
 DROP  Function  [dbo].[GiveParam]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17.5.2017>
-- Description:	<vrací hodnotu požadovaného parametru>
-- =============================================
CREATE FUNCTION [dbo].[GiveParam]
(
	-- Add the parameters for the function here
	@ConfigurationName AS NVARCHAR(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN (SELECT ConfigurationValue FROM $(ICC).[dbo].[CONFIGURATION]  WHERE ConfigurationName=@ConfigurationName)

END


GO

IF object_id('WriteParam') IS NOT NULL
 DROP  Procedure  [dbo].[WriteParam]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17.05.2017>
-- Description:	<Zápis parametru do Configuration>
-- =============================================
CREATE PROCEDURE [dbo].[WriteParam]
 @ConfigurationName AS NVARCHAR(50),
 @ConfigurationValue AS NVARCHAR(MAX),
 @Description AS NVARCHAR(800)
AS
BEGIN
--DECLARE @MyAgentId AS UniqueIdentifier = 'ffee47c8-da99-47d3-b4e2-ca92b624ac95' -- Admin ID
    IF NOT EXISTS (SELECT ConfigurationId FROM [$(ICC)].[dbo].[CONFIGURATION]  WHERE ConfigurationName=@ConfigurationName)
	  BEGIN
	    INSERT INTO $(ICC).[dbo].[Configuration]
           (
            [ConfigurationName]
           ,[ConfigurationValue]
           ,[Description]
           ,[GroupName])
     VALUES
           (@ConfigurationName,
           @ConfigurationValue,
           @Description,
           'Zakaznik')
	  END
    ELSE
	  BEGIN
        update $(ICC).[dbo].[Configuration] 
         SET ConfigurationValue = @ConfigurationValue
         WHERE  ConfigurationName=@ConfigurationName
      END
END


GO


IF object_id('ErrorLogProc') IS NOT NULL
 DROP  Procedure  [dbo].[ErrorLogProc]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <21.11.2019>
-- Description:	<Zpracování chybové zprávy>
-- =============================================

CREATE PROCEDURE [dbo].[ErrorLogProc] (
@Message as nvarchar(500)
,@Specif as nvarchar(200)
,@ProcVer as nvarchar(35)
,@RecMsg as nvarchar(500)
,@Severity as int
,@RepeatAfter as int
--,@FromField as nvarchar(100)
--,@TOCC as nvarchar(200)
--,@GW as uniqueidentifier
)
AS
BEGIN
  --declare @TGT as nvarchar(200) = 'servis@atlantis.cz'
  declare @TOCC as nvarchar(200) =.dbo.GiveParam('TOCC')
	IF @TOCC IS NULL
	     BEGIN
		   SET @TOCC  = 'homolka@atlantis.cz'
		   EXEC [dbo].[WriteParam] 'TOCC', @TOCC, 'Mailové adresy, kam se mají posílat zaznamenané problémy'
		 END
 declare @Company as nvarchar(200) =.dbo.GiveParam('Company')
 declare @MessageId as uniqueidentifier = (SELECT TOP 1 MessageId FROM [$(ICC)].[dbo].[Message]
	   WHERE Direction='O' AND MessageType='Email' AND ReceivedSentTime IS NOT NULL AND GatewayId IS NOT NULL ORDER BY ReceivedSentTime DESC)
 declare @GW as uniqueidentifier = (SELECT TOP 1 [GatewayId] FROM [$(ICC)].[dbo].[Message] WHERE MessageId=@MessageId)
 declare @FromField as nvarchar(150) = (SELECT TOP 1 PilotAddress FROM [$(ICC)].[dbo].[Gateway] WHERE GatewayId=@GW)

  declare @Mark as int = 77
  declare @RemoteAddress as nvarchar(200) = CASE WHEN @Severity>0 THEN 'servis@atlantis.cz' ELSE @TOCC END
  DECLARE @RepeatAfterMess as int
  DECLARE @TimeLocalMess as DateTime
  SELECT TOP 1 @RepeatAfterMess=RepeatAfter, @TimeLocalMess=TimeLocal FROM .dbo.ErrorLog WHERE Message=@Message ORDER BY TimeLocal DESC
  -- Pokud mám o tomto problému informovat
  IF @TimeLocalMess IS NULL OR (@RepeatAfterMess>0 AND DATEADD(Minute,@RepeatAfterMess,@TimeLocalMess) <GETDATE())
     BEGIN
	    declare @Now as datetime = GETDATE()
    
	insert into .[dbo].[Errorlog] (TimeLocal, RepeatAfter, Message) values(GETDATE(), @RepeatAfter, @Message)

 IF(NOT EXISTS(SELECT * FROM $(ICC).dbo.Message as M where M.Messagetype='Email' AND MessagePhase='Scheduled' AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE())
   AND M.TimeUTC<DATEADD(Minute,-10,GETUTCDATE()))) 
	insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,'Email','Scheduled','Active', @FromField, @RemoteAddress,@RemoteAddress,  @TOCC ,@GW,99,'O',
		@Company+' '+@Message+' '+@Specif+' '+@ProcVer, @RecMsg, @RecMsg, @Mark )
/**/
     END
END
GO


--------------------- Uživatelská procedura --------------------
SET NOEXEC OFF
---------------------------------------
IF object_id('CustomCheck') IS NULL
 BEGIN
  DECLARE @CreateCustom AS NVARCHAR(500)=
 ' 
 CREATE FUNCTION [dbo].[CustomCheck](@TestVer AS NVARCHAR(2), @Last as DateTime)
   RETURNS int
	 AS
	  BEGIN
		RETURN 0
	  END'
    EXEC (@CreateCustom)
  --SELECT 'Chybě ohledně existence CustomCheck nevěnujte pozornost' AS Zprava
   --PRINT 'Provádím nápravu pracoviště '+@Workplace+' - čekám 30sekund.'
   --WAITFOR DELAY '00:00:01'
   --STOP
   --RETURN
 END
GO



---- Doplnění Rep_Date
USE $(ICC)
DECLARE @maxRepDate datetime = (SELECT TOP 1(D) FROM Rep_Date ORDER BY D DESC)
IF(@maxRepDate is null) SET @maxRepDate = '2012-01-01 00:00:00'
ELSE SET @maxRepDate = DATEADD(DAY, 1, @maxRepDate)
IF @maxRepDate <= '2020-01-01 00:00:00' 
BEGIN
       declare @d as datetime = @maxRepDate
       while @d<'2030-01-01 00:00:00'
       begin
             insert into Rep_Date(D) VALUES(@d)
             set @d = DATEADD(DD,1,@d)
       end
END
IF (SELECT COUNT(*) FROM Rep_Time)=0 
BEGIN
       declare @t as time = '00:00:00'
       declare @q as char(1)
       while @t<'23:59:00'
       begin
             if DATEPART(minute,@t)=00 set @q='h'
             else if DATEPART(minute,@t) % 30 = 0 set @q='m'
             else if DATEPART(minute,@t) % 15 = 0 set @q='q'
             else if DATEPART(minute,@t) % 5 = 0 set @q='f'
             else set @q = ' '
             insert into Rep_Time(H,Q) VALUES(@t,@q)
             set @t =CAST( DATEADD(minute,1,@t) as time)
       end
END

GO

  /* Admin: Issue Events */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '6c5e8e3f-37b1-4fc6-8c7d-233efd017f2b'
DECLARE @DisplayName AS VARCHAR(150) = 'Issue Events'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'TimeLocal',N'SELECT ISU.[IssueId]
        ,PROJ.DisplayName AS Projekt
        ,[TimeLocal]
        ,[EventType]
        ,IE.[AgentId]
        ,AG.DisplayName AS AgentName
        ,[ReferenceData]
        ,[ReferenceId]
  	  ,ContactId
    FROM [iCC].[dbo].[IssueEvent] IE
       LEFT JOIN Issue ISU ON ISU.IssueId=IE.IssueId
  	 LEFT JOIN Project PROJ ON PROJ.ProjectId=ISU.ProjectId
  	 LEFT JOIN Agent AG ON IE.AgentId=AG.AgentId
  ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@DataQueryId,N'IssueId',N'Text',N'IssueId',NULL,NULL,NULL,NULL,NULL,N'IssueId',NULL,0,230,5,NULL,0,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@DataQueryId,N'TimeLocal',N'DateTimeFromTo',N'TimeLocal',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeLocal',NULL,0,100,20,NULL,0,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@DataQueryId,N'Project',N'Text',N'Projekt',NULL,NULL,NULL,NULL,NULL,N'Projekt',NULL,0,80,22,NULL,0,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@DataQueryId,N'EventType',N'Text',N'EventType',NULL,NULL,NULL,NULL,NULL,N'EventType',NULL,0,80,30,NULL,0,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@DataQueryId,N'AgentName',N'Text',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,170,40,NULL,0,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@DataQueryId,N'ReferenceData',N'Text',N'ReferenceData',NULL,NULL,NULL,NULL,NULL,N'ReferenceData',NULL,0,160,50,NULL,0,NULL)
  
 END
GO








