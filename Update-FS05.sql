/*
:setvar FS_CUSTOM [Frontstage-Linet]
:setvar ICC [Frontstage-ICC] 
:setvar ICC_Backup [Frontstage-Linet]
*/
/* Na WB nemá být test na scheduled u těch failed */
:setvar Version 18.8.22
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
    EXEC [Icc_Catalog].sys.sp_addextendedproperty @name=N'description', @value=N'Catalog of Frontstage modules'
END
--ELSE


--GO /**/
--USE FS_CUSTOM
GO
USE $(FS_CUSTOM)
GO
IF  db_name() ='ICC'
   BEGIN
      PRINT ' WARNING - Objects were created in wrong DB !!!!!!!!!!!!!!!!!!!!'
   END 

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
   declare @ProcVer as nvarchar(35) = ' Inspection function ver: $(Version)'

     ---  Texty pro komunikaci s uživatelem: -------------------------------------------------------------------------------------------------------------
	/*DECLARE @AlerteMails AS NVARCHAR(200)='Mailové adresy, kam se mají posílat zaznamenané problémy'
	DECLARE @AgentIncorStat AS NVARCHAR(200)='Agent %s has an incorrect phone status'
	DECLARE @InspectPlease AS NVARCHAR(200)='Prosím o kontrolu'
	DECLARE @AgentNotReady AS NVARCHAR(200)='Agent %s není ready, ale má být trvale přihlášen'
	DECLARE @AgentwWasLogoff AS NVARCHAR(200)='Agent %s byl odhlášen'
	DECLARE @AutoLogon AS NVARCHAR(200)='Bylo provedeno jeho automatické přihlášení'
	DECLARE @NoTemplate AS NVARCHAR(200)='Template for e-mail autoanswer is missing'*/
       DECLARE @AlerteMails AS NVARCHAR(200)='Email addresses for receiving discovered issues'
       DECLARE @AgentIncorStat AS NVARCHAR(200)='Agent %s has an incorrect phone status'
       DECLARE @InspectPlease AS NVARCHAR(200)='Please check'
       DECLARE @AgentNotReady AS NVARCHAR(200)='Agent %s that should be permanently logged on is not ready right now'
	   DECLARE @DuplicWPMess AS NVARCHAR(200)='Duplicate Workplace %s '
       DECLARE @AgentwWasLogoff AS NVARCHAR(200)='Agent %s was logged off'
       DECLARE @AutoLogon AS NVARCHAR(200)='Automatic logon performed'
       DECLARE @NoTemplate AS NVARCHAR(200)='Missing template for e-mail auto-answer'


	-----------------------------------------------------------------------------------------------------------------------------------------------------
	
	declare @Today as datetime = GETDATE()

    EXEC  .[dbo].[WriteEvent] 1,'CheckFS','Entry point'

	/* Tuto část bude možno vypustit : ---------------------------------------------------------------------------------------*/
	declare @TGT as nvarchar(200) = 'servis@atlantis.cz'
	declare @TOCC as nvarchar(200) =.dbo.GiveParam('TOCC')

	IF @TOCC IS NULL
	     BEGIN
		   SET @TOCC  = 'homolka@atlantis.cz'
		   EXEC [dbo].[WriteParam] 'TOCC', @TOCC, @AlerteMails
		 END
	declare @MessageId as uniqueidentifier =
	(SELECT TOP 1 MessageId FROM $(ICC).[dbo].[Message] WITH (NOLOCK)
	   WHERE Direction='O' AND MessageType='Email' AND ReceivedSentTime IS NOT NULL AND GatewayId IS NOT NULL ORDER BY ReceivedSentTime DESC)
	 declare @GW as uniqueidentifier = (SELECT TOP 1 [GatewayId] FROM $(ICC).[dbo].[Message] WITH (NOLOCK) WHERE MessageId=@MessageId)
	 declare @GWN as nvarchar(150) = (SELECT TOP 1 PilotAddress FROM $(ICC).[dbo].[Gateway] WITH (NOLOCK) WHERE GatewayId=@GW)
	 declare @Company as nvarchar(200) =.dbo.GiveParam('Company')
	 IF @Company IS NULL
	     BEGIN
		    EXEC [dbo].[WriteParam] 'Company', @GWN, 'Company Name'
		 END

    DECLARE @RecordingsLess AS Integer=.dbo.GiveParam('RecordingsLess')
	   IF @RecordingsLess IS NULL
	     BEGIN
		   SET @RecordingsLess=5
		   EXEC [dbo].[WriteParam] 'RecordingsLess', @RecordingsLess, 'Number of tolerated calls without recordings'
		 END
   DECLARE @PairingTime AS Integer=.dbo.GiveParam('PairingTime')
	   IF @PairingTime IS NULL
	     BEGIN
		   SET @PairingTime=10 -- Minutes
		   EXEC [dbo].[WriteParam] 'PairingTime', @PairingTime, 'Time required to pair calls with recordings'
		 END
   DECLARE @ServiceGateWay AS  NVARCHAR(10)=.dbo.GiveParam('ServiceGateWay')
	   IF @ServiceGateWay IS NULL
	     BEGIN
		   EXEC [dbo].[WriteParam] 'ServiceGateWay', '', 'Service GateWay'
		 END



     DECLARE @AgentName AS NVARCHAR(50)
	 DECLARE @String1 AS NVARCHAR(50)
	 DECLARE @String2 AS NVARCHAR(50)
   --------------------------------------------------------------------------------------------------------------------------
    DECLARE @Agentid AS UniqueIdentifier
	DECLARE @workplaceid AS UniqueIdentifier
	DECLARE @Statusid AS UniqueIdentifier 
    DECLARE @Counter AS Integer=3
	declare @EmlMsg as nvarchar(300)
	declare @Subject as nvarchar(200)
	declare @Specif as nvarchar(200)
    DECLARE @RemoteAddress AS NVARCHAR(100)
	DECLARE @ResultData AS NVARCHAR(100)
	DECLARE @Pocet AS Integer
	DECLARE @Zprava NVARCHAR(200)
	declare @Holiday as nvarchar(40) =.dbo.GiveParam('Holiday')
	IF @Holiday IS NULL
	     BEGIN
		   SET @Holiday  = 'OUT_OF_OFFICE'
		   EXEC [dbo].[WriteParam] 'Holiday', @Holiday, 'Name of holiday group'
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
    DECLARE @from AS datetime=DATEADD(Hour,-3,GETDATE())
    DECLARE @to AS datetime=DATEADD(Minute,-@PairingTime,GETDATE())
    DECLARE @UTCDif AS Integer = (SELECT TOP 1 DATEDIFF(HOUR,PilotTime,TimeUTC) FROM $(ICC).dbo.InboundCall WITH (NOLOCK) ORDER BY TIMEUTC DESC)
    DECLARE @fromUTC AS datetime=DATEADD(Hour,@UTCDif,@from)
    DECLARE @toUTC AS datetime=DATEADD(Hour,@UTCDif,@to)
    declare @T as nvarchar(120) = CONVERT(nvarchar(20), DATEADD(MINUTE, -@Interval, @Today), 20) + ' - ' + CONVERT(nvarchar(20), @Today, 8)
	declare @Activity as nvarchar(32)
	declare @LastRecording AS Datetime
	declare @LastinCall AS Datetime
	declare @Severity AS Integer
	declare @OpakpoMin AS Integer = 30 -- Opakuj chybové hlášení po x minutách
	

