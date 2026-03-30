/**/
:setvar FS_CUSTOM FS_CUSTOM
:setvar ICC ICC

:setvar ICC_Backup ICC_Backup
--:setvar ICC_Backup FS_Custom -- Pro @LowPermission=1
DECLARE @LowPermission AS bit = 0 -- 0 = normální opránění, 1 = nízké oprávnění

--
IF @LowPermission = 0
BEGIN
IF  NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'Icc_Backup')
    BEGIN
      CREATE DATABASE [Icc_Backup]
    END
IF NOT EXISTS (SELECT * FROM [Icc_Backup].SYS.EXTENDED_PROPERTIES WHERE Name = 'description')
    EXEC [Icc_Backup].sys.sp_addextendedproperty @name=N'description', @value=N'BackUp of iCC config tables or manually changed records'
IF  NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'Icc_Catalog')
    BEGIN
        CREATE DATABASE [Icc_Catalog]
    END
IF NOT EXISTS (SELECT * FROM [Icc_Catalog].SYS.EXTENDED_PROPERTIES WHERE Name = 'description')
    EXEC [Icc_Catalog].sys.sp_addextendedproperty @name=N'description', @value=N'Catalog of Frontstage moduls'
END
--ELSE


--GO /**/
USE $(FS_CUSTOM)
GO
-- Mode is by using a combination of keys ALT+Q+M

/****** Object:  StoredProcedure [dbo].[CheckRecAndEmlActivity2]    Script Date: 27. 8. 2019 12:54:19 ******/
-- Rekonfigurace EventLog:

/****** Object:  Table [dbo].[Eventlog]    Script Date: 28. 6. 2016 12:12:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF object_id('CheckRecAndEmlActivity2') IS NOT NULL
 DROP  PROCEDURE  [dbo].CheckRecAndEmlActivity2
GO

/* ===================================  S T A R T    O F   M A I N   P R O C E D U R E  ============================= */


-- Upravil ZbH 17.7.2018
-- Nyní probíhá stálé zdokonalování funkce
CREATE
--ALTER
 PROCEDURE [dbo].[CheckRecAndEmlActivity2] 
AS
BEGIN
  	declare @ProcVer as nvarchar(35) = ' Verze kontrolní funkce: 27.5.2020'
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
	(SELECT TOP 1 MessageId FROM $(ICC).[dbo].[Message] WITH (NOLOCK)
	   WHERE Direction='O' AND MessageType='Email' AND ReceivedSentTime IS NOT NULL AND GatewayId IS NOT NULL ORDER BY ReceivedSentTime DESC)
	 declare @GW as uniqueidentifier = (SELECT TOP 1 [GatewayId] FROM $(ICC).[dbo].[Message] WITH (NOLOCK) WHERE MessageId=@MessageId)
	 declare @GWN as nvarchar(150) = (SELECT TOP 1 PilotAddress FROM $(ICC).[dbo].[Gateway] WITH (NOLOCK) WHERE GatewayId=@GW)
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
    DECLARE @RemoteAddress AS NVARCHAR(100)
	DECLARE @ResultData AS NVARCHAR(100)
	DECLARE @Pocet AS Integer
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
	IF(EXISTS(SELECT * FROM $(ICC).dbo.Holiday as H WITH (NOLOCK) where H.HolidayGroupName=@Holiday AND H.TimeMode='SingleDay' AND CAST(H.TimeFrom as DATE)=CAST(@Today AS DATE))) RETURN
	IF(EXISTS(SELECT * FROM $(ICC).dbo.Holiday as H WITH (NOLOCK) where H.HolidayGroupName=@Holiday AND H.TimeMode='DayInYear' AND DATEPART(DAY,H.TimeFrom)=DATEPART(DAY,@Today) AND DATEPART(MONTH,H.TimeFrom)=DATEPART(MONTH,@Today))) RETURN
	-- Pokud tam jsou mé neodeslané maily mladší 24hodin, neodesílám další
	IF(EXISTS(SELECT * FROM $(ICC).dbo.Message as M WITH (NOLOCK) where M.Messagetype='Email' AND MessagePhase='Scheduled' AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE()))) RETURN


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
	declare @RecNow as int = (select count(*) from SRec.dbo.VoiceRecord as R WITH (NOLOCK) where R.EndTimeUtc<=@Now AND R.EndTimeUtc>=@Last) -- Počet nahrávek za posledních 30 minut
	declare @RecWeekAgo as int = (select count(*) from SRec.dbo.VoiceRecord as R WITH (NOLOCK) where R.EndTimeUtc<=@WeekAgo AND R.EndTimeUtc>=@LastWeekAgo) -- Počet nahrávek za 30 minut před týdnem
	IF ISNULL(@RecWeekAgo,0)=0
	  BEGIN
	    SET @RecWeekAgo=5
	  END
   --  SET @RecNow=0 -- Pro ladění
	declare @InCalls as int = (SELECT Count(*) FROM $(ICC).dbo.InboundCall as I WITH(NOLOCK) WHERE I.TimeUtc>=@Last AND I.TimeUtc<=@Now AND I.CallDuration>1 AND CallResult='Served')
	--                                                                                                                                                                                 Odchozí hovory automatu nejsou nahrávány
	declare @OutCalls as int = (SELECT Count(*) FROM $(ICC).dbo.OutboundCall as O WITH(NOLOCK) WHERE O.ScheduleTime>=@Pred15min AND O.ScheduleTime<=@Today AND O.CallDuration>1 AND CallResult<>'Active' AND O.AgentId IS NOT NULL)

	declare @Last10 as datetime = DATEADD(MINUTE, -10, @Now )

	declare @Predist30Now as int = (select count(*) from $(ICC).dbo.OutboundCall as O WITH (NOLOCK) where O.TimeUtc<=@Now AND O.TimeUtc>=@Last10 AND Predistributed=1 AND DATEDIFF(ss,O.EnqueueingTime,O.DistributionTime)>30)
	declare @Predist10Now as int = (select count(*) from $(ICC).dbo.OutboundCall as O WITH (NOLOCK) where O.TimeUtc<=@Now AND O.TimeUtc>=@Last10 AND Predistributed=1 AND DATEDIFF(ss,O.EnqueueingTime,O.DistributionTime)>10)

	declare @T as nvarchar(120) = CONVERT(nvarchar(20), DATEADD(MINUTE, -@Interval, @Today), 20) + ' - ' + CONVERT(nvarchar(20), @Today, 8)

    -- Kontrola nahrávek:
	IF @Debug=1 OR @GW IS NOT NULL AND (((@RecNow<@RecWeekAgo/5 OR @RecNow=0) AND @RecWeekAgo>0)  AND (@InCalls+@OutCalls>0) AND ((@InCalls+@OutCalls)>@RecNow))
	BEGIN
	  IF (@InCalls>0 AND .dbo.CustomCheck('IC',@Last)=1) OR (@OutCalls>0 AND .dbo.CustomCheck('OC',@Last)=1)
	   BEGIN
		SET @EmlMsg = 'T=' + @T + ' R- for last ' + CONVERT(nvarchar(10),@Interval) + ' min ='+ CONVERT(nvarchar(10),@RecNow) + ' R-weekago this time =' + CONVERT(nvarchar(10),@RecWeekAgo)
		SET @Specif = CONVERT(nvarchar(10),@RecNow)
		EXEC [dbo].[ErrorLogProc] 'nízký počet nahrávek',@Specif,@ProcVer,@EmlMsg,10,5
		/*
		insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,'Email','Scheduled','Active', @GWN, @TGT,@TGT,  @TOCC ,@GW,99,'O',
		'nízký počet nahrávek ' + CONVERT(nvarchar(10),@RecNow)+@ProcVer, @EmlMsg, @EmlMsg, @Mark )*/
       END
	END
  END
	------------------------------------------------------------------------------------
	-- Kontrola mailů:
	declare @EmlNow as int = (select count(*) from $(ICC).dbo.Message as M WITH (NOLOCK) where M.Direction='I' AND M.MessageType='Email' AND M.TimeUtc<=@Now AND M.TimeUtc>=@Last)
	declare @EmlWeekAgo as int = (select count(*) from $(ICC).dbo.Message as M WITH (NOLOCK) where M.Direction='I' AND M.MessageType='Email' AND  M.TimeUtc<=@WeekAgo AND M.TimeUtc>=@LastWeekAgo)


	IF @Debug=1 OR (@GW IS NOT NULL AND (@EmlNow<@EmlWeekAgo/5 AND @EmlNow<@EmlWeekAgo-10) AND @EmlWeekAgo>1) 
	 BEGIN
	    SET @EmlMsg = 'T=' + @T + ' E-now='+ CONVERT(nvarchar(10),@EmlNow) + ' E-weekago=' + CONVERT(nvarchar(10),@EmlWeekAgo)
		-- Možná byl minulý týden výjimečný - tak porovnám ještě údaje před dvěma týdny
		declare @Eml2WeeksAgo as int = (select count(*) from $(ICC).dbo.Message as M WITH (NOLOCK) where M.Direction='I' AND M.MessageType='Email' 
		  AND  M.TimeUtc<=DATEADD(Day,-7,@WeekAgo) AND M.TimeUtc>=DATEADD(Day,-7,@LastWeekAgo))
		IF (@EmlNow<@Eml2WeeksAgo/5 AND @EmlNow<@Eml2WeeksAgo-10 AND @Eml2WeeksAgo>1)
		  BEGIN		 
		    SET @Specif = CONVERT(nvarchar(10),@EmlNow)
		    EXEC [dbo].[ErrorLogProc] 'nízký počet příchozích emailů',@Specif,@ProcVer,@EmlMsg,2,60
		  END
	
	 END
	  -- Kontrola chyb v MessageEvent
		  SET @EmlMsg = (SELECT TOP 1 [ResultData] FROM $(ICC).[dbo].[MessageEvent] WITH (NOLOCK) WHERE EventType='Failure' AND TimeLocal>@OneHourAgo)
		  IF (@EmlMsg IS NOT NULL)
		    BEGIN		 
		      SET @Specif = ''
			  SET @EmlMsg = 'Maily: '+@EmlMsg 
		      EXEC [dbo].[ErrorLogProc] @EmlMsg,@Specif,@ProcVer,@EmlMsg,0,60
		    END

    IF @GW IS NOT NULL  
	 BEGIN
	   DECLARE @NoSent as int = (select count(*) from $(ICC).dbo.Message as M WITH (NOLOCK) where M.Direction='O' AND (MessagePhase='Scheduled' OR MessagePhase='Failed') AND M.MessageType='Email' AND M.TimeUtc<=@Last AND M.TimeUtc>=@DayAgo
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
		   -- Pokusím se zjistit důvod neodeslání

			select TOP 1 @RemoteAddress=RemoteAddress,@ResultData=ResultData from $(ICC).dbo.Message as M WITH (NOLOCK) 
			   LEFT JOIN $(ICC).dbo.MessageEvent as ME WITH (NOLOCK) ON M.MessageId=ME.MessageId AND EventType='Ndr'
			where M.Direction='O' AND (MessagePhase='Scheduled' OR MessagePhase='Failed') AND M.MessageType='Email' AND M.TimeUtc<=@Last AND M.TimeUtc>=@DayAgo
			IF @RemoteAddress IS NOT NULL
			  BEGIN
				SET @Specif = 'na adresu= '+@RemoteAddress
				EXEC [dbo].[ErrorLogProc] 'nedoručitelná zpráva',@Specif,@ProcVer,@ResultData,0,240
			  END
            ELSE
			  BEGIN
				SET @Specif = ', počet='+ CONVERT(nvarchar(10),@NoSent)
				EXEC [dbo].[ErrorLogProc] 'neodeslané emaily',@Specif,@ProcVer,@EmlMsg,2,60
							-- Pokusím se problém vyřešit
				UPDATE $(ICC).[dbo].[Message] SET MessageResult='Active'
				 WHERE  TimeUtc>@Yesterday AND Direction='O' AND MessagePhase='Scheduled' AND MessageResult='Closed' -- Pokud agent zadal odeslání uzavřeného mailu
			  END

          END
		-- Kontrola zapomenutých mailů
        IF (.dbo.CustomCheck('MN',@WeekAgo)>0)
		 BEGIN
		   SET @Specif = ''
		   EXEC [dbo].[ErrorLogProc] 'nepřijaté příchozí emaily',@Specif,@ProcVer,@EmlMsg,0,1440
         /*
	      SET  @EmlMsg='Prosím o kontrolu'
	      insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		  values(@Now,'Email','Scheduled','Active', @GWN, @TOCC,@TOCC,@GW,99,'O',
		  ' Varování: nepřijaté příchozí emaily' + @ProcVer, @EmlMsg, @EmlMsg, @Mark ) */
        END
		-- Kontrola mailů přodělených agentům, kteří nejsou v práci
        IF (.dbo.CustomCheck('NV',@WeekAgo)>0)
		 BEGIN
		   SET @Specif = ''
		   EXEC [dbo].[ErrorLogProc] 'maily přidělené agentům, kteří nejsou v práci',@Specif,@ProcVer,@EmlMsg,0,1440
         /*

	      SET  @EmlMsg='Prosím o kontrolu'
	      insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		  values(@Now,'Email','Scheduled','Active', @GWN, @TOCC,@TOCC,@GW,99,'O',
		  ' Varování: maily přidělené agentům, kteří nejsou v práci' + @ProcVer, @EmlMsg, @EmlMsg, @Mark ) */
        END




	 END
	------------------------------------------------------------------------------------
	-- Kontrola přiřazování mailů do případů (AssignMailOfIssue):
   IF EXISTS(SELECT 1 FROM $(ICC).[dbo].[ActionTrigger] WHERE Suspended=0 AND Deleted=0 AND CommandText LIKE 'AssignMailOfIssue')
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
 SELECT  [Number] FROM [ProServer].[dbo].[Extension] WITH (NOLOCK)
  WHERE OnLineStatus<>10 AND OnLineStatus<>0 AND Deleted=0 AND Suspended=0 AND Description NOT LIKE '%SoftPhone%'
  -- ExtensionNotAlive = 7
   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @Number   
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @Number IS NOT NULL 
		BEGIN
			  SET @EmlMsg='Prosím o kontrolu'
			  SET @Subject='linka '+@Number+' není ve stavu OK na ProServeru'
			  SET @Specif = ''
			  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,1000
		END
		FETCH NEXT FROM My_cursor INTO @Number  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;
--------------------------------------------------------------------------------------------------------------------------------------
	 -- Kontrola linek/pracovišť
    DECLARE @WPOK AS Integer=(SELECT TOP 1 1 FROM $(ICC).[dbo].[Workplace] WITH (NOLOCK) WHERE State<>'OutOfOrder')

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
    DECLARE @WorkplaceId as uniqueidentifier=(SELECT TOP 1 WorkPlaceId FROM $(ICC).[dbo].[Agent] where AgentId=@AgentId)
    DECLARE @TimeUTC as Datetime = (SELECT TOP 1 TimeUTC FROM $(ICC).[dbo].[AgentEvent] where EventType='AgentStatus' AND AgentId=@AgentId ORDER BY EventType,AgentId,TimeUTC DESC)
	IF DATEDIFF(Hour,@TimeUTC,GETUTCDATE())>4 AND EXISTS (SELECT TOP 1  AG.[AgentId] FROM $(ICC).[dbo].[Seating] AS SEA WITH (NOLOCK) 
      INNER JOIN $(ICC).[dbo].[Agent] AS AG WITH (NOLOCK) ON SEA.AgentId=AG.AgentId WHERE SEA.WorkPlaceId=@WorkplaceId AND AG.TeamName<>'ADMIN')
	    BEGIN
		  SET @AgentName = RTRIM((SELECT TOP 1 DisplayName FROM $(ICC).[dbo].[Agent] where AgentId=@AgentId))
		  SET @EmlMsg='Odhlašuji Admina'
		  SET @Subject='Admin '+@AgentName+' byl přihlášen a blokoval agentům pracoviště.'
		  SET @Specif = ISNULL((SELECT Displayname FROM $(ICC).dbo.Workplace WHERE WorkplaceId=@WorkplaceId),'')
		  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,180
          EXEC FS_CUSTOM.dbo.LogOffAgent @AgentId
		END	  
   END

   -- Kontrola odhlašování agenta díky poruše pracoviště 
    SELECT Top 1 @AgentName =AgentName,@Pocet=Pocet FROM (
	SELECT TOP (10)  AG.DisplayName AS AgentName,COUNT(1) AS Pocet FROM $(ICC).[dbo].[AgentEvent] AE LEFT JOIN $(ICC).[dbo].[Agent] AG ON AG.AgentId=AE.AgentId
    WHERE TimeLocal > DATEADD(Hour,-2,GETDATE())  AND ReferenceData='Logoff' AND Actor='Distribution' AND AE.ResultData='Phone'
	GROUP BY AG.DisplayName) AS Phase1
	  ORDER BY Pocet DESC

   IF @Pocet > 2 
   BEGIN
      SET @WorkplaceId =(SELECT TOP 1 WorkPlaceId FROM $(ICC).[dbo].[Agent] WITH (NOLOCK) where DisplayName=@AgentName)
 		  SET @EmlMsg='Prosím o kontrolu'
		  SET @Subject='Agent '+@AgentName+' je odhlašován. Jeho pracoviště má zřejmě poruchu.'
		  SET @Specif = ISNULL((SELECT Displayname FROM $(ICC).dbo.Workplace WHERE WorkplaceId=@WorkplaceId),'')
		  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,220
   END

    -- Kontrola chyb v IssueCondition:
	
SELECT TOP 1 @String1=ISUC.[DisplayName],@String2=TPC.DisplayName FROM $(ICC).[dbo].[IssueCondition] ISUC WITH (NOLOCK)
  LEFT JOIN $(ICC).[dbo].[Topic] TPC WITH (NOLOCK) ON TPC.TopicId=ISUC.NormalTopicId
  WHERE ISUC.NormalTopicId IS NOT NULL AND TPC.TopicId IS  NULL OR TPC.Deleted=1

  IF @String2 IS NOT NULL
   BEGIN
  		  SET @EmlMsg='Prosím o kontrolu'
		  SET @Subject='Pravidlo případu '+@String1+' používá chybné/smazané téma '+@String2
		  SET @Specif = ''
		  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,600
   END

  -- Kontrola synchronizačních procedur atd.
  DECLARE @Procedura AS NVARCHAR(50)
  DECLARE @Popis AS NVARCHAR(900)
  DECLARE @DatumCas AS Datetime
  DECLARE @Severity AS Integer
DECLARE My_cursor CURSOR FOR   
 SELECT DISTINCT TOP 10 Procedura,Popis,DatumCas  FROM .[dbo].[Eventlog] WITH (NOLOCK) WHERE DatumCas>@Yesterday AND (Popis='Vstupní bod' OR Procedura='SystemTests')
   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @Procedura,@Popis,@DatumCas    
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @Procedura  IS NOT NULL
		BEGIN
	       IF @Procedura='SystemTests' OR
		   NOT EXISTS(SELECT TOP 1 Procedura  FROM .[dbo].[Eventlog] WITH (NOLOCK) WHERE DatumCas>@Yesterday AND Popis='Konec procedury' AND Procedura=@Procedura)
		     BEGIN
			  SET @Severity=IIF(LEFT(@Popis,15)='Warning : Drive',1,0)
			  SET @EmlMsg='Prosím o kontrolu'
			  SET @Subject=IIF(@Procedura='SystemTests',IIF(@Severity=1,LEFT(@Popis,17),@Popis),' Procedura: '+RTRIM(@Procedura)+' neprobíhá do konce.')
			  SET @Specif = IIF(@Severity=1,SUBSTRING(@Popis,18,50),'')
			  IF @Severity=0 OR @DatumCas>DATEADD(Hour,-2,GETDATE())
			    EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,@Severity,1000

			 END
		END
		FETCH NEXT FROM My_cursor INTO @Procedura,@Popis,@DatumCas  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;

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
		SET @Specif = ' - DB Server: Na disku '+@DiskName+' je méně než 15GB volného místa'
		EXEC [dbo].[ErrorLogProc] 'Warning : Drive',@Specif,@ProcVer,@EmlMsg,10,120

     END

END
GO --------------------- 

--------------------- Pomocné tabulky   ---------------------
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

  IF OBJECT_ID (N'Eventlog', N'U') IS NULL 
CREATE TABLE [dbo].[Eventlog](
	[DatumCas] [datetime] NULL,
	[Procedura] [nchar](20) NULL,
	[Popis] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

IF OBJECT_ID (N'Results', N'U') IS NULL 
CREATE TABLE [dbo].[Results](
	[AgentId] [uniqueidentifier] NULL,
	[TimeLocal] [Datetime] NULL,
	[Message] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
IF OBJECT_ID (N'Commands', N'U') IS NULL 
CREATE TABLE [dbo].[Commands](
	[Command] [nvarchar](150) NULL,
	[Description] [nvarchar](150) NULL,
	[CommandId] [uniqueidentifier] NOT NULL DEFAULT (newid())
) ON [PRIMARY]

GO

IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE CommandId  = 'ee859402-15e9-48cc-802b-f40d9258b92e')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC FS_Custom.dbo.CancelZombieCalls', N'Close Inbound Calls which are longer time in distribution', N'ee859402-15e9-48cc-802b-f40d9258b92e')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE CommandId  = '62e84a06-6f83-4594-9ccd-a756a096d3b3')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC FS_Custom.dbo.InspectIVR', N'Look for errors in IVR', N'62e84a06-6f83-4594-9ccd-a756a096d3b3')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE CommandId  = 'ee118948-03ea-4d0c-9f03-754fcf195980')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC FS_Custom.dbo.SendEmails 3', N'Send e-mails in failed status', N'ee118948-03ea-4d0c-9f03-754fcf195980')
GO

