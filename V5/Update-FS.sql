:setvar Version 28.11.24
:r C:\\Atlantis\\Scripts\\setvar.txt
:on error exit
IF @@VERSION NOT LIKE '%Azure%'
  BEGIN
    SELECT 'I am not on Azure'
   :setvar UseCommand "USE Frontstage"
  -- $(UseCommand) -- Toto nelze na AZURE použít
  END
GO
DECLARE @FSVersion AS NVARCHAR(2) = 'V6'
IF @FSVersion<>$(FSVersion)
  BEGIN
    ----Zastav
    RAISERROR('Tato verze skriptu je určena pro jinou verzi FS !!!!!!!!!', 15, 10) --WITH LOG
    PRINT 'Tato verze je určena pro jinou verzi FS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  END
  IF DB_NAME()='Master'
   BEGIN
    ----Zastav
    RAISERROR('Switch please to Frontstage DB !!!!!!!!!', 15, 10) --WITH LOG
   END

 
  /*
  @HardRun
    Dataquery
  */
--------------------------------------------------
-- Doplnění ServiceAPP DataQuery
--------------------------------------------------
IF NOT EXISTS(
SELECT * FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_NAME='FSC_Monitor')
   BEGIN
	CREATE TABLE [dbo].[FSC_Monitor](
		[MonitorId] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
		[DisplayName] [nvarchar](50) NULL,
		[Command] [nvarchar](150) NULL,
		[ExecDuration] [int] NULL,
		[RepeatAfterMin] [int] NULL,
		[RunFromHour] [int] NULL,
		[RunToHour] [int] NULL,
		[Inform1] [bit] NULL,
		[Inform2] [bit] NULL,
		[Inform3] [bit] NULL,
		[Rank] [int] NULL,
		[LastRunTime] [datetime] NULL,
		[LastMessTime] [datetime] NULL,
		[LastMessage] [nvarchar](200) NULL,
		[InformBySecondMatch] [bit] NULL,
		[ReparationProc] [nvarchar](150) NULL,
		Note NVARCHAR(200) NULL
	) ON [PRIMARY]

    ALTER TABLE [dbo].[FSC_Monitor] ADD  CONSTRAINT [DF_FSC_Monitor_MonitorId]  DEFAULT (newid()) FOR [MonitorId]
 END
GO
IF NOT EXISTS(
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME='FSC_Monitor' AND COLUMN_NAME = 'Note'	)
ALTER TABLE FSC_Monitor
 ADD Note NVARCHAR(200) NULL
GO
IF NOT EXISTS(
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME='FSC_Monitor' AND COLUMN_NAME = 'DetailMessage'	)
ALTER TABLE FSC_Monitor
 ADD DetailMessage NVARCHAR(400) NULL
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command LIKE 'FSC_DiskSpace(%')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command], [ExecDuration], [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'Disk Space inspect', N'FSC_DiskSpace(15)', 0, 1000, 7, 10, 1, NULL, NULL)
  END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command='FSC_Recordings()')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command], [ExecDuration], [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3], [Rank], InformBySecondMatch) 
VALUES (NEWID(), N'Recordings inspection', N'FSC_Recordings()', 0, 10, 6, 22, NULL, NULL, NULL, NULL, 1)
  END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command='FSC_AutoTest()')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'AutoTest', N'FSC_AutoTest()',  10000, 14, 22, 1, NULL, NULL)
  END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command LIKE 'FSC_InCalls(%')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'Inbound Calls inspection', N'FSC_InCalls(''OUT_OF_OFFICE'',5)',  5, 9, 16, 1, NULL, NULL)
  END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command LIKE 'FSC_InCalls2(%')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'Inbound Calls Error inspection', N'FSC_InCalls2()',  5, 6, 21, 1, NULL, NULL)
  END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command LIKE 'FSC_InCalls3(%')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'Inbound Calls existence', N'FSC_InCalls3(''OUT_OF_OFFICE'',15)',  5, 6, 21, 1, NULL, NULL)
  END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command='FSC_WPBlockedbyAdmin()')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3], ReparationProc) 
VALUES (NEWID(), N'ADMIN block Workplace inspection', N'FSC_WPBlockedbyAdmin()',  60, 6, 22, 1, NULL, NULL,'FSC_LogOffAdmin')
  END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command LIKE 'FSC_DivertInsp(%')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1]) 
VALUES (NEWID(), N'Divert failed inspection', N'FSC_DivertInsp(30)',  1400, 17, 18, 1)
  END
GO


IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command LIKE 'FSC_DCReg(%')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], ReparationProc) 
VALUES (NEWID(), N'Desktop Client registration inspection', N'FSC_DCReg()',  5, 7, 18, 1,'FSC_DELDCConnect')
  END
GO


IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command LIKE 'FSC_DCReg2(%')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], ReparationProc) 
VALUES (NEWID(), N'Desktop Client registration inspection', N'FSC_DCReg2()',  5, 7, 18, 1,'')
  END
GO


IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command = 'FSC_CorrectFin()')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [ReparationProc]) 
VALUES (NEWID(), N'Correct finish of procedure inspection', N'FSC_CorrectFin()',  60, 8, 21, 1, 'FSC_Fin_Add')
  END
GO


IF NOT EXISTS(SELECT TOP 1 1 FROM [FSC_Monitor] WHERE Command LIKE 'FSC_Invalid_Call(%')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1]) 
VALUES (NEWID(), N'Invalid InCalls inspection', N'FSC_Invalid_Call()',  20, 8, 16, 1)
  END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[FSC_Monitor] WHERE Command = 'FSC_SystemTest()')
  BEGIN 
INSERT [dbo].[FSC_Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [ReparationProc]) 
VALUES (NEWID(), N'System messages inspection', N'FSC_SystemTest()',  60, 9, 21, 1, 'FSC_Sys_Ack')
  END
GO


DECLARE @MinHour AS Integer
DECLARE @MaxHour AS Integer
SELECT 
	  @MinHour=MIN(DatePart(Hour,TimeFrom)),
	  @MaxHour=MAX(DatePart(Hour,TimeTo)) 
  FROM [Holiday] WHERE Timemode='DayInWeek' AND DisplayName NOT LIKE '%TEST%' AND Deleted=0
SET @MinHour=ISNULL(@MinHour,6)
SET @MaxHour=ISNULL(@MaxHour,20)

DECLARE @MinHourR AS Integer, @MaxHourR AS Integer
SELECT 
 @MinHourR=MIN(DATEPART(HOUR,PilotTime))
 ,@MaxHourR= MAX(DATEPART(HOUR,PilotTime)) 
FROM .dbo.Inboundcall
WHERE PilotTime>DATEADD(Month,-2,GETDATE()) AND AnswerTime IS NOT NULL
SET @MinHour=IIF(@MinHour<@MinHourR,@MinHourR,@MinHour)
SET @MaxHour=IIF(@MaxHour>@MaxHourR,@MaxHourR,@MaxHour)
SET @MaxHour=IIF(@MaxHour>17,17,@MaxHour)


UPDATE .dbo.FSC_Monitor SET RunFromHour=@MinHour WHERE RunFromHour<@MinHour 
  AND (Command LIKE 'FSC_InCalls(%' OR Command LIKE 'FSC_InCalls3(%')