IF db_id('SREC') IS NOT NULL 
  BEGIN
   -- Dopárování nahrávek:
   DECLARE @PairRecord AS NVARCHAR(5) = 'true'
   EXEC .dbo.GiveParam2 'PairRecord', @PairRecord OUTPUT,'Pair RecordingLess Calls with Recordings'
  --IF .dbo.GiveParam3('PairRecord', 'true' ,'Pair RecordingLess Calls with Recordings')='true' - nedovoluje syntaxe

  IF @PairRecord  = 'true'
   BEGIN
     EXEC  .[dbo].HledNesparIn
     --EXEC  .[dbo].HledNesparOut
   END
   -- Kontrola nahrávek:
	IF (.[dbo].RecordingLessCallsS(@RecordingsLess) > @RecordingsLess)
	   BEGIN
	    SET @LastRecording = (SELECT TOP 1  $(FS_Custom).dbo.TimeUTC_Local(EndTimeUTC) FROM [SRec].[dbo].[VoiceRecord] ORDER BY StartTimeUtc DESC)
		SET @LastinCall = (SELECT TOP 1 EndTime FROM $(ICC).dbo.[InboundCall] WHERE EndTime IS NOT NULL ORDER BY TimeUTC DESC)
		SET @EmlMsg = (SELECT 'Last recording: '+ CONVERT(NVARCHAR(20),@LastRecording,109) )
		SET @Specif = ' > '+CONVERT(NVARCHAR(5),@RecordingsLess)
		SET @Severity = CASE WHEN DATEDIFF(Minute,@LastRecording,GETDATE())>5 AND @LastRecording<@LastinCall THEN 10 ELSE 0 END
		--SET @Severity =IIF(DATEDIFF(Minute,@LastRecording,GETDATE())>5,10,0)
		SET @Zprava = 'Recordingless Calls'+CASE WHEN @Severity>0 THEN ' !!!!! ' ELSE '' END
		SET @OpakpoMin = CASE WHEN @Severity=0 THEN 500 ELSE 30 END
		EXEC [dbo].[ErrorLogProc] @Zprava,@Specif,@ProcVer,@EmlMsg,@Severity,@OpakpoMin
       END

    /*
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



    -- Kontrola nahrávek:
	IF @Debug=1 OR @GW IS NOT NULL AND (((@RecNow<@RecWeekAgo/5 OR @RecNow=0) AND @RecWeekAgo>0)  AND (@InCalls+@OutCalls>0) AND ((@InCalls+@OutCalls)>@RecNow))
	BEGIN
	  IF (@InCalls>0 AND .dbo.CustomCheck('IC',@Last)=1) OR (@OutCalls>0 AND .dbo.CustomCheck('OC',@Last)=1)
	   BEGIN
		SET @EmlMsg = 'T=' + @T + ' R- for last ' + CONVERT(nvarchar(10),@Interval) + ' min ='+ CONVERT(nvarchar(10),@RecNow) + ' R-weekago this time =' + CONVERT(nvarchar(10),@RecWeekAgo)
		SET @Specif = CONVERT(nvarchar(10),@RecNow)
		EXEC [dbo].[ErrorLogProc] 'nízký počet nahrávek',@Specif,@ProcVer,@EmlMsg,10,500
		/*
		insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,'Email','Scheduled','Active', @GWN, @TGT,@TGT,  @TOCC ,@GW,99,'O',
		'nízký počet nahrávek ' + CONVERT(nvarchar(10),@RecNow)+@ProcVer, @EmlMsg, @EmlMsg, @Mark )*/
       END   
	END  */
  END
	------------------------------------------------------------------------------------
	-- Kontrola mailů:
	declare @EmlNow as int = (select count(*) from $(ICC).dbo.Message as M WITH (NOLOCK) where M.Direction='I' AND M.MessageType='Email' AND M.TimeUtc<=@Now AND M.TimeUtc>=@Last)
	declare @EmlWeekAgo as int = (select count(*) from $(ICC).dbo.Message as M WITH (NOLOCK) where M.Direction='I' AND M.MessageType='Email' AND  M.TimeUtc<=@WeekAgo AND M.TimeUtc>=@LastWeekAgo)


	IF @Debug=1 OR (@GW IS NOT NULL AND (@EmlNow<@EmlWeekAgo/5 AND @EmlNow<@EmlWeekAgo-10) AND @EmlWeekAgo>1) 
	  AND (@EmlNow=0 OR (SELECT COUNT(1) FROM $(ICC).dbo.Gateway WHERE Direction IN ('I','B') AND Deleted=0)>1 )
	 BEGIN
	    SET @EmlMsg = 'T=' + @T + ' E-now='+ CONVERT(nvarchar(10),@EmlNow) + ' E-weekago=' + CONVERT(nvarchar(10),@EmlWeekAgo)
		-- Možná byl minulý týden výjimečný - tak porovnám ještě údaje před dvěma týdny
		declare @Eml2WeeksAgo as int = (select count(*) from $(ICC).dbo.Message as M WITH (NOLOCK) where M.Direction='I' AND M.MessageType='Email' 
		  AND  M.TimeUtc<=DATEADD(Day,-7,@WeekAgo) AND M.TimeUtc>=DATEADD(Day,-7,@LastWeekAgo))
        IF (@EmlNow<@Eml2WeeksAgo/5 AND @EmlNow<@Eml2WeeksAgo-10 AND @Eml2WeeksAgo>1)
		  BEGIN		 
		    SET @Specif = CONVERT(nvarchar(10),@EmlNow)
			SET @Severity =CASE WHEN @EmlNow=0 THEN 10 ELSE 0 END
		    EXEC [dbo].[ErrorLogProc] 'low count of incomming emails',@Specif,@ProcVer,@EmlMsg,@Severity,60
		  END
	
	 END
	  -- Kontrola chyb v MessageEvent
		  SET @EmlMsg = (SELECT TOP 1 [ResultData] FROM $(ICC).[dbo].[MessageEvent] WITH (NOLOCK) WHERE EventType='Failure' AND TimeLocal>@OneHourAgo)
		  IF (@EmlMsg IS NOT NULL) 
		    AND @EmlMsg NOT LIKE 'One or more recipients rejected%' -- Těchto zpráv je tam stále mnoho a na funkčnost to nemá podstatný vliv
		    BEGIN		 
		      SET @Specif = ''
			  SET @EmlMsg = 'Emails: '+@EmlMsg 
		      EXEC [dbo].[ErrorLogProc] @EmlMsg,@Specif,@ProcVer,@EmlMsg,0,60
		    END
		  SET @EmlMsg = (SELECT TOP 1 [ResultData] FROM $(ICC).[dbo].[MessageEvent] WITH (NOLOCK) WHERE ResultData='NoTemplate' AND TimeLocal>@OneHourAgo)
		  IF (@EmlMsg IS NOT NULL) 		  
		    BEGIN		 
		      SET @Specif = ''
			  SET @EmlMsg = @NoTemplate 
		      EXEC [dbo].[ErrorLogProc] @EmlMsg,@Specif,@ProcVer,@EmlMsg,0,1200
		    END

    IF @GW IS NOT NULL  
	 BEGIN
	   DECLARE @NoSent as int = (select count(*) from $(ICC).dbo.Message as M WITH (NOLOCK) where M.Direction='O' 
	   AND (MessagePhase='Scheduled' OR MessagePhase='Failed') AND M.MessageType='Email' AND M.TimeUtc<=@Last AND
	   M.TimeUtc>=@DayAgo AND M.ReceivedSentTime IS NOT NULL AND M.ReceivedSentTime>=@DayAgo
	   AND RemoteAddress IS NOT NULL -- 28.5.2019 Odfiltrování chybných mailů z webu
	   and (ISNULL(ScheduledTime,.dbo.TimeUTC_Local(TimeUTC))  < @Last)--Kubat, podminka pro naplanovane maily a jejich zpozdene odeslani
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
				SET @Specif = 'to address= '+@RemoteAddress
				EXEC [dbo].[ErrorLogProc] 'undelivery message',@Specif,@ProcVer,@ResultData,0,240
			  END
            ELSE
			  BEGIN
				SET @Specif = ', count='+ CONVERT(nvarchar(10),@NoSent)
				EXEC [dbo].[ErrorLogProc] 'unsent emails',@Specif,@ProcVer,@EmlMsg,2,60
							-- Pokusím se problém vyřešit
				UPDATE $(ICC).[dbo].[Message] SET MessageResult='Active'
				 WHERE  TimeUtc>@Yesterday AND Direction='O' AND MessagePhase='Scheduled' AND MessageResult='Closed' -- Pokud agent zadal odeslání uzavřeného mailu
			  END

          END
		-- Kontrola zapomenutých mailů
        IF (.dbo.CustomCheck('MN',@WeekAgo)>0)
		 BEGIN
		   SET @Specif = ''
		   EXEC [dbo].[ErrorLogProc] 'not accepted incomming emails',@Specif,@ProcVer,@EmlMsg,0,1440
         /*
	      SET  @EmlMsg=@InspectPlease
	      insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		  values(@Now,'Email','Scheduled','Active', @GWN, @TOCC,@TOCC,@GW,99,'O',
		  ' Varování: nepřijaté příchozí emaily' + @ProcVer, @EmlMsg, @EmlMsg, @Mark ) */
        END
		-- Kontrola mailů přodělených agentům, kteří nejsou v práci
        IF (.dbo.CustomCheck('NV',@WeekAgo)>0)
		 BEGIN
		   SET @Specif = ''
		   EXEC [dbo].[ErrorLogProc] 'emails assigned to agents who are not at work',@Specif,@ProcVer,@EmlMsg,0,1440
         /*

	      SET  @EmlMsg=@InspectPlease
	      insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		  values(@Now,'Email','Scheduled','Active', @GWN, @TOCC,@TOCC,@GW,99,'O',
		  ' Varování: maily přidělené agentům, kteří nejsou v práci' + @ProcVer, @EmlMsg, @EmlMsg, @Mark ) */
        END




	 END
	------------------------------------------------------------------------------------ Kontrola stavu agentů/pracovišť
  SET @Counter=3
  WHILE @Counter>0
    BEGIN
	 SET @Agentid  =
     (SELECT TOP 1 AG.AgentId 
       FROM $(ICC).dbo.Agent AS AG  WITH(NOLOCK) 
      LEFT JOIN $(ICC).dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
      LEFT JOIN $(ICC).dbo.InboundCall IC ON IC.AgentId=AG.Agentid AND IC.CallResult='Active'
      LEFT JOIN $(ICC).dbo.OutboundCall OC ON OC.AgentId=AG.Agentid AND OC.CallResult='Active'
      WHERE AG.Deleted = 0 AND AG.Template=0 AND AG.Activity = 'Ready' AND w.State <> 'Free'
	   AND IC.InboundCallId IS NULL AND OC.OutboundCallId IS NULL)
    SET  @Counter= @Counter-1
	IF @Agentid IS NOT NULL 
	  BEGIN
	    IF @Counter=0
		  BEGIN
		   SET @AgentName = RTRIM((SELECT TOP 1 Displayname FROM $(ICC).dbo.Agent  WITH(NOLOCK) WHERE AgentId=@Agentid))
		  	SET @EmlMsg='Please check'
			SET @Subject=FormatMessage(@AgentIncorStat,@AgentName)
			SET @Specif = ''
		    IF @Counter=0
			EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,30
          END
        ELSE
         WAITFOR DELAY '00:00:02'
      END
	ELSE
	  BREAK
    END
  ----- Kontrola trvale přihlášených agentů
  SET @Agentid  = (SELECT TOP 1 AgentId FROM $(ICC).dbo.Agent  WITH(NOLOCK) WHERE Description LIKE '%permanent login%' AND Activity<>'Ready' )
  IF @Agentid IS NOT NULL
	  BEGIN
		  SET @AgentName = RTRIM((SELECT TOP 1 Displayname FROM $(ICC).dbo.Agent  WITH(NOLOCK) WHERE AgentId=@Agentid))
		  SET @workplaceid = (SELECT TOP 1 workplaceid FROM $(ICC).dbo.Agent  WITH(NOLOCK) WHERE AgentId=@Agentid)
		  SET @Activity = (SELECT TOP 1 Activity FROM $(ICC).dbo.Agent  WITH(NOLOCK) WHERE AgentId=@Agentid)
		   
		  IF @workplaceid IS NULL
			BEGIN -- Agent je odhlášený, tak jej musí zpět přihlásit
			  SET @Statusid = (SELECT TOP 1 [StatusId] FROM $(ICC).[dbo].[Status] WHERE Activity='Ready')
			  SET @workplaceid = (SELECT TOP 1 workplaceid FROM $(ICC).dbo.InboundCall  WITH(NOLOCK) WHERE AgentId=@Agentid ORDER BY PilotTime DESC)
			  UPDATE $(ICC).dbo.Agent
               SET  Activity='Ready', Statusid=@Statusid, workplaceid=@workplaceid WHERE AgentId=@Agentid
              insert into $(ICC).dbo.AgentEvent([TimeUtc],[TimeLocal],[EventType],[AgentId],[WorkplaceId],[ReferenceData])
		        values(GETUTCDATE(),GETUTCDATE(),'AgentLogon',@Agentid,@workplaceid,'AUTOMAT')

		      SET @EmlMsg=@AutoLogon
			  SET @Subject=FormatMessage(@AgentwWasLogoff,@AgentName)
			  SET @Specif = ''
			  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,1000
			END
		  ELSE
		   IF @AgentName IS NOT NULL AND @Activity<>'PostCall'
			BEGIN
				SET @EmlMsg= @InspectPlease -- 'Prosím o kontrolu'
				SET @Subject=FormatMessage(@AgentNotReady,@AgentName) --'Agent '+@AgentName+' není ready, ale má být trvale přihlášen'
				SET @Specif = ' Activity='+@Activity
		        EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,1000
			END
	
      END
-- Kontrola duplicit na pracovištích:
	DECLARE @DuplicWP AS NVARCHAR(50)=(.dbo.DuplicWP())
   IF  @DuplicWP IS NOT NULL
	 BEGIN
				SET @EmlMsg= @InspectPlease -- 'Prosím o kontrolu'
				SET @Subject=FormatMessage(@DuplicWPMess,@DuplicWP) 
				SET @Specif = ' '
		        EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,1000

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
  	      SET  @EmlMsg=@InspectPlease
	      insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		  values(@Now,'Email','Scheduled','Active', @GWN, @TOCC,@TOCC,@GW,99,'O',
		  ' Incoming emails are not assigned to cases (AssignMailOfIssue)'+@ProcVer , @EmlMsg, @EmlMsg, @Mark )
         END
		-- Tady by mohla být ještě kontrola příchozí pošty na jednotlivých branách
      END
	  	------------------------------------------------------------------------------------
IF db_id('ProServer') IS NOT NULL 
  BEGIN	 	
		-- Kontrola duplicit na ProServeru:
	DECLARE @DuplicExt AS NVARCHAR(50)=(.dbo.DuplicExt())
   IF  @DuplicExt IS NOT NULL
	 BEGIN
  	      SET  @EmlMsg=@InspectPlease
			SET @Subject=' On proServer is duplicate extension '+@DuplicExt+' This will cause it to malfunction'
			SET @Specif = ''
			EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,30
	 --  insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		--values(@Now,'Email','Scheduled','Active', @GWN, @TGT,@TGT,  @TOCC ,@GW,99,'O',
		--  ' On proServer is duplicate extension '+@DuplicExt+' This will cause it to malfunction'+@ProcVer , @EmlMsg, @EmlMsg, @Mark )
     END

	 	-- Kontrola nefunkčních linek na ProServeru:
DECLARE @Number AS varchar(16)
DECLARE My_cursor CURSOR FOR   
 SELECT  [Number] FROM [ProServer].[dbo].[Extension] WITH (NOLOCK) -- OnLineStatus=7 ExtensionIsnotAlive (Vypnutý SP)
  WHERE OnLineStatus<>10 AND OnLineStatus<>0 AND OnLineStatus<>7 AND Deleted=0 AND Suspended=0 AND Description NOT LIKE '%SoftPhone%'
  -- ExtensionNotAlive = 7
   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @Number   
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @Number IS NOT NULL 
		BEGIN
			  SET @EmlMsg=@InspectPlease
			  SET @Subject='extension '+@Number+' is not OK on ProServer'
			  SET @Specif = ''
			  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,1000
		END
		FETCH NEXT FROM My_cursor INTO @Number  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;
--------------------------------------------------------------------------------------------------------------------------------------
	 -- Kontrola linek/pracovišť
DECLARE @TotalWP AS Integer,@OutOfOrder AS Integer
SELECT @TotalWP=ISNULL(SUM(1),0),@OutOfOrder=ISNULL(SUM(CASE WHEN State='OutOfOrder' THEN 1 ELSE 0 END),0) FROM $(ICC).[dbo].[Workplace] WITH (NOLOCK) WHERE Deleted=0
   IF  @TotalWP>0 AND @TotalWP=@OutOfOrder
	 BEGIN
	     SET  @EmlMsg=@InspectPlease
		 SET @Subject='All workplaces are out of order '
		 SET @Specif = ''
		 EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,180
     END

	 -- Kontrola IVR vstupů
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'OnlineStatus' AND Object_ID = Object_ID(N'dbo.IVRENTRY'))
  BEGIN
    DECLARE @Command AS NVARCHAR(500)='DECLARE @WPOK AS Integer =(SELECT TOP 1 1 FROM $(ICC).[dbo].[IVREntry] WITH (NOLOCK) WHERE OnlineStatus<>0 AND Deleted=0)	  
     IF  @WPOK IS NOT NULL
	   BEGIN
	     SET  @EmlMsg=@InspectPlease
		 SET @Subject=''Some IVR input is down ''
		 SET @Specif = ''''
		 EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,180
       END
	
	 '
    EXEC (@Command)
  
  END
  -- Kontrola blokace agentského pracoviště Adminem
  SET @AgentId =(SELECT TOP 1 AgentId FROM $(ICC).[dbo].[Agent] where TeamName='ADMIN' AND WorkplaceId IS NOT NULL AND DATEDIFF(Hour,LastRefreshUtc,GETUTCDATE())>4)
  IF @AgentId IS NOT NULL
   BEGIN
    SET @WorkplaceId =(SELECT TOP 1 WorkPlaceId FROM $(ICC).[dbo].[Agent] where AgentId=@AgentId)
    DECLARE @TimeUTC as Datetime = (SELECT TOP 1 TimeUTC FROM $(ICC).[dbo].[AgentEvent] where EventType='AgentStatus' AND AgentId=@AgentId ORDER BY EventType,AgentId,TimeUTC DESC)
	IF DATEDIFF(Hour,@TimeUTC,GETUTCDATE())>4 AND EXISTS (SELECT TOP 1  AG.[AgentId] FROM $(ICC).[dbo].[Seating] AS SEA WITH (NOLOCK) 
      INNER JOIN $(ICC).[dbo].[Agent] AS AG WITH (NOLOCK) ON SEA.AgentId=AG.AgentId WHERE SEA.WorkPlaceId=@WorkplaceId AND AG.TeamName<>'ADMIN')
	    BEGIN
		  SET @AgentName = RTRIM((SELECT TOP 1 DisplayName FROM $(ICC).[dbo].[Agent] where AgentId=@AgentId))
		  SET @EmlMsg='I''m logging off Admin'
		  SET @Subject='Admin '+@AgentName+' was logged on and blocked workplace agents.'
		  SET @Specif = ISNULL((SELECT Displayname FROM $(ICC).dbo.Workplace WHERE WorkplaceId=@WorkplaceId),'')
		  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,180
          EXEC $(FS_CUSTOM).dbo.LogOffAgent @AgentId
		END	  
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
 		  SET @EmlMsg=@InspectPlease
		  SET @Subject='Agent '+@AgentName+' is logged out. His workplace seems to be down.'
		  SET @Specif = ISNULL((SELECT Displayname FROM $(ICC).dbo.Workplace WHERE WorkplaceId=@WorkplaceId),'')
		  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,220
   END

    -- Kontrola chyb v IssueCondition:
	
SELECT TOP 1 @String1=ISUC.[DisplayName],@String2=TPC.DisplayName FROM $(ICC).[dbo].[IssueCondition] ISUC WITH (NOLOCK)
  LEFT JOIN $(ICC).[dbo].[Topic] TPC WITH (NOLOCK) ON TPC.TopicId=ISUC.NormalTopicId
  WHERE ISUC.NormalTopicId IS NOT NULL AND TPC.TopicId IS  NULL OR TPC.Deleted=1

  IF @String2 IS NOT NULL
   BEGIN
  		  SET @EmlMsg=@InspectPlease
		  SET @Subject='Issue rule '+@String1+' uses bad / deleted topic '+@String2
		  SET @Specif = ''
		  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,600
   END

    -- Kontrola chyb v ProjectCondition:
	
SELECT TOP 1 @String1=PC.[DisplayName],@String2=PR.DisplayName FROM $(ICC).[dbo].[ProjectCondition] PC WITH (NOLOCK)
  LEFT JOIN $(ICC).[dbo].[Project] PR WITH (NOLOCK) ON PC.ProjectId=PR.ProjectId
  WHERE  PR.ProjectId IS  NULL OR PR.Deleted=1

  IF @String2 IS NOT NULL
   BEGIN
  		  SET @EmlMsg=@InspectPlease
		  SET @Subject='Project rule of inbound calls '+@String1+' uses bad / deleted project '+@String2
		  SET @Specif = ''
		  EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,0,600
   END
 SET @String1=NULL
 SET @String2=NULL
  -- Kontrola synchronizačních procedur atd.
  DECLARE @Procedura AS NVARCHAR(50)
  DECLARE @Popis AS NVARCHAR(900)
  DECLARE @DatumCas AS Datetime

DECLARE My_cursor CURSOR FOR   
 SELECT DISTINCT TOP 10 Procedura,Popis,DatumCas  FROM .[dbo].[Eventlog] WITH (NOLOCK) WHERE DatumCas>@Yesterday AND DatumCas<@Pred15min AND (Popis IN ('Vstupní bod','Entry point') OR Procedura='SystemTests')
   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @Procedura,@Popis,@DatumCas    
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @Procedura  IS NOT NULL
		BEGIN
	       IF @Procedura='SystemTests' OR
		   NOT EXISTS(SELECT TOP 1 Procedura  FROM .[dbo].[Eventlog] WITH (NOLOCK) WHERE DatumCas>@Yesterday AND Popis IN ('Konec procedury','End of procedure') AND Procedura=@Procedura)
		     BEGIN
			  SET @Severity=CASE WHEN LEFT(@Popis,15)='Warning : Drive' THEN 1 ELSE 0 END
			  SET @EmlMsg=@InspectPlease
			  IF  @Procedura='SystemTests'
			    BEGIN
			      SET @Subject=CASE WHEN @Severity=1 THEN LEFT(@Popis,17) ELSE @Popis END
				  -- Označím si zprávu jako zpracovanou
					UPDATE [dbo].[Eventlog]
					   SET [Procedura] = 'STProcessed'
					 WHERE DatumCas=@DatumCas AND Procedura='SystemTests'
                END
			  ELSE 
			   SET @Subject=' Procedure: '+RTRIM(@Procedura)+' is not finished correctly.'
			  SET @Specif = CASE WHEN @Severity=1 THEN SUBSTRING(@Popis,18,50) ELSE '' END
			  IF @Severity=0 OR @DatumCas>DATEADD(Hour,-2,GETDATE())
			    EXEC [dbo].[ErrorLogProc] @Subject,@Specif,@ProcVer,@EmlMsg,@Severity,1000

			 END
		END
		FETCH NEXT FROM My_cursor INTO @Procedura,@Popis,@DatumCas  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;

	-- Kontrola místa na discích:
	DECLARE @DiskName AS NVARCHAR(10),@MyPercent AS Integer,@GB AS Integer
	SELECT TOP 1 @DiskName=volume_mount_point
	  ,@MyPercent=(available_bytes/1048576* 1.0)/(total_bytes/1048576* 1.0)*100
      ,@GB=available_bytes/1048576000 
	 FROM sys.master_files AS f 
	  CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
        WHERE ( (available_bytes/1048576* 1.0)/(total_bytes/1048576* 1.0) *100)<10 AND available_bytes/1048576000<15

   IF  @DiskName IS NOT NULL
	 BEGIN
  	    SET @EmlMsg=@InspectPlease
		SET @Zprava = 'DB Server: On disk '+@DiskName+' is '+CONVERT(NVARCHAR(3),@MyPercent)+
	     '% of free place ('+CONVERT(NVARCHAR(6),@GB)+'GB)'
		SET @Specif = ''
		EXEC [dbo].[ErrorLogProc] @Zprava,@Specif,@ProcVer,@EmlMsg,10,120
     END

	-- Kontrola velikosti DB:
  IF @@Version LIKE '%Express%' AND iCC.dbo.SpaceUsed()>9850 -- MB
	  BEGIN
		SET @Zprava = 'Database $(ICC) Has almost maximum size '+CAST(CAST(FILEPROPERTY('$(ICC)', 'SpaceUsed') AS INT)/128 AS NVARCHAR(5))+'MB'
		SET @Specif = ''
		SET @Severity = 0
		SET @OpakpoMin = 30
		EXEC [dbo].[ErrorLogProc] @Zprava,@Specif,@ProcVer,@EmlMsg,@Severity,@OpakpoMin
      END

-- Kontrola zámků na DB:
-- SELECT  WS.wait_type,WS.max_wait_time_ms FROM sys.dm_os_wait_stats AS WS WHERE WS.waiting_tasks_count > 0 AND WS.wait_type LIKE 'LCK_%' AND max_wait_time_ms > 30000
   DECLARE @wait_type AS NVARCHAR(20)=(SELECT  TOP 1 wait_type FROM sys.dm_os_wait_stats AS WS WHERE WS.waiting_tasks_count > 0 AND WS.wait_type LIKE 'LCK_%' AND max_wait_time_ms > 30000)
   IF @wait_type IS NOT NULL
	 BEGIN
	   IF DATEPART(hour, GETDATE())>8
	     BEGIN -- Nechci hlásit pozůstatky noční údržby
  			SET  @EmlMsg=@InspectPlease
			SET @Specif = ' There are locks lasting over 30 seconds on SQL Server '+ @wait_type
		 END
		DBCC SQLPERF("sys.dm_os_wait_stats",CLEAR) -- RESET Statistiky
     END

 DECLARE @AVGCPU AS Int = ( SELECT 
    AVG(ProcessUtilization) as 'AVG_SQLCPU'
   FROM (
    SELECT record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') 
                          AS ProcessUtilization
    FROM (
        SELECT TOP 30
            convert(XML, record) AS record
        FROM sys.dm_os_ring_buffers
        WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
        ) AS sub1
    ) AS sub2)
   IF  (@AVGCPU > 70)
	 BEGIN
  	    SET  @EmlMsg=@InspectPlease
		SET @Specif = convert(NVARCHAR(3),@AVGCPU)+'%'
		EXEC [dbo].[ErrorLogProc] 'The average CPU load for the last hour is ',@Specif,@ProcVer,@EmlMsg,0,1000
     END
 -- Kontrola chyb v CallEvent:
    SET @EmlMsg=.[dbo].InspectCallEvent()
	IF (@EmlMsg IS NOT NULL)
	  BEGIN
		SET @Zprava = 'Error in CallEvent'
		SET @Specif = ''
		SET @Severity = 0
		SET @OpakpoMin = 1440
		EXEC [dbo].[ErrorLogProc] @Zprava,@Specif,@ProcVer,@EmlMsg,@Severity,@OpakpoMin
      END
-- Kontrola nadměrné délky hovoru:
    SET @EmlMsg=.[dbo].InspectCallLength()
	IF (@EmlMsg IS NOT NULL)
	  BEGIN
		SET @Zprava = 'Too long active Call'
		SET @Specif = ''
		SET @Severity = 0
		SET @OpakpoMin = 60
		EXEC [dbo].[ErrorLogProc] @Zprava,@Specif,@ProcVer,@EmlMsg,@Severity,@OpakpoMin
      END

-- Kontrola nastavení GDPR:
    SET @EmlMsg=NULL -- .[dbo].InspectGDPR()
	IF (@EmlMsg IS NOT NULL)
	  BEGIN
         DECLARE @GdprDefaultSensitivity AS Integer = (SELECT MIN(Sensitivity) FROM $(ICC).[dbo].[GdprSensitivity]) 
         /*update $(ICC).[dbo].[Configuration] 
           SET ConfigurationValue = @GdprDefaultSensitivity
             WHERE  ConfigurationName='GdprDefaultSensitivity'*/
		SET @Zprava = 'Error in GDPR'-- - I repair it'
		SET @Specif = ''
		SET @Severity = 0
		SET @OpakpoMin = 1440
		EXEC [dbo].[ErrorLogProc] @Zprava,@Specif,@ProcVer,@EmlMsg,@Severity,@OpakpoMin
      END

       EXEC  .[dbo].[WriteEvent] 1,'CheckFS','End of procedure'

END
GO --------------------- 

PRINT 'End of CheckRecAndEmlActivity2'

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
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC $(FS_Custom).dbo.CancelZombieCalls', N'Close Inbound Calls which are longer time in distribution', N'ee859402-15e9-48cc-802b-f40d9258b92e')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE CommandId  = '62e84a06-6f83-4594-9ccd-a756a096d3b3')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC $(FS_Custom).dbo.InspectIVR', N'Look for errors in IVR', N'62e84a06-6f83-4594-9ccd-a756a096d3b3')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE CommandId  = 'ee118948-03ea-4d0c-9f03-754fcf195980')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC $(FS_Custom).dbo.SendEmails 3', N'Send e-mails in failed status', N'ee118948-03ea-4d0c-9f03-754fcf195980')
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
   PRINT 'CustomCheck returns 0 - please repair!!!!'
/* CREATE ignorovalo klauzuli COLLATE, tak jsem to napravil takto
ALTER TABLE $(FS_Custom).dbo.HolidayPlan 
ALTER COLUMN [HolidayGroupName] [nvarchar](100)  COLLATE Czech_CI_AS NULL
*/

IF EXISTS(SELECT *  FROM sys.indexes  WHERE object_id = OBJECT_ID('$(FS_CUSTOM).DBO.Eventlog') AND name='PK_Eventlog')
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
IF object_id('IVRStepCopy') IS NOT NULL
 DROP  PROCEDURE  [dbo].[IVRStepCopy]
GO

CREATE PROCEDURE [dbo].[IVRStepCopy]
@IVRStepId UniqueIdentifier
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 20.12.2019
-- Description:	Kopíruje vybraný IVR step do vybraného IVR Scriptu
-- =============================================
--USE [iCC]
BEGIN
    declare @IVRScriptId as nvarchar(40) =.dbo.GiveParam('SELECTED_IVR')

  INSERT INTO iCC.dbo.IVRstep
 SELECT
       NewId()
      ,@IVRScriptId
      ,[DisplayName]
      ,[Rank]
      ,[Action]
      ,[TimeOut]
      ,[WaitTimeOut]
      ,[FileName]
      ,[MultiLanguage]
      ,[Retries]
      ,[ResultDigits]
      ,[SkipDigits]
      ,[ReplayDigits]
      ,[Targets]
      ,[TargetId]
      ,[Numbers]
      ,[TimeMode]
      ,[TimeFrom]
      ,[TimeTo]
      ,[Culture]
      ,[Deleted]
      ,[TargetOnTimeOut]
      ,[TargetOnSuccess]
      ,[TargetOnFailure]
  FROM iCC.[dbo].[IvrStep] WHERE IvrStepId=@IVRStepId
 
 END 
GO



IF object_id('GatewayTest') IS NOT NULL
 DROP  PROCEDURE  [dbo].[GatewayTest]
GO

CREATE  PROCEDURE [dbo].[GatewayTest]
@GatewayId UniqueIdentifier
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 28.06.2021
-- Description:	Testuje bránu
-- =============================================
BEGIN
  DECLARE @Direction AS NVARCHAR(1) = (SELECT TOP 1 [Direction] FROM $(iCC).[dbo].[Gateway] WHERE GatewayId=@GatewayId)
  DECLARE @PPilotAddress AS NVARCHAR(200) = (SELECT TOP 1 PilotAddress FROM $(iCC).[dbo].[Gateway] WHERE GatewayId=@GatewayId)
  DECLARE @InspectAddress as nvarchar(200) =.dbo.GiveParam('TOCC')
  DECLARE @RemoteAddress AS NVARCHAR(100) = IIF(@Direction='O',@InspectAddress,@PPilotAddress)
		 ,@TestId AS UniqueIdentifier = (SELECT TOP 1 GatewayId FROM $(iCC).[dbo].[Gateway] WHERE Direction IN ('B','O'))
  SET @GatewayId=IIF(@Direction='I',@TestId,@GatewayId)
  EXEC [dbo].[Write_Mail] @GatewayId,@RemoteAddress, 'Test','Test' -- Odeslání testovacího mailu
END 

GO

IF object_id('TranslateCol') IS NOT NULL
 DROP  PROCEDURE  [dbo].[TranslateCol]
GO

CREATE PROCEDURE [dbo].[TranslateCol]
@OldName NVARCHAR(50)
,@NewName NVARCHAR(50)
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <11.6.2021>
-- Description:	<Přejmenování sloupce v gridu>
-- =============================================

BEGIN
PRINT 'I rename column '+@OldName
UPDATE TOP (100) DQC
SET  DisplayName=@NewName
FROM $(iCC).dbo.DataQueryColumn DQC
  inner join $(iCC).dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
  LEFT JOIN $(iCC).dbo.[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
WHERE DQ.Deleted=0 AND PRT.NAVGroup='AdminPageNav'
	AND DQ.QueryGroup IN ('Admin','Kontakty','Supervizor')  AND DQC.DisplayName NOT LIKE '$%'
	AND  DQC.DisplayName=@OldName 

END

GO
IF object_id('GetPhoneNumPhoneBooks') IS NOT NULL
 DROP  FUNCTION  [dbo].GetPhoneNumPhoneBooks
GO

CREATE FUNCTION [dbo].[GetPhoneNumPhoneBooks] (@PhoneNumberId AS uniqueidentifier)
RETURNS nvarchar(max)
AS
BEGIN
	IF @PhoneNumberId IS NULL RETURN NULL
	DECLARE @Result AS nvarchar(max)
	SELECT 
		@Result = COALESCE(@Result + ',', '') + PB.DisplayName 
	FROM 
		iCC.dbo.PhoneComposition AS PC WITH (NOLOCK)
	INNER JOIN
		iCC.dbo.PhoneBook AS PB WITH (NOLOCK) ON PC.PhoneBookId=PB.PhoneBookId
	WHERE
		PC.PhoneNumberId=@PhoneNumberId AND PB.Deleted=0

	RETURN @Result

END
GO

IF object_id('InspectCalllength') IS NOT NULL
 DROP  FUNCTION  [dbo].InspectCalllength
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.12.2021>
-- Description:	<Kontrola délky aktivního hovoru>
-- =============================================
CREATE FUNCTION [dbo].InspectCalllength
(

)
RETURNS nvarchar(64)
AS
BEGIN
DECLARE @from AS datetime=DATEADD(Minute,-70,GETDATE())

RETURN (
	SELECT TOP (1) 'Agent '+RTRIM(AG.DisplayName)+' has long active call.'
  FROM $(ICC).[dbo].[InboundCall] IC 
     LEFT JOIN $(ICC).[dbo].Agent AG ON IC.AgentId=AG.AgentId
  WHERE CallResult='Active' AND PilotTime< @from)

END
GO


IF object_id('InspectCallEvent') IS NOT NULL
 DROP  FUNCTION  [dbo].InspectCallEvent
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <25.11.2021>
-- Description:	<Kontrola chyb v CallEvent>
-- =============================================
CREATE FUNCTION [dbo].[InspectCallEvent]
(

)
RETURNS nvarchar(64)
AS
BEGIN
DECLARE @from AS datetime=DATEADD(Minute,-55,GETDATE())

 	RETURN (SELECT TOP (1) RTRIM([ResultData])+' '+EventType
  FROM $(ICC).[dbo].[CallEvent] WHERE EventType='IvrScriptA' AND ReferenceData='Error' AND Timelocal> @from
)

END
GO

IF object_id('InspectGDPR') IS NOT NULL
 DROP  FUNCTION  [dbo].InspectGDPR
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <29.11.2021>
-- Description:	<Kontrola chyb v GDPR>
-- =============================================
CREATE FUNCTION [dbo].[InspectGDPR]
(

)
RETURNS nvarchar(64)
AS
BEGIN
DECLARE @GdprDefaultSensitivity AS Integer=.dbo.GiveParam('GdprDefaultSensitivity')
DECLARE @Message nvarchar(64) = ''
IF (SELECT TOP 1 [Sensitivity] FROM $(ICC).[dbo].[GdprSensitivity] WHERE Sensitivity=@GdprDefaultSensitivity) IS NULL
  BEGIN
    SET @Message = 'Wrong GdprDefaultSensitivity Value in Configuration'
  END
 RETURN @Message

END
GO


IF object_id('RecordingLessCallsS') IS NOT NULL
 DROP  FUNCTION  [dbo].RecordingLessCallsS
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <28.7.2021>
-- Description:	<Kontrola nespárovaných hovorů>
-- =============================================
CREATE FUNCTION [dbo].[RecordingLessCallsS]
(
@RecordingsLess AS Integer

)
RETURNS Integer
AS
BEGIN
   DECLARE @PairingTime AS Integer=.dbo.GiveParam('PairingTime')
   DECLARE @from AS datetime=DATEADD(Hour,-3,GETDATE())
   DECLARE @to AS datetime=DATEADD(Minute,-@PairingTime,GETDATE())
   DECLARE @UTCDif AS Integer = (SELECT TOP 1 DATEDIFF(HOUR,PilotTime,TimeUTC) FROM $(ICC).dbo.InboundCall WITH (NOLOCK) ORDER BY TIMEUTC DESC)
   DECLARE @fromUTC AS datetime=DATEADD(Hour,@UTCDif,@from)
   DECLARE @toUTC AS datetime=DATEADD(Hour,@UTCDif,@to)

	RETURN (SELECT TOP (@RecordingsLess+1)  COUNT(1)
  FROM $(ICC).dbo.[InboundCall] IC
    LEFT JOIN $(ICC).[dbo].[CallRecord] CR ON CR.InboundCallId=IC.InboundCallId
	LEFT JOIN [SRec].[dbo].[Directory] DI ON RIGHT(DI.Number,3) COLLATE Czech_CI_AS =IC.Redirector COLLATE Czech_CI_AS
	LEFT JOIN $(ICC).[dbo].[Workplace] WP WITH (NOLOCK) ON WP.WorkplaceId=IC.WorkplaceId
  WHERE TimeUTC>@FromUTC AND TimeUTC<@ToUTC
  AND CallDuration>1
  AND CR.INboundCallId IS NULL   
  AND CallResult ='served'
  AND LEN(CallerNumber)>6
  AND isnull(DI.Record,1) <> 0
  AND ($(FS_CUSTOM).dbo.CustomCheck2('IC',WP.DisplayName)=1 OR $(FS_CUSTOM).dbo.CustomCheck2('ID',IC.Redirector)=1
  OR $(FS_CUSTOM).dbo.CustomCheck2('IP',LEFT(IC.PilotId,20))=1)
)

END
GO


IF object_id('DuplicExt') IS NOT NULL
 DROP  FUNCTION  [dbo].DuplicExt
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <8.7.2021>
-- Description:	<Kontrola duplicit na ProServeru>
-- =============================================
Create FUNCTION [dbo].[DuplicExt]
(
	-- Add the parameters for the function here

)
RETURNS NVARCHAR(50)
AS
BEGIN
	RETURN (SELECT TOP 1 ProServer_Extension FROM
             (SELECT 
			  [Number] AS ProServer_Extension
			  ,COUNT(1) AS Pocet
		  FROM [ProServer].[dbo].[Extension]
		  WHERE Deleted=0
		  GROUP BY Number) AS Phase1
		  WHERE Pocet>1)

END

GO


IF object_id('DuplicWP') IS NOT NULL
 DROP  FUNCTION  [dbo].DuplicWP
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <22.9.2021>
-- Description:	<Kontrola duplicit pracovišť>
-- =============================================
Create FUNCTION [dbo].DuplicWP
(
	-- Add the parameters for the function here

)
RETURNS NVARCHAR(50)
AS
BEGIN
 RETURN (SELECT TOP 1 Number FROM
 (SELECT 
      [Number] 
      ,COUNT(1) AS Pocet
  FROM [iCC].[dbo].[Workplace]
  WHERE Deleted=0
  GROUP BY Number) AS Phase1
  WHERE Pocet>1)

END

GO





IF object_id('VolniAgentiCall') IS NOT NULL
 DROP  FUNCTION  [dbo].VolniAgentiCall
GO

CREATE FUNCTION [dbo].[VolniAgentiCall]
(	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
     IIF(ST.Activity='Ready'
	 AND PROF.LanguageId IS NOT NULL
	 AND WP.State='Free'
	 AND Skill.PbxInKnowledge>0
	 AND PROF.VoiceKnowledge>0
       ,'YES','NO ') AS FreeAgent
     ,A.DisplayName AS AgentName
     , P.DisplayName AS ProjectName 
	 ,Skill.PbxInKnowledge
	 , ST.DisplayName AS AgentStatus
	 , ST.PbxState
	 , LANG.DisplayName AS LangKnowledge
	 , WP.State AS WPState
     FROM $(iCC).dbo.Agent A  WITH (NOLOCK)   
      LEFT OUTER JOIN $(iCC).dbo.Skill  WITH (NOLOCK)
 ON Skill.AgentId=A.AgentId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1
      LEFT OUTER JOIN $(iCC).dbo.Project P  WITH (NOLOCK)
 ON P.ProjectId=Skill.ProjectId AND P.Deleted=0
      LEFT OUTER JOIN $(iCC).dbo.Status ST  WITH (NOLOCK)
 ON A.Activity=ST.Activity AND A.StatusId = ST.StatusId
     LEFT OUTER JOIN $(iCC).dbo.Workplace WP  WITH (NOLOCK)
 ON WP.WorkplaceId=A.WorkplaceId
    LEFT OUTER JOIN $(iCC).dbo.Proficiency PROF  WITH (NOLOCK)
 ON PROF.AgentId=A.AgentId AND PROF.VoiceKnowledge>0 AND PROF.VoiceEnabled=1 AND PROF.VoiceChannel=1
       LEFT OUTER JOIN $(iCC).dbo.Language LANG  WITH (NOLOCK)
 ON LANG.LanguageId=PROF.LanguageId

     WHERE A.Deleted=0 AND Template=0
 
     )

GO



IF object_id('VolniAgentiEmail') IS NOT NULL
 DROP  FUNCTION  [dbo].VolniAgentiEmail
GO

CREATE FUNCTION [dbo].[VolniAgentiEmail]
(	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
     IIF(EmailConsumption>0 AND EmailCount < ROUND(IIF(EmailConsumption>0,100/EmailConsumption,0),0)
	 AND ST.EmailDistribute=1
	 AND PROF.LanguageId IS NOT NULL
	 AND WP.Message=1,'YES','NO ') AS VolnyAgent
     ,A.DisplayName AS AgentName
     , P.DisplayName AS ProjectName 
	 , ST.DisplayName AS Statusagenta
     , EmailCount
	 , ROUND(IIF(EmailConsumption>0,100/EmailConsumption,0),0) AS MaxEmailCount
	 , LANG.DisplayName AS ZnalostJazyka
	 , ST.EmailDistribute AS EmailPovolenStav
	 , WP.Message AS EmailPovolenPracov
     FROM $(iCC).dbo.Agent A  WITH (NOLOCK)   
      LEFT OUTER JOIN $(iCC).dbo.Skill  WITH (NOLOCK)
 ON Skill.AgentId=A.AgentId AND Skill.EmailKnowledge>0 AND Skill.EmailEnabled=1 AND Skill.EmailChannel=1
      LEFT OUTER JOIN $(iCC).dbo.Project P  WITH (NOLOCK)
 ON P.ProjectId=Skill.ProjectId
      LEFT OUTER JOIN $(iCC).dbo.Status ST  WITH (NOLOCK)
 ON A.Activity=ST.Activity AND A.StatusId = ST.StatusId
     LEFT OUTER JOIN $(iCC).dbo.Workplace WP  WITH (NOLOCK)
 ON WP.WorkplaceId=A.WorkplaceId
    LEFT OUTER JOIN $(iCC).dbo.Proficiency PROF  WITH (NOLOCK)
 ON PROF.AgentId=A.AgentId AND PROF.MessageKnowledge>0 AND PROF.MessageEnabled=1 AND PROF.MessageChannel=1
       LEFT OUTER JOIN $(iCC).dbo.Language LANG  WITH (NOLOCK)
 ON LANG.LanguageId=PROF.LanguageId

     WHERE A.Deleted=0
          --A.Activity<>'Logoff'
	 --AND EmailConsumption>0 AND EmailCount < ROUND(100/EmailConsumption,0)
	 --AND ST.EmailDistribute=1
	 --AND WP.Message=1
	 --ORDER BY A.DisplayName
	 ------------------------------------
	 --AND A.AgentId=Skill.AgentId 
	 --AND ST.DisplayName<>'Odhlášen'

              
)

GO

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
  SET MessagePhase='Scheduled',MessageResult='Active'
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

IF object_id('TranslateDQ') IS NOT NULL
 DROP  PROCEDURE  [dbo].TranslateDQ
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <13.02.2020>
-- Description:	<Zápis mailu>
-- =============================================

CREATE PROCEDURE [dbo].TranslateDQ (
 @DisplayName AS NVARCHAR(200)
, @DisplayNameEn AS NVARCHAR(200)
, @QueryGroup AS NVARCHAR(200)
)
AS
BEGIN
DECLARE @Id AS UNIQUEIDENTIFIER --='22669630-84AA-49FC-9868-96DEE92E5B55'
SET @Id=(SELECT TOP 1 DataQueryId FROM $(iCC).dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
IF @Id IS NULL
  BEGIN -- Není text díky chybné CP Pačesky??
    SET @DisplayName=REPLACE(@DisplayName,'ř','o')
    SET @Id=(SELECT TOP 1 DataQueryId FROM $(iCC).dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
  END
IF @Id IS NOT NULL
  BEGIN
   UPDATE DQ
     SET  DisplayName = @DisplayNameEn
     FROM $(iCC).dbo.DataQuery DQ
       WHERE DataQueryId=@Id
   UPDATE .$(iCC).[dbo].[Portal] SET JsonData = REPLACE(JsonData,@DisplayName,@DisplayNameEn)   
	WHERE JsonData LIKE '%'+CONVERT(NVARCHAR(36),@Id)+'%'
  END
END

GO

IF object_id('ChangeDQ') IS NOT NULL
 DROP  PROCEDURE  [dbo].ChangeDQ
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <22.06.2021>
-- Description:	<Zmena príkazu v DQ>
-- =============================================

CREATE PROCEDURE [dbo].ChangeDQ (
 @oldString AS NVARCHAR(500)
, @newString AS NVARCHAR(500)
, @QueryGroup AS NVARCHAR(200)
)
AS
BEGIN
DECLARE @Id AS UNIQUEIDENTIFIER --='22669630-84AA-49FC-9868-96DEE92E5B55'
SET @Id=(SELECT TOP 1 DataQueryId FROM $(iCC).dbo.DataQuery WHERE QueryText LIKE '%'+@oldString+'%'
  AND QueryGroup=@QueryGroup)
IF @Id IS NULL
  BEGIN -- Není text díky chybné CP Pačesky??
    SET @oldString=REPLACE(@oldString,'ř','o')
    SET @Id=(SELECT TOP 1 DataQueryId FROM $(iCC).dbo.DataQuery WHERE QueryText LIKE '%'+@oldString+'%'
	AND QueryGroup=@QueryGroup)
  END
IF @Id IS NOT NULL
  BEGIN
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,@oldString,@newString)
     FROM $(iCC).dbo.DataQuery DQ
       WHERE DataQueryId=@Id
  END
END

GO

IF object_id('Write_Mail') IS NOT NULL
 DROP  PROCEDURE  [dbo].[Write_Mail]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <13.02.2020>
-- Description:	<Zápis mailu>
-- =============================================

CREATE PROCEDURE [dbo].[Write_Mail] (
@GW as uniqueidentifier,
@RemoteAddress as nvarchar(200),
@SubjectField as nvarchar(200),
@Message as nvarchar(500)
)
AS
BEGIN
  DECLARE @FromField as nvarchar(200)=(SELECT TOP 1 [DisplayName] FROM $(ICC).[dbo].[Gateway] WHERE [GatewayId]=@GW)
  DECLARE @TimeLocalMess as DateTime
  insert into $(ICC).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText)
		values(GETUTCDATE(),'Email','Scheduled','Active', @FromField, @RemoteAddress,@RemoteAddress ,@GW,99,'O',@SubjectField, @Message , @Message )
/**/

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
  DECLARE @LimDat AS Datetime = GETDATE()-90
  DELETE FROM [dbo].[Eventlog] WHERE DatumCas<@LimDat
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
 IF EXISTS(SELECT 1 FROM $(iCC).dbo.Agent WHERE Agentid=@AgentId AND Activity<>'Logoff')
  BEGIN
    DECLARE @LogoffId UniqueIdentifier = (SELECT TOP 1 [StatusId] FROM $(iCC).[dbo].[Status] WHERE Activity='Logoff')
    INSERT $(iCC).dbo.ChangeRequest( ChangeRequestTimeUtc , Command , SubjectId, ReferenceId)
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
DECLARE @TeamName AS nvarchar(120)
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
   SET @SystemName = (SELECT TOP 1 SystemName  from #TEMP)
   IF @SystemName IS NULL SET @Pokracuj = 0
   ELSE
     BEGIN   
	   -- Ověřím, zda existuje uživatel v SREC
	   SET @AccountId = (SELECT TOP 1 AccountId FROM [SRec].[dbo].[Account] WHERE SystemName=@SystemName)

	   IF @AccountId IS NULL 
		 BEGIN
		  SELECT  TOP 1 @DisplayName=DisplayName,@TeamName=TeamName From $(ICC).dbo.Agent WHERE SystemName=@SystemName
		   INSERT INTO [SRec].[dbo].[Account]
			   (
				[SystemName]
			   ,[DisplayName]
			   ,[TeamName]
			   )
		   VALUES
			   (
			   @SystemName,
			   @DisplayName
			  ,@TeamName)
           SET @AccountId = (SELECT TOP 1 AccountId FROM [SRec].[dbo].[Account] WHERE SystemName=@SystemName)         
		 END
       END
	 DELETE FROM #TEMP WHERE SystemName=@SystemName
  END

  PRINT 'I update Supervisors'
  
 UPDATE SAC
  SET  Supervisor = AG.Supervisor, TeamName = AG.TeamName
  FROM [SRec].[dbo].[Account] SAC
  inner join $(ICC).dbo.Agent AG on SAC.SystemName COLLATE DATABASE_DEFAULT=AG.SystemName COLLATE DATABASE_DEFAULT
 WHERE SAC.Supervisor<AG.Supervisor

/*
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
		 END */

	-- END
-- Zkontroluji obecná nastavení:
 SET @RoleId = (SELECT TOP 1 RoleId FROM [SRec].[dbo].[Role] WHERE SystemName='AccessRecordByAgent')
 IF @RoleId IS NOT NULL
   BEGIN
     IF NOT EXISTS(SELECT TOP 1 [PermissionId] FROM [SRec].[dbo].[Permission] WHERE RoleId=@RoleId AND Supervisor IS NULL)
	   BEGIN
		INSERT INTO [SRec].[dbo].[Permission]
			   (
				[RoleId]
			   ,[Degree])
			VALUES
			   (
				@RoleId, 
				1)
		    PRINT 'Listening rights for the general agent have been added'
	   END
    END
   IF NOT EXISTS(SELECT TOP 1 [PermissionId] FROM [SRec].[dbo].[Permission] WHERE RoleId=@RoleId AND Supervisor = 1)
	   BEGIN
		INSERT INTO [SRec].[dbo].[Permission]
			   (
				[RoleId]
			   ,Supervisor
			   ,[Degree])
			VALUES
			   (
				@RoleId, 
				1,
				3)
		    PRINT 'Listening rights for the general supervisor have been added '
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
   DECLARE @PhoneCompositionId AS UniqueIdentifier=(SELECT PhoneCompositionId FROM $(iCC).[dbo].[PhoneComposition]  WHERE PhoneBookId=@PhoneBookId AND PhoneNumberId=@PhoneNumberId)
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
--USE $(iCC)
BEGIN
    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)
	DECLARE @Hlaska AS NVARCHAR(900) = 'IVR Inspection: '
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
    AND NOT EXISTS(SELECT TOP 1 1 FROM $(iCC).[dbo].[IvrScript] IV WHERE IVS.TargetId=IV.IvrScriptId)
 
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

INSERT INTO ##TEMP
 select IVS.IvrStepId AS Id, 'Goto' AS Action  from $(ICC).dbo.IVRStep IVS WITH (NOLOCK)
   INNER JOIN $(ICC).dbo.IVRScript IV ON IV.IvrScriptId=IVS.IvrScriptId AND IV.Deleted=0
   LEFT JOIN $(ICC).dbo.IVRStep IV2 ON IV2.Rank=IVS.Targets AND IV2.IvrScriptId=IVS.IvrScriptId AND IV2.Deleted=0
   WHERE  1=1
   AND IVS.Action='Holiday'
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
 select PC.IvrStepId AS Id, PC.Action  FROM $(iCC).[dbo].[IvrStep] PC
	  LEFT JOIN $(iCC).[dbo].[IvrScript] IVR ON IVR.[IvrScriptId]=PC.[TargetId]
	  LEFT JOIN $(iCC).[dbo].[IvrScript] IVRP ON IVRP.[IvrScriptId]=PC.[IvrScriptId]
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
              WHEN @Action='Gosub' THEN 'Call a non-existent procedure:'
			  WHEN @Action='Holiday' THEN 'Non-existent holiday:'
			  WHEN @Action='Goto' THEN 'Jump to a non-existent label:'
			  WHEN @Action='SingleSteptransfer' THEN 'Wrong value in Numbers'
  			  ELSE 'Action '+@Action+' was not recognized'
		    END
			SET @Popis=@Popis+.dbo.IVRStepIdent(@Id)
		  EXEC .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
		  DELETE FROM ##TEMP WHERE Id=@Id
		END
    END
	    -- Ještě zápis protokolu
	SET @Hlaska = @Hlaska+CASE WHEN @PocChyb=0 THEN 'Error not found' ELSE 'Found '+CONVERT(NVARCHAR(5),@PocChyb)+' errors' END
    EXEC .dbo.ZapisProtok1 @Hlaska

    EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, 'End of procedure'
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
  DECLARE @Hlaska AS NVARCHAR(200) = 'Agent personalization '+@AgentName+' was deleted'
  DELETE FROM $(ICC).dbo.Perso WHERE AgentId=@AgentId and RefName not in ('ProCaller#RibbonDefinition','ProCaller#EventHandlingDefinition') -- Zatím jenom Perso pro Reactlient
  IF @UserId IS NOT NULL
    delete from [ASPNET_iCC].[dbo].[aspnet_PersonalizationPerUser] where UserId=@UserId

  -- Ještě zápis protokolu
  EXEC .dbo.ZapisProtok1 @Hlaska
 END

GO

IF object_id('IVRStepIdent') IS NOT NULL
 DROP  Function  [dbo].IVRStepIdent
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <19-07-2018>
-- Description:	Zjišťuje identifikaci IVR kroku z jeho ID
-- ======================================================

CREATE function [dbo].[IVRStepIdent] (
    @IVRStepId UniqueIdentifier
)
returns NVARCHAR(900)
as begin
    DECLARE @Popis AS NVARCHAR(900) =(	
	SELECT TOP 1 ' IVRScript='+(SELECT TOP 1 DisplayName FROM $(iCC).[dbo].[IvrScript] IV WITH (NOLOCK) WHERE IV.IVRScriptId=IVS.IVRScriptId)+
	'   IVRStep='+IVS.DisplayName+'   Rank='+CONVERT(nvarchar(6),IVS.Rank)
     FROM $(iCC).[dbo].[IvrStep] IVS WITH (NOLOCK)
	 WHERE IVRStepId=@IVRStepId
	)

return @Popis
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


IF object_id('GiveParam3') IS NOT NULL
 DROP  Function  [dbo].[GiveParam3]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <2.9.2021>
-- Description:	<vrací hodnotu požadovaného parametru>
-- =============================================
CREATE FUNCTION [dbo].[GiveParam3]
(
	-- Add the parameters for the function here
    @ConfigurationName AS NVARCHAR(50)
   ,@ConfigurationValue AS NVARCHAR(MAX) 
   ,@Description AS NVARCHAR(800)

)
RETURNS NVARCHAR(MAX)
AS
BEGIN
  DECLARE @ConfigurationValue2 AS NVARCHAR(MAX) = (SELECT ConfigurationValue FROM $(ICC).[dbo].[CONFIGURATION]  WHERE ConfigurationName=@ConfigurationName)
  IF @ConfigurationValue2 IS NULL
  	  EXEC [dbo].[WriteParam] @ConfigurationName,@ConfigurationValue, @Description
  ELSE
  	  SET @ConfigurationValue=@ConfigurationValue2
	RETURN @ConfigurationValue
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


IF object_id('CancelZombieCalls') IS NOT NULL
 DROP  Procedure  [dbo].CancelZombieCalls
GO


 CREATE PROCEDURE [dbo].[CancelZombieCalls]
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 19.10.2018
-- Description:	Ruší příchozí hovory, které jsou aktivní přes 70minut
-- =============================================

BEGIN

DECLARE @Now AS datetime=GETDATE()
DECLARE @TimeLimit AS datetime=DATEADD(Minute,-70,@Now)


UPDATE $(iCC).[dbo].[InboundCall]
SET CallResult = 'NoResult', CallPhase = 'HangupAgent'
WHERE 1=1
  AND Callresult='Active'
  --AND CallPhase='Distributing'
  AND PilotTime < @TimeLimit

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
-- Description:	<Zapisuje protokol o výsledku akce do tabulky Results>
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
   EXEC $(FS_CUSTOM).dbo.WriteParam  N'SELECTED_IVR',@RecordId,N'Selected IVR Script'
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
		   EXEC [dbo].[WriteParam] 'TOCC', @TOCC, 'E-mail addresses to which recorded problems should be sent'
		 END
 declare @Company as nvarchar(200) =.dbo.GiveParam('Company')
 declare @MessageId as uniqueidentifier = (SELECT TOP 1 MessageId FROM $(ICC).[dbo].[Message]
	   WHERE Direction='O' AND MessageType='Email' AND ReceivedSentTime IS NOT NULL AND GatewayId IS NOT NULL ORDER BY ReceivedSentTime DESC)
 declare @GW as uniqueidentifier = CASE WHEN .dbo.GiveParam('ServiceGateWay')='' THEN
(SELECT TOP 1 [GatewayId] FROM $(ICC).[dbo].[Message] WHERE MessageId=@MessageId) ELSE .dbo.GiveParam('ServiceGateWay') END

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
	SET @Message='Warning: '+@Message
	SET @RecMsg=@RecMsg+' - This is a diagnostic message for the system administrator'

 IF @GW IS NOT NULL AND (NOT EXISTS(SELECT * FROM $(ICC).dbo.Message as M where M.Messagetype='Email' AND MessagePhase='Scheduled' AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE())
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
left join ProServer.dbo.Credentials b on a.SystemName COLLATE Czech_CI_AS =b.SystemName COLLATE Czech_CI_AS
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
-- Pozastaveno z důvodů změny struktury dat 08/2021:
/*create table #ExistsInICC
(AccountId uniqueidentifier)

Insert into #ExistsInICC
select AccountId  from proserver.dbo.credentials as c with (nolock) where SystemName COLLATE Czech_CI_AS in (
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
	where c.SystemName COLLATE Czech_CI_AS in (
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
drop table #ExistsInICC

drop table #DeletedInICC

 08/2021*/
--------smazání dat tabulek tabulky

drop table #SynchroProServer


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
	EXEC .dbo.GiveParam2 'DoplnVelikonoce', @DoplnVelikonoce OUTPUT,'Automatic replenishment of Easter holidays'
	DECLARE @DoplnMimoPrac AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'DoplnMimoPrac',@DoplnMimoPrac OUTPUT,'Supplementing the indication of non-working hours'
    DECLARE @PracDobaChatu  AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'PracDobaChatu',@PracDobaChatu OUTPUT,'Making adjustments to the working hours of chats'
	DECLARE @DoplnproServer  AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.GiveParam2 'DoplnproServer',@DoplnproServer OUTPUT,'Adding ProServer settings (Toaster)'

	DECLARE @Zprava NVARCHAR(200)= 'Entry point'
   EXEC  .[dbo].[WriteEvent] 1,'Daily_Maint',@Zprava

   EXEC  .[dbo].[CustomProc] 'XX',NULL

-- Doplnění velikonoc:
   declare @Holiday as nvarchar(40) =.dbo.GiveParam('Holiday')
   EXEC .dbo.DoplnVelikonoce @DoplnVelikonoce,@Holiday
-- Údržba pracovní doby Chatů
IF @PracDobaChatu='true' AND EXISTS(SELECT * FROM $(ICC).dbo.ChatGateCondition WHERE Signal='Closed') AND OBJECT_ID(N'$(FS_Custom)..HolidayPlan', N'U') IS NOT NULL
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
              LEFT JOIN $(ICC).dbo.Holiday HO ON HP2.HolidayGroupName COLLATE DATABASE_DEFAULT  =HO.HolidayGroupName COLLATE DATABASE_DEFAULT  AND TimeMode='DayInYear' 
	             AND DATEPART(Month,@today)=DATEPART(Month,TimeFrom) AND DATEPART(Day,@today)=DATEPART(Day,TimeFrom)
				  WHERE HP.HolidayGroupName<>@Holiday AND HO.HolidayId IS NULL

    OPEN Hol_cursor 
	OPEN Hol_cursor2

  FETCH NEXT FROM Hol_cursor INTO @HolidayGroupName, @RelId   
  WHILE @@FETCH_STATUS = 0  
   BEGIN
    SET @CharDateFrom  = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeFrom FROM $(ICC).dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @CharDateTo = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeTo FROM $(ICC).dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	-- Zkontroluji, zda dnes není svátek:
	SELECT TOP 1 @ChatFrom=TimeFrom,@ChatTo=TimeTo FROM $(ICC).dbo.Holiday WHERE [HolidayGroupName]=@Holiday AND TimeMode='DayInYear' 
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
		UPDATE $(iCC).[dbo].ChatGateCondition
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
    SET @CharDateFrom  = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeFrom FROM $(ICC).dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @CharDateTo   = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeTo FROM $(ICC).dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @PerformChange  = 0
	-- v Holiday najdu pracovní dobu dnešního dne
		SELECT @ChatFrom=TimeFrom,@ChatTo=TimeTo FROM $(ICC).dbo.Holiday WHERE [HolidayGroupName]=@HolidayGroupName AND @today>=CONVERT(Date,TimeFrom) AND @today<=CONVERT(Date,TimeTo)
		IF @ChatFrom IS NOT NULL
		  BEGIN	   
		   -- Teď musím do @Start a @End dosadit datumy z ChatGateCondition
		   SET @ChatFrom = CONVERT(DateTime,@CharDateFrom+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatFrom,126),12,8))
		   SET @ChatTo   = CONVERT(DateTime,@CharDateTo+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatTo,126),12,8))
			UPDATE $(iCC).[dbo].ChatGateCondition
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
	  DECLARE @from3 AS datetime=DATEADD(DAY,-7,GETutcDATE())
	    -- Nastavím importy jako neaktivní
		UPDATE $(iCC).[dbo].[OutboundListImport]
		  SET  Active=0 
		WHERE Deleted=0
		AND Active=1
		AND TimeUTC<@from1
		AND $(FS_Custom).dbo.[isOutboundImpComplete](OutboundListImportId)=1
	    -- Zruším  neaktivní importy
		UPDATE  $(iCC).[dbo].[OutboundListImport]
			SET Deleted=1
		   WHERE Deleted=0
			AND Active=0
			AND TimeUTC<@from2
            AND $(FS_Custom).dbo.[isOutboundImpComplete](OutboundListImportId)=1
       ---------------------------------- Smazání starých Change Requestů:
	   DELETE FROM $(iCC).dbo.[ChangeRequest]
       WHERE Done=1 AND ChangeRequestTimeUtc < @From1
	   delete from iCC.dbo.ChangeRequest 
	   where Command not in ('BulkMessageImport','CampaignImport','OutboundListImport','OutboundListExport','DataQueryExport',
	     'ExportEventsAsCsv') and ChangeRequestTimeUtc < @from3 and Done = 1


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
 SELECT /*TOP 10*/ PilotTime,IC.InboundCallId  FROM $(ICC).dbo.InboundCall IC WITH (NOLOCK)
   LEFT JOIN $(ICC).dbo.callevent ce WITH (NOLOCK) ON IC.InboundCallId=CE.InboundCallId AND CE.referencedata = 'NopOK' and CE.ResultData = 'MIMOPRAC'
   --LEFT JOIN $(ICC).dbo.callevent ce2 WITH (NOLOCK) ON IC.InboundCallId=CE2.InboundCallId AND CE2.referencedata = 'NopOK' and CE2.ResultData = 'WHITELIST'
   WHERE PilotTime>@from AND dbo.IsWorkTime4(PilotTime,'PracDoba')=0.
   AND CE.InboundCallId IS NULL --AND CE2.InboundCallId IS NULL
   OPEN my_cursor 

  FETCH NEXT FROM My_cursor INTO @PilotTime, @InboundcallId    
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @InboundcallId  IS NOT NULL
		BEGIN
		  -- Zapiš do $(ICC).dbo.callevent chybějící záznam
          INSERT INTO $(ICC).[dbo].[CallEvent]
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

	   SET @Zprava = 'End of procedure'
       EXEC  .[dbo].[WriteEvent] 1,'Daily_Maint',@Zprava

END
GO

IF object_id('ParujHovor') IS NOT NULL
 DROP  Procedure  [dbo].[ParujHovor]
GO
---------------------------------------------
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 29.06.2018
-- Description:	Spárování hovoru s nahrávkou podle času
-- =============================================


CREATE PROCEDURE [dbo].[ParujHovor]
	@CallId as UniqueIdentifier,
	@Direction as VARCHAR(1)
AS

BEGIN
    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)

  DECLARE @CallerNumber AS nvarchar(32)=IIF(@Direction='O',
  (SELECT TOP 1 CallerNumber FROM  $(ICC).[dbo].[OutboundCall] WITH(NOLOCK) WHERE OutboundCallId=@CallId),
  (SELECT TOP 1 CallerNumber FROM  $(ICC).[dbo].[InboundCall] WITH(NOLOCK) WHERE InboundCallId=@CallId))
  DECLARE @TimeUtc AS DateTime=IIF(@Direction='O',
  (SELECT TOP 1 TimeUtc FROM  $(ICC).[dbo].[OutboundCall] WITH(NOLOCK) WHERE OutboundCallId=@CallId),
  (SELECT TOP 1 TimeUtc FROM  $(ICC).[dbo].[InboundCall] WITH(NOLOCK) WHERE InboundCallId=@CallId))
  DECLARE @CallResult AS nvarchar(32)=IIF(@Direction='O',
  (SELECT TOP 1 CallResult FROM  $(ICC).[dbo].[OutboundCall] WITH(NOLOCK) WHERE OutboundCallId=@CallId),
  (SELECT TOP 1 CallResult FROM  $(ICC).[dbo].[InboundCall] WITH(NOLOCK) WHERE InboundCallId=@CallId))

 DECLARE @CallDuration AS Integer=ISNULL(IIF(@Direction='O',
  (SELECT TOP 1 CallDuration FROM  $(ICC).[dbo].[OutboundCall] WITH(NOLOCK) WHERE OutboundCallId=@CallId),
  (SELECT TOP 1 CallDuration FROM  $(ICC).[dbo].[InboundCall] WITH(NOLOCK) WHERE InboundCallId=@CallId))
  ,0)

-- Zkusím najít tu nahrávku
 DECLARE @VoiceRecordID AS UniqueIdentifier=(SELECT TOP 1 VoiceRecordID FROM  [SREC].[dbo].[VoiceRecord] WITH(NOLOCK)
  WHERE StartTimeUtc>DATEADD(ss,-300,@TimeUtc) AND StartTimeUtc<DATEADD(ss,180,@TimeUtc)
  AND RIGHT(RemoteNumber,9)=RIGHT(@CallerNumber,9) --AND AgentName IS NULL --V jedné nahrávce může být více přepojených hovorů
  AND DATEDIFF(ss,StartTimeUtc,EndTimeUtc)>=@CallDuration -- Nahrávka by neměla být kratší než hovor v In/OutboundCall
  )
 IF @VoiceRecordID IS NOT NULL
    BEGIN
	  SET @CallDuration=(SELECT TOP 1 DATEDIFF(ss,StartTimeUtc,EndTimeUtc) AS Duration FROM [SRec].[dbo].[VoiceRecord] WHERE VoiceRecordId=@VoiceRecordId)
	  IF @CallDuration>10 -- Hovory kratší než 10 sekund nebudu párovat
	   BEGIN
		   DECLARE @OutboundCallId AS UniqueIdentifier
		   DECLARE @InboundCallId AS UniqueIdentifier
		   DECLARE @AgentName AS nvarchar(120)=IIF(@Direction='O',
	  (SELECT TOP 1 AG.DisplayName FROM  $(ICC).[dbo].[OutboundCall] OC WITH(NOLOCK) INNER JOIN $(ICC).[dbo].[AGENT] AG  WITH(NOLOCK) ON OC.AgentId=AG.AgentId WHERE OutboundCallId=@CallId),
	  (SELECT TOP 1 AG.DisplayName FROM  $(ICC).[dbo].[InboundCall] IC WITH(NOLOCK) INNER JOIN $(ICC).[dbo].[AGENT] AG  WITH(NOLOCK) ON IC.AgentId=AG.AgentId WHERE InboundCallId=@CallId))

	   IF @Direction='O'
		 SET @OutboundCallId=@CallId
	   ELSE
		 SET @InboundCallId=@CallId
	   INSERT INTO $(ICC).[dbo].[CallRecord] (RecordFileId,InboundCallId,OutboundCallId)
		  VALUES (@VoiceRecordID,@InboundCallId,@OutboundCallId)
	   update [SREC].[dbo].[VoiceRecord] set AgentName=@AgentName WHERE VoiceRecordId=@VoiceRecordId AND ISNULL(AgentName,'')=''
		IF @Direction='O'
         BEGIN
		     SET @OutboundCallId=@CallId -- Vycpávka kvůli syntaxi
	        -- IF @CallResult<>'Served'
		    --update $(ICC).[dbo].[OutboundCall] set CallResult='Served' WHERE OutboundCallId=@CallId
         END
	   ELSE
	     BEGIN
		   IF @CallResult<>'Served'
		   	 update $(ICC).[dbo].[InboundCall] set CallResult='Served', CallPhase='HangupCaller',CallDuration=@CallDuration WHERE InboundCallId=@CallId
		   --update $(ICC).[dbo].[InboundCall] set CallDuration=@CallDuration WHERE InboundCallId=@CallId
		 END
	   SET @Popis = 'I paired the call '+@Direction+' CallId='+convert(nvarchar(MAX), @CallId)+' with recording VoiceRecordId='+convert(nvarchar(MAX), @VoiceRecordId)
	   EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
      END
  END 
 END 

GO

IF object_id('DoplnVelikonoce') IS NOT NULL
 DROP  Procedure  [dbo].[DoplnVelikonoce]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <28.04.2021>
-- Description:	<Doplnění velikonočních svátků>
-- =============================================
CREATE PROCEDURE [dbo].[DoplnVelikonoce]
@DoplnVelikonoce NVARCHAR(6)
,@Holiday NVARCHAR(30)
AS
BEGIN
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
		  IF NOT EXISTS(SELECT * FROM $(ICC).dbo.Holiday WHERE TimeFrom=@Datum AND HolidayGroupName=@Holiday)
		   INSERT INTO $(ICC).[dbo].[Holiday]
				   ([DisplayName]
				   ,[HolidayGroupName]
				   ,[TimeMode]
				   ,[TimeFrom]
				   ,[TimeTo]
					)
			 VALUES
				   (
				   'Eastern'
				   ,@Holiday
				   ,'SingleDay'
				   , @Datum 
				   , CONVERT(DateTime,SUBSTRING(CONVERT(NVARCHAR(24),@Datum,126),1,10)+' 23:59')
				   )
			  SET @Datum=DATEADD(Day,-3,@Datum)
			  SET @i=@i+1
		   END
     END
 END
 GO

 IF object_id('HledNesparOut') IS NOT NULL
 DROP  Procedure  [dbo].[HledNesparOut]
GO
 -- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 25.01.2021
-- Description:	Vyhledání nespárovaných odchozích hovorů a pokus o dopárování
-- =============================================

CREATE PROCEDURE [dbo].[HledNesparOut]
AS
BEGIN
    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)
	DECLARE @PairingTime AS Integer=.dbo.GiveParam('PairingTime')

   DECLARE @OutboundcallId AS UniqueIdentifier
   DECLARE @TimeUTCMin AS DateTime=DATEADD(Hour,-10,GETUTCDATE())
   DECLARE @TimeUTCMax AS DateTime=DATEADD(Minute,-@PairingTime,GETUTCDATE()) -- Nechci Jardovi zasahovat do párování
 
     EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, 'Start'


DECLARE My_cursor CURSOR FOR   
 SELECT TOP 100
      OC.[OutboundCallId] 
  FROM ICC.[dbo].[OutboundCall] OC
    LEFT JOIN $(ICC).[dbo].[CallRecord] CR ON CR.OutboundCallId=OC.OutboundCallId
  --  LEFT JOIN [SRec].[dbo].[Directory] DI ON RIGHT(DI.Number,3) COLLATE Czech_CI_AS =C.Redirector COLLATE Czech_CI_AS
    LEFT JOIN $(ICC).[dbo].[Workplace] WP ON WP.WorkplaceId=OC.WorkplaceId
  WHERE TimeUTC>@TimeUTCMin AND TimeUTC<@TimeUTCMax
  AND CallDuration>1
  AND CR.OUtboundCallId IS NULL   
  AND CallResult ='served'
  AND LEN(RTRIM(CallerNumber))>6
  --AND isnull(DI.Record,1) <>0
    AND (.dbo.CustomCheck2('IC',WP.DisplayName)=1 )

   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @OutboundCallId   
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @OutboundCallId IS NOT NULL 
		BEGIN
		  EXEC .dbo.ParujHovor @OutboundcallId,'O'
		END
		FETCH NEXT FROM My_cursor INTO @OutboundCallId  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;
  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, 'Finish'
END
GO

IF object_id('HledNesparIn') IS NOT NULL
 DROP  Procedure  [dbo].[HledNesparIn]
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 25.01.2021
-- Description:	Vyhledání nespárovaných příchozích hovorů a pokus o dopárování
-- =============================================

CREATE PROCEDURE [dbo].[HledNesparIn]
AS
BEGIN
    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)
	DECLARE @PairingTime AS Integer=.dbo.GiveParam('PairingTime')

   DECLARE @InboundcallId AS UniqueIdentifier
   DECLARE @TimeUTCMin AS DateTime=DATEADD(Hour,-10,GETUTCDATE())
   DECLARE @TimeUTCMax AS DateTime=DATEADD(Minute,-@PairingTime,GETUTCDATE()) -- Nechci Jardovi zasahovat do párování
 
     EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, 'Start'


DECLARE My_cursor CURSOR FOR   
 SELECT TOP 100
      IC.[InboundCallId] 
  FROM $(ICC).[dbo].[InboundCall] IC
    LEFT JOIN $(ICC).[dbo].[CallRecord] CR ON CR.InboundCallId=IC.InboundCallId
    LEFT JOIN [SRec].[dbo].[Directory] DI ON RIGHT(DI.Number,3) COLLATE Czech_CI_AS =IC.Redirector COLLATE Czech_CI_AS
    LEFT JOIN $(ICC).[dbo].[Workplace] WP ON WP.WorkplaceId=IC.WorkplaceId
  WHERE TimeUTC>@TimeUTCMin AND TimeUTC<@TimeUTCMax
  AND CallDuration>1
  AND CR.INboundCallId IS NULL   
  AND CallResult ='served'
  AND LEN(RTRIM(CallerNumber))>6
  AND isnull(DI.Record,1) <>0
    AND (.dbo.CustomCheck2('IC',WP.DisplayName)=1 OR .dbo.CustomCheck2('ID',IC.Redirector)=1 OR $(FS_CUSTOM).dbo.CustomCheck2('IP',LEFT(IC.PilotId,20))=1)

   OPEN my_cursor 
  FETCH NEXT FROM My_cursor INTO @INboundCallId   
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @INboundCallId IS NOT NULL 
		BEGIN
		  EXEC .dbo.ParujHovor @INboundcallId,'I'
		END
		FETCH NEXT FROM My_cursor INTO @INboundCallId  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;
  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, 'Finish'
END

GO

IF object_id('Rename_Agent') IS NOT NULL
 DROP  Procedure  [dbo].[Rename_Agent]
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 20.07.2022
-- Description:	Agent rename - female maried
-- =============================================

CREATE PROCEDURE [dbo].[Rename_Agent]
@SystemNameOld AS NVARCHAR(100), --= 'martina.janockova'
@SystemNameNew AS NVARCHAR(100), --= 'martina.simeckova'
@DisplayNameNew AS NVARCHAR(100) --= 'Martina Šimečková'

AS
BEGIN

    UPDATE iCC.dbo.Agent
SET  DisplayName=@DisplayNameNew,SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'

   UPDATE SREC.dbo.Account
SET  DisplayName=@DisplayNameNew,SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'


   UPDATE ProServer.dbo.Agent
SET  DisplayName=@DisplayNameNew,SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'
 
   UPDATE ProServer.dbo.Credentials
SET   SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'

   UPDATE ProServer.dbo.DataItem
SET   DataValue=REPLACE(DataValue,@SystemNameOld,@SystemNameNew)
where DataValue like '%'+@SystemNameOld+'%'

END

GO



IF object_id('RecordingLessCalls') IS NOT NULL
 DROP  Function  [dbo].[RecordingLessCalls]
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	RecordinLess Calls
-- =============================================
CREATE FUNCTION [dbo].[RecordingLessCalls] (@Today datetime, @Now datetime)
RETURNS TABLE
AS
RETURN
(
SELECT IIF(VCR.VoiceRecordId IS NULL,'NO','YES') ExRecord
,Phase2.Direction 
,Redirector
,CallerNumber
,Number
,WorkPlaceName
,CallTime
,CallId
,StartTimeUTC
,CallDuration	  
FROM (
SELECT * FROM (
SELECT 
      'O' AS Direction
	  , NULL AS Redirector
	  , CallerNumber
	  , WP.Number
	  , WP.DisplayName AS WorkPlaceName
      , OC.[OutboundCallId] AS CallId
      ,DistributionTime AS CallTime
	  ,TimeUTC
	  ,CallDuration
  FROM $(ICC).[dbo].[OutboundCall] OC WITH (NOLOCK)
    LEFT JOIN $(ICC).[dbo].[CallRecord] CR WITH (NOLOCK) ON CR.OutboundCallId=OC.OutboundCallId
    LEFT JOIN $(ICC).[dbo].[Workplace] WP ON WP.WorkplaceId=OC.WorkplaceId
  WHERE DistributionTime>@Today  AND DistributionTime<DATEADD(Hour,-1,@Now)  AND CallDuration>1
  AND CR.OutboundCallId IS NULL 
    AND LEN(RTRIM(CallerNumber))>6
   AND CallResult<>'Canceled'
  AND  WP.Number IS NOT NULL -- Hodnocení hovorů nemá nahrávku ani pracoviště
  UNION
  SELECT 
      'I' AS Direction
	  , Redirector
	  , CallerNumber
	  , WP.Number
      , WP.DisplayName AS WorkPlaceName
      , IC.[InboundCallId] AS CallId
      ,[PilotTime]  AS CallTime
	  ,TimeUTC
	  ,CallDuration	  
  FROM $(ICC).[dbo].[InboundCall] IC
    LEFT JOIN $(ICC).[dbo].[CallRecord] CR ON CR.InboundCallId=IC.InboundCallId
    LEFT JOIN [SRec].[dbo].[Directory] DI ON RIGHT(DI.Number,3) COLLATE Czech_CI_AS =IC.Redirector COLLATE Czech_CI_AS
    LEFT JOIN $(ICC).[dbo].[Workplace] WP ON WP.WorkplaceId=IC.WorkplaceId
  WHERE TimeUTC>@Today AND TimeUTC<DATEADD(Hour,-3,@Now) AND CallDuration>1
  AND CR.INboundCallId IS NULL   
  AND CallResult ='served'
  AND LEN(RTRIM(CallerNumber))>6
  --AND Redirector NOT LIKE '7%'
  AND isnull(DI.Record,1) <>0
    AND (.dbo.CustomCheck2('IC',WP.DisplayName)=1 OR .dbo.CustomCheck2('ID',IC.Redirector)=1)
  ) AS Phase1 ) AS Phase2
  LEFT JOIN  [SREC].[dbo].[VoiceRecord] VCR WITH(NOLOCK) ON StartTimeUtc>DATEADD(ss,-300,Phase2.TimeUtc) AND StartTimeUtc<DATEADD(ss,90,Phase2.TimeUtc)
   AND RIGHT(RemoteNumber,9) COLLATE Czech_CI_AS =RIGHT(Phase2.CallerNumber,9) COLLATE Czech_CI_AS --AND AgentName IS NULL --V jedné nahrávce může být více přepojených hovorů
   AND DATEDIFF(ss,StartTimeUtc,EndTimeUtc)>=Phase2.CallDuration

)
GO

IF object_id('ReplaceSmiles') IS NOT NULL
 DROP  Procedure  [dbo].[ReplaceSmiles]
GO

CREATE PROCEDURE [dbo].[ReplaceSmiles]
@Messageid AS Uniqueidentifier
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.12.2018>
-- Description:	<Odstraňuje smajlíky z těla a předmětu zprávy
-- =============================================

BEGIN
  DECLARE @Loguj AS Bit=1
  DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
  DECLARE @Popis AS nvarchar(MAX)
  UPDATE $(ICC).dbo.Message
  SET  BodyText =  .dbo.ReplaceSmilyes(BodyText),SubjectField = .dbo.ReplaceSmilyes(SubjectField)
  WHERE  (MessageId = @MessageId)
  SET @Popis = 'Transcription of smileys on the message MessageId='+CONVERT(NVARCHAR(50),@MessageId)
  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
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

IF object_id('CustomCheck2') IS NULL
 BEGIN
  DECLARE @CreateCustom AS NVARCHAR(500)=
 ' 
 CREATE FUNCTION [dbo].[CustomCheck2](@TestVer AS NVARCHAR(2), @String as NVARCHAR(20))
   RETURNS int
	 AS
	  BEGIN
	    IF  @TestVer = ''IC''
		  RETURN 1
		RETURN 0
	  END'
    EXEC (@CreateCustom)
  END
GO

IF object_id('CustomProc') IS NULL
 BEGIN
  DECLARE @CreateCustom AS NVARCHAR(500)=
 ' 
 CREATE PROCEDURE [dbo].[CustomProc](@TestVer AS NVARCHAR(2), @Last as DateTime)
	 AS
	  BEGIN
	    DECLARE @Notning AS Integer=0
	  END'
    EXEC (@CreateCustom)
  END
GO

IF object_id('$(ICC).dbo.Commands') IS NOT NULL
  BEGIN
   PRINT 'V iCC existuje tabulka Commands'
   IF (SELECT COUNT(1) FROM $(ICC).dbo.Commands)=0
     BEGIN
	   DROP TABLE $(ICC).dbo.Commands
	   PRINT 'Delete table Commands was performed'
	 END
 END

IF object_id('$(ICC).dbo.Errorlog') IS NOT NULL
  BEGIN
   PRINT 'V iCC existuje tabulka Errorlog'
   IF (SELECT COUNT(1) FROM $(ICC).dbo.Errorlog)=0
     BEGIN
	   DROP TABLE $(ICC).dbo.Errorlog
	   PRINT 'Delete table Errorlog was performed'
	 END
 END
IF object_id('$(ICC).dbo.Eventlog') IS NOT NULL
  BEGIN
   PRINT 'V iCC existuje tabulka Eventlog'
   IF (SELECT COUNT(1) FROM $(ICC).dbo.Eventlog)=0
     BEGIN
	   DROP TABLE $(ICC).dbo.Eventlog
	   PRINT 'Delete table Eventlog was performed'
	 END
 END
IF object_id('$(ICC).dbo.Results') IS NOT NULL
  BEGIN
   PRINT 'V iCC existuje tabulka Results'
   IF (SELECT COUNT(1) FROM $(ICC).dbo.Results)=0
     BEGIN
	   DROP TABLE $(ICC).dbo.Results
	   PRINT 'Delete table Results was performed'
	 END
 END

 EXEC .dbo.TranslateDQ 'Všechny příchozí hovory','Inbound Calls','Admin'
 EXEC .dbo.TranslateDQ 'Události příchozího hovoru','Inbound Call Events','Admin'
 EXEC .dbo.TranslateDQ 'Nahrávky','Recordings','Admin'
 EXEC .dbo.TranslateDQ 'Všechny odchozí hovory','Outbound Calls','Admin'
 EXEC .dbo.TranslateDQ 'Události odchozího hovoru','Outbound Call Events','Admin'
 EXEC .dbo.TranslateDQ 'Přehled agentů Admin','List of Agents','Admin'
 EXEC .dbo.TranslateDQ 'Výsledky akcí','Results of Actions','Admin'
 EXEC .dbo.TranslateDQ 'Datové dotazy','Data Queries','Admin'
 EXEC .dbo.TranslateDQ 'Sloupce dotazů','Data Queries Columns','Admin'
 EXEC .dbo.TranslateDQ 'Všechny zprávy','Messages','Admin'
 EXEC .dbo.TranslateDQ 'MessageEvent','Message Events','Admin'
 EXEC .dbo.TranslateDQ 'Všechny případy','Issues','Admin'
 EXEC .dbo.TranslateDQ 'IVR Skripty','IVR Scripts','Admin'
 EXEC .dbo.TranslateDQ 'IVR Step','IVR Steps','Admin'
 EXEC .dbo.TranslateDQ 'Telefonní seznamy','PhoneBooks','Kontakty'
 EXEC .dbo.TranslateDQ 'Seznam telefonních čísel pro export','List of telephone numbers for export','Kontakty'
 EXEC .dbo.TranslateDQ 'Seznam telefonních čísel','List of telephone numbers','Kontakty'
 EXEC .dbo.TranslateDQ 'Admin příkazy','Admin Commands','Admin'
 EXEC .dbo.TranslateDQ 'Wallboard časy','Wallboard Times','Admin'
 EXEC .dbo.TranslateDQ 'Vyšetřování fronty','Queue investigation','Supervizor'
 EXEC .dbo.TranslateDQ 'Volní agenti seznam','Free agents list','Supervizor'
 EXEC .dbo.TranslateDQ 'Free agents seznam','Free agents list','Supervizor'
 EXEC .dbo.TranslateDQ 'Volní agenti','Free agents','Supervizor'   
 EXEC .dbo.TranslateDQ 'Všechny zprávy e-mailové fronty','E-mails Queue','Admin'
 EXEC .dbo.TranslateDQ 'VolniAgentiProMail','Free agents for mail','Admin' 
 EXEC .dbo.TranslateDQ 'Přiřazené zprávy agentům','Assigned messages to agents','Admin'  
 EXEC .dbo.TranslateDQ 'Distribuce odchozích hovorů','Outgoing call distribution','Admin' 
  
 EXEC .dbo.ChangeDQ 'Zombie hovory','Zombie Calls','Admin'  
 EXEC .dbo.ChangeDQ 'Počet naplánovaných odchozích mailů v posledních 5ti dnech a ještě nenastal čas odchodu',
 'The number of scheduled outgoing messages in the last 5 days and the time of departure has not yet come','Admin'  
 EXEC .dbo.ChangeDQ 'Počet naplánovaných odchozích mailů v posledních 5ti dnech a měly odejít',
 'The number of scheduled outgoing messages in the last 5 days and should have left','Admin'  
 EXEC .dbo.ChangeDQ 'Počet odchozích mailů v posledních 5ti dnech a selhaly',
 'The number of outgoing messages in the last 5 days that failed','Admin'  

 EXEC .dbo.ChangeDQ 'Počet naplánovaných odchozích zpráv v posledních 5ti dnech a ještě nenastal čas odchodu',
 'The number of scheduled outgoing messages in the last 5 days and the time of departure has not yet come','Admin'  
 EXEC .dbo.ChangeDQ 'Počet naplánovaných odchozích zpráv v posledních 5ti dnech a měly odejít',
 'The number of scheduled outgoing messages in the last 5 days and should have left','Admin'  
 EXEC .dbo.ChangeDQ 'Počet odchozích zpráv v posledních 5ti dnech a selhaly',
 'The number of outgoing messages in the last 5 days that failed','Admin'  

 EXEC .dbo.ChangeDQ 'Změna agenta při distribuci příchozího hovoru za poslední 2 hodiny',
 'Agent change when distributing an incoming call in the last 2 hours','Admin'  
 EXEC .dbo.ChangeDQ 'Maximální doba odeslání mailů za posledních 30 minut',
 'Maximum time to send emails in the last 30 minutes','Admin'  
 EXEC .dbo.ChangeDQ 'Průměrná doba odeslání mailů za posledních 30 minut',
 'Average time to send emails in the last 30 minutes','Admin'  

 EXEC .dbo.ChangeDQ 'Poeet naplánovaných odchozích zpráv v posledních 5ti dnech a ješti nenastal eas odchodu',
 'The number of scheduled outgoing messages in the last 5 days and the time of departure has not yet come','Admin'  
 EXEC .dbo.ChangeDQ 'Počet naplánovaných odchozích zpráv v posledních 5ti dnech a měly odejít',
 'The number of scheduled outgoing messages in the last 5 days and should have left','Admin'  
 EXEC .dbo.ChangeDQ 'Počet odchozích zpráv v posledních 5ti dnech a selhaly',
 'The number of outgoing messages in the last 5 days that failed','Admin'  
 EXEC .dbo.ChangeDQ 'Maximální doba odeslání mailů za posledních 30 minut',
 'Maximum time to send emails in the last 30 minutes','Admin'  
 EXEC .dbo.ChangeDQ 'Prùmìrná doba odeslání mailù za posledních 30 minut',
 'Average time to send emails in the last 30 minutes','Admin'  


 PRINT 'Translate to english:'
 UPDATE TOP (500) DQC
SET  DisplayName=TargetColumn
FROM $(iCC).dbo.DataQueryColumn DQC
  inner join $(iCC).dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
  LEFT JOIN $(iCC).[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
WHERE DQ.Deleted=0 AND PRT.NAVGroup='AdminPageNav'
	AND DQ.QueryGroup IN ('Admin','Kontakty','Supervizor') AND TargetColumn<>DQC.DisplayName AND DQC.DisplayName NOT LIKE '$%'

 EXEC .dbo.TranslateCol 'V_Praci','Logon'  
 EXEC .dbo.TranslateCol 'V Práci','Logon' 
 EXEC .dbo.TranslateCol 'Navesti','Rank'  
 EXEC .dbo.TranslateCol 'Akce','Action'  
 EXEC .dbo.TranslateCol 'IvrSkript','IvrScript'  
 EXEC .dbo.TranslateCol 'Ivrkrok','IvrStep'  
 EXEC .dbo.TranslateCol 'Hlaska','FileName' 
 EXEC .dbo.TranslateCol 'Sparovano','Paired' 
 EXEC .dbo.TranslateCol 'BylHovor','WasCall' 
 EXEC .dbo.TranslateCol 'Pokus','Attempt' 
 EXEC .dbo.TranslateCol 'Zahranicni','Foreign' 
 EXEC .dbo.TranslateCol 'CasUskutecneni','AnswerTime' 
 EXEC .dbo.TranslateCol 'Téma','Topic' 
 EXEC .dbo.TranslateCol 'PodTéma','SubTopic' 
 EXEC .dbo.TranslateCol 'ProvedAkci','Perform' 
 EXEC .dbo.TranslateCol 'DatumCas','DateTime' 
 EXEC .dbo.TranslateCol 'Popis','Description' 
 EXEC .dbo.TranslateCol 'Procedura','Procedure' 
 EXEC .dbo.TranslateCol 'Pocet','Count' 
 EXEC .dbo.TranslateCol 'ExNahravka','ExRecording' 
 EXEC .dbo.TranslateCol 'DQid','Select' 
 EXEC .dbo.TranslateCol 'Čas UTC','UTC Time' 
 EXEC .dbo.TranslateCol 'ExKom','Ex Comm' 
 EXEC .dbo.TranslateCol 'VolanySkript','Called Script' 
 EXEC .dbo.TranslateCol 'VolnyAgent','Free Agent' 
 EXEC .dbo.TranslateCol 'VolnyAgent','Free Agent' 
 EXEC .dbo.TranslateCol 'StatusAgenta','Agent Status' 
 EXEC .dbo.TranslateCol 'EmailPovolenstav','Status with email' 
 EXEC .dbo.TranslateCol 'EmailPovolenPracov','WP with email' 
 EXEC .dbo.TranslateCol 'ZnalostJazyka','Lang knowledge' 

USE $(ICC)

IF object_id('SpaceUsed') IS NOT NULL
 DROP  Function  [dbo].SpaceUsed
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <07-06-2022>
-- Description:	Vrací velikost použitého prostoru v MB v aktuální DB
-- ======================================================

CREATE function [dbo].[SpaceUsed] ()
returns Integer
as begin
 
return (SELECT CAST(FILEPROPERTY('$(ICC)', 'SpaceUsed') AS INT)/128)
END
GO
-- Vymazání chybně umístěných procedur:
IF object_id('.dbo.CustomProc') IS NOT NULL
 DROP  Procedure  .dbo.CustomProc
GO
IF object_id('.dbo.Backup_Table2') IS NOT NULL
 DROP  Procedure  .dbo.Backup_Table2
GO
 IF NOT eXISTS(SELECT *  FROM sys.indexes  WHERE object_id = OBJECT_ID('.DBO.ChangeRequest') AND name='CXF_Done_InProgress')
  BEGIN
	CREATE NONCLUSTERED INDEX [CXF_Done_InProgress] ON $(Icc).[dbo].[ChangeRequest]
	(
		   [ChangeRequestTimeUtc] ASC,
		   [Command] ASC,
		   [TimeUtc] ASC
	)
	INCLUDE (     [ChangeRequestId],
		   [Number],
		   [ReferenceId],
		   [SubjectId],
		   [DataId],
		   [ActorId],
		   [Result],
		   [Done],
		   [InProgress]) 
	WHERE ([Done]<>(1))
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
   END
   GO
-- Přejmenování od Toma Vicherka:
UPDATE DataQuery SET QueryGroup='VisualEditors' WHERE QueryGroup='Admin' AND DataQueryId IN ('5cff6ed2-fed3-4aad-bf61-ae8b2dca4521', 'a842f540-f793-4879-8b26-8341cf289894', 
 '1a52af73-5047-4e99-836a-5293257eef98', '00f27861-9385-4c03-bda8-0872ac399731', 'b39ec077-f0c8-4d90-b0b0-425e7855b8c9', '19e68c92-afc7-4782-bb7a-626722b6bd4b', 
 'a17714bb-6ef5-4d86-8285-f1cd0e2b2a29', '72babf46-63c1-46a8-a64e-7e6d20c51c22', 'c9f79d41-338c-4966-a1d1-dd898253621a', 'cbab012f-7371-443b-9920-7cafaa36f67d')


---- Doplnění Rep_Date
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

-- Doplnění nabídky projektů pro přepojení hovoru
UPDATE .[dbo].[Configuration] 
 SET ConfigurationValue=(SELECT ConfigurationValue FROM .[dbo].[Configuration] WHERE ConfigurationName='DropDownProjectsInCallDataQueryId')
WHERE ConfigurationName='DropDownProjectsInCallInfoDataQueryId' AND ConfigurationValue IS NULL  

----- Spoušť dohledového systému
IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Kontrola nahrávek ZbH')
INSERT [dbo].[ActionTrigger] ( [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted]) 
VALUES ( N'Kontrola nahrávek ZbH', NULL, N'Admin', N'EXEC [$(FS_custom)].dbo.CheckRecAndEmlActivity2', NULL, NULL, N'Interval', 30, N'DayInWeek', CAST(N'2017-01-02 07:45:00.000' AS DateTime), CAST(N'2017-01-06 20:10:59.900' AS DateTime), NULL, CAST(N'2018-07-09 10:50:27.247' AS DateTime), NULL, 0, 0)

------ Denní údržba
IF NOT EXISTS(SELECT * FROM [dbo].[ActionTrigger] WHERE DisplayName= 'Denní údržba' )
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
 VALUES (N'7a982dcb-e4c5-4a09-86db-52542909b406', N'Denní údržba', NULL, N'ADMIN', N'EXEC $(FS_custom).[dbo].[Daily_Maintenance]', NULL, NULL, N'PeriodDay', NULL, NULL, NULL, NULL, NULL, CAST(N'2019-12-14 03:00:00.000' AS DateTime), NULL, 0, 0)


IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Smazání starých událostí')
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
 VALUES (N'8a2405ca-b436-43e5-aa4d-fbd069afaf87', N'Smazání starých událostí', NULL, N'Admin', N'EXEC  [$(FS_custom)].[dbo].[DelEventlog]', NULL, NULL, N'PeriodMonth', NULL, NULL, NULL, NULL, NULL, CAST(N'2020-12-31T23:40:00.000' AS DateTime), NULL, 0, 0)

----- Spoušť importní funkce:
IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Selected modules import')
 INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
  VALUES (N'ac26be9c-a3cf-41e6-9472-2cd61177d150', N'Selected modules import', N'Slouží k instalaci komponent z katalogu', N'ADMIN', N'EXEC [$(FS_custom)].[dbo].[ImportModul] @RecordId,0', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)


 ----- Spoušť importní Test Gateway:
IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Gateway Test')
 INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
  VALUES (N'19e60d25-6014-48ca-95a9-0e0ffad9e6d4', N'Gateway Test', N'It is for GW testing', N'ADMIN', N'EXEC [$(FS_custom)].[dbo].[GatewayTest] @RecordId', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)

IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE ActionTriggerId='873404dd-0641-46b0-b8f4-3f6b33bf348c')
 INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted], [Offset], [LaunchTime])
 VALUES (N'873404dd-0641-46b0-b8f4-3f6b33bf348c', N'Copy selected steps into selected script', NULL, N'ADMIN', N'EXEC [FS_custom].[dbo].[IVRStepCopy] @RecordId', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL)
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
GO
----------------- Add Skill level into free agents list ----------------------
DECLARE @Id AS UNIQUEIDENTIFIER=(SELECT TOP 1 DataQueryId FROM $(iCC).dbo.DataQuery WHERE DisplayName='Free agents'
 AND QueryGroup='Supervizor' AND Deleted=0 AND QueryText NOT LIKE '%VolniAgentiCall%' )
IF @Id IS NOT NULL 
  BEGIN
   PRINT 'I improve free agents list'
     UPDATE DQ
     SET  QueryText = 'SELECT * FROM $(FS_Custom).[dbo].VolniAgentiCall()'
     FROM .dbo.DataQuery DQ
     WHERE DataQueryId=@Id
INSERT $(iCC).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'FreeAgent',N'Select',N'FreeAgent',NULL,NULL,NULL,NULL,NULL,N'FreeAgent',NULL,0,80,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT $(iCC).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'PbxInKnowledge',N'Text',N'PbxInKnowledge',NULL,NULL,NULL,NULL,NULL,N'PbxInKnowledge',NULL,0,70,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT $(iCC).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'AgentStatus',N'Text',N'AgentStatus',NULL,NULL,NULL,NULL,NULL,N'AgentStatus',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT $(iCC).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'PbxState',N'Integer',N'PbxState',NULL,NULL,NULL,NULL,NULL,N'PbxState',NULL,0,60,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT $(iCC).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'LangKnowledge',N'Text',N'LangKnowledge',NULL,NULL,NULL,NULL,NULL,N'LangKnowledge',NULL,0,80,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT $(iCC).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'WPState',N'Text',N'WPState',NULL,NULL,NULL,NULL,NULL,N'WPState',NULL,0,80,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  END

IF NOT EXISTS(SELECT * FROM [dbo].[ActionTrigger] WHERE DisplayName= 'Denní údržba' )
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], Deleted) VALUES (N'7a982dcb-e4c5-4a09-86db-52542909b406', N'Denní údržba', NULL, N'ADMIN', N'EXEC $(FS_CUSTOM).[dbo].[Daily_Maintenance]', NULL, NULL, N'PeriodDay', NULL, NULL, NULL, NULL, NULL, CAST(N'2019-12-14 03:00:00.000' AS DateTime), NULL, 0, 0)
GO

  /* Admin: IVR Skripty */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'b37e3ad0-c8e3-4083-a23a-0e18686076b6'
DECLARE @DisplayName AS VARCHAR(150) = 'IVR Skripty'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)

 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'DisplayName',N'SELECT DISTINCT IVR.[IvrScriptId] ,IVR.[IvrScriptId] AS RecordId
              , ''1'' AS ProvedAkci
              ,IVR.[DisplayName]
              ,[Description]
              ,[IvrMachine]
              ,[ScenarioId]
            ,CAST(IIF(IVR.IvrScriptId=CONVERT(UniqueIdentifier,FS_Custom.dbo.GiveParam(''SELECTED_IVR'')), 1,0) AS bit) AS IsSelected
  		  ,IIF(PC.IvrScriptAId IS NULL AND IVS.TargetId IS NULL,''NO'',''YES'') AS IsUsed
  
          FROM $(iCC).[dbo].[IvrScript] IVR
  			LEFT JOIN $(iCC).[dbo].[PreCondition] PC ON PC.IvrScriptAId=IVR.IvrScriptId 
  		    LEFT JOIN $(iCC).[dbo].[IVRStep] IVS ON IVS.TargetId=IVR.IvrScriptId 
  
  		WHERE IVR.Deleted=0',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IvrScriptId',N'Text',N'IvrScriptId',NULL,NULL,NULL,NULL,NULL,N'IvrScriptId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'DisplayName',N'HyperLink',N'DisplayName',NULL,N'IvrScriptId',N'http://Localhost/FSAdmin/Pages/IvrScripts/EditForm.aspx?Id={0}',NULL,NULL,N'DisplayName',NULL,0,160,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Description',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,80,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IvrMachine',N'Text',N'IvrMachine',NULL,NULL,NULL,NULL,NULL,N'IvrMachine',NULL,0,80,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Select IVR Script',N'ImageScript',N'ProvedAkci',N'~/CustomImages/{0}.png',N'RecordId',NULL,NULL,NULL,N'ProvedAkci',NULL,0,80,30,NULL,0,N'exec FS_CUSTOM.dbo.SelectIVRScript @Id',NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsSelected',N'Color',N'IsSelected',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,40,N'#E0FFFF',0,NULL,N'info',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsUsed',N'Select',N'IsUsed',NULL,NULL,NULL,NULL,NULL,N'IsUsed',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO
   /* Admin: IVR Step */
  DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'd45fde09-0bf3-4418-bf50-7f11f3e5c0e5'
  DECLARE @DisplayName AS VARCHAR(150) = 'IVR Step'
  DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
  --IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  --  SET @DataQueryId=NewId() -- Mus?m pozadat o nove iD
  --IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
   BEGIN
    INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
    VALUES(@DataQueryId,@DisplayName,N'IVR Step',@QueryGroup,N'ScriptName,Rank',N'SELECT
                  IVST.IVRScriptId,
                  IVST.IVRStepId,
                  IVSC.DisplayName AS ScriptName
                  ,IVST.DisplayName AS StepName
            	  ,Rank
                  ,Action
                  ,TimeOut
                  ,WaitTimeOut
                  ,FileName
                  ,MultiLanguage
                  ,Retries
                  ,ResultDigits
                  ,SkipDigits
                  ,ReplayDigits
                  ,Targets
                  ,TargetId
            	  ,(SELECT DisplayName FROM IvrScript WHERE IvrScriptId=TargetId) As VolanySkript
                  ,Numbers
                  ,TimeMode
                  ,TimeFrom
                  ,TimeTo
                  ,Culture
                  ,TargetOnTimeOut
                  ,TargetOnSuccess
                  ,TargetOnFailure
              FROM .dbo.IvrStep IVST WITH (NOLOCK)
              LEFT JOIN IvrScript IVSC WITH (NOLOCK) ON IVSC.IvrScriptId=IVST.IvrScriptId
            WHERE IVST.Deleted = 0 AND IVSC.Deleted = 0',0,NULL,NULL,NULL,0)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'V?b?r',N'Toggle',N'IVRStepId',NULL,NULL,N'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,30,1,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'IvrScriptId',N'Text',N'IvrScriptId',NULL,NULL,NULL,NULL,NULL,N'IvrScriptId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'ScriptName',N'Select',N'ScriptName',NULL,NULL,NULL,NULL,NULL,N'ScriptName',NULL,0,120,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'StepName',N'HyperLink',N'StepName',NULL,N'IVRStepId',N'http://localhost/fsadmin/Pages/IvrSteps/EditForm.aspx?Id={0}',NULL,NULL,N'StepName',NULL,0,200,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'Rank',N'Integer',N'Rank',NULL,NULL,NULL,NULL,NULL,N'Rank',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'Action',N'Select',N'Action',NULL,NULL,NULL,NULL,NULL,N'Action',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'TimeOut',N'Integer',N'TimeOut',NULL,NULL,NULL,NULL,NULL,N'TimeOut',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'WaitTimeOut',N'Integer',N'WaitTimeOut',NULL,NULL,NULL,NULL,NULL,N'WaitTimeOut',NULL,0,60,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'FileName',N'Text',N'FileName',NULL,NULL,NULL,NULL,NULL,N'FileName',NULL,0,140,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'MultiLanguage',N'Color',N'MultiLanguage',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'Retries',N'Integer',N'Retries',NULL,NULL,NULL,NULL,NULL,N'Retries',NULL,0,60,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'ResultDigits',N'Text',N'ResultDigits',NULL,NULL,NULL,NULL,NULL,N'ResultDigits',NULL,0,80,100,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'SkipDigits',N'Text',N'SkipDigits',NULL,NULL,NULL,NULL,NULL,N'SkipDigits',NULL,0,80,110,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'ReplayDigits',N'Text',N'ReplayDigits',NULL,NULL,NULL,NULL,NULL,N'ReplayDigits',NULL,0,80,120,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'Targets',N'Text',N'Targets',NULL,NULL,NULL,NULL,NULL,N'Targets',NULL,0,140,130,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'Targetid',N'Text',N'Targetid',NULL,NULL,NULL,NULL,NULL,N'Targetid',NULL,0,230,135,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'Volan? Skript',N'Text',N'VolanySkript',NULL,NULL,NULL,NULL,NULL,N'VolanySkript',NULL,0,160,137,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'Numbers',N'Text',N'Numbers',NULL,NULL,NULL,NULL,NULL,N'Numbers',NULL,0,80,140,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'TimeMode',N'Select',N'TimeMode',NULL,NULL,NULL,NULL,NULL,N'TimeMode',NULL,0,80,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'TimeFrom',N'DateTimeFromTo',N'TimeFrom',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeFrom',NULL,0,100,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'TimeTo',N'DateTimeFromTo',N'TimeTo',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeTo',NULL,0,100,170,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'Culture',N'Text',N'Culture',NULL,NULL,NULL,NULL,NULL,N'Culture',NULL,0,80,180,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'TargetOnTimeOut',N'Integer',N'TargetOnTimeOut',NULL,NULL,NULL,NULL,NULL,N'TargetOnTimeOut',NULL,0,60,190,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'TargetOnSuccess',N'Integer',N'TargetOnSuccess',NULL,NULL,NULL,NULL,NULL,N'TargetOnSuccess',NULL,0,60,200,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
      VALUES (@DataQueryId,N'TargetOnFailure',N'Integer',N'TargetOnFailure',NULL,NULL,NULL,NULL,NULL,N'TargetOnFailure',NULL,0,60,210,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
    
   END
  GO

    /* Kontakty: TelefonnĂ­ seznamy */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '1ff2043b-8f15-42a8-bb25-27e584b21061'
DECLARE @DisplayName AS VARCHAR(150) = 'Telefonní seznamy'
DECLARE @QueryGroup AS VARCHAR(50) = 'Kontakty'
IF EXISTS(SELECT Top 1 DataQueryId FROM iCC.dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  SET @DataQueryId=NewId() -- Musím požádat o nové iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM iCC.dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'DisplayName',N'SELECT 
     PhoneBookId AS RecordId
         , ''1'' AS ProvedAkci
         ,[DisplayName]
        ,[Description]
        ,CAST(IIF(PhoneBookId=CONVERT(UniqueIdentifier,$(FS_Custom).dbo.GiveParam(''SELECTEDPHONEBOOK'')), 1,0) AS bit) AS IsSelected
    FROM [iCC].[dbo].[PhoneBook] WITH (NOLOCK)',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Název',N'Text',N'DisplayName',NULL,NULL,NULL,NULL,NULL,N'DisplayName',NULL,0,120,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Popis',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,120,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Zvol seznam',N'ImageScript',N'ProvedAkci',N'~/CustomImages/{0}.png',N'RecordId',NULL,NULL,NULL,N'ProvedAkci',NULL,0,80,30,NULL,0,N'exec $(FS_Custom).dbo.SelectPhBook @Id',NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsSelected',N'Color',N'IsSelected',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,40,N'#E0FFFF',0,NULL,'Info',NULL,NULL,NULL,NULL)
  
 END
GO

-- CONVERSION INTO CORRECT CODEPAGE WAS PERFORMED
-------------------------------------------------

  /* Kontakty: Seznam telefonních čísel */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '19627bb1-4299-4a30-87ea-63c2e25fb52c'
DECLARE @DisplayName AS VARCHAR(150) = 'Seznam telefonních čísel'
DECLARE @QueryGroup AS VARCHAR(50) = 'Kontakty'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'DisplayName ',N'select  PN.PhoneNumberId AS RecordId,PN.DisplayName, PN.Description, [Rank]
          , ''1'' AS ProvedAkci		 
          ,[Numbers]
          ,[Emails]
      ,$(FS_Custom).dbo.[GetPhoneNumPhoneBooks](PN.PhoneNumberId) as PhoneBookName -- .dbo.GetContactNumber(C.ContactId,1) AS Number1,
     -- .dbo.GetContactNumber(C.ContactId,2) AS Number2,
     -- .dbo.GetContactEmail(C.ContactId,1) AS Email
      --C.CE_birthNumber, C.CE_companyNumber, C.CE_syncNumber,
      --COUNT(PB.PhoneBookId) AS PhoneBookCount,
      --CAST((CASE WHEN PB.ProjectId IS NULL THEN 1 ELSE 0 END) AS BIT) AS IsUnassigned
      from [iCC].[dbo].[PhoneNumber] PN WITH (NOLOCK)
      LEFT JOIN .dbo.PhoneComposition AS PC WITH (NOLOCK) ON PC.PhoneNumberId = PN.PhoneNumberId
      LEFT JOIN .dbo.PhoneBook AS PB WITH (NOLOCK) ON PB.PhoneBookId = PC.PhoneBookId
      where PN.Deleted=0   ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Zařaď do seznamu',N'ImageScript',N'ProvedAkci',N'~/CustomImages/{0}.png',N'RecordId',NULL,NULL,NULL,N'ProvedAkci',NULL,0,100,5,NULL,0,N'exec $(FS_Custom).dbo.PutPNIntoPhBook @Id ',NULL,NULL,NULL,NULL,NULL)
 INSERT [DataQueryColumn] (DataQueryId, [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Tel. číslo',N'HyperLink',N'Numbers',NULL,N'RecordId',N'/FsAdmin/Pages/PhoneNumbers/EditForm.aspx?Id={0}',NULL,NULL,N'Numbers',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Název',N'Text',N'DisplayName',NULL,NULL,NULL,NULL,NULL,N'DisplayName',NULL,0,200,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Popis',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,200,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Tel. seznam',N'Text',N'PhoneBookName',NULL,NULL,NULL,NULL,NULL,N'PhoneBookName',NULL,0,120,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Email',N'HyperLink',N'Emails',NULL,N'RecordId',N'/FsAdmin/Pages/PhoneNumbers/EditForm.aspx?Id={0}',NULL,NULL,N'Emails',NULL,0,160,110,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Pořadí',N'Integer',N'Rank',NULL,NULL,NULL,NULL,NULL,N'Rank',NULL,0,60,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO

  /* Kontakty: Seznam telefonních čísel pro export */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'f66ff314-27ab-4330-affa-937b005a0b47'
DECLARE @DisplayName AS VARCHAR(150) = 'Seznam telefonních čísel pro export'
DECLARE @QueryGroup AS VARCHAR(50) = 'Kontakty'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'DisplayName ',N'select PN.PhoneNumberId, PN.DisplayName, PN.Description, [Rank]		 
        ,[Numbers]
        ,[Emails]
  	  ,PB.DisplayName AS PhoneBookName
     from [iCC].[dbo].[PhoneNumber] PN WITH (NOLOCK)
    LEFT JOIN .dbo.PhoneComposition AS PC WITH (NOLOCK) ON PC.PhoneNumberId = PN.PhoneNumberId
    LEFT JOIN .dbo.PhoneBook AS PB WITH (NOLOCK) ON PB.PhoneBookId = PC.PhoneBookId
    where PN.Deleted=0 AND PC.PhoneNumberId IS NOT NULL',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Tel. číslo',N'HyperLink',N'Numbers',NULL,N'PhoneNumberId',N'/ReactClient/Pages/PhoneNumberEditor.html?Id={0}',NULL,NULL,N'Numbers',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Název',N'Text',N'DisplayName',NULL,NULL,NULL,NULL,NULL,N'DisplayName',NULL,0,200,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Popis',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,200,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Tel. seznam',N'Select',N'PhoneBookName',NULL,NULL,NULL,NULL,NULL,N'PhoneBookName',NULL,0,120,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Email',N'Text',N'Emails',NULL,NULL,NULL,NULL,NULL,N'Emails',NULL,0,160,110,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Pořadí',N'Integer',N'Rank',NULL,NULL,NULL,NULL,NULL,N'Rank',NULL,0,60,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO



-- CONVERSION INTO CORRECT CODEPAGE WAS PERFORMED
-------------------------------------------------

  /* Admin: Všechny zprávy */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '05d59721-8eed-493d-a88d-a547153aed49'
DECLARE @DisplayName AS VARCHAR(150) = 'Messages'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF Not EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'ADMIN - Messages',@QueryGroup,N'TimeUtc DESC',N'SELECT M.MessageId, M.TimeUtc, M.MessageType, M.MessagePhase, M.Direction,    M.FromField, M.ToField, M.ToCcField,
     M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,  M.ProjectId, M.GatewayId, M.AgentId, M.TeamName, M.LanguageId, M.IssueId,  P.DisplayName AS ProjectName, G.DisplayName AS GatewayName,
      A.DisplayName AS AgentName, L.DisplayName AS LanguageName,  ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,  CAST(CASE WHEN MessageResult=''Active'' THEN 1 ELSE 0 END AS bit) AS IsActive, 
       CAST(CASE WHEN MessagePhase=''Draft'' OR MessagePhase=''Received'' THEN 1 ELSE 0 END AS bit) AS IsNew,
       CAST(CASE WHEN (MessagePhase=''Read'' OR MessagePhase=''Received'') AND ReceivedSentTime<@Today THEN 1 ELSE 0 END AS bit) AS IsLate,
         CAST(CASE WHEN EXISTS(SELECT * From Attachment WHERE M.MessageId=Attachment.MessageId) THEN 1 ELSE 0 END AS bit) AS HasAttachment,
    	  ISU.OpenTime AS IsuOpenTime,
              M.RelatedMessageId,
          M.RemoteAddress
    	   FROM Message AS M   LEFT JOIN Project AS P ON M.ProjectId=P.ProjectId 
    	    LEFT JOIN Gateway AS G ON M.GatewayId=G.GatewayId 
    		 LEFT JOIN Agent AS A ON M.AgentId=A.AgentId
    		  LEFT JOIN Language AS L ON M.LanguageId=L.LanguageId
    		  LEFT JOIN Issue AS ISU ON M.IssueId=ISU.IssueId
    		    LEFT JOIN ScenarioResult AS SR ON SR.MessageId=M.MessageId AND (SR.ScenarioId=  ''f1cb5e2f-543f-4cd5-9df1-5365bde8066e'') ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'MessageId',N'Text',N'MessageId',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,230,2,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'MessageType',N'Image',N'MessageType',N'~/CustomImages/{0}.png',N'MessageId',N'/ReactClient/Pages/MessageEditor.html?Id={0}',NULL,N'MessageType',N'MessageType',NULL,0,25,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Direction',N'Image',N'Direction',N'~/CustomImages/Dir-{0}.png',NULL,NULL,NULL,N'MessageDirection',N'Direction',NULL,0,25,7,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'MessageTime',N'DateTimeFromTo',N'MessageTime',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'MessageTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Od',N'FullText',N'FromField',NULL,NULL,NULL,N'FromField',NULL,N'FromField',NULL,0,120,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'RemoteAddress',N'Text',N'RemoteAddress',NULL,NULL,NULL,NULL,NULL,N'RemoteAddress',NULL,0,80,25,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Pøedmìt',N'HyperFullText',N'SubjectField',NULL,N'MessageId',N'/ReactClient/Pages/MessageEditor.html?Id={0}',N'SubjectField',NULL,N'SubjectField',NULL,0,160,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Komu',N'FullText',N'ToField',NULL,NULL,NULL,N'ToField',NULL,N'ToField',NULL,0,100,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stav',N'Select',N'MessagePhase',NULL,NULL,NULL,NULL,N'MessagePhase',N'MessagePhase',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Agent',N'ForeignKey',N'AgentName',NULL,NULL,NULL,N'AgentId',N'AgentName',N'AgentName',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Tým',N'Select',N'TeamName',NULL,NULL,NULL,NULL,NULL,N'TeamName',NULL,0,80,61,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Brána',N'ForeignKey',N'GatewayName',NULL,NULL,NULL,N'GatewayId',N'GatewayName',N'GatewayName',NULL,0,80,65,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Projekt',N'ForeignKey',N'ProjectName',NULL,NULL,NULL,N'ProjectId',N'ProjectName',N'ProjectName',NULL,0,100,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Jazyk',N'ForeignKey',N'LanguageName',NULL,NULL,NULL,N'LanguageId',N'LanguageName',N'LanguageName',NULL,0,35,71,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Nová zpráva',N'Bold',N'IsNew',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,91,NULL,0,NULL,N'warning',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stará 1D',N'Color',N'IsLate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,N'#FFE9D1',0,NULL,N'warning',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Aktivní',N'Color',N'IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,93,N'#CCFADF',0,NULL,N'success',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeUtc',N'DateTimeUtc',N'TimeUtc',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeUtc',NULL,0,100,103,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'BodyField',N'Text',N'BodyField',NULL,NULL,NULL,NULL,NULL,N'BodyField',NULL,0,80,113,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsuOpenTime',N'DateTimeFromTo',N'IsuOpenTime',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'IsuOpenTime',NULL,0,100,123,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'RelatedMessageId',N'Text',N'RelatedMessageId',NULL,NULL,NULL,NULL,NULL,N'RelatedMessageId',NULL,0,230,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO


  /* Admin: Všechny případy  */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '34137610-1fb2-4b82-a857-2bf1f3c05d08'
DECLARE @DisplayName AS VARCHAR(150) = 'Všechny případy '
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0 IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
IF Not EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
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

DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'da89c2b0-f74d-4b41-8589-5491c8239a29'
UPDATE $(iCC).[dbo].[Dataquery] SET  Deleted=0 WHERE DataQueryId=@DataQueryId AND Deleted=1

IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN

/* Admin: Detected problems */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'da89c2b0-f74d-4b41-8589-5491c8239a29',N'Detected problems',NULL,N'Admin',N'Timelocal DESC',N'SELECT TOP (1000) [Timelocal]
      ,[RepeatAfter]
      ,[Message]
  FROM $(FS_Custom).[dbo].[ErrorLog] ORDER BY Timelocal DESC',0,NULL,NULL,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'a5efd52b-4b8d-43b4-bdd0-04a357ae8b18',N'da89c2b0-f74d-4b41-8589-5491c8239a29',N'Timelocal',N'DateTimeFromTo',N'Timelocal',N'{0:dd.MM.yyyy HH:mm}',NULL,NULL,NULL,NULL,N'Timelocal',NULL,0,95,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'363034a7-957a-4dd7-83f6-b9a1dda40f3d',N'da89c2b0-f74d-4b41-8589-5491c8239a29',N'RepeatAfter [min]',N'Integer',N'RepeatAfter',NULL,NULL,NULL,NULL,NULL,N'RepeatAfter',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'ce5d5024-2675-41f6-b5d5-de7c9bb332f1',N'da89c2b0-f74d-4b41-8589-5491c8239a29',N'Message',N'Text',N'Message',NULL,NULL,NULL,NULL,NULL,N'Message',NULL,0,500,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
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
    FROM $(iCC).[dbo].[IssueEvent] IE
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

IF OBJECT_ID (N'Portal', N'U') IS NOT NULL
 BEGIN 
  IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_KontSys')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'af62bfee-171b-489b-9e29-19232d11d71d', N'Admin_KontSys', N'Kontrolní systém', NULL, N'fa fa-phone', NULL, N'AdminPageNav', 5060, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Eventlog","Css":"","DataQuery":{"Id":"0052e9cb-1dd8-4829-ba19-d5a7d410915a","DisplayName":"Eventlog","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Výsledky akcí","Css":"","DataQuery":{"Id":"4c9e5e61-f17a-4ce1-9bb4-441c8ad8f83e","DisplayName":"Výsledky akcí","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":5,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Admin příkazy","Css":"","DataQuery":{"Id":"61c8ebc7-e7be-42b2-88b5-578479d8c30a","DisplayName":"Admin příkazy","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
  IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Kontrolní systém')=1
    UPDATE dbo.Portal SET  DisplayName='Inspection system'
     WHERE DisplayName='Kontrolní systém' AND HashPage='Admin_KontSys'
 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
    IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Wallboard')
     INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'77547454-f322-4658-b67f-1a9f038231c5', N'Admin_Wallboard', N'Wallboardy', NULL, N' fa-bar-chart', NULL, N'AdminPageNav', 5070, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Wallboard","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"d24df1de-5bdd-455c-aed1-1c45279cbd84","DisplayName":"Wallboard","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Wallboard časy","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"1c043f8c-2616-4293-8467-2422bf171ae7","DisplayName":"Wallboard časy","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
    IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Wallboardy')=1
     UPDATE dbo.Portal SET  DisplayName='Wallboards'
      WHERE DisplayName='Wallboardy' AND HashPage='Admin_Wallboard'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_IVR')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
    VALUES (N'a941d991-9d2e-427f-b230-443b4445b041', N'Admin_IVR', N'IVR', NULL, N'fa fa-phone', NULL, N'AdminPageNav', 5050, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"IVR Skripty","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"b36e3ad0-c8e3-4083-a23a-0e18686076b6","DisplayName":"IVR Skripty","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"IVR Step","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"d45fde09-0bf3-4418-bf50-7f11f3e5c0e5","DisplayName":"IVR Step","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"873404dd-0641-46b0-b8f4-3f6b33bf348c","DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","SpecificName":"ADMIN","Glyph":"fa fa-thermometer-full","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-thermometer-full",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
  END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Hovory')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
	 VALUES (N'49dfe157-4a6f-4656-8bde-56499183d4d2', N'Admin_Hovory', N'Hovory', NULL, N'fa fa-phone', NULL, N'AdminPageNav', 5010, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Všechny příchozí hovory","Css":"","DataQuery":{"Id":"99cecf13-c463-4abd-a52e-ad923d51ac7c","DisplayName":"Všechny příchozí hovory","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Admin: Události příchozího ","Css":"","DataQuery":{"Id":"354e10a1-14f7-4f66-b1aa-9b7ffee2b91f","DisplayName":"Události příchozího ","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"DataQueryGrid","Path":"A","Index":"E","DisplayName":"Admin: Všechny odchozí hovory","Css":"","DataQuery":{"Id":"ce85ccb8-d497-40ab-a067-e1561d4d7ab6","DisplayName":"Všechny odchozí hovory","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"DataQueryGrid","Path":"A","Index":"F","DisplayName":"Admin: Události odchozího hovoru","Css":"","DataQuery":{"Id":"354e10a1-14f7-4f66-b1aa-9b7ffee2b91f","DisplayName":"Události odchozího hovoru","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Admin: Nahrávky","Css":"","DataQuery":{"Id":"68df515a-31d7-4137-b661-9ce2c40a601a","DisplayName":"Nahrávky","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Hovory' AND HashPage='Admin_Hovory')=1
      UPDATE dbo.Portal SET  DisplayName='Calls'
       WHERE DisplayName='Hovory' AND HashPage='Admin_Hovory'
 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_FrontaHovoru')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
     VALUES (N'd0c44ccf-5260-4b1b-8f8e-a52a3fe10073', N'Admin_FrontaHovoru', N'Fronta hovorů', NULL, N'fa fa-align-left', NULL, N'AdminPageNav', 5080, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Vyšetřování fronty","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"832e1da3-c87e-4e51-a7a6-ca1ec2abcdfd","DisplayName":"Vyšetřování fronty","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Volní agenti","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"9e103b6f-379b-417c-8ec7-2361ef3124ed","DisplayName":"Volní agenti","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Volní agenti seznam","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"50baed36-ca55-46b5-a971-45996d7b52f0","DisplayName":"Volní agenti seznam","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Fronta hovorů' AND HashPage='Admin_FrontaHovoru')=1
      UPDATE dbo.Portal SET  DisplayName='Queue of Calls'
       WHERE DisplayName='Fronta hovorů' AND HashPage='Admin_FrontaHovoru'
  END
 GO
IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
 BEGIN
  IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_FrontaMailu')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
	 VALUES (N'16f6e129-53e1-4c83-8340-e85b888f7714', N'Admin_FrontaMailu', N'Fronta mailů', NULL, N'fa fa-align-left', NULL, N'AdminPageNav', 5082, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Admin: Všechny zprávy e-mailové fronty","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"98e73265-c1e5-4a7c-938f-fd69ccee3439","DisplayName":"Všechny zprávy e-mailové fronty","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Admin: VolniAgentiProMail","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"e67f9717-e912-4f37-8c81-ead7c65c7800","DisplayName":"VolniAgentiProMail","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Admin: Přiřazené zprávy agentům","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"f2e2995f-40ad-4fdc-a3ee-27716a48a96b","DisplayName":"Přiřazené zprávy agentům","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null}]')
  IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Fronta mailů' AND HashPage='Admin_FrontaMailu')=1
      UPDATE dbo.Portal SET  DisplayName='Queue of Emails'
       WHERE DisplayName='Fronta mailů' AND HashPage='Admin_FrontaMailu'

END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_DQ')
 BEGIN

INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'873b377f-11b3-4142-9063-b7db635d52d0', N'Admin_DQ', N'Data Query', NULL, N'fa fa-calendar', NULL, N'AdminPageNav', 5030, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Datové dotazy","Css":"","DataQuery":{"Id":"e5fe7ca3-06f1-46a4-9771-09cb4bfc43eb","DisplayName":"Datové dotazy","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Sloupce dotazů","Css":"","DataQuery":{"Id":"d1f1f295-8801-423b-aafd-9222ee4892fc","DisplayName":"Sloupce dotazů","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null}]')
 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Email')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
	 VALUES (N'7f649a00-6cda-47f5-a600-dcd4195f1051', N'Admin_Email', N'Emaily', NULL, N'fa fa-envelope', NULL, N'AdminPageNav', 5040, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner hlavni","Css":"col-md-12 col-sm-12 col-xs-12","FixedTopHeight":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Všechny zprávy","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"05d59721-8eed-493d-a88d-a547153aed49","DisplayName":"Všechny zprávy","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"MessageEvent","Css":"","DataQuery":{"Id":"2f0fd1d8-017a-4a7c-be35-a8c02f46007d","DisplayName":"MessageEvent","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":true,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Emaily' AND HashPage='Admin_Email')=1
      UPDATE dbo.Portal SET  DisplayName='Emails'
       WHERE DisplayName='Emaily' AND HashPage='Admin_Email'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Agenti')
     INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
	  VALUES (N'01de7c4a-d813-4031-84f6-ee3d561ccab9', N'Admin_Agenti', N'Agenti', NULL, N'fa fa-users', NULL, N'AdminPageNav', 5020, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Přehled agentů Admin","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"ec5174c1-ad19-4423-8fff-ae043dc92627","DisplayName":"Přehled agentů Admin","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Výsledky akcí","Css":"","DataQuery":{"Id":"4c9e5e61-f17a-4ce1-9bb4-441c8ad8f83e","DisplayName":"Výsledky akcí","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Agenti' AND HashPage='Admin_Agenti')=1
      UPDATE dbo.Portal SET  DisplayName='Agents'
       WHERE DisplayName='Agenti' AND HashPage='Admin_Agenti'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Kontakt') 
     INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
	  VALUES (N'014288d4-c3fe-433e-93da-fde0fce3c0e0', N'Admin_Kontakt', N'Kontakty', NULL, N'fa fa-address-card', NULL, N'AdminPageNav', 5055, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Telefonní seznamy","Css":"","DataQuery":{"Id":"1ff2043b-8f15-42a8-bb25-27e584b21061","DisplayName":"Telefonní seznamy","SpecificName":"Kontakty","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Seznam telefonních čísel","Css":"","DataQuery":{"Id":"19627bb1-4299-4a30-87ea-63c2e25fb52c","DisplayName":"Seznam telefonních čísel","SpecificName":"Kontakty","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Seznam telefonních čísel pro export","Css":"","DataQuery":{"Id":"f66ff314-27ab-4330-affa-937b005a0b47","DisplayName":"Seznam telefonních čísel pro export","SpecificName":"Kontakty","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Kontakty' AND HashPage='Admin_Kontakt')=1
      UPDATE dbo.Portal SET  DisplayName='Contacts'
       WHERE DisplayName='Kontakty' AND HashPage='Admin_Kontakt'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='admin_pripady' AND PortalId<>'f007b5da-21c9-499f-b781-88a8950c98a9')
   DELETE FROM $(ICC).dbo.Portal WHERE HashPage='admin_pripady' 
 END
GO
IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
 BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='admin_pripady')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
     VALUES (N'f007b5da-21c9-499f-b781-88a8950c98a9', N'admin_pripady', N'Případy', N'Případy', N'fa fa-briefcase', NULL, N'AdminPageNav', 5045, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Všechny případy ","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"34137610-1fb2-4b82-a857-2bf1f3c05d08","DisplayName":"Všechny případy ","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Issue Events","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"6c5e8e3f-37b1-4fc6-8c7d-233efd017f2b","DisplayName":"Issue Events","SpecificName":"ADMIN","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Případy' AND HashPage='admin_pripady')=1
      UPDATE dbo.Portal SET  DisplayName='Issues'
       WHERE DisplayName='Případy' AND HashPage='admin_pripady'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
 IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='admin_ExpImp')
 BEGIN
   INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) 
   VALUES (N'9ff03aae-a127-47e1-8a41-d491de622d2f', N'admin_expimp', N'Export/Import', N'Export/Import', N'fa fa-exchange', NULL, N'AdminPageNav', 5090, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true}]')
 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
 IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='admin_Record')
 BEGIN
  INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
   VALUES (N'2b25c09d-ad82-4472-9b38-49fe3074d82b', N'admin_Record', N'Recordings', N'Recordings', N'fa fa-microphone', NULL, N'AdminPageNav', 5092, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Admin Recordingless Calls","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"a12aae6c-caef-4ba1-a117-221b2a6c1f75","DisplayName":"Admin Recordingless Calls","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Percents","ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Admin Recordingless Calls"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true}]')
 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL AND NOT EXISTS 
 (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_KontSys' AND Glyph='fa fa-bug')
 BEGIN 
    UPDATE dbo.Portal SET  Glyph='fa fa-bug'
     WHERE HashPage='Admin_KontSys' AND NavGroup='AdminPageNav'
    UPDATE dbo.Portal SET  Glyph='fa fa-user'
     WHERE HashPage='Admin_Kontakt' AND NavGroup='AdminPageNav'
    UPDATE dbo.Portal SET  Glyph='fa fa-bar-chart'
     WHERE HashPage='Admin_Wallboard' AND NavGroup='AdminPageNav'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
 -- Toto nefungovalo - asi nějaká nekompatibilita
 UPDATE [dbo].[Portal]
   SET 
      [JsonData] = '[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"33047afb-6685-4587-9c8f-ab889675a20a","DisplayName":"Export vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Catalog","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"26b70734-8b02-44ad-a71c-90708690c3d3","DisplayName":"Catalog","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"ddc01671-d175-4de6-920f-541c8c4e7c8f","DisplayName":"Přepis vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":0},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]''[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"33047afb-6685-4587-9c8f-ab889675a20a","DisplayName":"Export vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Catalog","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"26b70734-8b02-44ad-a71c-90708690c3d3","DisplayName":"Catalog","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"ddc01671-d175-4de6-920f-541c8c4e7c8f","DisplayName":"Přepis vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":0},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]''[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"33047afb-6685-4587-9c8f-ab889675a20a","DisplayName":"Export vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Catalog","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"26b70734-8b02-44ad-a71c-90708690c3d3","DisplayName":"Catalog","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"ddc01671-d175-4de6-920f-541c8c4e7c8f","DisplayName":"Přepis vybraných modulů","SpecificName":"ADMIN","Glyph":"fa fa-arrow-left","Flag1":0},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]'
   WHERE 1=2 AND HAShPAGe='admin_expimp' and NavGroup='AdminPageNav'
GO

  /* Admin: Sloupce dotazů */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '1ccce0b7-3447-4822-bc5e-254a07fde056'
DECLARE @DisplayName AS VARCHAR(150) = 'Sloupce dotazů'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'Rank',N'/****** Script for SelectTopNRows command from SSMS  ******/
      SELECT  [DataQueryColumnId]
            ,DQ.[DisplayName] AS DQName
            ,DQ.QueryGroup 
            ,DQC.[DataQueryId]
            ,DQC.[DisplayName]
            ,[Model]
            ,[TargetColumn]
            ,[TargetFormat]
            ,[UrlColumn]
            ,[UrlFormat]
            ,[GuidColumn]
            ,[Convertor]
            ,[SortExpression]
            ,[SortExpressionDesc]
            ,[NoFilter]
            ,[Width]
            ,[Rank]
            ,[Color]
            ,[SqlCmd]
            ,[Css]
            ,[ToolTip]
            ,[LiteralGroup]
            ,[GlyphColumn]
            ,[GlyphFormat]
        FROM .[dbo].[DataQueryColumn] DQC
    inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
    WHERE DQC.Deleted=0
  ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'DataQueryId',N'Text',N'DataQueryId',NULL,NULL,NULL,NULL,NULL,N'DataQueryId',NULL,0,230,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'DQName',N'Select',N'DQName',NULL,NULL,NULL,NULL,NULL,N'DQName',NULL,0,200,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'QueryGroup',N'Select',N'QueryGroup',NULL,NULL,NULL,NULL,NULL,N'QueryGroup',NULL,0,80,9,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'DisplayName',N'HyperLink',N'DisplayName',NULL,N'DataqueryColumnId',N'http://localhost/FSAdmin/Pages/DataQueryColumns/EditForm.aspx?Id={0}&Source=%2fFSAdmin%2fPages%2fDataQueries%2fEditForm.aspx%3fId%3d1ccce0b7-3447-4822-bc5e-254a07fde056%26Source%3d%252fFSAdmin%252fPages%252fDataQueries%252fList.aspx%253f',NULL,NULL,N'DisplayName',NULL,0,80,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Model',N'Select',N'Model',NULL,NULL,NULL,NULL,NULL,N'Model',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TargetColumn',N'Text',N'TargetColumn',NULL,NULL,NULL,NULL,NULL,N'TargetColumn',NULL,0,100,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TargetFormat',N'Text',N'TargetFormat',NULL,NULL,NULL,NULL,NULL,N'TargetFormat',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'UrlColumn',N'Text',N'UrlColumn',NULL,NULL,NULL,NULL,NULL,N'UrlColumn',NULL,0,100,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'UrlFormat',N'Text',N'UrlFormat',NULL,NULL,NULL,NULL,NULL,N'UrlFormat',NULL,0,300,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'GuidColumn',N'Text',N'GuidColumn',NULL,NULL,NULL,NULL,NULL,N'GuidColumn',NULL,0,80,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Convertor',N'Text',N'Convertor',NULL,NULL,NULL,NULL,NULL,N'Convertor',NULL,0,80,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'SortExpression',N'Text',N'SortExpression',NULL,NULL,NULL,NULL,NULL,N'SortExpression',NULL,0,80,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'SortExpressionDesc',N'Text',N'SortExpressionDesc',NULL,NULL,NULL,NULL,NULL,N'SortExpressionDesc',NULL,0,80,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'NoFilter',N'Color',N'NoFilter',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,110,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Width',N'Integer',N'Width',NULL,NULL,NULL,NULL,NULL,N'Width',NULL,0,60,120,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Rank',N'Integer',N'Rank',NULL,NULL,NULL,NULL,NULL,N'Rank',NULL,0,60,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Color',N'Text',N'Color',NULL,NULL,NULL,NULL,NULL,N'Color',NULL,0,80,140,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'SqlCmd',N'Text',N'SqlCmd',NULL,NULL,NULL,NULL,NULL,N'SqlCmd',NULL,0,80,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Css',N'Text',N'Css',NULL,NULL,NULL,NULL,NULL,N'Css',NULL,0,80,170,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ToolTip',N'Integer',N'ToolTip',NULL,NULL,NULL,NULL,NULL,N'ToolTip',NULL,0,60,180,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'GlyphColumn',N'Text',N'GlyphColumn',NULL,NULL,NULL,NULL,NULL,N'GlyphColumn',NULL,0,80,190,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'GlyphFormat',N'Text',N'GlyphFormat',NULL,NULL,NULL,NULL,NULL,N'GlyphFormat',NULL,0,80,200,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO


  /* Admin: Datové dotazy */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'bce5b69c-6335-4d01-a620-33c44b891801'
DECLARE @DisplayName AS VARCHAR(150) = 'Data queries'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'DisplayName',N'SELECT  [DataQueryId]
            ,[DisplayName]
            ,[Description]
            ,[QueryGroup]
            ,[QuerySortExpression]
            ,[QueryText]
            ,[ManualFilter]
            ,[SnapshotInterval]
            ,[TimeLine]
            ,[Deleted]
            ,[CacheInterval]
        FROM $(iCC).[dbo].[DataQuery] WHERE Deleted=0',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'DataQueryId',N'Text',N'DataQueryId',NULL,NULL,NULL,NULL,NULL,N'DataQueryId',NULL,0,230,3,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'DisplayName',N'HyperLink',N'DisplayName',NULL,N'DataqueryId',N'http://localhost/FSAdmin/Pages/DataQueries/EditForm.aspx?Id={0}&Source=%2fFSAdmin%2fPages%2fDataQueries%2fList.aspx%3fSortExpression%3d%26SortDirection%3dAscending%26PageIndex%3d0',NULL,NULL,N'DisplayName',NULL,0,200,162,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'QueryGroup',N'Select',N'QueryGroup',NULL,NULL,NULL,NULL,NULL,N'QueryGroup',NULL,0,80,167,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Description',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,80,172,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'QuerySortExpression',N'Text',N'QuerySortExpression',NULL,NULL,NULL,NULL,NULL,N'QuerySortExpression',NULL,0,80,192,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'QueryText',N'Text',N'QueryText',NULL,NULL,NULL,NULL,NULL,N'QueryText',NULL,0,80,202,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ManualFilter',N'Color',N'ManualFilter',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,212,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'SnapshotInterval',N'Integer',N'SnapshotInterval',NULL,NULL,NULL,NULL,NULL,N'SnapshotInterval',NULL,0,60,222,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeLine',N'Text',N'TimeLine',NULL,NULL,NULL,NULL,NULL,N'TimeLine',NULL,0,80,232,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Deleted',N'Color',N'Deleted',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,242,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'CacheInterval',N'Integer',N'CacheInterval',NULL,NULL,NULL,NULL,NULL,N'CacheInterval',NULL,0,60,252,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO


-- CONVERSION INTO CORRECT CODEPAGE WAS PERFORMED
-------------------------------------------------

  /* Admin: MessageEvent */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '2f0fd1d8-017a-4a7c-be35-a8c02f46007d'
DECLARE @DisplayName AS VARCHAR(150) = 'MessageEvent'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'MessageEvent',@QueryGroup,N'TimeLocal',N'SELECT [MessageEventId]
          ,[TimeUtc]
          ,[TimeLocal]
          , AG.DisplayName
          ,[EventType]
          ,[MessageId]
          ,PR.[DisplayName] AS ProjectName
          ,ME.[AgentId]
          ,[ReferenceData]
          ,[ReferenceId]
          ,[Duration]
          ,[ResultData]
      FROM [dbo].[MessageEvent] AS ME WITH (NOLOCK)
  	 LEFT OUTER JOIN Agent AS AG  WITH (NOLOCK) ON ME.AgentId=AG.AgentId
  	 LEFT OUTER JOIN Project AS PR  WITH (NOLOCK) ON ME.ProjectId=PR.ProjectId',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'MessageId',N'Text',N'MessageId',NULL,NULL,NULL,NULL,NULL,N'MessageId',NULL,0,230,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeLocal',N'DateTimeFromTo',N'TimeLocal',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeLocal',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'AgentName',N'Text',N'DisplayName',NULL,NULL,NULL,NULL,NULL,N'DisplayName',NULL,0,120,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ProjectName',N'Text',N'ProjectName',NULL,NULL,NULL,NULL,NULL,N'ProjectName',NULL,0,140,35,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'EventType',N'Text',N'EventType',NULL,NULL,NULL,NULL,NULL,N'EventType',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ReferenceData',N'Text',N'ReferenceData',NULL,NULL,NULL,NULL,NULL,N'ReferenceData',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Duration',N'Duration',N'Duration',NULL,NULL,NULL,NULL,NULL,N'Duration',NULL,0,60,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ResultData',N'Text',N'ResultData',NULL,NULL,NULL,NULL,NULL,N'ResultData',NULL,0,80,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeUtc',N'DateTimeUtc',N'TimeUtc',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeUtc',NULL,0,100,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO
  /* Admin: Všechny zprávy */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '05d59721-8eed-493d-a88d-a547153aed49'
DECLARE @DisplayName AS VARCHAR(150) = 'Všechny zprávy'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'ADMIN - zprávy',@QueryGroup,N'TimeUtc DESC',N'SELECT M.MessageId, M.TimeUtc, M.MessageType, M.MessagePhase, M.Direction,    M.FromField, M.ToField, M.ToCcField,
     M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,  M.ProjectId, M.GatewayId, M.AgentId, M.TeamName, M.LanguageId, M.IssueId,  P.DisplayName AS ProjectName, G.DisplayName AS GatewayName,
      A.DisplayName AS AgentName, L.DisplayName AS LanguageName,  ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,  CAST(CASE WHEN MessageResult=''Active'' THEN 1 ELSE 0 END AS bit) AS IsActive, 
       CAST(CASE WHEN MessagePhase=''Draft'' OR MessagePhase=''Received'' THEN 1 ELSE 0 END AS bit) AS IsNew,
       CAST(CASE WHEN (MessagePhase=''Read'' OR MessagePhase=''Received'') AND ReceivedSentTime<@Today THEN 1 ELSE 0 END AS bit) AS IsLate,
         CAST(CASE WHEN EXISTS(SELECT * From Attachment WHERE M.MessageId=Attachment.MessageId) THEN 1 ELSE 0 END AS bit) AS HasAttachment,
    	  ISU.OpenTime AS IsuOpenTime,
              M.RelatedMessageId,
          M.RemoteAddress
    	   FROM Message AS M   LEFT JOIN Project AS P ON M.ProjectId=P.ProjectId 
    	    LEFT JOIN Gateway AS G ON M.GatewayId=G.GatewayId 
    		 LEFT JOIN Agent AS A ON M.AgentId=A.AgentId
    		  LEFT JOIN Language AS L ON M.LanguageId=L.LanguageId
    		  LEFT JOIN Issue AS ISU ON M.IssueId=ISU.IssueId
    		    LEFT JOIN ScenarioResult AS SR ON SR.MessageId=M.MessageId AND (SR.ScenarioId=  ''f1cb5e2f-543f-4cd5-9df1-5365bde8066e'') ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'MessageId',N'Text',N'MessageId',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,230,2,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Typ',N'Image',N'MessageType',N'~/CustomImages/{0}.png',N'MessageId',N'/ReactClient/Pages/MessageEditor.html?Id={0}',NULL,N'MessageType',N'MessageType',NULL,0,25,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Směr',N'Image',N'Direction',N'~/CustomImages/Dir-{0}.png',NULL,NULL,NULL,N'MessageDirection',N'Direction',NULL,0,25,7,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Čas',N'DateTimeFromTo',N'MessageTime',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'MessageTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Od',N'FullText',N'FromField',NULL,NULL,NULL,N'FromField',NULL,N'FromField',NULL,0,120,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'RemoteAddress',N'Text',N'RemoteAddress',NULL,NULL,NULL,NULL,NULL,N'RemoteAddress',NULL,0,80,25,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Předmět',N'HyperFullText',N'SubjectField',NULL,N'MessageId',N'/ReactClient/Pages/MessageEditor.html?Id={0}',N'SubjectField',NULL,N'SubjectField',NULL,0,160,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Komu',N'FullText',N'ToField',NULL,NULL,NULL,N'ToField',NULL,N'ToField',NULL,0,100,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stav',N'Select',N'MessagePhase',NULL,NULL,NULL,NULL,N'MessagePhase',N'MessagePhase',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Agent',N'ForeignKey',N'AgentName',NULL,NULL,NULL,N'AgentId',N'AgentName',N'AgentName',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Tým',N'Select',N'TeamName',NULL,NULL,NULL,NULL,NULL,N'TeamName',NULL,0,80,61,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Brána',N'ForeignKey',N'GatewayName',NULL,NULL,NULL,N'GatewayId',N'GatewayName',N'GatewayName',NULL,0,80,65,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Projekt',N'ForeignKey',N'ProjectName',NULL,NULL,NULL,N'ProjectId',N'ProjectName',N'ProjectName',NULL,0,100,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Jazyk',N'ForeignKey',N'LanguageName',NULL,NULL,NULL,N'LanguageId',N'LanguageName',N'LanguageName',NULL,0,35,71,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Nová zpráva',N'Bold',N'IsNew',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,91,NULL,0,NULL,N'warning',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stará 1D',N'Color',N'IsLate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,N'#FFE9D1',0,NULL,N'warning',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Aktivní',N'Color',N'IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,93,N'#CCFADF',0,NULL,N'success',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeUtc',N'DateTimeUtc',N'TimeUtc',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeUtc',NULL,0,100,103,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'BodyField',N'Text',N'BodyField',NULL,NULL,NULL,NULL,NULL,N'BodyField',NULL,0,80,113,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsuOpenTime',N'DateTimeFromTo',N'IsuOpenTime',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'IsuOpenTime',NULL,0,100,123,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'RelatedMessageId',N'Text',N'RelatedMessageId',NULL,NULL,NULL,NULL,NULL,N'RelatedMessageId',NULL,0,230,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO


DECLARE @DisplayName AS VARCHAR(150) = 'Data Query usage'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'

 IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId='2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6'/*DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0*/)
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
  FROM $(iCC).[dbo].[DataQuery] DQ
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
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'a10ad2c8-64cb-4aff-b937-69cffe292dba'

UPDATE $(iCC).[dbo].[Dataquery] SET  Deleted=0 WHERE DataQueryId=@DataQueryId AND Deleted=1
 IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE [DataQueryId]=@DataQueryId/*DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0*/)
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
 IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Kontrola nahrávek ZbH')
INSERT [dbo].[ActionTrigger] ( [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted]) 
VALUES ( N'Kontrola nahrávek ZbH', NULL, N'Admin', N'EXEC $(FS_custom).dbo.CheckRecAndEmlActivity2', NULL, NULL, N'Interval', 30, N'DayInWeek', CAST(N'2017-01-02 07:45:00.000' AS DateTime), CAST(N'2017-01-06 20:10:59.900' AS DateTime), NULL, CAST(N'2018-07-09 10:50:27.247' AS DateTime), NULL, 0, 0)
GO

 DECLARE @DisplayName AS VARCHAR(150) = 'Catalog'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '26b70734-8b02-44ad-a71c-90708690c3d3'
-- IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId  = @DataQueryId)
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
        FROM $(FS_Custom).dbo.Commands 
     ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Perform command',N'ImageScript',N'ProvedAkci',N'~/CustomImages/{0}.png',N'RecordId',NULL,NULL,NULL,N'ProvedAkci',NULL,0,70,3,NULL,0,N'exec $(FS_Custom).dbo.RunScript @Id',NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Description',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,500,340,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
 
 END

GO
 /* Admin: Wallboard */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '372f67e1-c08d-49da-a1ce-89e875a1d68b'
DECLARE @DisplayName AS VARCHAR(150) = 'Wallboard'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'Wallboard',@QueryGroup,N'Popis',N'SELECT ''Zombie hovory'' AS Popis, COUNT(1) AS Pocet FROM [iCC].[dbo].[InboundCall]
    WHERE 1=1
      AND Callresult=''Active''
      AND CallPhase=''Distributing''
      AND PilotTime < DATEADD(Minute,-20,GETDATE())
    UNION ALL
    SELECT ''Změna agenta při distribuci příchozího hovoru za poslední 2 hodiny'' AS Popis, COUNT(1) AS Value
      FROM [iCC].[dbo].[CallEvent] CAE
        LEFT JOIN [iCC].[dbo].[CallEvent] CAE2 ON CAE.InboundCallId=CAE2.InboundCallId
    	AND CAE2.EventType=''AgentRing'' 
      WHERE 1=1
      AND CAE.TimeLocal>DATEADD(Hour,-2,@Now)
      AND CAE.EventType=''IssueChange ''
      AND CAE.ResultData=''AUTO''
      AND CAE.AgentId<>CAE2.AgentId
    UNION ALL
   SELECT ''Počet naplánovaných odchozích zpráv v posledních 5ti dnech a měly odejít'' AS Popis, COUNT(1) AS Value
      FROM .dbo.Message ME
       WHERE 1=1
      AND ME.Direction=''O''
      AND TimeUTC > DATEADD(Day,-5,@Now)
      AND (ME.ScheduledTime<@Now OR ME.ScheduledTime IS NULL)
      AND (ME.MessagePhase=''Scheduled'')
      AND ME.MessageResult=''Active''
   UNION ALL
    SELECT ''Počet naplánovaných odchozích zpráv v posledních 5ti dnech a ještě nenastal čas odchodu'' AS Popis, COUNT(1) AS Value
      FROM .dbo.Message ME
       WHERE 1=1
      AND ME.Direction=''O''
      AND TimeUTC > DATEADD(Day,-5,@Now)
      AND (ME.ScheduledTime>@Now)
      AND (ME.MessagePhase=''Scheduled'')
      AND ME.MessageResult=''Active''
   UNION ALL
    SELECT ''Počet odchozích zpráv v posledních 5ti dnech a selhaly'' AS Popis, COUNT(1) AS Value
      FROM .dbo.Message ME
       WHERE 1=1
      AND ME.Direction=''O''
      AND TimeUTC > DATEADD(Day,-5,@Now)
      AND (ME.ScheduledTime<@Now)
      AND (ME.MessagePhase=''Failed'' )
  ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Popis',N'Text',N'Popis',NULL,NULL,NULL,NULL,NULL,N'Popis',NULL,0,800,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Počet',N'Integer',N'Pocet',NULL,NULL,NULL,NULL,NULL,N'Pocet',NULL,0,60,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO

  /* Admin: Wallboard časy */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '1c043f8c-2616-4293-8467-2422bf171ae7'
DECLARE @DisplayName AS VARCHAR(150) = 'Wallboard Times'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'Wallboard Times',@QueryGroup,N'Popis',N'SELECT 
    ''Průměrná doba odeslání mailů za posledních 30 minut'' AS Popis,
   AVG(Seconds) AS Seconds FROM
   ( SELECT 
    DATEDIFF(SECOND,(SELECT TOP 1 TimeLocal FROM MessageEvent MEE WITH (NOLOCK) WHERE MEE.MessageId=ME.MessageId AND MEE.EVentType=''Sent'' AND MEE.ReferenceData=''Scheduled''),ReceivedSentTime) AS Seconds
      FROM .dbo.Message ME
     WHERE 1=1
    AND ME.Direction=''O''
    AND ME.MessagePhase=''Sent''
    AND ME.ReceivedSentTime>DATEADD(Minute,-30,GETDATE())) AS Phase1
    UNION ALL
    SELECT 
    ''Maximální doba odeslání mailů za posledních 30 minut'' AS Popis,
   MAX(Seconds) AS Seconds FROM
   ( SELECT 
    DATEDIFF(SECOND,(SELECT TOP 1 TimeLocal FROM MessageEvent MEE WITH (NOLOCK) WHERE MEE.MessageId=ME.MessageId AND MEE.EVentType=''Sent'' AND MEE.ReferenceData=''Scheduled''),ReceivedSentTime) AS Seconds
      FROM .dbo.Message ME
     WHERE 1=1
    AND ME.Direction=''O''
    AND ME.MessagePhase=''Sent''
    AND ME.ReceivedSentTime>DATEADD(Minute,-30,GETDATE())) AS Phase1',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Popis',N'Text',N'Popis',NULL,NULL,NULL,NULL,NULL,N'Popis',NULL,0,800,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Čas',N'Duration',N'Seconds',NULL,NULL,NULL,NULL,N'DurationHMMSS',N'Seconds',NULL,0,60,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO



 /* ADMIN: RecordingLess Calls */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'a12aae6c-caef-4ba1-a117-221b2a6c1f75'
DECLARE @DisplayName AS VARCHAR(150) = 'Admin Recordingless Calls'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId  = @DataQueryId  AND Deleted=0)
 BEGIN
 INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'Admin Recordingless Calls',N'Recordingless Calls Today',N'Admin',N'CallTime DESC',N'SELECT * FROM $(FS_Custom).[dbo].[RecordingLessCalls] (DATEADD(Day,-10,@Today), @Now)',0,NULL,NULL,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'356889fb-b72b-4cdd-b4a3-210ffe83f968',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'ExRecord',N'Select',N'ExRecord',NULL,NULL,NULL,NULL,NULL,N'ExRecord',NULL,0,80,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'e2b9c1ce-c986-4a5b-8fd6-f425a48075d8',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'CallTime',N'DateTimeFromTo',N'CallTime',N'{0:dd.MM. HH:mm:ss}',NULL,NULL,NULL,NULL,N'CallTime',NULL,0,95,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'78cfb51d-532e-4a1d-a123-8cf8d3acca4a',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'StartTimeUTC',N'DateTimeUtc',N'StartTimeUTC',N'{0:dd.MM. HH:mm:ss}',NULL,NULL,NULL,NULL,N'StartTimeUTC',NULL,0,95,9,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'f8ab2090-b9fc-4842-bf99-8f32942f7526',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'Direction',N'Select',N'Direction',NULL,NULL,NULL,NULL,NULL,N'Direction',NULL,0,80,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'7f1dee4f-e552-4983-a9a4-a0a11339d2fe',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'Redirector',N'Select',N'Redirector',NULL,NULL,NULL,NULL,NULL,N'Redirector',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'bdf1b9a8-9a37-4647-83cb-bda8e24f2bb8',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'CallerNumber',N'Text',N'CallerNumber',NULL,NULL,NULL,NULL,NULL,N'CallerNumber',NULL,0,80,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'eb500b00-ed8f-4029-a760-fa4df36a4882',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'Number',N'Select',N'Number',NULL,NULL,NULL,NULL,NULL,N'Number',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'f28d0016-555e-4970-8ffc-ee8ab4825091',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'WorkPlaceName',N'Text',N'WorkPlaceName',NULL,NULL,NULL,NULL,NULL,N'WorkPlaceName',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'aace9b2d-9beb-48c7-b091-af1a1c8b3e07',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'CallId',N'Text',N'CallId',NULL,NULL,NULL,NULL,NULL,N'CallId',NULL,0,120,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'402d66e7-40ab-403c-a3ab-0cbed76af391',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'CallDuration',N'Duration',N'CallDuration',NULL,NULL,NULL,NULL,N'DurationHMMSS',N'CallDuration',NULL,0,60,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)


 END
GO


 /* ADMIN: Eventlog */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '8cac0b68-a27a-4388-ba71-7bf8b1de42d3'
DECLARE @DisplayName AS VARCHAR(150) = 'Eventlog'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
--WHERE (DataQueryId  = @DataQueryId ) -- Dotaz někde existuje pod jiným ID
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'Prohlížení Eventlogu',@QueryGroup,N'DatumCas  DESC',N'select
  * FROM $(FS_Custom).dbo.Eventlog',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'Time',N'DayTime',N'DatumCas',N'{0:dd.MM.yyyy HH:mm:ss}',NULL,NULL,NULL,NULL,N'DatumCas',NULL,0,110,20,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'Description',N'Text',N'Popis',NULL,NULL,NULL,NULL,NULL,N'Popis',NULL,0,600,30,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'Procedure',N'Text',N'Procedura',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,150,40,NULL,0)
  
 END
GO
/* Všechny zprávy e-mailové fronty */
DECLARE @DataQueryId AS UniqueIdentifier = '98e73265-c1e5-4a7c-938f-fd69ccee3439'

DECLARE @DisplayName AS VARCHAR(150) = 'Všechny zprávy e-mailové fronty'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(iCC).dbo.DataQuery WHERE DataQueryId = @DataQueryId)
 BEGIN
  INSERT [DataQuery] (DataQueryId, [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
VALUES(@DataQueryId, @DisplayName,NULL,@QueryGroup,N'TimeUtc DESC',N'SELECT distinct 
c.Description, @MeTeamName AS MujTym,m.MessageId, M.TimeUtc, M.MessageType, M.MessagePhase, M.Direction, M.RemoteAddress, 
M.FromField, M.ToField, M.ToCcField, M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,
M.ProjectId, M.GatewayId, M.AgentId, M.TeamName,
c.CompanyName as ICO_RC, M.LanguageId, P.DisplayName AS ProjectName, G.DisplayName AS GatewayName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName,
ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,
CAST(CASE WHEN MessageResult=''Active'' THEN 1 ELSE 0 END AS bit) AS IsActive,
CAST(CASE WHEN MessagePhase=''Draft'' OR MessagePhase=''Received'' THEN 1 ELSE 0 END AS bit) AS IsNew,
CAST(CASE WHEN (MessagePhase=''Read'' OR MessagePhase=''Received'') AND ReceivedSentTime<getdate() THEN 1 ELSE 0 END AS bit) AS IsLate,
CAST(CASE WHEN EXISTS(SELECT * From Attachment WHERE M.MessageId=Attachment.MessageId) THEN 1 ELSE 0 END AS bit) AS HasAttachment

FROM Message AS M 
LEFT JOIN Project AS P ON M.ProjectId=P.ProjectId
LEFT JOIN Gateway AS G ON M.GatewayId=G.GatewayId
LEFT JOIN Agent AS A ON M.AgentId=A.AgentId
LEFT JOIN Language AS L ON M.LanguageId=L.LanguageId
LEFT JOIN ScenarioResult AS SR WITH(NOLOCK) ON SR.MessageId=M.MessageId
LEFT JOIN Contact as C with (NOLOCK) on c.Contactid=m.ContactId
WHERE (MessageType =''Email'' AND M.AGENTID IS NULL AND M.DIRECTION =''I'' AND MessagePhase <> ''Canceled'' and @SubjectField=''##FullText##'' and @FromField=''##FullText##'' and @ToField=''##FullText##'' and @BodyField=''##FullText##'')and (m.spamlevel is null or m.spamlevel = 0) and m.messageResult<>''Closed'' AND ((@MeTeamName<>''ENERGY'' AND M.GatewayId<>''1FC446C7-038F-446C-881A-F96C15B4D348'') OR (@MeTeamName=''ENERGY'' AND M.GatewayId=''1FC446C7-038F-446C-881A-F96C15B4D348''))
',0,NULL,NULL,NULL,0)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Výběr',N'Toggle',N'MessageId',NULL,NULL,N'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,30,1,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Typ',N'Image',N'MessageType',N'~/CustomImages/{0}.png',N'MessageId',N'~/Pages/Messages/DispFormPlus.aspx?Id={0}',NULL,N'MessageType',N'MessageType',NULL,0,25,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Nový editor',N'Image',N'MessageType',N'~/CustomImages/{0}.png',N'MessageId',N'/ReactClient/Pages/MessageEditor.html?Id={0}',NULL,N'MessageType',N'MessageType',NULL,0,25,6,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Směr',N'Image',N'Direction',N'~/CustomImages/Dir-{0}.png',NULL,NULL,NULL,N'MessageDirection',N'Direction',NULL,0,25,7,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Příl.',N'Image',N'HasAttachment',N'~/CustomImages/Att-{0}.png',NULL,NULL,NULL,N'Bool',N'HasAttachment',NULL,0,25,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Čas',N'DateTimeFromTo',N'MessageTime',N'{0:dd.MM HH.mm}',NULL,NULL,NULL,NULL,N'MessageTime',NULL,0,60,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Od',N'FullText',N'FromField',NULL,NULL,NULL,N'FromField',NULL,N'FromField',NULL,0,120,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Předmět',N'HyperFullText',N'SubjectField',NULL,N'MessageId',N'~/Pages/Messages/DispFormPlus.aspx?Id={0}',N'SubjectField',NULL,N'SubjectField',NULL,0,220,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Komu',N'FullText',N'ToField',NULL,NULL,NULL,N'ToField',NULL,N'ToField',NULL,0,100,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Stav',N'Select',N'MessagePhase',NULL,NULL,NULL,NULL,N'MessagePhase',N'MessagePhase',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Agent',N'Text',N'AgentName',NULL,NULL,NULL,N'AgentId',N'AgentName',N'AgentName',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Tým',N'Text',N'TeamName',NULL,NULL,NULL,NULL,NULL,N'TeamName',NULL,0,80,61,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Projekt',N'ForeignKey',N'ProjectName',NULL,NULL,NULL,N'ProjectId',N'ProjectName',N'ProjectName',NULL,0,100,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Text zprávy',N'FullText',N'BodyField',NULL,NULL,NULL,N'M.*',NULL,N'BodyField',NULL,0,140,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Kopie',N'Text',N'ToCcField',NULL,NULL,NULL,NULL,NULL,N'ToCcField',NULL,0,80,85,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Nová zpráva',N'Bold',N'IsNew',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,91,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Stará 1D',N'Color',N'IsLate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,N'#FFE9D1',0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Aktivní',N'Color',N'IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,93,N'#CCFADF',0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'TimeUtc',N'DateTimeUtc',N'TimeUtc',N'{0:dd.MM. HH:mm}',NULL,NULL,NULL,NULL,N'TimeUtc',NULL,0,60,103,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Adresa',N'Text',N'RemoteAddress',NULL,NULL,NULL,NULL,NULL,N'RemoteAddress',NULL,0,80,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Brána',N'ForeignKey',N'GatewayName',NULL,NULL,NULL,N'GatewayId',N'GatewayName',N'GatewayName',NULL,0,80,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Jazyk',N'ForeignKey',N'LanguageName',NULL,NULL,NULL,N'LanguageId',N'LanguageName',N'LanguageName',NULL,0,60,165,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'Description',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,80,175,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'MujTym',N'Text',N'MujTym',NULL,NULL,NULL,NULL,NULL,N'MujTym',NULL,0,80,185,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@DataQueryId,N'ICO_RC',N'Text',N'ICO_RC',NULL,NULL,NULL,NULL,NULL,N'ICO_RC',NULL,0,80,195,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)

 END
GO

  /* Admin: VolniAgentiProMail */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'e67f9717-e912-4f37-8c81-ead7c65c7800'
DECLARE @DisplayName AS VARCHAR(150) = 'VolniAgentiProMail'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM $(iCC)dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(iCC)dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(iCC).dbo.DataQuery WHERE DataQueryId = @DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'Admin',@QueryGroup,N'AgentName',N'select
    * FROM $(FS_Custom).dbo.VolniAgentiEmail()',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Volný Agent',N'Select',N'VolnyAgent',NULL,NULL,NULL,NULL,NULL,N'VolnyAgent',NULL,0,80,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'AgentName',N'Select',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,160,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ProjectName',N'Select',N'ProjectName',NULL,NULL,NULL,NULL,NULL,N'ProjectName',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Statusagenta',N'Select',N'Statusagenta',NULL,NULL,NULL,NULL,NULL,N'Statusagenta',NULL,0,80,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'EmailCount',N'Integer',N'EmailCount',NULL,NULL,NULL,NULL,NULL,N'EmailCount',NULL,0,60,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'MaxEmailCount',N'Integer',N'MaxEmailCount',NULL,NULL,NULL,NULL,NULL,N'MaxEmailCount',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'EmailPovolen-Stav',N'Select',N'EmailPovolenStav',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,150,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'EmailPovolen-Pracoviště',N'Select',N'EmailPovolenPracov',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,150,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Znalost Jazyka',N'Select',N'ZnalostJazyka',NULL,NULL,NULL,NULL,NULL,N'ZnalostJazyka',NULL,0,80,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO
  /* Admin: Přiřazené zprávy agentům */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'f2e2995f-40ad-4fdc-a3ee-27716a48a96b'
DECLARE @DisplayName AS VARCHAR(150) = 'Přiřazené zprávy agentům'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(iCC).dbo.DataQuery WHERE DataQueryId = @DataQueryId)

 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'TimeUtc DESC',N'SELECT distinct 
      c.Description, m.MessageId, M.TimeUtc, M.MessageType, M.MessagePhase, M.Direction, M.RemoteAddress, 
      M.FromField, M.ToField, M.ToCcField, M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,
      M.ProjectId, M.GatewayId, M.AgentId, M.TeamName,
      c.CompanyName as ICO_RC, M.LanguageId, P.DisplayName AS ProjectName, G.DisplayName AS GatewayName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName,
      ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,
      CAST(CASE WHEN MessageResult=''Active'' THEN 1 ELSE 0 END AS bit) AS IsActive,
      CAST(CASE WHEN MessagePhase=''Draft'' OR MessagePhase=''Received'' THEN 1 ELSE 0 END AS bit) AS IsNew,
      CAST(CASE WHEN (MessagePhase=''Read'' OR MessagePhase=''Received'') AND ReceivedSentTime<getdate() THEN 1 ELSE 0 END AS bit) AS IsLate,
      CAST(CASE WHEN EXISTS(SELECT * From Attachment WHERE M.MessageId=Attachment.MessageId) THEN 1 ELSE 0 END AS bit) AS HasAttachment,
      (SELECT TOP 1 TimeLocal FROM MessageEvent ME with (NOLOCK) WHERE M.MessageId=ME.MessageId AND ME.EventType=''Assigned'' ORDER BY TimeLocal DESC) AS CasPrirazeni,
      (SELECT TOP 1 ResultData FROM MessageEvent ME with (NOLOCK) WHERE M.MessageId=ME.MessageId AND ME.EventType=''Assigned'' ORDER BY TimeLocal DESC) AS ResultData
      FROM Message AS M 
      LEFT JOIN Project AS P ON M.ProjectId=P.ProjectId
      LEFT JOIN Gateway AS G ON M.GatewayId=G.GatewayId
      LEFT JOIN Agent AS A ON M.AgentId=A.AgentId
      LEFT JOIN Language AS L ON M.LanguageId=L.LanguageId
      LEFT JOIN Contact as C with (NOLOCK) on c.Contactid=m.ContactId
      --LEFT JOIN MessageEvent as ME with (NOLOCK) on M.MessageId=ME.MessageId AND ME.EventType=''Assigned''
      
      WHERE (MessageType IN (''Email'',''SMS'') AND M.AGENTID IS NOT NULL AND MessageResult=''Active'' AND M.Direction=''I'' 
       ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Výběr',N'Toggle',N'MessageId',NULL,NULL,N'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,30,1,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Typ',N'Image',N'MessageType',N'~/CustomImages/{0}.png',N'MessageId',N'~/Pages/Messages/DispFormPlus.aspx?Id={0}',NULL,N'MessageType',N'MessageType',NULL,0,25,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Nový editor',N'Image',N'MessageType',N'~/CustomImages/{0}.png',N'MessageId',N'/ReactClient/Pages/MessageEditor.html?Id={0}',NULL,N'MessageType',N'MessageType',NULL,0,25,6,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Směr',N'Image',N'Direction',N'~/CustomImages/Dir-{0}.png',N'MessageId',N'/ReactClient/Pages/MessageEditor.html?Id={0}',NULL,N'MessageDirection',N'Direction',NULL,0,25,7,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Příl.',N'Image',N'HasAttachment',N'~/CustomImages/Att-{0}.png',NULL,NULL,NULL,N'Bool',N'HasAttachment',NULL,0,25,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Čas',N'DateTimeFromTo',N'MessageTime',N'{0:dd.MM HH.mm}',NULL,NULL,NULL,NULL,N'MessageTime',NULL,0,60,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Od',N'FullText',N'FromField',NULL,NULL,NULL,N'FromField',NULL,N'FromField',NULL,0,120,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Předmět',N'HyperFullText',N'SubjectField',NULL,N'MessageId',N'~/Pages/Messages/DispFormPlus.aspx?Id={0}',N'SubjectField',NULL,N'SubjectField',NULL,0,220,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Komu',N'FullText',N'ToField',NULL,NULL,NULL,N'ToField',NULL,N'ToField',NULL,0,100,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stav',N'Select',N'MessagePhase',NULL,NULL,NULL,NULL,N'MessagePhase',N'MessagePhase',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Agent',N'Select',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Tým',N'Text',N'TeamName',NULL,NULL,NULL,NULL,NULL,N'TeamName',NULL,0,80,61,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Projekt',N'ForeignKey',N'ProjectName',NULL,NULL,NULL,N'ProjectId',N'ProjectName',N'ProjectName',NULL,0,100,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Text zprávy',N'FullText',N'BodyField',NULL,NULL,NULL,N'M.*',NULL,N'BodyField',NULL,0,140,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Kopie',N'Text',N'ToCcField',NULL,NULL,NULL,NULL,NULL,N'ToCcField',NULL,0,80,85,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Nová zpráva',N'Bold',N'IsNew',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,91,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stará 1D',N'Color',N'IsLate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,N'#FFE9D1',0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Aktivní',N'Color',N'IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,93,N'#CCFADF',0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeUtc',N'DateTimeUtc',N'TimeUtc',N'{0:dd.MM. HH:mm}',NULL,NULL,NULL,NULL,N'TimeUtc',NULL,0,60,103,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Adresa',N'Text',N'RemoteAddress',NULL,NULL,NULL,NULL,NULL,N'RemoteAddress',NULL,0,80,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Brána',N'ForeignKey',N'GatewayName',NULL,NULL,NULL,N'GatewayId',N'GatewayName',N'GatewayName',NULL,0,80,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Jazyk',N'ForeignKey',N'LanguageName',NULL,NULL,NULL,N'LanguageId',N'LanguageName',N'LanguageName',NULL,0,60,165,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Description',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,80,175,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ICO_RC',N'Text',N'ICO_RC',NULL,NULL,NULL,NULL,NULL,N'ICO_RC',NULL,0,80,195,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Čas přiřazení',N'DateTimeFromTo',N'CasPrirazeni',N'{0:dd.MM. HH:mm:ss}',NULL,NULL,NULL,NULL,N'CasPrirazeni',NULL,0,60,205,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ResultData',N'Text',N'ResultData',NULL,NULL,NULL,NULL,NULL,N'ResultData',NULL,0,80,215,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO

  /* Admin: Výsledky akcí */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '4c9e5e61-f17a-4ce1-9bb4-441c8ad8f83e'
DECLARE @DisplayName AS VARCHAR(150) = 'Výsledky akcí'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM $(iCC)dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(iCC)dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'Message',N'SELECT * FROM $(FS_Custom).dbo.Results -- WHERE AgentId=@MEAgentId 
  ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@DataQueryId,N'TimeLocal',N'DateTimeFromTo',N'TimeLocal',N'{0:dd.MM. HH:mm}',NULL,NULL,NULL,NULL,N'TimeLocal',NULL,0,80,5,NULL,0,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@DataQueryId,N'Výsledek',N'Text',N'Message',NULL,NULL,NULL,NULL,NULL,N'Message',NULL,0,500,10,NULL,0,NULL)
  
 END
 GO
  /* Admin: Gateways Monitor */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '4eff4b79-581e-41df-a62a-ceaee89ad0f5'
DECLARE @DisplayName AS VARCHAR(150) = 'Gateways Monitor'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'GateWayName',N'SELECT 
    Phase2.GatewayId
    ,ISNULL(GW.DisplayName,''BEZ BRÁNY'') AS GateWayName
    ,PilotAddress
    ,Received
    ,Sent
    ,[Channel]
    ,[Direction]
    , InDevice
    , OutDevice
    ,CAST(IIF((Received>0 AND Sent>0) OR (Received>0 AND [Direction]=''I'')  OR (Sent>0 AND [Direction]=''O''),1,0) AS bit) AS isOK
  
  FROM
  (SELECT 
      GatewayId
      ,SUM(Received) AS Received
      ,SUM(Sent) AS Sent
    FROM 
  (SELECT       
  	  GatewayId
        ,SUM(IIF(Direction=''I'',1,0)) AS Received
  	  ,SUM(IIF(Direction=''O'' AND MessagePhase=''Sent'',1,0)) AS Sent
       -- ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId=GW.GateWayId AND TimeUTC>@from AND Direction=''O'' AND MessagePhase=''Sent'') AS OdeslanychZprav
     FROM .[dbo].[Message] ME
    WHERE TimeUTC > DATEADD(Hour,-3,@Now)
    GROUP BY GatewayId
    UNION
    SELECT
  	  GatewayId
        ,0 AS Received
  	  ,0 AS Sent
       -- ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId=GW.GateWayId AND TimeUTC>@from AND Direction=''O'' AND MessagePhase=''Sent'') AS OdeslanychZprav
     FROM .[dbo].[Gateway] GW WHERE Deleted=0
    ) AS Phase1
    GROUP BY GatewayId
    ) AS Phase2
      LEFT JOIN .[dbo].[Gateway] GW ON GW.GatewayId=Phase2.GatewayId
   
  ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'GatewayId',N'Text',N'GatewayId',NULL,NULL,NULL,NULL,NULL,N'GatewayId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'GateWayName',N'Text',N'GateWayName',NULL,NULL,NULL,NULL,NULL,N'GateWayName',NULL,0,130,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'PilotAddress',N'Text',N'PilotAddress',NULL,NULL,NULL,NULL,NULL,N'PilotAddress',NULL,0,120,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Direction',N'Select',N'Direction',NULL,NULL,NULL,NULL,NULL,N'Direction',NULL,0,50,25,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Received',N'Integer',N'Received',NULL,NULL,NULL,NULL,NULL,N'Received',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Sent',N'Integer',N'Sent',NULL,NULL,NULL,NULL,NULL,N'Sent',NULL,0,60,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Channel',N'Select',N'Channel',NULL,NULL,NULL,NULL,NULL,N'Channel',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'InDevice',N'Text',N'InDevice',NULL,NULL,NULL,NULL,NULL,N'InDevice',NULL,0,400,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'OutDevice',N'Text',N'OutDevice',NULL,NULL,NULL,NULL,NULL,N'OutDevice',NULL,0,400,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'isOK',N'Color',N'isOK',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,80,NULL,0,NULL,N'success',NULL,NULL,NULL,NULL)
  
 END
GO
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '288c691e-7ad8-4de0-8dbc-972abfd05ef6'
DECLARE @DisplayName AS VARCHAR(150) = 'Volní agenti'
DECLARE @QueryGroup AS VARCHAR(50) = 'Supervizor'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'AgentName',N'SELECT  
         A.DisplayName AS AgentName
         , P.DisplayName AS ProjectName 
         FROM Agent A  WITH (NOLOCK)   
          LEFT OUTER JOIN Skill  WITH (NOLOCK)
    ON Skill.AgentId=A.AgentId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1
          LEFT OUTER JOIN Project P  WITH (NOLOCK)
     ON P.ProjectId=Skill.ProjectId AND P.Deleted=0
         WHERE A.AgentId=Skill.AgentId 
  	   --AND A.Activity=''Ready''
  	   -- AND (SELECT Activity FROM Status WHERE Status.StatusId=A.StatusId)=''Ready''
           AND (SELECT State FROM WorkPlace AS W WHERE A.WorkplaceId = W.WorkplaceId)=''Free''
  		 AND  P.DisplayName IS NOT NULL
    ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@DataQueryId,N'AgentName',N'Text',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,120,10,NULL,0,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@DataQueryId,N'ProjectName - dovednost',N'Text',N'ProjectName',NULL,NULL,NULL,NULL,NULL,N'ProjectName',NULL,0,140,20,NULL,0,NULL)
  
 END
GO

/* Supervizor: Volní agenti seznam */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'c593a564-8a5f-48dd-a22a-f2a06ea51084'
DECLARE @DisplayName AS VARCHAR(150) = 'Volní agenti seznam'
DECLARE @QueryGroup AS VARCHAR(50) = 'Supervizor'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN

INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'c593a564-8a5f-48dd-a22a-f2a06ea51084',N'Volní agenti seznam',NULL,N'Supervizor',N'AgentName',N'	SELECT  DISTINCT
       A.DisplayName AS AgentName
	   , ST.Activity AS STActivity
	   , WP.State AS WPStatus
       FROM Agent A  WITH (NOLOCK)   
        LEFT OUTER JOIN Skill  WITH (NOLOCK)
   ON Skill.AgentId=A.AgentId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1
        LEFT OUTER JOIN Project P  WITH (NOLOCK)
   ON P.ProjectId=Skill.ProjectId
       LEFT OUTER JOIN Workplace WP  WITH (NOLOCK)
   ON WP.WorkplaceId=A.WorkplaceId
      LEFT OUTER JOIN Status ST  WITH (NOLOCK)
   ON ST.StatusId=A.StatusId
       WHERE 1=1
	   AND A.Activity=''Ready'' 
	   AND A.AgentId=Skill.AgentId 
	   AND A.WorkplaceId IS NOT NULL  
  ',0,NULL,NULL,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'00b0ebbf-2d69-4976-b210-661e4d62e467',N'c593a564-8a5f-48dd-a22a-f2a06ea51084',N'AgentName',N'Text',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,120,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'cd356662-f809-436f-9b5a-a292473518d7',N'c593a564-8a5f-48dd-a22a-f2a06ea51084',N'Stat.Activity',N'Select',N'STActivity',NULL,NULL,NULL,NULL,NULL,N'STActivity',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'ad617413-5ebb-4011-99c4-4dffe37a9ba3',N'c593a564-8a5f-48dd-a22a-f2a06ea51084',N'WP.Status',N'Select',N'WPStatus',NULL,NULL,NULL,NULL,NULL,N'WPStatus',NULL,0,80,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
 END
GO
  /* Supervizor: vysetrovani­ fronty */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '2bd46080-ce8d-4c10-8b4d-3772417f57d8'
DECLARE @DisplayName AS VARCHAR(150) = 'Calls Queue investigation'
DECLARE @QueryGroup AS VARCHAR(50) = 'Supervizor'
--IF EXISTS(SELECT Top 1 DataQueryId FROM $(ICC).dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím požádat o nové iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(ICC).dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'Investigation',@QueryGroup,N'RegionalTime',N'SELECT DISTINCT InboundCallId
        ,RegionalTime
        , CallerNumber
         ,QueueDuration
         ,PilotName      
       ,P.DisplayName AS ProjectName
   , Agent.DisplayName AS AgentName
   FROM
  (SELECT InboundCallId
         ,RegionalTime
         ,QueueDuration
         ,Pil.DisplayName AS PilotName
         ,CallerNumber
        ,CallType
        ,CallPhase
        ,CallResult
        ,ProjectId
        ,Skill
        ,PreferredAgentId
        ,AgentId
        ,TeamName
        ,IC.LanguageId
    FROM $(ICC).dbo.InboundCall IC WITH (NOLOCK)
    LEFT JOIN Pilot Pil  WITH (NOLOCK)
  ON Pil.PilotId=IC.PilotId
    WHERE IC.CallPhase IN (''WaitingQueue'') AND CallResult=''Active'')  Fronta 
   LEFT OUTER JOIN Skill  WITH (NOLOCK)
   ON Skill.ProjectId=Fronta.ProjectId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1
       LEFT OUTER JOIN Project P  WITH (NOLOCK)
  ON P.ProjectId=Fronta.ProjectId
       LEFT OUTER JOIN Agent  WITH (NOLOCK)
  ON Agent.AgentId=Skill.AgentId AND Agent.Activity=''Ready'' AND (SELECT Activity FROM Status WHERE Status.StatusId=Agent.StatusId)=''Ready''
                   AND (SELECT State FROM WorkPlace AS W WHERE Agent.WorkplaceId = W.WorkplaceId)=''Free'' 
       LEFT JOIN Proficiency AS PROF  WITH (NOLOCK)
  ON PROF.AgentId=Agent.AgentId AND PROF.LanguageId=FRONTA.LanguageId AND PROF.VoiceKnowledge>0 AND PROF.VoiceEnabled=1 AND PROF.VoiceChannel=1
  ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'InboundCallId',N'Text',N'InboundCallId',NULL,NULL,NULL,NULL,NULL,N'InboundCallId',NULL,0,220,5,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'RegionalTime',N'DateTimeFromTo',N'RegionalTime',N'{0:dd.MM. HH:mm}',NULL,NULL,NULL,NULL,N'RegionalTime',NULL,0,90,10,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'PilotName',N'Text',N'PilotName',NULL,NULL,NULL,NULL,NULL,N'PilotName',NULL,0,120,15,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'CallerNumber',N'Text',N'CallerNumber',NULL,NULL,NULL,NULL,NULL,N'CallerNumber',NULL,0,110,20,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'QueueDuration',N'Duration',N'QueueDuration',NULL,NULL,NULL,NULL,NULL,N'QueueDuration',NULL,0,60,25,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'ProjectName',N'Text',N'ProjectName',NULL,NULL,NULL,NULL,NULL,N'ProjectName',NULL,0,80,30,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
    VALUES (@DataQueryId,N'AgentName',N'Text',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,120,40,NULL,0)
  
 END
GO
  /* Admin: Všechny pøíchozí hovory */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '99cecf13-c463-4abd-a52e-ad923d51ac7c'
DECLARE @DisplayName AS VARCHAR(150) = 'Všechny pøíchozí hovory'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'TimeUtc DESC',N'SELECT
  1 AS Akce, 
  C.InboundCallId, C.TimeUtc, C.CallPhase, C.CallResult, C.CallerNumber, C.IssueId,
  C.ProjectId, C.LanguageId, C.AgentId, C.WorkplaceId,
  C.CallDuration, C.PilotTime, PIL.DisplayName AS PilotName, C.ChainingId,
  P.DisplayName AS ProjectName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName, W.DisplayName AS WorkplaceName,
  CAST(CASE WHEN CallResult=''Active'' THEN 1 ELSE 0 END AS bit) AS IsActive,
  CAST(CASE WHEN CallResult=''Lost'' THEN 1 ELSE 0 END AS bit) AS IsLost,
  S.DisplayName as Afterwork,
  --X.agreementid as Smlouva,
  --X.Notice as Poznamka,
  --CAST(CASE WHEN X.Souhlas=''1'' THEN ''Ano'' ELSE ''Ne'' END AS nvarchar(3)) as Souhlas,
  T.DisplayName as Téma, S.DisplayName as Podtéma
  ,Redirector
  ,CASE WHEN CR.InboundCallId IS NULL THEN ''NE'' ELSE ''ANO'' END AS ExNahravka
  FROM InboundCall AS C  WITH (NOLOCK)
  LEFT JOIN Project AS P WITH (NOLOCK) ON C.ProjectId=P.ProjectId
  LEFT JOIN Agent AS A WITH (NOLOCK)ON C.AgentId=A.AgentId
  LEFT JOIN Language AS L WITH (NOLOCK) ON C.LanguageId=L.LanguageId
  LEFT JOIN Workplace AS W WITH (NOLOCK) ON C.WorkplaceId=W.WorkplaceId
  LEFT JOIN Issue AS I WITH (NOLOCK) ON C.IssueId=I.IssueId
  --LEFT JOIN IssueExtra AS X ON C.IssueId=X.IssueId
  LEFT JOIN Topic AS T WITH (NOLOCK) ON T.TopicId=I.TopicId
  LEFT JOIN SubTopic AS S WITH (NOLOCK) ON S.SubTopicId=I.SubTopicId
  LEFT JOIN Pilot AS PIL WITH (NOLOCK) ON PIL.PilotId=C.PilotId
  LEFT JOIN CallRecord AS CR WITH (NOLOCK) ON CR.InboundCallId=C.InboundCallId
  ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Akce',N'ImageScript',N'Akce',N'~/CustomImages/{0}.png',N'InboundCallId',NULL,NULL,NULL,N'Akce',NULL,0,30,2,NULL,0,N'exec $(FS_Custom).dbo.AktVazbu @Id,''InboundCallId'',''Test''',NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'InboundCallId',N'Text',N'InboundCallId',NULL,NULL,NULL,NULL,NULL,N'InboundCallId',NULL,0,230,3,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stav',N'Image',N'CallResult',N'~/CustomImages/CallResult-I-{0}.png',N'InboundCallId',N'/ReactClient/Pages/calleditor.html?Id={0}',NULL,N'InboundCallResult',N'CallResult',NULL,0,25,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Èas',N'DateTimeFromTo',N'PilotTime',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'PilotTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'PilotName',N'Text',N'PilotName',NULL,NULL,NULL,NULL,NULL,N'PilotName',NULL,0,65,15,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Redirector',N'Text',N'Redirector',NULL,NULL,NULL,NULL,NULL,N'Redirector',NULL,0,50,18,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Telefon',N'HyperLink',N'CallerNumber',NULL,N'InboundCallId',N'/ReactClient/Pages/calleditor.html?Id={0}',NULL,NULL,N'CallerNumber',NULL,0,80,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Fáze',N'Image',N'CallPhase',N'~/CustomImages/CallPhase-I-{0}.png',NULL,NULL,NULL,N'InboundCallPhase',N'CallPhase',NULL,0,25,21,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IssueId',N'Text',N'IssueId',NULL,NULL,NULL,NULL,NULL,N'IssueId',NULL,0,230,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Projekt',N'ForeignKey',N'ProjectName',NULL,NULL,NULL,N'ProjectId',N'ProjectName',N'ProjectName',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Jazyk',N'ForeignKey',N'LanguageName',NULL,NULL,NULL,N'LanguageId',N'LanguageName',N'LanguageName',NULL,0,35,41,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Agent',N'Text',N'AgentName',NULL,NULL,NULL,NULL,N'AgentName',N'AgentName',NULL,0,120,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Pracovištì',N'ForeignKey',N'WorkplaceName',NULL,NULL,NULL,N'WorkplaceId',N'WorkplaceName',N'WorkplaceName',NULL,0,62,61,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Trvání',N'Duration',N'CallDuration',NULL,NULL,NULL,NULL,N'DurationMSS',N'CallDuration',NULL,0,50,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Ztracený',N'Color',N'IsLost',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,91,N'#FFE9D1',0,NULL,N'warning',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Aktivní',N'Color',N'IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,N'#CCFADF',0,NULL,N'success',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeUtc',N'DateTimeUtc',N'TimeUtc',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeUtc',NULL,0,100,102,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Afterwork',N'Text',N'Afterwork',NULL,NULL,NULL,NULL,NULL,N'Afterwork',NULL,0,80,122,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Téma',N'Text',N'Téma',NULL,NULL,NULL,NULL,NULL,N'Téma',NULL,0,80,152,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Podtéma',N'Text',N'Podtéma',NULL,NULL,NULL,NULL,NULL,N'Podtéma',NULL,0,80,162,NULL,0,NULL,NULL,500,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ExNahravka',N'Text',N'ExNahravka',NULL,NULL,NULL,NULL,NULL,N'ExNahravka',NULL,0,60,172,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO
  /* Admin: Události pøíchozího hovoru */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '882362dc-f36f-4248-ad4d-64d1a883e91a'