IF object_id('HolidayPlan') IS NULL
  BEGIN
	CREATE TABLE [dbo].[HolidayPlan](
		[RelId] UniqueIdentifier NULL,
		[HolidayGroupName] [nvarchar](100) COLLATE Czech_CI_AS NULL
	) ON [PRIMARY] 
  END
GO

IF .dbo.CustomCheck('IC',GETDATE())=0
   PRINT 'CustomCheck vrací 0 - opravit!!!!'
/* CREATE ignorovalo klauzuli COLLATE, tak jsem to napravil takto
ALTER TABLE $(FS_Custom).dbo.HolidayPlan 
ALTER COLUMN [HolidayGroupName] [nvarchar](100)  COLLATE Czech_CI_AS NULL
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

  UPDATE dbo.ErrorLog SET  Message=REPLACE(REPLACE(Message,'Varování: ',''),'Varování:','') WHERE Message LIKE 'Varování:%'
  GO

-------------------------------------------------------------
--------------------- Podpůrné procedury --------------------
-------------------------------------------------------------

-------------------------------------------------------------
IF object_id('SendEmails') IS NOT NULL
 DROP  PROCEDURE  [dbo].[SendEmails]
GO

CREATE PROCEDURE [dbo].[SendEmails]
@DaysCount Int

AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <21.5.2020>
-- Description:	<Pokus o odeslání mailů, které selhaly>
-- =============================================

BEGIN
DECLARE @from AS datetime = GETDATE()-@DaysCount

UPDATE $(iCC).[dbo].[Message]
  SET MessagePhase='Scheduled'
  WHERE 1=1
    AND TimeUtc>@From
    AND Direction='O'
    AND MessagePhase='Failed'

UPDATE $(iCC).[dbo].[Message]
  SET ScheduledTime=DATEADD(ss,10,GETDATE())
  WHERE 1=1
    AND TimeUtc>@From
    AND Direction='O'
    AND MessagePhase='Scheduled'
	AND ScheduledTime>DATEADD(ss,60,GETDATE())
    

END

GO

IF object_id('DelEventlog') IS NOT NULL
 DROP  PROCEDURE  [dbo].[DelEventlog]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <15.06.2017>
-- Description:	<Mazání Eventlogu>
-- =============================================
CREATE PROCEDURE [dbo].[DelEventlog]

AS
BEGIN
  DELETE FROM [dbo].[Eventlog] WHERE DatumCas<GETDATE()-90
END
GO

IF object_id('WriteEvent') IS NOT NULL
 DROP  PROCEDURE  [dbo].WriteEvent
GO

CREATE PROCEDURE [dbo].[WriteEvent] (@Loguj AS bit, @ProcName AS nchar(20), @popis as nvarchar(MAX) )
AS
BEGIN
  IF @Loguj=1
	--DECLARE @MessageId AS UniqueIdentifier='A3899D5B-CF36-E611-80F1-F8BC1253A1A4'
	insert into .[dbo].[Eventlog] (DatumCas, Procedura, Popis) values(GETDATE(), @ProcName, @popis)
  --END
END
GO

IF object_id('LogOffAgent') IS NOT NULL
 DROP  PROCEDURE  [dbo].LogOffAgent
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <15.11.2018>
-- Description:	<Odhlašuje určeného agenta>
-- =============================================
CREATE PROCEDURE [dbo].[LogOffAgent]
@AgentId UniqueIdentifier
AS
BEGIN
 IF EXISTS(SELECT 1 FROM iCC.dbo.Agent WHERE Agentid=@AgentId AND Activity<>'Logoff')
  BEGIN
    DECLARE @LogoffId UniqueIdentifier = (SELECT TOP 1 [StatusId] FROM [iCC].[dbo].[Status] WHERE Activity='Logoff')
    INSERT iCC.dbo.ChangeRequest( ChangeRequestTimeUtc , Command , SubjectId, ReferenceId)
    VALUES (GETUTCDATE(),N'AgentStatus',@AgentId,@LogoffId)
  END
  -- Ještě zápis protokolu
  --EXEC .dbo.ZapisProtok1 @Hlaska
 END


GO

IF object_id('TimeUTC_Local') IS NOT NULL
 DROP  FUNCTION  [dbo].TimeUTC_Local
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <15.3.2016>
-- Description:	<Převádí TimeUTC na Timelocal>
-- =============================================

CREATE FUNCTION [dbo].[TimeUTC_Local](@TimeUTC as DateTime)
RETURNS DateTime
AS
BEGIN
	DECLARE @Offset as int
	IF @TimeUTC>=CONVERT(datetime,'2015.03.29 01:00') AND @TimeUTC<=CONVERT(datetime,'2015.10.25 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2016.03.27 01:00') AND @TimeUTC<=CONVERT(datetime,'2016.10.30 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2017.03.26 01:00') AND @TimeUTC<=CONVERT(datetime,'2017.10.29 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2018.03.25 01:00') AND @TimeUTC<=CONVERT(datetime,'2018.10.28 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2019.03.31 01:00') AND @TimeUTC<=CONVERT(datetime,'2019.10.27 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2020.03.29 01:00') AND @TimeUTC<=CONVERT(datetime,'2020.10.25 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2021.03.28 01:00') AND @TimeUTC<=CONVERT(datetime,'2021.10.31 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2022.03.27 01:00') AND @TimeUTC<=CONVERT(datetime,'2022.10.30 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2023.03.26 01:00') AND @TimeUTC<=CONVERT(datetime,'2023.10.29 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2024.03.31 01:00') AND @TimeUTC<=CONVERT(datetime,'2024.10.27 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2025.03.30 01:00') AND @TimeUTC<=CONVERT(datetime,'2025.10.26 02:00') 
	  SET @Offset = 2
	ELSE
	  SET @Offset = 1
	RETURN DATEADD(Hour,@Offset,@TimeUTC)
END
--
GO

IF object_id('PridejPravaPoslechu') IS NOT NULL
 DROP  PROCEDURE  [dbo].PridejPravaPoslechu
GO


CREATE PROCEDURE [dbo].[PridejPravaPoslechu]
--@OCId UniqueIdentifier 
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <6.6.2017>
-- Description:	<Doplnění práv pro poslech vlastních hovorů>
-- =============================================

BEGIN

DECLARE @DisplayName AS nvarchar(120)
DECLARE @SystemName AS nvarchar(200)
DECLARE @AccountId AS UniqueIdentifier
DECLARE @RoleId AS UniqueIdentifier=(SELECT TOP 1 [RoleId] FROM [SRec].[dbo].[Role] WHERE SystemName='AccessRecordByAgent')
DECLARE @ScopeId AS UniqueIdentifier
DECLARE @Degree AS Integer=1
DECLARE @Pokracuj AS bit = 1


IF OBJECT_ID (N'#TEMP', N'U') IS NOT NULL DROP TABLE #TEMP
SELECT SystemName into #TEMP from $(ICC).dbo.Agent WHERE Deleted=0 and Template=0 AND SystemName IS NOT NULL

WHILE (@Pokracuj = 1) 
 BEGIN  
   SET @SystemName = (SELECT TOP 1 *  from #TEMP)
   IF @SystemName IS NULL SET @Pokracuj = 0
   ELSE
     BEGIN   
	   -- Ověřím, zda existuje uživatel v SREC
	   SET @AccountId = (SELECT TOP 1 AccountId FROM [SRec].[dbo].[Account] WHERE SystemName=@SystemName)
	   -- Ověřím, zda má uživatel již nastavená práva
	   IF @AccountId IS NULL 
		 BEGIN
		   SET @DisplayName = (SELECT  TOP 1 DisplayName From $(ICC).dbo.Agent WHERE SystemName=@SystemName)
		   INSERT INTO [SRec].[dbo].[Account]
			   (
				[SystemName]
			   ,[DisplayName])
		   VALUES
			   (
			   @SystemName,
			   @DisplayName)
           SET @AccountId = (SELECT TOP 1 AccountId FROM [SRec].[dbo].[Account] WHERE SystemName=@SystemName)         
		 END

       IF NOT EXISTS(SELECT TOP 1 [PermissionId] FROM [SRec].[dbo].[Permission] WHERE AccountId=@AccountId)
	    BEGIN
		  -- Ještě zkontroluji ScopeId
		  SET @ScopeId = (SELECT TOP 1 ScopeId FROM [SRec].[dbo].[Scope] WHERE ReferenceData=@SystemName)
          IF @ScopeId IS NULL
		    SET @DisplayName = (SELECT  TOP 1 DisplayName From $(ICC).dbo.Agent WHERE SystemName=@SystemName)
		    BEGIN

              INSERT INTO [SRec].[dbo].[Scope]
				   (
				   [DisplayName]
				   ,[MyGroup]
				   ,[MyTeam]
					,[ReferenceData])
			  VALUES
				   (
				   'Omezeni '+@DisplayName
				   ,0
				   ,0
				   ,@SystemName
				   )
			  SET @ScopeId = (SELECT TOP 1 ScopeId FROM [SRec].[dbo].[Scope] WHERE ReferenceData=@SystemName)
			END

			INSERT INTO [SRec].[dbo].[Permission]
			   (
				[RoleId]
			   ,[AccountId]
			   ,[Degree]
			   ,[ScopeId])
			VALUES
			   (
				@RoleId, 
				@AccountId,
				@Degree,
				@ScopeId)
		    PRINT 'Byla přidána práva poslechu pro '+@DisplayName
		  END
			--BREAK
		 END
	   DELETE FROM #TEMP WHERE SystemName=@SystemName
	 END
 END

GO



IF object_id('RunScript') IS NOT NULL
 DROP  PROCEDURE  [dbo].RunScript
GO

CREATE PROCEDURE [dbo].[RunScript]
@RecId UniqueIdentifier
--@MEAgentId UniqueIdentifier
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <3.5.2017>
-- Description:	<Spuštění zvolené funkce z nabídky v Admin aplikaci>
-- V příkazu ImageScript patrně @MEAgentId neexistuje
-- =============================================

BEGIN
--DECLARE @MeAgentId AS uniqueidentifier=NewId() 
DECLARE @Command AS nvarchar(150) = (SELECT Command FROM $(FS_CUSTOM).[dbo].[Commands] WHERE CommandiD=@RecId) --+' '+''''+CONVERT(NVARCHAR(36),@MEAgentId)+''''
EXEC (@Command) 
END

GO

IF object_id('IsHoliday') IS NOT NULL
 DROP  FUNCTION  [dbo].[IsHoliday]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <8.2.2016>
-- Description:	<říká, zda spadá zadaný čas do svátku>
-- =============================================
CREATE FUNCTION [dbo].[IsHoliday]
(
	-- Add the parameters for the function here
	@MyDatime as Datetime,
	@HolidayGroupName AS NVARCHAR(50)='OUT_OF_OFFICE'
)
RETURNS integer
AS
BEGIN
	DECLARE @isHol as integer = 0
	IF EXISTS((SELECT * FROM
	(SELECT TimeFrom AS Start, TimeTo AS MyEnd FROM  $(ICC).dbo.Holiday WHERE HolidayGroupName=@HolidayGroupName and TimeMode='SingleDay'
	   UNION
	SELECT DATEADD(YEAR,YEAR(@MyDatime) - YEAR(TimeFrom),TimeFrom) AS Start, DATEADD(YEAR,YEAR(@MyDatime) - YEAR(TimeTo),TimeTo) AS MyEnd
    FROM  $(ICC).dbo.Holiday WHERE HolidayGroupName=@HolidayGroupName and TimeMode='DayInYear') AS Holidays
	   WHERE @MyDatime>=Start and @MyDatime<=MyEnd))
	BEGIN
	  SET @isHol = 1  -- Je svátek
	END
	RETURN @isHol

END
GO

IF object_id('SelectPhBook') IS NOT NULL
 DROP  PROCEDURE  [dbo].SelectPhBook
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <12.05.2017>
-- Description:	<Volba telefonního seznamu>
-- =============================================
CREATE PROCEDURE [dbo].[SelectPhBook]
@RecordId UniqueIdentifier
AS
BEGIN
--DECLARE @MyAgentId AS UniqueIdentifier = 'ffee47c8-da99-47d3-b4e2-ca92b624ac95' -- Admin ID
   EXEC .dbo.WriteParam  N'SELECTEDPHONEBOOK',@RecordId,N'Zvolený telefonní seznam'
END
GO


IF object_id('PutPNIntoPhBook') IS NOT NULL
 DROP  PROCEDURE  [dbo].PutPNIntoPhBook
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <1.06.2017>
-- Description:	<Vloží­ zvolené tel. číslo do vybraného telefonní­ho seznamu>
-- =============================================
CREATE PROCEDURE [dbo].[PutPNIntoPhBook]
@PhoneNumberId UniqueIdentifier
AS
BEGIN
--DECLARE @MyAgentId AS UniqueIdentifier = 'ffee47c8-da99-47d3-b4e2-ca92b624ac95' -- Admin ID
--DECLARE @ConfigurationId AS UniqueIdentifier
DECLARE @ConfigurationName AS NVARCHAR(50) = 'SELECTEDPHONEBOOK'
DECLARE @PhoneBookId AS UniqueIdentifier=CONVERT(UniqueIdentifier,$(FS_CUSTOM).dbo.GiveParam(@ConfigurationName))
  IF @PhoneBookId IS NOT NULL
   BEGIN
-- Podívám se, zda se číslo v seznamu již nenachází
   DECLARE @PhoneCompositionId AS UniqueIdentifier=(SELECT PhoneCompositionId FROM [iCC].[dbo].[PhoneComposition]  WHERE PhoneBookId=@PhoneBookId AND PhoneNumberId=@PhoneNumberId)
    IF @PhoneCompositionId IS NULL
	  BEGIN
	    INSERT INTO $(ICC).[dbo].[PhoneComposition]
           ([PhoneBookId],[PhoneNumberId])
        VALUES (@PhoneBookId,@PhoneNumberId)
	  END
     ELSE
	  DELETE FROM $(ICC).dbo.[PhoneComposition] WHERE PhoneCompositionId=@PhoneCompositionId -- Odstranění čísla z telefonního seznamu
	END
END
GO

-------------------------------------------------------------
IF object_id('InspectIVR') IS NOT NULL
 DROP  PROCEDURE  [dbo].InspectIVR
GO


CREATE PROCEDURE [dbo].[InspectIVR]
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 19.07.2018
-- Description:	Kontroluje IVR
-- =============================================
--USE [iCC]
BEGIN
    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)
	DECLARE @Hlaska AS NVARCHAR(900) = 'Kontrola IVR: '
	DECLARE @Id AS UniqueIdentifier='013451B7-5F05-E611-80BD-001E67FEED31'
	DECLARE @PocChyb AS Integer=0
    DECLARE @Action AS nvarchar(20)
	SET @Popis = 'Start'
	EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
 IF OBJECT_ID(N'tempdb..##TEMP', N'U') IS NOT NULL DROP TABLE ##TEMP


  select IvrStepId AS Id,Action  into ##TEMP from $(ICC).dbo.IVRStep IVS WITH (NOLOCK)
   INNER JOIN $(ICC).dbo.IVRScript IV ON IV.IvrScriptId=IVS.IvrScriptId AND IV.Deleted=0
   WHERE  Action='Gosub'
    AND IVS.Deleted=0
    AND NOT EXISTS(SELECT TOP 1 1 FROM [iCC].[dbo].[IvrScript] IV WHERE IVS.TargetId=IV.IvrScriptId)
 
 INSERT INTO ##TEMP
 select IvrStepId AS Id,Action  from $(ICC).dbo.IVRStep IVS WITH (NOLOCK)
   INNER JOIN $(ICC).dbo.IVRScript IV ON IV.IvrScriptId=IVS.IvrScriptId AND IV.Deleted=0
   LEFT JOIN $(ICC).dbo.Holiday HOL ON IVS.Numbers=HOL.HolidayGroupName AND IV.Deleted=0
   WHERE  Action='Holiday'
    AND IVS.Deleted=0
    AND HOL.HolidayGroupName IS NULL
   
INSERT INTO ##TEMP
 select IVS.IvrStepId AS Id, IVS.Action  from $(ICC).dbo.IVRStep IVS WITH (NOLOCK)
   INNER JOIN $(ICC).dbo.IVRScript IV ON IV.IvrScriptId=IVS.IvrScriptId AND IV.Deleted=0
   LEFT JOIN $(ICC).dbo.IVRStep IV2 ON IV2.Rank=IVS.Targets AND IV2.IvrScriptId=IV.IvrScriptId AND IV.Deleted=0
   WHERE  IVS.Action='Goto'
    AND IVS.Deleted=0
    AND IV2.Rank IS NULL
	AND IVS.Targets IS NOT NULL AND IVS.Targets<>''
   
-- Chyba v přepojení:
 INSERT INTO ##TEMP
 select IVS.IvrStepId AS Id, IVS.Action  from $(ICC).dbo.IVRStep IVS WITH (NOLOCK)
   INNER JOIN $(ICC).dbo.IVRScript IV ON IV.IvrScriptId=IVS.IvrScriptId AND IV.Deleted=0
   WHERE  IVS.Action='SingleSteptransfer'
    AND IVS.Deleted=0
	AND (IVS.Numbers LIKE '%+%' OR LEN(Numbers)<3 OR (Numbers IS NULL AND FileName IS NULL))

-- skok na smazaný IVR Skript:
 INSERT INTO ##TEMP
 select PC.IvrStepId AS Id, PC.Action  FROM [iCC].[dbo].[IvrStep] PC
	  LEFT JOIN [iCC].[dbo].[IvrScript] IVR ON IVR.[IvrScriptId]=PC.[TargetId]
	  LEFT JOIN [iCC].[dbo].[IvrScript] IVRP ON IVRP.[IvrScriptId]=PC.[IvrScriptId]
	 WHERE PC.Deleted=0 AND IVRP.Deleted=0 AND (PC.[TargetId] IS NOT NULL AND IVR.[IvrScriptId] IS NULL OR IVR.Deleted=1) AND PC.Action='Gosub'


  
  WHILE @Id IS NOT NULL
    BEGIN
      SET @Id = (select TOP 1 Id FROM ##TEMP)
	  IF @Id IS NOT NULL
		BEGIN
		  SET @PocChyb= @PocChyb+1
		  SET @Action = (select TOP 1 Action FROM ##TEMP)
		  SET @Popis =   
            CASE
              WHEN @Action='Gosub' THEN 'Volání neexistující procedury:'
			  WHEN @Action='Holiday' THEN 'Neexistující svátek:'
			  WHEN @Action='Goto' THEN 'Skok na neexistující návěští:'
			  WHEN @Action='SingleSteptransfer' THEN 'Chybná hodnota v Numbers'
  			  ELSE ''
		    END
			SET @Popis=@Popis+.dbo.IVRStepIdent(@Id)
		  EXEC .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
		  DELETE FROM ##TEMP WHERE Id=@Id
		END
    END
	    -- Ještě zápis protokolu
	SET @Hlaska = @Hlaska+IIF(@PocChyb=0,'Chyba nenalezena','Nalezeno '+CONVERT(NVARCHAR(5),@PocChyb)+' chyb')
    EXEC .dbo.ZapisProtok1 @Hlaska

    EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, 'Konec procedury'
   DROP TABLE ##TEMP
 
 END 

GO

IF object_id('DelPerso') IS NOT NULL
 DROP  PROCEDURE  [dbo].[DelPerso]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <01.06.2017>
-- Description:	<Maže personalizaci určeného agenta>
-- =============================================
CREATE PROCEDURE [dbo].[DelPerso]
@AgentId UniqueIdentifier
AS
BEGIN
  DECLARE @AgentName AS NVARCHAR(100) = ISNULL((SELECT TOP 1 DisplayName FROM $(ICC).dbo.Agent WHERE AgentId=@AgentId),'')
  DECLARE @SystemName AS NVARCHAR(100) = ISNULL((SELECT TOP 1 SystemName FROM $(ICC).dbo.Agent WHERE AgentId=@AgentId),'')
  DECLARE @UserId AS UniqueIdentifier = (SELECT TOP 1 UserId FROM ASPNET_iCC.dbo.aspnet_Users WHERE UserName=@SystemName)
  DECLARE @Hlaska AS NVARCHAR(200) = 'Perzonalizace agenta '+@AgentName+' byla vymazána'
  DELETE FROM $(ICC).dbo.Perso WHERE AgentId=@AgentId -- Zatím jenom Perso pro Reactlient
  IF @UserId IS NOT NULL
    delete from [ASPNET_iCC].[dbo].[aspnet_PersonalizationPerUser] where UserId=@UserId

  -- Ještě zápis protokolu
  EXEC .dbo.ZapisProtok1 @Hlaska
 END

GO


IF object_id('ExistsIVRStep') IS NOT NULL
 DROP  Function  [dbo].ExistsIVRStep
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <9.3.2020>
-- Description:	<Zjišťuje, zda k určenému pťíchozímu hovoru existuje určitý IVR krok>
-- =============================================
CREATE FUNCTION [dbo].[ExistsIVRStep]
(
	-- Add the parameters for the function here
	@InboundCallId AS Uniqueidentifier
   ,@NopValue AS NVARCHAR(50)
)
RETURNS bit
AS
BEGIN
	RETURN 
  ISNULL((
  SELECT TOP 1 1 FROM $(ICC).dbo.CallEvent CAE with(nolock) 
 LEFT JOIN $(ICC).dbo.IvrStep AS IVRST with(nolock) ON IVRST.IvrStepId=CAE.ReferenceId
  WHERE  CAE.InboundCallId = @InboundCallId AND IVRST.Action='NOP' AND ResultData=@NopValue)
  ,0)

END
GO

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

IF object_id('GiveParam2') IS NOT NULL
 DROP  PROCEDURE  [dbo].[GiveParam2]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <22.4.2020>
-- Description:	<vrací hodnotu požadovaného parametru>
-- =============================================
CREATE PROCEDURE [dbo].[GiveParam2]
(
	-- Add the parameters for the function here
	@ConfigurationName AS NVARCHAR(50)
   ,@ConfigurationValue AS NVARCHAR(MAX) OUTPUT  
   ,@Description AS NVARCHAR(800)

)

AS
BEGIN
  DECLARE @ConfigurationValue2 AS NVARCHAR(MAX) = (SELECT ConfigurationValue FROM $(ICC).[dbo].[CONFIGURATION]  WHERE ConfigurationName=@ConfigurationName)
  IF @ConfigurationValue2 IS NULL
  	  EXEC [dbo].[WriteParam] @ConfigurationName,@ConfigurationValue, @Description
  ELSE
  	  SET @ConfigurationValue=@ConfigurationValue2
	RETURN 
END
GO

IF object_id('ZapisProtok1') IS NOT NULL
 DROP  Procedure  [dbo].ZapisProtok1
GO
CREATE PROCEDURE [dbo].[ZapisProtok1]
@Message AS NVARCHAR(500)
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <2.6.2017>
-- Description:	<Zapisuje protokol o výseldku akce do tabulky Results>
-- =============================================

BEGIN
	PRINT @Message
    INSERT .dbo.Results ( [AgentId], [Message], [TimeLocal])
    VALUES (NULL,@Message,GETDATE())

END
GO


IF object_id('WriteParam') IS NOT NULL
 DROP  Procedure  [dbo].[WriteParam]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17.05.2017>
-- Description:	<Zápis parametru do Configuration>
-- Test 6.5.2020
-- =============================================
CREATE PROCEDURE [dbo].[WriteParam]
 @ConfigurationName AS NVARCHAR(50),
 @ConfigurationValue AS NVARCHAR(MAX),
 @Description AS NVARCHAR(800)
AS
BEGIN
--DECLARE @MyAgentId AS UniqueIdentifier = 'ffee47c8-da99-47d3-b4e2-ca92b624ac95' -- Admin ID
    IF NOT EXISTS (SELECT ConfigurationId FROM $(ICC).[dbo].[CONFIGURATION]  WHERE ConfigurationName=@ConfigurationName)
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

IF object_id('UTL_ForceSPRecompilation') IS NOT NULL
 DROP  Procedure  [dbo].[UTL_ForceSPRecompilation]
GO

CREATE PROCEDURE [dbo].[UTL_ForceSPRecompilation]
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <19.3.2020>
-- Description:	<Kontrola/Rekompilace modulů>
-- =============================================

(
     @ModulName AS NVARCHAR(50)
	,@SearchExpr AS NVARCHAR(50)
	,@Verbose BIT = 0
)
AS
BEGIN

    --Forces all stored procedures to recompile, thereby checking syntax validity.

    DECLARE @SQL NVARCHAR(MAX)
    DECLARE @SPName NVARCHAR(255)           

    DECLARE abc CURSOR FOR
         SELECT NAME, OBJECT_DEFINITION(o.[object_id])
         FROM sys.objects AS o 
         WHERE 1=1
		 -- AND o.[type] = 'P'
		 AND OBJECT_DEFINITION(o.[object_id]) LIKE '%'+@SearchExpr+'%'
		  AND (Name=@ModulName OR @ModulName IS NULL)
         ORDER BY o.[name]

    OPEN abc

    FETCH NEXT FROM abc
    INTO @SPName, @SQL
    WHILE @@FETCH_STATUS = 0 
    BEGIN       

         SET @SQL = REPLACE(REPLACE(@SQL,'CREATE FUNCTION','ALTER FUNCTION'),'CREATE PROCEDURE','ALTER PROCEDURE')

        IF @Verbose <> 0 PRINT @SPName
		--PRINT @SQL
        EXEC(@SQL)

        FETCH NEXT FROM abc
        INTO @SPName, @SQL
    END
    CLOSE abc
    DEALLOCATE abc  

END
GO


IF object_id('SelectIVRScript') IS NOT NULL
 DROP  Procedure  [dbo].[SelectIVRScript]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <20.12.2019>
-- Description:	<Volba IVR Scriptu>
-- =============================================
CREATE PROCEDURE [dbo].[SelectIVRScript]
@RecordId UniqueIdentifier
AS
BEGIN
--DECLARE @MyAgentId AS UniqueIdentifier = 'ffee47c8-da99-47d3-b4e2-ca92b624ac95' -- Admin ID
   EXEC $(FS_CUSTOM).dbo.WriteParam  N'SELECTED_IVR',@RecordId,N'Zvolený IVR Script'
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
 declare @MessageId as uniqueidentifier = (SELECT TOP 1 MessageId FROM $(ICC).[dbo].[Message]
	   WHERE Direction='O' AND MessageType='Email' AND ReceivedSentTime IS NOT NULL AND GatewayId IS NOT NULL ORDER BY ReceivedSentTime DESC)
 declare @GW as uniqueidentifier = (SELECT TOP 1 [GatewayId] FROM $(ICC).[dbo].[Message] WHERE MessageId=@MessageId)
 declare @FromField as nvarchar(150) = (SELECT TOP 1 PilotAddress FROM $(ICC).[dbo].[Gateway] WHERE GatewayId=@GW)

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
	SET @Message='Varování: '+@Message

 IF(NOT EXISTS(SELECT * FROM $(ICC).dbo.Message as M where M.Messagetype='Email' AND MessagePhase='Scheduled' AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE())
   AND M.TimeUTC<DATEADD(Minute,-10,GETUTCDATE()))) 
	insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,'Email','Scheduled','Active', @FromField, @RemoteAddress,@RemoteAddress,  @TOCC ,@GW,99,'O',
		@Company+' '+@Message+' '+@Specif+' '+@ProcVer, @RecMsg, @RecMsg, @Mark )
/**/
     END