UPDATE .dbo.FSC_Monitor SET RunToHour=@MaxHour WHERE RunToHour>@MaxHour
  AND (Command LIKE 'FSC_InCalls(%' OR Command LIKE 'FSC_InCalls3(%')

  UPDATE .dbo.FSC_Monitor SET Command = 'InspectCallEvent('''')' WHERE Command = 'InspectCallEvent()'
  UPDATE .dbo.FSC_Monitor SET Inform1 = 1 WHERE Inform2 IS NULL AND Inform3 IS NULL
  UPDATE .dbo.FSC_Monitor SET ReparationProc = 'Stat_Res' WHERE Command LIKE 'FSC_DBLocks(%' AND ISNULL(ReparationProc,'')=''
  UPDATE .dbo.FSC_Monitor SET DisplayName = 'CPU Load inspection' WHERE Command LIKE 'FSC_CPU(%'
  UPDATE .dbo.FSC_Monitor SET Command = 'FSC_InCalls3(''OUT_OF_OFFICE'',15)' WHERE Command LIKE 'FSC_InCalls3(%' AND Command NOT LIKE 'FSC_InCalls3(''OUT_OF_OFFICE'',%'
  UPDATE .dbo.FSC_Monitor SET Command = 'FSC_InCalls(''OUT_OF_OFFICE'',5)' WHERE Command LIKE 'FSC_InCalls(%' AND Command NOT LIKE 'FSC_InCalls(''OUT_OF_OFFICE'',%'
  UPDATE .dbo.FSC_Monitor SET InformBySecondMatch = 1 WHERE Command LIKE 'FSCMessageEvent(%' 
    OR Command LIKE 'FSCNewMessages(%'
  UPDATE .dbo.FSC_Monitor SET RepeatAfterMin = 10080 WHERE Command = 'FSC_LogLevelInspect()' AND RepeatAfterMin < 1000
  UPDATE .dbo.FSC_Monitor SET ExecDuration = 0 WHERE RepeatAfterMin=-1 AND ExecDuration <> 0
  UPDATE .dbo.FSC_Monitor SET ReparationProc = 'FSC_HledNesparIn' WHERE Command LIKE 'FSCRecordings(%' AND ISNULL(ReparationProc,'')=''
  IF @@VERSION LIKE '%Azure%'  
    UPDATE .dbo.FSC_Monitor SET RepeatAfterMin = -1 WHERE Command LIKE 'FSC_DiskSpace(%' 

--------------------- Pomocné tabulky   ---------------------
IF object_id('FSC_Errorlog') IS NULL
  BEGIN
	CREATE TABLE [dbo].[FSC_ErrorLog](
		[Timelocal] [datetime] NULL,
		[RepeatAfter] [int] NULL,
		[Message] [nvarchar](500) NULL
	) ON [PRIMARY]
	--GO
	/****** Object:  Index [TimeLocal]    Script Date: 11/21/2019 11:26:01 ******/
	CREATE CLUSTERED INDEX [TimeLocal] ON [dbo].[FSC_ErrorLog]
	(
		[Timelocal] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	--GO
  END
  GO

IF OBJECT_ID (N'FSC_Commands', N'U') IS NULL 
CREATE TABLE [dbo].[FSC_Commands](
	[Command] [nvarchar](150) NULL,
	[Description] [nvarchar](150) NULL,
	[CommandId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
    [GroupName] [nvarchar](6) NULL
) ON [PRIMARY]

GO
UPDATE [FSC_Commands] SET Command = 'EXEC FSC_CheckFS' WHERE Command = 'EXEC dbo.CheckRecAndEmlActivity2'
  

IF NOT EXISTS(SELECT Top 1 1 FROM .dbo.FSC_commands WHERE CommandId  = 'ee859402-15e9-48cc-802b-f40d9258b92e')
INSERT [dbo].[FSC_commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC dbo.CancelZombieCalls', N'Close Inbound Calls which are longer time in distribution', N'ee859402-15e9-48cc-802b-f40d9258b92e')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM .dbo.FSC_commands WHERE CommandId  = '62e84a06-6f83-4594-9ccd-a756a096d3b3')
INSERT [dbo].[FSC_commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC dbo.InspectIVR', N'Look for errors in IVR', N'62e84a06-6f83-4594-9ccd-a756a096d3b3')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM .dbo.FSC_commands WHERE CommandId  = 'ee118948-03ea-4d0c-9f03-754fcf195980')
INSERT [dbo].[FSC_commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC dbo.FSC_SendEmails 3', N'Send e-mails in failed status', N'ee118948-03ea-4d0c-9f03-754fcf195980')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM .dbo.FSC_commands WHERE CommandId  = 'BDD430C8-B44C-4D74-B2B8-1A1600DACE97')
INSERT [dbo].[FSC_commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC dbo.PridejPravaPoslechu', N'Set rights for Recordings listening', N'BDD430C8-B44C-4D74-B2B8-1A1600DACE97')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM .dbo.FSC_commands WHERE CommandId  = '705C018E-4182-4DFF-ACF1-460992D31180')
INSERT [dbo].[FSC_commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC Icc_Backup.dbo.Backup_DB ''C:\'' ', N'Configuration Backup', N'705C018E-4182-4DFF-ACF1-460992D31180')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM .dbo.FSC_commands WHERE CommandId  = '9E6654E7-FD93-41CB-98F5-CDD77DDE02B8')
INSERT [dbo].[FSC_commands] ([Command], [Description], [CommandId], GroupName) VALUES (N'EXEC dbo.FSCSwitchXSS', N'Message Security Setting', N'9E6654E7-FD93-41CB-98F5-CDD77DDE02B8','SUPER')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM .dbo.FSC_commands WHERE Command LIKE '%FSC_CheckFS%')
INSERT [dbo].[FSC_commands] ([Command], [Description]) VALUES (N'EXEC FSC_CheckFS', N'Monitoring system')
GO




IF object_id('FSC_ErrorLogProc') IS NOT NULL
 DROP  Procedure  [dbo].[FSC_ErrorLogProc]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <21.11.2019>
-- Description:	<Zpracování chybové zprávy>
-- =============================================

CREATE PROCEDURE [dbo].[FSC_ErrorLogProc] (
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
  declare @TOCC as nvarchar(200) =dbo.FSC_GiveParam('TOCC')
	IF @TOCC IS NULL
	     BEGIN
		   SET @TOCC  = 'error@atlantis.cz'
		   EXEC [dbo].[FSC_WriteParam] 'TOCC', @TOCC, 'E-mail addresses to which recorded problems should be sent'
		 END
  declare @TOCC2 as nvarchar(200) =dbo.FSC_GiveParam('TOCC2')
	IF @TOCC2 IS NULL AND 1=2
	     BEGIN
		   SET @TOCC2  = 'servis@atlantis.cz'
		   EXEC [dbo].[FSC_WriteParam] 'TOCC2', @TOCC2, 'E-mail addresses to which recorded problems should be sent'
		 END
  declare @TOCC3 as nvarchar(200) =dbo.FSC_GiveParam('TOCC3')
	IF @TOCC3 IS NULL
	     BEGIN
		   SET @TOCC3  = ''
		   EXEC [dbo].[FSC_WriteParam] 'TOCC3', @TOCC3, 'E-mail addresses to which recorded problems should be sent'
		 END
--
DECLARE @Inform1 AS Bit, @Inform2 AS Bit, @Inform3 AS Bit
SELECT @Inform1=Inform1,@Inform2=Inform2,@Inform3=Inform3 FROM .dbo.FSC_Monitor WHERE Displayname=@RecMsg
--SET @Inform1=ISNULL(@Inform1,1) -- Pokud test ještě není v seznamu -- Vypuštěno 1.2.24
-- Speciální úprava:
IF @Message LIKE 'Emails:%'
  BEGIN
	SET @Inform3=0
  END
IF @Message LIKE 'Emails: No recipients found in the message%'
  AND @TOCC3 NOT  LIKE '%atlantis%'
  BEGIN
    SET @Inform1=0
	SET @Inform3=1
  END

 --declare @RemoteAddress as nvarchar(200) = CASE WHEN @Severity>0 THEN 'servis@atlantis.cz' ELSE @TOCC END
 declare @RemoteAddress as nvarchar(200) = CASE WHEN @Inform1=1 THEN @TOCC ELSE CASE WHEN @Inform2=1 THEN @TOCC2 ELSE @TOCC3 END END
 SET @TOCC=CASE WHEN @Inform1=1 THEN @TOCC ELSE '' END 
 SET @TOCC=@TOCC+CASE WHEN @Inform2=1 THEN @TOCC2 ELSE '' END 
 SET @TOCC=@TOCC+CASE WHEN @Inform3=1 THEN @TOCC3 ELSE '' END 
 SET @TOCC=REPLACE(@TOCC,@RemoteAddress,'') -- Vyhodím @RemoteAddress, která mail již dostane

 declare @Company as nvarchar(200) =dbo.FSC_GiveParam('Company')
 declare @SyncVer as nvarchar(200) = --dbo.FSC_GiveParam('iCC.ServiceSync')-- Potebuji Description
 (SELECT Description FROM .[dbo].[CONFIGURATION]  WHERE ConfigurationName='iCC.ServiceSync')
 declare @ProVer as nvarchar(200) = 
 (SELECT Description FROM .[dbo].[CONFIGURATION]  WHERE ConfigurationName='Pro.Service')

 SET @RecMsg='iCCServiceSync version: '+RTRIM(@SyncVer)+' ProServer version: '+RTRIM(@ProVer)
 declare @MessageId as uniqueidentifier = (SELECT TOP 1 MessageId FROM .[dbo].[Message]
	   WHERE Direction='O' AND MessageType=1 /*'Email'*/ AND ReceivedSentTime IS NOT NULL AND GatewayId IS NOT NULL ORDER BY ReceivedSentTime DESC)
 declare @GW as uniqueidentifier = CASE WHEN dbo.FSC_GiveParam('ServiceGateWay')='' THEN
(SELECT TOP 1 [GatewayId] FROM .[dbo].[Message] WHERE MessageId=@MessageId) ELSE dbo.FSC_GiveParam('ServiceGateWay') END

 declare @FromField as nvarchar(150) = (SELECT TOP 1 PilotAddress FROM .[dbo].[Gateway] WHERE GatewayId=@GW)

  declare @Mark as int = 77
  DECLARE @RepeatAfterMess as int
  DECLARE @TimeLocalMess as DateTime
  SELECT TOP 1 @RepeatAfterMess=RepeatAfter, @TimeLocalMess=TimeLocal FROM dbo.FSC_ErrorLog WHERE Message=@Message ORDER BY TimeLocal DESC
  -- Pokud mám o tomto problému informovat
  IF @TimeLocalMess IS NULL OR (@RepeatAfterMess>0 AND DATEADD(Minute,@RepeatAfterMess,@TimeLocalMess) <GETDATE())
     BEGIN
	    declare @Now as datetime = GETUTCDATE()
    
	insert into .[dbo].[FSC_Errorlog] (TimeLocal, RepeatAfter, Message) values(GETDATE(), @RepeatAfter, @Message)
	--SET @Message='Warning: '+@Message
	SET @RecMsg=@RecMsg+' - This is a diagnostic message for the system administrator'

 IF @GW IS NOT NULL AND (NOT EXISTS(SELECT * FROM .dbo.Message as M where M.Messagetype=1
  AND MessagePhase=8 AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE())
   AND GatewayId=@GW AND M.TimeUTC<DATEADD(Minute,-10,GETUTCDATE()))) 
	insert into .dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,1,8,0, @FromField, @RemoteAddress,@RemoteAddress,  @TOCC ,@GW,99,'O',
		'FSL1: '+@Company+' '+@Message+' '+ISNULL(@Specif,'')+' '+@ProcVer, @RecMsg, @RecMsg, @Mark )
/**/
     END
END
GO


IF object_id('FSC_CheckFS') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_CheckFS
GO

/* ===================================  S T A R T    O F   M A I N   P R O C E D U R E  ============================= */


-- Upravil ZbH 17.7.2018
-- Nyní probíhá stálé zdokonalování funkce
CREATE
--ALTER
 PROCEDURE [dbo].[FSC_CheckFS] 
AS
BEGIN
   declare @ProcVer as nvarchar(35) = ' Inspection function ver: $(Version)'
   
  -- SELECT 'Start '+RIGHT(CONVERT(NVARCHAR(28),GETDATE(),120),8) AS Zpráva
     ---  Texty pro komunikaci s uživatelem: -------------------------------------------------------------------------------------------------------------
       DECLARE @AlerteMails AS NVARCHAR(200)='Email addresses for receiving discovered issues'
       DECLARE @AgentIncorStat AS NVARCHAR(200)='Agent %s has an incorrect phone status'
       DECLARE @InspectPlease AS NVARCHAR(200)='Please check'
       DECLARE @AgentNotReady AS NVARCHAR(200)='Agent %s that should be permanently logged on is not ready right now'
	   DECLARE @DuplicWPMess AS NVARCHAR(200)='Duplicate Workplace %s '
       DECLARE @AgentwWasLogoff AS NVARCHAR(200)='Agent %s was logged off'
       DECLARE @AutoLogon AS NVARCHAR(200)='Automatic logon performed'
       DECLARE @NoTemplate AS NVARCHAR(200)='Missing template for e-mail auto-answer'


	-----------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @StartTime AS Datetime = GETDATE()
	--exec FSCMonCheck 'Start ',@StartTime
	declare @Today as datetime = GETDATE()

    EXEC  [FSC_WriteEvent] 1,'CheckFS','Entry point'

	/* Tuto část bude možno vypustit : ---------------------------------------------------------------------------------------*/
	declare @TGT as nvarchar(200) = 'servis@atlantis.cz'

	

    DECLARE @EndTime AS datetime = (SELECT MAX(EndTime) FROM .[dbo].[Message] WITH (NOLOCK)
	WHERE MessageType=1 AND Direction='O' AND  ReceivedSentTime IS NOT NULL AND GatewayId IS NOT NULL)

	declare @MessageId as uniqueidentifier =
	(SELECT TOP 1 MessageId FROM .[dbo].[Message] WITH (NOLOCK) WHERE Direction='O' AND EndTime=@EndTime)
	 declare @GW as uniqueidentifier = (SELECT TOP 1 [GatewayId] FROM .[dbo].[Message] WITH (NOLOCK)
	 WHERE MessageId=@MessageId)
	 declare @GWN as nvarchar(150) = (SELECT TOP 1 PilotAddress FROM .[dbo].[Gateway] WITH (NOLOCK) WHERE GatewayId=@GW)
	 declare @Company as nvarchar(200) =dbo.FSC_GiveParam('Company')
	 IF @Company IS NULL
	     BEGIN
		    EXEC [dbo].[FSC_WriteParam] 'Company', @GWN, 'Company Name'
		 END

    DECLARE @RecordingsLess AS Integer=dbo.FSC_GiveParam('RecordingsLess')
	   IF @RecordingsLess IS NULL
	     BEGIN
		   SET @RecordingsLess=5
		   EXEC [dbo].[FSC_WriteParam] 'RecordingsLess', @RecordingsLess, 'Number of tolerated calls without recordings'
		 END
   DECLARE @PairingTime AS Integer=dbo.FSC_GiveParam('PairingTime')
	   IF @PairingTime IS NULL
	     BEGIN
		   SET @PairingTime=10 -- Minutes
		   EXEC [dbo].[FSC_WriteParam] 'PairingTime', @PairingTime, 'Time required to pair calls with recordings'
		 END
   DECLARE @ServiceGateWay AS  NVARCHAR(10)=dbo.FSC_GiveParam('ServiceGateWay')
	   IF @ServiceGateWay IS NULL
	     BEGIN
		   EXEC [dbo].[FSC_WriteParam] 'ServiceGateWay', '', 'Service GateWay'
		 END



     DECLARE @AgentName AS NVARCHAR(50)
	 DECLARE @String1 AS NVARCHAR(50)
	 DECLARE @String2 AS NVARCHAR(50)
	 declare @Command AS NVARCHAR(500)
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
	declare @Holiday as nvarchar(40) =dbo.FSC_GiveParam('Holiday')
	IF @Holiday IS NULL
	     BEGIN
		   SET @Holiday  = 'OUT_OF_OFFICE'
		   EXEC [dbo].[FSC_WriteParam] 'Holiday', @Holiday, 'Name of holiday group'
		 END


	declare @Mark as int = 77
	IF(EXISTS(SELECT * FROM .dbo.Holiday as H WITH (NOLOCK) where H.HolidayGroupName=@Holiday AND H.TimeMode='SingleDay' AND CAST(H.TimeFrom as DATE)=CAST(@Today AS DATE))) OR
	(EXISTS(SELECT * FROM .dbo.Holiday as H WITH (NOLOCK) where H.HolidayGroupName=@Holiday AND H.TimeMode='DayInYear' AND DATEPART(DAY,H.TimeFrom)=DATEPART(DAY,@Today) AND DATEPART(MONTH,H.TimeFrom)=DATEPART(MONTH,@Today))) OR
	-- Pokud tam jsou mé neodeslané maily mladší 24hodin, neodesílám další
	(EXISTS(SELECT * FROM .dbo.Message as M WITH (NOLOCK) where M.Messagetype=1 AND MessagePhase=8 AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE()))) 
	  BEGIN
	    EXEC  [FSC_WriteEvent] 1,'CheckFS','End of procedure'
	    RETURN --====================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	  END



	declare @Now as datetime = GETDATE()
	declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Now )	-- Před 15 min

	declare @Interval as int = 30;
	declare @Debug as bit = 0


	declare @Last as datetime = DATEADD(MINUTE, -@Interval, @Now ) -- Posledních 30minut
	declare @WeekAgo as datetime = DATEADD(DAY, -7, @Now )
	declare @DayAgo as datetime = DATEADD(DAY, -2, @Now )
	declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
	declare @LastWeekAgo as datetime = DATEADD(DAY, -7, @Last )
	declare @OneHourAgo as datetime = DATEADD(Hour, -1, @Now )
    DECLARE @from AS datetime=DATEADD(Hour,-3,GETDATE())
    DECLARE @to AS datetime=DATEADD(Minute,-@PairingTime,GETDATE())
    DECLARE @UTCDif AS Integer = (SELECT TOP 1 DATEDIFF(HOUR,PilotTime,TimeUTC) FROM .dbo.InboundCall WITH (NOLOCK) ORDER BY TIMEUTC DESC)
    DECLARE @fromUTC AS datetime=DATEADD(Hour,@UTCDif,@from)
    DECLARE @toUTC AS datetime=DATEADD(Hour,@UTCDif,@to)
    declare @T as nvarchar(120) = CONVERT(nvarchar(20), DATEADD(MINUTE, -@Interval, @Today), 20) + ' - ' + CONVERT(nvarchar(20), @Today, 8)
	declare @Activity as nvarchar(32)
	declare @LastRecording AS Datetime
	declare @LastinCall AS Datetime
	declare @Severity AS Integer
	declare @OpakpoMin AS Integer = 30 -- Opakuj chybové hlášení po x minutách
	--exec FSCMonCheck 'Starting part completed',@StartTime
    IF @GW IS NOT NULL  
	 BEGIN
	   DECLARE @NoSent as int = (select count(*) from .dbo.Message as M WITH (NOLOCK) where M.Direction='O' 
	   AND (MessagePhase=8 OR MessagePhase=9) AND M.MessageType=1 AND M.TimeUtc<=@Last AND
	   M.TimeUtc>=@DayAgo AND M.ReceivedSentTime IS NOT NULL AND M.ReceivedSentTime>=@DayAgo
	   AND RemoteAddress IS NOT NULL -- 28.5.2019 Odfiltrování chybných mailů z webu
	   and (ISNULL(ScheduledTime,dbo.FSC_TimeUTC_Local(TimeUTC))  < @Last)--Kubat, podminka pro naplanovane maily a jejich zpozdene odeslani
	   --and MessageResult = 0 -- ZbH 27.3.2019
	   )
	   DECLARE @NoSentTreshold AS Integer=dbo.FSC_GiveParam('NoSentTreshold')
	   IF @NoSentTreshold IS NULL
	     BEGIN
		   SET @NoSentTreshold=10
		   EXEC [dbo].[FSC_WriteParam] 'NoSentTreshold', @NoSentTreshold, 'Hranice, při níž se nahlašuje počet neodeslaných mailů (Scheduled, Failed)'
		 END
	   IF @NoSent>@NoSentTreshold
	    BEGIN
		   -- Pokusím se zjistit důvod neodeslání

			select TOP 1 @RemoteAddress=RemoteAddress,@ResultData=ResultData from .dbo.Message as M WITH (NOLOCK) 
			   LEFT JOIN .dbo.MessageEvent as ME WITH (NOLOCK) ON M.MessageId=ME.MessageId AND EventType=30 /*'Ndr'*/
			where M.Direction='O' AND (MessagePhase=8 OR MessagePhase=9) AND M.MessageType=1 AND M.TimeUtc<=@Last AND M.TimeUtc>=@DayAgo
			IF @RemoteAddress IS NOT NULL
			  BEGIN
				SET @Specif = 'to address= '+@RemoteAddress
				EXEC [dbo].[FSC_ErrorLogProc] 'undelivery message',@Specif,@ProcVer,@ResultData,0,240
			  END
            ELSE
			  BEGIN
				SET @Specif = ', count='+ CONVERT(nvarchar(10),@NoSent)
				EXEC [dbo].[FSC_ErrorLogProc] 'unsent emails',@Specif,@ProcVer,@EmlMsg,2,60
							-- Pokusím se problém vyřešit
				UPDATE .[dbo].[Message] SET MessageResult=0
				 WHERE  TimeUtc>@Yesterday AND Direction='O' AND MessagePhase=8 AND MessageResult=2 -- Pokud agent zadal odeslání uzavřeného mailu
			  END

          END
	 END

 SET @String1=NULL
 SET @String2=NULL
    SET @EmlMsg=NULL -- .[dbo].InspectGDPR()
	IF (@EmlMsg IS NOT NULL)
	  BEGIN
         DECLARE @GdprDefaultSensitivity AS Integer = (SELECT MIN(Sensitivity) FROM .[dbo].[GdprSensitivity]) 
         /*update .[dbo].[Configuration] 
           SET ConfigurationValue = @GdprDefaultSensitivity
             WHERE  ConfigurationName='GdprDefaultSensitivity'*/
		SET @Zprava = 'Error in GDPR'-- - I repair it'
		SET @Specif = ''
		SET @Severity = 0
		SET @OpakpoMin = 1440
		EXEC [dbo].[FSC_ErrorLogProc] @Zprava,@Specif,@ProcVer,@EmlMsg,@Severity,@OpakpoMin
      END
   ------------ OBECNÁ SEKCE: --------------------------------------
DECLARE @StartProcTime DateTime
declare @MonitorId AS UniqueIdentifier
declare @ExecDuration AS Integer
declare @DisplayName AS NVARCHAR(50)
declare @LastMessage AS NVARCHAR(50)
declare @InformBySecondMatch AS bit
declare @ReparationProc AS NVARCHAR(150)
declare @Inform1 AS bit
declare @Inform2 AS bit
declare @Inform3 AS bit

declare @Hour as Integer = DATEPART(HOUR,@Now)
DECLARE Mon_cursor CURSOR FOR   
 SELECT TOP 1000 [MonitorId]
      ,[Command]
	  ,DisplayName
	  ,LastMessage
	  ,InformBySecondMatch
      ,[Inform1]
      ,[Inform2]
      ,[Inform3]
      ,[ReparationProc]
  FROM .[dbo].[FSC_Monitor]
  WHERE @Hour BETWEEN RunFromHour AND RunToHour-1 AND (LastRunTime IS NULL OR DATEADD(MINUTE,RepeatAfterMin,LastRunTime)<@Now)
    AND Command is not NULL and RepeatAfterMin <>-1

  OPEN Mon_cursor 
  FETCH NEXT FROM Mon_cursor INTO @MonitorId,@Command,@DisplayName,@LastMessage,@InformBySecondMatch,@Inform1,@Inform2,
    @Inform3,@ReparationProc
  WHILE @@FETCH_STATUS = 0  AND DATEDIFF(SS,@StartTime,GETDATE())<25
    BEGIN
	  UPDATE .dbo.FSC_Monitor
          SET ExecDuration =-1
         WHERE MonitorId =@MonitorId

	  SET @StartProcTime=GETDATE()
	  SET @EmlMsg='' -- Přenášely se hlášky z testu do testu
	  -- Spuštění testu
	  SET @Command='SET @EmlMsg=.[dbo].'+LTRIM(@Command)
      EXEC SP_EXECUTESQL @Command, N'@EmlMsg NVARCHAR(300) OUTPUT', @EmlMsg OUTPUT
	  IF ISNULL(@EmlMsg,'')<>'' AND @EmlMsg<>'RUNPROC' -- Někdy chci spustit jen nápravnou proceduru
	    AND (ISNULL(@InformBySecondMatch,0)=0 OR @EmlMsg=@LastMessage)
	    BEGIN		  
 		 SET @Severity = (SELECT CASE WHEN @EmlMsg LIKE '%!!!%' THEN 10 ELSE 0 END)
		  UPDATE .dbo.FSC_Monitor
			  SET 
				  LastMessTime = GETDATE()
				 ,LastMessage  = @EmlMsg
			  WHERE MonitorId =@MonitorId
          SET @Specif=(SELECT TOP 1 DetailMessage FROM .dbo.FSC_Monitor WHERE MonitorId =@MonitorId )
		  EXEC [dbo].[FSC_ErrorLogProc] @EmlMsg,@Specif,@ProcVer,@DisplayName,@Severity,10

		 END
	   ELSE
	     BEGIN
           IF ISNULL(@EmlMsg,'')<>'' AND @EmlMsg<>'RUNPROC'
	        AND (ISNULL(@InformBySecondMatch,0)=1 AND @EmlMsg=@LastMessage)	
			 UPDATE .dbo.FSC_Monitor
			   SET 
				  LastMessTime = GETDATE()
				 ,LastMessage  = @EmlMsg+' 2'
	   
		 END

		SET @ExecDuration=DATEDIFF(SS,@StartProcTime,GETDATE())
		UPDATE .dbo.FSC_Monitor
          SET LastRunTime  = GETDATE()
		     ,ExecDuration = @ExecDuration
         WHERE MonitorId =@MonitorId
         IF ISNULL(@EmlMsg,'')<>''
		   BEGIN
             IF @ReparationProc IS NOT NULL
			   BEGIN
		         SET @Command='EXEC '+LTRIM(@ReparationProc)
                 EXEC SP_EXECUTESQL @Command		     
			   END
		   END

         SELECT @DisplayName+' had duration '+CONVERT(NVARCHAR(4),@ExecDuration)+' seconds' AS Test,@EmlMsg AS Message

		FETCH NEXT FROM Mon_cursor INTO @MonitorId,@Command,@DisplayName,@LastMessage,@InformBySecondMatch,@Inform1,@Inform2,
    @Inform3,@ReparationProc

    END
  CLOSE Mon_cursor;  
  DEALLOCATE Mon_cursor;
----------------------------------------------------------------------------------------


       EXEC  [FSC_WriteEvent] 1,'CheckFS','End of procedure'

END
GO --------------------- 

PRINT 'End of FSC_CheckFS'

-- Doplnění ServiceAPP:
-- Monitoring system:
IF NOT EXISTS(SELECT * FROM [ActionTrigger] WHERE DisplayName='Monitoring System' AND GroupName='ServiceAPP')
INSERT INTO [ActionTrigger] ([ActionTriggerId],[DisplayName],[Description],[GroupName],[CommandText],[WorkflowId],[WorkflowXaml],[Model],[Interval],[TimeMode],[TimeFrom],[TimeTo],[ReferenceKey],[LastRunUtc],[LastWorkflowInstanceId],[Suspended],[Deleted],[Offset],[LaunchTime])VALUES('33311DF9-EA0F-4203-866B-0C4F2D2B584A','Monitoring system',NULL,'ServiceAPP','EXEC FSC_CheckFS',NULL,NULL,'Interval',30,NULL,NULL,NULL,NULL,GETDATE(),NULL,0,0,NULL,NULL)

 ----- Spoušť  Test Gateway:
IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Gateway Test')
 INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
  VALUES (N'19e60d25-6014-48ca-95a9-0e0ffad9e6d4', N'Gateway Test', N'It is for GW testing', N'ServiceAPP', N'EXEC FSC_GatewayTest @RecordId', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)


------ Denní údržba
IF NOT EXISTS(SELECT * FROM [ActionTrigger] WITH(NOLOCK) WHERE ActionTriggerId= '7a982dcb-e4c5-4a09-86db-52542909b406' )
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
 VALUES (N'7a982dcb-e4c5-4a09-86db-52542909b406', N'Denní údržba', NULL, N'ServiceAPP', N'EXEC .[dbo].[FSC_Daily_Maintenance]', NULL, NULL, N'PeriodDay', NULL, NULL, NULL, NULL, NULL, CAST(LEFT(CONVERT(NVARCHAR(28),GETDATE()+1,120),10)+' 03:00:00.000' AS DateTime), NULL, 0, 0)

------ Copy selected steps into selected script
 IF NOT EXISTS(SELECT * FROM [ActionTrigger] WHERE ActionTriggerId='873404dd-0641-46b0-b8f4-3f6b33bf348c')
 INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted], [Offset], [LaunchTime])
 VALUES (N'873404dd-0641-46b0-b8f4-3f6b33bf348c', N'Copy selected steps into selected script', NULL, N'ServiceAPP', N'EXEC .[dbo].[FSC_IVRStepCopy] @RecordId', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL)


  IF NOT EXISTS (SELECT TOP 1 1 FROM [Portal] WHERE HashPage='Admin_KontSys' OR HashPage='ServiceAPP_KontSys')
    BEGIN
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('AF62BFEE-171B-489B-9E29-19232D11D71D','Admin_KontSys','Inspection system',NULL,'fa fa-bug',NULL,'AdminPageNav',5060,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Eventlog","Css":"","DataQuery":{"Id":"1fe47865-ad21-4ec7-8cf9-3841dd6efac7","DisplayName":"Eventlog","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Admin Commands","Css":"","DataQuery":{"Id":"61c8ebc7-e7be-42b2-88b5-578479d8c30a","DisplayName":"Admin Commands","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":[],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"F","DisplayName":"Web Admin Changes","OriginalDisplayName":"Web Admin Changes","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"a10ad2c8-64cb-4aff-b937-69cffe292dba","DisplayName":"Web Admin Changes","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":[],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"E","DisplayName":"Detected problems","OriginalDisplayName":"Detected problems","Css":"col-md-12 col-sm-12 col-xs-12","Glyph":null,"DataQuery":{"Id":"da89c2b0-f74d-4b41-8589-5491c8239a29","DisplayName":"Detected problems","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Monitoring System","OriginalDisplayName":"Monitoring System","Css":"col-md-12 col-sm-12 col-xs-12","Glyph":null,"DataQuery":{"Id":"77f81f33-c8a9-4883-a480-c3d29d8541cc","DisplayName":"Monitoring System","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"","Index":"B","DisplayName":"Code Change","OriginalDisplayName":"Code Change","Css":"col-md-12 col-sm-12 col-xs-12","Glyph":null,"DataQuery":{"Id":"9fb476c8-1d02-4d17-820b-e5324fafe087","DisplayName":"Code Change","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"Tag":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ResetToggleAfter":false,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"NoSpam":null,"SpamManual":null,"SpamBlocked":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Percents","TableType":null,"TargetColumn":null}]',NULL,NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('77547454-F322-4658-B67F-1A9F038231C5','Admin_Wallboard','Wallboards',NULL,'fa fa-bar-chart',NULL,'AdminPageNav',5070,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Wallboard","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"372f67e1-c08d-49da-a1ce-89e875a1d68b","DisplayName":"Wallboard","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Wallboard Times","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"1c043f8c-2616-4293-8467-2422bf171ae7","DisplayName":"Wallboard Times","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":[],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]}]',NULL,NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('A941D991-9D2E-427F-B230-443B4445B041','Admin_IVR','IVR',NULL,'fa fa-phone',NULL,'AdminPageNav',5050,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"IVR Scripts","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"b37e3ad0-c8e3-4083-a23a-0e18686076b6","DisplayName":"IVR Scripts","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"IVR Scripts"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"IVR Steps","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"d45fde09-0bf3-4418-bf50-7f11f3e5c0e5","DisplayName":"IVR Steps","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"873404dd-0641-46b0-b8f4-3f6b33bf348c","DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","Glyph":"fa fa-thermometer-full","Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ImmediatelyExecuteAndMonitor","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null]}]',NULL,NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('49DFE157-4A6F-4656-8BDE-56499183D4D2','Admin_Hovory','Calls',NULL,'fa fa-phone',NULL,'AdminPageNav',5010,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Inbound Calls","Css":"","DataQuery":{"Id":"99cecf13-c463-4abd-a52e-ad923d51ac7c","DisplayName":"Inbound Calls","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Inbound Call Events","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"882362dc-f36f-4248-ad4d-64d1a883e91a","DisplayName":"Inbound Call Events","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":30,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Inbound Call Events"},{"Type":"DataQueryGrid","Path":"A","Index":"E","DisplayName":"Admin: Outbound Calls","Css":"","DataQuery":{"Id":"ce85ccb8-d497-40ab-a067-e1561d4d7ab6","DisplayName":"Outbound Calls","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"F","DisplayName":"Outbound Call Events","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"354e10a1-14f7-4f66-b1aa-9b7ffee2b91f","DisplayName":"Outbound Call Events","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Outbound Call Events"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Admin: Recordings","Css":"","DataQuery":{"Id":"68df515a-31d7-4137-b661-9ce2c40a601a","DisplayName":"Recordings","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]}]',NULL,NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('F007B5DA-21C9-499F-B781-88A8950C98A9','admin_pripady','Issues','Issues','fa fa-briefcase',NULL,'AdminPageNav',5045,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12","FixedTopHeight":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true,"Navbar":false},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Issues","Css":"col-md-10 col-sm-10 col-xs-10","DataQuery":{"Id":"34137610-1fb2-4b82-a857-2bf1f3c05d08","DisplayName":"Issues","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":30,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":120,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":"fa fa-cubes","MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ColumnWidthUnit":"Percents","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Issues"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Issue Events","Css":"col-md-10 col-sm-10 col-xs-10","DataQuery":{"Id":"6c5e8e3f-37b1-4fc6-8c7d-233efd017f2b","DisplayName":"Issue Events","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":120,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":"fa fa-users","MessageChangeMeta":"fa fa-cubes","MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ColumnWidthUnit":"Percents","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"956bd651-5e05-4019-b394-dd33bf1c68d1","DisplayName":"Není SPAM","Glyph":null,"SpecificName":"Message"},"ActionItem":{"Id":null,"DisplayName":"Není SPAM","Glyph":"fa fa-thumbs-up","Rank":0,"SpecificName":null},"ExecuteType":"ImmediatelyExecuteAndMonitor","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Issue Events"}]','Issues',NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('54BA365C-F98F-494F-8857-9C85EEB8686E','admin_Record','Recordings','Recordings','fa fa-microphone',NULL,'AdminPageNav',5090,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Admin Recordingless Calls","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"a12aae6c-caef-4ba1-a117-221b2a6c1f75","DisplayName":"Admin Recordingless Calls","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Percents","ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Admin Recordingless Calls"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true}]',NULL,NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('D0C44CCF-5260-4B1B-8F8E-A52A3FE10073','Admin_FrontaHovoru','Queue of Calls',NULL,'fa fa-align-left',NULL,'AdminPageNav',5080,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Queue investigation","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"832e1da3-c87e-4e51-a7a6-ca1ec2abcdfd","DisplayName":"Queue investigation","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Free agents","Css":"col-md-8 col-sm-8 col-xs-8","DataQuery":{"Id":"9e103b6f-379b-417c-8ec7-2361ef3124ed","DisplayName":"Free agents","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Free agents seznam","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"50baed36-ca55-46b5-a971-45996d7b52f0","DisplayName":"Free agents seznam","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]}]',NULL,NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('873B377F-11B3-4142-9063-B7DB635D52D0','Admin_DQ','Data Query',NULL,'fa fa-calendar',NULL,'AdminPageNav',5030,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Queries","Css":"","DataQuery":{"Id":"e5fe7ca3-06f1-46a4-9771-09cb4bfc43eb","DisplayName":"Data Queries","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Data Queries Columns","Css":"","DataQuery":{"Id":"d1f1f295-8801-423b-aafd-9222ee4892fc","DisplayName":"Data Queries Columns","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Data Queries Columns"}]',NULL,NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('9FF03AAE-A127-47E1-8A41-D491DE622D2F','admin_expimp','Dataquery Usage','Dataquery Usage','fa fa-exchange',NULL,'AdminPageNav',5090,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Color":null,"Rank":null,"Flag1":1,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Data Query usage"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true}]','Export/Import',NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('7F649A00-6CDA-47F5-A600-DCD4195F1051','Admin_Email','Emails',NULL,'fa fa-envelope',NULL,'AdminPageNav',5040,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner hlavni","Css":"col-md-12 col-sm-12 col-xs-12","FixedTopHeight":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Messages","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"05d59721-8eed-493d-a88d-a547153aed49","DisplayName":"Messages","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"19e60d25-6014-48ca-95a9-0e0ffad9e6d4","DisplayName":"Gateway Test","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Gateway Test","Glyph":null,"Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ShowActionDialog","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Message Events","Css":"","DataQuery":{"Id":"2f0fd1d8-017a-4a7c-be35-a8c02f46007d","DisplayName":"Message Events","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":true,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"19e60d25-6014-48ca-95a9-0e0ffad9e6d4","DisplayName":"Gateway Test","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Gateway Test","Glyph":null,"Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ShowActionDialog","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Gateways Monitor","OriginalDisplayName":"Gateways Monitor","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"4eff4b79-581e-41df-a62a-ceaee89ad0f5","DisplayName":"Gateways Monitor","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"19e60d25-6014-48ca-95a9-0e0ffad9e6d4","DisplayName":"Gateway Test","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Gateway Test","Glyph":"fa fa-thermometer-full   ","Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ShowActionDialog","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null]}]',NULL,NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('16F6E129-53E1-4C83-8340-E85B888F7714','Admin_FrontaMailu','Queue of Emails',NULL,'fa fa-align-left',NULL,'AdminPageNav',5082,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"E-mails Queue","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"ee1aadfd-f66c-4bbe-892a-6335089bafa4","DisplayName":"E-mails Queue","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Color":null,"Rank":null,"Flag1":1,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"E-mails Queue"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Free agents for mail","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"e67f9717-e912-4f37-8c81-ead7c65c7800","DisplayName":"Free agents for mail","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Free agents for mail"},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Admin: Assigned messages to agents","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"f2e2995f-40ad-4fdc-a3ee-27716a48a96b","DisplayName":"Assigned messages to agents","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]}]',NULL,NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('7AC633A9-EA17-4540-8442-F363F059C526','Admin_Agenti','Agents','Teams Queues',NULL,NULL,'AdminPageNav',5020,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12","FixedTopHeight":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true,"Navbar":false},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"List of Agents","Css":"col-md-10 col-sm-10 col-xs-10","DataQuery":{"Id":"ec5174c1-ad19-4423-8fff-ae043dc92627","DisplayName":"List of Agents","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":30,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":120,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":"fa fa-cubes","MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ColumnWidthUnit":"Percents","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"List of Agents"}]',NULL,NULL,0)
INSERT INTO [Portal] ([PortalId],[HashPage],[DisplayName],[Description],[Glyph],[KbTagId],[NavGroup],[Rank],[TimeOut],[JsonData],[Title],[ExternalUrl],[Version])VALUES('014288D4-C3FE-433E-93DA-FDE0FCE3C0E0','Admin_Kontakt','Contacts',NULL,'fa fa-user',NULL,'AdminPageNav',5055,NULL,'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"PhoneBooks","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"1ff2043b-8f15-42a8-bb25-27e584b21061","DisplayName":"PhoneBooks","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"PhoneBooks"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"List of telephone numbers","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"19627bb1-4299-4a30-87ea-63c2e25fb52c","DisplayName":"List of telephone numbers","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"873404dd-0641-46b0-b8f4-3f6b33bf348c","DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","Glyph":"fa fa-thermometer-full","Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ImmediatelyExecuteAndMonitor","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"List of telephone numbers"}]',NULL,NULL,0)
/*
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'af62bfee-171b-489b-9e29-19232d11d71d', N'Admin_KontSys', N'Inspection system', NULL, N'fa fa-bug', NULL, N'AdminPageNav', 5060, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Eventlog","Css":"","DataQuery":{"Id":"1fe47865-ad21-4ec7-8cf9-3841dd6efac7","DisplayName":"Eventlog","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"F","DisplayName":"Results of Actions","Css":"","DataQuery":{"Id":"4c9e5e61-f17a-4ce1-9bb4-441c8ad8f83e","DisplayName":"Results of Actions","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":5,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":[],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Admin Commands","Css":"","DataQuery":{"Id":"61c8ebc7-e7be-42b2-88b5-578479d8c30a","DisplayName":"Admin Commands","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":[],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"G","DisplayName":"Web Admin Changes","OriginalDisplayName":"Web Admin Changes","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"a10ad2c8-64cb-4aff-b937-69cffe292dba","DisplayName":"Web Admin Changes","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":[],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"E","DisplayName":"Detected problems","OriginalDisplayName":"Detected problems","Css":"col-md-12 col-sm-12 col-xs-12","Glyph":null,"DataQuery":{"Id":"da89c2b0-f74d-4b41-8589-5491c8239a29","DisplayName":"Detected problems","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Monitoring System","OriginalDisplayName":"Monitoring System","Css":"col-md-12 col-sm-12 col-xs-12","Glyph":null,"DataQuery":{"Id":"77f81f33-c8a9-4883-a480-c3d29d8541cc","DisplayName":"Monitoring System","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]', NULL, NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'77547454-f322-4658-b67f-1a9f038231c5', N'Admin_Wallboard', N'Wallboards', NULL, N'fa fa-bar-chart', NULL, N'AdminPageNav', 5070, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Wallboard","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"372f67e1-c08d-49da-a1ce-89e875a1d68b","DisplayName":"Wallboard","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Wallboard Times","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"1c043f8c-2616-4293-8467-2422bf171ae7","DisplayName":"Wallboard Times","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":[],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Zvolený režim v IVR Datart","OriginalDisplayName":"Zvolený režim v IVR Datart","Css":"col-md-12 col-sm-12 col-xs-12","Glyph":null,"DataQuery":{"Id":"4f9cef83-c3a4-495b-a24b-90bd7606b878","DisplayName":"Zvolený režim v IVR Datart","SpecificName":"SupervizorPage","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"None","ShowFilters":"None","ShowFooter":"None","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]', NULL, NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'a941d991-9d2e-427f-b230-443b4445b041', N'Admin_IVR', N'IVR', NULL, N'fa fa-phone', NULL, N'AdminPageNav', 5050, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"IVR Scripts","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"b37e3ad0-c8e3-4083-a23a-0e18686076b6","DisplayName":"IVR Scripts","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"IVR Scripts"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"IVR Steps","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"d45fde09-0bf3-4418-bf50-7f11f3e5c0e5","DisplayName":"IVR Steps","SpecificName":"Admin","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"873404dd-0641-46b0-b8f4-3f6b33bf348c","DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","Glyph":"fa fa-thermometer-full","Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ImmediatelyExecuteAndMonitor","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null]}]', NULL, NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'49dfe157-4a6f-4656-8bde-56499183d4d2', N'Admin_Hovory', N'Calls', NULL, N'fa fa-phone', NULL, N'AdminPageNav', 5010, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Inbound Calls","Css":"","DataQuery":{"Id":"99cecf13-c463-4abd-a52e-ad923d51ac7c","DisplayName":"Inbound Calls","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Inbound Call Events","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"882362dc-f36f-4248-ad4d-64d1a883e91a","DisplayName":"Inbound Call Events","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":30,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Inbound Call Events"},{"Type":"DataQueryGrid","Path":"A","Index":"E","DisplayName":"Admin: Outbound Calls","Css":"","DataQuery":{"Id":"ce85ccb8-d497-40ab-a067-e1561d4d7ab6","DisplayName":"Outbound Calls","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"F","DisplayName":"Outbound Call Events","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"354e10a1-14f7-4f66-b1aa-9b7ffee2b91f","DisplayName":"Outbound Call Events","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Outbound Call Events"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Admin: Recordings","Css":"","DataQuery":{"Id":"68df515a-31d7-4137-b661-9ce2c40a601a","DisplayName":"Recordings","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"G","DisplayName":"Zpětná volání","OriginalDisplayName":"Zpětná volání","Css":"col-md-4 col-sm-4 col-xs-4","Glyph":null,"DataQuery":{"Id":"dcedb66f-b5f6-4397-8bdc-286cd1399cff","DisplayName":"Zpětná volání","SpecificName":"AgentPage","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Percents"},{"Type":"DataQueryGrid","Path":"","Index":"B","DisplayName":"Zpětná volání DATART CZ (copy)","OriginalDisplayName":"Zpětná volání DATART CZ (copy)","Css":"col-md-12 col-sm-12 col-xs-12","Glyph":null,"DataQuery":{"Id":"746e29eb-fd38-443a-9a08-f22f097aef6a","DisplayName":"Zpětná volání DATART CZ (copy)","SpecificName":"AgentPage","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ResetToggleAfter":false,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"NoSpam":null,"SpamManual":null,"SpamBlocked":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Percents","TableType":null,"TargetColumn":null}]', NULL, NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'f007b5da-21c9-499f-b781-88a8950c98a9', N'admin_pripady', N'Issues', N'Issues', N'fa fa-briefcase', NULL, N'AdminPageNav', 5045, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12","FixedTopHeight":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true,"Navbar":false},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Issues","Css":"col-md-10 col-sm-10 col-xs-10","DataQuery":{"Id":"34137610-1fb2-4b82-a857-2bf1f3c05d08","DisplayName":"Issues","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":30,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":120,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":"fa fa-cubes","MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ColumnWidthUnit":"Percents","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Issues"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Issue Events","Css":"col-md-10 col-sm-10 col-xs-10","DataQuery":{"Id":"6c5e8e3f-37b1-4fc6-8c7d-233efd017f2b","DisplayName":"Issue Events","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":120,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":"fa fa-users","MessageChangeMeta":"fa fa-cubes","MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ColumnWidthUnit":"Percents","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"956bd651-5e05-4019-b394-dd33bf1c68d1","DisplayName":"Není SPAM","Glyph":null,"SpecificName":"Message"},"ActionItem":{"Id":null,"DisplayName":"Není SPAM","Glyph":"fa fa-thumbs-up","Rank":0,"SpecificName":null},"ExecuteType":"ImmediatelyExecuteAndMonitor","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Issue Events"}]', N'Issues', NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'54ba365c-f98f-494f-8857-9c85eeb8686e', N'admin_Record', N'Recordings', N'Recordings', N'fa fa-microphone', NULL, N'AdminPageNav', 5090, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Admin Recordingless Calls","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"a12aae6c-caef-4ba1-a117-221b2a6c1f75","DisplayName":"Admin Recordingless Calls","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Percents","ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Admin Recordingless Calls"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true}]', NULL, NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'd0c44ccf-5260-4b1b-8f8e-a52a3fe10073', N'Admin_FrontaHovoru', N'Queue of Calls', NULL, N'fa fa-align-left', NULL, N'AdminPageNav', 5080, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Queue investigation","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"832e1da3-c87e-4e51-a7a6-ca1ec2abcdfd","DisplayName":"Queue investigation","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Free agents","Css":"col-md-8 col-sm-8 col-xs-8","DataQuery":{"Id":"9e103b6f-379b-417c-8ec7-2361ef3124ed","DisplayName":"Free agents","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Free agents seznam","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"50baed36-ca55-46b5-a971-45996d7b52f0","DisplayName":"Free agents seznam","SpecificName":"Supervizor","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]}]', NULL, NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'873b377f-11b3-4142-9063-b7db635d52d0', N'Admin_DQ', N'Data Query', NULL, N'fa fa-calendar', NULL, N'AdminPageNav', 5030, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Queries","Css":"","DataQuery":{"Id":"e5fe7ca3-06f1-46a4-9771-09cb4bfc43eb","DisplayName":"Data Queries","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null]},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Data Queries Columns","Css":"","DataQuery":{"Id":"d1f1f295-8801-423b-aafd-9222ee4892fc","DisplayName":"Data Queries Columns","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Data Queries Columns"}]', NULL, NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'9ff03aae-a127-47e1-8a41-d491de622d2f', N'admin_expimp', N'Dataquery Usage', N'Dataquery Usage', N'fa fa-exchange', NULL, N'AdminPageNav', 5090, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Color":null,"Rank":null,"Flag1":1,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"Data Query usage"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true}]', N'Export/Import', NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'7f649a00-6cda-47f5-a600-dcd4195f1051', N'Admin_Email', N'Emails', NULL, N'fa fa-envelope', NULL, N'AdminPageNav', 5040, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner hlavni","Css":"col-md-12 col-sm-12 col-xs-12","FixedTopHeight":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Messages","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"05d59721-8eed-493d-a88d-a547153aed49","DisplayName":"Messages","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"19e60d25-6014-48ca-95a9-0e0ffad9e6d4","DisplayName":"Gateway Test","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Gateway Test","Glyph":null,"Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ShowActionDialog","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Message Events","Css":"","DataQuery":{"Id":"2f0fd1d8-017a-4a7c-be35-a8c02f46007d","DisplayName":"Message Events","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":true,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"19e60d25-6014-48ca-95a9-0e0ffad9e6d4","DisplayName":"Gateway Test","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Gateway Test","Glyph":null,"Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ShowActionDialog","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Nové položky - pobočky","Css":"col-md-3 col-sm-3 col-xs-3","DataQuery":{"Id":"ee93ada1-0259-48ee-b706-9777ce4e8cd3","DisplayName":"Nové položky - pobočky","SpecificName":"Nové","Glyph":"fa fa-camera-retro","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"19e60d25-6014-48ca-95a9-0e0ffad9e6d4","DisplayName":"Gateway Test","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Gateway Test","Glyph":null,"Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ShowActionDialog","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"E","DisplayName":"Gateways Monitor","OriginalDisplayName":"Gateways Monitor","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"4eff4b79-581e-41df-a62a-ceaee89ad0f5","DisplayName":"Gateways Monitor","SpecificName":"Admin","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"19e60d25-6014-48ca-95a9-0e0ffad9e6d4","DisplayName":"Gateway Test","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Gateway Test","Glyph":"fa fa-thermometer-full   ","Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ShowActionDialog","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null]},{"Type":"DataQueryGrid","Path":"A","Index":"F","DisplayName":"Moje rozpracované zprávy Test","OriginalDisplayName":"Moje rozpracované zprávy Test","Css":"col-md-12 col-sm-12 col-xs-12","Glyph":null,"DataQuery":{"Id":"146ed606-9993-4f51-8f3e-f0907a06b55e","DisplayName":"Moje rozpracované zprávy Test","SpecificName":"Portal_AgentPage","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"WindowParameters":null,"ResetToggleAfter":false,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"NoSpam":null,"SpamManual":null,"SpamBlocked":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","TableType":null,"TargetColumn":null}]', NULL, NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'7ac633a9-ea17-4540-8442-f363f059c526', N'Admin_Agenti', N'Agents', N'Teams Queues', NULL, NULL, N'AdminPageNav', 5020, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12","FixedTopHeight":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true,"Navbar":false},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"List of Agents","Css":"col-md-10 col-sm-10 col-xs-10","DataQuery":{"Id":"ec5174c1-ad19-4423-8fff-ae043dc92627","DisplayName":"List of Agents","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":30,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":120,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":"fa fa-cubes","MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ColumnWidthUnit":"Percents","ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"List of Agents"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Všechny spamy","Css":"col-md-10 col-sm-10 col-xs-10","DataQuery":{"Id":"1c035cb5-19e1-4ebe-9aa7-a8ccc2c79bfc","DisplayName":"Všechny spamy","SpecificName":"Portal_SupervisorPage","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":120,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":"fa fa-users","MessageChangeMeta":"fa fa-cubes","MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ColumnWidthUnit":"Percents","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"956bd651-5e05-4019-b394-dd33bf1c68d1","DisplayName":"Není SPAM","Glyph":null,"SpecificName":"Message"},"ActionItem":{"Id":null,"DisplayName":"Není SPAM","Glyph":"fa fa-thumbs-up","Rank":0,"SpecificName":null},"ExecuteType":"ImmediatelyExecuteAndMonitor","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null]}]', NULL, NULL, 0)
INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData], [Title], [ExternalUrl], [Version]) VALUES (N'014288d4-c3fe-433e-93da-fde0fce3c0e0', N'Admin_Kontakt', N'Contacts', NULL, N'fa fa-user', NULL, N'AdminPageNav', 5055, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"PhoneBooks","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"1ff2043b-8f15-42a8-bb25-27e584b21061","DisplayName":"PhoneBooks","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":null,"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"PhoneBooks"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"List of telephone numbers","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"19627bb1-4299-4a30-87ea-63c2e25fb52c","DisplayName":"List of telephone numbers","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Color":null,"Rank":null,"Flag1":0,"Flag2":null,"Flag3":null,"Flag4":null,"Flag5":null,"DefaultSubItem":null,"Deleted":false},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":null,"ManualActionExecuteTypes":null,"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionDefinitions":[{"Index":0,"Items":null,"Text":null,"DoAsync":false,"ActionTrigger":{"Id":"873404dd-0641-46b0-b8f4-3f6b33bf348c","DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","Glyph":null,"Color":null,"SpecificName":"ADMIN"},"ActionItem":{"Id":null,"DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","Glyph":"fa fa-thermometer-full","Color":null,"Rank":0,"SpecificName":null},"ExecuteType":"ImmediatelyExecuteAndMonitor","ActionType":"Manual","MaxTextLength":1000,"AllowNulls":true},null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"List of telephone numbers"}]', NULL, NULL, 0)
*/
	END
GO
-- Doplnění ServiceAPP DataQuery:
  IF NOT EXISTS (SELECT TOP 1 1 FROM [DataQuery] WHERE DataQueryId='73342443-45F0-4C26-AA6C-37335ADB34A4')
    BEGIN

INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('73342443-45F0-4C26-AA6C-37335ADB34A4','Události agenta','DPD','SubQuery','TimeUtc DESC','SELECT DTA.Timeutc, DTA.Kind, A.DisplayName as AgentName, W.DisplayName as WorkplaceName, DTA.Duration,
DTA.EventAgent, S.DisplayName as StatusName, 
DTA.EventCall, 
CASE WHEN DTA.InboundCallId IS NOT NULL THEN ''I-''+ll.DisplayName
	WHEN DTA.OutboundCallId IS NOT NULL THEN ''O-''+Phase.DisplayName
	ELSE NULL
	END AS CallResultX,
CASE WHEN DTA.InboundCallId IS NOT NULL THEN ''I-''+ll2.DisplayName
	WHEN DTA.OutboundCallId IS NOT NULL THEN ''O-''+Result.DisplayName
	ELSE NULL
	END AS CallPhaseX,
ISNULL(IC.CallerNumber,OC.CallerNumber) AS CallerNumber, P.DisplayName AS ProjectName,
DTA.Detail,
DTA.AgentId, DTA.WorkplaceId, ISNULL(DTA.InboundCallId, DTA.OutboundCallId) AS CallId
FROM
	(
		SELECT TimeUtc, ''Agent'' as Kind, EventType AS EventAgent, NULL as EventCall, AgentId, WorkplaceId, 
			dbo.ConcatName(NULL,Actor,ReferenceData) AS Detail, ReferenceId, NULL AS InboundCallId, NULL as OutboundCallId, Duration, ProjectId
		FROM AgentEvent WITH(NOLOCK) WHERE TimeUtc>=DATEADD(day,-7,@NowUtc) 

	UNION

		SELECT TimeUtc, ''Hovor'' as Kind, NULL AS EventAgent, EventType AS EventCall, AgentId, WorkplaceId,  
			NULL as Detail, NULL AS ReferenceId, InboundCallId, OutboundCallId, NULL AS Duration, ProjectId
		FROM CallEvent WITH(NOLOCK) WHERE AgentId IS NOT NULL AND TimeUtc>=DATEADD(day,-7,@NowUtc) 
	) AS DTA
LEFT JOIN Agent AS A ON DTA.AgentId=A.AgentId
LEFT JOIN Workplace AS W ON DTA.WorkplaceId=W.WorkplaceId
LEFT JOIN Status AS S ON DTA.ReferenceId=S.StatusId
LEFT JOIN InboundCall AS IC ON DTA.InboundCallId=IC.InboundCallId AND IC.TimeUtc>=DATEADD(day,-7,@NowUtc) and ic.AgentId IS NOT NULL
left join LiteralLookup ll2 with (nolock) on ll2.LiteralValue = ic.CallPhase and ll2.Culture = ''cs-CZ'' and ll2.LiteralGroup = 41
left join LiteralLookup ll with (nolock) on ll.LiteralValue = ic.CallResult and ll.Culture = ''cs-CZ'' and ll.LiteralGroup = 40
LEFT JOIN OutboundCall AS OC ON DTA.OutboundCallId=OC.OutboundCallId AND OC.TimeUtc>=DATEADD(day,-7,@NowUtc) and oc.AgentId IS NOT NULL
left join LiteralLookup Result with (nolock) on Result.LiteralValue = oc.CallResult and Result.Culture = ''en-US'' and Result.LiteralGroup = 42
left join LiteralLookup Phase with (nolock) on Phase.LiteralValue = oc.CallPhase and Phase.Culture = ''en-US'' and Phase.LiteralGroup = 43
LEFT JOIN Project AS P ON DTA.ProjectId=P.ProjectId',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)

INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A42F96E4-934C-4E88-BAA0-35FA8D466530','73342443-45F0-4C26-AA6C-37335ADB34A4','Detail','Text','Detail',NULL,NULL,NULL,NULL,NULL,'Detail',NULL,0,120,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('549CC136-0C5A-4448-A0C2-F0C12D22631E','73342443-45F0-4C26-AA6C-37335ADB34A4','Čas','DateTimeUtc','TimeUtc','{0:dd.MM HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeUtc',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EC2C2A30-1E07-41CE-878E-34A1E54F0564','73342443-45F0-4C26-AA6C-37335ADB34A4','Druh','Text','Kind',NULL,NULL,NULL,NULL,NULL,'Kind',NULL,0,50,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('66BAE592-4B73-40A8-8578-921C08C2F468','73342443-45F0-4C26-AA6C-37335ADB34A4','Pracoviště','ForeignKey','WorkplaceName',NULL,NULL,NULL,'WorkplaceId','WorkplaceName','WorkplaceName',NULL,0,50,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D735319B-53E5-467A-B057-8BD278CF57C5','73342443-45F0-4C26-AA6C-37335ADB34A4','Trvání','Duration','Duration',NULL,NULL,NULL,NULL,'DurationMSS','Duration',NULL,0,50,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4C2CE50C-6987-45CC-AB96-87EC4A4479CF','73342443-45F0-4C26-AA6C-37335ADB34A4','Událost agenta','Select','EventAgent',NULL,NULL,NULL,NULL,NULL,'EventAgent',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('2E19357D-3B42-4A67-98B6-4ACEE2A2C1C3','73342443-45F0-4C26-AA6C-37335ADB34A4','Stav','Select','StatusName',NULL,NULL,NULL,NULL,NULL,'StatusName',NULL,0,70,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('37D4B2E4-B7D6-4EF8-8FC6-28FAED46FEF9','73342443-45F0-4C26-AA6C-37335ADB34A4','Událost hovoru','Select','EventCall',NULL,NULL,NULL,NULL,'CallEventType','EventCall',NULL,0,80,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('75BE869A-A1FC-45D3-ACE7-379CF0A361AB','73342443-45F0-4C26-AA6C-37335ADB34A4','St.hov.','Text','CallResultX',NULL,'CallId','/RC/Pages/calleditor.html?Id={0}',NULL,NULL,'CallResultX',NULL,0,100,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C2B229A6-8976-404E-BF96-DC8627CFE732','73342443-45F0-4C26-AA6C-37335ADB34A4','Fáze','Text','CallPhaseX',NULL,NULL,NULL,NULL,NULL,'CallPhaseX',NULL,0,100,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B07D26FC-FAF4-4F6D-B171-BA27D56022DC','73342443-45F0-4C26-AA6C-37335ADB34A4','CallerNumber','Text','CallerNumber',NULL,NULL,NULL,NULL,NULL,'CallerNumber',NULL,0,100,110,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7CA439FD-3855-453E-AFB8-E73FA943832A','73342443-45F0-4C26-AA6C-37335ADB34A4','ProjectName','Select','ProjectName',NULL,NULL,NULL,NULL,NULL,'ProjectName',NULL,0,80,120,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0AAF41B5-581A-4A31-A669-AB3F7E67D979','73342443-45F0-4C26-AA6C-37335ADB34A4','Agent','Text','AgentName',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,120,190,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B627D35B-8D52-48CF-A37D-376CF867EAD8','73342443-45F0-4C26-AA6C-37335ADB34A4','Agent','QueryId','AgentId',NULL,NULL,NULL,'AgentId','AgentName','AgentName',NULL,0,80,200,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

  END
 DECLARE @HardRun AS bit=0
  IF NOT EXISTS (SELECT TOP 1 1 FROM [DataQuery] WHERE QueryGroup='ServiceAPP') OR @HardRun=1
    BEGIN
	INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','Data Queries',NULL,'ServiceAPP','DisplayName','SELECT  [DataQueryId]              ,[DisplayName]              ,[Description]              ,[QueryGroup]              ,[QuerySortExpression]              ,[QueryText]              ,[ManualFilter]              ,[SnapshotInterval]              ,[TimeLine]              ,[Deleted]              ,[CacheInterval]          FROM .[dbo].[DataQuery] WHERE Deleted=0',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('B37E3AD0-C8E3-4083-A23A-0E18686076B6','IVR Scripts',NULL,'ServiceAPP','DisplayName','SELECT DISTINCT IVR.[IvrScriptId] ,IVR.[IvrScriptId] AS RecordId              , ''1'' AS ProvedAkci              ,IVR.[DisplayName]              ,[Description]              ,[IvrMachine]              ,[ScenarioId]            ,CAST(IIF(IVR.IvrScriptId=CONVERT(UniqueIdentifier,.dbo.FSC_GiveParam(''SELECTED_IVR'')), 1,0) AS bit) AS IsSelected      ,IIF(PC.IvrScriptAId IS NULL AND IVS.TargetId IS NULL,''NO'',''YES'') AS IsUsed            FROM .[dbo].[IvrScript] IVR     LEFT JOIN .[dbo].[PreCondition] PC ON PC.IvrScriptAId=IVR.IvrScriptId         LEFT JOIN .[dbo].[IVRStep] IVS ON IVS.TargetId=IVR.IvrScriptId       WHERE IVR.Deleted=0',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','Admin Recordingless Calls',NULL,'ServiceAPP','CallTime DESC','SELECT * FROM .[dbo].[FSC_RecordingLessCalls] (DATEADD(Day,-2,@Today),@Now)',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('6C5E8E3F-37B1-4FC6-8C7D-233EFD017F2B','Issue Events',NULL,'ServiceAPP','TimeLocal','SELECT ISU.[IssueId]        ,PROJ.DisplayName AS Projekt        ,IE.[TimeUtc] AS TimeLocal        ,[EventType]        ,IE.[AgentId]        ,AG.DisplayName AS AgentName        ,[ReferenceData]        ,[ReferenceId]     ,ContactId    FROM .[dbo].[IssueEvent] IE       LEFT JOIN Issue ISU ON ISU.IssueId=IE.IssueId    LEFT JOIN Project PROJ ON PROJ.ProjectId=ISU.ProjectId    LEFT JOIN Agent AG ON IE.AgentId=AG.AgentId  ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('9E103B6F-379B-417C-8EC7-2361EF3124ED','Free agents',NULL,'ServiceAPP','AgentName','SELECT * FROM .[dbo].FSC_VolniAgentiCall()',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('1C043F8C-2616-4293-8467-2422BF171AE7','Wallboard Times','Administrátorský WB -  časy','ServiceAPP','Popis','SELECT       ''Average time to send emails in the last 30 minutes'' AS Popis,     AVG(Seconds) AS Seconds FROM     ( SELECT       DATEDIFF(SECOND,ME.TimeUTC,ReceivedSentTime) AS Seconds        FROM .dbo.Message ME     INNER JOIN MessageEvent MEE WITH (NOLOCK) ON MEE.MessageId=ME.MessageId AND MEE.EVentType=25       WHERE Direction=''O'' AND EndTime>DATEADD(Minute,-30,@NowUTC) AND ME.MessagePhase=10      ) AS Phase1        UNION ALL      SELECT       ''Maximum time to send emails in the last 30 minutes'' AS Popis,     MAX(Seconds) AS Seconds FROM      ( SELECT       DATEDIFF(SECOND,ME.TimeUTC,ReceivedSentTime) AS Seconds        FROM .dbo.Message ME     INNER JOIN MessageEvent MEE WITH (NOLOCK) ON MEE.MessageId=ME.MessageId AND MEE.EVentType=25       WHERE Direction=''O'' AND EndTime>DATEADD(Minute,-30,@NowUTC) AND ME.MessagePhase=10      ) AS Phase1  ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('F2E2995F-40AD-4FDC-A3EE-27716A48A96B','Assigned messages to agents',NULL,'ServiceAPP','TimeUtc DESC','SELECT         c.Description, m.MessageId, M.TimeUtc, M.MessageType, M.MessagePhase, M.Direction, M.RemoteAddress,        M.FromField, M.ToField, M.ToCcField, M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,       M.ProjectId, M.GatewayId, M.AgentId, M.TeamName,       c.CompanyName as ICO_RC, M.LanguageId, P.DisplayName AS ProjectName, G.DisplayName AS GatewayName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName,       ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,       CAST(CASE WHEN MessageResult=0 THEN 1 ELSE 0 END AS bit) AS IsActive,       CAST(CASE WHEN MessagePhase=7 OR MessagePhase=1 THEN 1 ELSE 0 END AS bit) AS IsNew,       CAST(CASE WHEN (MessagePhase=2 OR MessagePhase=1) AND ReceivedSentTime<getdate() THEN 1 ELSE 0 END AS bit) AS IsLate,  CASE WHEN EXISTS(SELECT TOP 1 1 AS Nic From Attachment WITH(NOLOCK) WHERE M.MessageId=Attachment.MessageId) THEN ''fa fa-paperclip'' ELSE NULL END AS HasAttachment,       (SELECT TOP 1 TimeUtc FROM MessageEvent ME with (NOLOCK) WHERE M.MessageId=ME.MessageId AND ME.EventType=36 ORDER BY TimeUtc DESC) AS CasPrirazeni,       (SELECT TOP 1 ResultData FROM MessageEvent ME with (NOLOCK) WHERE M.MessageId=ME.MessageId AND ME.EventType=36 ORDER BY TimeUtc DESC) AS ResultData ,IIF(SpamLevel>0,''YES'',''NO'') AS Spam       FROM Message AS M        LEFT JOIN Project AS P ON M.ProjectId=P.ProjectId       LEFT JOIN Gateway AS G ON M.GatewayId=G.GatewayId       LEFT JOIN Agent AS A ON M.AgentId=A.AgentId       LEFT JOIN Language AS L ON M.LanguageId=L.LanguageId       LEFT JOIN Contact as C with (NOLOCK) on c.Contactid=m.ContactId              WHERE MessageType IN (1,2) AND M.AGENTID IS NOT NULL AND MessageResult=0 AND M.Direction=''I''',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('1FF2043B-8F15-42A8-BB25-27E584B21061','PhoneBooks',NULL,'ServiceAPP','DisplayName','SELECT        PhoneBookId AS RecordId           , ''1'' AS ProvedAkci           ,[DisplayName]          ,[Description]          ,CAST(IIF(PhoneBookId=CONVERT(UniqueIdentifier,.dbo.FSC_GiveParam(''SELECTEDPHONEBOOK'')), 1,0) AS bit) AS IsSelected      FROM .[dbo].[PhoneBook] WITH (NOLOCK)',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('34137610-1FB2-4B82-A857-2BF1F3C05D08','Issues',NULL,'ServiceAPP','NewTime DESC','SELECT I.IssueId, I.TopicId, I.SubTopicId, I.PhaseId, I.AgentId, I.ProjectId, I.Activity, I.NewTime, P.DisplayName as ProjectName,  A.DisplayName as AgentName,  A.TeamName AS Team, T.DisplayName as TopicName,  ST.DisplayName as SubTopicName,  PH.DisplayName as PhaseName,   CAST(CASE WHEN I.PhaseID=''BFC21976-8923-41E9-BAA7-43298621531E'' THEN 1 ELSE 0 END AS bit) AS Returned  , CAST(CASE WHEN I.PhaseID=''78B2953D-D870-4F78-AB52-3DE00CF59B40'' THEN 1 ELSE 0 END AS bit) AS Doplnit  ,CAST(CASE WHEN exists (select top 1 1 from message m  with (nolock) where MessagePhase=1 and MessageResult=0 and m.IssueId=i.IssueId and m.Direction=''I'')THEN 1 ELSE 0 END AS bit) AS NewMessage   , CAST(CASE WHEN I.Activity<>5/*''Closed''*/ THEN 1 ELSE 0 END AS bit) AS IsActive    ,CAST(CASE WHEN (I.Activity<>5/*''Closed''*/) AND I.NewTime<@LastWeek THEN 1 ELSE 0 END AS bit) AS IsLate  FROM Issue as I WITH(NOLOCK) LEFT JOIN Topic AS T WITH(NOLOCK) ON I.TopicId=T.TopicId LEFT JOIN SubTopic AS ST WITH(NOLOCK) ON I.SubTopicId =ST.SubTopicId LEFT JOIN Phase AS PH WITH(NOLOCK) ON I.PhaseId = PH.PhaseId LEFT JOIN Project AS P WITH(NOLOCK) ON I.ProjectId=P.ProjectId LEFT JOIN Agent AS A WITH(NOLOCK) ON I.AgentId=A.AgentId WHERE NewTime>DATEADD(Month,-6,@Today)',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('2BD46080-CE8D-4C10-8B4D-3772417F57D8','Calls Queue investigation','Investigation','ServiceAPP','RegionalTime','SELECT DISTINCT InboundCallId          ,RegionalTime          , CallerNumber           ,QueueDuration           ,PilotName               ,P.DisplayName AS ProjectName     , Agent.DisplayName AS AgentName     FROM    (SELECT InboundCallId           ,RegionalTime           ,QueueDuration           ,Pil.DisplayName AS PilotName           ,CallerNumber          ,CallType          ,CallPhase          ,CallResult          ,ProjectId          ,Skill          ,PreferredAgentId          ,AgentId          ,TeamName          ,IC.LanguageId      FROM InboundCall IC WITH (NOLOCK)      LEFT JOIN Pilot Pil  WITH (NOLOCK)    ON Pil.PilotId=IC.PilotId      WHERE IC.CallPhase IN (23) AND CallResult=0)  Fronta      LEFT OUTER JOIN Skill  WITH (NOLOCK)     ON Skill.ProjectId=Fronta.ProjectId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1         LEFT OUTER JOIN Project P  WITH (NOLOCK)    ON P.ProjectId=Fronta.ProjectId         LEFT OUTER JOIN Agent  WITH (NOLOCK)    ON Agent.AgentId=Skill.AgentId AND Agent.Activity=''Ready'' AND (SELECT Activity FROM Status WHERE Status.StatusId=Agent.StatusId)=''Ready''                     AND (SELECT State FROM WorkPlace AS W WHERE Agent.WorkplaceId = W.WorkplaceId)=''Free''          LEFT JOIN Proficiency AS PROF  WITH (NOLOCK)    ON PROF.AgentId=Agent.AgentId AND PROF.LanguageId=FRONTA.LanguageId AND PROF.VoiceKnowledge>0 AND PROF.VoiceEnabled=1 AND PROF.VoiceChannel=1  ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('1FE47865-AD21-4EC7-8CF9-3841DD6EFAC7','Eventlog','Prohlížení Eventlogu','ServiceAPP','DatumCas  DESC','select    * FROM .dbo.FSC_Eventlog',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('4C9E5E61-F17A-4CE1-9BB4-441C8AD8F83E','Results of Actions',NULL,'ServiceAPP','Message','SELECT * FROM Results   ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('50BAED36-CA55-46B5-A971-45996D7B52F0','Free agents list',NULL,'ServiceAPP','AgentName','SELECT  DISTINCT       A.DisplayName AS AgentName       FROM Agent A  WITH (NOLOCK)           LEFT OUTER JOIN Skill  WITH (NOLOCK)  ON Skill.AgentId=A.AgentId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1        LEFT OUTER JOIN Project P  WITH (NOLOCK)   ON P.ProjectId=Skill.ProjectId       WHERE A.AgentId=Skill.AgentId AND A.Activity=''Ready'' AND (SELECT Activity FROM Status WHERE Status.StatusId=A.StatusId)=''Ready''                   AND (SELECT State FROM WorkPlace AS W WHERE A.WorkplaceId = W.WorkplaceId)=''Free''     ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('A5134A50-8053-4921-BD42-538C7B175934','Volní agenti Outbound',NULL,'ServiceAPP','AgentName','SELECT        IIF(ST.Activity=''Ready''       AND W.State=''Free''    AND Skill.PbxOutKnowledge>0    AND Skill.PbxOutEnabled>0    AND Skill.PbxOutChannel>0         ,''YES'',''NO '') AS FreeAgent,         A.DisplayName AS AgentName       , TeamName       , P.DisplayName AS ProjectName    ,Skill.PbxOutKnowledge     ,Skill.PbxOutEnabled    ,Skill.PbxOutChannel     ,A.Activity     ,W.State       FROM Agent A  WITH (NOLOCK)           LEFT OUTER JOIN Skill  WITH (NOLOCK) ON Skill.AgentId=A.AgentId         LEFT OUTER JOIN Project P  WITH (NOLOCK) ON P.ProjectId=Skill.ProjectId     LEFT OUTER JOIN Status ST  WITH (NOLOCK) ON ST.StatusId=A.StatusId     LEFT OUTER JOIN WorkPlace W WITH (NOLOCK) ON A.WorkplaceId = W.WorkplaceId       WHERE A.AgentId=Skill.AgentId',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('DA89C2B0-F74D-4B41-8589-5491C8239A29','Detected problems',NULL,'ServiceAPP','Timelocal DESC','SELECT TOP (1000) [Timelocal]        ,[RepeatAfter]        ,[Message]    FROM .[dbo].[FSC_ErrorLog] ORDER BY Timelocal DESC',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('61C8EBC7-E7BE-42B2-88B5-578479D8C30A','Admin Commands',NULL,'ServiceAPP','Description','SELECT CommandId AS RecordId               , ''1'' AS ProvedAkci               ,Description          FROM .dbo.FSC_Commands   ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('EE1AADFD-F66C-4BBE-892A-6335089BAFA4','E-mails Queue',NULL,'ServiceAPP','TimeUtc DESC','SELECT distinct   c.Description, @MeTeamName AS MujTym,m.MessageId, M.TimeUtc, M.MessageType, M.MessagePhase, M.Direction, M.RemoteAddress,   M.FromField, M.ToField, M.ToCcField, M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,  M.ProjectId, M.GatewayId, M.AgentId, M.TeamName,  c.CompanyName as ICO_RC, M.LanguageId, P.DisplayName AS ProjectName, G.DisplayName AS GatewayName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName,  ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,  CAST(CASE WHEN MessageResult=0 THEN 1 ELSE 0 END AS bit) AS IsActive,  CAST(CASE WHEN MessagePhase=7 OR MessagePhase=1 THEN 1 ELSE 0 END AS bit) AS IsNew,  CAST(CASE WHEN (MessagePhase=2 OR MessagePhase=1) AND ReceivedSentTime<getdate() THEN 1 ELSE 0 END AS bit) AS IsLate,  CAST(CASE WHEN EXISTS(SELECT * From Attachment WHERE M.MessageId=Attachment.MessageId) THEN 1 ELSE 0 END AS bit) AS HasAttachment    FROM Message AS M   LEFT JOIN Project AS P ON M.ProjectId=P.ProjectId  LEFT JOIN Gateway AS G ON M.GatewayId=G.GatewayId  LEFT JOIN Agent AS A ON M.AgentId=A.AgentId  LEFT JOIN Language AS L ON M.LanguageId=L.LanguageId  LEFT JOIN ScenarioResult AS SR WITH(NOLOCK) ON SR.MessageId=M.MessageId  LEFT JOIN Contact as C with (NOLOCK) on c.Contactid=m.ContactId  WHERE MessageType =1 AND M.AGENTID IS NULL AND M.DIRECTION =''I'' AND MessagePhase <> 12/*''Canceled''*/ and (m.spamlevel is null or m.spamlevel = 0) and m.messageResult<>2/*''Closed'' */',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('19627BB1-4299-4A30-87EA-63C2E25FB52C','List of telephone numbers',NULL,'ServiceAPP','DisplayName','select  PN.PhoneNumberId AS RecordId,PN.DisplayName, PN.Description, [Rank]          , ''1'' AS ProvedAkci             ,[Numbers]          ,[Emails]      ,.dbo.[FSC_GetPhoneNumPhoneBooks](PN.PhoneNumberId) as PhoneBookName       from .[dbo].[PhoneNumber] PN WITH (NOLOCK)      LEFT JOIN PhoneComposition AS PC WITH (NOLOCK) ON PC.PhoneNumberId = PN.PhoneNumberId      LEFT JOIN PhoneBook AS PB WITH (NOLOCK) ON PB.PhoneBookId = PC.PhoneBookId      where PN.Deleted=0',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('882362DC-F36F-4248-AD4D-64D1A883E91A','Inbound Call Events',NULL,'ServiceAPP','TimeLocal','SELECT   CAE.InboundCallId   ,CAE.TimeUTC AS TimeLocal  , EventType   , LL.DisplayName AS cEventType   , IVRST.Rank AS Navesti  , IVRST.Action AS Akce  , IVRST.DisplayName AS Ivrkrok  , IVRST.FileName AS Hlaska  , IVRSC.DisplayName AS IvrSkript  , PR.DisplayName AS ProjectName   , AG.DisplayName AS AgentName   , WP.DisplayName AS WorkPlaceName   , ReferenceData   , Duration   , ResultData  , IC.CallerNumber   FROM .dbo.CallEvent AS CAE WITH (NOLOCK)  LEFT JOIN IvrStep AS IVRST  WITH (NOLOCK)ON IVRST.IvrStepId=CAE.ReferenceId  LEFT JOIN IvrScript AS IVRSC  WITH (NOLOCK) ON IVRST.IvrScriptId=IVRSC.IvrScriptId  LEFT JOIN InboundCall AS IC  WITH (NOLOCK) ON IC.InboundCallId=CAE.InboundCallId  LEFT JOIN Project AS PR  WITH (NOLOCK) ON PR.ProjectId=CAE.ProjectId  LEFT JOIN Agent AS AG  WITH (NOLOCK) ON AG.AgentId=CAE.AgentId  LEFT JOIN Workplace AS WP  WITH (NOLOCK) ON WP.WorkPlaceId=CAE.WorkPlaceId  LEFT JOIN LiteralLookup AS LL ON CAE.EventType=LL.LiteralValue AND LL.LiteralGroup = 44 AND LL.Culture = ''cs-CZ''  WHERE CAE.InboundCallId IS NOT NULL AND CAE.TimeUTC>DATEADD(Month,-1,@today)    ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('A10AD2C8-64CB-4AFF-B937-69CFFE292DBA','Web Admin Changes','over WebAdmin app','ServiceAPP','TimeUTC DESC','SELECT          AG.DisplayName AS AgentName        ,[TimeUtc]        ,[TableNames]        ,[RefInserts]        ,[RefUpdates]        ,[RefDeletes]         FROM .[dbo].[AdminEvent] WAE      LEFT JOIN .[dbo].Agent AG ON AG.AgentId=WAE.ActorId  ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('2ECAA8BB-0E67-4F5E-817A-7DD0E020C2C6','Data Query usage',NULL,'ServiceAPP','PageName,NAVGroup,DataQueryId','SELECT         [DataQueryId] AS DQid        ,ISNULL(PRT.DisplayName,''--- Nepoužito ---'') AS PageName        ,PRT.NAVGroup        ,PRT.HashPage        ,[DataQueryId]        ,DQ.DisplayName AS QueryName        ,DQ.[Description]        ,[QueryGroup]    FROM .[dbo].[DataQuery] DQ      LEFT JOIN .[dbo].[Portal] PRT ON PRT.JsonData LIKE ''%''+CONVERT(NVARCHAR(36),DQ.DataQueryId)+''%''   WHERE Deleted=0',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','IVR Steps','IVR Step','ServiceAPP','ScriptName,Rank','SELECT                IVST.IVRScriptId,                IVST.IVRStepId,                IVSC.DisplayName AS ScriptName                ,IVST.DisplayName AS StepName             ,Rank                ,Action                ,TimeOut                ,WaitTimeOut                ,FileName                ,MultiLanguage                ,Retries                ,ResultDigits                ,SkipDigits                ,ReplayDigits                ,Targets                ,TargetId             ,(SELECT DisplayName FROM IvrScript WHERE IvrScriptId=TargetId) As VolanySkript                ,Numbers                ,TimeMode                ,TimeFrom                ,TimeTo                ,Culture                ,TargetOnTimeOut                ,TargetOnSuccess                ,TargetOnFailure            FROM .dbo.IvrStep IVST WITH (NOLOCK)            LEFT JOIN IvrScript IVSC WITH (NOLOCK) ON IVSC.IvrScriptId=IVST.IvrScriptId          WHERE IVST.Deleted = 0 AND IVSC.Deleted = 0',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('372F67E1-C08D-49DA-A1CE-89E875A1D68B','Wallboard','Administrátorský WB - počty','ServiceAPP','Popis','SELECT ''Zombie Calls'' AS Popis, COUNT(1) AS Pocet FROM .[dbo].[InboundCall]    WHERE 1=1      AND Callresult=0      AND CallPhase=21      AND PilotTime < DATEADD(Minute,-20,GETDATE())    UNION ALL    SELECT ''Agent change when distributing an incoming call in the last 2 hours'' AS Popis, COUNT(1) AS Value      FROM .[dbo].[CallEvent] CAE        LEFT JOIN .[dbo].[CallEvent] CAE2 ON CAE.InboundCallId=CAE2.InboundCallId     AND CAE2.EventType=20       WHERE 1=1      AND CAE.TimeUTC>DATEADD(Hour,-2,@NowUTC)      AND CAE.EventType=54 /*''IssueChange'' */     AND CAE.ResultData=''AUTO''      AND CAE.AgentId<>CAE2.AgentId    UNION ALL   SELECT ''The number of scheduled outgoing messages in the last 5 days and should have left'' AS Popis, COUNT(1) AS Value      FROM .dbo.Message ME       WHERE 1=1      AND ME.Direction=''O''      AND TimeUTC > DATEADD(Day,-5,@NowUTC)      AND (ME.ScheduledTime<@NowUTC OR ME.ScheduledTime IS NULL)      AND (ME.MessagePhase=8)      AND ME.MessageResult=0   UNION ALL    SELECT ''The number of scheduled outgoing messages in the last 5 days and the time of departure has not yet come'' AS Popis, COUNT(1) AS Value      FROM .dbo.Message ME       WHERE 1=1      AND ME.Direction=''O''      AND TimeUTC > DATEADD(Day,-5,@NowUTC)      AND (ME.ScheduledTime>@NowUTC)      AND (ME.MessagePhase=8)      AND ME.MessageResult=0   UNION ALL    SELECT ''The number of outgoing messages in the last 5 days that failed'' AS Popis, COUNT(1) AS Value      FROM .dbo.Message ME       WHERE 1=1      AND ME.Direction=''O''      AND TimeUTC > DATEADD(Day,-5,@NowUTC)      AND (ME.ScheduledTime<@NowUTC)      AND (ME.MessagePhase=9 /*''Failed''*/ )  ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('D1F1F295-8801-423B-AAFD-9222EE4892FC','Data Queries Columns',NULL,'ServiceAPP','Rank','      SELECT  [DataQueryColumnId]              ,DQ.[DisplayName] AS DQName              ,DQ.QueryGroup               ,DQC.[DataQueryId]              ,DQC.[DisplayName]              ,[Model]              ,[TargetColumn]              ,[TargetFormat]              ,[UrlColumn]              ,[UrlFormat]              ,[GuidColumn]              ,[Convertor]              ,[SortExpression]              ,[SortExpressionDesc]              ,[NoFilter]              ,[Width]              ,[Rank]              ,[Color]              ,[SqlCmd]              ,[Css]              ,[ToolTip]              ,[LiteralGroup]              ,[GlyphColumn]              ,[GlyphFormat]          FROM .[dbo].[DataQueryColumn] DQC      inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId      WHERE DQC.Deleted=0  ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('F66FF314-27AB-4330-AFFA-937B005A0B47','List of telephone numbers for export',NULL,'ServiceAPP','DisplayName','select PN.PhoneNumberId, PN.DisplayName, PN.Description, [Rank]             ,[Numbers]          ,[Emails]       ,PB.DisplayName AS PhoneBookName       from .[dbo].[PhoneNumber] PN WITH (NOLOCK)      LEFT JOIN .dbo.PhoneComposition AS PC WITH (NOLOCK) ON PC.PhoneNumberId = PN.PhoneNumberId      LEFT JOIN .dbo.PhoneBook AS PB WITH (NOLOCK) ON PB.PhoneBookId = PC.PhoneBookId      where PN.Deleted=0 AND PC.PhoneNumberId IS NOT NULL',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('354E10A1-14F7-4F66-B1AA-9B7FFEE2B91F','Outbound Call Events',NULL,'ServiceAPP','TimeLocal','SELECT              OutboundCallId           , TimeUTC AS TimeLocal            , EventType             , LL.DisplayName AS cEventType             , ProjectId             , AgentId             , WorkplaceId             , ReferenceData             , Duration             , ResultData         FROM  CallEvent  AS CAE         LEFT JOIN LiteralLookup AS LL ON CAE.EventType=LL.LiteralValue AND LL.LiteralGroup = 44 AND LL.Culture = ''cs-CZ''  ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('68DF515A-31D7-4137-B661-9CE2C40A601A','Recordings',NULL,'ServiceAPP','TimeUTC DESC','SELECT [VoiceRecordId]          ,[TimeUtc]          ,[StartTimeUtc]          ,[EndTimeUtc]          ,DATEDIFF(ss,StartTimeUtc,EndTimeUtc) AS Duration          ,IIF(Agentid IS NULL,''NO'',''YES'') AS Sparovano          ,[FileName]          ,[Direction]          ,[LocalNumber]          ,[LocalName]          ,[RemoteNumber]          ,[RemoteName]          ,[ExtensionNumber]           ,[AgentId]          ,[StationName]       FROM .[dbo].[VoiceRecord]',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('05D59721-8EED-493D-A88D-A547153AED49','Messages','ADMIN - zprávy','ServiceAPP','TimeUtc DESC','SELECT M.MessageId, M.TimeUtc, M.MessageType, M.MessagePhase, M.Direction,    M.FromField, M.ToField, M.ToCcField,       M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,  M.ProjectId, M.GatewayId, M.AgentId, M.TeamName, M.LanguageId, M.IssueId,  P.DisplayName AS ProjectName, G.DisplayName AS GatewayName,        A.DisplayName AS AgentName, L.DisplayName AS LanguageName,  ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,  CAST(CASE WHEN MessageResult=0 THEN 1 ELSE 0 END AS bit) AS IsActive,          CAST(CASE WHEN MessagePhase=7 OR MessagePhase=1 THEN 1 ELSE 0 END AS bit) AS IsNew,         CAST(CASE WHEN (MessagePhase=2 OR MessagePhase=1) AND ReceivedSentTime<@Today THEN 1 ELSE 0 END AS bit) AS IsLate,           CAST(CASE WHEN EXISTS(SELECT * From Attachment WHERE M.MessageId=Attachment.MessageId) THEN 1 ELSE 0 END AS bit) AS HasAttachment,         ISU.OpenTime AS IsuOpenTime,                M.RelatedMessageId,            M.RemoteAddress          FROM Message AS M   LEFT JOIN Project AS P ON M.ProjectId=P.ProjectId            LEFT JOIN Gateway AS G ON M.GatewayId=G.GatewayId          LEFT JOIN Agent AS A ON M.AgentId=A.AgentId          LEFT JOIN Language AS L ON M.LanguageId=L.LanguageId          LEFT JOIN Issue AS ISU ON M.IssueId=ISU.IssueId            LEFT JOIN ScenarioResult AS SR ON SR.MessageId=M.MessageId AND (SR.ScenarioId=  ''f1cb5e2f-543f-4cd5-9df1-5365bde8066e'')',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('2F0FD1D8-017A-4A7C-BE35-A8C02F46007D','Message Events','MessageEvent','ServiceAPP','TimeUTC','SELECT [MessageEventId]          ,[TimeUtc]         /* ,[TimeLocal]*/          , AG.DisplayName          ,[EventType]          ,[MessageId]          ,PR.[DisplayName] AS ProjectName          ,ME.[AgentId]          ,[ReferenceData]          ,[ReferenceId]          ,[Duration]          ,[ResultData]      FROM [dbo].[MessageEvent] AS ME WITH (NOLOCK)    LEFT OUTER JOIN Agent AS AG  WITH (NOLOCK) ON ME.AgentId=AG.AgentId    LEFT OUTER JOIN Project AS PR  WITH (NOLOCK) ON ME.ProjectId=PR.ProjectId',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('99CECF13-C463-4ABD-A52E-AD923D51AC7C','Inbound Calls',NULL,'ServiceAPP','TimeUtc DESC','SELECT DISTINCT     C.InboundCallId, C.TimeUtc, C.CallPhase, C.CallResult, C.CallerNumber, C.IssueId,     C.ProjectId, C.LanguageId, C.AgentId, C.WorkplaceId,    C.CallDuration, C.PilotTime, PIL.DisplayName AS PilotName, WQ.DisplayName AS WQueueName, C.ChainingId,    P.DisplayName AS ProjectName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName, W.DisplayName AS WorkplaceName,    CAST(CASE WHEN CallResult=0 THEN 1 ELSE 0 END AS bit) AS IsActive,    CAST(CASE WHEN CallResult=1 THEN 1 ELSE 0 END AS bit) AS IsLost,    S.DisplayName as Afterwork,      T.DisplayName as Téma, S.DisplayName as Podtéma,    C.Redirector,    IIF(LEN(C.CallerNumber)>10,''YES'',''NO'') AS Zahranicni,    IIF(CR.InboundCallId IS NOT NULL,''YES'',''NO'') AS ExRecording      FROM InboundCall AS C  WITH (NOLOCK)    LEFT JOIN Project AS P ON C.ProjectId=P.ProjectId    LEFT JOIN Agent AS A ON C.AgentId=A.AgentId    LEFT JOIN Language AS L ON C.LanguageId=L.LanguageId    LEFT JOIN Workplace AS W ON C.WorkplaceId=W.WorkplaceId    LEFT JOIN Issue AS I ON C.IssueId=I.IssueId     LEFT JOIN Topic AS T ON T.TopicId=I.TopicId    LEFT JOIN SubTopic AS S ON S.SubTopicId=I.SubTopicId    LEFT JOIN Pilot AS PIL ON PIL.PilotId=C.PilotId    LEFT JOIN WaitingQueue AS WQ ON C.WaitingQueueId=WQ.WaitingQueueId    LEFT JOIN .[dbo].[CallRecord] CR ON CR.InboundCallId=C.InboundCallId    WHERE 1=1    /*AND LEN(C.CallerNumber)>10*/',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('EC5174C1-AD19-4423-8FFF-AE043DC92627','List of Agents',NULL,'ServiceAPP','TeamName, AgentName',' SELECT AG.AgentId ,AG.AgentId AS RecordId,ST.StatusId              , ''1'' AS RESETPers   , IIF(AG.Activity=''Logoff'',NULL,MC.InTime) AS LastInCall         , NULL AS LastOutCall         , ''NO'' AS ExPerso                  , ''CANC'' AS SystemName         ,W.Number AS Extension              ,IIF(AG.Activity=''Logoff'',''NO'',''YES'') AS V_Praci         ,AG.DisplayName AS AgentName, AG.TeamName        ,ST.DisplayName AS StatusName             ,W.State AS WorkplaceStatus        ,CAST(0  AS bit) AS IsFree          ,CAST(0  AS bit) AS IsPause         ,CAST(0  AS bit) AS IsRinging         ,CAST(0  AS bit) AS IsBusy         ,CAST(0  AS bit) AS IsPCP            /*            ,(SELECT MAX(EnqueueingTime) FROM           (SELECT DistributionTime FROM .dbo.InboundCall WITH(NOLOCK)             WHERE projectid in (select projectid from .dbo.Project where  Deleted = 0)           AND DistributionTime>@LastWeek AND TimeUtc>@LastWeek AND AgentId = AG.AgentId AND (CallResult = 2 OR CallResult = 0) UNION            SELECT DistributionTime FROM .dbo.OutboundCall WITH(NOLOCK)             WHERE projectid in (select projectid from .dbo.Project where  Deleted = 0)           AND TimeUtc>@LastWeek AND AgentId = AG.AgentId AND (EndTime IS NOT NULL)) AS CTE1) AS LastCallTime          */        FROM .dbo.Agent AS AG  WITH(NOLOCK)         LEFT JOIN .dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId        LEFT JOIN .dbo.Status AS ST WITH(NOLOCK)  ON AG.StatusId=ST.StatusId     LEFT JOIN (SELECT  Agentid,MAX(AnswerTime) AS inTime FROM .[dbo].InboundCall IC           WHERE TimeUtc>@today            GROUP BY Agentid) AS MC ON AG.AgentId=MC.AgentId          WHERE AG.Deleted = 0 AND AG.Template=0',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('77F81F33-C8A9-4883-A480-C3D29D8541CC','Monitoring System',NULL,'ServiceAPP','Rank DESC','SELECT  *  FROM .dbo.FSC_Monitor',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('832E1DA3-C87E-4E51-A7A6-CA1EC2ABCDFD','Queue investigation',NULL,'ServiceAPP','RegionalTime','SELECT DISTINCT InboundCallId        ,RegionalTime        , CallerNumber         ,QueueDuration         ,PilotName             ,P.DisplayName AS ProjectName   , Agent.DisplayName AS AgentName   FROM  (SELECT InboundCallId         ,RegionalTime         ,QueueDuration         ,Pil.DisplayName AS PilotName         ,CallerNumber        ,CallType        ,CallPhase        ,CallResult        ,ProjectId        ,Skill        ,PreferredAgentId        ,AgentId        ,TeamName        ,IC.LanguageId    FROM InboundCall IC WITH (NOLOCK)    LEFT JOIN Pilot Pil  WITH (NOLOCK)  ON Pil.PilotId=IC.PilotId    WHERE IC.CallPhase IN (23) AND CallResult=0)  Fronta    LEFT OUTER JOIN Skill  WITH (NOLOCK)   ON Skill.ProjectId=Fronta.ProjectId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1       LEFT OUTER JOIN Project P  WITH (NOLOCK)  ON P.ProjectId=Fronta.ProjectId       LEFT OUTER JOIN Agent  WITH (NOLOCK)  ON Agent.AgentId=Skill.AgentId AND Agent.Activity=''Ready'' AND (SELECT Activity FROM Status WHERE Status.StatusId=Agent.StatusId)=''Ready''                   AND (SELECT State FROM WorkPlace AS W WHERE Agent.WorkplaceId = W.WorkplaceId)=''Free''        LEFT JOIN Proficiency AS PROF  WITH (NOLOCK)  ON PROF.AgentId=Agent.AgentId AND PROF.LanguageId=FRONTA.LanguageId AND PROF.VoiceKnowledge>0 AND PROF.VoiceEnabled=1 AND PROF.VoiceChannel=1  ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','Gateways Monitor',NULL,'ServiceAPP','GateWayName','SELECT       Phase2.GatewayId AS RecordId      ,Phase2.GatewayId      ,ISNULL(GW.DisplayName,''BEZ BRÁNY'') AS GateWayName      ,PilotAddress      ,Received      ,Sent      ,Scheduled      ,[Channel]      ,[Direction]      , InDevice      , OutDevice      ,CAST(IIF((Received>0 AND Sent>0) OR (Received>0 AND [Direction]=''I'')  OR (Sent>0 AND [Direction]=''O''),1,0) AS bit) AS isOK     , IIF(Received>0 OR Sent>0,''YES'',''NO'') AS ExKom    FROM    (SELECT         GatewayId        ,SUM(Received) AS Received        ,SUM(Sent) AS Sent     ,SUM(Scheduled) AS Scheduled      FROM     (SELECT              GatewayId        ,SUM(IIF(Direction=''I'',1,0)) AS Received       ,SUM(IIF(Direction=''O'' AND MessagePhase=10,1,0)) AS Sent     ,0 AS Scheduled         FROM .[dbo].[Message] ME      WHERE ReceivedSentTime > DATEADD(Hour,-2,@NowUTC)      GROUP BY GatewayId     UNION      SELECT              GatewayId        ,0 AS Received       ,0 AS Sent       ,SUM(1) AS Scheduled       FROM .[dbo].[Message] ME      WHERE Direction=''O'' AND MessagePhase=8      GROUP BY GatewayId        UNION      SELECT       GatewayId          ,0 AS Received       ,0 AS Sent     ,0 AS Scheduled           FROM .[dbo].[Gateway] GW WHERE Deleted=0      ) AS Phase1      GROUP BY GatewayId      ) AS Phase2        LEFT JOIN .[dbo].[Gateway] GW ON GW.GatewayId=Phase2.GatewayId     ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','Inbound Call Events V6',NULL,'ServiceAPP','TimeLocal','SELECT TOP 100  CAE.InboundCallId   ,CAE.TimeUTC AS TimeLocal  , EventType, LL.DisplayName as EventName  , IVRST.Rank AS Navesti  , IVRST.Action AS Akce  , IVRST.DisplayName AS Ivrkrok  , IVRST.FileName AS Hlaska  , IVRSC.DisplayName AS IvrSkript  , PR.DisplayName AS ProjectName   , AG.DisplayName AS AgentName   , WP.DisplayName AS WorkPlaceName   , ReferenceData   , Duration   , ResultData  , IC.CallerNumber   FROM .dbo.CallEvent AS CAE WITH (NOLOCK)  LEFT JOIN IvrStep AS IVRST  WITH (NOLOCK)ON IVRST.IvrStepId=CAE.ReferenceId  LEFT JOIN IvrScript AS IVRSC  WITH (NOLOCK) ON IVRST.IvrScriptId=IVRSC.IvrScriptId  LEFT JOIN InboundCall AS IC  WITH (NOLOCK) ON IC.InboundCallId=CAE.InboundCallId  LEFT JOIN Project AS PR  WITH (NOLOCK) ON PR.ProjectId=CAE.ProjectId  LEFT JOIN Agent AS AG  WITH (NOLOCK) ON AG.AgentId=CAE.AgentId  LEFT JOIN Workplace AS WP  WITH (NOLOCK) ON WP.WorkPlaceId=CAE.WorkPlaceId  INNER JOIN LiteralLookup AS LL WITH (NOLOCK) ON  CAE.EventType =LL.LiteralValue AND LL.LiteralGroup=''44'' AND LL.Culture=''cs-CZ''   WHERE CAE.InboundCallId IS NOT NULL AND CAE.TimeUTC>DATEADD(Month,-1,@today)',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('8B5D27D3-FFA0-46BC-93D9-D47396BB0241','OutboundCalls Distribution',NULL,'ServiceAPP','ScheduleTime','SELECT     C.OutboundCallId           , A.DisplayName AS AgentName    , ISNULL(A.Activity,''N/A'') AS Activity             ,C.ScheduleTime             ,IIF(C.ScheduleTime <= GETDATE()OR C.ScheduleTime IS NULL ,''YES'',''NO'') AS SchedTimeOK       ,C.CallType             ,IIF(C.CallType=''DialOut'',''YES'',''NO'') AS CallTypeOK       ,C.CallResult             ,IIF(C.CallResult=8,''YES'',''NO'') AS CallResultOK       ,C.CallPhase             ,IIF(C.CallPhase = 6 OR C.CallPhase = 2,''YES'',''NO'') AS CallPhaseOK       ,OLI.Active  AS OLIActive             ,IIF(OLI.Active IS NULL OR OLI.Active = 1,''YES'',''NO'') AS OLIActiveOK       ,OL.Activity AS OLActivity             ,IIF(OL.Activity = 8 OR OL.Activity IS NULL,''YES'',''NO'') AS OLActivityOK       ,IIF(C.Predistributed = 1 OR OL.PredictorId IS NULL,''YES'',''NO'') AS PreDisDictOK       ,C.Predistributed       ,OL.PredictorId          ,IIF(C.Predistributed = 0 OR A.Activity=''Ready'',''YES'',''NO'') AS PreDisAgentOK       ,IIF(OL.RankBatch IS NULL OR C.OutboundListImportId IS NULL OR C.Rank <= OLI.RankBarrier,''YES'',''NO'') AS FollowingOK       ,OL.RankBatch       ,C.OutboundListImportId       ,C.Rank        ,OLI.RankBarrier       ,IIF(C.Rank <= OLI.RankBarrier,''YES'',''NO'') AS UnderBarrier       ,IIF(OL.PredictorId IS NULL,''NO'',''YES'') AS PreDictiveCall    FROM         dbo.OutboundCall AS C INNER JOIN                        dbo.Project AS P ON C.ProjectId = P.ProjectId LEFT OUTER JOIN                        dbo.OutboundList AS OL ON C.OutboundListId = OL.OutboundListId AND OL.Deleted = 0 LEFT OUTER JOIN                        dbo.OutboundListImport AS OLI ON C.OutboundListImportId = OLI.OutboundListImportId AND OLI.Deleted = 0      LEFT JOIN Agent AS A ON C.AgentId=A.AgentId  ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('CE85CCB8-D497-40AB-A067-E1561D4D7AB6','Outbound Calls',NULL,'ServiceAPP','TimeUtc DESC','SELECT       C.OutboundCallId, C.RegionalTime, C.TimeUTC, C.RingDuration, C.CallPhase, C.CallResult, C.CallerNumber,       C.ProjectId, C.LanguageId, C.AgentId, C.WorkplaceId,      C.CallDuration,C.DistributionTime, C.ScheduleTime,AnswerTime as CasUskutecneni,      P.DisplayName AS ProjectName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName, W.DisplayName AS WorkplaceName,      OL.DisplayName AS OutboundListName, C.endtime ,      CAST(CASE WHEN CallResult=0 THEN 1 ELSE 0 END AS bit) AS IsActive,     IIF (EXISTS(SELECT TOP 1 1 FROM .[dbo].[CallRecord] CR WHERE C.OutboundCallId=CR.OutboundCallId),''YES'',''NO'') AS Sparovano      FROM .dbo.OutboundCall AS C  WITH (NOLOCK)      LEFT JOIN Project AS P ON C.ProjectId=P.ProjectId      LEFT JOIN Agent AS A ON C.AgentId=A.AgentId      LEFT JOIN Language AS L ON C.LanguageId=L.LanguageId      LEFT JOIN Workplace AS W ON C.WorkplaceId=W.WorkplaceId      LEFT JOIN OutboundList AS OL ON OL.OutboundListId = C.OutboundListId      /*        WHERE C.AgentId=''b9c54a15-1019-48ff-8cd8-8aa01f489fb9''            AND DAY(AnswerTime)=12 AND MONTH(AnswerTime)=10 AND YEAR(AnswerTime)=2016 AND DATEPART(HOUR,AnswerTime)<10 */',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('9FB476C8-1D02-4D17-820B-E5324FAFE087','Code Change',NULL,'ServiceAPP','Timelocal DESC','SELECT DISTINCT        modify_date AS TimeLocal,        ''Frontstage'' AS DB         ,o.Name ,         o.type_desc,      LEFT(Definition,250) AS Definition    FROM .sys.sql_modules m         INNER JOIN         .sys.objects o           ON m.object_id = o.object_id  ',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
INSERT INTO [Dataquery] ([DataQueryId],[DisplayName],[Description],[QueryGroup],[QuerySortExpression],[QueryText],[ManualFilter],[SnapshotInterval],[TimeLine],[Deleted],[CacheInterval],[LogLevel],[DataQuerySourceId],[DataQueryWhereJSON],[MainEntity])VALUES('E67F9717-E912-4F37-8C81-EAD7C65C7800','Free agents for mail','Admin','ServiceAPP','AgentName','select      * FROM .dbo.FSC_VolniAgentiEmail()',0,NULL,NULL,0,NULL,0,NULL,NULL,NULL)
	END
	--GO

-- Doplnění ServiceAPP DataQueryColumn:
  IF NOT EXISTS (SELECT TOP 1 1 FROM [DataQueryColumn] WHERE DataQueryColumnId='D2DBAD05-DA7D-4DF1-83C5-00F834E36B94')
  OR @HardRun=1
    BEGIN
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AB03479C-94C0-4023-8DDF-B85CBA51F12B','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','DataQueryId','Text','DataQueryId',NULL,NULL,NULL,NULL,NULL,'DataQueryId',NULL,0,230,3,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('33689F53-333E-4804-BD2C-0D402B4269A8','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','DisplayName','HyperLink','DisplayName',NULL,'DataqueryId','https://localhost/RA/Pages/DataQuery/1/{0}',NULL,NULL,'DisplayName',NULL,0,200,162,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A02B244A-194E-47EB-9480-36B481032217','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','QueryGroup','Select','QueryGroup',NULL,NULL,NULL,NULL,NULL,'QueryGroup',NULL,0,80,167,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A5DDE7A1-65BE-4E09-94B4-6323E9F9C3B5','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','Description','Text','Description',NULL,NULL,NULL,NULL,NULL,'Description',NULL,0,80,172,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('07EF3B7F-BCD3-44D6-8D60-9406933235F8','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','QuerySortExpression','Text','QuerySortExpression',NULL,NULL,NULL,NULL,NULL,'QuerySortExpression',NULL,0,80,192,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('79DE34C0-4A67-4C5A-B46A-F788C36E9D0F','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','QueryText','Text','QueryText',NULL,NULL,NULL,NULL,NULL,'QueryText',NULL,0,80,202,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('87C9787A-CB56-46EA-9171-FC102D8FBA6C','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','ManualFilter','Color','ManualFilter',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,212,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('3E179550-94EF-4294-80ED-4E69C11609C1','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','SnapshotInterval','Integer','SnapshotInterval',NULL,NULL,NULL,NULL,NULL,'SnapshotInterval',NULL,0,60,222,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EE46D060-898B-4EE8-BB63-984BECCFD628','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','TimeLine','Text','TimeLine',NULL,NULL,NULL,NULL,NULL,'TimeLine',NULL,0,80,232,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('68FA013C-2D7E-449A-96C5-8FC8501C9B09','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','Deleted','Color','Deleted',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,242,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('739A9F99-AE5A-4CF9-9F3D-3678905C87E4','E5FE7CA3-06F1-46A4-9771-09CB4BFC43EB','CacheInterval','Integer','CacheInterval',NULL,NULL,NULL,NULL,NULL,'CacheInterval',NULL,0,60,252,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('343EF99C-87F5-4EDE-8A07-6AAE41157512','B37E3AD0-C8E3-4083-A23A-0E18686076B6','IvrScriptId','Text','IvrScriptId',NULL,NULL,NULL,NULL,NULL,'IvrScriptId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4683B9A0-8488-4AD4-B017-1C499B030EBB','B37E3AD0-C8E3-4083-A23A-0E18686076B6','DisplayName','HyperLink','DisplayName',NULL,'IvrScriptId','http://Localhost/FSAdmin/RC/Pages/IvrScripts/EditForm.aspx?Id={0}',NULL,NULL,'DisplayName',NULL,0,160,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B4B40666-9A80-4936-A81D-C1C9FF685E03','B37E3AD0-C8E3-4083-A23A-0E18686076B6','Description','Text','Description',NULL,NULL,NULL,NULL,NULL,'Description',NULL,0,80,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('47156627-D939-4998-8DF8-A4773F8C360B','B37E3AD0-C8E3-4083-A23A-0E18686076B6','IvrMachine','Text','IvrMachine',NULL,NULL,NULL,NULL,NULL,'IvrMachine',NULL,0,80,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('00341F20-7100-413B-BF1D-F5A2E6666EC5','B37E3AD0-C8E3-4083-A23A-0E18686076B6','Perform','ImageScript','ProvedAkci',NULL,'RecordId',NULL,NULL,NULL,'ProvedAkci',NULL,0,80,30,NULL,0,'exec .dbo.FSC_SelectIVRScript @Id',NULL,NULL,NULL,NULL,'fa fa-play-circle',NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BB0A84E1-7265-4692-82E5-3ECFB55814A1','B37E3AD0-C8E3-4083-A23A-0E18686076B6','IsSelected','Color','IsSelected',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,40,'#E0FFFF',0,NULL,'info',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('2E3AF85F-0160-4ECD-892B-7F508C0BE721','B37E3AD0-C8E3-4083-A23A-0E18686076B6','IsUsed','Select','IsUsed',NULL,NULL,NULL,NULL,NULL,'IsUsed',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('455EFCFF-0C4B-41E6-8A3B-7DA1CB4B52D2','A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','ExRecord','Select','ExRecord',NULL,NULL,NULL,NULL,NULL,'ExRecord',NULL,0,80,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F8AB2090-B9FC-4842-BF99-8F32942F7526','A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','Direction','Select','Direction',NULL,NULL,NULL,NULL,NULL,'Direction',NULL,0,80,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7F1DEE4F-E552-4983-A9A4-A0A11339D2FE','A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','Redirector','Select','Redirector',NULL,NULL,NULL,NULL,NULL,'Redirector',NULL,0,80,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BDF1B9A8-9A37-4647-83CB-BDA8E24F2BB8','A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','CallerNumber','Text','CallerNumber',NULL,NULL,NULL,NULL,NULL,'CallerNumber',NULL,0,80,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EB500B00-ED8F-4029-A760-FA4DF36A4882','A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','Number','Select','Number',NULL,NULL,NULL,NULL,NULL,'Number',NULL,0,80,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F28D0016-555E-4970-8FFC-EE8AB4825091','A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','WorkPlaceName','Text','WorkPlaceName',NULL,NULL,NULL,NULL,NULL,'WorkPlaceName',NULL,0,80,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E2B9C1CE-C986-4A5B-8FD6-F425A48075D8','A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','CallTime','DateTimeFromTo','CallTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'CallTime',NULL,0,100,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('98355ED4-551D-4EB1-8F71-873D6FE14393','A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','StartTimeUTC','DateTimeUtc','StartTimeUTC','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'StartTimeUTC',NULL,0,100,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BC426E5C-59AC-4DCE-937D-E8E8478B7F4D','A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','CallId','Text','CallId',NULL,NULL,NULL,NULL,NULL,'CallId',NULL,0,230,120,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('55CF0A46-2835-4448-9D5D-24702BC65CD5','A12AAE6C-CAEF-4BA1-A117-221B2A6C1F75','CallDuration','Duration','CallDuration',NULL,NULL,NULL,NULL,'DurationMSS','CallDuration',NULL,0,60,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('20531F7C-C246-4E70-9B47-0EF1F18F90B1','6C5E8E3F-37B1-4FC6-8C7D-233EFD017F2B','IssueId','Text','IssueId',NULL,NULL,NULL,NULL,NULL,'IssueId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9C52DAFD-B67C-44AD-9C10-FD349B1EA3EE','6C5E8E3F-37B1-4FC6-8C7D-233EFD017F2B','TimeLocal','DateTimeUtc','TimeLocal','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeLocal',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('208362CE-5087-4FF8-A084-DD2FA9DF5992','6C5E8E3F-37B1-4FC6-8C7D-233EFD017F2B','Projekt','Text','Projekt',NULL,NULL,NULL,NULL,NULL,'Projekt',NULL,0,80,22,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DB2D1315-EF16-4432-9C21-B949273A23FB','6C5E8E3F-37B1-4FC6-8C7D-233EFD017F2B','EventType','Text','EventType',NULL,NULL,NULL,NULL,NULL,'EventType',NULL,0,80,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('22B3FF8A-2949-4042-ACFE-25F6518335B4','6C5E8E3F-37B1-4FC6-8C7D-233EFD017F2B','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,170,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('339C5677-33AD-4011-908C-95EA625952BF','6C5E8E3F-37B1-4FC6-8C7D-233EFD017F2B','ReferenceData','Text','ReferenceData',NULL,NULL,NULL,NULL,NULL,'ReferenceData',NULL,0,160,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('ED03AE7A-6C05-43A2-A801-A5D066A5A3C7','9E103B6F-379B-417C-8EC7-2361EF3124ED','FreeAgent','Select','FreeAgent',NULL,NULL,NULL,NULL,NULL,'FreeAgent',NULL,0,80,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F227B536-E544-4C93-BBDD-64F43F753D38','9E103B6F-379B-417C-8EC7-2361EF3124ED','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,120,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('ED490A4A-9C3D-4EC6-8704-B699F77608F3','9E103B6F-379B-417C-8EC7-2361EF3124ED','ProjectName','Text','ProjectName',NULL,NULL,NULL,NULL,NULL,'ProjectName',NULL,0,140,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('594F1320-8BB5-49CD-A361-DECEA01864BF','9E103B6F-379B-417C-8EC7-2361EF3124ED','PbxInKnowledge','Text','PbxInKnowledge',NULL,NULL,NULL,NULL,NULL,'PbxInKnowledge',NULL,0,70,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E6E939B4-233A-469B-9564-25DE16ECE858','9E103B6F-379B-417C-8EC7-2361EF3124ED','AgentStatus','Text','AgentStatus',NULL,NULL,NULL,NULL,NULL,'AgentStatus',NULL,0,80,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9B03C477-3039-4383-B7D2-702C10CF6369','9E103B6F-379B-417C-8EC7-2361EF3124ED','PbxState','Integer','PbxState',NULL,NULL,NULL,NULL,NULL,'PbxState',NULL,0,60,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0CECFEC6-F0DF-4AB0-B617-DC355D59A2F6','9E103B6F-379B-417C-8EC7-2361EF3124ED','LangKnowledge','Text','LangKnowledge',NULL,NULL,NULL,NULL,NULL,'LangKnowledge',NULL,0,80,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BFEF9E06-8090-46B7-A70C-8E0C7C4E9BC8','9E103B6F-379B-417C-8EC7-2361EF3124ED','WPState','Text','WPState',NULL,NULL,NULL,NULL,NULL,'WPState',NULL,0,80,80,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BAF63EDD-C93B-4E56-BB94-0B54820D4F97','1C043F8C-2616-4293-8467-2422BF171AE7','Description','Text','Popis',NULL,NULL,NULL,NULL,NULL,'Popis',NULL,0,800,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B5D0B3BD-F33B-46A6-89E4-15E490AC9137','1C043F8C-2616-4293-8467-2422BF171AE7','Seconds','Duration','Seconds',NULL,NULL,NULL,NULL,'DurationHMMSS','Seconds',NULL,0,60,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BE5EDA27-4722-4634-8F37-84A80FB276C2','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','MessageId','Toggle','MessageId',NULL,NULL,'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,30,1,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('13BD027C-9F82-41E5-8097-CFB7E889EB72','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','MessageType','Image','MessageType',NULL,'MessageId','/RC/Pages/MessageEditor.html?Id={0}',NULL,'LiteralValue','MessageType',NULL,0,25,5,NULL,0,NULL,NULL,20,50,'MessageType',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9DF7BEF5-6EA8-4A75-A409-5CE02FA0AB70','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','Direction','Image','Direction',NULL,'MessageId','/RC/Pages/MessageEditor.html?Id={0}',NULL,'LiteralValue','Direction',NULL,0,25,7,NULL,0,NULL,NULL,20,51,'Direction',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C054E5BB-57DB-465D-B9CE-3AEAFAF38546','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','HasAttachment','Image','HasAttachment',NULL,NULL,NULL,NULL,NULL,'HasAttachment',NULL,0,25,8,NULL,0,NULL,NULL,NULL,NULL,'HasAttachment',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('8CB08F62-2E4E-4439-9DA2-ADB5D57634BB','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','MessageTime','DateTimeFromTo','MessageTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'MessageTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7EB647E0-CB1A-4D84-90C8-30312B7F3756','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','FromField','Text','FromField',NULL,NULL,NULL,'FromField',NULL,'FromField',NULL,0,120,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('03329494-E40C-4192-88D1-ABED5C9E24AD','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','SubjectField','HyperLink','SubjectField',NULL,'MessageId','/RC/Pages/MessageEditor.html?Id={0}','SubjectField',NULL,'SubjectField',NULL,0,160,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BC97ED4F-DF5D-4EB0-8343-7244668D610A','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','ToField','Text','ToField',NULL,NULL,NULL,'ToField',NULL,'ToField',NULL,0,100,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('1C46915F-DDE2-4528-A40C-505238DE1891','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','MessagePhase','Select','MessagePhase',NULL,NULL,NULL,NULL,'MessagePhase','MessagePhase',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A41B058F-792B-40FA-9BA3-C3473C960272','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','AgentName','Select','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0B0A27E7-D3BA-40A4-A551-830CB3ADB61A','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','TeamName','Text','TeamName',NULL,NULL,NULL,NULL,NULL,'TeamName',NULL,0,80,61,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('869E8028-9B7A-4C2E-BA87-26F74245FB3B','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','ProjectName','ForeignKey','ProjectName',NULL,NULL,NULL,'ProjectId','ProjectName','ProjectName',NULL,0,100,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4D01D782-231B-4072-925F-A2560526833E','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','BodyField','Text','BodyField',NULL,NULL,NULL,NULL,NULL,'BodyField',NULL,0,140,80,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('54F6EDAB-F156-40E6-A598-302327958BD6','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','ToCcField','Text','ToCcField',NULL,NULL,NULL,NULL,NULL,'ToCcField',NULL,0,80,85,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('85C250AC-2BEE-4EB0-BB58-51F5D517294D','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','IsNew','Bold','IsNew',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,91,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('CA154DA6-E332-4DD2-9C8A-2C5201F7084C','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','IsLate','Color','IsLate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,'#FFE9D1',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('064B39C2-8CAB-45EC-814C-BB28A4B91DD8','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','IsActive','Color','IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,93,'#CCFADF',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9DE20B78-7420-48A8-9798-81CDCB68BD80','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','TimeUtc','DateTimeUtc','TimeUtc','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeUtc',NULL,0,100,103,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7232C292-52B9-45A6-9D6D-638BF3E94EEA','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','RemoteAddress','Text','RemoteAddress',NULL,NULL,NULL,NULL,NULL,'RemoteAddress',NULL,0,80,150,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B1152699-D074-452E-A049-AD3EC5C35298','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','GatewayName','ForeignKey','GatewayName',NULL,NULL,NULL,'GatewayId','GatewayName','GatewayName',NULL,0,130,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EBD951F2-F4F6-40AF-A416-2FEF8AA46177','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','LanguageName','ForeignKey','LanguageName',NULL,NULL,NULL,'LanguageId','LanguageName','LanguageName',NULL,0,35,165,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('96D3B934-F231-496E-A887-449A001AB618','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','Description','Text','Description',NULL,NULL,NULL,NULL,NULL,'Description',NULL,0,80,175,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7F2776E4-CA58-4FD9-9F4E-E35364045A68','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','ICO_RC','Text','ICO_RC',NULL,NULL,NULL,NULL,NULL,'ICO_RC',NULL,0,80,195,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7D06F1C5-BE1E-47F0-A45D-7A132075CF67','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','Spam','Select','Spam',NULL,NULL,NULL,NULL,NULL,'Spam',NULL,0,40,200,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A0CB679E-8CA4-4A36-9AEB-061CC43D56CE','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','CasPrirazeni','DateTimeFromTo','CasPrirazeni','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'CasPrirazeni',NULL,0,100,205,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('424C6ED1-EC5F-419D-8119-6B43FF8E02CD','F2E2995F-40AD-4FDC-A3EE-27716A48A96B','ResultData','Text','ResultData',NULL,NULL,NULL,NULL,NULL,'ResultData',NULL,0,200,215,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('ED724495-0061-417B-9656-6F3B016965AF','1FF2043B-8F15-42A8-BB25-27E584B21061','DisplayName','Text','DisplayName',NULL,NULL,NULL,NULL,NULL,'DisplayName',NULL,0,200,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D62D1D4C-7554-4009-803B-2588F671C907','1FF2043B-8F15-42A8-BB25-27E584B21061','Description','Text','Description',NULL,NULL,NULL,NULL,NULL,'Description',NULL,0,120,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6765C223-6B5B-484C-82F7-B4536224C69E','1FF2043B-8F15-42A8-BB25-27E584B21061','Perform','ImageScript','ProvedAkci',NULL,'RecordId',NULL,NULL,NULL,'ProvedAkci',NULL,0,80,30,NULL,0,'exec .dbo.FSC_SelectPhBook @Id',NULL,NULL,NULL,NULL,'fa fa-play-circle',NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('108E315C-CD3B-4692-898E-4222D034DE6C','1FF2043B-8F15-42A8-BB25-27E584B21061','IsSelected','Color','IsSelected',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,40,'#E0FFFF',0,NULL,'success',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('92E16D6D-BBB5-49E1-A69B-67B99159CDB3','34137610-1FB2-4B82-A857-2BF1F3C05D08','IssueId','Text','IssueId',NULL,NULL,NULL,NULL,NULL,'IssueId',NULL,0,230,3,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
/*INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B4F7F291-DC33-4AE7-ADA7-A068FA88CA46','34137610-1FB2-4B82-A857-2BF1F3C05D08','Activity','Image','Activity','~/CustomImages/Issue-{0}.png','IssueId','/RC/Pages/Issueeditor.html?Id={0}','LiteralValue','IssueActivity','Activity',NULL,0,25,5,NULL,0,NULL,NULL,NULL,0,'Activity',NULL,NULL,NULL)*/
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B4F7F291-DC33-4AE7-ADA7-A068FA88CA46','34137610-1FB2-4B82-A857-2BF1F3C05D08','Activity','Image','Activity',NULL,'IssueId','/RC/Pages/Issueeditor.html?Id={0}',NULL,'LiteralValue','Activity',NULL,0,25,5,NULL,0,NULL,NULL,NULL,60,'Activity',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A86E2296-C85C-4866-A89C-491783D2F4D8','34137610-1FB2-4B82-A857-2BF1F3C05D08','NewTime','DateTimeFromTo','NewTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'NewTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DC8AEE46-C047-4436-8143-9AA3C5B5A56F','34137610-1FB2-4B82-A857-2BF1F3C05D08','ProjectName','ForeignKey','ProjectName',NULL,NULL,NULL,'ProjectId','ProjectName','ProjectName',NULL,0,100,11,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EA221788-2072-4B06-A1A2-C2C14FC64FAE','34137610-1FB2-4B82-A857-2BF1F3C05D08','TopicName','ForeignKey','TopicName',NULL,NULL,NULL,'TopicId','TopicName','TopicName',NULL,0,120,13,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('79E2E488-7528-4440-BA8F-B136C44C8233','34137610-1FB2-4B82-A857-2BF1F3C05D08','SubTopicName','ForeignKey','SubTopicName',NULL,NULL,NULL,'SubTopicId',NULL,'SubTopicName',NULL,0,120,14,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9CBC30BB-2642-4F79-A764-78B995EE9895','34137610-1FB2-4B82-A857-2BF1F3C05D08','PhaseName','ForeignKey','PhaseName',NULL,NULL,NULL,'PhaseId','PhaseName','PhaseName',NULL,0,80,15,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E2F3212C-D026-4044-9557-E68BFFC51E2B','34137610-1FB2-4B82-A857-2BF1F3C05D08','AgentName','ForeignKey','AgentName',NULL,NULL,NULL,'AgentId','AgentName','AgentName',NULL,0,150,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9B2FB09B-0716-4A57-87D0-47A4BDE8023F','34137610-1FB2-4B82-A857-2BF1F3C05D08','Returned','Color','Returned',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,88,'#70AD47',0,NULL,'warning',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D5D4C770-C50F-4D18-B958-5826CE44A5A6','34137610-1FB2-4B82-A857-2BF1F3C05D08','Doplnit','Color','Doplnit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,89,'#ffc000',0,NULL,'info',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B6AEC6F1-DFA5-4C28-89B2-9861BA8AC76A','34137610-1FB2-4B82-A857-2BF1F3C05D08','NewMessage','Color','NewMessage',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,90,'#FF0000',0,NULL,'active',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7D440444-D770-4170-B242-80FA4506D538','34137610-1FB2-4B82-A857-2BF1F3C05D08','IsActive','Color','IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,'#E0FFFF',0,NULL,'active',NULL,NULL,NULL,NULL,NULL,NULL)
--INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('35DC2633-0194-48D8-90C4-3874B7A63A6D','34137610-1FB2-4B82-A857-2BF1F3C05D08','Predat','Select','Predat',NULL,NULL,NULL,NULL,NULL,'Predat',NULL,0,80,171,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
--INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('76F3F659-EBB2-429C-AEC3-922BEC39D317','34137610-1FB2-4B82-A857-2BF1F3C05D08','Doklad','Text','Doklad',NULL,NULL,NULL,NULL,NULL,'Doklad',NULL,0,80,181,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
--INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B6C3790B-7042-4497-806B-A9253A4E0F10','34137610-1FB2-4B82-A857-2BF1F3C05D08','Interni','Text','Interni',NULL,NULL,NULL,NULL,NULL,'Interni',NULL,0,190,191,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5740D4F6-6B94-4EC0-9DF4-33D9E0DA0793','2BD46080-CE8D-4C10-8B4D-3772417F57D8','InboundCallId','Text','InboundCallId',NULL,NULL,NULL,NULL,NULL,'InboundCallId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B9CCB886-56C8-4147-8BC2-023E4CFD86FF','2BD46080-CE8D-4C10-8B4D-3772417F57D8','RegionalTime','DateTimeFromTo','RegionalTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'RegionalTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('182E7654-21BA-4EC5-9F6B-2E9CCBE2878C','2BD46080-CE8D-4C10-8B4D-3772417F57D8','PilotName','Text','PilotName',NULL,NULL,NULL,NULL,NULL,'PilotName',NULL,0,120,15,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F550D403-77AA-4123-9B51-C08F2F1B7E7B','2BD46080-CE8D-4C10-8B4D-3772417F57D8','CallerNumber','Text','CallerNumber',NULL,NULL,NULL,NULL,NULL,'CallerNumber',NULL,0,110,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('35E6BCC8-965D-4F18-A4DE-F80D9F38E929','2BD46080-CE8D-4C10-8B4D-3772417F57D8','QueueDuration','Duration','QueueDuration',NULL,NULL,NULL,NULL,NULL,'QueueDuration',NULL,0,60,25,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5433C727-C50E-444A-B4D4-7472D47FCDEA','2BD46080-CE8D-4C10-8B4D-3772417F57D8','ProjectName','Text','ProjectName',NULL,NULL,NULL,NULL,NULL,'ProjectName',NULL,0,80,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6622F3D6-0471-451B-8583-C173A9A7F67B','2BD46080-CE8D-4C10-8B4D-3772417F57D8','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,120,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('641A9107-6E93-4F37-A7DD-914646D77A79','1FE47865-AD21-4EC7-8CF9-3841DD6EFAC7','DateTime','DateTimeFromTo','DatumCas','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'DatumCas',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('FC6E2ADD-14BB-48DA-87F6-87955A693891','1FE47865-AD21-4EC7-8CF9-3841DD6EFAC7','Description','Text','Popis',NULL,NULL,NULL,NULL,NULL,'Popis',NULL,0,999,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('8D0BC607-0654-413A-938E-40BB128B300C','1FE47865-AD21-4EC7-8CF9-3841DD6EFAC7','Procedure','Select','Procedura',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,150,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('8794379A-08D1-41A4-AF4A-32288B95400D','4C9E5E61-F17A-4CE1-9BB4-441C8AD8F83E','TimeLocal','DateTimeFromTo','TimeLocal','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeLocal',NULL,0,100,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('464909A6-2B38-4C20-8650-6993E026D289','4C9E5E61-F17A-4CE1-9BB4-441C8AD8F83E','Message','Text','Message',NULL,NULL,NULL,NULL,NULL,'Message',NULL,0,600,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C71AA4C3-2109-41B8-9953-6295DC190C30','50BAED36-CA55-46B5-A971-45996D7B52F0','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,120,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('05C1BAF1-E85B-4A26-B60C-E865909BD671','A5134A50-8053-4921-BD42-538C7B175934','FreeAgent','Select','FreeAgent',NULL,NULL,NULL,NULL,NULL,'FreeAgent',NULL,0,80,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('117EA6F5-C7B4-4280-ACD8-E1E4DD7C73CD','A5134A50-8053-4921-BD42-538C7B175934','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,120,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('65AE6EE6-8548-4AF8-8563-8209C9A0C69C','A5134A50-8053-4921-BD42-538C7B175934','TeamName','Select','TeamName',NULL,NULL,NULL,NULL,NULL,'TeamName',NULL,0,80,15,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0FF747A6-514D-4550-93FC-A6B3933FE559','A5134A50-8053-4921-BD42-538C7B175934','ProjectName','Text','ProjectName',NULL,NULL,NULL,NULL,NULL,'ProjectName',NULL,0,140,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('48D8603A-F372-448D-B0D4-F683FB8F22D9','A5134A50-8053-4921-BD42-538C7B175934','PbxOutKnowledge','Integer','PbxOutKnowledge',NULL,NULL,NULL,NULL,NULL,'PbxOutKnowledge',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('70BD0E91-322F-4A2B-A33E-ABDD0A59CC1E','A5134A50-8053-4921-BD42-538C7B175934','PbxOutEnabled','Select','PbxOutEnabled',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,70,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('583DFE13-0E69-44F4-8B39-812B07362973','A5134A50-8053-4921-BD42-538C7B175934','PbxOutChannel','Select','PbxOutChannel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,70,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('48AE8355-58D3-41AB-889A-5D22F7A26C98','A5134A50-8053-4921-BD42-538C7B175934','Activity','Select','Activity',NULL,NULL,NULL,NULL,NULL,'Activity',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('645A49CA-D275-424A-AB36-F8BF42A53468','A5134A50-8053-4921-BD42-538C7B175934','State','Select','State',NULL,NULL,NULL,NULL,NULL,'State',NULL,0,80,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A5EFD52B-4B8D-43B4-BDD0-04A357AE8B18','DA89C2B0-F74D-4B41-8589-5491C8239A29','Timelocal','DateTimeFromTo','Timelocal','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'Timelocal',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('363034A7-957A-4DD7-83F6-B9A1DDA40F3D','DA89C2B0-F74D-4B41-8589-5491C8239A29','RepeatAfter','Integer','RepeatAfter',NULL,NULL,NULL,NULL,NULL,'RepeatAfter',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('CE5D5024-2675-41F6-B5D5-DE7C9BB332F1','DA89C2B0-F74D-4B41-8589-5491C8239A29','Message','Text','Message',NULL,NULL,NULL,NULL,NULL,'Message',NULL,0,500,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7B9D8B2A-F3B7-4C48-A342-748BA78FD808','61C8EBC7-E7BE-42B2-88B5-578479D8C30A','Perform','ImageScript','ProvedAkci',NULL,'RecordId',NULL,NULL,NULL,'ProvedAkci',NULL,0,70,3,NULL,0,'exec FSC_RunScript @Id',NULL,NULL,NULL,NULL,'fa fa-play-circle',NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('60815E35-A6D1-471C-A973-3520157CF188','61C8EBC7-E7BE-42B2-88B5-578479D8C30A','Description','Text','Description',NULL,NULL,NULL,NULL,NULL,'Description',NULL,0,600,340,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('74F6F48C-8843-4C0A-BED0-7D20FCC5F342','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','MessageId','Toggle','MessageId',NULL,NULL,'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,30,1,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('CE94F6CD-AF6C-422C-A550-F6477608F6BC','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','MessageType','Image','MessageType','~/CustomImages/{0}.png','MessageId','/RC/Pages/MessageEditor.html?Id={0}',NULL,'MessageType','MessageType',NULL,0,25,6,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('498DB4FC-096A-424A-8F16-7E35FCF84FB2','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','Direction','Image','Direction','~/CustomImages/Dir-{0}.png',NULL,NULL,NULL,'MessageDirection','Direction',NULL,0,25,7,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4786CC3A-7F7D-4390-9B3C-DFFC54BFD929','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','HasAttachment','Image','HasAttachment','~/CustomImages/Att-{0}.png',NULL,NULL,NULL,'Bool','HasAttachment',NULL,0,25,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('07F8307D-D0EB-4010-9FDF-1FFB78F51648','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','MessageTime','DateTimeFromTo','MessageTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'MessageTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7CD0638D-0043-460D-BFA6-EA66BF04C41B','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','FromField','Text','FromField',NULL,NULL,NULL,'FromField',NULL,'FromField',NULL,0,120,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('095E87F0-8F2E-4251-B32B-4E6E94C37D9F','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','SubjectField','HyperLink','SubjectField',NULL,'MessageId','/RC/Pages/MessageEditor.html?Id={0}','SubjectField',NULL,'SubjectField',NULL,0,160,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A4BC1BE3-63F6-4ED2-BE5F-366306833AF3','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','ToField','Text','ToField',NULL,NULL,NULL,'ToField',NULL,'ToField',NULL,0,100,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B84030E2-A33F-4CBF-95CB-DB3E75C6560B','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','MessagePhase','Select','MessagePhase',NULL,NULL,NULL,NULL,'MessagePhase','MessagePhase',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('3A284D6C-8966-4C11-8FEE-14447B169DAD','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','AgentName','Text','AgentName',NULL,NULL,NULL,'AgentId','AgentName','AgentName',NULL,0,80,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7B794523-E1FE-4D4E-AB1A-1FDB02A08E1C','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','TeamName','Text','TeamName',NULL,NULL,NULL,NULL,NULL,'TeamName',NULL,0,80,61,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('FD8A2FDE-BFAD-48C9-A521-6D5DF50BCE49','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','ProjectName','ForeignKey','ProjectName',NULL,NULL,NULL,'ProjectId','ProjectName','ProjectName',NULL,0,100,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('80AE2BFA-7C38-48EF-8660-128FE76B0A78','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','BodyField','Text','BodyField',NULL,NULL,NULL,NULL,NULL,'BodyField',NULL,0,140,80,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D69F134B-B6D7-4DDC-BF0C-CC6B55320FFE','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','ToCcField','Text','ToCcField',NULL,NULL,NULL,NULL,NULL,'ToCcField',NULL,0,80,85,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('64CAB0A4-7562-4555-BFF9-A5E9074CBE64','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','IsNew','Bold','IsNew',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,91,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('32F0F420-BAEB-4EB7-921C-71DD1F92FC54','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','IsLate','Color','IsLate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,'#FFE9D1',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F37C8E8F-AFE0-4F1F-9843-76A3303E8F5D','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','IsActive','Color','IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,93,'#CCFADF',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('CEF26FF3-665D-4D08-BBF5-F423EC1D2139','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','TimeUtc','DateTimeUtc','TimeUtc','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeUtc',NULL,0,100,103,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EADBDF96-293B-4FEA-9481-6834C7B3AD2C','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','RemoteAddress','Text','RemoteAddress',NULL,NULL,NULL,NULL,NULL,'RemoteAddress',NULL,0,80,150,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D2DBAD05-DA7D-4DF1-83C5-00F834E36B94','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','GatewayName','ForeignKey','GatewayName',NULL,NULL,NULL,'GatewayId','GatewayName','GatewayName',NULL,0,130,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E6DE9500-DD82-492A-B5F5-8B5D6E80B8BC','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','LanguageName','ForeignKey','LanguageName',NULL,NULL,NULL,'LanguageId','LanguageName','LanguageName',NULL,0,35,165,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('CEB57D55-1035-4ADA-BE6C-6F9BF6DEF5D8','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','Description','Text','Description',NULL,NULL,NULL,NULL,NULL,'Description',NULL,0,80,175,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7306C00A-1A30-4D1D-AE52-D71F899604D7','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','MujTym','Text','MujTym',NULL,NULL,NULL,NULL,NULL,'MujTym',NULL,0,80,185,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B65C0A27-4C11-4EFE-8DE8-C0AC0250AE6A','EE1AADFD-F66C-4BBE-892A-6335089BAFA4','ICO_RC','Text','ICO_RC',NULL,NULL,NULL,NULL,NULL,'ICO_RC',NULL,0,80,195,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A28AAC62-0175-4A26-A2DB-00A7B42F4C4D','2F0FD1D8-017A-4A7C-BE35-A8C02F46007D','ReferenceData','Text','ReferenceData',NULL,NULL,NULL,NULL,NULL,'ReferenceData',NULL,0,120,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('CB48BFCC-0FAA-4F31-858D-030911A1BAC9','D1F1F295-8801-423B-AAFD-9222EE4892FC','UrlColumn','Text','UrlColumn',NULL,NULL,NULL,NULL,NULL,'UrlColumn',NULL,0,100,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AC046054-9A81-48C7-838D-0458C81DF1B8','68DF515A-31D7-4137-B661-9CE2C40A601A','LocalNumber','Text','LocalNumber',NULL,NULL,NULL,NULL,NULL,'LocalNumber',NULL,0,80,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7A50BAD2-D71E-43BA-B1C0-0622323E0DDA','882362DC-F36F-4248-AD4D-64D1A883E91A','ReferenceData','Text','ReferenceData',NULL,NULL,NULL,NULL,NULL,'ReferenceData',NULL,0,80,80,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('38C7B063-025B-4AF2-9502-087434A2D342','E67F9717-E912-4F37-8C81-EAD7C65C7800','Free Agent','Select','VolnyAgent',NULL,NULL,NULL,NULL,NULL,'VolnyAgent',NULL,0,80,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('3C9A5DAA-BD83-430C-8CE7-08B6F5546329','372F67E1-C08D-49DA-A1CE-89E875A1D68B','Description','Text','Popis',NULL,NULL,NULL,NULL,NULL,'Popis',NULL,0,800,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('23E530D8-61C2-4AEA-B21E-0AB99E44A9E2','99CECF13-C463-4ABD-A52E-AD923D51AC7C','Afterwork','Text','Afterwork',NULL,NULL,NULL,NULL,NULL,'Afterwork',NULL,0,80,122,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A5326513-B637-49A9-BCCE-0B052CE4DE28','D1F1F295-8801-423B-AAFD-9222EE4892FC','SortExpression','Text','SortExpression',NULL,NULL,NULL,NULL,NULL,'SortExpression',NULL,0,80,90,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E2D87464-21BE-415A-BE91-0B7C1BF1F82B','832E1DA3-C87E-4E51-A7A6-CA1EC2ABCDFD','PilotName','Text','PilotName',NULL,NULL,NULL,NULL,NULL,'PilotName',NULL,0,120,15,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('42686A71-9DDF-442E-9C6C-0D4304B8DAE0','D1F1F295-8801-423B-AAFD-9222EE4892FC','ToolTip','Integer','ToolTip',NULL,NULL,NULL,NULL,NULL,'ToolTip',NULL,0,60,180,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('287934DE-8104-417B-A82E-0F91773F61BC','68DF515A-31D7-4137-B661-9CE2C40A601A','EndTimeUtc','DateTimeUtc','EndTimeUtc','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'EndTimeUtc',NULL,0,100,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E9096303-5EB5-489B-A590-12B8530D1029','68DF515A-31D7-4137-B661-9CE2C40A601A','RemoteNumber','Text','RemoteNumber',NULL,NULL,NULL,NULL,NULL,'RemoteNumber',NULL,0,90,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('36A17053-6123-459A-A524-13C01B109AE0','68DF515A-31D7-4137-B661-9CE2C40A601A','LocalName','Text','LocalName',NULL,NULL,NULL,NULL,NULL,'LocalName',NULL,0,80,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('38CC590E-A520-484F-9D44-16D101EDB9C0','D1F1F295-8801-423B-AAFD-9222EE4892FC','DisplayName','HyperLink','DisplayName',NULL,'DataQueryColumnId','http://localhost/FSAdmin/RC/Pages/DataQueryColumns/EditForm.aspx?Id={0}&Source=%2fFSAdmin%2fPages%2fDataQueries%2fEditForm.aspx%3fId%3d1ccce0b7-3447-4822-bc5e-254a07fde056%26Source%3d%252fFSAdmin%252fPages%252fDataQueries%252fList.aspx%253f',NULL,NULL,'DisplayName',NULL,0,80,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('48513A88-928F-4EDA-A7C1-1B6B9EF6882B','EC5174C1-AD19-4423-8FFF-AE043DC92627','TeamName','Select','TeamName',NULL,NULL,NULL,NULL,NULL,'TeamName',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('ECB1C38F-BE93-42D8-AD18-1C65C8DF9E64','77F81F33-C8A9-4883-A480-C3D29D8541CC','RunFromHour','Integer','RunFromHour',NULL,NULL,NULL,NULL,NULL,'RunFromHour',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5E72D336-D1D5-46E1-9A95-1CD28899ECBA','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','Rank','Integer','Rank',NULL,NULL,NULL,NULL,NULL,'Rank',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BEEAB35B-7AA5-4FF0-B65F-1DD1617558B6','EC5174C1-AD19-4423-8FFF-AE043DC92627','LastInCall','DateTimeFromTo','LastInCall','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,NULL,NULL,0,100,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('13367A49-C517-44B5-A79D-1DDAF34DB5EE','68DF515A-31D7-4137-B661-9CE2C40A601A','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,200,100,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5B2DA7E0-B149-4EB7-A2EF-2159C4BCB299','77F81F33-C8A9-4883-A480-C3D29D8541CC','Rank','Integer','Rank',NULL,NULL,NULL,NULL,NULL,'Rank',NULL,0,30,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AC1BF1F4-4F0E-4F93-B02D-2214BFA919DA','354E10A1-14F7-4F66-B1AA-9B7FFEE2B91F','TimeLocal','DateTimeUtc','TimeLocal','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeLocal',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('CBB78431-AC4C-45DF-B971-2501DCFA83D5','EC5174C1-AD19-4423-8FFF-AE043DC92627','IsPCP','Color','IsPCP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,259,'#FFBFBF',0,NULL,'primary',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('33B6F091-8899-42C2-BDE3-25040D9AC300','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','Action','Select','Action',NULL,NULL,NULL,NULL,NULL,'Action',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5D79346C-1716-421E-A9AD-2584B30B7305','99CECF13-C463-4ABD-A52E-AD923D51AC7C','CallPhase','Image','CallPhase',NULL,NULL,NULL,NULL,'LiteralValue','CallPhase',NULL,0,25,21,NULL,0,NULL,NULL,NULL,41,'CallPhase',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('445BAC65-5F09-4B8F-94B6-2767AB3BDA2B','99CECF13-C463-4ABD-A52E-AD923D51AC7C','LanguageName','ForeignKey','LanguageName',NULL,NULL,NULL,'LanguageId','LanguageName','LanguageName',NULL,0,35,41,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C650ADEB-E5EF-4997-97A4-28DE3EB075D5','EC5174C1-AD19-4423-8FFF-AE043DC92627','SystemName','Text','SystemName',NULL,NULL,NULL,NULL,NULL,'SystemName',NULL,0,160,8,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E3BA0264-D01A-4357-AE4A-292812162207','A10AD2C8-64CB-4AFF-B937-69CFFE292DBA','AgentName','Select','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,180,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AB9F6306-2EB5-46AF-A604-2A78B1261FAA','05D59721-8EED-493D-A88D-A547153AED49','Direction','Image','Direction','~/CustomImages/Dir-{0}.png',NULL,NULL,NULL,'MessageDirection','Direction',NULL,0,25,7,NULL,0,NULL,NULL,NULL,51,'Direction',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('11B52ADD-B974-4E92-B034-2AD0BDFEAEBB','99CECF13-C463-4ABD-A52E-AD923D51AC7C','Redirector','Text','Redirector',NULL,NULL,NULL,NULL,NULL,'Redirector',NULL,0,52,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('FF62440B-710D-475F-90F3-2F3241DA7FC2','99CECF13-C463-4ABD-A52E-AD923D51AC7C','Topic','Text','Téma',NULL,NULL,NULL,NULL,NULL,'Téma',NULL,0,80,152,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BE1F48BD-1585-4257-9C49-315D42DA5A96','05D59721-8EED-493D-A88D-A547153AED49','MessageId','Text','MessageId',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,230,2,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('646192BD-B104-4ACA-82ED-35B8130ED95C','99CECF13-C463-4ABD-A52E-AD923D51AC7C','CallResult','Image','CallResult',NULL,'InboundCallId','~/RC/Pages/calleditor.html?Id={0}',NULL,'LiteralValue','CallResult',NULL,0,25,5,NULL,0,NULL,NULL,NULL,40,'CallResult',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('680D7B13-848A-4A81-BE88-3A59095FF5DF','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','ResultDigits','Text','ResultDigits',NULL,NULL,NULL,NULL,NULL,'ResultDigits',NULL,0,80,100,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('FDE85401-B437-4DF8-8574-3A69ABE335BA','A10AD2C8-64CB-4AFF-B937-69CFFE292DBA','TimeUtc','DateTimeUtc','TimeUtc','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeUtc',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('080AA4AB-4619-48D2-8999-3DD44319EB66','D1F1F295-8801-423B-AAFD-9222EE4892FC','Model','Select','Model',NULL,NULL,NULL,NULL,NULL,'Model',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('1629E9D8-0379-4183-8C82-3E21F0CE9A81','05D59721-8EED-493D-A88D-A547153AED49','SubjectField','HyperLink','SubjectField',NULL,'MessageId','/RC/Pages/MessageEditor.html?Id={0}','SubjectField',NULL,'SubjectField',NULL,0,160,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('2D7F3315-84F7-4F7F-AEF4-4009969C660E','68DF515A-31D7-4137-B661-9CE2C40A601A','Paired','Select','Sparovano',NULL,NULL,NULL,NULL,NULL,'Sparovano',NULL,0,80,9,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E3C620A5-B76E-429D-836F-423A12BE3FC8','EC5174C1-AD19-4423-8FFF-AE043DC92627','Logon','Select','V_Praci',NULL,NULL,NULL,NULL,NULL,'V_Praci',NULL,0,80,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D34D9CE2-193C-4B9D-8785-4282D794068E','05D59721-8EED-493D-A88D-A547153AED49','IsLate','Color','IsLate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,'#FFE9D1',0,NULL,'warning',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('FB6D27D0-3C99-4CF9-8B6B-430639B3E0B4','F66FF314-27AB-4330-AFFA-937B005A0B47','Rank','Integer','Rank',NULL,NULL,NULL,NULL,NULL,'Rank',NULL,0,60,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F662FD34-2447-4651-8E1F-44DC5A07E6C8','77F81F33-C8A9-4883-A480-C3D29D8541CC','DisplayName','Text','DisplayName',NULL,NULL,NULL,NULL,NULL,'DisplayName',NULL,0,160,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F87826D6-C07F-4154-8FC1-487F663FAACD','77F81F33-C8A9-4883-A480-C3D29D8541CC','LastMessage','Text','LastMessage',NULL,NULL,NULL,NULL,NULL,'LastMessage',NULL,0,200,37,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B81671A1-5ABC-4391-9D80-4CE0AE94CE48','68DF515A-31D7-4137-B661-9CE2C40A601A','RemoteName','Text','RemoteName',NULL,NULL,NULL,NULL,NULL,'RemoteName',NULL,0,80,80,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('02FC4782-A1DE-4F97-9DB6-4E2F2B3C0448','EC5174C1-AD19-4423-8FFF-AE043DC92627','IsBusy','Color','IsBusy',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,249,'#FFFFC9',0,NULL,'danger',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0C503371-2401-404C-87EF-504FFA55ADCB','2ECAA8BB-0E67-4F5E-817A-7DD0E020C2C6','PageName','Select','PageName',NULL,NULL,NULL,NULL,NULL,'PageName',NULL,0,100,12,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('77A3EF1B-4B70-42B7-A2DD-50E41261656F','D1F1F295-8801-423B-AAFD-9222EE4892FC','Color','Text','Color',NULL,NULL,NULL,NULL,NULL,'Color',NULL,0,80,140,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5E62E191-B062-47AA-A122-52850023B762','E67F9717-E912-4F37-8C81-EAD7C65C7800','EmailCount','Integer','EmailCount',NULL,NULL,NULL,NULL,NULL,'EmailCount',NULL,0,60,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('23E4277E-3E5A-462C-AF12-52A3D595E5A6','D1F1F295-8801-423B-AAFD-9222EE4892FC','Rank','Integer','Rank',NULL,NULL,NULL,NULL,NULL,'Rank',NULL,0,60,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('57983254-4C4B-40C2-9532-52FE4F774ED1','F66FF314-27AB-4330-AFFA-937B005A0B47','DisplayName','Text','DisplayName',NULL,NULL,NULL,NULL,NULL,'DisplayName',NULL,0,200,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B70355AF-078A-44D9-A9C6-562855EB95BE','832E1DA3-C87E-4E51-A7A6-CA1EC2ABCDFD','InboundCallId','Text','InboundCallId',NULL,NULL,NULL,NULL,NULL,'InboundCallId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('827C76DE-024C-4377-8FFA-569D5917F938','68DF515A-31D7-4137-B661-9CE2C40A601A','ExtensionNumber','Text','ExtensionNumber',NULL,NULL,NULL,NULL,NULL,'ExtensionNumber',NULL,0,80,90,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('CB3C4010-6F53-4C35-8A07-5703E57DC9B9','F66FF314-27AB-4330-AFFA-937B005A0B47','PhoneBookName','Select','PhoneBookName',NULL,NULL,NULL,NULL,NULL,'PhoneBookName',NULL,0,120,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('11AEEB7E-E871-48FA-B0DB-594C2D153ED7','99CECF13-C463-4ABD-A52E-AD923D51AC7C','InboundCallId','Text','InboundCallId',NULL,NULL,NULL,NULL,NULL,'InboundCallId',NULL,0,230,3,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AA0C32C1-CCE3-40EE-B163-598E6FFB6387','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','Numbers','Text','Numbers',NULL,NULL,NULL,NULL,NULL,'Numbers',NULL,0,120,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0B2B3B29-9914-4FF6-9DFE-59E389A68D8A','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','TargetOnFailure','Integer','TargetOnFailure',NULL,NULL,NULL,NULL,NULL,'TargetOnFailure',NULL,0,60,210,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A20427B2-0516-45C4-9925-5A17D44D39FC','882362DC-F36F-4248-AD4D-64D1A883E91A','EventType','Text','cEventType',NULL,NULL,NULL,NULL,'LiteralValue','cEventType',NULL,0,100,20,NULL,0,NULL,NULL,500,44,'EventType',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('CA2B5E79-AFFE-4B3E-B8FD-5C5BF4A9DC4D','99CECF13-C463-4ABD-A52E-AD923D51AC7C','PilotName','Text','PilotName',NULL,NULL,NULL,NULL,NULL,'PilotName',NULL,0,80,15,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C3B00E7A-87D7-4806-9BB9-5C93622B02C9','77F81F33-C8A9-4883-A480-C3D29D8541CC','InformBySecondMatch','Color','InformBySecondMatch',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('69917DFD-0F7A-442C-A9A5-5CEA38CD69C1','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','MultiLanguage','Color','MultiLanguage',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9DEA706F-446B-4B0B-B948-5E8E59B9B8AF','05D59721-8EED-493D-A88D-A547153AED49','MessageTime','DateTimeFromTo','MessageTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'MessageTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('730BFC83-6287-4CE6-961C-5F531097B932','EC5174C1-AD19-4423-8FFF-AE043DC92627','IsFree','Color','IsFree',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,220,'#CCFADF',0,NULL,'success',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D9740220-2EF9-43F0-92CB-601AB15DE830','05D59721-8EED-493D-A88D-A547153AED49','TimeUtc','DateTimeUtc','TimeUtc','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeUtc',NULL,0,100,103,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('58C2E0B8-F526-47BB-B0B3-6020E45A0B43','2ECAA8BB-0E67-4F5E-817A-7DD0E020C2C6','DataQueryId','Text','DataQueryId',NULL,NULL,NULL,NULL,NULL,'DataQueryId',NULL,0,230,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AF6184DA-207E-4CD6-AD11-620A78F84D3C','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','TargetOnSuccess','Integer','TargetOnSuccess',NULL,NULL,NULL,NULL,NULL,'TargetOnSuccess',NULL,0,60,200,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E87D56CD-9341-4A8E-BA32-6314638DEA77','832E1DA3-C87E-4E51-A7A6-CA1EC2ABCDFD','CallerNumber','Text','CallerNumber',NULL,NULL,NULL,NULL,NULL,'CallerNumber',NULL,0,110,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('22AC5F3E-8639-45D7-8E49-638E49A089BA','832E1DA3-C87E-4E51-A7A6-CA1EC2ABCDFD','QueueDuration','Duration','QueueDuration',NULL,NULL,NULL,NULL,NULL,'QueueDuration',NULL,0,60,25,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('2697C057-D8AD-469A-A071-65E253653AE8','A10AD2C8-64CB-4AFF-B937-69CFFE292DBA','RefInserts','Text','RefInserts',NULL,NULL,NULL,NULL,NULL,'RefInserts',NULL,0,200,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('21E79DDA-A8D4-4213-B0D6-67C95930C014','68DF515A-31D7-4137-B661-9CE2C40A601A','StartTimeUtc','DateTimeUtc','StartTimeUtc','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'StartTimeUtc',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('3BAE2B5F-CE0B-40E0-B43D-6834D69E86B7','E67F9717-E912-4F37-8C81-EAD7C65C7800','AgentName','Select','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,160,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('94374982-4FEB-43BB-A398-6865DF64B3E0','77F81F33-C8A9-4883-A480-C3D29D8541CC','Command','Text','Command',NULL,NULL,NULL,NULL,NULL,'Command',NULL,0,120,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('21C55221-A0C4-4535-86D4-69BCB8CEFB14','D1F1F295-8801-423B-AAFD-9222EE4892FC','Width','Integer','Width',NULL,NULL,NULL,NULL,NULL,'Width',NULL,0,60,120,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4BF7E760-D8AC-4D5E-8CDA-69FFEC23BACD','99CECF13-C463-4ABD-A52E-AD923D51AC7C','TimeUtc','DateTimeUtc','TimeUtc','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeUtc',NULL,0,100,102,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('1DCBA3AA-E6B1-457D-80E7-6A01E2EE89F9','EC5174C1-AD19-4423-8FFF-AE043DC92627','AgentId','Text','AgentId',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0F1E2ADF-23F6-4BB9-947A-6B57C710B92B','05D59721-8EED-493D-A88D-A547153AED49','MessageType','Image','MessageType','~/CustomImages/{0}.png','MessageId','/RC/Pages/MessageEditor.html?Id={0}',NULL,'LiteralValue','MessageType',NULL,0,25,5,NULL,0,NULL,NULL,NULL,50,'MessageType',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6BD0CA43-6C3C-46A4-AB61-6CDEFB1D7E95','D1F1F295-8801-423B-AAFD-9222EE4892FC','GuidColumn','Text','GuidColumn',NULL,NULL,NULL,NULL,NULL,'GuidColumn',NULL,0,80,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('8B3DA770-DFC7-421E-8D1F-71FCC4EF4544','882362DC-F36F-4248-AD4D-64D1A883E91A','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,80,41,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F22FBE47-887B-4D6A-987A-7365C6E3CBCC','F66FF314-27AB-4330-AFFA-937B005A0B47','Emails','Text','Emails',NULL,NULL,NULL,NULL,NULL,'Emails',NULL,0,160,110,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C3AA967F-BDC3-4954-B410-738C034A7FEB','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','IvrScriptId','Text','IvrScriptId',NULL,NULL,NULL,NULL,NULL,'IvrScriptId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A57ECDC9-2421-4822-BC86-766287C76A66','EC5174C1-AD19-4423-8FFF-AE043DC92627','LastOutCall','DateTimeFromTo','LastOutCall','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'LastOutCall',NULL,0,100,140,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BA91CC3E-0B05-4657-A1E9-76F0E2691275','77F81F33-C8A9-4883-A480-C3D29D8541CC','Note','Text','Note',NULL,NULL,NULL,NULL,NULL,'Note',NULL,0,80,120,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DBD3630B-9C61-4E6C-BBCA-77CD16D94DCC','882362DC-F36F-4248-AD4D-64D1A883E91A','Rank','Integer','Navesti',NULL,NULL,NULL,NULL,NULL,'Navesti',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('675D5EBE-4B12-428E-8194-77EB92349B71','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','Targetid','Text','Targetid',NULL,NULL,NULL,NULL,NULL,'Targetid',NULL,0,230,135,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5F0EA6BC-ABDB-4602-93A6-7983AEA4E6D7','99CECF13-C463-4ABD-A52E-AD923D51AC7C','WorkplaceName','ForeignKey','WorkplaceName',NULL,NULL,NULL,'WorkplaceId','WorkplaceName','WorkplaceName',NULL,0,90,61,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AAC25E88-7A22-4620-88CC-7A2975AC7B13','77F81F33-C8A9-4883-A480-C3D29D8541CC','ExecDuration','Duration','ExecDuration',NULL,NULL,NULL,NULL,NULL,'ExecDuration',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C0222EA4-30D9-4E8D-B28C-7AA1CB7F26A9','882362DC-F36F-4248-AD4D-64D1A883E91A','InboundCallId','Text','InboundCallId',NULL,NULL,NULL,NULL,NULL,'InboundCallId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F7C3DFEB-301F-47C0-988F-7B0C371F1944','05D59721-8EED-493D-A88D-A547153AED49','FromField','Text','FromField',NULL,NULL,NULL,'FromField',NULL,'FromField',NULL,0,120,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6A217B8A-1FB0-4A9C-A13F-7B565A77C17F','2ECAA8BB-0E67-4F5E-817A-7DD0E020C2C6','QueryGroup','Select','QueryGroup',NULL,NULL,NULL,NULL,NULL,'QueryGroup',NULL,0,80,167,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4BF972FC-D4A2-41C4-BD40-7D9457520F3C','F66FF314-27AB-4330-AFFA-937B005A0B47','Numbers','HyperLink','Numbers',NULL,'PhoneNumberId','/RC/Pages/PhoneNumberEditor.html?Id={0}',NULL,NULL,'Numbers',NULL,0,100,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D424D11A-F32D-4BA5-B1FC-7E1D49E7E30C','05D59721-8EED-493D-A88D-A547153AED49','BodyField','Text','BodyField',NULL,NULL,NULL,NULL,NULL,'BodyField',NULL,0,80,113,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B50F7741-D2C0-4DFC-84BC-7E85A32AB8A8','77F81F33-C8A9-4883-A480-C3D29D8541CC','RepeatAfterMin','Integer','RepeatAfterMin',NULL,NULL,NULL,NULL,NULL,'RepeatAfterMin',NULL,0,60,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('93B9485B-4282-4B57-A13B-7EB589FABD86','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','TimeOut','Integer','TimeOut',NULL,NULL,NULL,NULL,NULL,'TimeOut',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4793295E-B4D8-4012-AE2A-800FC9223396','77F81F33-C8A9-4883-A480-C3D29D8541CC','Inform1','Integer','Inform1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,45,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('86BFBC38-8E3E-4946-8E10-80B79293CEEF','D1F1F295-8801-423B-AAFD-9222EE4892FC','Convertor','Text','Convertor',NULL,NULL,NULL,NULL,NULL,'Convertor',NULL,0,80,80,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('41F0910F-997D-4F20-B9E5-81D508C8694E','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','FileName','Text','FileName',NULL,NULL,NULL,NULL,NULL,'FileName',NULL,0,140,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('298D8543-07C3-43ED-AD6D-827A2CF09BA7','D1F1F295-8801-423B-AAFD-9222EE4892FC','SqlCmd','Text','SqlCmd',NULL,NULL,NULL,NULL,NULL,'SqlCmd',NULL,0,80,160,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B94FE1AD-47A0-4015-A843-83B7F3490654','68DF515A-31D7-4137-B661-9CE2C40A601A','FileName','Text','FileName',NULL,NULL,NULL,NULL,NULL,'FileName',NULL,0,300,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F66FC522-6F9B-4F43-8865-880228DDE3F7','D1F1F295-8801-423B-AAFD-9222EE4892FC','DataQueryId','Text','DataQueryId',NULL,NULL,NULL,NULL,NULL,'DataQueryId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('42E845CE-866A-47A2-8853-88384D8145A9','05D59721-8EED-493D-A88D-A547153AED49','RelatedMessageId','Text','RelatedMessageId',NULL,NULL,NULL,NULL,NULL,'RelatedMessageId',NULL,0,230,130,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C4A9F639-CF4F-455B-B3F7-896CEAA2AD15','99CECF13-C463-4ABD-A52E-AD923D51AC7C','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,'AgentName','AgentName',NULL,0,120,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EED45261-B01A-426D-B0C1-8A802793CD7E','E67F9717-E912-4F37-8C81-EAD7C65C7800','WP with email','Select','EmailPovolenPracov',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,150,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EB82DE41-192D-4C3A-8D44-8CDDAA6BED1B','2ECAA8BB-0E67-4F5E-817A-7DD0E020C2C6','NAVGroup','Select','NAVGroup',NULL,NULL,NULL,NULL,NULL,'NAVGroup',NULL,0,120,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('464DC690-B736-4805-A9A2-8CF2EB530C34','2ECAA8BB-0E67-4F5E-817A-7DD0E020C2C6','Description','Text','Description',NULL,NULL,NULL,NULL,NULL,'Description',NULL,0,80,172,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('749BBB7B-4D65-427E-BB56-8D3D55542887','D1F1F295-8801-423B-AAFD-9222EE4892FC','DQName','Select','DQName',NULL,NULL,NULL,NULL,NULL,'DQName',NULL,0,200,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('978D307A-735E-4F15-B4AF-8D7BABC4EDFF','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','TargetOnTimeOut','Integer','TargetOnTimeOut',NULL,NULL,NULL,NULL,NULL,'TargetOnTimeOut',NULL,0,60,190,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DCE4572C-BC39-4818-891A-90FBE299CE22','882362DC-F36F-4248-AD4D-64D1A883E91A','Action','Text','Akce',NULL,NULL,NULL,NULL,NULL,'Akce',NULL,0,80,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DEDF11D3-F9FF-4871-8E3D-936C841E4D16','EC5174C1-AD19-4423-8FFF-AE043DC92627','Extension','Text','Extension',NULL,NULL,NULL,NULL,NULL,'Extension',NULL,0,45,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('FBC47698-A8E7-44E9-A2DA-93BAE75DF508','882362DC-F36F-4248-AD4D-64D1A883E91A','ProjectName','Text','ProjectName',NULL,NULL,NULL,NULL,NULL,'ProjectName',NULL,0,120,44,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B55A43CD-F471-45BA-97A8-94D2E195794F','05D59721-8EED-493D-A88D-A547153AED49','ToField','Text','ToField',NULL,NULL,NULL,'ToField',NULL,'ToField',NULL,0,100,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('371EF982-25F6-49C0-9000-96ABB31C24F2','EC5174C1-AD19-4423-8FFF-AE043DC92627','IsRinging','Color','IsRinging',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,269,'#FFC080',0,NULL,'success',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DD35B6CF-3B57-47DD-BED7-97252667FF68','68DF515A-31D7-4137-B661-9CE2C40A601A','StationName','Text','StationName',NULL,NULL,NULL,NULL,NULL,'StationName',NULL,0,80,110,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5E8E992A-0120-4F3E-9D00-974D05A812A7','D1F1F295-8801-423B-AAFD-9222EE4892FC','Css','Text','Css',NULL,NULL,NULL,NULL,NULL,'Css',NULL,0,80,170,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B54319E3-1479-4079-BDA2-97D98C5A97BD','882362DC-F36F-4248-AD4D-64D1A883E91A','FileName','Text','Hlaska',NULL,NULL,NULL,NULL,NULL,'Hlaska',NULL,0,160,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BD868696-E3F7-430C-8FE5-9800A9C38146','354E10A1-14F7-4F66-B1AA-9B7FFEE2B91F','Duration','Duration','Duration',NULL,NULL,NULL,NULL,NULL,'Duration',NULL,0,60,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F332930B-A4EF-48C5-9ADF-9AD0376189CD','99CECF13-C463-4ABD-A52E-AD923D51AC7C','CallDuration','Duration','CallDuration',NULL,NULL,NULL,NULL,'DurationMSS','CallDuration',NULL,0,50,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('2462AE70-ABE3-4B12-B811-9B9375DE736B','E67F9717-E912-4F37-8C81-EAD7C65C7800','Agent Status','Select','Statusagenta',NULL,NULL,NULL,NULL,NULL,'Statusagenta',NULL,0,80,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('21D2DC2B-BD9C-4619-BC5B-9E078670A8D2','E67F9717-E912-4F37-8C81-EAD7C65C7800','ProjectName','Select','ProjectName',NULL,NULL,NULL,NULL,NULL,'ProjectName',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('82DCC13A-DC41-4E15-B2A4-9EBF69AE8CAA','77F81F33-C8A9-4883-A480-C3D29D8541CC','ReparationProc','Text','ReparationProc',NULL,NULL,NULL,NULL,NULL,'ReparationProc',NULL,0,80,160,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('05C5989D-98BE-49A0-8D9F-9F97ED6E586A','D1F1F295-8801-423B-AAFD-9222EE4892FC','GlyphFormat','Text','GlyphFormat',NULL,NULL,NULL,NULL,NULL,'GlyphFormat',NULL,0,80,200,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E257319A-C0C2-4E2F-BE69-A083857568FB','882362DC-F36F-4248-AD4D-64D1A883E91A','IvrScript','Text','IvrSkript',NULL,NULL,NULL,NULL,NULL,'IvrSkript',NULL,0,140,45,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6B7655D4-37C2-4B6B-8D85-A30F286EE768','A10AD2C8-64CB-4AFF-B937-69CFFE292DBA','RefDeletes','Text','RefDeletes',NULL,NULL,NULL,NULL,NULL,'RefDeletes',NULL,0,200,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('8AC268BE-CCB4-43F4-97CE-A34A4C0FDAD5','2F0FD1D8-017A-4A7C-BE35-A8C02F46007D','ReferenceId','Text','ReferenceId',NULL,NULL,NULL,NULL,NULL,'ReferenceId',NULL,0,230,55,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DEE3F09B-522B-4335-82D3-A35FC4020162','E67F9717-E912-4F37-8C81-EAD7C65C7800','Status with email','Select','EmailPovolenStav',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,150,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C497EB6D-9483-4F8C-857F-A3B04B444007','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','TimeFrom','DateTimeFromTo','TimeFrom','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeFrom',NULL,0,100,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DBD9F570-B668-462E-AB25-A3E153AA0C49','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','ScriptName','Select','ScriptName',NULL,NULL,NULL,NULL,NULL,'ScriptName',NULL,0,120,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6438D40B-E7C7-4378-AAE9-A5BEBE778845','05D59721-8EED-493D-A88D-A547153AED49','MessagePhase','Select','MessagePhase',NULL,NULL,NULL,NULL,'MessagePhase','MessagePhase',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('21D124ED-2E7E-42F2-8518-A6C0FAAAAF31','EC5174C1-AD19-4423-8FFF-AE043DC92627','IsPause','Color','IsPause',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,239,'#C0C0FF',0,NULL,'info',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D1C196A7-F361-435C-872B-A9318CF11AB7','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','Retries','Integer','Retries',NULL,NULL,NULL,NULL,NULL,'Retries',NULL,0,60,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9517C788-810E-4EE9-BBCF-AAE8B5E6C85D','05D59721-8EED-493D-A88D-A547153AED49','GatewayName','ForeignKey','GatewayName',NULL,NULL,NULL,'GatewayId','GatewayName','GatewayName',NULL,0,130,65,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('969BD91A-F51D-4463-ACA8-AC355E577916','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','StepName','HyperLink','StepName',NULL,'IVRStepId','http://localhost/fsadmin/RC/Pages/IvrSteps/EditForm.aspx?Id={0}',NULL,NULL,'StepName',NULL,0,200,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('02E23BB7-013D-4358-8FD2-AD7E8F947D61','372F67E1-C08D-49DA-A1CE-89E875A1D68B','Count','Integer','Pocet',NULL,NULL,NULL,NULL,NULL,'Pocet',NULL,0,60,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('65972533-FCF1-4646-A2C5-ADA5B39ACDA1','F66FF314-27AB-4330-AFFA-937B005A0B47','Description','Text','Description',NULL,NULL,NULL,NULL,NULL,'Description',NULL,0,200,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('61C903A0-B599-478F-87BF-ADDDFBD2546D','832E1DA3-C87E-4E51-A7A6-CA1EC2ABCDFD','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,120,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('3330372C-E968-4BAD-AFCC-AE1571827BED','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','Culture','Text','Culture',NULL,NULL,NULL,NULL,NULL,'Culture',NULL,0,80,180,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D58C45C8-AE4B-4259-B3DE-AE7E7CD3E38A','05D59721-8EED-493D-A88D-A547153AED49','LanguageName','ForeignKey','LanguageName',NULL,NULL,NULL,'LanguageId','LanguageName','LanguageName',NULL,0,35,71,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9035B29D-1E07-4BDE-8DCF-AF2ADB7CD8D1','2F0FD1D8-017A-4A7C-BE35-A8C02F46007D','MessageId','Text','MessageId',NULL,NULL,NULL,NULL,NULL,'MessageId',NULL,0,230,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('02141084-FCAF-499F-BC62-AF66A9AD8EE6','05D59721-8EED-493D-A88D-A547153AED49','ProjectName','ForeignKey','ProjectName',NULL,NULL,NULL,'ProjectId','ProjectName','ProjectName',NULL,0,100,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5FDFCB63-D7D7-4772-8312-B0507E9141C2','77F81F33-C8A9-4883-A480-C3D29D8541CC','Inform2','Integer','Inform2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,45,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('3334B185-D766-4273-8CCF-B23CFC03721B','05D59721-8EED-493D-A88D-A547153AED49','TeamName','Select','TeamName',NULL,NULL,NULL,NULL,NULL,'TeamName',NULL,0,80,61,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AA24D32B-297F-402B-A4C5-B2870856CB30','05D59721-8EED-493D-A88D-A547153AED49','IssueId','Text','IssueId',NULL,NULL,NULL,NULL,NULL,'IssueId',NULL,0,230,120,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('14AC4C49-0F4B-4E6E-923E-B4A1746E42DC','A10AD2C8-64CB-4AFF-B937-69CFFE292DBA','RefUpdates','Text','RefUpdates',NULL,NULL,NULL,NULL,NULL,'RefUpdates',NULL,0,200,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('086B3FB7-0741-4A9B-BAC4-B578D177D37A','68DF515A-31D7-4137-B661-9CE2C40A601A','TimeUtc','DateTimeUtc','TimeUtc','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeUtc',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DF9DF293-B7CE-4869-84DB-B693CD0D59C5','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','TimeTo','DateTimeFromTo','TimeTo','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeTo',NULL,0,100,170,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F6313B6F-26A2-4EE6-B4BA-B9A6731D7A87','68DF515A-31D7-4137-B661-9CE2C40A601A','Direction','Text','Direction',NULL,NULL,NULL,NULL,NULL,'Direction',NULL,0,40,8,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('68D23E42-4BD4-4C47-B57A-BA61C7BBBEEF','99CECF13-C463-4ABD-A52E-AD923D51AC7C','Foreign','Select','Zahranicni',NULL,NULL,NULL,NULL,NULL,'Zahranicni',NULL,0,54,17,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('14B1947B-3410-4178-A76E-BC103EA39DB7','68DF515A-31D7-4137-B661-9CE2C40A601A','Duration','Duration','Duration',NULL,NULL,NULL,NULL,'DurationHMMSS','Duration',NULL,0,60,35,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9BEC708B-070B-4B22-96F6-BCABE87B3B21','99CECF13-C463-4ABD-A52E-AD923D51AC7C','SubTopic','Text','Podtéma',NULL,NULL,NULL,NULL,NULL,'Podtéma',NULL,0,80,162,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('061F75B2-DA8C-4DFA-A639-BDEAD0D610DF','EC5174C1-AD19-4423-8FFF-AE043DC92627','WorkplaceStatus','Select','WorkplaceStatus',NULL,NULL,NULL,NULL,'WorkplaceState','WorkplaceStatus',NULL,0,70,120,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C1854074-8ED4-4DB2-BCAC-BE9C009E10B0','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','ReplayDigits','Text','ReplayDigits',NULL,NULL,NULL,NULL,NULL,'ReplayDigits',NULL,0,80,120,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('21AAA025-B0EB-4F4C-AE7A-BF6BA372E124','D1F1F295-8801-423B-AAFD-9222EE4892FC','NoFilter','Color','NoFilter',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,110,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('3094B185-1579-439A-9F14-C0256FD8F547','99CECF13-C463-4ABD-A52E-AD923D51AC7C','IsLost','Color','IsLost',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,91,'#FFE9D1',0,NULL,'warning',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AAAF0569-0449-4D0A-856F-C2E204EFBFCC','D1F1F295-8801-423B-AAFD-9222EE4892FC','GlyphColumn','Text','GlyphColumn',NULL,NULL,NULL,NULL,NULL,'GlyphColumn',NULL,0,80,190,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('367B59CA-A1A8-4205-9CBD-C502765B5F78','D1F1F295-8801-423B-AAFD-9222EE4892FC','TargetColumn','Text','TargetColumn',NULL,NULL,NULL,NULL,NULL,'TargetColumn',NULL,0,100,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6395EFA7-0AE5-4646-9A48-C78AF0A5EDA5','2F0FD1D8-017A-4A7C-BE35-A8C02F46007D','TimeUtc','DateTimeUtc','TimeUtc','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeUtc',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('FBC910C7-C105-47EC-A19B-CB856F658C78','77F81F33-C8A9-4883-A480-C3D29D8541CC','LastRunTime','DateTimeUtc','LastRunTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'LastRunTime',NULL,0,100,35,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('1504B341-368E-4C3C-8819-CC81E4A5684E','99CECF13-C463-4ABD-A52E-AD923D51AC7C','ExRecording','Select','ExRecording',NULL,NULL,NULL,NULL,NULL,'ExRecording',NULL,0,40,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B2362453-765B-46DF-8D68-CC92985D34F9','2F0FD1D8-017A-4A7C-BE35-A8C02F46007D','EventType','Text','EventType',NULL,NULL,NULL,NULL,NULL,'EventType',NULL,0,80,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DF8BE901-C6B3-4A36-865C-CDC910EEA416','2ECAA8BB-0E67-4F5E-817A-7DD0E020C2C6','HashPage','Select','HashPage',NULL,NULL,NULL,NULL,NULL,'HashPage',NULL,0,120,15,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('1B2A73A6-4F6D-4A36-9E82-CEA7DFBFAC7F','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','SkipDigits','Text','SkipDigits',NULL,NULL,NULL,NULL,NULL,'SkipDigits',NULL,0,80,110,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('1D2373C4-758F-4C68-ABC2-CEF2EBFC7C77','77F81F33-C8A9-4883-A480-C3D29D8541CC','RunToHour','Integer','RunToHour',NULL,NULL,NULL,NULL,NULL,'RunToHour',NULL,0,60,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6975B5E9-B0AD-4363-BA18-D04BEAA40BBB','77F81F33-C8A9-4883-A480-C3D29D8541CC','Inform3','Integer','Inform3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,45,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('57B2264F-FA48-42A5-854F-D0B0A6F34E0E','99CECF13-C463-4ABD-A52E-AD923D51AC7C','IssueId','Text','IssueId',NULL,NULL,NULL,NULL,NULL,'IssueId',NULL,0,230,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6F563251-5EC1-4149-985B-D13D070F9321','05D59721-8EED-493D-A88D-A547153AED49','IsActive','Color','IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,93,'#CCFADF',0,NULL,'success',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E7EB20A5-9702-41AE-980D-D14068BE5B73','354E10A1-14F7-4F66-B1AA-9B7FFEE2B91F','ReferenceData','Text','ReferenceData',NULL,NULL,NULL,NULL,NULL,'ReferenceData',NULL,0,80,80,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A5B91D8E-36E5-49FE-A9D7-D1DDC464199E','882362DC-F36F-4248-AD4D-64D1A883E91A','Duration','Duration','Duration',NULL,NULL,NULL,NULL,NULL,'Duration',NULL,0,60,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('28B95C5D-31C2-4E42-97D6-D4674559C939','77F81F33-C8A9-4883-A480-C3D29D8541CC','LastMessTime','DateTimeFromTo','LastMessTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'LastMessTime',NULL,0,100,38,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5E163A39-DC2A-4FC1-BB25-D5FF50210B81','354E10A1-14F7-4F66-B1AA-9B7FFEE2B91F','OutboundCallId','Text','OutboundCallId',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9162A7D4-B7CC-454B-9E07-D6F89C2B4564','05D59721-8EED-493D-A88D-A547153AED49','TimeUtc','DateTimeUtc','TimeUtc','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeUtc',NULL,0,100,15,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('56A377A0-C8BD-4ECD-8741-D73D2DC60CD1','882362DC-F36F-4248-AD4D-64D1A883E91A','IvrStep','Text','Ivrkrok',NULL,NULL,NULL,NULL,NULL,'Ivrkrok',NULL,0,80,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A06AB3DA-7DEB-47A6-9811-D8042DA02BF3','882362DC-F36F-4248-AD4D-64D1A883E91A','ResultData','Text','ResultData',NULL,NULL,NULL,NULL,NULL,'ResultData',NULL,0,200,100,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4DFD2C79-BA2F-4314-97FE-DAE37B393CF2','05D59721-8EED-493D-A88D-A547153AED49','AgentName','ForeignKey','AgentName',NULL,NULL,NULL,'AgentId','AgentName','AgentName',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5163B6C4-7FA7-4159-9F20-DD3B4BC8A8A1','882362DC-F36F-4248-AD4D-64D1A883E91A','CallerNumber','Text','CallerNumber',NULL,NULL,NULL,NULL,NULL,'CallerNumber',NULL,0,70,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('32549298-A4BC-4F9F-8611-DDB267C9D5E2','882362DC-F36F-4248-AD4D-64D1A883E91A','TimeLocal','DateTimeFromTo','TimeLocal','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeLocal',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A623AE54-682F-4968-8455-DDFAB410CD64','2F0FD1D8-017A-4A7C-BE35-A8C02F46007D','ResultData','Text','ResultData',NULL,NULL,NULL,NULL,NULL,'ResultData',NULL,0,200,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('254B885A-0116-4EF3-8CD6-E06F36426BF1','D1F1F295-8801-423B-AAFD-9222EE4892FC','TargetFormat','Text','TargetFormat',NULL,NULL,NULL,NULL,NULL,'TargetFormat',NULL,0,80,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DAD81799-E3A9-4531-A1D7-E0772E75CD2B','68DF515A-31D7-4137-B661-9CE2C40A601A','VoiceRecordId','Text','VoiceRecordId',NULL,NULL,NULL,NULL,NULL,'VoiceRecordId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B0CA6C20-E0D3-4C82-A78B-E08384FBEA51','2F0FD1D8-017A-4A7C-BE35-A8C02F46007D','Duration','Duration','Duration',NULL,NULL,NULL,NULL,NULL,'Duration',NULL,0,60,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0047AB04-D547-4173-AD26-E11A5DC1B935','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','Called Script','Text','VolanySkript',NULL,NULL,NULL,NULL,NULL,'VolanySkript',NULL,0,160,137,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6E0650DA-99B3-48D4-97EA-E170B3E129AC','D1F1F295-8801-423B-AAFD-9222EE4892FC','SortExpressionDesc','Text','SortExpressionDesc',NULL,NULL,NULL,NULL,NULL,'SortExpressionDesc',NULL,0,80,100,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B42A0F34-2A74-4BD0-8797-E22C2805FF5D','D1F1F295-8801-423B-AAFD-9222EE4892FC','UrlFormat','Text','UrlFormat',NULL,NULL,NULL,NULL,NULL,'UrlFormat',NULL,0,300,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('88E56224-83C2-4021-9B24-E2EA9EDA68A8','354E10A1-14F7-4F66-B1AA-9B7FFEE2B91F','ResultData','Text','ResultData',NULL,NULL,NULL,NULL,NULL,'ResultData',NULL,0,200,100,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BE4973CD-5AAB-4A02-9303-E367EC88B9AD','99CECF13-C463-4ABD-A52E-AD923D51AC7C','PilotTime','DateTimeFromTo','PilotTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'PilotTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0385A114-DD6F-47CD-80D1-E4534F4A28F9','2F0FD1D8-017A-4A7C-BE35-A8C02F46007D','DisplayName','Text','DisplayName',NULL,NULL,NULL,NULL,NULL,'DisplayName',NULL,0,120,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('07991FC2-6156-41C8-B141-E519F6030A33','A10AD2C8-64CB-4AFF-B937-69CFFE292DBA','TableNames','Select','TableNames',NULL,NULL,NULL,NULL,NULL,'TableNames',NULL,0,80,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AF88285B-763C-4377-9428-E559462D8E3A','E67F9717-E912-4F37-8C81-EAD7C65C7800','MaxEmailCount','Integer','MaxEmailCount',NULL,NULL,NULL,NULL,NULL,'MaxEmailCount',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('493B9337-93BA-46D6-AF60-E5F5703648E5','EC5174C1-AD19-4423-8FFF-AE043DC92627','ExPerso','Text','ExPerso',NULL,NULL,NULL,NULL,NULL,'ExPerso',NULL,0,65,3,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('8F19062A-43D1-44A1-B56E-E7DE233ED755','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','IVRStepId','Toggle','IVRStepId',NULL,NULL,'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,30,1,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('3C48C60E-2298-4F9F-B14B-E8B81F59AC9D','E67F9717-E912-4F37-8C81-EAD7C65C7800','Lang knowledge','Select','ZnalostJazyka',NULL,NULL,NULL,NULL,NULL,'ZnalostJazyka',NULL,0,80,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0129B197-6D94-4EBE-AC9E-EA25324B474E','99CECF13-C463-4ABD-A52E-AD923D51AC7C','CallerNumber','HyperLink','CallerNumber',NULL,'InboundCallId','~/RC/Pages/calleditor.html?Id={0}',NULL,NULL,'CallerNumber',NULL,0,80,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('741E11C2-69E1-422B-9190-EB6BD569FBD5','2F0FD1D8-017A-4A7C-BE35-A8C02F46007D','ProjectName','Text','ProjectName',NULL,NULL,NULL,NULL,NULL,'ProjectName',NULL,0,140,35,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B9E3755E-499A-432D-AA27-ECBAF34AA026','832E1DA3-C87E-4E51-A7A6-CA1EC2ABCDFD','RegionalTime','DateTimeFromTo','RegionalTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'RegionalTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4C3EE164-D530-4C65-AC46-ED40FA2E3734','05D59721-8EED-493D-A88D-A547153AED49','IsuOpenTime','DateTimeFromTo','IsuOpenTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'IsuOpenTime',NULL,0,100,123,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F7F303F1-02AF-4035-98E3-F11431BCDB92','882362DC-F36F-4248-AD4D-64D1A883E91A','WorkPlaceName','Text','WorkPlaceName',NULL,NULL,NULL,NULL,NULL,'WorkPlaceName',NULL,0,80,42,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AA0334B2-07C8-4777-A393-F30D031E4583','99CECF13-C463-4ABD-A52E-AD923D51AC7C','ProjectName','ForeignKey','ProjectName',NULL,NULL,NULL,'ProjectId','ProjectName','ProjectName',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6515C838-00FE-4649-8679-F38279554C66','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','WaitTimeOut','Integer','WaitTimeOut',NULL,NULL,NULL,NULL,NULL,'WaitTimeOut',NULL,0,60,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DA71EB99-7310-4F15-88C0-F3DE1BB14B54','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','Targets','Text','Targets',NULL,NULL,NULL,NULL,NULL,'Targets',NULL,0,140,130,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0CA645EB-A5B1-4840-A9E5-F5B699FEBA73','832E1DA3-C87E-4E51-A7A6-CA1EC2ABCDFD','ProjectName','Text','ProjectName',NULL,NULL,NULL,NULL,NULL,'ProjectName',NULL,0,80,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('1F49ABD7-E6EE-45AE-AABB-F5E64C34B133','D1F1F295-8801-423B-AAFD-9222EE4892FC','QueryGroup','Select','QueryGroup',NULL,NULL,NULL,NULL,NULL,'QueryGroup',NULL,0,80,9,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('FB1B0C97-B2BA-4224-8EE0-F7A49012E113','D45FDE09-0BF3-4418-BF50-7F11F3E5C0E5','TimeMode','Select','TimeMode',NULL,NULL,NULL,NULL,NULL,'TimeMode',NULL,0,80,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('692155A7-DF81-4FA9-9474-F853DCC79828','99CECF13-C463-4ABD-A52E-AD923D51AC7C','IsActive','Color','IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,'#CCFADF',0,NULL,'success',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F5F8EE10-A84A-407A-88E1-F99951EAADD0','99CECF13-C463-4ABD-A52E-AD923D51AC7C','WQueueName','Text','WQueueName',NULL,NULL,NULL,NULL,NULL,'WQueueName',NULL,0,80,35,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4D0BD303-4B5B-4F09-8292-F9A492495E02','2ECAA8BB-0E67-4F5E-817A-7DD0E020C2C6','Select','Toggle','DQid',NULL,NULL,'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,NULL,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('FB0CBA39-CB32-4597-BDB9-F9D8398A5F99','354E10A1-14F7-4F66-B1AA-9B7FFEE2B91F','EventType','Text','cEventType',NULL,NULL,NULL,NULL,NULL,'cEventType',NULL,0,140,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('958957EE-6381-4510-BDC8-FDB945355587','05D59721-8EED-493D-A88D-A547153AED49','IsNew','Bold','IsNew',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,91,NULL,0,NULL,'warning',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('8FD0CD6B-C3CC-4BBC-A2A2-FE57D9A73FBB','2ECAA8BB-0E67-4F5E-817A-7DD0E020C2C6','QueryName','Text','QueryName',NULL,NULL,NULL,NULL,NULL,'QueryName',NULL,0,200,292,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B23D6374-9D41-40E3-B3D8-FEBE9742D243','EC5174C1-AD19-4423-8FFF-AE043DC92627','AgentName','HyperLink','AgentName',NULL,'AgentId','DataQueryPage.html?Id=73342443-45f0-4c26-aa6c-37335adb34a4&FilterName=AgentId&FilterValue={0}',NULL,NULL,'AgentName',NULL,0,130,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DBEE9892-28A1-41CA-B802-FEDA29AAB7DE','05D59721-8EED-493D-A88D-A547153AED49','RemoteAddress','Text','RemoteAddress',NULL,NULL,NULL,NULL,NULL,'RemoteAddress',NULL,0,80,25,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('88B81A1F-1E9B-473D-AB99-E43B340DA81A','19627BB1-4299-4A30-87EA-63C2E25FB52C','Perform','ImageScript','ProvedAkci',NULL,'RecordId',NULL,NULL,NULL,'ProvedAkci',NULL,0,100,5,NULL,0,'exec .dbo.FSC_PutPNIntoPhBook @Id',NULL,NULL,NULL,NULL,'fa fa-play-circle',NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7CF0AA4B-00E5-46AB-ADF3-34DD146E80CA','19627BB1-4299-4A30-87EA-63C2E25FB52C','Numbers','Text','Numbers',NULL,NULL,NULL,NULL,NULL,'Numbers',NULL,0,100,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E2C3F2E2-FD1C-4CCF-9606-0FF70443F8B8','19627BB1-4299-4A30-87EA-63C2E25FB52C','DisplayName','Text','DisplayName',NULL,NULL,NULL,NULL,NULL,'DisplayName',NULL,0,200,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('70D34BE7-2578-41F0-AAE1-C1035805C307','19627BB1-4299-4A30-87EA-63C2E25FB52C','Description','Text','Description',NULL,NULL,NULL,NULL,NULL,'Description',NULL,0,200,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5C2D2F96-7333-46A8-8BE6-33C4AD202167','19627BB1-4299-4A30-87EA-63C2E25FB52C','PhoneBookName','Text','PhoneBookName',NULL,NULL,NULL,NULL,NULL,'PhoneBookName',NULL,0,120,80,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('73318BA2-1DB3-4733-9746-D49240E09EE7','19627BB1-4299-4A30-87EA-63C2E25FB52C','Emails','Text','Emails',NULL,NULL,NULL,NULL,NULL,'Emails',NULL,0,160,110,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('217FD4D0-0B4D-4879-AB30-EA4F6C60CF2D','19627BB1-4299-4A30-87EA-63C2E25FB52C','Rank','Integer','Rank',NULL,NULL,NULL,NULL,NULL,'Rank',NULL,0,60,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E142A05B-6F00-4313-A9B3-41585FE7636B','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','RecordId','Toggle','RecordId',NULL,NULL,'~/CustomImages/Bullet-{0}.png',NULL,NULL,'RecordId',NULL,0,50,3,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E600B4BD-611E-4185-AA3F-C4FC037ABB72','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','GatewayId','Text','GatewayId',NULL,NULL,NULL,NULL,NULL,'GatewayId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('32ACBE28-CDFE-46CA-B6A2-65274E06770A','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','GateWayName','Text','GateWayName',NULL,NULL,NULL,NULL,NULL,'GateWayName',NULL,0,130,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('0A1C4D01-FC36-4C59-A0B4-5F162EC2B357','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','PilotAddress','Text','PilotAddress',NULL,NULL,NULL,NULL,NULL,'PilotAddress',NULL,0,120,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('92052E02-55B4-4219-A09B-ED87821A2255','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','Direction','Select','Direction',NULL,NULL,NULL,NULL,NULL,'Direction',NULL,0,50,25,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('3B112B84-FCC8-4A33-9C3C-B7409ABFB1F5','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','Received','Integer','Received',NULL,NULL,NULL,NULL,NULL,'Received',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EFDB1DF5-BEDE-4C3B-895C-EA28B2458A14','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','Scheduled','Integer','Scheduled',NULL,NULL,NULL,NULL,NULL,'Scheduled',NULL,0,60,35,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DF8165E1-19DB-44FF-A24B-8EB0A8932426','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','Sent','Integer','Sent',NULL,NULL,NULL,NULL,NULL,'Sent',NULL,0,60,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A74C0BA7-1CA4-4B79-A1E9-3E87FE74DC99','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','Channel','Select','Channel',NULL,NULL,NULL,NULL,NULL,'Channel',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('73E9AF51-424D-4507-A2B7-EEE1E57803CC','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','InDevice','Text','InDevice',NULL,NULL,NULL,NULL,NULL,'InDevice',NULL,0,400,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('43604DBA-E5FB-4CD7-A7A1-A43AB09AD9D8','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','OutDevice','Text','OutDevice',NULL,NULL,NULL,NULL,NULL,'OutDevice',NULL,0,400,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('24360787-4B01-48C8-A7AC-E5947827EAD4','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','isOK','Color','isOK',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,80,NULL,0,NULL,'success',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','4EFF4B79-581E-41DF-A62A-CEAEE89AD0F5','Ex Comm','Select','ExKom',NULL,NULL,NULL,NULL,NULL,'ExKom',NULL,0,80,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4817EE9F-DBBF-4332-B015-4B1AB92A2321','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','InboundCallId','Text','InboundCallId',NULL,NULL,NULL,NULL,NULL,'InboundCallId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('07509561-441B-4D36-835C-7473B9CFC7CD','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','TimeLocal','DateTimeFromTo','TimeLocal','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeLocal',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('5249D206-6B45-46EE-A01C-CBBC2EB57B1E','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','EventType','Text','EventType',NULL,NULL,NULL,NULL,NULL,'EventType',NULL,0,50,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E23237A4-6EF9-4AA3-9C1D-4332677ACB6A','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','EventName','Text','EventName',NULL,NULL,NULL,NULL,NULL,'EventName',NULL,0,100,22,NULL,0,NULL,NULL,100,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D13F181C-861D-4CD4-AEDD-2467A89EC32A','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','CallerNumber','Text','CallerNumber',NULL,NULL,NULL,NULL,NULL,'CallerNumber',NULL,0,70,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('69E1180C-E037-493A-B2FF-95535BDE275C','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','Rank','Integer','Navesti',NULL,NULL,NULL,NULL,NULL,'Navesti',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F0AB7742-EA50-4ECF-A4D5-573345F1CA98','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','Action','Text','Akce',NULL,NULL,NULL,NULL,NULL,'Akce',NULL,0,80,40,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9363FC11-FF2C-4269-9DE2-7CFAD31E2F3C','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,80,41,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F352E3DC-C8AD-4305-A9C9-85D077B375F9','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','WorkPlaceName','Text','WorkPlaceName',NULL,NULL,NULL,NULL,NULL,'WorkPlaceName',NULL,0,80,42,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A31F8245-6B63-4773-9855-444C98F4A89A','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','ProjectName','Text','ProjectName',NULL,NULL,NULL,NULL,NULL,'ProjectName',NULL,0,120,44,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E0B2D348-6F57-4DB7-95C9-9CD470A21EC6','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','IvrScript','Text','IvrSkript',NULL,NULL,NULL,NULL,NULL,'IvrSkript',NULL,0,140,45,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D5746C6D-B129-49C6-BDE5-8DA65730F469','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','IvrStep','Text','Ivrkrok',NULL,NULL,NULL,NULL,NULL,'Ivrkrok',NULL,0,80,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('39A8521B-3E6F-44F1-9AB3-91FFCF147918','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','FileName','Text','Hlaska',NULL,NULL,NULL,NULL,NULL,'Hlaska',NULL,0,160,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7BE00FFB-7DB0-4A9D-9FAD-6A9A5762DD54','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','ReferenceData','Text','ReferenceData',NULL,NULL,NULL,NULL,NULL,'ReferenceData',NULL,0,80,80,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E07D81AA-379B-4F39-B400-0A94D4D1C596','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','Duration','Duration','Duration',NULL,NULL,NULL,NULL,NULL,'Duration',NULL,0,60,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AF8B79AA-3224-44B6-9C96-2F548E53F635','F9572E3D-F96E-48B1-9CC6-CFBA6E797CE5','ResultData','Text','ResultData',NULL,NULL,NULL,NULL,NULL,'ResultData',NULL,0,200,100,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B694E2AA-A3B0-4225-ACA3-6419F202446B','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','OutboundCallId','Text','OutboundCallId',NULL,NULL,NULL,NULL,NULL,'OutboundCallId',NULL,0,230,5,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DC71656B-AF69-4D61-8DC6-C2EDA22B4ACD','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','ScheduleTime','DateTimeFromTo','ScheduleTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'ScheduleTime',NULL,0,100,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A7462E7C-027E-4506-8ACE-33856D869772','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','SchedTimeOK','Select','SchedTimeOK',NULL,NULL,NULL,NULL,NULL,'SchedTimeOK',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('F5B33898-9BEA-4ADE-815D-E963884D2D72','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','CallType','Text','CallType',NULL,NULL,NULL,NULL,NULL,'CallType',NULL,0,80,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('C544FF14-0CBB-44BF-A0A0-1189BBECD919','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','CallTypeOK','Select','CallTypeOK',NULL,NULL,NULL,NULL,NULL,'CallTypeOK',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4EF968DD-4C55-4757-A236-DC7903A18E1E','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','CallResult','Text','CallResult',NULL,NULL,NULL,NULL,NULL,'CallResult',NULL,0,80,50,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EB05FC57-2586-4B28-B62E-00748675FC5B','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','CallResultOK','Select','CallResultOK',NULL,NULL,NULL,NULL,NULL,'CallResultOK',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DBBCCDE5-CEEE-4AF4-992C-5E68F1AE84E4','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','CallPhase','Text','CallPhase',NULL,NULL,NULL,NULL,NULL,'CallPhase',NULL,0,80,70,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('A51A6462-BCCA-499A-BCCF-26784170D3EF','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','CallPhaseOK','Select','CallPhaseOK',NULL,NULL,NULL,NULL,NULL,'CallPhaseOK',NULL,0,80,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('2C4BF782-A55B-4E08-AB55-E8ABFC9A3A7C','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','OLIActive','Integer','OLIActive',NULL,NULL,NULL,NULL,NULL,'OLIActive',NULL,0,50,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('EFECA87F-8414-4AB2-94C2-FCF2A38EAE43','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','OLIActiveOK','Select','OLIActiveOK',NULL,NULL,NULL,NULL,NULL,'OLIActiveOK',NULL,0,80,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('7CDB041E-424A-40A0-90A3-95784117C9E4','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','OLActivity','Text','OLActivity',NULL,NULL,NULL,NULL,NULL,'OLActivity',NULL,0,80,110,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('574B259C-90E0-49FC-981D-4C10AD2BF77E','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','OLActivityOK','Select','OLActivityOK',NULL,NULL,NULL,NULL,NULL,'OLActivityOK',NULL,0,80,120,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('4714B4CC-08A0-436A-8DA2-81EF139E8CBD','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','PreDictiveCall','Select','PreDictiveCall',NULL,NULL,NULL,NULL,NULL,'PreDictiveCall',NULL,0,60,125,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('691B5FF6-62FC-4DCD-8B1B-808C5381E87F','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','PreDisDictOK','Select','PreDisDictOK',NULL,NULL,NULL,NULL,NULL,'PreDisDictOK',NULL,0,80,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('92638C8A-BF02-42A5-BFB6-9B11CCDFA505','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','Predistributed','Color','Predistributed',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,140,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B3536141-B33C-4ABA-83DE-5EF46A8174CA','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','PreDisAgentOK','Select','PreDisAgentOK',NULL,NULL,NULL,NULL,NULL,'PreDisAgentOK',NULL,0,80,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('81422408-2097-4DCB-A551-7CA8F619C1EC','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','AgentName','Text','AgentName',NULL,NULL,NULL,NULL,NULL,'AgentName',NULL,0,80,152,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B60C603B-F518-4B4C-8383-8CFDAC5564E0','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','Activity','Text','Activity',NULL,NULL,NULL,NULL,NULL,'Activity',NULL,0,80,154,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B5B0FC29-A418-4D3F-ADBA-0C2630E67AFB','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','FollowingOK','Select','FollowingOK',NULL,NULL,NULL,NULL,NULL,'FollowingOK',NULL,0,80,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('E01824F1-2FF5-4254-B9F4-1EBDEF1E4C78','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','RankBatch','Integer','RankBatch',NULL,NULL,NULL,NULL,NULL,'RankBatch',NULL,0,60,170,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('8DCBA588-0A5C-4ECF-8DEF-75FA82D73280','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','Rank','Integer','Rank',NULL,NULL,NULL,NULL,NULL,'Rank',NULL,0,60,180,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('05698CEB-7F19-48B8-BC80-6594779BE422','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','RankBarrier','Integer','RankBarrier',NULL,NULL,NULL,NULL,NULL,'RankBarrier',NULL,0,60,190,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('45F11B11-856D-4FAA-870E-4981ABEBFE9B','8B5D27D3-FFA0-46BC-93D9-D47396BB0241','UnderBarrier','Select','UnderBarrier',NULL,NULL,NULL,NULL,NULL,'UnderBarrier',NULL,0,80,200,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D26DFAE8-30E8-4A25-948A-DDE55799D83C','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','OutBoundCallId','Text','OutBoundCallId',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,230,3,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D4CA681A-FC48-4E6E-9AAC-B3D93168413C','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','Paired','Select','Sparovano',NULL,NULL,NULL,NULL,NULL,'Sparovano',NULL,0,60,4,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D39A425B-59ED-43C0-B424-81650F43FA4B','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','DistributionTime','DateTimeFromTo','DistributionTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'DistributionTime',NULL,0,100,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('6BB5B346-4918-4098-B9F2-98B3605496CB','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','TimeUTC','DateTimeUtc','TimeUTC','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeUTC','TimeUTC',0,100,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('55CB9ABA-B6B0-4553-9A00-7F89D3013867','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','CallResult','Image','CallResult',NULL,'OutboundCallId','~/RC/Pages/calleditor.html?Id={0}',NULL,'LiteralValue','CallResult',NULL,0,25,10,NULL,0,NULL,NULL,NULL,42,'CallResult',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('2725E7BD-C0F7-495E-A463-56FCC31EF0C6','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','CallerNumber','HyperLink','CallerNumber',NULL,'OutboundCallId',' /RC/Pages/calleditor.html?Id={0}',NULL,NULL,'CallerNumber',NULL,0,80,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('DF1B2AB8-1059-4E49-B026-B6AD63F31EFB','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','CallPhase','Image','CallPhase',NULL,NULL,NULL,NULL,'LiteralValue','CallPhase',NULL,0,25,21,NULL,0,NULL,NULL,NULL,43,'CallPhase',NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('58687628-DA4A-4FFD-8255-1EE7808C4A5C','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','OutboundListName','Text','OutboundListName',NULL,NULL,NULL,NULL,NULL,'OutboundListName',NULL,0,60,31,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B2F806C6-49EF-4A2F-9407-1095894544E0','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','ProjectName','ForeignKey','ProjectName',NULL,NULL,NULL,'ProjectId','ProjectName','ProjectName',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('13FE1738-F42C-4887-A0BC-2B03F0D49A7B','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','LanguageName','ForeignKey','LanguageName',NULL,NULL,NULL,'LanguageId','LanguageName','LanguageName',NULL,0,35,41,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B0105C57-5B63-457E-96A5-4C5E43D2DB7B','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','AgentName','ForeignKey','AgentName',NULL,NULL,NULL,'AgentId','AgentName','AgentName',NULL,0,120,140,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('ED034D53-981B-4CD4-A8C0-DE79962689CB','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','WorkplaceName','ForeignKey','WorkplaceName',NULL,NULL,NULL,'WorkplaceId','WorkplaceName','WorkplaceName',NULL,0,90,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('82C04318-09DC-40F4-B987-48CCA668CC4E','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','CallDuration','Duration','CallDuration',NULL,NULL,NULL,NULL,'DurationMSS','CallDuration',NULL,0,50,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('BD47CD32-3C8C-4FF2-8664-3391DC5FED4B','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','IsActive','Color','IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,199,'#CCFADF',0,NULL,'success',NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('B7BB7614-6907-4322-AB19-EA8FB4215D3F','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','RingDuration','Duration','RingDuration',NULL,NULL,NULL,NULL,NULL,'RingDuration',NULL,0,50,209,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('8EF31215-5BA1-4E28-A6A1-48CC8BA0461A','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','AnswerTime','DateTimeFromTo','CasUskutecneni','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'CasUskutecneni',NULL,0,100,219,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('9012210A-50E6-458B-8769-0BA895858C3E','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','endtime','DateTimeFromTo','endtime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'endtime',NULL,0,100,229,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('44D22198-F0F2-4B63-9176-341450B243E3','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','RegionalTime','DateTimeFromTo','RegionalTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'RegionalTime',NULL,0,100,239,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AD2C7908-8D84-4630-8257-D3365891B5A7','CE85CCB8-D497-40AB-A067-E1561D4D7AB6','ScheduleTime','DateTimeFromTo','ScheduleTime','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'ScheduleTime',NULL,0,100,259,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('AD77BB61-8E63-4D43-AAAF-034D8FE430A0','9FB476C8-1D02-4D17-820B-E5324FAFE087','TimeLocal','DateTimeFromTo','TimeLocal','{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,'TimeLocal',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('27A3C9EB-16B5-4993-AE7A-EC75C554A280','9FB476C8-1D02-4D17-820B-E5324FAFE087','Name','Text','Name',NULL,NULL,NULL,NULL,NULL,'Name',NULL,0,140,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D10B025F-AD94-4734-ACE3-CDEE55E80BC2','9FB476C8-1D02-4D17-820B-E5324FAFE087','DB','Select','DB',NULL,NULL,NULL,NULL,NULL,'DB',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D821F824-A054-44DA-AC61-1E9DACC0EEB4','9FB476C8-1D02-4D17-820B-E5324FAFE087','type_desc','Text','type_desc',NULL,NULL,NULL,NULL,NULL,'type_desc',NULL,0,150,60,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
INSERT INTO [DataqueryColumn] ([DataQueryColumnId],[DataQueryId],[DisplayName],[Model],[TargetColumn],[TargetFormat],[UrlColumn],[UrlFormat],[GuidColumn],[Convertor],[SortExpression],[SortExpressionDesc],[NoFilter],[Width],[Rank],[Color],[Deleted],[SqlCmd],[Css],[ToolTip],[LiteralGroup],[GlyphColumn],[GlyphFormat],[GdprSensitivity],[DisplayGlyph])VALUES('D9E4DED5-3E98-4124-B732-FDE188C7F405','9FB476C8-1D02-4D17-820B-E5324FAFE087','Definition','Text','Definition',NULL,NULL,NULL,NULL,NULL,'Definition',NULL,0,400,90,NULL,0,NULL,NULL,500,NULL,NULL,NULL,NULL,NULL)
	END
	GO

	-- Náprava odkazu na SubQuery:
IF object_id('FSC_Repair_Target') IS NOT NULL
  EXEC FSC_Repair_Target 'B23D6374-9D41-40E3-B3D8-FEBE9742D243','DataQueryPage'
/*  UPDATE TOP (1) DataQueryColumn 
SET UrlFormat=REPLACE(UrlFormat,'/RC','')
WHERE DataqueryColumnId='B23D6374-9D41-40E3-B3D8-FEBE9742D243'*/

-- Náprava událostí agenta:
 UPDATE Dataquery
SET  [QueryText]=
'SELECT DTA.Timeutc, DTA.Kind, A.DisplayName as AgentName, W.DisplayName as WorkplaceName, DTA.Duration, DTA.EventAgent, S.DisplayName as StatusName,  DTA.EventCall,  CASE WHEN DTA.InboundCallId IS NOT NULL THEN ''I-''+ll.DisplayName  WHEN DTA.OutboundCallId IS NOT NULL THEN ''O-''+Phase.DisplayName  ELSE NULL  END AS CallResultX, CASE WHEN DTA.InboundCallId IS NOT NULL THEN ''I-''+ll2.DisplayName  WHEN DTA.OutboundCallId IS NOT NULL THEN ''O-''+Result.DisplayName  ELSE NULL  END AS CallPhaseX, ISNULL(IC.CallerNumber,OC.CallerNumber) AS CallerNumber, P.DisplayName AS ProjectName, DTA.Detail, DTA.AgentId, DTA.WorkplaceId, ISNULL(DTA.InboundCallId, DTA.OutboundCallId) AS CallId FROM  (   SELECT TimeUtc, ''Agent'' as Kind, EventType AS EventAgent, NULL as EventCall, AgentId, WorkplaceId,     dbo.ConcatName(NULL,Actor,ReferenceData) AS Detail, ReferenceId, NULL AS InboundCallId, NULL as OutboundCallId, Duration, ProjectId   FROM AgentEvent WITH(NOLOCK) WHERE TimeUtc>=DATEADD(day,-7,@NowUtc)    UNION    SELECT TimeUtc, ''Hovor'' as Kind, NULL AS EventAgent, EventType AS EventCall, AgentId, WorkplaceId,      NULL as Detail, NULL AS ReferenceId, InboundCallId, OutboundCallId, NULL AS Duration, ProjectId   FROM CallEvent WITH(NOLOCK) WHERE AgentId IS NOT NULL AND TimeUtc>=DATEADD(day,-7,@NowUtc)   ) AS DTA LEFT JOIN Agent AS A ON DTA.AgentId=A.AgentId LEFT JOIN Workplace AS W ON DTA.WorkplaceId=W.WorkplaceId LEFT JOIN Status AS S ON DTA.ReferenceId=S.StatusId LEFT JOIN InboundCall AS IC ON DTA.InboundCallId=IC.InboundCallId AND IC.TimeUtc>=DATEADD(day,-7,@NowUtc) and ic.AgentId IS NOT NULL left join LiteralLookup ll2 with (nolock) on ll2.LiteralValue = ic.CallPhase and ll2.Culture = ''cs-CZ'' and ll2.LiteralGroup = 41 left join LiteralLookup ll with (nolock) on ll.LiteralValue = ic.CallResult and ll.Culture = ''cs-CZ'' and ll.LiteralGroup = 40 LEFT JOIN OutboundCall AS OC ON DTA.OutboundCallId=OC.OutboundCallId AND OC.TimeUtc>=DATEADD(day,-7,@NowUtc) and oc.AgentId IS NOT NULL left join LiteralLookup Result with (nolock) on Result.LiteralValue = oc.CallResult and Result.Culture = ''en-US'' and Result.LiteralGroup = 42 left join LiteralLookup Phase with (nolock) on Phase.LiteralValue = oc.CallPhase and Phase.Culture = ''en-US'' and Phase.LiteralGroup = 43 LEFT JOIN Project AS P ON DTA.ProjectId=P.ProjectId'
,QuerySortExpression = REPLACE(QuerySortExpression,'TimeLocal','TimeUTC')
WHERE DataQueryId='73342443-45F0-4C26-AA6C-37335ADB34A4' AND QueryText LIKE '%TimeLocal%'
-- Náprava sloupce čas událostí agenta:
  UPDATE DataqueryColumn
SET  Model='DateTimeUtc', TargetColumn='TimeUtc',SortExpression='TimeUtc'
WHERE DataQueryColumnId IN ('549CC136-0C5A-4448-A0C2-F0C12D22631E') AND  Model<>'DateTimeUtc'
  UPDATE DataqueryColumn
SET  Model='DateTimeUtc'
WHERE DataQueryColumnId IN ('641A9107-6E93-4F37-A7DD-914646D77A79') AND  Model<>'DateTimeUtc'

-- 27.11.2024 Náprava URLFormat:
IF NOT EXISTS(SELECT TOP 1 1
FROM [DataQueryColumn] DQC
  LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
  WHERE DQ.QueryGroup<>'ServiceAPP' AND DQ.Deleted=0
  AND URLFormat IS NOT NULL
  AND URLFormat LIKE '%/RC%'
)
   UPDATE DQC
SET URLFormat = IIF(URLFormat LIKE '~','','~')+LTRIM(REPLACE(URLFormat,'/RC',''))
FROM [DataQueryColumn] DQC
  LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
  WHERE DQ.QueryGroup='ServiceAPP' AND DQ.Deleted=0
  AND URLFormat IS NOT NULL
  AND URLFormat LIKE '%/RC%'
  AND UrlColumn IN ('MessageId','InboundCallId','OutboundCallId')  

  -- 27.11.2024 Náprava HasAttachment:
     UPDATE DQC
SET GlyphColumn = 'HasAttachment', TargetFormat = NULL
FROM [DataQueryColumn] DQC
  LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
  WHERE DQ.QueryGroup='ServiceAPP' AND DQ.Deleted=0
  AND Model = 'Image' 
  AND TargetColumn  = 'HasAttachment' 
  AND TargetFormat IS NOT NULL

  -- 27.11.2024 Náprava MessageType:
     UPDATE DQC
SET GlyphColumn = 'MessageType', TargetFormat = NULL, Convertor = 'LiteralValue', LiteralGroup = 50
FROM [DataQueryColumn] DQC
  LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
  WHERE DQ.QueryGroup='ServiceAPP' AND DQ.Deleted=0
  AND Model = 'Image' 
  AND TargetColumn  = 'MessageType' 
  AND GlyphColumn IS NULL



IF object_id('FSC_CustomProc') IS NULL
 BEGIN
  DECLARE @CreateCustom AS NVARCHAR(500)=
 ' 
 CREATE PROCEDURE [dbo].[FSC_CustomProc](@TestVer AS NVARCHAR(2), @Last as DateTime)
	 AS
	  BEGIN
	    DECLARE @Nothing AS Integer=0
	  END'
    EXEC (@CreateCustom)
  END
GO

IF NOT EXISTS(
SELECT * FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_NAME='FSC_Eventlog')
   BEGIN
CREATE TABLE [dbo].[FSC_Eventlog](
	[DatumCas] [datetime] NOT NULL,
	[Procedura] [nchar](20) NULL,
	[Popis] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
CREATE NONCLUSTERED INDEX [CX_DatumCas] ON [dbo].[FSC_Eventlog]
(
	[DatumCas] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

 END
GO


IF object_id('FSC_WriteEvent') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_WriteEvent]
GO

CREATE PROCEDURE [dbo].[FSC_WriteEvent] (@Loguj AS bit, @ProcName AS nchar(20), @popis as nvarchar(MAX) )
AS
BEGIN
  IF @Loguj=1
	--DECLARE @MessageId AS UniqueIdentifier='A3899D5B-CF36-E611-80F1-F8BC1253A1A4'
	insert into .[dbo].[FSC_Eventlog] (DatumCas, Procedura, Popis) values(GETUTCDATE(), @ProcName, @popis)
  --END
END


GO


IF object_id('FSC_CustMaintenance') IS NULL
 BEGIN
  DECLARE @CreateCustom AS NVARCHAR(500)=
 ' 
 CREATE PROCEDURE [dbo].[FSC_CustMaintenance]
	 AS
	  BEGIN
	    DECLARE @Nothing AS Integer=0
	  END'
    EXEC (@CreateCustom)
  END
GO

IF object_id('FSC_DoplnVelikonoce') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_DoplnVelikonoce]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <28.04.2021>
-- Description:	<Doplnění velikonočních svátků>
-- =============================================
CREATE PROCEDURE [dbo].[FSC_DoplnVelikonoce]
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
		  IF NOT EXISTS(SELECT * FROM Holiday WHERE TimeFrom=@Datum AND HolidayGroupName=@Holiday)
		   INSERT INTO  [Holiday]
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


IF object_id('FSC_WriteParam') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_WriteParam
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17.05.2017>
-- Description:	<Zápis parametru do Configuration>
-- Test 6.5.2020
-- =============================================
create PROCEDURE [dbo].[FSC_WriteParam]
 @ConfigurationName AS NVARCHAR(50),
 @ConfigurationValue AS NVARCHAR(MAX),
 @Description AS NVARCHAR(800)
AS
BEGIN
--DECLARE @MyAgentId AS UniqueIdentifier = 'ffee47c8-da99-47d3-b4e2-ca92b624ac95' -- Admin ID
    IF NOT EXISTS (SELECT ConfigurationId FROM [CONFIGURATION]  WHERE ConfigurationName=@ConfigurationName)
	  BEGIN
	    INSERT INTO [Configuration]
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
        update  [Configuration] 
         SET ConfigurationValue = @ConfigurationValue
         WHERE  ConfigurationName=@ConfigurationName
      END
END


GO

IF object_id('FSC_GiveParam') IS NOT NULL
 DROP  Function  [dbo].[FSC_GiveParam]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17.5.2017>
-- Description:	<vrací hodnotu požadovaného parametru>
-- =============================================
CREATE FUNCTION [dbo].[FSC_GiveParam]
(
	-- Add the parameters for the function here
	@ConfigurationName AS NVARCHAR(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN (SELECT ConfigurationValue FROM .[dbo].[CONFIGURATION]  WHERE ConfigurationName=@ConfigurationName)
END
GO


IF object_id('FSC_GiveParam2') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_GiveParam2]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <22.4.2020>
-- Description:	<vrací hodnotu požadovaného parametru>
-- =============================================
CREATE PROCEDURE [dbo].[FSC_GiveParam2]
(
	-- Add the parameters for the function here
	@ConfigurationName AS NVARCHAR(50)
   ,@ConfigurationValue AS NVARCHAR(MAX) OUTPUT  
   ,@Description AS NVARCHAR(800)

)

AS
BEGIN
  DECLARE @ConfigurationValue2 AS NVARCHAR(MAX) = (SELECT ConfigurationValue FROM [CONFIGURATION]  WHERE ConfigurationName=@ConfigurationName)
  IF @ConfigurationValue2 IS NULL
  	  EXEC [dbo].[FSC_WriteParam] @ConfigurationName,@ConfigurationValue, @Description
  ELSE
  	  SET @ConfigurationValue=@ConfigurationValue2
	RETURN 
END


GO


IF object_id('FSC_IVRStepCopy') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_IVRStepCopy]
GO

CREATE PROCEDURE [dbo].[FSC_IVRStepCopy]
@IVRStepId UniqueIdentifier
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 20.12.2019
-- Description:	Kopíruje vybraný IVR step do vybraného IVR Scriptu
-- =============================================
--USE [iCC]
BEGIN
    declare @IVRScriptId as nvarchar(40) =.dbo.FSC_GiveParam('SELECTED_IVR')

 INSERT INTO IVRstep
           ([IvrStepId]
           ,[IvrScriptId]
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
           ,[Deleted]
           ,[TargetOnTimeOut]
           ,[TargetOnSuccess]
           ,[TargetOnFailure]
           ,[Culture])

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
      ,0 AS [Deleted]
      ,[TargetOnTimeOut]
      ,[TargetOnSuccess]
      ,[TargetOnFailure]
	     ,[Culture]
  
  FROM [IvrStep] WITH(NOLOCK) WHERE IvrStepId=@IVRStepId
 
 END 
GO



IF object_id('FSC_Daily_Maintenance') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_Daily_Maintenance]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <12.12.2019>
-- Description:	<Denní údržba nastavení Frontstage>
-- =============================================
-- ALTER
create PROCEDURE [dbo].[FSC_Daily_Maintenance]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Vypnuto AS NVARCHAR(5)='false'
	DECLARE @DoplnVelikonoce AS NVARCHAR(5) = @Vypnuto
	EXEC dbo.FSC_GiveParam2 'DoplnVelikonoce', @DoplnVelikonoce OUTPUT,'Automatic replenishment of Easter holidays'
	DECLARE @DoplnMimoPrac AS NVARCHAR(5) = @Vypnuto
	EXEC dbo.FSC_GiveParam2 'DoplnMimoPrac',@DoplnMimoPrac OUTPUT,'Supplementing the indication of non-working hours'
    DECLARE @PracDobaChatu  AS NVARCHAR(5) = @Vypnuto
	EXEC dbo.FSC_GiveParam2 'PracDobaChatu',@PracDobaChatu OUTPUT,'Making adjustments to the working hours of chats'
	DECLARE @DoplnproServer  AS NVARCHAR(5) = @Vypnuto
	EXEC dbo.FSC_GiveParam2 'DoplnproServer',@DoplnproServer OUTPUT,'Adding ProServer settings (Toaster)'
    DECLARE @ImportListAge AS NVARCHAR(5) = '4'
	EXEC dbo.FSC_GiveParam2 'ImportListAge', @ImportListAge OUTPUT,'Maximal age of Import Lists in Months'
    DECLARE @ImportListAgeN AS Integer = IIF(ISNUMERIC(@ImportListAge)=1,CONVERT(Integer,@ImportListAge),4)

	DECLARE @Zprava NVARCHAR(200)= 'Entry point'
   EXEC  [FSC_WriteEvent] 1,'Daily_Maint',@Zprava

   EXEC  [FSC_CustomProc] 'XX',NULL

-- Doplnění velikonoc:
   declare @Holiday as nvarchar(40) =dbo.FSC_GiveParam('Holiday')
   EXEC dbo.FSC_DoplnVelikonoce @DoplnVelikonoce,@Holiday
-- Údržba pracovní doby Chatů
IF @PracDobaChatu='true' AND EXISTS(SELECT * FROM  ChatGateCondition WHERE Signal=2) AND OBJECT_ID(N'..HolidayPlan', N'U') IS NOT NULL
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
    DECLARE Hol_cursor CURSOR FOR SELECT  *  FROM dbo.FSC_HolidayPlan WHERE HolidayGroupName=@Holiday
	DECLARE Hol_cursor2 CURSOR FOR  SELECT  HP.HolidayGroupName,HP.RelId  FROM dbo.FSC_HolidayPlan HP
              LEFT JOIN dbo.FSC_HolidayPlan HP2 ON HP.RelId=HP2.RelId AND HP2.HolidayGroupName=@Holiday
              LEFT JOIN Holiday HO ON HP2.HolidayGroupName COLLATE DATABASE_DEFAULT  =HO.HolidayGroupName COLLATE DATABASE_DEFAULT  AND TimeMode='DayInYear' 
	             AND DATEPART(Month,@today)=DATEPART(Month,TimeFrom) AND DATEPART(Day,@today)=DATEPART(Day,TimeFrom)
				  WHERE HP.HolidayGroupName<>@Holiday AND HO.HolidayId IS NULL

    OPEN Hol_cursor 
	OPEN Hol_cursor2

  FETCH NEXT FROM Hol_cursor INTO @HolidayGroupName, @RelId   
  WHILE @@FETCH_STATUS = 0  
   BEGIN
    SET @CharDateFrom  = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeFrom FROM  ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @CharDateTo = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeTo FROM  ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	-- Zkontroluji, zda dnes není svátek:
	SELECT TOP 1 @ChatFrom=TimeFrom,@ChatTo=TimeTo FROM  Holiday WHERE [HolidayGroupName]=@Holiday AND TimeMode='DayInYear' 
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
		UPDATE  ChatGateCondition
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
    SET @CharDateFrom  = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeFrom FROM  ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @CharDateTo   = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeTo FROM  ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @PerformChange  = 0
	-- v Holiday najdu pracovní dobu dnešního dne
		SELECT @ChatFrom=TimeFrom,@ChatTo=TimeTo FROM  Holiday WHERE [HolidayGroupName]=@HolidayGroupName AND @today>=CONVERT(Date,TimeFrom) AND @today<=CONVERT(Date,TimeTo)
		IF @ChatFrom IS NOT NULL
		  BEGIN	   
		   -- Teď musím do @Start a @End dosadit datumy z ChatGateCondition
		   SET @ChatFrom = CONVERT(DateTime,@CharDateFrom+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatFrom,126),12,8))
		   SET @ChatTo   = CONVERT(DateTime,@CharDateTo+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatTo,126),12,8))
			UPDATE  ChatGateCondition
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
	  DECLARE @from1 AS datetime=DATEADD(Month,-@ImportListAgeN+1,GETDATE())
	  DECLARE @from2 AS datetime=DATEADD(Month,-@ImportListAgeN,GETDATE())
	  DECLARE @from3 AS datetime=DATEADD(DAY,-7,GETutcDATE())
	    -- Nastavím importy jako neaktivní
		UPDATE  [OutboundListImport]
		  SET  Active=0 
		WHERE Deleted=0
		AND Active=1
		AND TimeUTC<@from1
		AND  dbo.[FSC_isOutboundImpComplete](OutboundListImportId)=1
	    -- Zruším  neaktivní importy
		UPDATE   [OutboundListImport]
			SET Deleted=1
		   WHERE Deleted=0
			AND Active=0
			AND TimeUTC<@from2
            AND  dbo.[FSC_isOutboundImpComplete](OutboundListImportId)=1
       ---------------------------------- Smazání starých Change Requestů:
	   DELETE FROM  [ChangeRequest]
       WHERE Done=1 AND ChangeRequestTimeUtc < @From1
	   delete from  ChangeRequest 
	   where Command not in ('BulkMessageImport','CampaignImport','OutboundListImport','OutboundListExport','DataQueryExport',
	     'ExportEventsAsCsv') and ChangeRequestTimeUtc < @from3 and Done = 1


	END

--IF @DoplnproServer='true'
--   BEGIN
--	   EXEC PridejPravaPoslechu
--	   EXEC ProServerSync_Toaster
--   END

------------------------------------------------------------------------------------------------------
 IF @DoplnMimoPrac='true'
   BEGIN


-- Údržba značek MimoPracovní doby:

 DECLARE @from AS datetime=DATEADD(Day,-6,GETDATE()) -- Jak daleko do minulosti se dívat
 DECLARE @PilotTime AS datetime
 DECLARE @InboundcallId AS UniqueIdentifier = '00000000-0000-0000-0000-000000000000'
 DECLARE My_cursor CURSOR FOR   
 SELECT /*TOP 10*/ PilotTime,IC.InboundCallId  FROM InboundCall IC WITH (NOLOCK)
   LEFT JOIN  callevent ce WITH (NOLOCK) ON IC.InboundCallId=CE.InboundCallId AND CE.referencedata = 'NopOK' and CE.ResultData = 'MIMOPRAC'
   --LEFT JOIN dbo.callevent ce2 WITH (NOLOCK) ON IC.InboundCallId=CE2.InboundCallId AND CE2.referencedata = 'NopOK' and CE2.ResultData = 'WHITELIST'
   WHERE PilotTime>@from AND dbo.FSC_IsWorkTime(PilotTime,'PracDoba')=0.
   AND CE.InboundCallId IS NULL --AND CE2.InboundCallId IS NULL
   OPEN my_cursor 

  FETCH NEXT FROM My_cursor INTO @PilotTime, @InboundcallId    
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @InboundcallId  IS NOT NULL
		BEGIN
		  -- Zapiš do dbo.callevent chybějící záznam
          INSERT INTO  [CallEvent]
           ( [TimeUTC]
              ,[EventType]
           ,[InboundCallId]
           ,[ReferenceData]
           ,[ResultData]
           )
          VALUES
           (GETUTCDATE()
           ,4
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
       EXEC  [FSC_WriteEvent] 1,'Daily_Maint',@Zprava

END


GO



IF object_id('FSC_Runscript') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_Runscript
GO

CREATE PROCEDURE [dbo].[FSC_Runscript]
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
DECLARE @Command AS nvarchar(150) = (SELECT Command FROM .[dbo].[FSC_Commands] WHERE CommandiD=@RecId) --+' '+''''+CONVERT(NVARCHAR(36),@MEAgentId)+''''
EXEC (@Command) 
END

GO


IF object_id('FSC_DiskSpace') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_DiskSpace
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <21.2.2023>
-- Description:	<Kontrola místa na disku>
-- =============================================
CREATE FUNCTION [dbo].[FSC_DiskSpace]
(
@LimGB Integer
)
RETURNS nvarchar(200)
AS
BEGIN

	-- Kontrola místa na discích:
	DECLARE @DiskName AS NVARCHAR(10),@MyPercent AS Integer,@GB AS Integer
	SELECT TOP 1 @DiskName=volume_mount_point
	  ,@MyPercent=(available_bytes/1048576* 1.0)/(total_bytes/1048576* 1.0)*100
      ,@GB=available_bytes/1048576000 
	 FROM sys.master_files AS f 
	  CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
        WHERE ( (available_bytes/1048576* 1.0)/(total_bytes/1048576* 1.0) *100)<20 AND available_bytes/1048576000<@LimGB

   IF  @DiskName IS NOT NULL
	 BEGIN
  	    RETURN 'DB Server: On disk '+@DiskName+' is '+CONVERT(NVARCHAR(3),@MyPercent)+
	     '% of free place ('+CONVERT(NVARCHAR(6),@GB)+'GB)'
     END

RETURN ''

END
GO


IF object_id('FSC_ReleaseWorkplace') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_ReleaseWorkplace]
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2024-03-15
-- Description:	Uvolnění zaseklého pracoviště
-- =============================================
CREATE PROCEDURE [dbo].[FSC_ReleaseWorkplace](@Workplace AS VARCHAR(24))

AS
BEGIN
--DECLARE @Workplace AS VARCHAR(24) = '9778'
DECLARE @RepeatCount AS Integer=3

DECLARE @WPState AS NVARCHAR(20)
DECLARE @WorkplaceId AS UniqueIdentifier 

SELECT TOP 1 @WorkplaceId=WorkplaceId,@WPState=State FROM .dbo.Workplace WHERE Number = @Workplace AND Deleted=0


--SELECT @WorkplaceId

-- Načtení od obsluhy
--accept l_dept number format '99' prompt 'Department #: '
IF @WorkplaceId IS NULL
  BEGIN
    SELECT 'Workplace '+@Workplace+' does not exist' AS Report
    RETURN
  END

IF @WPState='Free'
 SELECT 'Workplace has status= '+@WPState AS Report

WHILE @WPState<>'Free' AND @RepeatCount>0
  BEGIN

    SET @RepeatCount=@RepeatCount-1
	SELECT 'I am repairing Workplace '+@Workplace+' - I am waiting 50 seconds' AS Report
	--PRINT 'Provádím nápravu pracoviště '+@Workplace+' - čekám 30sekund.'
	WAITFOR DELAY '00:00:01'
	RAISERROR('',10,1) WITH NOWAIT

	--BEGIN Transaction
	UPDATE .[dbo].[Workplace] SET Deleted=1 WHERE WorkplaceId=@WorkplaceId
	--COMMIT TRANSACTION

	WAITFOR DELAY '00:00:50'
	--BEGIN Transaction
	UPDATE .[dbo].[Workplace] SET Deleted=0 WHERE WorkplaceId=@WorkplaceId
	--COMMIT TRANSACTION
	SELECT 'I am waiting 30 seconds for ServiceSync' AS Report
	WAITFOR DELAY '00:00:30'
	SET @WPState =(SELECT State FROM .dbo.Workplace WHERE WorkplaceId=@WorkplaceId)
	IF @WPState<>'Free' UPDATE .[dbo].[Agent] SET WorkplaceId=NULL WHERE WorkplaceId =  @WorkplaceId

	SELECT 'Workplace has status= '+@WPState AS Report

  END
 END
GO


IF object_id('FSC_CustomCheck2') IS NULL
 BEGIN
  DECLARE @CreateCustom AS NVARCHAR(500)=
 ' 
 CREATE FUNCTION [dbo].[FSC_CustomCheck2](@TestVer AS NVARCHAR(2), @String as NVARCHAR(20))
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


IF object_id('FSC_CustomCheckint') IS NULL
 BEGIN
  DECLARE @CreateCustom AS NVARCHAR(500)=
 ' 
 CREATE FUNCTION [dbo].[FSC_CustomCheckint](@TestVer AS NVARCHAR(2), @MyLimit as Integer)
   RETURNS int
	 AS
	  BEGIN
		 RETURN 1
	  END'
    EXEC (@CreateCustom)
  END
GO


IF object_id('FSC_RecordingLessCallsS') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_RecordingLessCallsS
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <28.7.2021>
-- Description:	<Kontrola nespárovaných hovorů>
-- =============================================
CREATE FUNCTION [dbo].[FSC_RecordingLessCallsS]
(
@RecordingsLess AS Integer 
,@LastMessageTime AS Datetime

)
RETURNS Integer
AS
BEGIN
   DECLARE @PairingTime AS Integer=dbo.FSC_GiveParam('PairingTime')
   DECLARE @from AS datetime=ISNULL(@LastMessageTime,DATEADD(Hour,-3,GETDATE()))
   DECLARE @to AS datetime=DATEADD(Minute,-@PairingTime,GETDATE())
   DECLARE @UTCDif AS Integer = (SELECT TOP 1 DATEDIFF(HOUR,PilotTime,TimeUTC) FROM .dbo.InboundCall WITH (NOLOCK) ORDER BY TIMEUTC DESC)
   DECLARE @fromUTC AS datetime=DATEADD(Hour,@UTCDif,@from)
   DECLARE @toUTC AS datetime=DATEADD(Hour,@UTCDif,@to)

	RETURN (SELECT TOP (@RecordingsLess+1)  COUNT(1)
  FROM .dbo.[InboundCall] IC WITH (INDEX(AX_InboundCall_TimeUtc))
    LEFT JOIN .[dbo].[CallRecord] CR ON CR.InboundCallId=IC.InboundCallId
	LEFT JOIN .[dbo].[Directory] DI ON RIGHT(DI.Number,3) COLLATE Czech_CI_AS =IC.Redirector COLLATE Czech_CI_AS
	LEFT JOIN .[dbo].[Workplace] WP WITH (NOLOCK) ON WP.WorkplaceId=IC.WorkplaceId
  WHERE TimeUTC>@FromUTC AND TimeUTC<@ToUTC
  AND CallDuration>1
  AND CR.INboundCallId IS NULL   
  AND CallResult =2--'served'
  AND LEN(CallerNumber)>6
  AND isnull(DI.Record,1) <> 0
  AND (dbo.FSC_CustomCheck2('IC',WP.DisplayName)=1 OR dbo.FSC_CustomCheck2('ID',IC.Redirector)=1
  OR dbo.FSC_CustomCheck2('IP',LEFT(IC.PilotId,20))=1)
  AND dbo.FSC_CustomCheckInt('DU',IC.CallDuration)=1 
)

END
GO



IF object_id('FSC_Recordings') IS NOT NULL
 DROP  FUNCTION  [dbo].[FSC_Recordings]
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	RecordinLess Calls
-- =============================================
CREATE FUNCTION [dbo].FSC_Recordings ()
RETURNS nvarchar(200)
AS
BEGIN
 DECLARE @RecordingsLess AS Integer=dbo.FSC_GiveParam('RecordingsLess')
 declare @LastRecording AS Datetime
 declare @LastinCall AS Datetime
 declare @Severity AS Integer
 declare @MyMess AS nvarchar(200)
 declare @LastMessageTime AS DateTime =(SELECT TOP 1 LastMessTime FROM  dbo.FSC_Monitor WHERE  DisplayName='Recordings inspection')
 declare @LimTime AS DateTime = DATEADD(Hour,-8,GETDATE())
 SET @LastMessageTime=IIF(@LimTime>@LastMessageTime,@LimTime,@LastMessageTime)
 DECLARE @RecordingsLessCurr AS Integer= dbo.FSC_RecordingLessCallsS(@RecordingsLess,@LastMessageTime)
 --DECLARE @PairingTime AS Integer=dbo.FSC_GiveParam('PairingTime')
IF (@RecordingsLessCurr > @RecordingsLess)
  BEGIN
	SET @LastRecording = (SELECT TOP 1  dbo.FSC_TimeUTC_Local(EndTimeUTC) FROM .[dbo].[VoiceRecord] ORDER BY StartTimeUtc DESC)
	SET @LastinCall = (SELECT TOP 1 EndTime FROM .dbo.[InboundCall] WHERE EndTime IS NOT NULL ORDER BY TimeUTC DESC)
	SET @MyMess = (SELECT 'Last recording: '+ CONVERT(NVARCHAR(20),@LastRecording,109) )+' > '+CONVERT(NVARCHAR(5),@RecordingsLess)
	--UPDATE .dbo.FSC_Monitor SET DetailMessage=@MyMess WHERE  DisplayName='Recordings inspection'
	SET @Severity = CASE WHEN DATEDIFF(Minute,@LastRecording,GETDATE())>5 AND @LastRecording<@LastinCall THEN 10 ELSE 0 END
	RETURN 'Recordingless Calls'+CASE WHEN @Severity>0 THEN ' !!!!! ' ELSE '' END+' = '+CONVERT(NVARCHAR(6),@RecordingsLessCurr)
  END
IF (@RecordingsLessCurr > 0)
  BEGIN
	RETURN 'RUNPROC' -- Zkus zjednat nápravu
  END
RETURN ''
END
 
GO

	
IF object_id('FSC_AutoTest') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_AutoTest
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-10-24
-- Description:	Autotest kontrolní funkce
-- =============================================
CREATE FUNCTION [dbo].FSC_AutoTest ()
RETURNS nvarchar(200)
AS
BEGIN
 DECLARE @TestDuration AS Int, @Displayname AS NVARCHAR(50)
 SELECT TOP 1
      @TestDuration=ExecDuration,@Displayname=Displayname
     FROM .dbo.FSC_Monitor
        WHERE ExecDuration > 10
   IF  (@Displayname IS NOT NULL)
		RETURN @Displayname+' has duration '+convert(NVARCHAR(3),@TestDuration)+' seconds'
RETURN ''
END

GO
	    

IF object_id('FSC_WPBlockedbyAdmin') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_WPBlockedbyAdmin
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Kontrola blokace agentského pracoviště Adminem
-- =============================================
CREATE FUNCTION [dbo].FSC_WPBlockedbyAdmin ()
RETURNS nvarchar(200)
AS
BEGIN
DECLARE @AgentId AS UniqueIdentifier=
 (SELECT TOP 1 AgentId FROM .[dbo].[Agent] where TeamName='ADMIN' AND WorkplaceId IS NOT NULL AND DATEDIFF(Hour,LastRefreshUtc,GETUTCDATE())>4)
  IF @AgentId IS NOT NULL
    BEGIN
      DECLARE @WorkplaceId AS UniqueIdentifier =(SELECT TOP 1 WorkPlaceId FROM .[dbo].[Agent] where AgentId=@AgentId)
      DECLARE @TimeUTC as Datetime = (SELECT TOP 1 TimeUTC FROM .[dbo].[AgentEvent] where EventType=0 /*'AgentStatus'*/ AND AgentId=@AgentId ORDER BY EventType,AgentId,TimeUTC DESC)
	  IF DATEDIFF(Hour,@TimeUTC,GETUTCDATE())>4 AND EXISTS (SELECT TOP 1  AG.[AgentId] FROM .[dbo].[Seating] AS SEA WITH (NOLOCK) 
        INNER JOIN .[dbo].[Agent] AS AG WITH (NOLOCK) ON SEA.AgentId=AG.AgentId WHERE SEA.WorkPlaceId=@WorkplaceId AND AG.TeamName<>'ADMIN')
	    BEGIN
		  DECLARE @AgentName AS NVARCHAR(100) = RTRIM((SELECT TOP 1 DisplayName FROM .[dbo].[Agent] where AgentId=@AgentId))
          RETURN 'Admin '+@AgentName+' was logged on and blocked workplace agents.'
        END
     END
  RETURN ''
END

GO


IF object_id('FSC_LogOffAgent') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_LogOffAgent
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <15.11.2018>
-- Description:	<Odhlašuje určeného agenta>
-- =============================================
CREATE PROCEDURE [dbo].[FSC_LogOffAgent]
@AgentId UniqueIdentifier
AS
BEGIN
 IF EXISTS(SELECT 1 FROM .dbo.Agent WHERE Agentid=@AgentId AND Activity<>'Logoff')
  BEGIN
    DECLARE @Popis nvarchar(100)
    DECLARE @LogoffId UniqueIdentifier = (SELECT TOP 1 [StatusId] FROM .[dbo].[Status] WHERE Activity='Logoff' AND Deleted=0)
    INSERT .dbo.ChangeRequest( ChangeRequestTimeUtc , Command , SubjectId, ReferenceId)
    VALUES (GETUTCDATE(),N'AgentStatus',@AgentId,@LogoffId)
    SET @Popis = 'I logoff AgentId= '+convert(nvarchar(40), @AgentId)
	EXEC  [FSC_WriteEvent] 1,'FSC_LogOffAgent',@Popis
  END
 END

GO

IF object_id('FSC_DELDCConnect') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_DELDCConnect
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <1.07.2024>
-- Description:	<Maže nejstarší registraci DC ve Station >
-- =============================================
CREATE PROCEDURE [dbo].[FSC_DELDCConnect]
AS
BEGIN
	DECLARE @AgentId AS UNIQUEIDENTIFIER,@OldestConnect AS datetime, @Popis nvarchar(100)
	SELECT TOP 1 @AgentId=Agentid,@OldestConnect=OldestConnect FROM (
	SELECT Agentid,
		  Count(1) AS PocReg,
		  MIN(ConnectionTimeUtc) AS OldestConnect
	  FROM [Station] ST
	  WHERE ClientInfo LIKE 'iCC.DesktopClient%' AND DisconnectionTimeUTC IS NULL
	  GROUP BY AgentId ) AS Phase1
	  WHERE PocReg>1
    IF @AgentId IS NOT NULL
      DELETE TOP (1) FROM Station WHERE @AgentId=Agentid AND @OldestConnect=ConnectionTimeUtc

    SET @Popis = 'I have deleted Oldest DC registration from Station, AgentId= '+convert(nvarchar(40), @AgentId)
	EXEC  [FSC_WriteEvent] 1,'FSC_DELDCConnect',@Popis
 END

GO



IF object_id('FSC_LogOffAdmin') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_LogOffAdmin
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Kontrola blokace agentského pracoviště Adminem
-- =============================================
CREATE PROCEDURE [dbo].FSC_LogOffAdmin

AS
BEGIN
DECLARE @AgentId AS UniqueIdentifier=
 (SELECT TOP 1 AgentId FROM .[dbo].[Agent] where TeamName='ADMIN' AND WorkplaceId IS NOT NULL AND DATEDIFF(Hour,LastRefreshUtc,GETUTCDATE())>4)
  IF @AgentId IS NOT NULL
    BEGIN
    DECLARE @WorkplaceId AS UniqueIdentifier =(SELECT TOP 1 WorkPlaceId FROM .[dbo].[Agent] where AgentId=@AgentId)
    DECLARE @TimeUTC as Datetime = (SELECT TOP 1 TimeUTC FROM .[dbo].[AgentEvent] where EventType=0 /*'AgentStatus'*/ AND AgentId=@AgentId ORDER BY EventType,AgentId,TimeUTC DESC)
	IF DATEDIFF(Hour,@TimeUTC,GETUTCDATE())>4 AND EXISTS (SELECT TOP 1  AG.[AgentId] FROM .[dbo].[Seating] AS SEA WITH (NOLOCK) 
      INNER JOIN .[dbo].[Agent] AS AG WITH (NOLOCK) ON SEA.AgentId=AG.AgentId WHERE SEA.WorkPlaceId=@WorkplaceId AND AG.TeamName<>'ADMIN')
	    BEGIN
          EXEC dbo.FSC_LogOffAgent @AgentId
          EXEC  [FSC_WriteEvent] 1,'FSC_LogOffAdmin','Admin was logged off.'
        END
   END
END

GO

IF object_id('FSC_IsHoliday') IS NOT NULL
 DROP  FUNCTION  [dbo].[FSC_IsHoliday]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <8.2.2016>
-- Description:	<říká, zda spadá zadaný čas do svátku>
-- =============================================
CREATE FUNCTION [dbo].[FSC_IsHoliday]
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
	(SELECT TimeFrom AS Start, TimeTo AS MyEnd FROM  .dbo.Holiday WHERE HolidayGroupName=@HolidayGroupName and TimeMode='SingleDay'
	   UNION
	SELECT DATEADD(YEAR,YEAR(@MyDatime) - YEAR(TimeFrom),TimeFrom) AS Start, DATEADD(YEAR,YEAR(@MyDatime) - YEAR(TimeTo),TimeTo) AS MyEnd
    FROM  .dbo.Holiday WHERE HolidayGroupName=@HolidayGroupName and TimeMode='DayInYear') AS Holidays
	   WHERE @MyDatime>=Start and @MyDatime<=MyEnd))
	BEGIN
	  SET @isHol = 1  -- Je svátek
	END
	RETURN @isHol

END
GO



IF object_id('FSC_InCalls3') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_InCalls3
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-10-05
-- Description:	Kontrola existence příchozích hovorů
-- =============================================
CREATE FUNCTION [dbo].FSC_InCalls3 (@HolidayGroupName AS NVARCHAR(50),@Minutes AS Integer)
RETURNS nvarchar(200)
AS
BEGIN
	 DECLARE @String1 AS NVARCHAR(50)
	 DECLARE @String2 AS NVARCHAR(50)
	 DECLARE @from AS datetime=DATEADD(minute,-@Minutes,GETDATE())
	 DECLARE @to AS datetime=GETUTCDATE()
	 DECLARE @fromLW AS datetime=DATEADD(week,-1,@from)
	 DECLARE @toLW AS datetime=DATEADD(week,-1,@to)
	 DECLARE @SecondsWithoutAnswer AS Integer
	 DECLARE @NewNotAnswered AS Integer
	 DECLARE @MAXanswertime AS datetime
	 DECLARE @InboundCallId AS UNIQUEIDENTIFIER

IF dbo.FSC_IsHoliday(GETDATE(),@HolidayGroupName)=0
  AND
	 NOT EXISTS(SELECT TOP 1 1 FROM .[dbo].[InboundCall] 
		   WHERE PilotTime>@from AND PilotTime<@To )
  AND
			   -- Ještě se podívám na minulý týden
		   EXISTS(SELECT TOP 1 1 FROM .[dbo].[InboundCall] 
		   WHERE PilotTime>@fromLW AND PilotTime<@ToLW )
  AND
   -- Pokud je není nikdo v práci po začátku pracovní doby, může jít o odstávku - nebudu posílat alarm:
   (EXISTS(SELECT TOP 1 1 FROM .[dbo].[Agent] WHERE Activity<>'Logoff') OR DATEPART(Hour,GETDATE())<9)
    BEGIN
	  -- Ještě zjistím, kolik uplynulo od  posledního hovoru
	  SET @from = (SELECT TOP 1 PilotTime FROM .[dbo].[InboundCall] ORDER BY PilotTime DESC)
	  SET @Minutes=DATEDIFF(Minute,@from,@to)
	  RETURN 'No inbound Call in last '+CONVERT(NVARCHAR(5),@Minutes)+' minutes - Error'
	END        

RETURN ''
END

GO
	    


IF object_id('FSC_InCalls2') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_InCalls2
GO

-- =============================================
-- Author:		Lenka Chmelová + Zbyněk Homolka
-- Create date:  2023-09-13
-- Description:	Kontrola funkčnosti příchozích hovorů
-- =============================================
CREATE FUNCTION [dbo].[FSC_InCalls2] ()
RETURNS nvarchar(200)
AS
BEGIN
	 DECLARE @String1 AS NVARCHAR(50)
	 DECLARE @String2 AS NVARCHAR(50)
	 DECLARE @from AS datetime=DATEADD(minute,-10,GETDATE())
	 DECLARE @fromUTC AS datetime=DATEADD(minute,-10,GETUTCDATE())
	 DECLARE @CallEventErrors AS Integer=
	 (select count(1) from .dbo.callevent 
	   where TimeUTC>@fromUTC AND eventtype = 23 /*'error'*/ AND inboundcallid is not null) 
	 DECLARE @NewInBoundCals AS Integer=
	 (select count(1) from .dbo.InboundCall where TimeUTC>@fromUTC)

	 IF @CallEventErrors >2 AND @CallEventErrors > @NewInBoundCals/2
	   RETURN CONVERT(NVARCHAR(5),@CallEventErrors)+' inbound Calls with errors'
RETURN ''
END

GO

IF object_id('FSC_InCalls') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_InCalls
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-09-07
-- Description:	Kontrola funkčnosti příchozích hovorů
-- =============================================
CREATE FUNCTION [dbo].FSC_InCalls (@HolidayGroupName AS NVARCHAR(50),@Minutes AS Integer)
RETURNS nvarchar(200)
AS
BEGIN
	 DECLARE @String1 AS NVARCHAR(50)
	 DECLARE @String2 AS NVARCHAR(50)
	 DECLARE @from AS datetime=DATEADD(minute,-10,GETDATE())
	 DECLARE @to AS datetime=GETDATE()
	 DECLARE @fromLW AS datetime=DATEADD(week,-1,@from)
	 DECLARE @toLW AS datetime=DATEADD(week,-1,@to)
	 DECLARE @SecondsWithoutAnswer AS Integer
	 DECLARE @NewNotAnswered AS Integer
	 DECLARE @MAXanswertime AS datetime
	 DECLARE @MAXServedtime AS datetime
	 DECLARE @MAXReacttime AS datetime
	 DECLARE @InboundCallId AS UNIQUEIDENTIFIER
	 DECLARE @CallResult AS NVARCHAR(10)

IF dbo.FSC_IsHoliday(GETDATE(),@HolidayGroupName)=0
  BEGIN
    SELECT 
	   @MAXanswertime=ISNULL(MAXanswertime,@from)
	   ,@MAXServedtime=ISNULL(MAXServedtime,@from)
       ,@SecondsWithoutAnswer=DATEDIFF(ss,IIF(ISNULL(MAXServedtime,@from)>ISNULL(MAXanswertime,@from),ISNULL(MAXServedtime,@from),ISNULL(MAXanswertime,@from)),MAXPilotTime) 
	   ,@NewNotAnswered=(SELECT COUNT(1) FROM .[dbo].[InboundCall] 
	   WHERE PilotTime>IIF(ISNULL(MAXServedtime,@from)>ISNULL(MAXanswertime,@from),ISNULL(MAXServedtime,@from),ISNULL(MAXanswertime,@from))
	    AND PilotTime<@To AND NOT (AnswerTime IS NOT NULL OR CallResult=2 /*'Served'*/)
	   ) 
	   FROM
 (SELECT TOP 100 
	   MAX(PilotTime) AS MAXPilotTime
	   ,MAX(answertime) AS MAXanswertime
	   ,MAX(IIF(CallResult=2 /*'served'*/,EndTime,@from)) AS MAXServedtime
   FROM .[dbo].[InboundCall] IC   
  WHERE 1=1
    AND PilotTime>@from AND PilotTime<@To ) AS Phase1

	 IF @SecondsWithoutAnswer > @Minutes*60 AND @NewNotAnswered>2
	   BEGIN
	     SET @MAXReacttime=IIF(@MAXanswertime>@MAXServedtime,@MAXanswertime,@MAXServedtime)
	     SET @InboundCallId = (SELECT TOP 1 InboundCallId FROM .[dbo].[InboundCall]
		 WHERE PilotTime>@MAXReacttime AND CallResult<>0 /*'Active'*/ ORDER BY TimeUTC DESC)
	     IF  @InboundCallId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM .[dbo].[CallEvent]   
          WHERE InboundCallId =@InboundCallId AND TimeUTC> @MAXReacttime AND
		  (EventType=34 /*'ScenarioResult'*/ AND ReferenceData='Completed' OR ResultData='Served'))
		    AND
			   -- Ještě se podívám na minulý týden
		   NOT EXISTS(SELECT TOP 1 1 FROM .[dbo].[InboundCall] 
		   WHERE PilotTime>@fromLW AND PilotTime<@ToLW AND AnswerTime IS NULL AND CallResult<>2 /*'Served'*/)

	   RETURN CONVERT(NVARCHAR(5),@NewNotAnswered)+' not handled inbound Calls '+CONVERT(NVARCHAR(5),@SecondsWithoutAnswer)
	   +' seconds - error'
	        
	   END
  END
RETURN ''
END

GO


IF object_id('FSC_DivertInsp') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_DivertInsp
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-12-05
-- Description:	Analýza Divert Failed
-- =============================================
CREATE FUNCTION [dbo].FSC_DivertInsp(@LimCount AS Integer)
RETURNS nvarchar(200)
AS
BEGIN
DECLARE @from AS date=GETUTCDATE()
DECLARE @DivFailCount AS Integer=
(
SELECT COUNT(1) FROM (
SELECT DISTINCT TOP 10000 
	  CAE.[TimeUTC],
	  CAE.InboundCallId
   FROM .[dbo].[CallEvent] CAE WITH (NOLOCK)
  LEFT JOIN .[dbo].[CallEvent] CAE2 WITH (NOLOCK) ON CAE.InboundCallId=CAE2.InboundCallId AND CAE2.EventType=23 /*'error'*/
  LEFT JOIN .[dbo].[CallEvent] CAE3 WITH (NOLOCK) ON CAE.InboundCallId=CAE3.InboundCallId 
  AND CAE.AgentId=CAE3.AgentId AND CAE3.EventType=15 --'AgentMissed'
  LEFT JOIN .[dbo].[CallEvent] CAE4 WITH (NOLOCK) ON CAE.InboundCallId=CAE4.InboundCallId 
   AND CAE4.ResultData='NormalRelease'
  LEFT JOIN .[dbo].[InboundCall] IC WITH (NOLOCK) ON CAE.InboundCallId=IC.InboundCallId

  WHERE 1=1
	AND CAE.EventType IN (68,23) -- ('Distributing','Error')--and ResultData like 'Divert not arrived%'
    AND CAE.[TimeUTC]>@from
    AND CAE2.[TimeUTC]>@from

	AND (CAE2.InboundCallId IS NOT NULL OR CAE.WorkplaceId<>IC.WorkplaceId OR IC.WorkplaceId IS NULL)
	AND CAE3.InboundCallId IS NULL -- Nešlo o zmeškaný hovor
	AND CAE4.InboundCallId IS NULL -- Nešlo o hovor ukončený zákazníkem
    AND CAE.InboundCallId IS NOT NULL -- Zatím jen příchozí hovory
	
) AS Phase1)

 IF  (@DivFailCount >@LimCount)
		RETURN CONVERT(NVARCHAR(5),@DivFailCount)+' Divert Failed'
RETURN ''
END
GO

IF object_id('FSC_DCReg') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_DCReg	
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2024-05-27
-- Description:	Desktop Client registration inspection
-- =============================================
CREATE FUNCTION [dbo].FSC_DCReg	()
RETURNS nvarchar(200)
AS
BEGIN
  
RETURN (SELECT TOP 1 AgentName+' ON IP Address: '+IPAddress+' has more DC Registrations.' FROM (
SELECT AgentName,
       IPAddress,
      Count(1) AS PocReg
	  FROM (
SELECT TOP (1000) [StationId]
      ,[ConnectionTimeUtc]
	  ,AG.DisplayName AS AgentName
      ,[IPAddress]
  --    ,[ProxyVersion]
      ,[ClientInfo]
      ,[AuthenticationTimeUtc]     
      ,[CredentialsId]
      ,[AppEndId]
      ,[DisconnectionTimeUtc]
      ,[Reason]
  FROM .[dbo].[Station] ST
  LEFT JOIN .[dbo].Agent AG ON AG.Agentid=ST.Agentid 
  WHERE ClientInfo LIKE 'iCC.DesktopClient%' AND DisconnectionTimeUTC IS NULL) AS Phase1
  GROUP BY AgentName,IPAddress ) AS Phase2
  WHERE PocReg>1)
-- IF  (@DivFailCount >@LimCount)
--		RETURN CONVERT(NVARCHAR(5),@DivFailCount)+' Divert Failed'
--RETURN ''
END
GO

 
IF object_id('FSC_DCReg2') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_DCReg2	
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2024-05-27
-- Description:	Desktop Client registration inspection - Logoff agents
-- =============================================
CREATE FUNCTION [dbo].FSC_DCReg2	()
RETURNS nvarchar(200)
AS
BEGIN
  
RETURN (SELECT TOP 1 AG.DisplayName+' is Logoff and has DC Registration.' 
FROM [Station] ST
  LEFT JOIN Agent AG ON AG.Agentid=ST.Agentid 
  WHERE ClientInfo LIKE 'iCC.DesktopClient%' AND AG.Activity='Logoff'
     AND DisconnectionTimeUtc IS NULL
)
END
GO

   


IF object_id('FSC_RecordingLessCalls') IS NOT NULL
 DROP  Function  [dbo].[FSC_RecordingLessCalls]
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	RecordinLess Calls
-- =============================================
CREATE FUNCTION [dbo].[FSC_RecordingLessCalls] (@Today datetime, @Now datetime)
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
,CallId2 AS CallId
,StartTimeUTC
,CallDuration	
,Chained
FROM (
SELECT * FROM (
SELECT 
      'O' AS Direction
	  , NULL AS Redirector
	  , CallerNumber
	  , WP.Number
	  , WP.DisplayName AS WorkPlaceName
      , OC.[OutboundCallId] AS CallId2
      ,DistributionTime AS CallTime
	  ,TimeUTC
	  ,CallDuration
	  ,0 AS Chained
  FROM .[dbo].[OutboundCall] OC WITH (NOLOCK)
    LEFT JOIN .[dbo].[CallRecord] CR WITH (NOLOCK) ON CR.OutboundCallId=OC.OutboundCallId
    LEFT JOIN .[dbo].[Workplace] WP ON WP.WorkplaceId=OC.WorkplaceId
  WHERE DistributionTime>@Today  AND DistributionTime<DATEADD(Hour,-1,@Now)  AND CallDuration>1
  AND CR.OutboundCallId IS NULL 
    AND LEN(RTRIM(CallerNumber))>6
   AND CallResult<>2 --'Canceled'
  AND  WP.Number IS NOT NULL -- Hodnocení hovorů nemá nahrávku ani pracoviště
  AND dbo.FSC_CustomCheckInt('DU',OC.CallDuration)=1
  AND dbo.FSC_CustomCheck2('OC',WP.DisplayName)=1
  UNION ALL
  SELECT 
      'I' AS Direction
	  , Redirector
	  , CallerNumber
	  , WP.Number
      , WP.DisplayName AS WorkPlaceName
      , IC.[InboundCallId] AS CallId2
      ,[PilotTime]  AS CallTime
	  ,TimeUTC
	  ,CallDuration	 
	  ,ChainedInbound AS Chained
  FROM .[dbo].[InboundCall] IC
    LEFT JOIN .[dbo].[CallRecord] CR ON CR.InboundCallId=IC.InboundCallId
    LEFT JOIN .[dbo].[Directory] DI ON RIGHT(DI.Number,3) COLLATE Czech_CI_AS =IC.Redirector COLLATE Czech_CI_AS
    LEFT JOIN .[dbo].[Workplace] WP ON WP.WorkplaceId=IC.WorkplaceId
  WHERE TimeUTC>@Today AND TimeUTC<DATEADD(Hour,-3,@Now) AND CallDuration>1
  AND CR.INboundCallId IS NULL   
  AND CallResult =2--'served'
  AND LEN(RTRIM(CallerNumber))>6
  --AND Redirector NOT LIKE '7%'
  AND isnull(DI.Record,1) <>0
    AND (dbo.FSC_CustomCheck2('IC',WP.DisplayName)=1 OR dbo.FSC_CustomCheck2('ID',IC.Redirector)=1)
  AND dbo.FSC_CustomCheckInt('DU',IC.CallDuration)=1 
  ) AS Phase1 ) AS Phase2
  LEFT JOIN  .[dbo].[VoiceRecord] VCR WITH(NOLOCK) ON 
   StartTimeUtc>DATEADD(ss,-30,Phase2.TimeUtc) AND StartTimeUtc<DATEADD(ss,230,Phase2.TimeUtc)
   AND RIGHT(RemoteNumber,9) COLLATE Czech_CI_AS =RIGHT(Phase2.CallerNumber,9) COLLATE Czech_CI_AS --AND AgentName IS NULL --V jedné nahrávce může být více přepojených hovorů
   AND DATEDIFF(ss,StartTimeUtc,EndTimeUtc)>=Phase2.CallDuration

)
GO


IF object_id('FSC_GetPhoneNumPhoneBooks') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_GetPhoneNumPhoneBooks
GO

CREATE FUNCTION [dbo].[FSC_GetPhoneNumPhoneBooks] (@PhoneNumberId AS uniqueidentifier)
RETURNS nvarchar(max)
AS
BEGIN
	IF @PhoneNumberId IS NULL RETURN NULL
	DECLARE @Result AS nvarchar(max)
	SELECT 
		@Result = COALESCE(@Result + ',', '') + PB.DisplayName 
	FROM 
		.dbo.PhoneComposition AS PC WITH (NOLOCK)
	INNER JOIN
		.dbo.PhoneBook AS PB WITH (NOLOCK) ON PC.PhoneBookId=PB.PhoneBookId
	WHERE
		PC.PhoneNumberId=@PhoneNumberId AND PB.Deleted=0

	RETURN @Result

END
GO



IF object_id('FSC_VolniAgentiCall') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_VolniAgentiCall
GO

CREATE FUNCTION [dbo].[FSC_VolniAgentiCall]
(	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
     IIF(ST.Activity='Ready'
	 AND WP.State='Free'
	 AND Skill.PbxInKnowledge>0
	 AND PbxInKnowledgeOffset>-100
	 AND (CONVERT(bit,dbo.FSC_GiveParam('UseFlatProficiency'))=0 OR (PROF.VoiceKnowledge>0 AND PROF.LanguageId IS NOT NULL))
       ,'YES','NO ') AS FreeAgent
     ,A.DisplayName AS AgentName
     , P.DisplayName AS ProjectName 
	 ,Skill.PbxInKnowledge
	 , ST.DisplayName AS AgentStatus
	 , ST.PbxState
	 , LANG.DisplayName AS LangKnowledge
	 , WP.State AS WPState
     FROM .dbo.Agent A  WITH (NOLOCK)   
      LEFT OUTER JOIN .dbo.Skill  WITH (NOLOCK)
 ON Skill.AgentId=A.AgentId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1
      LEFT OUTER JOIN .dbo.Project P  WITH (NOLOCK)
 ON P.ProjectId=Skill.ProjectId AND P.Deleted=0
      LEFT OUTER JOIN .dbo.Status ST  WITH (NOLOCK)
 ON A.Activity=ST.Activity AND A.StatusId = ST.StatusId
     LEFT OUTER JOIN .dbo.Workplace WP  WITH (NOLOCK)
 ON WP.WorkplaceId=A.WorkplaceId
    LEFT OUTER JOIN .dbo.Proficiency PROF  WITH (NOLOCK)
 ON PROF.AgentId=A.AgentId AND PROF.VoiceKnowledge>0 AND PROF.VoiceEnabled=1 AND PROF.VoiceChannel=1
       LEFT OUTER JOIN .dbo.Language LANG  WITH (NOLOCK)
 ON LANG.LanguageId=PROF.LanguageId

     WHERE A.Deleted=0 AND Template=0
 
     )

GO


IF object_id('FSC_TimeUTC_Local') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_TimeUTC_Local
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <15.3.2016>
-- Description:	<Převádí TimeUTC na Timelocal>
-- poslední neděle v březnu  -  poslední neděle v říjnu
-- =============================================

CREATE FUNCTION [dbo].[FSC_TimeUTC_Local](@TimeUTC as DateTime)
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
	   @TimeUTC>=CONVERT(datetime,'2025.03.30 01:00') AND @TimeUTC<=CONVERT(datetime,'2025.10.26 02:00') OR
       @TimeUTC>=CONVERT(datetime,'2026.03.29 01:00') AND @TimeUTC<=CONVERT(datetime,'2026.10.25 02:00') OR 
       @TimeUTC>=CONVERT(datetime,'2027.03.28 01:00') AND @TimeUTC<=CONVERT(datetime,'2027.10.31 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2028.03.26 01:00') AND @TimeUTC<=CONVERT(datetime,'2028.10.29 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2029.03.25 01:00') AND @TimeUTC<=CONVERT(datetime,'2029.10.28 02:00') OR
	   @TimeUTC>=CONVERT(datetime,'2030.03.31 01:00') AND @TimeUTC<=CONVERT(datetime,'2030.10.27 02:00') OR 
	   @TimeUTC>=CONVERT(datetime,'2031.03.30 01:00') AND @TimeUTC<=CONVERT(datetime,'2031.10.31 02:00') 

	  SET @Offset = 2
	ELSE
	  SET @Offset = 1
	RETURN DATEADD(Hour,@Offset,@TimeUTC)
END
--
GO

IF object_id('FSC_SelectPhBook') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_SelectPhBook
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <12.05.2017>
-- Description:	<Volba telefonního seznamu>
-- =============================================
CREATE PROCEDURE [dbo].[FSC_SelectPhBook]
@RecordId UniqueIdentifier
AS
BEGIN
--DECLARE @MyAgentId AS UniqueIdentifier = 'ffee47c8-da99-47d3-b4e2-ca92b624ac95' -- Admin ID
   EXEC .dbo.FSC_WriteParam  N'SELECTEDPHONEBOOK',@RecordId,N'Selected PhoneBook'
END
GO


IF object_id('FSC_PutPNIntoPhBook') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_PutPNIntoPhBook
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <1.06.2017>
-- Description:	<Vloží­ zvolené tel. číslo do vybraného telefonní­ho seznamu>
-- =============================================
CREATE PROCEDURE [dbo].[FSC_PutPNIntoPhBook]
@PhoneNumberId UniqueIdentifier
AS
BEGIN
--DECLARE @MyAgentId AS UniqueIdentifier = 'ffee47c8-da99-47d3-b4e2-ca92b624ac95' -- Admin ID
--DECLARE @ConfigurationId AS UniqueIdentifier
DECLARE @ConfigurationName AS NVARCHAR(50) = 'SELECTEDPHONEBOOK'
DECLARE @PhoneBookId AS UniqueIdentifier=CONVERT(UniqueIdentifier,dbo.FSC_GiveParam(@ConfigurationName))
  IF @PhoneBookId IS NOT NULL
   BEGIN
-- Podívám se, zda se číslo v seznamu již nenachází
   DECLARE @PhoneCompositionId AS UniqueIdentifier=(SELECT PhoneCompositionId FROM [PhoneComposition]  WHERE PhoneBookId=@PhoneBookId AND PhoneNumberId=@PhoneNumberId)
    IF @PhoneCompositionId IS NULL
	  BEGIN
	    INSERT INTO [PhoneComposition]
           ([PhoneBookId],[PhoneNumberId])
        VALUES (@PhoneBookId,@PhoneNumberId)
	  END
     ELSE
	  DELETE FROM [PhoneComposition] WHERE PhoneCompositionId=@PhoneCompositionId -- Odstranění čísla z telefonního seznamu
	END
END
GO


IF object_id('FSC_GatewayTest') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_GatewayTest]
GO

CREATE  PROCEDURE [dbo].[FSC_GatewayTest]
@GatewayId UniqueIdentifier
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 28.06.2021
-- Description:	Testuje bránu
-- =============================================
BEGIN
  DECLARE @Direction AS NVARCHAR(1) = (SELECT TOP 1 [Direction] FROM [Gateway] WHERE GatewayId=@GatewayId)
  DECLARE @PPilotAddress AS NVARCHAR(200) = (SELECT TOP 1 PilotAddress FROM [Gateway] WHERE GatewayId=@GatewayId)
  DECLARE @InspectAddress as nvarchar(200) =.dbo.FSC_GiveParam('TOCC')
  DECLARE @RemoteAddress AS NVARCHAR(100) = IIF(@Direction='O',@InspectAddress,@PPilotAddress)
		 ,@TestId AS UniqueIdentifier = (SELECT TOP 1 GatewayId FROM [Gateway] WHERE Direction IN ('B','O'))
  SET @GatewayId=IIF(@Direction='I',@TestId,@GatewayId)
  EXEC [dbo].[FSC_Write_Mail] @GatewayId,@RemoteAddress, 'FSL1: Test','Test' -- Odeslání testovacího mailu
END 

GO

IF object_id('FSC_Write_Mail') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_Write_Mail]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <13.02.2020>
-- Description:	<Zápis mailu>
-- =============================================

CREATE PROCEDURE [dbo].[FSC_Write_Mail] (
@GW as uniqueidentifier,
@RemoteAddress as nvarchar(200),
@SubjectField as nvarchar(200),
@Message as nvarchar(500)
)
AS
BEGIN
  DECLARE @FromField as nvarchar(200)=(SELECT TOP 1 [DisplayName] FROM [Gateway] WHERE [GatewayId]=@GW)
  DECLARE @TimeLocalMess as DateTime
  insert into Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText)
		values(GETUTCDATE(),1,8,0, @FromField, @RemoteAddress,@RemoteAddress ,@GW,99,'O',@SubjectField, @Message , @Message )
/**/

END

GO


IF object_id('FSC_IndexReorganize') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_IndexReorganize
GO

CREATE PROCEDURE dbo.FSC_IndexReorganize
    @FragmentationThreshold FLOAT = 5.0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IndexList TABLE (
        TableName NVARCHAR(128),
        IndexName NVARCHAR(128),
        Fragmentation FLOAT
    );

    INSERT INTO @IndexList
    SELECT
        QUOTENAME(t.name) AS TableName,
        QUOTENAME(i.name) AS IndexName,
        s.avg_fragmentation_in_percent AS Fragmentation
    FROM
        sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS s
        JOIN sys.indexes AS i WITH (NOLOCK) ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id
        JOIN sys.tables AS t WITH (NOLOCK) ON i.[object_id] = t.[object_id]
    WHERE
        --s.database_id = DB_ID() AND
        s.avg_fragmentation_in_percent >= @FragmentationThreshold
        AND i.name IS NOT NULL
        --AND i.type_desc IN ('CLUSTERED', 'HEAP')
        AND i.is_disabled = 0
        AND i.is_hypothetical = 0;

    DECLARE @TableName NVARCHAR(128);
    DECLARE @IndexName NVARCHAR(128);
    DECLARE @Fragmentation FLOAT;
	DECLARE @EndTime AS DateTime=DATEADD(Hour,1,GETDATE()) -- Maximální čas = 1hodina
    DECLARE cur CURSOR FOR
    SELECT TableName, IndexName, Fragmentation FROM @IndexList;

    OPEN cur;

    FETCH NEXT FROM cur INTO @TableName, @IndexName, @Fragmentation;

    WHILE @@FETCH_STATUS = 0 AND GETDATE()<@EndTime
    BEGIN
        DECLARE @SQL NVARCHAR(4000);
        SET @SQL = 'ALTER INDEX ' + @IndexName + ' ON ' + @TableName + 
		IIF(@Fragmentation<30,' REORGANIZE;',		
             ' REBUILD WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON,STATISTICS_NORECOMPUTE = ON)')
        EXEC (@SQL);

        FETCH NEXT FROM cur INTO @TableName, @IndexName, @Fragmentation;
    END

    CLOSE cur;
    DEALLOCATE cur;
END
GO



IF object_id('FSC_Maintenance') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_Maintenance]
GO

CREATE  PROCEDURE [dbo].[FSC_Maintenance]
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 28.12.2023
-- Description:	Provádí údržbu databází Frontstage
-- =============================================
BEGIN
    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)
	SET @Popis = 'Entry point'
	EXEC  .[dbo].[FSC_WriteEvent] @Loguj, @ProcName, @Popis

  EXEC .[dbo].[FSC_Daily_Maintenance]
  EXEC .[dbo].[FSC_DelEventlog]
  EXEC .[dbo].[FSC_CustMaintenance]
  EXEC .[dbo].FSC_IndexReorganize
  EXEC .[dbo].[FSC_WriteEvent] @Loguj, @ProcName, 'End of procedure'
END 

GO


IF object_id('FSC_isOutboundImpComplete') IS NOT NULL
 BEGIN
  DROP  FUNCTION [dbo].FSC_isOutboundImpComplete
 END
 GO
 -- =============================================
-- Author:          <Zbyněk Homolka>
-- Create date: <17.2.2020>
-- Description:     <zjištuje, zda je celý import odchozí kampaně zpracován>
-- =============================================
CREATE FUNCTION [dbo].[FSC_isOutboundImpComplete]
(
       -- Add the parameters for the function here
       @OutboundListImportId as UniqueIdentifier
)
RETURNS integer
AS
BEGIN
 
RETURN ISNULL((SELECT TOP 1 0 FROM [OutboundCall]
WITH(NOLOCK)  WHERE 1=1  AND OutboundListImportId =@OutboundListImportId AND CallResult=10 /*'Scheduled'*/),1)
END
GO

IF object_id('FSC_DelEventlog') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_DelEventlog]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <15.06.2017>
-- Description:	<Mazání Eventlogu>
-- =============================================
CREATE PROCEDURE [dbo].[FSC_DelEventlog]

AS
BEGIN
  DECLARE @LimDat AS Datetime = GETDATE()-90
  DELETE FROM [FSC_Eventlog] WHERE DatumCas<@LimDat
END
GO


IF object_id('FSC_SelectIVRScript') IS NOT NULL
 DROP  Procedure  [dbo].[FSC_SelectIVRScript]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <20.12.2019>
-- Description:	<Volba IVR Scriptu>
-- =============================================
CREATE PROCEDURE [dbo].[FSC_SelectIVRScript]
@RecordId UniqueIdentifier
AS
BEGIN
--DECLARE @MyAgentId AS UniqueIdentifier = 'ffee47c8-da99-47d3-b4e2-ca92b624ac95' -- Admin ID
   EXEC .dbo.FSC_WriteParam  N'SELECTED_IVR',@RecordId,N'Selected IVR Script'
END

GO

	
IF object_id('FSC_CorrectFin') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_CorrectFin
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2024-04-03
-- Description:	Analýza Eventlogu
-- =============================================
CREATE FUNCTION [dbo].FSC_CorrectFin()
RETURNS nvarchar(200)
AS
BEGIN
 declare @Now as datetime = GETUTCDATE()
 declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
 declare @LastRun as datetime = (SELECT LastRunTime FROM FSC_Monitor WHERE Command='FSC_CorrectFin()')
 declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Now )
 DECLARE @Procedura AS NVARCHAR(50)
 DECLARE @StartTime AS DateTime
SELECT  TOP 1 @Procedura=EL1.Procedura,@StartTime=.dbo.FSC_TimeUTC_Local(EL1.DatumCas)  FROM [FSC_Eventlog] EL1 WITH (NOLOCK)
 LEFT JOIN [FSC_Eventlog] EL2 WITH (NOLOCK) ON EL2.DatumCas>=EL1.DatumCas AND EL1.Procedura=EL2.Procedura AND 
    EL2.Popis IN ('Konec procedury','End of procedure','End of procedure (from inspection)')
  WHERE EL1.DatumCas>@LastRun AND EL1.DatumCas<@Pred15min AND EL1.Popis IN ('Vstupní bod','Entry point')
    AND EL2.DatumCas IS NULL

 IF  (@Procedura IS NOT NULL)
		RETURN 'Procedure '+@Procedura+' was not finished correctly! StartTime='+convert(NVARCHAR(26), @StartTime)
RETURN ''
END
GO


IF object_id('FSC_Fin_Add') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_Fin_Add]
GO

CREATE  PROCEDURE [dbo].[FSC_Fin_Add]
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 3.4.2024
-- Description:	Přidává falešný konec nefunkční procedury
-- =============================================
BEGIN
 declare @Now as datetime = GETDATE()
 declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
 declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Now )
  DECLARE @Procedura AS NVARCHAR(50) = (
SELECT  TOP 1 EL1.Procedura  FROM [FSC_Eventlog] EL1 WITH (NOLOCK)
 LEFT JOIN [FSC_Eventlog] EL2 WITH (NOLOCK) ON EL1.Procedura=EL2.Procedura AND EL2.DatumCas>EL1.DatumCas AND 
    EL2.Popis IN ('Konec procedury','End of procedure','End of procedure (from inspection)')
  WHERE EL1.DatumCas>@Yesterday AND EL1.DatumCas<@Pred15min AND EL1.Popis IN ('Vstupní bod','Entry point')
    AND EL2.DatumCas IS NULL)

 IF  (@Procedura IS NOT NULL)
   BEGIN
     EXEC  .[dbo].[FSC_WriteEvent] 1,@Procedura,'End of procedure (from inspection)'   
   END
END 

GO

--
IF object_id('FSC_Backup_Table') IS NOT NULL
 BEGIN
  DROP  PROCEDURE [dbo].FSC_Backup_Table
 END


GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <6.08.2024>
-- Description:	Záloha 1 (konfigurační) tabulky do FSC_*
-- =============================================

CREATE PROCEDURE [dbo].[FSC_Backup_Table]
@TableName NVARCHAR(50),
@WhereCond NVARCHAR(250)
AS
BEGIN
  DECLARE @OrigName AS NVARCHAR(100) = 'FSC_'+@TableName
  DECLARE @NewName AS NVARCHAR(100) = @TableName+'_old'
  --PRINT DB_NAME()
 	IF OBJECT_ID(N'FSC_'+@TableName, N'U') IS NOT NULL -- Tabulka existuje
	  BEGIN
	    IF OBJECT_ID(N'FSC_'+@TableName+'_old', N'U') IS NOT NULL -- Tabulka existuje 
		  EXEC('DROP TABLE FSC_'+@TableName+'_old')--DROP TABLE $(Icc_Backup).dbo.Agent_old
	    EXEC sp_rename @OrigName, @NewName
	  END
	 EXEC('select * into FSC_'+@TableName+' from '+@TableName+@WhereCond)

 END
 GO



IF object_id('FSC_CancelZombieCalls') IS NOT NULL
 DROP  Procedure  [dbo].FSC_CancelZombieCalls
GO


 CREATE PROCEDURE [dbo].[FSC_CancelZombieCalls]
 @MinStuck Integer
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 19.10.2018
-- Description:	Ruší příchozí hovory, které jsou aktivní přes @MinStuck minut
-- =============================================

BEGIN

DECLARE @Now AS datetime=GETDATE()
DECLARE @TimeLimit AS datetime=DATEADD(Minute,-@MinStuck,@Now)


UPDATE [InboundCall]
SET CallResult = 1 /*'Lost'*/, CallPhase = 9 /*'HangupAgent'*/
WHERE 1=1
  AND Callresult=0 --'Active'
  --AND CallPhase='Distributing'
  AND PilotTime < @TimeLimit

END
GO


IF object_id('FSC_VolniAgentiEmail') IS NOT NULL
 BEGIN
  DROP  FUNCTION [dbo].FSC_VolniAgentiEmail
 END
 GO



CREATE FUNCTION [dbo].[FSC_VolniAgentiEmail]
(	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
      IIF(EmailConsumption>0 AND ISNULL(MCountReal,0) < ROUND(IIF(EmailConsumption>0,100/EmailConsumption,0),0)
	 AND ST.EmailDistribute=1
	 AND PROF.LanguageId IS NOT NULL
	 AND WP.Message=1,'YES','NO ') AS VolnyAgent
     ,A.DisplayName AS AgentName
     , P.DisplayName AS ProjectName 
	 , ST.DisplayName AS Statusagenta
     , ISNULL(MCountReal,0) AS EmailCount
	 , ROUND(IIF(EmailConsumption>0,100/EmailConsumption,0),0) AS MaxEmailCount
	 , LANG.DisplayName AS ZnalostJazyka
	 , ST.EmailDistribute AS EmailPovolenStav
	 , WP.Message AS EmailPovolenPracov
     FROM .dbo.Agent A  WITH (NOLOCK)   
      LEFT OUTER JOIN .dbo.Skill  WITH (NOLOCK)
 ON Skill.AgentId=A.AgentId AND Skill.EmailKnowledge>0 AND Skill.EmailEnabled=1 AND Skill.EmailChannel=1
      LEFT OUTER JOIN .dbo.Project P  WITH (NOLOCK)
 ON P.ProjectId=Skill.ProjectId
      LEFT OUTER JOIN .dbo.Status ST  WITH (NOLOCK)
 ON A.Activity=ST.Activity AND A.StatusId = ST.StatusId
     LEFT OUTER JOIN .dbo.Workplace WP  WITH (NOLOCK)
 ON WP.WorkplaceId=A.WorkplaceId
    LEFT OUTER JOIN .dbo.Proficiency PROF  WITH (NOLOCK)
 ON PROF.AgentId=A.AgentId AND PROF.MessageKnowledge>0 AND PROF.MessageEnabled=1 AND PROF.MessageChannel=1
       LEFT OUTER JOIN .dbo.Language LANG  WITH (NOLOCK)
 ON LANG.LanguageId=PROF.LanguageId
 LEFT OUTER JOIN 
 (SELECT  
      M.AgentId, COUNT(1) AS MCountReal
       FROM Message AS M 
      WHERE MessageType IN (1,2) AND M.AGENTID IS NOT NULL AND MessageResult=0 AND M.Direction='I' 
	  GROUP BY AgentId) AS ME ON ME.AgentId=A.AgentId

     WHERE A.Deleted=0
 

              
)

GO


IF object_id('FSC_Invalid_Call') IS NOT NULL
 BEGIN
  DROP  FUNCTION [dbo].FSC_Invalid_Call
 END
 GO
 -- =============================================
-- Author:          <Zbyněk Homolka>
-- Create date: <14.8.2024>
-- Description:     <Hledá aktivní chybné hovory>
-- =============================================
CREATE FUNCTION [dbo].FSC_Invalid_Call
(
)
RETURNS nvarchar(200)
AS
BEGIN
DECLARE @NowUTC AS datetime=GETUTCDATE()
DECLARE @TimeLimit AS datetime=DATEADD(Minute,-70,@NowUTC)
DECLARE @InboundCallId AS UniqueIdentifier
SELECT TOP 1 @InboundCallId=InboundCallId /*,PilotTime,CallPhase,CallResult,Callernumber
   ,AG.DisplayName AS AgentName
   ,AG.Activity 
   ,WP.State
   ,DATEDIFF(MINUTE,PilotTime,@Now) AS ActiveMin*/
FROM [InboundCall] IC
 LEFT JOIN Agent AG ON AG.AgentId=IC.AgentId
 LEFT JOIN WorkPlace WP ON WP.WorkPlaceId=IC.WorkPlaceId

WHERE 1=1
  AND Callresult=0--'Active'
  AND DATEADD(Minute,15,TimeUTC)<@NowUTC
  AND ((PilotTime < @TimeLimit AND IC.AgentId IS NULL)
  OR  (WP.State NOT IN ('Busy','Ring','Hold') AND WP.State IS NOT NULL AND IC.AgentId IS NOT NULL
         AND AG.Activity NOT IN ('PostCall') )
  OR  (AG.Activity NOT IN ('Ready','Pause','PostCall') AND IC.AgentId IS  NOT NULL))

IF  (@InboundCallId IS NOT NULL)
   BEGIN
 	RETURN 'Invalid InCall '+CONVERT(NVARCHAR(40),@InboundCallId)
   END
RETURN ''
END
GO

	
IF object_id('FSC_SystemTest') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_SystemTest
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-11-21
-- Description:	Analýza Eventlogu
-- =============================================
CREATE FUNCTION [dbo].FSC_SystemTest()
RETURNS nvarchar(200)
AS
BEGIN
 declare @Now as datetime = GETUTCDATE()
 declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
 declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Now )
 DECLARE @Procedura AS NVARCHAR(50), @Popis AS NVARCHAR(50)
  SELECT TOP 1 @Procedura=Procedura,@Popis=Popis  FROM [FSC_Eventlog] WITH (NOLOCK)
  WHERE DatumCas>@Yesterday /*AND DatumCas<@Pred15min*/ AND Procedura='SystemTests'
   ORDER BY DatumCas DESC
 IF  (@Popis IS NOT NULL)
		RETURN @Popis
RETURN ''
END
GO


IF object_id('FSC_Sys_Ack') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_Sys_Ack]
GO

CREATE  PROCEDURE [dbo].[FSC_Sys_Ack]
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 21.11.2023
-- Description:	Provádí Acknowledge příslušné chyby
-- =============================================
BEGIN
 declare @Now as datetime = GETUTCDATE()
 declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
 declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Now )
 DECLARE @Procedura AS NVARCHAR(50), @Popis AS NVARCHAR(50)
  SELECT TOP 1 @Procedura=Procedura,@Popis=LEFT(Popis,7) FROM [FSC_Eventlog] WITH (NOLOCK)
  WHERE DatumCas>@Yesterday /*AND DatumCas<@Pred15min*/ AND Procedura='SystemTests'
   ORDER BY DatumCas DESC
 IF  (@Popis IS NOT NULL)
   BEGIN
 	 UPDATE [dbo].[FSC_Eventlog]
		 SET [Procedura] = 'STProcessed'
		WHERE DatumCas>@Yesterday AND Procedura='SystemTests' AND Popis LIKE @Popis+'%' --DatumCas=@DatumCas
    
   END
END 

GO


IF object_id('FSC_Repair_Target') IS NOT NULL
 BEGIN
  DROP  PROCEDURE [dbo].FSC_Repair_Target
 END


GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <16.08.2024>
-- Description:	Záloha 1 (konfigurační) tabulky do FSC_*
-- =============================================

CREATE PROCEDURE [dbo].[FSC_Repair_Target]
@DataQueryColumnId AS UniqueIdentifier,
@Expression NVARCHAR(250)
AS
BEGIN

--DECLARE @DataQueryColumnId AS UniqueIdentifier='B23D6374-9D41-40E3-B3D8-FEBE9742D243'
DECLARE @RightPosition AS Int = CHARINDEX(@Expression,
(SELECT TOP 1 UrlFormat FROM (
SELECT [UrlFormat]
    ,COUNT(1) AS Pocet
  FROM [DataQueryColumn] DQC
  WHERE 1=1
  AND UrlFormat LIKE '%'+@Expression+'%'
  GROUP BY UrlFormat ) AS Phase1
  ORDER BY Pocet DESC))

DECLARE @URLFormat AS NVARCHAR(300)=
(SELECT [UrlFormat]
  FROM [DataQueryColumn] DQC
  WHERE 1=1
  AND DataQueryColumnId=@DataQueryColumnId)

DECLARE @MyPosition AS Int = CHARINDEX(@Expression,@URLFormat)
SET @URLFormat=SUBSTRING(@URLFormat,@MyPosition-@RightPosition+1,300)

 /* SELECT @RightPosition AS RightPosition,@MyPosition AS MyPosition,@URLFormat
*/
UPDATE TOP (1) DataQueryColumn 
SET UrlFormat=@URLFormat
WHERE DataqueryColumnId=@DataQueryColumnId
END
GO
IF NOT EXISTS(SELECT TOP 1 Timelocal FROM [FSC_Errorlog])
	EXEC [dbo].[FSC_ErrorLogProc] 'Starting test','','','',0,240


	