DECLARE @DisplayName AS VARCHAR(150) = 'Události pøíchozího hovoru'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'TimeLocal',N'SELECT 
           InboundCallId
          , TimeLocal
          , EventType 
          , IVRST.Rank AS Navesti
          , IVRST.Action AS Akce
          , IVRST.DisplayName AS Ivrkrok
          , IVRST.FileName AS Hlaska
          , IVRSC.DisplayName AS IvrSkript
          , PR.DisplayName AS ProjectName 
          , AG.DisplayName AS AgentName 
          , WP.DisplayName AS WorkPlaceName 
          , ReferenceData 
          , Duration 
          , ResultData 
      FROM  .dbo.CallEvent  AS CAE
       LEFT JOIN IvrStep AS IVRST ON IVRST.IvrStepId=CAE.ReferenceId
       LEFT JOIN IvrScript AS IVRSC ON IVRST.IvrScriptId=IVRSC.IvrScriptId
       LEFT JOIN Project AS PR ON PR.ProjectId=CAE.ProjectId
  	 LEFT JOIN Agent AS AG ON AG.AgentId=CAE.AgentId
  	 LEFT JOIN Workplace AS WP ON WP.WorkPlaceId=CAE.WorkPlaceId
    ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'InboundCallId',N'Text',N'InboundCallId',NULL,NULL,NULL,NULL,NULL,N'InboundCallId',NULL,0,230,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeLocal',N'DateTimeFromTo',N'TimeLocal',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeLocal',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'EventType',N'Text',N'EventType',NULL,NULL,NULL,NULL,NULL,N'EventType',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Navesti',N'Integer',N'Navesti',NULL,NULL,NULL,NULL,NULL,N'Navesti',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Akce',N'Text',N'Akce',NULL,NULL,NULL,NULL,NULL,N'Akce',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'AgentName',N'Text',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,80,41,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'WorkPlaceName',N'Text',N'WorkPlaceName',NULL,NULL,NULL,NULL,NULL,N'WorkPlaceName',NULL,0,80,42,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ProjectName',N'Text',N'ProjectName',NULL,NULL,NULL,NULL,NULL,N'ProjectName',NULL,0,120,44,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IvrSkript',N'Text',N'IvrSkript',NULL,NULL,NULL,NULL,NULL,N'IvrSkript',NULL,0,140,45,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Ivrkrok',N'Text',N'Ivrkrok',NULL,NULL,NULL,NULL,NULL,N'Ivrkrok',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Hlaska',N'Text',N'Hlaska',NULL,NULL,NULL,NULL,NULL,N'Hlaska',NULL,0,160,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ReferenceData',N'Text',N'ReferenceData',NULL,NULL,NULL,NULL,NULL,N'ReferenceData',NULL,0,80,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Duration',N'Duration',N'Duration',NULL,NULL,NULL,NULL,NULL,N'Duration',NULL,0,60,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ResultData',N'Text',N'ResultData',NULL,NULL,NULL,NULL,NULL,N'ResultData',NULL,0,200,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO
  /* Admin: Nahrávky */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '68df515a-31d7-4137-b661-9ce2c40a601a'