END
GO
IF object_id('ProServerSync_Toaster') IS NOT NULL
 DROP  Procedure  [dbo].ProServerSync_Toaster
GO

CREATE PROCEDURE [dbo].[ProServerSync_Toaster]
--@OCId UniqueIdentifier 
AS
-- =============================================
-- Author:		<Václav Kubát>
-- Create date: <6.6.2017>
-- Description:	<Doplnění práv pro Toaster>
-- =============================================

BEGIN

------------smaž úèty, které už tam jsou-----------
declare @RoleAktivniPobocky uniqueidentifier = (select RoleId from proserver.dbo.Role where SystemName = 'AllowedActive')
declare @RoleAdministrace uniqueidentifier = (select RoleId from proserver.dbo.Role where SystemName = 'AllowedAdminRights')

create table #SynchroProServer
(Login nvarchar(100)
,DisplayName nvarchar(100)
,NewAccountId uniqueidentifier
,Team nvarchar(100)
,Description nvarchar (15)
)

insert into #SynchroProServer
select a.systemname,displayname, newid(),TeamName,
case when Supervisor = 1 then 'Supervizor' else 'Agent' end as Description
from $(ICC).dbo.Agent a
left join ProServer.dbo.Credentials b on a.SystemName=b.SystemName
--=========POZOR NA PODMINKU NA TYM - DLE POTREBY UPRAVIT==========================================================================================================
where (TeamName <> 'Admin') 
--=================================================================================================================================================================
and a.Deleted=0 AND a.SystemName is not null AND b.SystemName is null