DECLARE @DisplayName AS VARCHAR(150) = 'Recordings'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'TimeUTC DESC',N'SELECT [VoiceRecordId]
        ,[TimeUtc]
        ,[StartTimeUtc]
        ,[EndTimeUtc]
        ,DATEDIFF(ss,StartTimeUtc,EndTimeUtc) AS Duration
        ,IIF(AgentName IS NULL,''NE'',''ANO'') AS Sparovano
        ,[FileName]
        ,[Direction]
        ,[LocalNumber]
        ,[LocalName]
        ,[RemoteNumber]
        ,[RemoteName]
        ,[ExtensionNumber]
         ,[AgentName]
        ,[StationName]
     FROM [SRec].[dbo].[VoiceRecord]',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'VoiceRecordId',N'Text',N'VoiceRecordId',NULL,NULL,NULL,NULL,NULL,N'VoiceRecordId',NULL,0,230,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Smìr',N'Text',N'Direction',NULL,NULL,NULL,NULL,NULL,N'Direction',NULL,0,40,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Spárováno',N'Select',N'Sparovano',NULL,NULL,NULL,NULL,NULL,N'Sparovano',NULL,0,80,9,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeUtc',N'DateTimeUtc',N'TimeUtc',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeUtc',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'StartTimeUtc',N'DateTimeUtc',N'StartTimeUtc',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'StartTimeUtc',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'EndTimeUtc',N'DateTimeUtc',N'EndTimeUtc',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'EndTimeUtc',NULL,0,100,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Duration',N'Duration',N'Duration',NULL,NULL,NULL,NULL,N'DurationHMMSS',N'Duration',NULL,0,60,35,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'FileName',N'Text',N'FileName',NULL,NULL,NULL,NULL,NULL,N'FileName',NULL,0,300,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'LocalNumber',N'Text',N'LocalNumber',NULL,NULL,NULL,NULL,NULL,N'LocalNumber',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'LocalName',N'Text',N'LocalName',NULL,NULL,NULL,NULL,NULL,N'LocalName',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'RemoteNumber',N'Text',N'RemoteNumber',NULL,NULL,NULL,NULL,NULL,N'RemoteNumber',NULL,0,90,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'RemoteName',N'Text',N'RemoteName',NULL,NULL,NULL,NULL,NULL,N'RemoteName',NULL,0,80,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ExtensionNumber',N'Text',N'ExtensionNumber',NULL,NULL,NULL,NULL,NULL,N'ExtensionNumber',NULL,0,80,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'AgentName',N'Text',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,200,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'StationName',N'Text',N'StationName',NULL,NULL,NULL,NULL,NULL,N'StationName',NULL,0,80,110,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO

  /* Admin: Všechny odchozí hovory */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '1c26d83f-642e-4ef7-b31e-e7d5ec74e804'
DECLARE @DisplayName AS VARCHAR(150) = 'Všechny odchozí hovory'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'TimeUtc DESC',N'SELECT 
        C.OutboundCallId, C.RegionalTime, C.TimeUTC, C.RingDuration, C.CallPhase, C.CallResult, C.CallerNumber, 
        C.ProjectId, C.LanguageId, C.AgentId, C.WorkplaceId,
        C.CallDuration,C.DistributionTime, Trial AS Pokus,C.ScheduleTime,AnswerTime as CasUskutecneni,
        P.DisplayName AS ProjectName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName, W.DisplayName AS WorkplaceName,
        OL.DisplayName AS OutboundListName, C.endtime ,
        CAST(CASE WHEN CallResult=''Active'' THEN 1 ELSE 0 END AS bit) AS IsActive,
       IIF(Callduration>0,''ANO'',''NE'') AS BylHovor,
       IIF (EXISTS(SELECT TOP 1 1 FROM $(ICC).[dbo].[CallRecord] CR WHERE C.OutboundCallId=CR.OutboundCallId),''ANO'',''NE'') AS Sparovano
  ,IssueId
        FROM .dbo.OutboundCall AS C  WITH (NOLOCK)
        LEFT JOIN Project AS P ON C.ProjectId=P.ProjectId
        LEFT JOIN Agent AS A ON C.AgentId=A.AgentId
        LEFT JOIN Language AS L ON C.LanguageId=L.LanguageId
        LEFT JOIN Workplace AS W ON C.WorkplaceId=W.WorkplaceId
        LEFT JOIN OutboundList AS OL ON OL.OutboundListId = C.OutboundListId
        /*
          WHERE C.AgentId=''b9c54a15-1019-48ff-8cd8-8aa01f489fb9''
              AND DAY(AnswerTime)=12 AND MONTH(AnswerTime)=10 AND YEAR(AnswerTime)=2016 AND DATEPART(HOUR,AnswerTime)<10 */',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'OutBoundCallId',N'Text',N'OutBoundCallId',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,230,3,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Spárováno',N'Select',N'Sparovano',NULL,NULL,NULL,NULL,NULL,N'Sparovano',NULL,0,60,4,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'DistributionTime',N'DateTimeFromTo',N'DistributionTime',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'DistributionTime',NULL,0,100,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Byl hovor?',N'Select',N'BylHovor',NULL,NULL,NULL,NULL,NULL,N'BylHovor',NULL,0,60,6,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeUTC',N'DateTimeUtc',N'TimeUTC',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'RegionalTime',NULL,0,100,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stav',N'Image',N'CallResult',N'~/CustomImages/CallResult-O-{0}.png',N'OutboundCallId',N'~/Pages/calleditor.html?Id={0}',NULL,N'OutboundCallResult',N'CallResult',NULL,0,25,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Výsledek',N'Text',N'CallResult',NULL,N'OutboundCallId',N'/ReactClient/Pages/calleditor.html?Id={0}',NULL,N'OutboundCallResult',N'CallResult',NULL,1,60,15,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Èíslo',N'HyperLink',N'CallerNumber',NULL,N'OutboundCallId',N' /ReactClient/Pages/calleditor.html?Id={0}',NULL,NULL,N'CallerNumber',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Fáze',N'Image',N'CallPhase',N'~/CustomImages/CallPhase-O-{0}.png',NULL,NULL,NULL,N'OutboundCallPhase',N'CallPhase',NULL,0,25,21,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Kampaò',N'Text',N'OutboundListName',NULL,NULL,NULL,NULL,NULL,N'OutboundListName',NULL,0,60,31,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Projekt',N'ForeignKey',N'ProjectName',NULL,NULL,NULL,N'ProjectId',N'ProjectName',N'ProjectName',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Pokus',N'Integer',N'Pokus',NULL,NULL,NULL,NULL,NULL,N'Pokus',NULL,0,30,42,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Jazyk',N'ForeignKey',N'LanguageName',NULL,NULL,NULL,N'LanguageId',N'LanguageName',N'LanguageName',NULL,0,35,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IssueId',N'Text',N'IssueId',NULL,NULL,NULL,NULL,NULL,N'IssueId',NULL,0,230,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Agent',N'ForeignKey',N'AgentName',NULL,NULL,NULL,N'AgentId',N'AgentName',N'AgentName',NULL,0,120,140,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Pracovištì',N'ForeignKey',N'WorkplaceName',NULL,NULL,NULL,N'WorkplaceId',N'WorkplaceName',N'WorkplaceName',NULL,0,62,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Trvání',N'Duration',N'CallDuration',NULL,NULL,NULL,NULL,N'DurationMSS',N'CallDuration',NULL,0,50,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Aktivní',N'Color',N'IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,199,N'#CCFADF',0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Delka zvoneni',N'Duration',N'RingDuration',NULL,NULL,NULL,NULL,NULL,N'RingDuration',NULL,0,50,209,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Èas uskuteènìní',N'DateTimeFromTo',N'CasUskutecneni',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'CasUskutecneni',NULL,0,100,219,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Èas ukonèení',N'DateTimeFromTo',N'endtime',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'endtime',NULL,0,100,229,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'RegionalTime',N'DateTimeFromTo',N'RegionalTime',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'RegionalTime',NULL,0,100,239,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ScheduleTime',N'DateTimeFromTo',N'ScheduleTime',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'ScheduleTime',NULL,0,100,259,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO

  /* Admin: Události odchozího hovoru */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '354e10a1-14f7-4f66-b1aa-9b7ffee2b91f'