/* Původní verze VaK:
select systemname,displayname, newid(),TeamName,
case when Supervisor = 1 then 'Supervizor' else 'Agent' end as Description

--=========POZOR NA PODMINKU NA TYM - DLE POTREBY UPRAVIT========================================================================================================================================================
from $(ICC).dbo.Agent where (TeamName <> 'Admin') and Deleted=0 AND SystemName is not null
--===============================================================================================================================================================================================================

------------vymazání úètù, které už existují z docasne tabulky
delete from #SynchroProServer
where login in (select B.SystemName from ProServer.dbo.Account a left join ProServer.dbo.Credentials b on a.AccountId=b.AccountId and b.SystemName is not null and a.Deleted=0)
*/

------------- založení úètu
INSERT into ProServer.dbo.Account (AccountId,DisplayName,Description,TeamName,Deleted)
select NewAccountId, DisplayName,Description,Team,0 from #SynchroProServer

-------------vložení loginù
insert into ProServer.dbo.Credentials (CredentialsId,AccountId,Rank,SystemName,Deleted)
SELECT newid(),NewAccountId,10,Login,0 from  #SynchroProServer

---------vložení oprávnìní na Aktivní poboèky
insert into ProServer.dbo.Permission (PermissionId,RoleId,Degree,AccountId,Scope)
select newid(),@RoleAktivniPobocky,1,NewAccountId,'*' from #SynchroProServer

---------vložení oprávnìní na Administrace
insert into ProServer.dbo.Permission (PermissionId,RoleId,Degree,AccountId,Scope)
select newid(),@RoleAdministrace,1,NewAccountId,'UseChannels' from #SynchroProServer