DECLARE @DisplayName AS VARCHAR(150) = 'Události odchozího hovoru'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'TimeLocal',N'SELECT 
             OutboundCallId
            , TimeLocal
            , EventType 
            , AG.DisplayName AS AgentName
            , AG2.DisplayName AS ActorName
            , ProjectId 
            , ReferenceData 
            , Duration 
            , ResultData 
        FROM  .dbo.CallEvent  AS CAE
         LEFT JOIN Agent AS AG ON AG.AgentId=CAE.AgentId
         LEFT JOIN Agent AS AG2 ON AG2.AgentId=CAE.ActorId
        
  ',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'OutboundCallId',N'Text',N'OutboundCallId',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,230,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'TimeLocal',N'DateTimeFromTo',N'TimeLocal',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeLocal',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'EventType',N'Text',N'EventType',NULL,NULL,NULL,NULL,NULL,N'EventType',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'AgentName',N'Text',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,100,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ActorName',N'Text',N'ActorName',NULL,NULL,NULL,NULL,NULL,N'ActorName',NULL,0,100,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ReferenceData',N'Text',N'ReferenceData',NULL,NULL,NULL,NULL,NULL,N'ReferenceData',NULL,0,80,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Duration',N'Duration',N'Duration',NULL,NULL,NULL,NULL,NULL,N'Duration',NULL,0,60,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'ResultData',N'Text',N'ResultData',NULL,NULL,NULL,NULL,NULL,N'ResultData',NULL,0,80,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO
  /* Admin: Pøehled agentù Admin */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'e61147d7-3aef-402c-b551-e9f8af55847e'