--===================vymazavani smazanych iCC uctu v ProServer================
--nalezeni nesmazanych v iCC a vlozeni do docasne tabulky
create table #ExistsInICC
(AccountId uniqueidentifier)

Insert into #ExistsInICC
select AccountId from proserver.dbo.credentials as c with (nolock) where SystemName in (
	select SystemName from $(ICC).dbo.Agent as a with (nolock) where Deleted = 0 and SystemName is not null)

	--obnoveni nesmazanych v tabulce Credentials, kteri jsou v $(ICC).dbo.Agent
	update Proserver.dbo.Credentials 
	set Deleted = 0
	where AccountId in (select AccountId from #ExistsInICC)

	--obnoveni nesmazanych v tabulce Account, kteri jsou v $(ICC).dbo.Agent
	update Proserver.dbo.Account 
	set Deleted = 0
	where AccountId in (select AccountId from #ExistsInICC)

--nalezeni smazanych v iCC a vlozeni do docasne tabulky (kteri nejsou iCC ucet aplikace)
create table #DeletedInICC
(AccountId uniqueidentifier)

Insert into #DeletedInICC
select c.AccountId from proserver.dbo.credentials as c with (nolock)
	left join proserver.dbo.Account as a on a.AccountId = c.AccountId
	where c.SystemName in (
	select SystemName from $(ICC).dbo.Agent as a with (nolock) where Deleted = 1 and SystemName is not null)
	and not exists (select SystemName from $(ICC).dbo.Agent as a with (nolock) where Deleted = 0 and SystemName is not null)--existuje tedy pouze jako smazany a ne nekolik smazanych a i existujici login
	and a.DisplayName <> 'iCC'

	--smazani v tabulce Credentials
	update Proserver.dbo.Credentials 
	set Deleted = 1
	where AccountId in (select AccountId from #DeletedInICC)

	--smazani v tabulce Account
	update Proserver.dbo.Account 
	set Deleted = 1
	where AccountId in (select AccountId from #DeletedInICC)

--------smazání dat tabulek tabulky

drop table #SynchroProServer

drop table #ExistsInICC

drop table #DeletedInICC

END
GO

IF object_id('isOutboundImpComplete') IS NOT NULL
 BEGIN
  DROP  FUNCTION [dbo].isOutboundImpComplete
 END
 GO
 -- =============================================
-- Author:          <Zbyněk Homolka>
-- Create date: <17.2.2020>
-- Description:     <zjištuje, zda je celý import odchozí kampaně zpracován>
-- =============================================
CREATE FUNCTION [dbo].[isOutboundImpComplete]
(
       -- Add the parameters for the function here
       @OutboundListImportId as UniqueIdentifier
)
RETURNS integer
AS
BEGIN
 
RETURN ISNULL((SELECT TOP 1 0 FROM [$(ICC)].[dbo].[OutboundCall]
  WHERE 1=1  AND OutboundListImportId =@OutboundListImportId AND CallResult='Scheduled'),1)
END
GO
IF object_id('Daily_Maintenance') IS NOT NULL
 DROP  Procedure  [dbo].[Daily_Maintenance]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <12.12.2019>
-- Description:	<Denní údržba nastavení Frontstage>
-- =============================================
-- ALTER
CREATE
 PROCEDURE [dbo].[Daily_Maintenance]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Vypnuto AS NVARCHAR(5)='false'
	DECLARE @DoplnVelikonoce AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'DoplnVelikonoce', @DoplnVelikonoce OUTPUT,'Automatické doplňování velikonočních svátků'
	DECLARE @DoplnMimoPrac AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'DoplnMimoPrac',@DoplnMimoPrac OUTPUT,'Doplňování indikace mimopracovní doby'
    DECLARE @PracDobaChatu  AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'PracDobaChatu',@PracDobaChatu OUTPUT,'Provádění úprav pracovních dob chatů'
	DECLARE @DoplnproServer  AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'DoplnproServer',@DoplnproServer OUTPUT,'Doplňování nastavení ProServeru (Toaster)'
	
	DECLARE @Zprava NVARCHAR(200)= 'Vstupní bod'
   EXEC  .[dbo].[WriteEvent] 1,'Daily_Maint',@Zprava

-- Doplnění velikonoc:
   declare @Holiday as nvarchar(40) =.dbo.GiveParam('Holiday')
   IF @DoplnVelikonoce='true' AND DATEPART(MONTH,GETDATE()) <=4 AND @Holiday IS NOT NULL
     BEGIN
		 DECLARE @ROK AS Int = DATEPART(YEAR,GETDATE())
		 DECLARE @m AS Int = 24
		 DECLARE @n AS Int = 5
		 DECLARE @a AS Int = @ROK % 19
		 DECLARE @b AS Int = @ROK % 4
		 DECLARE @c AS Int = @ROK % 7
		 DECLARE @d AS Int = (19 * @a + @m) % 30
		 DECLARE @e AS Int = (@n + 2 * @b + 4 * @c + 6 * @d) % 7
		 DECLARE @POBREZEN AS Int = (22 + @d + @e)  + 1
		 --DECLARE @PABREZEN AS Int = (22 + @d + @e)  - 2
		 DECLARE @DUBEN AS Int = (@d + @e - 9) + 1
		 DECLARE @DEN AS Int 
		 DECLARE @Datum AS DateTime
		 DECLARE @MESIC AS Int 
		 DECLARE @I AS Int = 0
		 IF @DUBEN>0
		   BEGIN
			 SET @DEN=@DUBEN
			 SET @MESIC=4
		   END
		 ELSE
			BEGIN
			 SET @DEN=@POBREZEN
			 SET @MESIC=3
		   END
		  --  Vytvořím datum a čas
		  SET @Datum=CONVERT(DateTime,convert(NVARCHAR(4),@Rok)+'.'+convert(NVARCHAR(2),@Mesic)+'.'+convert(NVARCHAR(2),@DEN))
		  --SELECT @POBREZEN AS PondBrezen,@DUBEN AS Duben, @Datum
		  WHILE @i<2
		   BEGIN
		  IF NOT EXISTS(SELECT * FROM ICC.dbo.Holiday WHERE TimeFrom=@Datum AND HolidayGroupName=@Holiday)
		   INSERT INTO ICC.[dbo].[Holiday]
				   ([DisplayName]
				   ,[HolidayGroupName]
				   ,[TimeMode]
				   ,[TimeFrom]
				   ,[TimeTo]
					)
			 VALUES
				   (
				   'Velikonoce'
				   ,@Holiday
				   ,'SingleDay'
				   , @Datum 
				   , CONVERT(DateTime,SUBSTRING(CONVERT(NVARCHAR(24),@Datum,126),1,10)+' 23:59')
				   )
			  SET @Datum=DATEADD(Day,-3,@Datum)
			  SET @i=@i+1
		   END
END
-- Údržba pracovní doby Chatů
IF @PracDobaChatu='true' AND EXISTS(SELECT * FROM ICC.dbo.ChatGateCondition WHERE Signal='Closed') AND OBJECT_ID(N'$(FS_Custom)..HolidayPlan', N'U') IS NOT NULL
  BEGIN
    DECLARE @today AS Date=GETDATE()
    DECLARE @ChatWorkTime AS NVARCHAR(50)='CHATWT'
	DECLARE @ChatFrom AS DateTime
	DECLARE @ChatTo AS DateTime
	DECLARE @CharDateFrom AS NVARCHAR(24) 
	DECLARE @CharDateTo AS NVARCHAR(24)

	DECLARE @HolidayGroupName AS VARCHAR(50)
    DECLARE @RelId AS UniqueIdentifier
    DECLARE @PerformChange AS bit = 0
    DECLARE Hol_cursor CURSOR FOR SELECT  *  FROM dbo.HolidayPlan WHERE HolidayGroupName=@Holiday
	DECLARE Hol_cursor2 CURSOR FOR  SELECT  HP.HolidayGroupName,HP.RelId  FROM dbo.HolidayPlan HP
              LEFT JOIN dbo.HolidayPlan HP2 ON HP.RelId=HP2.RelId AND HP2.HolidayGroupName=@Holiday
              LEFT JOIN ICC.dbo.Holiday HO ON HP2.HolidayGroupName=HO.HolidayGroupName AND TimeMode='DayInYear' 
	             AND DATEPART(Month,@today)=DATEPART(Month,TimeFrom) AND DATEPART(Day,@today)=DATEPART(Day,TimeFrom)
				  WHERE HP.HolidayGroupName<>@Holiday AND HO.HolidayId IS NULL

    OPEN Hol_cursor 
	OPEN Hol_cursor2

  FETCH NEXT FROM Hol_cursor INTO @HolidayGroupName, @RelId   
  WHILE @@FETCH_STATUS = 0  
   BEGIN
    SET @CharDateFrom  = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeFrom FROM ICC.dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @CharDateTo = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeTo FROM ICC.dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	-- Zkontroluji, zda dnes není svátek:
	SELECT TOP 1 @ChatFrom=TimeFrom,@ChatTo=TimeTo FROM ICC.dbo.Holiday WHERE [HolidayGroupName]=@Holiday AND TimeMode='DayInYear' 
	  AND DATEPART(Month,@today)=DATEPART(Month,TimeFrom) AND DATEPART(Day,@today)=DATEPART(Day,TimeFrom)
	IF @ChatFrom IS NOT NULL
	  BEGIN
	    SET @ChatFrom = CONVERT(Datetime,@today) -- Vyrobím čas 0:00
		SET @ChatTo   = @ChatFrom
		SET @PerformChange=1
		--DELETE FROM Hol_cursor2 WHERE @RefId=RefId
		-- Teď musím do @Start a @End dosadit datumy z ChatGateCondition
		SET @ChatFrom = CONVERT(DateTime,@CharDateFrom+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatFrom,126),12,8))
		SET @ChatTo   = CONVERT(DateTime,@CharDateTo+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatTo,126),12,8))
		UPDATE [ICC].[dbo].ChatGateCondition
			SET TimeFrom=@ChatFrom,
				TimeTo  =@ChatTo 
			WHERE ChatGateConditionId=@RelId
	  END
    FETCH NEXT FROM Hol_cursor INTO @HolidayGroupName, @RelId  
  END
  -- Teď zkontroluji pracovní doby (ne svátky)
  FETCH NEXT FROM Hol_cursor2 INTO @HolidayGroupName, @RelId   
  WHILE @@FETCH_STATUS = 0  
   BEGIN
    SET @CharDateFrom  = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeFrom FROM ICC.dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @CharDateTo   = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeTo FROM ICC.dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @PerformChange  = 0
	-- v Holiday najdu pracovní dobu dnešního dne
		SELECT @ChatFrom=TimeFrom,@ChatTo=TimeTo FROM ICC.dbo.Holiday WHERE [HolidayGroupName]=@HolidayGroupName AND @today>=CONVERT(Date,TimeFrom) AND @today<=CONVERT(Date,TimeTo)
		IF @ChatFrom IS NOT NULL
		  BEGIN	   
		   -- Teď musím do @Start a @End dosadit datumy z ChatGateCondition
		   SET @ChatFrom = CONVERT(DateTime,@CharDateFrom+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatFrom,126),12,8))
		   SET @ChatTo   = CONVERT(DateTime,@CharDateTo+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatTo,126),12,8))
			UPDATE [ICC].[dbo].ChatGateCondition
			   SET TimeFrom=@ChatFrom,
				   TimeTo  =@ChatTo 
			 WHERE ChatGateConditionId=@RelId
		  END
     FETCH NEXT FROM Hol_cursor2 INTO @HolidayGroupName, @RelId  
   END
  CLOSE Hol_cursor;  
  DEALLOCATE Hol_cursor;
  CLOSE Hol_cursor2;  
  DEALLOCATE Hol_cursor2;
  END
  --------------------------------- úklid splněných importů kampaní ------------------------
  IF 1=1
    BEGIN
	  DECLARE @from1 AS datetime=DATEADD(Month,-3,GETDATE())
	  DECLARE @from2 AS datetime=DATEADD(Month,-4,GETDATE())
	    -- Nastavím importy jako neaktivní
		UPDATE [ICC].[dbo].[OutboundListImport]
		  SET  Active=0 
		WHERE Deleted=0
		AND Active=1
		AND TimeUTC<@from1
		AND $(FS_Custom).dbo.[isOutboundImpComplete](OutboundListImportId)=1
	    -- Zruším  neaktivní importy
		UPDATE  [ICC].[dbo].[OutboundListImport]
			SET Deleted=1
		   WHERE Deleted=0
			AND Active=0
			AND TimeUTC<@from2
	END

IF @DoplnproServer='true'
   BEGIN
	   EXEC PridejPravaPoslechu
	   EXEC ProServerSync_Toaster
   END

------------------------------------------------------------------------------------------------------
 IF @DoplnMimoPrac='true'
   BEGIN