DECLARE @DisplayName AS VARCHAR(150) = 'Pøehled agentù Admin'
DECLARE @QueryGroup AS VARCHAR(50) = 'Admin'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'TeamName, AgentName',N' SELECT AG.AgentId ,AG.AgentId AS RecordId,ST.StatusId
            , ''1'' AS RESETPers
  		  , IIF(EXISTS(SELECT TOP 1 1 FROM ASPNET_iCC.dbo.aspnet_Users AU 
  		                 INNER JOIN [ASPNET_iCC].[dbo].[aspnet_PersonalizationPerUser] AP ON AU.UserId=AP.UserId WHERE AU.UserName=AG.SystemName
  		  ),''ANO'',''NE'') AS ExPerso
  
            , SystemName
      	,W.Number AS Extension
            ,IIF(AG.Activity=''Logoff'',''NE '',''ANO'') AS V_Praci
      	,AG.DisplayName AS AgentName, AG.TeamName
      --,(SELECT $(FS_Custom).dbo.GetFirstLogonTime(AG.AgentId, @Today)) AS FirstLogonTime
      	--,fs_custom.dbo.GetCurrentStateLength3(AG.AgentId, @Now) AS StateLength
      	,ST.DisplayName AS StatusName    
      	,W.State AS WorkplaceStatus
      	  	,CAST(CASE WHEN AG.Activity = ''Ready'' AND w.State = ''Free'' THEN 1 ELSE 0 END AS bit) AS IsFree	
      	,CAST(CASE WHEN AG.Activity = ''Pause'' THEN 1 ELSE 0 END AS bit) AS IsPause
      	,CAST(CASE WHEN w.State = ''Ring'' THEN 1 ELSE 0 END AS bit) AS IsRinging
      	,CAST(CASE WHEN w.State = ''Busy'' THEN 1 ELSE 0 END AS bit) AS IsBusy
      	,CAST(CASE WHEN AG.Activity = ''PostCall'' THEN 1 ELSE 0 END AS bit) AS IsPCP
       FROM .dbo.Agent AS AG  WITH(NOLOCK) 
      LEFT JOIN .dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
      LEFT JOIN .dbo.Status AS ST WITH(NOLOCK)  ON AG.StatusId=ST.StatusId
      WHERE AG.Deleted = 0 AND AG.Template=0 ',0,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'RESET Perzonalizace',N'ImageScript',N'RESETPers',N'~/CustomImages/{0}.png',N'RecordId',NULL,NULL,NULL,N'RESETPers',NULL,0,110,2,NULL,0,N'exec $(FS_Custom).dbo.DelPerso @Id ',NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Exist Perso',N'Text',N'ExPerso',NULL,NULL,NULL,NULL,NULL,N'ExPerso',NULL,0,65,3,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'AgentId',N'Text',N'AgentId',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,230,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'SystemName',N'Text',N'SystemName',NULL,NULL,NULL,NULL,NULL,N'SystemName',NULL,0,160,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'V práci',N'Select',N'V_Praci',NULL,NULL,NULL,NULL,NULL,N'V_Praci',NULL,0,80,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Poboèka',N'Text',N'Extension',NULL,NULL,NULL,NULL,NULL,N'Extension',NULL,0,45,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Jméno',N'HyperLink',N'AgentName',NULL,N'AgentId',N'/ReactClient/Pages/DataQueryPage.html?Id=73342443-45f0-4c26-aa6c-37335adb34a4&FilterName=AgentId&FilterValue={0}',NULL,NULL,N'AgentName',NULL,0,130,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Tým',N'Select',N'TeamName',NULL,NULL,NULL,NULL,NULL,N'TeamName',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Stav tel.',N'Select',N'WorkplaceStatus',NULL,NULL,NULL,NULL,N'WorkplaceState',N'WorkplaceStatus',NULL,0,70,120,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Aktivita op.',N'ForeignKey',N'StatusName',NULL,NULL,NULL,N'StatusId',NULL,N'StatusName',NULL,0,70,140,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsFree',N'Color',N'IsFree',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,220,N'#CCFADF ',0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsPause',N'Color',N'IsPause',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,239,N'#C0C0FF',0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsBusy',N'Color',N'IsBusy',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,249,N'#FFFFC9',0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsPCP',N'Color',N'IsPCP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,259,N'#FFBFBF',0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsRinging',N'Color',N'IsRinging',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,269,N'#FFC080',0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO

/*
IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Export vybraných modulů')
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
 VALUES (N'34047afb-6685-4587-9c8f-ab889675a20a', N'Export vybraných modulů', N'Slouží k údržbě katalogu', N'ADMIN', N'EXEC [$(FS_CUSTOM)].[dbo].[ExportModul] @RecordId', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO

IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Import vybraných modulů')
INSERT [dbo].[ActionTrigger] ( [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
 VALUES ( N'Import vybraných modulů', N'Slouží k instalaci komponent z katalogu', N'ADMIN', N'EXEC [$(FS_CUSTOM)].[dbo].[ImportModul] @RecordId,0', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
*/
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
@TableName NVARCHAR(50),
@WhereCond NVARCHAR(250)
AS
BEGIN
  DECLARE @OrigName AS NVARCHAR(100) = '$(Icc_Backup)..'+@TableName
  DECLARE @NewName AS NVARCHAR(100) = @TableName+'_old'
  --PRINT DB_NAME()
 	IF OBJECT_ID(N'$(Icc_Backup)..'+@TableName, N'U') IS NOT NULL -- Tabulka existuje
	  BEGIN
	    IF OBJECT_ID(N'$(Icc_Backup)..'+@TableName+'_old', N'U') IS NOT NULL -- Tabulka existuje 
		  EXEC('DROP TABLE $(Icc_Backup).dbo.'+@TableName+'_old')--DROP TABLE $(Icc_Backup).dbo.Agent_old
	    EXEC sp_rename @OrigName, @NewName
	  END
	 EXEC('select * into $(Icc_Backup).dbo.'+@TableName+' from $(ICC).dbo.'+@TableName+@WhereCond)-- select * into $(Icc_Backup).dbo.Agent from $(ICC).dbo.Agent

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
EXEC Icc_Backup.dbo.Backup_Table2 'ActionTrigger','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Agent',''
EXEC Icc_Backup.dbo.Backup_Table2 'Campaign',''
EXEC Icc_Backup.dbo.Backup_Table2 'Configuration',''
EXEC Icc_Backup.dbo.Backup_Table2 'DataQuery',''
EXEC Icc_Backup.dbo.Backup_Table2 'DataQueryColumn',''
EXEC Icc_Backup.dbo.Backup_Table2 'Editor',''
EXEC Icc_Backup.dbo.Backup_Table2 'EditorTab',''
EXEC Icc_Backup.dbo.Backup_Table2 'EditorTask','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Gateway','' 
EXEC Icc_Backup.dbo.Backup_Table2 'GatewayCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Holiday','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ChatGateway','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ChatGateCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ChatProjectCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ImrScript','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ImrStep','' 
EXEC Icc_Backup.dbo.Backup_Table2 'IssueCondition',''
EXEC Icc_Backup.dbo.Backup_Table2 'IvrEntry',''
EXEC Icc_Backup.dbo.Backup_Table2 'IvrScript',''
EXEC Icc_Backup.dbo.Backup_Table2 'IvrStep','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Language','' 
EXEC Icc_Backup.dbo.Backup_Table2 'LiteralLookup','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Message',' WHERE MessageType Like ''Tmp%'' AND MessageResult = ''Active''' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessagePostCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessagePreCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageProjectCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageScheduleCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'MessageWaitPostCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Navigation','' 
EXEC Icc_Backup.dbo.Backup_Table2 'OutboundList',''
EXEC Icc_Backup.dbo.Backup_Table2 'Permission',''
EXEC Icc_Backup.dbo.Backup_Table2 'Phase',''
EXEC Icc_Backup.dbo.Backup_Table2 'PhaseTransition',''
EXEC Icc_Backup.dbo.Backup_Table2 'PhoneBook','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Pilot','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Portal','' 
EXEC Icc_Backup.dbo.Backup_Table2 'PostCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'PreCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Predictor','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Proficiency','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Project','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ProjectCondition',''
EXEC Icc_Backup.dbo.Backup_Table2 'Queue',''
EXEC Icc_Backup.dbo.Backup_Table2 'Redirector',''
EXEC Icc_Backup.dbo.Backup_Table2 'Role','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Scenario','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScenarioCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Scope','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Screen','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScreenControl','' 
EXEC Icc_Backup.dbo.Backup_Table2 'ScreenControlParameter','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Seating','' 
EXEC Icc_Backup.dbo.Backup_Table2 'SchedulePostCondition',''
EXEC Icc_Backup.dbo.Backup_Table2 'Skill','' 
EXEC Icc_Backup.dbo.Backup_Table2 'Status',''
EXEC Icc_Backup.dbo.Backup_Table2 'SubTopic',''
EXEC Icc_Backup.dbo.Backup_Table2 'Topic','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WaitingQueue','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WaitPostCondition','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WebSiteTemplate',''
EXEC Icc_Backup.dbo.Backup_Table2 'Workflow','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WorkflowStep','' 
 BACKUP DATABASE Icc_Backup TO DISK = @BackupFile
END

GO

USE $(iCC)
GO
-------------------------  ADMIN OPTIMISE ---------------------------

DECLARE @Id AS UNIQUEIDENTIFIER --='22669630-84AA-49FC-9868-96DEE92E5B55'

SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Zprávy opomenuté' AND QueryGroup='Admin'
 AND QueryText LIKE '%ISNULL(M.SpamLevel,0)>0%' )
IF @Id IS NOT NULL
  BEGIN
   PRINT 'I repair condition in neglected messages'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'ISNULL(M.SpamLevel,0)>0','ISNULL(M.SpamLevel,0)=0')
     FROM .dbo.DataQuery DQ
  WHERE DataQueryId=@Id
  END

  
IF (SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE QueryGroup='Admin' AND QueryText LIKE '%''ANO''%' AND Deleted=0) IS NOT NULL 
  BEGIN
   PRINT 'I Translate QueryText'
   UPDATE DQ
     SET  QueryText = REPLACE(REPLACE(REPLACE(QueryText,'''ANO''','''YES'''),'''NE ''','''NO'''),'''NE''','''NO''')
     FROM .dbo.DataQuery DQ
	 WHERE QueryGroup='Admin'
  END
SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName IN ('Přehled agentů Admin','List of Agents') AND QueryGroup='Admin' AND QueryText NOT LIKE '%LastInCall%' AND Deleted=0)
IF @Id IS NOT NULL 
  BEGIN
   PRINT 'I add LastCalls into Admin agents'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'RESETPers','RESETPers
	 ,(SELECT TOP 1 PilotTime FROM .[dbo].InboundCall IC WHERE IC.Agentid=AG.Agentid ORDER BY TimeUTC DESC ) AS LastInCall  
     ,(SELECT TOP 1 DistributionTime FROM .[dbo].OutboundCall OC WHERE OC.Agentid=AG.Agentid ORDER BY TimeUTC DESC ) AS LastOutCall
     ')
     FROM .dbo.DataQuery DQ
    WHERE DataQueryId=@Id
   INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@Id,N'LastInCall',N'DayTime',N'LastInCall',N'LastInCall',NULL,0,110,130,NULL,0,NULL) 
   INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@Id,N'LastOutCall',N'DayTime',N'LastOutCall',N'LastOutCall',NULL,0,110,140,NULL,0,NULL) 

  END

SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName IN ('Přehled agentů Admin','List of Agents')
 AND QueryGroup='Admin' AND QueryText NOT LIKE '%MAX(PilotTime)%' AND Deleted=0)
IF @Id IS NOT NULL 
  BEGIN
   PRINT 'I tune Query Admin agents'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'
	 ,(SELECT TOP 1 PilotTime FROM .[dbo].InboundCall IC WHERE IC.Agentid=AG.Agentid ORDER BY TimeUTC DESC ) AS LastInCall  
     ,(SELECT TOP 1 DistributionTime FROM .[dbo].OutboundCall OC WHERE OC.Agentid=AG.Agentid ORDER BY TimeUTC DESC ) AS LastOutCall
     ',
	 	 ',(SELECT MAX(PilotTime) FROM .[dbo].InboundCall IC WHERE IC.Agentid=AG.Agentid) AS LastInCall  
     ,(SELECT MAX(EnqueueingTime) FROM .[dbo].OutboundCall OC WHERE OC.Agentid=AG.Agentid) AS LastOutCall')
    FROM .dbo.DataQuery DQ
    WHERE DataQueryId=@Id

  UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'SELECT MAX(DistributionTime)', 'SELECT MAX(EnqueueingTime)')
     FROM .dbo.DataQuery DQ
    WHERE DataQueryId=@Id
   END
SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Assigned messages to agents' AND QueryGroup='Admin' AND QueryText NOT LIKE '%SpamLevel%' )
IF @Id IS NOT NULL 
  BEGIN
   PRINT 'Přidávám SpamLevel do Assigned messages to agents'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'ME.ResultData','ME.ResultData, SpamLevel')
     FROM .dbo.DataQuery DQ
  WHERE DataQueryId=@Id
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@Id,N'SpamLevel',N'Text',N'SpamLevel',NULL,NULL,NULL,NULL,NULL,N'SpamLevel',NULL,0,52,300,NULL,0,NULL) 
  END




SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName IN ('Gateways Monitor')
 AND QueryGroup='Admin' AND QueryText NOT LIKE '%RecordId%' AND Deleted=0)
IF @Id IS NOT NULL 
  BEGIN
   PRINT 'I tune Gateways Monitor'
   UPDATE DQ
     SET  QueryText = 'SELECT 
    Phase2.GatewayId AS RecordId
    ,Phase2.GatewayId
    ,ISNULL(GW.DisplayName,''BEZ BRÁNY'') AS GateWayName
    ,PilotAddress
    ,Received
    ,Sent
    ,[Channel]
    ,[Direction]
    , InDevice
    , OutDevice
    ,CAST(IIF((Received>0 AND Sent>0) OR (Received>0 AND [Direction]=''I'')  OR (Sent>0 AND [Direction]=''O''),1,0) AS bit) AS isOK
  	, IIF(Received>0 OR Sent>0,''YES'',''NO'') AS ExKom
  FROM
  (SELECT 
      GatewayId
      ,SUM(Received) AS Received
      ,SUM(Sent) AS Sent
    FROM 
  (SELECT       
  	  GatewayId
        ,SUM(IIF(Direction=''I'',1,0)) AS Received
  	  ,SUM(IIF(Direction=''O'' AND MessagePhase=''Sent'',1,0)) AS Sent
       -- ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId=GW.GateWayId AND TimeUTC>@from AND Direction=''O'' AND MessagePhase=''Sent'') AS OdeslanychZprav
     FROM .[dbo].[Message] ME
    WHERE ReceivedSentTime > DATEADD(Hour,-2,@Now)
    GROUP BY GatewayId
    UNION
    SELECT
  	  GatewayId
        ,0 AS Received
  	  ,0 AS Sent
       -- ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId=GW.GateWayId AND TimeUTC>@from AND Direction=''O'' AND MessagePhase=''Sent'') AS OdeslanychZprav
     FROM .[dbo].[Gateway] GW WHERE Deleted=0
    ) AS Phase1
    GROUP BY GatewayId
    ) AS Phase2
      LEFT JOIN .[dbo].[Gateway] GW ON GW.GatewayId=Phase2.GatewayId
   
  '
     FROM .dbo.DataQuery DQ
    WHERE DataQueryId=@Id
  INSERT [DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@Id,N'Select',N'Toggle',N'RecordId',NULL,NULL,N'~/CustomImages/Bullet-{0}.png',NULL,NULL,N'RecordId',NULL,0,50,3,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)

   UPDATE $(iCC).[dbo].[Portal] SET JsonData = REPLACE(JsonData,'"ManualActions":[null,null,null,null,null,null,null,null,null,null]'
  ,'"ManualActions":[{"Id":"19e60d25-6014-48ca-95a9-0e0ffad9e6d4","DisplayName":"Gateway Test","SpecificName":"ADMIN","Glyph":"fa fa-thermometer-full   ","Flag1":0},null,null,null,null,null,null,null,null,null]')   
	WHERE HashPage='Admin_Email' AND NavGroup='AdminPageNav'

   END

SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Assigned messages to agents' AND QueryGroup='Admin' AND QueryText NOT LIKE '%SpamLevel%' )
IF @Id IS NOT NULL 
  BEGIN
   PRINT 'Přidávám SpamLevel do Assigned messages to agents'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'ME.ResultData','ME.ResultData, SpamLevel')
     FROM .dbo.DataQuery DQ
  WHERE DataQueryId=@Id
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@Id,N'SpamLevel',N'Text',N'SpamLevel',NULL,NULL,NULL,NULL,NULL,N'SpamLevel',NULL,0,52,300,NULL,0,NULL) 
  END





SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Všechny příchozí hovory' AND QueryGroup='Admin')
IF @Id IS NOT NULL AND NOT EXISTS(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@Id AND QueryText LIKE '%Redirector%' )
  BEGIN
   PRINT 'Přidávám Redirector do Všechny příchozí hovory'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'.CallerNumber,','.CallerNumber, Redirector,')
     FROM .dbo.DataQuery DQ
  WHERE DataQueryId=@Id
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@Id,N'Redirector',N'Text',N'Redirector',NULL,NULL,NULL,NULL,NULL,N'Redirector',NULL,0,52,30,NULL,0,NULL) 
  END
  IF @Id IS NOT NULL AND NOT EXISTS(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@Id AND QueryText LIKE '%DISTINCT%' )
  BEGIN
   PRINT 'Přidávám DISTINCT do Všechny příchozí hovory'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'SELECT','SELECT DISTINCT')
     FROM .dbo.DataQuery DQ
  WHERE DataQueryId=@Id
  END

--SET @Id=NULL
--IF EXISTS(SELECT TOP 1 1 FROM .dbo.Issue)
--  SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Všechny příchozí hovory' AND QueryGroup='Admin')
IF @Id IS NOT NULL AND NOT EXISTS(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@Id AND QueryText LIKE '%, C.IssueId%' )
  BEGIN
   PRINT 'Přidávám IssueId do Všechny příchozí hovory'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'C.CallerNumber,','C.CallerNumber, C.IssueId,')
     FROM .dbo.DataQuery DQ
  WHERE DataQueryId=@Id
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@Id,N'IssueId',N'Text',N'IssueId',NULL,NULL,NULL,NULL,NULL,N'IssueId',NULL,0,52,30,NULL,0,NULL) 
  END

SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Všechny zprávy' AND QueryGroup='Admin')
IF @Id IS NOT NULL AND NOT EXISTS(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@Id AND QueryText LIKE '%, M.IssueId%' )
  BEGIN
   PRINT 'Přidávám IssueId do Všechny zprávy'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'M.SubjectField,','M.SubjectField, M.IssueId,')
     FROM .dbo.DataQuery DQ
  WHERE DataQueryId=@Id
    INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd])
    VALUES (@Id,N'IssueId',N'Text',N'IssueId',NULL,NULL,NULL,NULL,NULL,N'IssueId',NULL,0,52,30,NULL,0,NULL) 
  END

IF (SELECT TOP 1 1 FROM .[dbo].[DataQueryColumn] DQC
    LEFT JOIN .[dbo].[DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
  WHERE DQ.QueryGroup='ADMIN' AND UrlFormat LIKE '%Messages/DispFormPlus%')=1
   BEGIN
     PRINT 'I repair link for MessageEditor'
     -- Najdu si správný formát
	 DECLARE @UrlFormat AS NVARCHAR(150)=(SELECT TOP 1 UrlFormat FROM .[dbo].[DataQueryColumn] WHERE UrlFormat LIKE '%MessageEditor%' )
	 IF @UrlFormat IS NOT NULL
	    UPDATE DQC
          SET  UrlFormat = @UrlFormat
			FROM .dbo.DataQueryColumn DQC
			  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
			WHERE DQ.QueryGroup='Admin' AND UrlFormat LIKE '%Messages/DispFormPlus%'
   END

   PRINT 'Vyhazuji TOP 1000'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'TOP 1000','')
     FROM .dbo.DataQuery DQ
  WHERE QueryGroup='Admin' AND QueryText LIKE '%TOP 1000%'

 -- Nastavení správného formátu datumu v Eventlog u skupiny Admin:
  PRINT 'Opravuji model v Eventlog'
 UPDATE DQC
SET  Model = 'DateTimeFromTo'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND (DQC.Model='DayTime' ) 


 -- Konverze FullText na Text u skupiny Admin:
 PRINT 'Konverze FullText na Text:'
 UPDATE DQC
SET  Model='Text'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQC.Model='FullText' 

-- Konverze FullText na Text u skupiny Admin:
 PRINT 'Konverze FullText Hyperlink na Text:'
 UPDATE DQC
SET  Model='HyperLink'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQC.Model='HyperFullText' 


 -- Nastavení stejné velikosti písmen u skupiny Admin:
 UPDATE DQ
SET  QueryGroup = 'Admin'
FROM .dbo.DataQuery DQ
WHERE 1=1
AND DQ.QueryGroup='Admin'

-- Nastavení Tooltipů
UPDATE DQC
SET  ToolTip = 500
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND (DQC.Model='Text' OR DQC.Model='Hyperlink') AND ISNULL(ToolTip,0)=0

UPDATE DQC
SET  ToolTip = 500
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND (DQC.Model='Text')

UPDATE DQC
SET  Width = 200
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQC.DisplayName='ResultData'

UPDATE DQC
SET  Width = 120
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQC.DisplayName='ResultData'


UPDATE DQC
SET  Width = 35
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQC.DisplayName='Jazyk'

UPDATE DQC
SET  Width = 62
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQC.DisplayName='Pracoviště'

UPDATE DQC
SET  Width = 130
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQC.TargetColumn='GatewayName'



UPDATE DQC
SET  Width = 140
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQC.TargetColumn='IVR Step'

UPDATE DQC
SET  Width = 999
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQ.DisplayName='Eventlog' AND DQC.TargetColumn='Popis'

UPDATE DQC
SET  Width = 600
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQ.DisplayName='Admin příkazy' AND DQC.TargetColumn='Description'


UPDATE DQC
SET  Width = 600
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQ.DisplayName='Výsledky akcí' AND DQC.TargetColumn='Message'



UPDATE DQC
SET  Model = 'Select'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='Admin' AND DQ.DisplayName='Eventlog' AND DQC.TargetColumn='Procedura'



UPDATE DQC
SET  TargetFormat = '{0:dd.MM.yy HH:mm:ss}',
     Width = 100
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE Model LIKE 'DateTime%'
AND DQ.QueryGroup='Admin'

UPDATE DQC
SET  Width = 160
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE TargetColumn='Subjectfield'
AND DQ.QueryGroup='Admin'

UPDATE DQC
SET  Width = 200
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE TargetColumn='DisplayName'
AND DQ.QueryGroup='Kontakty'
AND DQ.DisplayName='Telefonní seznamy'

UPDATE DQC
SET  CSS = 'success'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE TargetColumn='IsSelected'
AND DQ.QueryGroup='Kontakty'
AND DQ.DisplayName='Telefonní seznamy'
AND CSS IS NULL

-- Nastavení šířky id:
UPDATE DQC SET  
     Width = 230
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE TargetColumn LIKE '%Id' AND Model='Text'
AND DQ.QueryGroup='Admin'

UPDATE DQC SET  
     UrlFormat = REPLACE(UrlFormat,'~/Pages/DataQueryPage.aspx?DataQueryId','/ReactClient/Pages/DataQueryPage.html?Id')
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE UrlColumn IS NOT NULL
AND DQ.QueryGroup='Admin'

UPDATE DQC SET  
     UrlFormat = REPLACE(UrlFormat,'/Calls/DispFormPlusIn.aspx','/calleditor.html')
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE UrlColumn IS NOT NULL
AND DQ.QueryGroup='Admin'

UPDATE DQC SET  
     UrlFormat = REPLACE(UrlFormat,'/Calls/DispFormPlusOut.aspx','/calleditor.html')
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE UrlColumn IS NOT NULL
AND DQ.QueryGroup='Admin'

-- Nastavení šířky ResultText:
UPDATE DQC SET  
     Width = 200
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE TargetColumn = 'ResultData' AND Model='Text'
AND DQ.QueryGroup='Admin'

UPDATE CONF SET  
     ConfigurationValue = ConfigurationValue+'; Gruber@atlantis.cz'
FROM .dbo.Configuration CONF
 WHERE ConfigurationValue NOT LIKE '%Gruber%' AND ConfigurationName='TOCC' AND GroupName='Zakaznik'


IF EXISTS 
(
  SELECT * 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'Portal'
  AND column_name = 'Title'
)
 BEGIN
	  UPDATE $(iCC).dbo.Portal
	SET  Title = 'Export/Import'
	WHERE [NavGroup]='AdminPageNav' AND HashPage='admin_expimp'

	  UPDATE $(iCC).dbo.Portal
	SET  Title = 'Issues', Description = 'Issues'
	WHERE [NavGroup]='AdminPageNav' AND HashPage='admin_pripady'
 END

---- Překlad do angličtiny:
/**/

GO
PRINT 'All commands were completed'

/* Smazání nepoužitých/duplicitních ADMIN DQ:
Zde se objevují všechny nepoužité, tak někdy pomůže je přidat na příslušnou záložku
SELECT TOP (30) *
 FROM iCC.[dbo].[DataQuery] DQ
    LEFT JOIN iCC.[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
	LEFT JOIN iCC.[dbo].[DataQuery] DQ2 ON DQ.DisplayName=DQ2.DisplayName AND DQ2.DataqueryId<>DQ.DataqueryId
	WHERE DQ.Deleted=0 AND PRT.JsonData IS NULL AND DQ.QueryGroup='Admin' AND DQ2.DataqueryId IS NOT NULL

UPDATE TOP (30) DQ 
  SET deleted=1
 FROM iCC.[dbo].[DataQuery] DQ
    LEFT JOIN iCC.[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
	WHERE Deleted=0 AND PRT.JsonData IS NULL AND QueryGroup='Admin'

UPDATE TOP (1) DQ 
  SET deleted=0
 FROM iCC.[dbo].[DataQuery] DQ
    LEFT JOIN iCC.[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
	WHERE Deleted=1 AND PRT.JsonData IS NOT NULL AND QueryGroup='Admin'

UPDATE TOP (1) DQ 
  SET deleted=0
 FROM iCC.[dbo].[DataQuery] DQ
	WHERE 1=1
	--AND DQ.DataQueryId='b37e3ad0-c8e3-4083-a23a-0e18686076b6'
	AND DQ.DisplayName='IVR Steps'

	

*/