-- Údržba značek MimoPracovní doby:
 --USE $(FS_CUSTOM)
 DECLARE @from AS datetime=DATEADD(Day,-6,GETDATE()) -- Jak daleko do minulosti se dívat
 DECLARE @PilotTime AS datetime
 DECLARE @InboundcallId AS UniqueIdentifier = '00000000-0000-0000-0000-000000000000'
 DECLARE My_cursor CURSOR FOR   
 SELECT /*TOP 10*/ PilotTime,IC.InboundCallId  FROM ICC.dbo.InboundCall IC WITH (NOLOCK)
   LEFT JOIN ICC.dbo.callevent ce WITH (NOLOCK) ON IC.InboundCallId=CE.InboundCallId AND CE.referencedata = 'NopOK' and CE.ResultData = 'MIMOPRAC'
   --LEFT JOIN ICC.dbo.callevent ce2 WITH (NOLOCK) ON IC.InboundCallId=CE2.InboundCallId AND CE2.referencedata = 'NopOK' and CE2.ResultData = 'WHITELIST'
   WHERE PilotTime>@from AND dbo.IsWorkTime4(PilotTime,'PracDoba')=0.
   AND CE.InboundCallId IS NULL --AND CE2.InboundCallId IS NULL
   OPEN my_cursor 

  FETCH NEXT FROM My_cursor INTO @PilotTime, @InboundcallId    
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @InboundcallId  IS NOT NULL
		BEGIN
		  -- Zapiš do $(ICC).dbo.callevent chybějící záznam
          INSERT INTO ICC.[dbo].[CallEvent]
           ( [TimeUTC]
           , [TimeLocal]
           ,[EventType]
           ,[InboundCallId]
           ,[ReferenceData]
           ,[ResultData]
           )
          VALUES
           (GETUTCDATE()
           ,@PilotTime
           ,'IvrScriptA'
           ,@InboundCallId
           ,'NopOK'
           ,'MIMOPRAC'
            )
		END
		FETCH NEXT FROM My_cursor INTO @PilotTime, @InboundcallId  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;

  END

	   SET @Zprava = 'Konec procedury'
       EXEC  .[dbo].[WriteEvent] 1,'Daily_Maint',@Zprava

END
GO



IF object_id('ExportModul') IS NOT NULL
 DROP  Procedure  [dbo].[ExportModul]
GO
CREATE  PROCEDURE [dbo].[ExportModul]
@DataQueryId UniqueIdentifier
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 1.03.2020
-- Description:	Exportuje modul do Icc_Catalog
-- =============================================
BEGIN
DECLARE @LastTime AS bit=1
 -- Nejprve Dataquery:
 IF OBJECT_ID(N'Icc_Catalog..DataQuery', N'U') IS NULL -- Tabulka neexistuje
   select * into Icc_Catalog.dbo.DataQuery from $(ICC).dbo.DataQuery WHERE DataQueryId=@DataQueryId
 ELSE
   BEGIN
     IF (SELECT TOP 1 1 FROM Icc_Catalog.dbo.DataQuery WHERE DataQueryId=@DataQueryId)=1
	  BEGIN
	   SET @LastTime=1
	   /**/
	   UPDATE Icc_Catalog.dbo.DataQuery
       SET DisplayName = DGOUT.DisplayName
	      ,[Description]= DGOUT.Description
          ,[QueryGroup]= DGOUT.[QueryGroup]
          ,[QuerySortExpression]= DGOUT.[QuerySortExpression]
          ,[QueryText]= DGOUT.[QueryText]

	   FROM Icc_Catalog.dbo.DataQuery DGIN
	   JOIN $(ICC).dbo.DataQuery DGOUT  
       ON DGIN.Dataqueryid = DGOUT.Dataqueryid  
       WHERE  DGOUT.DataQueryId=@DataQueryId 
	  END
    ELSE   -- Záznam v tabulce neexistuje
	  INSERT INTO Icc_Catalog.dbo.DataQuery SELECT * FROM $(ICC).dbo.DataQuery WHERE DataQueryId=@DataQueryId
   END
 -- Dataquerycolumn:
  IF OBJECT_ID(N'Icc_Catalog..DataQueryColumn', N'U') IS NULL -- Tabulka neexistuje
   select * into Icc_Catalog.dbo.DataQueryColumn from $(ICC).dbo.DataQueryColumn WHERE DataQueryId=@DataQueryId
 ELSE
   BEGIN
      -- Nejprve přidám neexistující záznamy
	  INSERT INTO Icc_Catalog.dbo.DataQueryColumn SELECT
	  IDQ.[DataQueryColumnId]
      ,IDQ.[DataQueryId]
      ,IDQ.[DisplayName]
      ,IDQ.[Model]
      ,IDQ.[TargetColumn]
      ,IDQ.[TargetFormat]
      ,IDQ.[UrlColumn]
      ,IDQ.[UrlFormat]
      ,IDQ.[GuidColumn]
      ,IDQ.[Convertor]
      ,IDQ.[SortExpression]
      ,IDQ.[SortExpressionDesc]
      ,IDQ.[NoFilter]
      ,IDQ.[Width]
      ,IDQ.[Rank]
      ,IDQ.[Color]
      ,IDQ.[Deleted]
      ,IDQ.[SqlCmd]
      ,IDQ.[Css]
      ,IDQ.[ToolTip]
      ,IDQ.[LiteralGroup]
      ,IDQ.[GlyphColumn]
      ,IDQ.[GlyphFormat]
      ,IDQ.[GdprSensitivity]
	   FROM $(ICC).dbo.DataQueryColumn IDQ
	    LEFT JOIN Icc_Catalog.dbo.DataQueryColumn EDQ ON IDQ.TargetColumn=EDQ.TargetColumn
	  WHERE IDQ.DataQueryId=@DataQueryId AND EDQ.DataQueryColumnId IS NULL
     -- Potom vše zaktualizuji
 	   UPDATE Icc_Catalog.dbo.DataQueryColumn
       SET DisplayName = DGOUT.DisplayName
      ,[Model] = DGOUT.[Model]
      ,[TargetColumn] = DGOUT.[TargetColumn]
      ,[TargetFormat] = DGOUT.[TargetFormat]
      ,[UrlColumn] = DGOUT.[UrlColumn]
      ,[UrlFormat] = DGOUT.[UrlFormat]
      ,[GuidColumn] = DGOUT.[GuidColumn]
      ,[Convertor] = DGOUT.[Convertor]
      ,[SortExpression] = DGOUT.[SortExpression]
      ,[SortExpressionDesc] = DGOUT.[SortExpressionDesc]
      ,[NoFilter] = DGOUT.[NoFilter]
      ,[Width] = DGOUT.[Width]
      ,[Rank] = DGOUT.[Rank]
      ,[Color] = DGOUT.[Color]
      ,[SqlCmd] = DGOUT.[SqlCmd]
      ,[Css] = DGOUT.[Css]
      ,[ToolTip] = DGOUT.[ToolTip]
      ,[LiteralGroup] = DGOUT.[LiteralGroup]
      ,[GlyphColumn] = DGOUT.[GlyphColumn]
      ,[GlyphFormat] = DGOUT.[GlyphFormat]
      ,[GdprSensitivity] = DGOUT.[GdprSensitivity]
	   FROM Icc_Catalog.dbo.DataQueryColumn DGIN
	   JOIN $(ICC).dbo.DataQueryColumn DGOUT  
       ON DGIN.DataQueryColumnid = DGOUT.DataQueryColumnid  
       WHERE  DGOUT.DataQueryId=@DataQueryId AND DGIN.[Deleted] = 0
   END
END 


GO
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
	    IF  @TestVer IN (''IC'',''OC'') 
		  RETURN 1
		RETURN 0
	  END'
    EXEC (@CreateCustom)
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
----------------- Doplnění čísla volajícího do gridu události příchozího hovoru ----------------------
DECLARE @Id AS UNIQUEIDENTIFIER=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Události příchozího hovoru' AND QueryGroup='Admin' AND Deleted=0)
IF @Id IS NOT NULL AND NOT EXISTS(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@Id AND QueryText LIKE '%CallerNumber%' )
  BEGIN
   PRINT 'Přidávám CallerNumber do Události příchozího hovoru'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'LEFT JOIN IvrScript AS IVRSC ON IVRST.IvrScriptId=IVRSC.IvrScriptId',
	 'LEFT JOIN IvrScript AS IVRSC ON IVRST.IvrScriptId=IVRSC.IvrScriptId
	  LEFT JOIN InboundCall AS IC ON IC.InboundCallId=CAE.InboundCallId')
     FROM .dbo.DataQuery DQ
     WHERE DataQueryId=@Id
	UPDATE DQ
     SET  QueryText = REPLACE(QueryText,', ResultData',', ResultData
	 , IC.CallerNumber')
     FROM .dbo.DataQuery DQ
     WHERE DataQueryId=@Id
    UPDATE DQ
     SET  QueryText = REPLACE(QueryText,' InboundCallId',' CAE.InboundCallId')
     FROM .dbo.DataQuery DQ
     WHERE DataQueryId=@Id
    UPDATE DQ
     SET  QueryText = REPLACE(QueryText,', AgentId',', CAE.AgentId')
     FROM .dbo.DataQuery DQ
     WHERE DataQueryId=@Id

	        

    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@Id,N'CallerNumber',N'Text',N'CallerNumber',NULL,NULL,NULL,NULL,NULL,N'CallerNumber',NULL,0,70,30,NULL,0,NULL) 
  END

IF NOT EXISTS(SELECT * FROM [dbo].[ActionTrigger] WHERE DisplayName= 'Denní údržba' )
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted], [Offset], [LaunchTime]) VALUES (N'7a982dcb-e4c5-4a09-86db-52542909b406', N'Denní údržba', NULL, N'ADMIN', N'EXEC $(FS_CUSTOM).[dbo].[Daily_Maintenance]', NULL, NULL, N'PeriodDay', NULL, NULL, NULL, NULL, NULL, CAST(N'2019-12-14 03:00:00.000' AS DateTime), NULL, 0, 0, NULL, CAST(N'2019-12-12 04:00:00.000' AS DateTime))
GO

-- CONVERSION INTO CORRECT CODEPAGE WAS PERFORMED
-------------------------------------------------

  /* Admin: Všechny případy  */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '34137610-1fb2-4b82-a857-2bf1f3c05d08'
DECLARE @DisplayName AS VARCHAR(150) = 'Všechny případy '
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'NewTime DESC',N'SELECT I.IssueId, I.TopicId, I.SubTopicId, I.PhaseId, I.AgentId, I.ProjectId,
        I.Activity, I.NewTime,
        P.DisplayName as ProjectName, 
        A2.DisplayName as CreatorName, 
  	  A.DisplayName as AgentName, 
        A.TeamName AS Team,
        T.DisplayName as TopicName, 
        ST.DisplayName as SubTopicName, 
        PH.DisplayName as PhaseName,
        I.DisplayName as IssueName,
        
         CAST(CASE WHEN I.PhaseID=''BFC21976-8923-41E9-BAA7-43298621531E'' THEN 1 ELSE 0 END AS bit) AS Returned
        
        , CAST(CASE WHEN I.PhaseID=''78B2953D-D870-4F78-AB52-3DE00CF59B40'' THEN 1 ELSE 0 END AS bit) AS Doplnit
        
        ,CAST(CASE WHEN exists (select top 1 1 from .dbo.message m  with (nolock) where MessagePhase=''Received'' and MessageResult=''Active'' and m.IssueId=i.IssueId and m.Direction=''I'')THEN 1 ELSE 0 END AS bit) AS NewMessage
        
        
        , CAST(CASE WHEN I.Activity<>''Closed'' THEN 1 ELSE 0 END AS bit) AS IsActive
        
        
        
        ,CAST(CASE WHEN (I.Activity<>''Closed'') AND I.NewTime<@LastWeek THEN 1 ELSE 0 END AS bit) AS IsLate
         FROM Issue as I WITH(NOLOCK)
        LEFT JOIN Topic AS T WITH(NOLOCK) ON I.TopicId=T.TopicId
        LEFT JOIN SubTopic AS ST WITH(NOLOCK) ON I.SubTopicId =ST.SubTopicId
        LEFT JOIN Phase AS PH WITH(NOLOCK) ON I.PhaseId = PH.PhaseId
        LEFT JOIN Project AS P WITH(NOLOCK) ON I.ProjectId=P.ProjectId
        LEFT JOIN Agent AS A WITH(NOLOCK) ON I.AgentId=A.AgentId
  	  LEFT JOIN Agent AS A2 WITH(NOLOCK) ON I.NewAgentId=A2.AgentId
        --left join contact C with (nolock) on c.ContactId=i.ContactId
         WHERE NewTime>DATEADD(Month,-6,@Today)',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IssueId',N'Text',N'IssueId',NULL,NULL,NULL,NULL,NULL,N'IssueId',NULL,0,230,3,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stav',N'Image',N'Activity',N'~/CustomImages/Issue-{0}.png',N'IssueId',N'/ReactClient/Pages/Issueeditor.html?Id={0}',NULL,N'IssueActivity',N'Activity',NULL,0,25,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Time',N'DateTimeFromTo',N'NewTime',N'{0:dd.MM. HH:mm:ss}',NULL,NULL,NULL,NULL,N'NewTime',NULL,0,95,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'CreatorName',N'Text',N'CreatorName',NULL,NULL,NULL,NULL,NULL,N'CreatorName',NULL,0,100,11,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Projekt',N'ForeignKey',N'ProjectName',NULL,NULL,NULL,N'ProjectId',N'ProjectName',N'ProjectName',NULL,0,100,12,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Téma',N'ForeignKey',N'TopicName',NULL,NULL,NULL,N'TopicId',N'TopicName',N'TopicName',NULL,0,120,13,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Podtéma',N'ForeignKey',N'SubTopicName',NULL,NULL,NULL,N'SubTopicId',NULL,N'SubTopicName',NULL,0,120,14,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stav',N'ForeignKey',N'PhaseName',NULL,NULL,NULL,N'PhaseId',N'PhaseName',N'PhaseName',NULL,0,80,15,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Agent',N'ForeignKey',N'AgentName',NULL,NULL,NULL,N'AgentId',N'AgentName',N'AgentName',NULL,0,150,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Returned',N'Color',N'Returned',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,88,N'#70AD47',0,NULL,N'warning',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Doplnit',N'Color',N'Doplnit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,89,N'#ffc000',0,NULL,N'info',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'NewMessage',N'Color',N'NewMessage',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,90,N'#FF0000',0,NULL,N'active',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Aktivní',N'Color',N'IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,N'#E0FFFF',0,NULL,N'active',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Team',N'Text',N'Team',NULL,NULL,NULL,NULL,NULL,N'Team',NULL,0,80,201,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IssueName',N'Text',N'IssueName',NULL,NULL,NULL,NULL,NULL,N'IssueName',NULL,0,80,211,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsLate',N'Color',N'IsLate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,221,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
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

-- Doplnění ADM Portál:

IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_KontSys')
 BEGIN
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'af62bfee-171b-489b-9e29-19232d11d71d', N'Admin_KontSys', N'Kontrolní systém', NULL, N'fa fa-phone', NULL, N'AdminPageNav', 5060, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Eventlog","Css":"","DataQuery":{"Id":"0052e9cb-1dd8-4829-ba19-d5a7d410915a","DisplayName":"Eventlog","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Výsledky akcí","Css":"","DataQuery":{"Id":"4c9e5e61-f17a-4ce1-9bb4-441c8ad8f83e","DisplayName":"Výsledky akcí","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":5,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Admin příkazy","Css":"","DataQuery":{"Id":"61c8ebc7-e7be-42b2-88b5-578479d8c30a","DisplayName":"Admin příkazy","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
 END
 GO
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Wallboard')
 BEGIN
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'77547454-f322-4658-b67f-1a9f038231c5', N'Admin_Wallboard', N'Wallboardy', NULL, N' fa-bar-chart', NULL, N'AdminPageNav', 5070, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Wallboard","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"d24df1de-5bdd-455c-aed1-1c45279cbd84","DisplayName":"Wallboard","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Wallboard časy","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"1c043f8c-2616-4293-8467-2422bf171ae7","DisplayName":"Wallboard časy","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
 END
 GO
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_IVR')
 BEGIN
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
 VALUES (N'a941d991-9d2e-427f-b230-443b4445b041', N'Admin_IVR', N'IVR', NULL, N'fa fa-phone', NULL, N'AdminPageNav', 5050, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"IVR Skripty","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"b36e3ad0-c8e3-4083-a23a-0e18686076b6","DisplayName":"IVR Skripty","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"IVR Step","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"d45fde09-0bf3-4418-bf50-7f11f3e5c0e5","DisplayName":"IVR Step","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"873404dd-0641-46b0-b8f4-3f6b33bf348c","DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","SpecificName":"ADMIN","Glyph":"fa fa-thermometer-full","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-thermometer-full",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
 END
 GO
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Hovory')
 BEGIN
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'49dfe157-4a6f-4656-8bde-56499183d4d2', N'Admin_Hovory', N'Hovory', NULL, N'fa fa-phone', NULL, N'AdminPageNav', 5010, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Všechny příchozí hovory","Css":"","DataQuery":{"Id":"99cecf13-c463-4abd-a52e-ad923d51ac7c","DisplayName":"Všechny příchozí hovory","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Admin: Události příchozího ","Css":"","DataQuery":{"Id":"354e10a1-14f7-4f66-b1aa-9b7ffee2b91f","DisplayName":"Události příchozího ","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"DataQueryGrid","Path":"A","Index":"E","DisplayName":"Admin: Všechny odchozí hovory","Css":"","DataQuery":{"Id":"ce85ccb8-d497-40ab-a067-e1561d4d7ab6","DisplayName":"Všechny odchozí hovory","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"DataQueryGrid","Path":"A","Index":"F","DisplayName":"Admin: Události odchozího hovoru","Css":"","DataQuery":{"Id":"354e10a1-14f7-4f66-b1aa-9b7ffee2b91f","DisplayName":"Události odchozího hovoru","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Admin: Nahrávky","Css":"","DataQuery":{"Id":"68df515a-31d7-4137-b661-9ce2c40a601a","DisplayName":"Nahrávky","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null}]')
 END
 GO
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_FrontaHovoru')
 BEGIN

INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'd0c44ccf-5260-4b1b-8f8e-a52a3fe10073', N'Admin_FrontaHovoru', N'Fronta hovorů', NULL, N'fa fa-align-left', NULL, N'AdminPageNav', 5080, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Vyšetřování fronty","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"832e1da3-c87e-4e51-a7a6-ca1ec2abcdfd","DisplayName":"Vyšetřování fronty","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Volní agenti","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"9e103b6f-379b-417c-8ec7-2361ef3124ed","DisplayName":"Volní agenti","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Volní agenti seznam","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"50baed36-ca55-46b5-a971-45996d7b52f0","DisplayName":"Volní agenti seznam","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
 END
 GO
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_DQ')
 BEGIN

INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'873b377f-11b3-4142-9063-b7db635d52d0', N'Admin_DQ', N'Data Query', NULL, N'fa fa-calendar', NULL, N'AdminPageNav', 5030, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Datové dotazy","Css":"","DataQuery":{"Id":"e5fe7ca3-06f1-46a4-9771-09cb4bfc43eb","DisplayName":"Datové dotazy","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Sloupce dotazů","Css":"","DataQuery":{"Id":"d1f1f295-8801-423b-aafd-9222ee4892fc","DisplayName":"Sloupce dotazů","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null}]')
 END
 GO
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Email')
 BEGIN
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'7f649a00-6cda-47f5-a600-dcd4195f1051', N'Admin_Email', N'Emaily', NULL, N'fa fa-envelope', NULL, N'AdminPageNav', 5040, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner hlavni","Css":"col-md-12 col-sm-12 col-xs-12","FixedTopHeight":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Všechny zprávy","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"05d59721-8eed-493d-a88d-a547153aed49","DisplayName":"Všechny zprávy","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"MessageEvent","Css":"","DataQuery":{"Id":"2f0fd1d8-017a-4a7c-be35-a8c02f46007d","DisplayName":"MessageEvent","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":true,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
 END
 GO
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Agenti')
 BEGIN
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'01de7c4a-d813-4031-84f6-ee3d561ccab9', N'Admin_Agenti', N'Agenti', NULL, N'fa fa-users', NULL, N'AdminPageNav', 5020, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Přehled agentů Admin","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"ec5174c1-ad19-4423-8fff-ae043dc92627","DisplayName":"Přehled agentů Admin","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Výsledky akcí","Css":"","DataQuery":{"Id":"4c9e5e61-f17a-4ce1-9bb4-441c8ad8f83e","DisplayName":"Výsledky akcí","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
 END
 GO
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Kontakt')
 BEGIN
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'014288d4-c3fe-433e-93da-fde0fce3c0e0', N'Admin_Kontakt', N'Kontakty', NULL, N'fa fa-address-card', NULL, N'AdminPageNav', 5055, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Telefonní seznamy","Css":"","DataQuery":{"Id":"1ff2043b-8f15-42a8-bb25-27e584b21061","DisplayName":"Telefonní seznamy","SpecificName":"Kontakty","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Seznam telefonních čísel","Css":"","DataQuery":{"Id":"19627bb1-4299-4a30-87ea-63c2e25fb52c","DisplayName":"Seznam telefonních čísel","SpecificName":"Kontakty","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Seznam telefonních čísel pro export","Css":"","DataQuery":{"Id":"f66ff314-27ab-4330-affa-937b005a0b47","DisplayName":"Seznam telefonních čísel pro export","SpecificName":"Kontakty","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
 END
 GO
 IF EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='admin_pripady' AND PortalId<>'f007b5da-21c9-499f-b781-88a8950c98a9')
 BEGIN
   DELETE FROM $(ICC).dbo.Portal WHERE HashPage='admin_pripady' 
 END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='admin_pripady')
 BEGIN
   INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
    VALUES (N'f007b5da-21c9-499f-b781-88a8950c98a9', N'admin_pripady', N'Případy', N'Případy', N'fa fa-briefcase', NULL, N'AdminPageNav', 5045, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Všechny případy ","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"34137610-1fb2-4b82-a857-2bf1f3c05d08","DisplayName":"Všechny případy ","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Issue Events","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"6c5e8e3f-37b1-4fc6-8c7d-233efd017f2b","DisplayName":"Issue Events","SpecificName":"ADMIN","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
 END

 IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='admin_ExpImp')
 BEGIN
   INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) 
   VALUES (N'9ff03aae-a127-47e1-8a41-d491de622d2f', N'admin_expimp', N'Export/Import', N'Export/Import', N'fa fa-exchange', NULL, N'AdminPageNav', 5090, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true}]')
 END
 GO
 
 -- Toto nefungovalo - asi nějaká nekompatibilita
 UPDATE [dbo].[Portal]
   SET 
      [JsonData] = '[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"33047afb-6685-4587-9c8f-ab889675a20a","DisplayName":"Export vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Catalog","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"26b70734-8b02-44ad-a71c-90708690c3d3","DisplayName":"Catalog","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"ddc01671-d175-4de6-920f-541c8c4e7c8f","DisplayName":"Přepis vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":0},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]''[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"33047afb-6685-4587-9c8f-ab889675a20a","DisplayName":"Export vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Catalog","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"26b70734-8b02-44ad-a71c-90708690c3d3","DisplayName":"Catalog","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"ddc01671-d175-4de6-920f-541c8c4e7c8f","DisplayName":"Přepis vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":0},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]''[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"33047afb-6685-4587-9c8f-ab889675a20a","DisplayName":"Export vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Catalog","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"26b70734-8b02-44ad-a71c-90708690c3d3","DisplayName":"Catalog","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"ddc01671-d175-4de6-920f-541c8c4e7c8f","DisplayName":"Přepis vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":0},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]'
   WHERE 1=2 AND HAShPAGe='admin_expimp' and NavGroup='AdminPageNav'
GO

DECLARE @DisplayName AS VARCHAR(150) = 'Data Query usage'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'

 IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN

 /* Admin: Data Query usage */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6',N'Data Query usage',NULL,N'Admin',N'PageName,NAVGroup,DataQueryId',N'SELECT 
      [DataQueryId] AS RecordId
      ,ISNULL(PRT.DisplayName,''--- Nepoužito ---'') AS PageName
      ,PRT.NAVGroup
      ,PRT.HashPage
      ,[DataQueryId]
      ,DQ.DisplayName AS QueryName
      ,DQ.[Description]
      ,[QueryGroup]
  FROM [iCC].[dbo].[DataQuery] DQ
    LEFT JOIN .[dbo].[Portal] PRT ON PRT.JsonData LIKE ''%''+CONVERT(NVARCHAR(36),DQ.DataQueryId)+''%''
	WHERE Deleted=0',0,NULL,NULL,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'4d0bd303-4b5b-4f09-8292-f9a492495e02',N'2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6',N'Select',N'Toggle',N'RecordId',NULL,NULL,N'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,NULL,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'eb82de41-192d-4c3a-8d44-8cddaa6bed1b',N'2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6',N'NAVGroup',N'Select',N'NAVGroup',NULL,NULL,NULL,NULL,NULL,N'NAVGroup',NULL,0,120,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'0c503371-2401-404c-87ef-504ffa55adcb',N'2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6',N'PageName',N'Select',N'PageName',NULL,NULL,NULL,NULL,NULL,N'PageName',NULL,0,100,12,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'df8be901-c6b3-4a36-865c-cdc910eea416',N'2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6',N'HashPage',N'Select',N'HashPage',NULL,NULL,NULL,NULL,NULL,N'HashPage',NULL,0,120,15,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'58c2e0b8-f526-47bb-b0b3-6020e45a0b43',N'2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6',N'DataQueryId',N'Text',N'DataQueryId',NULL,NULL,NULL,NULL,NULL,N'DataQueryId',NULL,0,230,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'6a217b8a-1fb0-4a9c-a13f-7b565a77c17f',N'2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6',N'QueryGroup',N'Select',N'QueryGroup',NULL,NULL,NULL,NULL,NULL,N'QueryGroup',NULL,0,80,167,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'464dc690-b736-4805-a9a2-8cf2eb530c34',N'2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6',N'Description',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,80,172,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'8fd0cd6b-c3cc-4bbc-a2a2-fe57d9a73fbb',N'2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6',N'QueryName',N'Text',N'QueryName',NULL,NULL,NULL,NULL,NULL,N'QueryName',NULL,0,200,292,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)

 END

 GO

DECLARE @DisplayName AS VARCHAR(150) = 'Web Admin Changes'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'

 IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN

 /* Admin: Web Admin Changes */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'a10ad2c8-64cb-4aff-b937-69cffe292dba',N'Web Admin Changes',N'over WebAdmin app',N'Admin',N'TimeUTC DESC',N'SELECT  [WebAdminEventId]
      ,AG.DisplayName AS AgentName
      ,[TimeUtc]
      ,[TableNames]
      ,[RefInserts]
      ,[RefUpdates]
      ,[RefDeletes]
      --,[AgentId]
  FROM .[dbo].[WebAdminEvent] WAE
    LEFT JOIN .[dbo].Agent AG ON AG.AgentId=WAE.AgentId
',0,NULL,NULL,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'e3ba0264-d01a-4357-ae4a-292812162207',N'a10ad2c8-64cb-4aff-b937-69cffe292dba',N'AgentName',N'Select',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,180,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'fde85401-b437-4df8-8574-3a69abe335ba',N'a10ad2c8-64cb-4aff-b937-69cffe292dba',N'TimeUtc',N'DateTimeUtc',N'TimeUtc',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeUtc',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'07991fc2-6156-41c8-b141-e519f6030a33',N'a10ad2c8-64cb-4aff-b937-69cffe292dba',N'TableNames',N'Select',N'TableNames',NULL,NULL,NULL,NULL,NULL,N'TableNames',NULL,0,80,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'2697c057-d8ad-469a-a071-65e253653ae8',N'a10ad2c8-64cb-4aff-b937-69cffe292dba',N'RefInserts',N'Text',N'RefInserts',NULL,NULL,NULL,NULL,NULL,N'RefInserts',NULL,0,200,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'14ac4c49-0f4b-4e6e-923e-b4a1746e42dc',N'a10ad2c8-64cb-4aff-b937-69cffe292dba',N'RefUpdates',N'Text',N'RefUpdates',NULL,NULL,NULL,NULL,NULL,N'RefUpdates',NULL,0,200,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'6b7655d4-37c2-4b6b-8d85-a30f286ee768',N'a10ad2c8-64cb-4aff-b937-69cffe292dba',N'RefDeletes',N'Text',N'RefDeletes',NULL,NULL,NULL,NULL,NULL,N'RefDeletes',NULL,0,200,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL)


 END

 GO

 DECLARE @DisplayName AS VARCHAR(150) = 'Catalog'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'

 IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN

 /* Admin: Catalog */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'26b70734-8b02-44ad-a71c-90708690c3d3',N'Catalog',NULL,N'Admin',N'HashPage,Section,ModulName',N'SELECT 
      [SectionId] AS RecordId
      , [Section]
      ,[HashPage]
	  , IIF(DQ.DisplayName IS NOT NULL,DQ.DisplayName,IIF(DQC.DisplayName IS NOT NULL,DQC.DisplayName,'''')) AS ModulName
  FROM [Icc_Catalog].[dbo].[Catalog] AS CAT WITH (NOLOCK)
     LEFT JOIN [Icc_Catalog].[dbo].[DataQuery] AS DQ WITH (NOLOCK) ON CAT.SectionId=DQ.DataQueryId
	 LEFT JOIN [Icc_Catalog].[dbo].[DataQueryColumn] AS DQC WITH (NOLOCK) ON CAT.SectionId=DQC.DataQueryColumnId',0,NULL,NULL,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'8d319c97-3968-432e-9acb-aa367f1a0050',N'26b70734-8b02-44ad-a71c-90708690c3d3',N'Select',N'Toggle',N'RecordId',NULL,NULL,N'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,NULL,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'0d109bb2-cb15-4bc7-9f1b-ea74a24eb07b',N'26b70734-8b02-44ad-a71c-90708690c3d3',N'Section',N'Select',N'Section',NULL,NULL,NULL,NULL,NULL,N'Section',NULL,0,200,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'9f012871-1581-47ff-a460-df663537d0dd',N'26b70734-8b02-44ad-a71c-90708690c3d3',N'HashPage',N'Select',N'HashPage',NULL,NULL,NULL,NULL,NULL,N'HashPage',NULL,0,120,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'f7855f1f-6642-44bb-a4fb-3dbabbd3a740',N'26b70734-8b02-44ad-a71c-90708690c3d3',N'ModulName',N'Text',N'ModulName',NULL,NULL,NULL,NULL,NULL,N'ModulName',NULL,0,300,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)

 END

 GO

DECLARE @DisplayName AS VARCHAR(150) = 'Admin commands'
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '61c8ebc7-e7be-42b2-88b5-578479d8c30a'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId  = @DataQueryId  AND Deleted=0)
 BEGIN

  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'Description',N'SELECT CommandId AS RecordId
             , ''1'' AS ProvedAkci
             ,Description
        FROM FS_CUSTOM.dbo.Commands 
     ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Perform command',N'ImageScript',N'ProvedAkci',N'~/CustomImages/{0}.png',N'RecordId',NULL,NULL,NULL,N'ProvedAkci',NULL,0,70,3,NULL,0,N'exec FS_CUSTOM.dbo.RunScript @Id',NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Description',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,500,340,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
 
 END

GO


 /* ADMIN: Eventlog */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '9cac0b68-a27a-4388-ba71-7bf8b1de42d3'
DECLARE @DisplayName AS VARCHAR(150) = 'Eventlog'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId  = @DataQueryId  AND Deleted=0)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'Prohlížení Eventlogu',@QueryGroup,N'DatumCas  DESC',N'select
  * FROM FS_Custom.dbo.Eventlog',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'Time',N'DayTime',N'DatumCas',N'{0:dd.MM.yyyy HH:mm:ss}',NULL,NULL,NULL,NULL,N'DatumCas',NULL,0,110,20,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'Description',N'Text',N'Popis',NULL,NULL,NULL,NULL,NULL,N'Popis',NULL,0,600,30,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'Procedure',N'Text',N'Procedura',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,150,40,NULL,0)
  
 END
GO

IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Export vybraných modulů')
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted], [Offset], [LaunchTime]) VALUES (N'33047afb-6685-4587-9c8f-ab889675a20a', N'Export vybraných modulů', N'Slouží k údržbě katalogu', N'ADMIN', N'EXEC [$(FS_CUSTOM)].[dbo].[ExportModul] @RecordId', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL)
GO

IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Import vybraných modulů')
INSERT [dbo].[ActionTrigger] ( [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted], [Offset], [LaunchTime]) VALUES ( N'Import vybraných modulů', N'Slouží k instalaci komponent z katalogu', N'ADMIN', N'EXEC [$(FS_CUSTOM)].[dbo].[ImportModul] @RecordId,0', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL)
GO

DECLARE @RoleId AS Uniqueidentifier =(SELECT TOP (1) [RoleId]  FROM $(ICC).[dbo].[Role] WHERE SystemName='RunActionManual')
IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.[Permission] WHERE [RoleId]=@RoleId )
  BEGIN

	INSERT INTO [dbo].[Permission]
			   ([RoleId]
			   ,[Degree]
			   ,Supervisor)
		  VALUES
			   (@RoleId
			   ,3
			   ,1
				)
  END
  GO

   USE $(Icc_Backup)
   GO
--
IF object_id('$(Icc_Backup)..Backup_Table2') IS NOT NULL
 BEGIN
  DROP  PROCEDURE [dbo].Backup_Table2
 END


GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.04.2020>
-- Description:	Záloha 1 (konfigurační) tabulky do iCC_Backup
-- =============================================

CREATE PROCEDURE [dbo].[Backup_Table2]
@TableName NVARCHAR(50)
AS
BEGIN
  DECLARE @OrigName AS NVARCHAR(100) = 'Icc_Backup..'+@TableName
  DECLARE @NewName AS NVARCHAR(100) = @TableName+'_old'
  --PRINT DB_NAME()
 	IF OBJECT_ID(N'Icc_Backup..'+@TableName, N'U') IS NOT NULL -- Tabulka existuje
	  BEGIN
	    IF OBJECT_ID(N'Icc_Backup..'+@TableName+'_old', N'U') IS NOT NULL -- Tabulka existuje 
		  EXEC('DROP TABLE Icc_Backup.dbo.'+@TableName+'_old')--DROP TABLE Icc_Backup.dbo.Agent_old
	    EXEC sp_rename @OrigName, @NewName
	  END
	 EXEC('select * into Icc_Backup.dbo.'+@TableName+' from $(ICC).dbo.'+@TableName)-- select * into Icc_Backup.dbo.Agent from $(ICC).dbo.Agent

 END
 GO

 IF object_id('$(Icc_Backup)..Backup_DB') IS NOT NULL
 BEGIN
  DROP  PROCEDURE [dbo].Backup_DB
 END
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <20.05.2020>
-- Description:	DB iCC_Backup backup to file iCC_Backupyymmdd.bak on destination
-- =============================================

CREATE PROCEDURE [dbo].[Backup_DB]
@BackupPath AS NVARCHAR(100)
AS
BEGIN
 DECLARE @BackupFile AS NVARCHAR(150)= @BackupPath+'Icc_Backup'+convert(varchar(25), getdate(), 12)+'.bak'
 EXEC Icc_Backup.dbo.Backup_Table2 'ActionTrigger' 
EXEC Icc_Backup.dbo.Backup_Table2 'Agent'
EXEC Icc_Backup.dbo.Backup_Table2 'Campaign'
EXEC Icc_Backup.dbo.Backup_Table2 'Configuration'
EXEC Icc_Backup.dbo.Backup_Table2 'DataQuery'
EXEC Icc_Backup.dbo.Backup_Table2 'DataQueryColumn'
EXEC Icc_Backup.dbo.Backup_Table2 'Editor'
EXEC Icc_Backup.dbo.Backup_Table2 'EditorTab'
EXEC Icc_Backup.dbo.Backup_Table2 'EditorTask' 
EXEC Icc_Backup.dbo.Backup_Table2 'Gateway' 
EXEC Icc_Backup.dbo.Backup_Table2 'GatewayCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'Holiday' 
EXEC Icc_Backup.dbo.Backup_Table2 'ChatGateway' 
EXEC Icc_Backup.dbo.Backup_Table2 'ChatProjectCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'ImrScript' 
EXEC Icc_Backup.dbo.Backup_Table2 'ImrStep' 
EXEC Icc_Backup.dbo.Backup_Table2 'IssueCondition'
EXEC Icc_Backup.dbo.Backup_Table2 'IvrEntry'
EXEC Icc_Backup.dbo.Backup_Table2 'IvrScript'
EXEC Icc_Backup.dbo.Backup_Table2 'IvrStep' 
EXEC Icc_Backup.dbo.Backup_Table2 'Language' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessagePostCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessagePreCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageProjectCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageScheduleCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageWaitPostCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'Navigation' 
EXEC Icc_Backup.dbo.Backup_Table2 'OutboundList'
EXEC Icc_Backup.dbo.Backup_Table2 'Phase'
EXEC Icc_Backup.dbo.Backup_Table2 'PhaseTransition'
EXEC Icc_Backup.dbo.Backup_Table2 'PhoneBook' 
EXEC Icc_Backup.dbo.Backup_Table2 'Pilot' 
EXEC Icc_Backup.dbo.Backup_Table2 'Portal' 
EXEC Icc_Backup.dbo.Backup_Table2 'PostCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'PreCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'Predictor' 
EXEC Icc_Backup.dbo.Backup_Table2 'Proficiency' 
EXEC Icc_Backup.dbo.Backup_Table2 'Project' 
EXEC Icc_Backup.dbo.Backup_Table2 'ProjectCondition'
EXEC Icc_Backup.dbo.Backup_Table2 'Queue'
EXEC Icc_Backup.dbo.Backup_Table2 'Redirector'
EXEC Icc_Backup.dbo.Backup_Table2 'Role' 
EXEC Icc_Backup.dbo.Backup_Table2 'Scenario' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScenarioCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'Scope' 
EXEC Icc_Backup.dbo.Backup_Table2 'Screen' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScreenControl' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScreenControlParameter' 
EXEC Icc_Backup.dbo.Backup_Table2 'Seating' 
EXEC Icc_Backup.dbo.Backup_Table2 'SchedulePostCondition'
EXEC Icc_Backup.dbo.Backup_Table2 'Skill' 
EXEC Icc_Backup.dbo.Backup_Table2 'Status'
EXEC Icc_Backup.dbo.Backup_Table2 'SubTopic'
EXEC Icc_Backup.dbo.Backup_Table2 'Topic' 
EXEC Icc_Backup.dbo.Backup_Table2 'WaitingQueue' 
EXEC Icc_Backup.dbo.Backup_Table2 'WaitPostCondition' 
EXEC Icc_Backup.dbo.Backup_Table2 'WebSiteTemplate'
EXEC Icc_Backup.dbo.Backup_Table2 'Workflow' 
EXEC Icc_Backup.dbo.Backup_Table2 'WorkflowStep' 
 BACKUP DATABASE Icc_Backup TO DISK = @BackupFile
END

GO
USE $(iCC)
GO
GO
PRINT 'All commands were completed'
