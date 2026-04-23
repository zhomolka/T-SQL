
:setvar Version 22.04.2026
:r C:\\Atlantis\\Scripts\\setvar.txt
:on error exit
PRINT 'Script is running on == $(MonitorDB) =='

DECLARE @FSVersion AS NVARCHAR(2) = 'V2'

   -- BEGIN TRY
IF @FSVersion<>$(FSVersion)
  BEGIN
    ----Zastav
    RAISERROR('Tato verze skriptu je určena pro jinou verzi  !!!!!!!!!', 15, 10) --WITH LOG
    PRINT 'Tato verze je určena pro jinou verzi  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'	
	--SET NOEXEC ON
  END
--:setvar ICC_Backup FS_Custom -- Pro @LowPermission=1
DECLARE @LowPermission AS bit = $(LowPermission) -- 0 = normální oprávnění, 1 = nízké oprávnění


-- Vyhledávání sekcí:
-- Plánovaný konec
--OBECNÁ SEKCE:
--Podpůrné procedury
 --PRINT 'Script běží dál!'	

IF @LowPermission = 0
BEGIN
	IF  NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'$(MonitorDB)')
		BEGIN
		  CREATE DATABASE [$(MonitorDB)]
		  PRINT 'DB $(MonitorDB) was created!'	
		END
	IF NOT EXISTS (SELECT * FROM [$(MonitorDB)].SYS.EXTENDED_PROPERTIES WHERE Name = 'description')
		EXEC [$(MonitorDB)].sys.sp_addextendedproperty @name=N'description', @value=N'Monitoring_DB'
END
GO

USE $(MonitorDB)
GO

IF NOT EXISTS(
SELECT * FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_NAME='Monitor')
   BEGIN
	CREATE TABLE [dbo].[Monitor](
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
		DetailMessage NVARCHAR(400) NULL,
		[InformBySecondMatch] [bit] NULL,
		[ReparationProc] [nvarchar](150) NULL,
		Note NVARCHAR(200) NULL
	) ON [PRIMARY]

    ALTER TABLE [dbo].[Monitor] ADD  CONSTRAINT [DF_Monitor_MonitorId]  DEFAULT (newid()) FOR [MonitorId]
 END
GO

IF NOT EXISTS(
SELECT * FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_NAME='Configuration')
   BEGIN
	CREATE TABLE [dbo].Configuration(
		[ConfigurationId] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
		[ConfigurationName] [nvarchar](50) NULL,
	    [ConfigurationValue] [nvarchar](300) NULL,
        [Description] [nvarchar](300) NULL   
	) ON [PRIMARY]

    ALTER TABLE [dbo].Configuration ADD  CONSTRAINT [DF_Configuration_ConfigurationId]  DEFAULT (newid()) FOR [ConfigurationId]
 END
GO


IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Monitor] WHERE Command='CustomCheckMain()')
  BEGIN 
INSERT [dbo].[Monitor] ([MonitorId], [DisplayName], [Command], [ExecDuration], [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'Testing Procedure', N'CustomCheckMain()', 0, -1, 8, 16, NULL, NULL, NULL)
  END
GO


IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Monitor] WHERE Command LIKE 'DiskSpace(%')
  BEGIN 
INSERT [dbo].[Monitor] ([MonitorId], [DisplayName], [Command], [ExecDuration], [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'Disk Space inspect', N'DiskSpace(15)', 0, 1000, 7, 10, NULL, NULL, NULL)
  END
GO



IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Monitor] WHERE Command='DBSize()')
  BEGIN 
INSERT [dbo].[Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'Express DB size inspection', N'DBSize()',  -1, 14, 22, 1, NULL, NULL)
  END
GO



IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Monitor] WHERE Command='AutoTest()')
  BEGIN 
INSERT [dbo].[Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'AutoTest', N'AutoTest()',  10000, 14, 22, 1, NULL, NULL)
  END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Monitor] WHERE Command LIKE 'DBLocks(%')
  BEGIN 
INSERT [dbo].[Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'DB Locks inspection', N'DBLocks(1)',  20, 6, 22, 1, NULL, NULL)
  END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Monitor] WHERE Command = 'CPU()')
  BEGIN 
INSERT [dbo].[Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [Inform2], [Inform3]) 
VALUES (NEWID(), N'CPU Load inspection', N'CPU()',  20, 6, 22, 1, NULL, NULL)
  END
GO


IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Monitor] WHERE Command = 'SystemTest()')
  BEGIN 
INSERT [dbo].[Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [ReparationProc]) 
VALUES (NEWID(), N'System messages inspection', N'SystemTest()',  60, 9, 21, 1, 'FSC_Sys_Ack')
  END
GO


IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Monitor] WHERE Command = 'CorrectFin()')
  BEGIN 
INSERT [dbo].[Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [ReparationProc]) 
VALUES (NEWID(), N'Correct finish of procedure inspection', N'CorrectFin()',  60, 8, 21, 1, 'FSC_Fin_Add')
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
	RETURN (SELECT ConfigurationValue FROM $(MonitorDB).[dbo].[CONFIGURATION]  WHERE ConfigurationName=@ConfigurationName)
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
    IF NOT EXISTS (SELECT ConfigurationId FROM $(MonitorDB).[dbo].[CONFIGURATION]  WHERE ConfigurationName=@ConfigurationName)
	  BEGIN
	    INSERT INTO $(MonitorDB).[dbo].[Configuration]
           (
            [ConfigurationName]
           ,[ConfigurationValue]
           ,[Description])
     VALUES
           (@ConfigurationName,
           @ConfigurationValue,
           @Description
         )
	  END
    ELSE
	  BEGIN
        update $(MonitorDB).[dbo].[Configuration] 
         SET ConfigurationValue = @ConfigurationValue
         WHERE  ConfigurationName=@ConfigurationName
      END
END
GO



/* ===================================  M A I N   P R O C E D U R E  ============================= */

IF object_id('CheckSys') IS NOT NULL
 DROP  PROCEDURE  [dbo].CheckSys
GO
CREATE PROCEDURE [dbo].[CheckSys] 
AS
BEGIN
   declare @ProcVer as nvarchar(35) = ' Inspection function ver: $(Version)'
   
IF .dbo.GiveParam('TOCC3')=''
  BEGIN
	  UPDATE $(MonitorDB).dbo.Configuration 
        SET  ConfigurationValue='servis3@yourdomain.cz' 
      WHERE ConfigurationName='TOCC3'
  END

declare @TOCC as nvarchar(200) =.dbo.GiveParam('TOCC')
	IF @TOCC IS NULL
	     BEGIN
		   SET @TOCC  = 'servis@yourdomain.cz'
		   EXEC [dbo].[WriteParam] 'TOCC', @TOCC, 'E-mail addresses to which recorded problems should be sent'
		 END
  declare @TOCC2 as nvarchar(200) =.dbo.GiveParam('TOCC2')
	IF @TOCC2 IS NULL AND 1=2
	     BEGIN
		   SET @TOCC2  = 'servis@atlantis.cz'
		   EXEC [dbo].[WriteParam] 'TOCC2', @TOCC2, 'E-mail addresses to which recorded problems should be sent'
		 END
  declare @TOCC3 as nvarchar(200) =.dbo.GiveParam('TOCC3')
	IF @TOCC3 IS NULL
	     BEGIN
		   SET @TOCC3  = ''
		   EXEC [dbo].[WriteParam] 'TOCC3', @TOCC3, 'E-mail addresses to which recorded problems should be sent'
		 END;


     ---  Texty pro komunikaci s uživatelem: -------------------------------------------------------------------------------------------------------------
       DECLARE @AlerteMails AS NVARCHAR(200)='Email addresses for receiving discovered issues'
       DECLARE @InspectPlease AS NVARCHAR(200)='Please check'


	-----------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @StartTime AS Datetime = GETDATE()
	declare @Today as datetime = GETDATE()

    EXEC  .[dbo].[WriteEvent] 1,'CheckFS','Entry point'

	declare @TGT as nvarchar(200) = 'servis@yourdomain.cz'

	

    DECLARE @EndTime AS datetime 
	declare @Company as nvarchar(200) =.dbo.GiveParam('Company')
   DECLARE @ServiceGateWay AS  NVARCHAR(10)=.dbo.GiveParam('ServiceGateWay')
	   IF @ServiceGateWay IS NULL
	     BEGIN
		   EXEC [dbo].[WriteParam] 'ServiceGateWay', '', 'Service GateWay'
		 END

	 DECLARE @String1 AS NVARCHAR(50)
	 DECLARE @String2 AS NVARCHAR(50)
	 declare @Command AS NVARCHAR(500)
   --------------------------------------------------------------------------------------------------------------------------
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

	declare @Mark as int = 77
	-- Pokud tam jsou mé neodeslané maily mladší 24hodin, neodesílám další
	IF (EXISTS(SELECT * FROM $(MonitorDB).dbo.Message as M WITH (NOLOCK) where M.Messagetype='Email' AND MessagePhase='Scheduled' AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE()))) 
	  BEGIN
	    EXEC  .[dbo].[WriteEvent] 1,'CheckSys','End of procedure'
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
    DECLARE @to AS datetime=DATEADD(Minute,-10,GETDATE())
    DECLARE @UTCDif AS Integer = (SELECT TOP 1 DATEDIFF(HOUR,PilotTime,TimeUTC) FROM $(MonitorDB).dbo.InboundCall WITH (NOLOCK) ORDER BY TIMEUTC DESC)
    DECLARE @fromUTC AS datetime=DATEADD(Hour,@UTCDif,@from)
    DECLARE @toUTC AS datetime=DATEADD(Hour,@UTCDif,@to)
    declare @T as nvarchar(120) = CONVERT(nvarchar(20), DATEADD(MINUTE, -@Interval, @Today), 20) + ' - ' + CONVERT(nvarchar(20), @Today, 8)
	declare @Activity as nvarchar(32)
	declare @LastRecording AS Datetime
	declare @LastinCall AS Datetime
	declare @Severity AS Integer
	declare @OpakpoMin AS Integer = 30 -- Opakuj chybové hlášení po x minutách
	exec FSCMonCheck 'Starting part completed',@StartTime

 SET @String1=NULL
 SET @String2=NULL

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
  FROM .[dbo].[Monitor]
  WHERE @Hour BETWEEN RunFromHour AND RunToHour-1 AND (LastRunTime IS NULL OR DATEADD(MINUTE,RepeatAfterMin,LastRunTime)<@Now)
    AND Command is not NULL and RepeatAfterMin <>-1

  OPEN Mon_cursor 
  FETCH NEXT FROM Mon_cursor INTO @MonitorId,@Command,@DisplayName,@LastMessage,@InformBySecondMatch,@Inform1,@Inform2,
    @Inform3,@ReparationProc
  WHILE @@FETCH_STATUS = 0  AND DATEDIFF(SS,@StartTime,GETDATE())<25
    BEGIN
	  UPDATE .dbo.Monitor
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
		  UPDATE .dbo.Monitor
			  SET 
				  LastMessTime = GETDATE()
				 ,LastMessage  = @EmlMsg
			  WHERE MonitorId =@MonitorId
          SET @Specif=(SELECT TOP 1 DetailMessage FROM .dbo.Monitor WHERE MonitorId =@MonitorId )
		  EXEC [dbo].[FSC_ErrorLogProc] @EmlMsg,@Specif,@ProcVer,@DisplayName,@Severity,10

		 END
	   ELSE
	     BEGIN
           IF ISNULL(@EmlMsg,'')<>'' AND @EmlMsg<>'RUNPROC'
	        AND (ISNULL(@InformBySecondMatch,0)=1 AND @EmlMsg=@LastMessage)	
			 UPDATE .dbo.Monitor
			   SET 
				  LastMessTime = GETDATE()
				 ,LastMessage  = @EmlMsg+' 2'
	   
		 END

		SET @ExecDuration=DATEDIFF(SS,@StartProcTime,GETDATE())
		UPDATE .dbo.Monitor
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

         SELECT @DisplayName+' had duration '+CONVERT(NVARCHAR(2),@ExecDuration)+' seconds' AS Test,@EmlMsg AS Message

		FETCH NEXT FROM Mon_cursor INTO @MonitorId,@Command,@DisplayName,@LastMessage,@InformBySecondMatch,@Inform1,@Inform2,
    @Inform3,@ReparationProc

    END
  CLOSE Mon_cursor;  
  DEALLOCATE Mon_cursor;
----------------------------------------------------------------------------------------


       EXEC  .[dbo].[WriteEvent] 1,'CheckFS','End of procedure'

END
GO --------------------- 

PRINT 'End of CheckSys';

         THROW 50000, 'Plánovaný konec skriptu', 1; /* --´====================================== */




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
	[CommandId] [uniqueidentifier] NOT NULL DEFAULT (newid()),
    [GroupName] [nvarchar](6) NULL
) ON [PRIMARY]

GO
IF NOT EXISTS(SELECT TOP 1 1 FROM $(ProServer)..Configuration WITH(NOLOCK) WHERE ConfigurationName='Debug.Service')
INSERT INTO $(ProServer).[dbo].[Configuration]
           (
           [ConfigurationName]
	   ,[ConfigurationValue]
           ,[Description])
     VALUES
           (
           'Debug.Service'  
	   ,'RenameLogByDays'         
           ,'Dynamické indikátory úrovně ladění pro Pro.Service.')

IF NOT EXISTS(SELECT TOP 1 1 FROM $(ProServer).dbo.Configuration WITH(NOLOCK) WHERE ConfigurationName='Debug.Service' AND ConfigurationValue LIKE '%RenameLogByDays%')
   UPDATE $(ProServer).[dbo].[Configuration]
     SET  ConfigurationValue = ConfigurationValue+';RenameLogByDays'
  WHERE  ConfigurationName='Debug.Service'
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WITH(NOLOCK) WHERE CommandId  = 'ee859402-15e9-48cc-802b-f40d9258b92e')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC $(FS_Custom).dbo.CancelZombieCalls', N'Close Inbound Calls which are longer time in distribution', N'ee859402-15e9-48cc-802b-f40d9258b92e')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE CommandId  = '62e84a06-6f83-4594-9ccd-a756a096d3b3')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC $(FS_Custom).dbo.InspectIVR', N'Look for errors in IVR', N'62e84a06-6f83-4594-9ccd-a756a096d3b3')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE CommandId  = 'ee118948-03ea-4d0c-9f03-754fcf195980')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC $(FS_Custom).dbo.FSC_SendEmails 3', N'Send e-mails in failed status', N'ee118948-03ea-4d0c-9f03-754fcf195980')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE CommandId  = 'BDD430C8-B44C-4D74-B2B8-1A1600DACE97')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC $(FS_Custom).dbo.PridejPravaPoslechu', N'Set rights for Recordings listening', N'BDD430C8-B44C-4D74-B2B8-1A1600DACE97')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE CommandId  = '705C018E-4182-4DFF-ACF1-460992D31180')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId]) VALUES (N'EXEC Icc_Backup.dbo.Backup_DB ''C:\'' ', N'Configuration Backup', N'705C018E-4182-4DFF-ACF1-460992D31180')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE CommandId  = '9E6654E7-FD93-41CB-98F5-CDD77DDE02B8')
INSERT [dbo].[Commands] ([Command], [Description], [CommandId], GroupName) VALUES (N'EXEC $(FS_Custom).dbo.FSCSwitchXSS', N'Message Security Setting', N'9E6654E7-FD93-41CB-98F5-CDD77DDE02B8','SUPER')
GO
IF NOT EXISTS(SELECT Top 1 1 FROM $(FS_Custom).dbo.Commands WHERE Command LIKE '%CheckRecAndEmlActivity2%')
INSERT [dbo].[Commands] ([Command], [Description]) VALUES (N'EXEC $(FS_Custom).dbo.CheckRecAndEmlActivity2', N'Monitoring system')
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
DECLARE @from AS date=GETDATE()
DECLARE @DivFailCount AS REAL=
(
SELECT COUNT(1) FROM (
SELECT DISTINCT TOP 10000 
	  CAE.[TimeLocal],
	  CAE.InboundCallId
   FROM $(MonitorDB).[dbo].[CallEvent] CAE WITH (NOLOCK)
  LEFT JOIN $(MonitorDB).[dbo].[CallEvent] CAE2 WITH (NOLOCK) ON CAE.InboundCallId=CAE2.InboundCallId AND CAE2.EventType='Error'
  LEFT JOIN $(MonitorDB).[dbo].[CallEvent] CAE3 WITH (NOLOCK) ON CAE.InboundCallId=CAE3.InboundCallId 
  AND CAE.AgentId=CAE3.AgentId AND CAE3.EventType='AgentMissed'
  LEFT JOIN $(MonitorDB).[dbo].[CallEvent] CAE4 WITH (NOLOCK) ON CAE.InboundCallId=CAE4.InboundCallId 
   AND CAE4.ResultData='NormalRelease'
  LEFT JOIN $(MonitorDB).[dbo].[InboundCall] IC WITH (NOLOCK) ON CAE.InboundCallId=IC.InboundCallId

  WHERE 1=1
	AND CAE.EventType IN ('Distributing','Error') --and ResultData like 'Divert not arrived%'
    AND CAE.[TimeLocal]>@from
    AND CAE2.[TimeLocal]>@from
	--AND CAE3.[TimeLocal]>@from
	--AND CAE4.[TimeLocal]>@from

	AND (CAE2.InboundCallId IS NOT NULL OR CAE.WorkplaceId<>IC.WorkplaceId OR IC.WorkplaceId IS NULL)
	AND CAE3.InboundCallId IS NULL -- Nešlo o zmeškaný hovor
	AND CAE4.InboundCallId IS NULL -- Nešlo o hovor ukončený zákazníkem
    AND CAE.InboundCallId IS NOT NULL -- Zatím jen příchozí hovory
	
) AS Phase1)

 IF  (@DivFailCount >@LimCount)
   BEGIN
     DECLARE @InCallCount AS REAL=
      (SELECT COUNT(1) FROM $(MonitorDB).[dbo].[InboundCall] WITH (NOLOCK) WHERE PilotTime>@from)

		RETURN CONVERT(NVARCHAR(5),@DivFailCount)+' Divert Failed. It is '+CONVERT(NVARCHAR(9),@DivFailCount*100/@InCallCount)+' %'
   END
RETURN ''
END
GO

IF object_id('FSC_ReleaseWorkplace') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_ReleaseWorkplace
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2024-03-15
-- Description:	Uvolnění zaseklého pracoviště
-- =============================================
CREATE PROCEDURE [dbo].FSC_ReleaseWorkplace(@Workplace AS VARCHAR(24))

AS
BEGIN
--DECLARE @Workplace AS VARCHAR(24) = '9778'
DECLARE @RepeatCount AS Integer=3

DECLARE @WPState AS NVARCHAR(20)
DECLARE @WorkplaceId AS UniqueIdentifier 

SELECT TOP 1 @WorkplaceId=WorkplaceId,@WPState=State FROM $(MonitorDB).dbo.Workplace WITH(NOLOCK) WHERE Number = @Workplace AND Deleted=0


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
	UPDATE $(MonitorDB).[dbo].[Workplace] SET Deleted=1 WHERE WorkplaceId=@WorkplaceId
	--COMMIT TRANSACTION

	WAITFOR DELAY '00:00:50'
	--BEGIN Transaction
	UPDATE $(MonitorDB).[dbo].[Workplace] SET Deleted=0 WHERE WorkplaceId=@WorkplaceId
	--COMMIT TRANSACTION
	SELECT 'I am waiting 30 seconds for ServiceSync' AS Report
	WAITFOR DELAY '00:00:30'
	SET @WPState =(SELECT State FROM $(MonitorDB).dbo.Workplace WITH(NOLOCK) WHERE WorkplaceId=@WorkplaceId)
	IF @WPState<>'Free' UPDATE $(MonitorDB).[dbo].[Agent] SET WorkplaceId=NULL WHERE WorkplaceId =  @WorkplaceId

	SELECT 'Workplace has status= '+@WPState AS Report

  END
 END
GO



IF object_id('FSC_EmailsHaveOffAg') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_EmailsHaveOffAg
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2024-01-15
-- Description:	Kontrola mailů u agentů Offline
-- =============================================
CREATE FUNCTION [dbo].FSC_EmailsHaveOffAg()
RETURNS nvarchar(200)
AS
BEGIN
	declare @WeekAgo as datetime = DATEADD(DAY, -7, GETDATE())
	-- Kontrola mailů přidělených agentům, kteří nejsou v práci
    IF (.dbo.CustomCheck('NV',@WeekAgo)>0)
	   RETURN 'emails assigned to agents who are not at work.'

RETURN ''
END
GO

IF object_id('FSC_IsZero') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_IsZero
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2024-01-15
-- Description:	Omezení testovacích výpočtů v podkladových dotazech
-- =============================================

CREATE FUNCTION [dbo].[FSC_IsZero] (
    @Number FLOAT,
    @IsZeroNumber FLOAT
)
RETURNS FLOAT
AS
BEGIN

    IF (@Number = 0)
    BEGIN
        SET @Number = @IsZeroNumber
    END

    RETURN (@Number)

END
GO
	
IF object_id('CorrectFin') IS NOT NULL
 DROP  FUNCTION  [dbo].CorrectFin
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2024-04-03
-- Description:	Analýza Eventlogu
-- =============================================
CREATE FUNCTION [dbo].CorrectFin()
RETURNS nvarchar(200)
AS
BEGIN
 declare @Now as datetime = GETDATE()
 declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
 declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Now )
 DECLARE @Procedura AS NVARCHAR(50) = (
SELECT  TOP 1 EL1.Procedura  FROM .[dbo].[Eventlog] EL1 WITH (NOLOCK)
 LEFT JOIN .[dbo].[Eventlog] EL2 WITH (NOLOCK) ON EL1.Procedura=EL2.Procedura AND EL2.DatumCas>=EL1.DatumCas AND 
    EL2.Popis IN ('Konec procedury','End of procedure','End of procedure (from inspection)')
  WHERE EL1.DatumCas>@Yesterday AND EL1.DatumCas<@Pred15min AND EL1.Popis IN ('Vstupní bod','Entry point')
    AND EL2.DatumCas IS NULL)

 IF  (@Procedura IS NOT NULL)
		RETURN 'Procedure '+@Procedura+' was not finished correctly!'
RETURN ''
END
GO

	

	
IF object_id('SystemTest') IS NOT NULL
 DROP  FUNCTION  [dbo].SystemTest
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-11-21
-- Description:	Analýza Eventlogu
-- =============================================
CREATE FUNCTION [dbo].SystemTest()
RETURNS nvarchar(200)
AS
BEGIN
 declare @Now as datetime = GETDATE()
 declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
 declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Now )
 DECLARE @Procedura AS NVARCHAR(50), @Popis AS NVARCHAR(50)
  SELECT TOP 1 @Procedura=Procedura,@Popis=Popis  FROM .[dbo].[Eventlog] WITH (NOLOCK)
  WHERE DatumCas>@Yesterday /*AND DatumCas<@Pred15min*/ AND Procedura='SystemTests'
   ORDER BY DatumCas DESC
 IF  (@Popis IS NOT NULL)
		RETURN @Popis
RETURN ''
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

IF object_id('FSC_RepairMess') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_RepairMess]
GO

CREATE  PROCEDURE [dbo].[FSC_RepairMess]
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 29.7.2024
-- Description:	Provádí napravu chybnych zaznamu v Message
-- =============================================
BEGIN
DECLARE @LimTime AS dateTime = GETDATE()-5, @LimTime2 AS dateTime = GETDATE()-100
  	 UPDATE $(MonitorDB).dbo.Message  
SET  MessagePhase='Closed',Mark=7
   WHERE Direction='O' AND MessagePhase='Scheduled' AND MessageResult='Closed'
    AND TimeUTC < @LimTime

  	 UPDATE $(MonitorDB).dbo.Message  
SET  MessagePhase='Closed', MessageResult='Closed',Mark=8
   WHERE Direction='O' AND MessagePhase='Scheduled'
    AND TimeUTC < @LimTime2

  	 UPDATE $(MonitorDB).dbo.Message  
SET  MessageResult='Active'
   WHERE Direction='O' AND MessagePhase='Scheduled' AND MessageResult='Closed'
    AND TimeUTC >= @LimTime

	 UPDATE $(MonitorDB).dbo.Message  
SET  MessagePhase='Failed', MessageResult='Closed',Mark=9
   WHERE Direction='O' AND MessageResult='Active' AND MessagePhase='Scheduled'
    AND TimeUTC >= @LimTime2 AND TimeUTC < @LimTime


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
	EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis

  EXEC .[dbo].[FSC_Daily_Maintenance]
  EXEC .[dbo].[FSC_DelEventlog]
  EXEC .[dbo].[FSC_CustMaintenance]
  EXEC $(MonitorDB).[dbo].FSC_IndexReorganize
  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, 'End of procedure'
END 

GO

IF object_id('FSC_DelDuplIndexes') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_DelDuplIndexes]
GO

CREATE  PROCEDURE [dbo].[FSC_DelDuplIndexes]
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 4.1.2024
-- Description:	Maže duplicitní index Frontstage
-- =============================================
BEGIN
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'ContactComposition','UQ_PhoneBookId_ContactId','UQ_ContactComposition_PhoneBookId_ContactId'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'Skill','UQ_AgentId_ProjectId','UQ_Skill_AgentId_ProjectId'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'GdprSensitivity','UQ_Sensitivity','UQ_GdprSensitivity_Sensitivity'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'PhaseTransition','UQ_FromPhaseId_ToPhaseId','UQ_PhaseTransition_FromPhaseId_ToPhaseId'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'Portal','UQ_HashPage','UQ_Portal_HashPage'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'BusyConditionRule','UQ_CommCh_AgentCh','UQ_BusyConditionRule_CommCh_AgentCh'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'CrewMember','UQ_CrewId_AgentId','UQ_CrewMember_CrewId_AgentId'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'GdprEvidence','AX_GdprEvidence_GdprEvidenceId','PK_GdprEvidence'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'Perso','UQ_AgentId_Profile_RefName_RefId_CtxId','UQ_Perso_AgentId_Profile_RefName_RefId_CtxId'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'PhoneComposition','UQ_PhoneBookId_PhoneNumberId','UQ_PhoneComposition_PhoneBookId_PhoneNumberId'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'Proficiency','UQ_AgentId_LanguageId','UQ_Proficiency_AgentId_LanguageId'
	EXEC $(MonitorDB).[dbo].[FSC_DelDuplIndex] 'Queue','UQ_CommId','UQ_Queue_CommId'

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
SELECT  TOP 1 EL1.Procedura  FROM .[dbo].[Eventlog] EL1 WITH (NOLOCK)
 LEFT JOIN .[dbo].[Eventlog] EL2 WITH (NOLOCK) ON EL1.Procedura=EL2.Procedura AND EL2.DatumCas>EL1.DatumCas AND 
    EL2.Popis IN ('Konec procedury','End of procedure','End of procedure (from inspection)')
  WHERE EL1.DatumCas>@Yesterday AND EL1.DatumCas<@Pred15min AND EL1.Popis IN ('Vstupní bod','Entry point')
    AND EL2.DatumCas IS NULL)

 IF  (@Procedura IS NOT NULL)
   BEGIN
     EXEC  .[dbo].[WriteEvent] 1,@Procedura,'End of procedure (from inspection)'   
   END
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
 declare @Now as datetime = GETDATE()
 declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
 declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Now )
 DECLARE @Procedura AS NVARCHAR(50), @Popis AS NVARCHAR(50)
  SELECT TOP 1 @Procedura=Procedura,@Popis=LEFT(Popis,7) FROM .[dbo].[Eventlog] WITH (NOLOCK)
  WHERE DatumCas>@Yesterday /*AND DatumCas<@Pred15min*/ AND Procedura='SystemTests'
   ORDER BY DatumCas DESC
 IF  (@Popis IS NOT NULL)
   BEGIN
 	 UPDATE [dbo].[Eventlog]
		 SET [Procedura] = 'STProcessed'
		WHERE DatumCas>@Yesterday AND Procedura='SystemTests' AND Popis LIKE @Popis+'%' --DatumCas=@DatumCas
    
   END
END 

GO


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
	 DECLARE @to AS datetime=GETDATE()
	 DECLARE @fromLW AS datetime=DATEADD(week,-1,@from)
	 DECLARE @toLW AS datetime=DATEADD(week,-1,@to)
	 DECLARE @SecondsWithoutAnswer AS Integer
	 DECLARE @NewNotAnswered AS Integer
	 DECLARE @MAXanswertime AS datetime
	 DECLARE @InboundCallId AS UNIQUEIDENTIFIER

IF .dbo.FSC_IsHoliday(GETDATE(),@HolidayGroupName)=0
  AND
    @from>.dbo.fsc_StartWorkTime() -- Uplynul již tolerovaný počet minut od začátku pracovní doby?
  AND
	 NOT EXISTS(SELECT TOP 1 1 FROM $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK) 
		   WHERE PilotTime>@from AND PilotTime<@To )
  AND
			   -- Ještě se podívám na minulý týden
		   EXISTS(SELECT TOP 1 1 FROM $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK) 
		   WHERE PilotTime>@fromLW AND PilotTime<@ToLW )
  AND
   -- Pokud není nikdo v práci po začátku pracovní doby, může jít o odstávku - nebudu posílat alarm:
   (EXISTS(SELECT TOP 1 1 FROM $(MonitorDB).[dbo].[Agent] WITH(NOLOCK) WHERE Activity<>'Logoff') OR DATEPART(Hour,GETDATE())<9)
    BEGIN
	  -- Ještě zjistím, kolik uplynulo od  posledního hovoru
	  SET @from = (SELECT TOP 1 PilotTime FROM $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK)  ORDER BY PilotTime DESC)
	  SET @Minutes=DATEDIFF(Minute,@from,@to)
	  RETURN 'No inbound Call in last '+CONVERT(NVARCHAR(2),@Minutes)+' minutes - Error'
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
	 (select count(1) from $(MonitorDB).dbo.callevent WITH(NOLOCK) 
	   where Timelocal>@from AND eventtype = 'error' AND inboundcallid is not null) 
	 DECLARE @NewInBoundCals AS Integer=
	 (select count(1) from $(MonitorDB).dbo.InboundCall WITH(NOLOCK) where TimeUTC>@fromUTC)

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

IF .dbo.FSC_IsHoliday(GETDATE(),@HolidayGroupName)=0
  BEGIN
    SELECT 
	   @MAXanswertime=ISNULL(MAXanswertime,@from)
	   ,@MAXServedtime=ISNULL(MAXServedtime,@from)
       ,@SecondsWithoutAnswer=DATEDIFF(ss,IIF(ISNULL(MAXServedtime,@from)>ISNULL(MAXanswertime,@from),ISNULL(MAXServedtime,@from),ISNULL(MAXanswertime,@from)),MAXPilotTime) 
	   ,@NewNotAnswered=(SELECT COUNT(1) FROM $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK) 
	   WHERE PilotTime>IIF(ISNULL(MAXServedtime,@from)>ISNULL(MAXanswertime,@from),ISNULL(MAXServedtime,@from),ISNULL(MAXanswertime,@from))
	    AND PilotTime<@To AND NOT (AnswerTime IS NOT NULL OR CallResult='Served')
	   ) 
	   FROM
 (SELECT TOP 100 
	   MAX(PilotTime) AS MAXPilotTime
	   ,MAX(answertime) AS MAXanswertime
	   ,MAX(IIF(CallResult='Served',EndTime,@from)) AS MAXServedtime
   FROM $(MonitorDB).[dbo].[InboundCall] IC WITH(NOLOCK)  
  WHERE 1=1
    AND PilotTime>@from AND PilotTime<@To ) AS Phase1

	 IF @SecondsWithoutAnswer > @Minutes*60 AND @NewNotAnswered>2
	   BEGIN
	     SET @MAXReacttime=IIF(@MAXanswertime>@MAXServedtime,@MAXanswertime,@MAXServedtime)
	     SET @InboundCallId = (SELECT TOP 1 InboundCallId FROM $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK) 
		 WHERE PilotTime>@MAXReacttime AND CallResult<>'Active' ORDER BY TimeUTC DESC)
	     IF  @InboundCallId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM $(MonitorDB).[dbo].[CallEvent] WITH(NOLOCK)   
          WHERE InboundCallId =@InboundCallId AND TimeLocal> @MAXReacttime AND
		  (EventType='ScenarioResult' AND ReferenceData='Completed' OR ResultData='Served'))
		    AND
			   -- Ještě se podívám na minulý týden
		   NOT EXISTS(SELECT TOP 1 1 FROM $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK) 
		   WHERE PilotTime>@fromLW AND PilotTime<@ToLW AND AnswerTime IS NULL AND CallResult<>'Served')

	   RETURN CONVERT(NVARCHAR(5),@NewNotAnswered)+' not handled inbound Calls '+CONVERT(NVARCHAR(5),@SecondsWithoutAnswer)
	   +' seconds - error'
	        
	   END
  END
RETURN ''
END

GO
	    
IF object_id('CPU') IS NOT NULL
 DROP  FUNCTION  [dbo].CPU
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Kontrola vytížení CPU
-- =============================================
CREATE FUNCTION [dbo].CPU ()
RETURNS nvarchar(200)
AS
BEGIN
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
		RETURN 'The average CPU load for the last hour is '+convert(NVARCHAR(3),@AVGCPU)+'%'
RETURN ''
END

GO
	
IF object_id('AutoTest') IS NOT NULL
 DROP  FUNCTION  [dbo].AutoTest
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-10-24
-- Description:	Autotest kontrolní funkce
-- =============================================
CREATE FUNCTION [dbo].AutoTest ()
RETURNS nvarchar(200)
AS
BEGIN
 DECLARE @TestDuration AS Int, @Displayname AS NVARCHAR(50)
 SELECT TOP 1
      @TestDuration=ExecDuration,@Displayname=Displayname
     FROM .dbo.Monitor
        WHERE ExecDuration > 10
   IF  (@Displayname IS NOT NULL)
		RETURN @Displayname+' has duration '+convert(NVARCHAR(3),@TestDuration)+' seconds'
RETURN ''
END

GO
	    
IF object_id('DBLocks') IS NOT NULL
 DROP  FUNCTION  [dbo].DBLocks
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Kontrola zámků na DB
-- =============================================
CREATE FUNCTION [dbo].DBLocks (@ResStat AS Bit)
RETURNS nvarchar(200)
AS
BEGIN
 DECLARE @max_wait_time_ms AS Integer=(SELECT  TOP 1 max_wait_time_ms FROM sys.dm_os_wait_stats AS WS WHERE WS.waiting_tasks_count > 0 AND WS.wait_type LIKE 'LCK_%' AND max_wait_time_ms > 30000)/1000
   IF @max_wait_time_ms IS NOT NULL 
	  BEGIN -- Nechci hlásit pozůstatky noční údržby
	    IF DATEPART(hour, GETDATE())>7
		  RETURN 'There are locks lasting '+CONVERT(NVARCHAR(4),@max_wait_time_ms)+' seconds on SQL Server ' --+ @wait_type
        ELSE
		  RETURN 'RUNPROC'
      END 
RETURN ''
END

GO

   
IF object_id('FSC_ProjRuleInCalls') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_ProjRuleInCalls
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Kontrola Project rule of inbound calls
-- =============================================
CREATE FUNCTION [dbo].FSC_ProjRuleInCalls ()
RETURNS nvarchar(200)
AS
BEGIN
	 DECLARE @String1 AS NVARCHAR(50)
	 DECLARE @String2 AS NVARCHAR(50)

SELECT TOP 1 @String1=PC.[DisplayName],@String2=PR.DisplayName FROM $(MonitorDB).[dbo].[ProjectCondition] PC WITH (NOLOCK)
  LEFT JOIN $(MonitorDB).[dbo].[Project] PR WITH (NOLOCK) ON PC.ProjectId=PR.ProjectId
  WHERE  PR.ProjectId IS  NULL OR PR.Deleted=1
 IF @String2 IS NOT NULL
   RETURN 'Project rule of inbound calls '+@String1+' uses bad / deleted project '+@String2
RETURN ''
END

GO

  
IF object_id('FSC_IssueCond') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_IssueCond
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-04-18
-- Description:	 Kontrola chyb v IssueCondition:
-- =============================================
CREATE FUNCTION [dbo].FSC_IssueCond ()
RETURNS nvarchar(200)
AS
BEGIN
	 DECLARE @String1 AS NVARCHAR(50)
	 DECLARE @String2 AS NVARCHAR(50)

 SELECT TOP 1 @String1=ISUC.[DisplayName],@String2=TPC.DisplayName FROM $(MonitorDB).[dbo].[IssueCondition] ISUC WITH (NOLOCK)
  LEFT JOIN $(MonitorDB).[dbo].[Topic] TPC WITH (NOLOCK) ON TPC.TopicId=ISUC.NormalTopicId
  WHERE ISUC.NormalTopicId IS NOT NULL AND TPC.TopicId IS  NULL OR TPC.Deleted=1
 IF @String2 IS NOT NULL
   RETURN 'Issue rule '+@String1+' uses bad / deleted topic '+@String2
RETURN ''
END

GO

IF object_id('FSC_MessageDisp') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_MessageDisp
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-05-10
-- Description:	Kontrola chyb MessageDisp
-- =============================================
CREATE FUNCTION [dbo].FSC_MessageDisp()
RETURNS nvarchar(200)
AS
BEGIN
	 DECLARE @String1 AS NVARCHAR(50)=(
SELECT TOP 1 [ConfigurationValue] FROM $(MonitorDB).[dbo].[Configuration] WITH(NOLOCK) WHERE ConfigurationName='XssMessageDisp')
  IF @String1 ='Protect'
   RETURN 'XssMessageDisp=Protect'
RETURN ''
END

GO

IF object_id('FSC_MessageInsp') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_MessageInsp
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2024-07-08
-- Description:	Kontrola zpráv
-- =============================================
CREATE FUNCTION [dbo].FSC_MessageInsp()
RETURNS nvarchar(200)
AS
BEGIN
 DECLARE @Result AS nvarchar(200)=''
 DECLARE @LimTime1 AS dateTime = DATEADD(Minute,-10,GETDATE()), @LimTime2 AS dateTime = DATEADD(Minute,-10,GETUTCDATE())
 DECLARE @Messageid AS UniqueIdentifier
 SELECT TOP 1 @Messageid=Messageid FROM $(MonitorDB).[dbo].[Message] ME
 	LEFT JOIN $(MonitorDB).dbo.Campaign as CMP with (NOLOCK) on ME.CampaignId=CMP.CampaignId 
	LEFT JOIN $(MonitorDB).dbo.CampaignImport as CI with (NOLOCK) on ME.CampaignImportId=CI.CampaignImportId 

  WHERE MessagePhase='Scheduled' AND (ME.ScheduledTime<@LimTime1 OR (ScheduledTime IS NULL AND ME.TimeUtc<@LimTime2))
   AND ISNULL(CMP.Activity,'Scheduled')='Scheduled' AND ISNULL(CI.Active,1)=1
  IF @Messageid IS NOT NULL
   SET @Result= 'MessageId='+CONVERT(NVARCHAR(40), @Messageid)+' is more than 10 minutes in Scheduled status!'
   
RETURN @Result
END

GO

IF object_id('FSC_Triggers') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_Triggers
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-04-06
-- Description:	Kontrola chyb v Triggers:
-- =============================================
CREATE FUNCTION [dbo].FSC_Triggers()
RETURNS nvarchar(200)
AS
BEGIN
	 DECLARE @String1 AS NVARCHAR(50)=(
SELECT TOP 1 ATr.DisplayName
FROM (
SELECT 
     COUNT(1) AS Pocet
    ,[Model]
    ,[ReferenceKey]
 FROM $(MonitorDB).[dbo].[ActionTrigger] WITH(NOLOCK) 
   WHERE Deleted=0 AND Suspended=0 AND Model NOT IN ('Interval','Manual','PeriodDay','PeriodMonth','ManualText')
    GROUP BY Model,ReferenceKey) AS Phase1
  INNER JOIN $(MonitorDB).[dbo].[ActionTrigger] ATr WITH (NOLOCK) ON ATr.Model=Phase1.Model AND ATr.ReferenceKey=Phase1.ReferenceKey
	WHERE Pocet>1 
	)
  IF @String1 IS NOT NULL
   RETURN 'Action Trigger '+@String1+' has duplicate model and ReferenceKey.'
RETURN ''
END

GO

IF object_id('FSC_GWCond') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_GWCond
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-04-05
-- Description:	Kontrola chyb v GatewayCondition:
-- =============================================
CREATE FUNCTION [dbo].FSC_GWCond()
RETURNS nvarchar(200)
AS
BEGIN
	 DECLARE @String1 AS NVARCHAR(50)
	 DECLARE @String2 AS NVARCHAR(50)

 SELECT TOP 1 @String1=GWC.[DisplayName],@String2=GW.DisplayName 
   FROM $(MonitorDB).[dbo].GatewayCondition GWC WITH (NOLOCK)
  LEFT JOIN $(MonitorDB).[dbo].[Gateway] GW WITH (NOLOCK) ON GW.GatewayId=GWC.GatewayId
  WHERE GWC.GatewayId IS NOT NULL AND (GW.GatewayId IS  NULL OR GW.Deleted=1)
 IF @String2 IS NOT NULL
   RETURN 'Gateway Condition '+@String1+' uses bad / deleted Gateway '+@String2
RETURN ''
END

GO
IF object_id('FSC_WPDown') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_WPDown
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Kontrola odhlašování agenta díky poruše pracoviště 
-- =============================================
CREATE FUNCTION [dbo].FSC_WPDown()
RETURNS nvarchar(200)
AS
BEGIN
 DECLARE @AgentName AS NVARCHAR(50)
 DECLARE @Pocet AS Integer
 DECLARE @Number AS NVARCHAR(24)
 DECLARE @LimTime AS Datetime= DATEADD(Hour,-2,GETDATE())
	
 SELECT Top 1 @AgentName =AgentName,@Pocet=Pocet,@Number=Number FROM (
	SELECT TOP (10) AG.DisplayName AS AgentName,COUNT(1) AS Pocet
	  ,WP.Number
    FROM $(MonitorDB).[dbo].[AgentEvent] AE  WITH(NOLOCK) 
	LEFT JOIN $(MonitorDB).[dbo].[Agent] AG WITH (NOLOCK) ON AG.AgentId=AE.AgentId
	LEFT JOIN $(MonitorDB).dbo.Workplace WP WITH (NOLOCK) ON WP.WorkplaceId=AG.WorkplaceId
    WHERE EventType='AgentStatus' AND TimeLocal > @LimTime AND ReferenceData='Logoff' 
	AND Actor='Distribution' AND AE.ResultData='Phone'
	GROUP BY AG.DisplayName,WP.Number) AS Phase1
	  ORDER BY Pocet DESC
   IF @Pocet > 2 
     RETURN 'Agent '+@AgentName+' is logged out. Extension '+@Number+' seems to be down.'
RETURN ''
END

GO

IF object_id('FSC_PermanentLogin') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_PermanentLogin
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Kontrola trvale přihlášených agentů
-- =============================================
CREATE FUNCTION [dbo].FSC_PermanentLogin ()
RETURNS nvarchar(200)
AS
BEGIN
DECLARE @AgentName AS NVARCHAR(50)
DECLARE @Agentid AS UniqueIdentifier
DECLARE @workplaceid AS UniqueIdentifier
DECLARE @Activity AS NVARCHAR(20)
DECLARE @AgentwWasLogoff AS NVARCHAR(200)='Agent %s was logged off'
DECLARE @AgentNotReady AS NVARCHAR(200)='Agent %s that should be permanently logged on is not ready right now'


SELECT TOP 1 @Agentid=AgentId,@workplaceid = workplaceid,@Activity = Activity  
 FROM $(MonitorDB).dbo.Agent  WITH(NOLOCK) WHERE Description LIKE '%permanent login%' AND Activity<>'Ready' 
IF @Agentid IS NOT NULL
  BEGIN
	  IF @workplaceid IS NULL
		RETURN 'Agent '+@AgentName+' was logged off'
  	  IF @Activity<>'PostCall'
		RETURN 'Agent '+@AgentName+' that should be permanently logged on is not ready right now'
  END
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
 (SELECT TOP 1 AgentId FROM $(MonitorDB).[dbo].[Agent] WITH(NOLOCK) where TeamName='ADMIN' AND WorkplaceId IS NOT NULL AND DATEDIFF(Hour,LastRefreshUtc,GETUTCDATE())>4)
  IF @AgentId IS NOT NULL
    BEGIN
      DECLARE @WorkplaceId AS UniqueIdentifier =(SELECT TOP 1 WorkPlaceId FROM $(MonitorDB).[dbo].[Agent] WITH(NOLOCK) where AgentId=@AgentId)
      DECLARE @TimeUTC as Datetime = (SELECT TOP 1 TimeUTC FROM $(MonitorDB).[dbo].[AgentEvent] WITH(NOLOCK) where EventType='AgentStatus' AND AgentId=@AgentId ORDER BY EventType,AgentId,TimeUTC DESC)
	  IF DATEDIFF(Hour,@TimeUTC,GETUTCDATE())>4 AND EXISTS (SELECT TOP 1  AG.[AgentId] FROM $(MonitorDB).[dbo].[Seating] AS SEA WITH (NOLOCK) 
        INNER JOIN $(MonitorDB).[dbo].[Agent] AS AG WITH (NOLOCK) ON SEA.AgentId=AG.AgentId WHERE SEA.WorkPlaceId=@WorkplaceId AND AG.TeamName<>'ADMIN')
	    BEGIN
		  DECLARE @AgentName AS NVARCHAR(100) = RTRIM((SELECT TOP 1 DisplayName FROM $(MonitorDB).[dbo].[Agent] WITH(NOLOCK) where AgentId=@AgentId))
          RETURN 'Admin '+@AgentName+' was logged on and blocked workplace agents.'
        END
     END
  RETURN ''
END

GO

IF object_id('FSC_LogLevelInspect') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_LogLevelInspect
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-01-04
-- Description:	Kontrola logování:
-- =============================================
CREATE FUNCTION [dbo].FSC_LogLevelInspect ()
RETURNS nvarchar(200)
AS
BEGIN
   RETURN (SELECT TOP 1 'IvrScriptLogLevel=All'
  FROM $(MonitorDB).[dbo].[Configuration] WITH(NOLOCK) 
  WHERE ConfigurationName='IvrScriptLogLevel' AND ConfigurationValue='All')

END

GO
 
IF object_id('FSC_IVRInspect') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_IVRInspect
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Kontrola IVR vstupů na ProServeru:
-- =============================================
CREATE FUNCTION [dbo].FSC_IVRInspect ()
RETURNS nvarchar(200)
AS
BEGIN
  DECLARE @WPOK AS NVARCHAR(30) =(SELECT TOP 1 DisplayName FROM $(MonitorDB).[dbo].[IVREntry] WITH (NOLOCK) WHERE OnlineStatus<>0 AND Deleted=0)	  
     IF  @WPOK IS NOT NULL
        RETURN 'IVR input '+@WPOK+' is down'
RETURN ''
END

GO

IF object_id('FSCProsExt') IS NOT NULL
 DROP  FUNCTION  [dbo].FSCProsExt
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Kontrola nefunkčních linek na ProServeru:
-- =============================================
CREATE FUNCTION [dbo].FSCProsExt ()
RETURNS nvarchar(200)
AS
BEGIN
DECLARE @Number AS varchar(16)=
 (SELECT Top 1 [Number] FROM [$(ProServer)].[dbo].[Extension] WITH (NOLOCK) -- OnLineStatus=7 ExtensionIsnotAlive (Vypnutý SP)
  WHERE OnLineStatus<>10 AND OnLineStatus<>0 AND OnLineStatus<>7 AND Deleted=0 AND Suspended=0 AND Description NOT LIKE '%SoftPhone%')
 IF @Number IS NOT NULL
   RETURN 'extension '+@Number+' is not OK on ProServer'
RETURN ''
END

GO

IF object_id('FSCWPsOutOfOrder') IS NOT NULL
 DROP  FUNCTION  [dbo].FSCWPsOutOfOrder
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].FSCWPsOutOfOrder ()
RETURNS nvarchar(200)
AS
BEGIN
  DECLARE @TotalWP AS Integer,@OutOfOrder AS Integer
  SELECT @TotalWP=ISNULL(SUM(1),0) ,
    @OutOfOrder=ISNULL(SUM(CASE WHEN State='OutOfOrder' THEN 1 ELSE 0 END),0)
  FROM $(MonitorDB).[dbo].[Workplace] AS WP WITH (NOLOCK)
   INNER JOIN $(ProServer).[dbo].Extension AS EX WITH (NOLOCK) ON WP.Number COLLATE DATABASE_DEFAULT =EX.Number COLLATE DATABASE_DEFAULT
   INNER JOIN $(ProServer).[dbo].PBX WITH (NOLOCK) ON PBX.PbxId=EX.PbxId
   WHERE WP.Deleted=0
      AND NOT(PBX.DisplayName='AS7' AND EX.OnLineStatus=7)   IF  @TotalWP>0 AND @TotalWP=@OutOfOrder
	 RETURN 'All workplaces are out of order'

  RETURN ''
END

GO



IF object_id('DuplicExt') IS NOT NULL
 DROP  FUNCTION  [dbo].[DuplicExt]
GO
IF object_id('FSCDuplicExt') IS NOT NULL
 DROP  FUNCTION  [dbo].[FSCDuplicExt]
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Duplicate extensions inspection
-- =============================================
CREATE FUNCTION [dbo].FSCDuplicExt ()
RETURNS nvarchar(200)
AS
BEGIN
	IF (SELECT TOP 1 1 ProServer_Extension FROM
             (SELECT 
			  [Number] AS ProServer_Extension
			  ,COUNT(1) AS Pocet
		  FROM $(ProServer).[dbo].[Extension] WITH(NOLOCK) 
		  WHERE Deleted=0 AND Suspended=0
		  GROUP BY Number) AS Phase1
		  WHERE Pocet>1)>0
		    RETURN ' On ProServer is duplicate extension. This will cause it to malfunction.'
  RETURN ''
END

GO
IF object_id('FSCAssignMail') IS NOT NULL
 DROP  FUNCTION  [dbo].FSCAssignMail
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	RecordinLess Calls
-- =============================================
CREATE FUNCTION [dbo].FSCAssignMail()
RETURNS nvarchar(200)
AS
BEGIN
   declare @Last as datetime = DATEADD(MINUTE, -60, GETDATE()) -- Posledních 60minut
   IF EXISTS(SELECT 1 FROM $(MonitorDB).[dbo].[ActionTrigger] WITH(NOLOCK) WHERE Suspended=0 AND Deleted=0 AND CommandText LIKE 'AssignMailOfIssue')
	AND
	  EXISTS(select TOP 1 1 from $(MonitorDB).dbo.Message as M WITH (NOLOCK)
           INNER JOIN $(MonitorDB).dbo.Message as M2 WITH (NOLOCK) ON M.RelatedMessageId=M2.MessageId AND M2.IssueId IS NULL
           where M.Direction='I' AND M.MessageType='Email' AND M.ReceivedSentTime>@Last  AND M.IssueId IS NOT NULL)
        RETURN ' Incoming emails are not assigned to issues (AssignMailOfIssue)'
  RETURN ''
END

GO


IF object_id('FSCNewMessages') IS NOT NULL
 DROP  FUNCTION  [dbo].FSCNewMessages
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Inspect count of new messages
-- =============================================
CREATE FUNCTION [dbo].FSCNewMessages ()
RETURNS nvarchar(200)
AS
BEGIN
declare @Now as datetime = GETDATE()	

declare @Interval as int = 30
declare @Last as datetime = DATEADD(MINUTE, -@Interval, @Now ) -- Posledních 30minut
declare @LastUTC as datetime = DATEADD(MINUTE, -@Interval, GETUTCDATE() ) -- Posledních 30minut
declare @WeekAgo as datetime = DATEADD(DAY, -7, @Now )
declare @LastWeekAgo as datetime = DATEADD(DAY, -7, @Last )
declare @EmlNow as int = (select count(*) AS Now from $(MonitorDB).dbo.Message as M WITH (NOLOCK) 
where M.Direction='I' AND EndTime<=@Now AND EndTime>=@Last AND M.MessageType='Email')
IF @EmlNow=0
  SET @EmlNow = (select count(*) from $(MonitorDB).dbo.Message as M WITH (NOLOCK) where M.Direction='I' AND M.MessageType='Email'
   /*AND M.TimeUtc<=@Now*/ AND M.TimeUtc>=@LastUTC)
declare @EmlWeekAgo as int = (select count(*) AS Lastweek from $(MonitorDB).dbo.Message as M WITH (NOLOCK)
where M.Direction='I' AND EndTime<=@WeekAgo AND EndTime>=@LastWeekAgo AND M.MessageType='Email') 
--declare @EmlWeekAgo as int = (select count(*) from $(MonitorDB).dbo.Message as M WITH (NOLOCK) where M.Direction='I' AND M.MessageType='Email' AND  M.TimeUtc<=@WeekAgo AND M.TimeUtc>=@LastWeekAgo)


	IF  (@EmlNow<@EmlWeekAgo/5 AND (@EmlNow<@EmlWeekAgo-10 OR @EmlNow=0)) AND @EmlWeekAgo>1 
	  AND (@EmlNow=0 OR (SELECT COUNT(1) FROM $(MonitorDB).dbo.Gateway WITH(NOLOCK)  WHERE Direction IN ('I','B') AND Deleted=0)>1)
	 BEGIN
	  
	    --SET @EmlMsg = 'T=' + @T + ' E-now='+ CONVERT(nvarchar(10),@EmlNow) + ' E-weekago=' + CONVERT(nvarchar(10),@EmlWeekAgo)
		-- Možná byl minulý týden výjimečný - tak porovnám ještě údaje před dvěma týdny
		declare @Eml2WeeksAgo as int = (select count(*) from $(MonitorDB).dbo.Message as M WITH (NOLOCK) where M.Direction='I' AND M.MessageType='Email' 
		  AND  M.TimeUtc<=DATEADD(Day,-7,@WeekAgo) AND M.TimeUtc>=DATEADD(Day,-7,@LastWeekAgo))
        IF (@EmlNow<@Eml2WeeksAgo AND @Eml2WeeksAgo>1 AND (@EmlNow<@Eml2WeeksAgo-10 OR @EmlNow=0))
		  BEGIN		 
		    --SET @Specif = CONVERT(nvarchar(10),@EmlNow)
			--SET @Severity =CASE WHEN @EmlNow=0 THEN 10 ELSE 0 END
		    RETURN 'low count of incomming emails '+CONVERT(NVARCHAR(5),@EmlNow)
		  END
	
	 END


RETURN ''
END

GO

-------------------------------------------------------------
IF object_id('FSC_SET_Oauth2') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_SET_Oauth2]
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- alter date: <27.10.2023>
-- Description:	<Nastavuje bránu EWS Oauth2>
-- =============================================
CREATE PROCEDURE [dbo].[FSC_SET_Oauth2]

AS
BEGIN
-- EWSHost {"HostAddress": "outlook.office365.com",   "UserName": "info@company.sk",   "ClientID": "XXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX",   "Password": "Secret-Password",   "AccessToken": "https://login.microsoftonline.com/XXXXXX-XXXXX-XXXX-XXXX-XXXXXXXXX/oauth2/v2.0/token",   "ReportParam": "https://outlook.office365.com/.default",   "AuthType": "OAuth20",   "Throttling": 5}
DECLARE @GatewayId AS UNIQUEIDENTIFIER=(SELECT TOP 1 GatewayId FROM $(MonitorDB)..Gateway WHERE Deleted=0 
   and Description='EWS/Oauth2' AND ISNULL(InDevice,'') = '' AND ISNULL(OutDevice,'') = ''  
 )
  DECLARE @TemplateGWiD AS UNIQUEIDENTIFIER =(SELECT TOP 1 GatewayId FROM $(MonitorDB)..Gateway WHERE Deleted=0 
   and inDevice LIKE '%OAuth20%') 
  DECLARE @Device AS NVARCHAR(MAX)=(SELECT InDevice FROM $(MonitorDB).dbo.Gateway WHERE GatewayId=@TemplateGWiD)
  DECLARE @StartPos AS Integer=CHARINDEX('UserName', @Device)
  DECLARE @TestString AS NVARCHAR(MAX)=SUBSTRING(@Device,@StartPos,100)
  SET @StartPos=CHARINDEX(':', @TestString)+1
  SET @TestString= SUBSTRING(@TestString,@StartPos,100)
  SET @StartPos=CHARINDEX('"', @TestString)+1
  SET @TestString=SUBSTRING(@TestString,@StartPos,100)
  SET @StartPos=CHARINDEX('"', @TestString)

  DECLARE @TemplateUsr AS NVARCHAR(100) = --'info@planeo.sk'
  SUBSTRING(@TestString,1,@StartPos-1)
  --SELECT @StartPos,@TemplateUsr
 -- SELECT @GatewayId AS GatewayId,@TemplateGWiD AS TemplateGWiD
--  IF @GatewayId IS NOT NULL AND 1=1
 -- EXEC fs_ custom.[dbo].SET_Oauth2 @GatewayId,@TemplateGWiD,'info@planeo.sk'

DECLARE @PilotAddress AS NVARCHAR(512)=RTRIM((SELECT PilotAddress FROM $(MonitorDB).dbo.Gateway WHERE GatewayId=@GatewayId))

SET @Device=REPLACE(@Device,@TemplateUsr,@PilotAddress)

IF @Device IS NOT NULL AND @TemplateUsr IS NOT NULL AND @PilotAddress IS NOT NULL
	UPDATE $(MonitorDB).dbo.Gateway
	SET InDevice=@Device,OutDevice=@Device
	WHERE  GatewayId=@GatewayId 

--SELECT @PilotAddress AS PilotAddress, @Device AS Device
 	RETURN 
END

GO


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

  INSERT INTO $(MonitorDB).dbo.IVRstep
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
  FROM $(MonitorDB).[dbo].[IvrStep] WITH(NOLOCK) WHERE IvrStepId=@IVRStepId
 
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
 (SELECT TOP 1 AgentId FROM $(MonitorDB).[dbo].[Agent] WITH(NOLOCK) where TeamName='ADMIN' AND WorkplaceId IS NOT NULL AND DATEDIFF(Hour,LastRefreshUtc,GETUTCDATE())>4)
  IF @AgentId IS NOT NULL
    BEGIN
    DECLARE @WorkplaceId AS UniqueIdentifier =(SELECT TOP 1 WorkPlaceId FROM $(MonitorDB).[dbo].[Agent] WITH(NOLOCK)  where AgentId=@AgentId)
    DECLARE @TimeUTC as Datetime = (SELECT TOP 1 TimeUTC FROM $(MonitorDB).[dbo].[AgentEvent] WITH(NOLOCK)  where EventType='AgentStatus' AND AgentId=@AgentId ORDER BY EventType,AgentId,TimeUTC DESC)
	IF DATEDIFF(Hour,@TimeUTC,GETUTCDATE())>4 AND EXISTS (SELECT TOP 1  AG.[AgentId] FROM $(MonitorDB).[dbo].[Seating] AS SEA WITH (NOLOCK) 
      INNER JOIN $(MonitorDB).[dbo].[Agent] AS AG WITH (NOLOCK) ON SEA.AgentId=AG.AgentId WHERE SEA.WorkPlaceId=@WorkplaceId AND AG.TeamName<>'ADMIN')
	    BEGIN
          EXEC .dbo.FSC_LogOffAgent @AgentId
          EXEC  .[dbo].[WriteEvent] 1,'FSC_LogOffAdmin','Admin was logged off.'
        END
   END
END

GO


IF object_id('FSC_LogOnAgent') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_LogOnAgent
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Přihlášení permanentního agenta
-- =============================================
CREATE PROCEDURE [dbo].FSC_LogOnAgent

AS
BEGIN
DECLARE @Agentid AS UniqueIdentifier
DECLARE @workplaceid AS UniqueIdentifier
DECLARE @Statusid AS UniqueIdentifier

SELECT TOP 1 @Agentid=AgentId,@workplaceid = workplaceid 
 FROM $(MonitorDB).dbo.Agent  WITH(NOLOCK) WHERE Description LIKE '%permanent login%' AND Activity<>'Ready' 
IF @Agentid IS NOT NULL AND @workplaceid IS NULL
  BEGIN -- Agent je odhlášený, tak jej musí zpět přihlásit
	SET @Statusid = (SELECT TOP 1 [StatusId] FROM $(MonitorDB).[dbo].[Status] WITH(NOLOCK) WHERE Activity='Ready')
	SET @workplaceid = (SELECT TOP 1 workplaceid FROM $(MonitorDB).dbo.InboundCall  WITH(NOLOCK) WHERE AgentId=@Agentid
	                    ORDER BY PilotTime DESC)
    UPDATE $(MonitorDB).dbo.Agent
         SET  Activity='Ready', Statusid=@Statusid, workplaceid=@workplaceid WHERE AgentId=@Agentid
    insert into $(MonitorDB).dbo.AgentEvent([TimeUtc],[TimeLocal],[EventType],[AgentId],[WorkplaceId],[ReferenceData])
		        values(GETUTCDATE(),GETUTCDATE(),'AgentLogon',@Agentid,@workplaceid,'AUTOMAT')
  END
END

GO

IF object_id('Stat_Res') IS NOT NULL
 DROP  PROCEDURE  [dbo].[Stat_Res]
GO

CREATE  PROCEDURE [dbo].[Stat_Res]
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 25.05.2023
-- Description:	Resetuje statistiky
-- =============================================
BEGIN
  DBCC SQLPERF("sys.dm_os_wait_stats",CLEAR) -- RESET Statistiky
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
  DECLARE @Direction AS NVARCHAR(1) = (SELECT TOP 1 [Direction] FROM $(MonitorDB).[dbo].[Gateway] WITH(NOLOCK) WHERE GatewayId=@GatewayId)
  DECLARE @PPilotAddress AS NVARCHAR(200) = (SELECT TOP 1 PilotAddress FROM $(MonitorDB).[dbo].[Gateway] WITH(NOLOCK) WHERE GatewayId=@GatewayId)
  DECLARE @InspectAddress as nvarchar(200) =.dbo.GiveParam('TOCC')
  DECLARE @RemoteAddress AS NVARCHAR(100) = IIF(@Direction='O',@InspectAddress,@PPilotAddress)
		 ,@TestId AS UniqueIdentifier = (SELECT TOP 1 GatewayId FROM $(MonitorDB).[dbo].[Gateway] WITH(NOLOCK) WHERE Direction IN ('B','O'))
  SET @GatewayId=IIF(@Direction='I',@TestId,@GatewayId)
  EXEC [dbo].[FSC_Write_Mail] @GatewayId,@RemoteAddress, 'FSL1: Test','Test' -- Odeslání testovacího mailu
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
FROM $(MonitorDB).dbo.DataQueryColumn DQC  
  inner join $(MonitorDB).dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
  LEFT JOIN $(MonitorDB).dbo.[Portal] PRT WITH (NOLOCK) ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
WHERE DQ.Deleted=0 AND PRT.NAVGroup='AdminPageNav'
	AND DQ.QueryGroup IN ('Admin','Kontakty','Supervizor')  AND DQC.DisplayName NOT LIKE '$%'
	AND  DQC.DisplayName=@OldName 

END

GO

IF object_id('NotRegistered') IS NOT NULL
 DROP  FUNCTION  [dbo].NotRegistered
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <6.9.2022>
-- Description:	<vrací počet nezaregistrovaných poboček>
-- =============================================
CREATE FUNCTION [dbo].[NotRegistered]
(
)
RETURNS Integer
AS
BEGIN
	RETURN (select count(*) AS Pocet from $(ProServer).dbo.extension EX WITH(NOLOCK) 
       where EX.Deleted=0 AND Suspended=0 AND OnLineStatus=10)
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
		$(MonitorDB).dbo.PhoneComposition AS PC WITH (NOLOCK)
	INNER JOIN
		$(MonitorDB).dbo.PhoneBook AS PB WITH (NOLOCK) ON PC.PhoneBookId=PB.PhoneBookId
	WHERE
		PC.PhoneNumberId=@PhoneNumberId AND PB.Deleted=0

	RETURN @Result

END
GO

IF object_id('FSCSwitchXSS') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSCSwitchXSS
GO

 CREATE PROCEDURE [dbo].[FSCSwitchXSS]
AS
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 9.2.2023
-- Description:	Přepíná úroveň zabezpečení zobrazování mailů
-- =============================================

BEGIN

DECLARE @Now AS datetime=GETDATE()
DECLARE @ConfigurationValue AS NVARCHAR(10)=(SELECT TOP 1 [ConfigurationValue] FROM $(MonitorDB).[dbo].[Configuration] WITH(NOLOCK) WHERE ConfigurationName='XssMessageDisp')
SET @ConfigurationValue=IIF(@ConfigurationValue='Filter','Protect','Filter')

UPDATE $(MonitorDB).[dbo].[Configuration]
SET ConfigurationValue = @ConfigurationValue
WHERE ConfigurationName='XssMessageDisp'
DECLARE @Zprava NVARCHAR(200)='Switch XssMessageDisp to '+@ConfigurationValue
EXEC  .[dbo].[WriteEvent] 1,'FSCSwitchXSS',@Zprava

END
GO

IF object_id('FSCRecordings') IS NOT NULL
 DROP  FUNCTION  [dbo].[FSCRecordings]
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	RecordinLess Calls
-- =============================================
CREATE FUNCTION [dbo].FSCRecordings ()
RETURNS nvarchar(200)
AS
BEGIN
 DECLARE @RecordingsLess AS Integer=.dbo.GiveParam('RecordingsLess')
 declare @LastRecording AS Datetime
 declare @LastinCall AS Datetime
 declare @Severity AS Integer
 declare @MyMess AS nvarchar(200)
 declare @LastMessageTime AS DateTime =(SELECT TOP 1 LastMessTime FROM  .dbo.Monitor WHERE  DisplayName='Recordings inspection')
 declare @LimTime AS DateTime = DATEADD(Hour,-8,GETDATE())
 SET @LastMessageTime=IIF(@LimTime>@LastMessageTime,@LimTime,@LastMessageTime)
 DECLARE @RecordingsLessCurr AS Integer=.[dbo].RecordingLessCallsS(@RecordingsLess,@LastMessageTime)
 --DECLARE @PairingTime AS Integer=.dbo.GiveParam('PairingTime')
IF (@RecordingsLessCurr > @RecordingsLess)
  BEGIN
	SET @LastRecording = (SELECT TOP 1  .dbo.TimeUTC_Local(EndTimeUTC) FROM $(SREC).[dbo].[VoiceRecord] WITH(NOLOCK)  ORDER BY StartTimeUtc DESC)
	SET @LastinCall = (SELECT TOP 1 EndTime FROM $(MonitorDB).dbo.[InboundCall] WITH(NOLOCK) WHERE EndTime IS NOT NULL ORDER BY TimeUTC DESC)
	SET @MyMess = (SELECT 'Last recording: '+ CONVERT(NVARCHAR(20),@LastRecording,109) )+' > '+CONVERT(NVARCHAR(5),@RecordingsLess)
	--UPDATE .dbo.Monitor SET DetailMessage=@MyMess WHERE  DisplayName='Recordings inspection'
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

IF object_id('FSCDiskSpace') IS NOT NULL
 DROP  FUNCTION  [dbo].FSCDiskSpace
GO

IF object_id('DiskSpace') IS NOT NULL
 DROP  FUNCTION  [dbo].DiskSpace
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <21.2.2023>
-- Description:	<Kontrola místa na disku>
-- =============================================
CREATE FUNCTION [dbo].[DiskSpace]
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
RETURNS nvarchar(200)
AS
BEGIN
DECLARE @from AS datetime=DATEADD(Minute,-70,GETDATE())


RETURN (
	SELECT TOP (1) 'Agent '+RTRIM(AG.DisplayName)+' has long active call.'
  FROM $(MonitorDB).[dbo].[InboundCall] IC WITH(NOLOCK) 
     LEFT JOIN $(MonitorDB).[dbo].Agent AG WITH (NOLOCK) ON IC.AgentId=AG.AgentId
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
@MyIndex AS NVARCHAR(100)
)
RETURNS nvarchar(200)
AS
BEGIN
DECLARE @from AS datetime=DATEADD(Minute,-55,GETUTCDATE())
declare @EmlMsg as nvarchar(300)=''
--IF @MyIndex='CX_Type_Agent_Time'
--SELECT TOP (1) @EmlMsg=RTRIM([ResultData])+EventType 
--  FROM $(MonitorDB).[dbo].[CallEvent] WITH (INDEX(CX_Type_Agent_Time)) 
--  WHERE TimeUTC>@from AND EventType='IvrScriptA' AND ReferenceData='Error' 
--  AND Timelocal>@from
--  AND ResultData not like '%SetTarget:invalid target%'
IF @MyIndex=''
 SELECT TOP (1) @EmlMsg=RTRIM([ResultData])+EventType 
  FROM $(MonitorDB).[dbo].[CallEvent] WITH (NOLOCK) 
  WHERE TimeUTC>@from AND EventType='IvrScriptA' AND ReferenceData='Error' 
  AND Timelocal>@from
  AND ResultData not like '%SetTarget:invalid target%'
ELSE
 BEGIN
   SET @EmlMsg='' -- Tady musím zavolat proceduru, která vrátí výsledek
 END
	  
  RETURN @EmlMsg


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
IF (SELECT TOP 1 [Sensitivity] FROM $(MonitorDB).[dbo].[GdprSensitivity] WITH(NOLOCK) WHERE Sensitivity=@GdprDefaultSensitivity) IS NULL
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
,@LastMessageTime AS Datetime

)
RETURNS Integer
AS
BEGIN
   DECLARE @PairingTime AS Integer=.dbo.GiveParam('PairingTime')
   DECLARE @from AS datetime=ISNULL(@LastMessageTime,DATEADD(Hour,-3,GETDATE()))
   DECLARE @to AS datetime=DATEADD(Minute,-@PairingTime,GETDATE())
   DECLARE @UTCDif AS Integer = (SELECT TOP 1 DATEDIFF(HOUR,PilotTime,TimeUTC) FROM $(MonitorDB).dbo.InboundCall WITH (NOLOCK) ORDER BY TIMEUTC DESC)
   DECLARE @fromUTC AS datetime=DATEADD(Hour,@UTCDif,@from)
   DECLARE @toUTC AS datetime=DATEADD(Hour,@UTCDif,@to)

	RETURN (SELECT TOP (@RecordingsLess+1)  COUNT(1)
  FROM $(MonitorDB).dbo.[InboundCall] IC WITH (INDEX(AX_InboundCall_TimeUtc),NOLOCK)
    LEFT JOIN $(MonitorDB).[dbo].[CallRecord] CR WITH (NOLOCK) ON CR.InboundCallId=IC.InboundCallId
	LEFT JOIN $(SREC).[dbo].[Directory] DI WITH (NOLOCK) ON RIGHT(DI.Number,3) COLLATE Czech_CI_AS =IC.Redirector COLLATE Czech_CI_AS
	LEFT JOIN $(MonitorDB).[dbo].[Workplace] WP WITH (NOLOCK) ON WP.WorkplaceId=IC.WorkplaceId
  WHERE TimeUTC>@FromUTC AND TimeUTC<@ToUTC
  AND CallDuration>1
  AND CR.INboundCallId IS NULL   
  AND CallResult ='served'
  AND LEN(CallerNumber)>6
  AND isnull(DI.Record,1) <> 0
  AND ($(FS_CUSTOM).dbo.CustomCheck2('IC',WP.DisplayName)=1 OR $(FS_CUSTOM).dbo.CustomCheck2('ID',IC.Redirector)=1
  OR $(FS_CUSTOM).dbo.CustomCheck2('IP',LEFT(IC.PilotId,20))=1)
  AND $(FS_CUSTOM).dbo.CustomCheckInt('DU',IC.CallDuration)=1 
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
		  FROM [$(ProServer)].[dbo].[Extension] WITH(NOLOCK) 
		  WHERE Deleted=0
		  GROUP BY Number) AS Phase1
		  WHERE Pocet>1)

END

GO


IF object_id('FSC_DuplicWP') IS NOT NULL
 DROP  FUNCTION  [dbo].FSC_DuplicWP
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <22.9.2021>
-- Description:	<Kontrola duplicit pracovišť>
-- =============================================
Create FUNCTION [dbo].FSC_DuplicWP
(
	-- Add the parameters for the function here

)
RETURNS NVARCHAR(50)
AS
BEGIN
 IF (SELECT TOP 1 1 FROM
 (SELECT 
      [Number] 
      ,COUNT(1) AS Pocet
  FROM $(MonitorDB).[dbo].[Workplace] WITH(NOLOCK) 
  WHERE Deleted=0
  GROUP BY Number) AS Phase1
  WHERE Pocet>1)>0
		 RETURN ' In FS is duplicate Workplace!!'
  RETURN ''

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
	 AND WP.State='Free'
	 AND Skill.PbxInKnowledge>0
	 AND PbxInKnowledgeOffset>-100
	 AND (CONVERT(bit,.dbo.GiveParam('UseFlatProficiency'))=0 OR (PROF.VoiceKnowledge>0 AND PROF.LanguageId IS NOT NULL))
       ,'YES','NO ') AS FreeAgent
     ,A.DisplayName AS AgentName
     , P.DisplayName AS ProjectName 
	 ,Skill.PbxInKnowledge
	 , ST.DisplayName AS AgentStatus
	 , ST.PbxState
	 , LANG.DisplayName AS LangKnowledge
	 , WP.State AS WPState
     FROM $(MonitorDB).dbo.Agent A  WITH (NOLOCK)   
      LEFT OUTER JOIN $(MonitorDB).dbo.Skill  WITH (NOLOCK)
 ON Skill.AgentId=A.AgentId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1
      LEFT OUTER JOIN $(MonitorDB).dbo.Project P  WITH (NOLOCK)
 ON P.ProjectId=Skill.ProjectId AND P.Deleted=0
      LEFT OUTER JOIN $(MonitorDB).dbo.Status ST  WITH (NOLOCK)
 ON A.Activity=ST.Activity AND A.StatusId = ST.StatusId
     LEFT OUTER JOIN $(MonitorDB).dbo.Workplace WP  WITH (NOLOCK)
 ON WP.WorkplaceId=A.WorkplaceId
    LEFT OUTER JOIN $(MonitorDB).dbo.Proficiency PROF  WITH (NOLOCK)
 ON PROF.AgentId=A.AgentId AND PROF.VoiceKnowledge>0 AND PROF.VoiceEnabled=1 AND PROF.VoiceChannel=1
       LEFT OUTER JOIN $(MonitorDB).dbo.Language LANG  WITH (NOLOCK)
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
     FROM $(MonitorDB).dbo.Agent A  WITH (NOLOCK)   
      LEFT OUTER JOIN $(MonitorDB).dbo.Skill  WITH (NOLOCK)
 ON Skill.AgentId=A.AgentId AND Skill.EmailKnowledge>0 AND Skill.EmailEnabled=1 AND Skill.EmailChannel=1
      LEFT OUTER JOIN $(MonitorDB).dbo.Project P  WITH (NOLOCK)
 ON P.ProjectId=Skill.ProjectId
      LEFT OUTER JOIN $(MonitorDB).dbo.Status ST  WITH (NOLOCK)
 ON A.Activity=ST.Activity AND A.StatusId = ST.StatusId
     LEFT OUTER JOIN $(MonitorDB).dbo.Workplace WP  WITH (NOLOCK)
 ON WP.WorkplaceId=A.WorkplaceId
    LEFT OUTER JOIN $(MonitorDB).dbo.Proficiency PROF  WITH (NOLOCK)
 ON PROF.AgentId=A.AgentId AND PROF.MessageKnowledge>0 AND PROF.MessageEnabled=1 AND PROF.MessageChannel=1
       LEFT OUTER JOIN $(MonitorDB).dbo.Language LANG  WITH (NOLOCK)
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

IF object_id('FSC_SendEmails') IS NOT NULL
 DROP  PROCEDURE  [dbo].[FSC_SendEmails]
GO

CREATE PROCEDURE [dbo].[FSC_SendEmails]
@DaysCount Int

AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <21.5.2020>
-- Description:	<Pokus o odeslání mailů, které selhaly>
-- =============================================

BEGIN
DECLARE @from AS datetime = GETDATE()-@DaysCount

UPDATE $(MonitorDB).[dbo].[Message]
  SET MessagePhase='Scheduled',MessageResult='Active'
  WHERE 1=1
    AND TimeUtc>@From
    AND Direction='O'
    AND MessagePhase='Failed'

UPDATE $(MonitorDB).[dbo].[Message]
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
SET @Id=(SELECT TOP 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WITH(NOLOCK) WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
IF @Id IS NULL
  BEGIN -- Není text díky chybné CP Pačesky??
    SET @DisplayName=REPLACE(@DisplayName,'ř','o')
    SET @Id=(SELECT TOP 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WITH(NOLOCK) WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
  END
IF @Id IS NOT NULL
  BEGIN
   UPDATE DQ
     SET  DisplayName = @DisplayNameEn
     FROM $(MonitorDB).dbo.DataQuery DQ WITH(NOLOCK) 
       WHERE DataQueryId=@Id
   UPDATE .$(MonitorDB).[dbo].[Portal] SET JsonData = REPLACE(JsonData,@DisplayName,@DisplayNameEn)   
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
SET @Id=(SELECT TOP 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WHERE QueryText LIKE '%'+@oldString+'%'
  AND QueryGroup=@QueryGroup)
IF @Id IS NULL
  BEGIN -- Není text díky chybné CP Pačesky??
    SET @oldString=REPLACE(@oldString,'ř','o')
    SET @Id=(SELECT TOP 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WHERE QueryText LIKE '%'+@oldString+'%'
	AND QueryGroup=@QueryGroup)
  END
IF @Id IS NOT NULL
  BEGIN
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,@oldString,@newString)
     FROM $(MonitorDB).dbo.DataQuery DQ
       WHERE DataQueryId=@Id AND QueryText NOT LIKE '%'+@newString+'%'
  END
END

GO
IF object_id('Write_Mail') IS NOT NULL
 DROP  PROCEDURE  [dbo].[Write_Mail]
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
  DECLARE @FromField as nvarchar(200)=(SELECT TOP 1 [DisplayName] FROM $(MonitorDB).[dbo].[Gateway] WITH(NOLOCK) WHERE [GatewayId]=@GW)
  DECLARE @TimeLocalMess as DateTime
  insert into $(MonitorDB).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText)
		values(GETUTCDATE(),'Email','Scheduled','Active', @FromField, @RemoteAddress,@RemoteAddress ,@GW,99,'O',@SubjectField, @Message , @Message )
/**/

END

GO

IF object_id('DelEventlog') IS NOT NULL
 DROP  PROCEDURE  [dbo].[DelEventlog]
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
 IF EXISTS(SELECT 1 FROM $(MonitorDB).dbo.Agent WITH(NOLOCK) WHERE Agentid=@AgentId AND Activity<>'Logoff')
  BEGIN
    DECLARE @Popis nvarchar(100)
    DECLARE @LogoffId UniqueIdentifier = (SELECT TOP 1 [StatusId] FROM $(MonitorDB).[dbo].[Status] WITH(NOLOCK) WHERE Activity='Logoff' AND Deleted=0)
    INSERT $(MonitorDB).dbo.ChangeRequest( ChangeRequestTimeUtc , Command , SubjectId, ReferenceId)
    VALUES (GETUTCDATE(),N'AgentStatus',@AgentId,@LogoffId)
    SET @Popis = 'I logoff AgentId= '+convert(nvarchar(40), @AgentId)
	EXEC  .[dbo].[WriteEvent] 1,'FSC_LogOffAgent',@Popis
  END
 END


GO

IF object_id('TimeUTC_Local') IS NOT NULL
 DROP  FUNCTION  [dbo].TimeUTC_Local
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <15.3.2016>
-- Description:	<Převádí TimeUTC na Timelocal>
-- poslední neděle v březnu  -  poslední neděle v říjnu
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
DECLARE @RoleId AS UniqueIdentifier=(SELECT TOP 1 [RoleId] FROM $(SREC).[dbo].[Role] WITH(NOLOCK)  WHERE SystemName='AccessRecordByAgent')
DECLARE @ScopeId AS UniqueIdentifier
DECLARE @Degree AS Integer=1
DECLARE @Pokracuj AS bit = 1


IF OBJECT_ID (N'#TEMP', N'U') IS NOT NULL DROP TABLE #TEMP
SELECT SystemName into #TEMP from $(MonitorDB).dbo.Agent WITH(NOLOCK) WHERE Deleted=0 and Template=0 AND SystemName IS NOT NULL

WHILE (@Pokracuj = 1) 
 BEGIN  
   SET @SystemName = (SELECT TOP 1 SystemName  from #TEMP)
   IF @SystemName IS NULL SET @Pokracuj = 0
   ELSE
     BEGIN   
	   -- Ověřím, zda existuje uživatel v SREC
	   SET @AccountId = (SELECT TOP 1 AccountId FROM $(SREC).[dbo].[Account] WHERE SystemName=@SystemName)

	   IF @AccountId IS NULL 
		 BEGIN
		  SELECT  TOP 1 @DisplayName=DisplayName,@TeamName=TeamName From $(MonitorDB).dbo.Agent WITH(NOLOCK) WHERE SystemName=@SystemName
		   INSERT INTO $(SREC).[dbo].[Account]
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
           SET @AccountId = (SELECT TOP 1 AccountId FROM $(SREC).[dbo].[Account] WHERE SystemName=@SystemName)         
		 END
       END
	 DELETE FROM #TEMP WHERE SystemName=@SystemName
  END

  PRINT 'I update Supervisors'
  
 UPDATE SAC
  SET  Supervisor = AG.Supervisor, TeamName = AG.TeamName
  FROM $(SREC).[dbo].[Account] SAC
  inner join $(MonitorDB).dbo.Agent AG WITH (NOLOCK) ON SAC.SystemName COLLATE DATABASE_DEFAULT=AG.SystemName COLLATE DATABASE_DEFAULT
 WHERE SAC.Supervisor<AG.Supervisor

/*
       IF NOT EXISTS(SELECT TOP 1 [PermissionId] FROM $(SREC).[dbo].[Permission] WHERE AccountId=@AccountId)
	    BEGIN
		  -- Ještě zkontroluji ScopeId
		  SET @ScopeId = (SELECT TOP 1 ScopeId FROM $(SREC).[dbo].[Scope] WHERE ReferenceData=@SystemName)
          IF @ScopeId IS NULL
		    SET @DisplayName = (SELECT  TOP 1 DisplayName From $(MonitorDB).dbo.Agent WHERE SystemName=@SystemName)
		    BEGIN

              INSERT INTO $(SREC).[dbo].[Scope]
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
			  SET @ScopeId = (SELECT TOP 1 ScopeId FROM $(SREC).[dbo].[Scope] WHERE ReferenceData=@SystemName)
			END

			INSERT INTO $(SREC).[dbo].[Permission]
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
 SET @RoleId = (SELECT TOP 1 RoleId FROM $(SREC).[dbo].[Role] WITH(NOLOCK)  WHERE SystemName='AccessRecordByAgent')
 IF @RoleId IS NOT NULL
   BEGIN
     IF NOT EXISTS(SELECT TOP 1 [PermissionId] FROM $(SREC).[dbo].[Permission] WITH(NOLOCK)  WHERE RoleId=@RoleId AND Supervisor IS NULL)
	   BEGIN
		INSERT INTO $(SREC).[dbo].[Permission]
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
   IF NOT EXISTS(SELECT TOP 1 [PermissionId] FROM $(SREC).[dbo].[Permission] WITH(NOLOCK) WHERE RoleId=@RoleId AND Supervisor = 1)
	   BEGIN
		INSERT INTO $(SREC).[dbo].[Permission]
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
DECLARE @Command AS nvarchar(150) = (SELECT Command FROM $(FS_CUSTOM).[dbo].[Commands] WITH(NOLOCK) WHERE CommandiD=@RecId) --+' '+''''+CONVERT(NVARCHAR(36),@MEAgentId)+''''
EXEC (@Command) 
END

GO

--IF object_id('IsHoliday') IS NOT NULL
-- DROP  FUNCTION  [dbo].[IsHoliday]
--GO

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
	(SELECT TimeFrom AS Start, TimeTo AS MyEnd FROM  $(MonitorDB).dbo.Holiday WITH(NOLOCK) WHERE HolidayGroupName=@HolidayGroupName and TimeMode='SingleDay'
	   UNION
	SELECT DATEADD(YEAR,YEAR(@MyDatime) - YEAR(TimeFrom),TimeFrom) AS Start, DATEADD(YEAR,YEAR(@MyDatime) - YEAR(TimeTo),TimeTo) AS MyEnd
    FROM  $(MonitorDB).dbo.Holiday WITH(NOLOCK) WHERE HolidayGroupName=@HolidayGroupName and TimeMode='DayInYear') AS Holidays
	   WHERE @MyDatime>=Start and @MyDatime<=MyEnd))
	BEGIN
	  SET @isHol = 1  -- Je svátek
	END
	RETURN @isHol

END
GO

IF object_id('fsc_StartWorkTime') IS NOT NULL
 DROP  FUNCTION  [dbo].[fsc_StartWorkTime]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <30.8.2024>
-- Description:	<vrací čas začátku dnešní pracovní doby>
-- =============================================
CREATE FUNCTION [dbo].[fsc_StartWorkTime]
(
)
RETURNS Datetime
AS
BEGIN
	DECLARE @Start AS DateTime 
	DECLARE @CharDate AS NVARCHAR(24) = LEFT(CONVERT(NVARCHAR(24),GETDATE(),126),10)
	SET @Start=(
	SELECT MIN(CAST(Pilottime AS TIME))
	FROM $(MonitorDB).dbo.Inboundcall
	WHERE PilotTime>DATEADD(Day,-10,GETDATE()) AND AnswerTime IS NOT NULL
	)
	SET @Start = CONVERT(DateTime,@CharDate+' '+SUBSTRING(CONVERT(NVARCHAR(24),@Start,126),12,8))
	RETURN @Start
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
   EXEC .dbo.WriteParam  N'SELECTEDPHONEBOOK',@RecordId,N'Selected PhoneBook'
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
   DECLARE @PhoneCompositionId AS UniqueIdentifier=(SELECT PhoneCompositionId FROM $(MonitorDB).[dbo].[PhoneComposition]  WITH(NOLOCK) WHERE PhoneBookId=@PhoneBookId AND PhoneNumberId=@PhoneNumberId)
    IF @PhoneCompositionId IS NULL
	  BEGIN
	    INSERT INTO $(MonitorDB).[dbo].[PhoneComposition]
           ([PhoneBookId],[PhoneNumberId])
        VALUES (@PhoneBookId,@PhoneNumberId)
	  END
     ELSE
	  DELETE FROM $(MonitorDB).dbo.[PhoneComposition]  WHERE PhoneCompositionId=@PhoneCompositionId -- Odstranění čísla z telefonního seznamu
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
--USE $(MonitorDB)
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


  select IvrStepId AS Id,Action  into ##TEMP from $(MonitorDB).dbo.IVRStep IVS WITH (NOLOCK)
   INNER JOIN $(MonitorDB).dbo.IVRScript IV WITH (NOLOCK) ON IV.IvrScriptId=IVS.IvrScriptId AND IV.Deleted=0
   WHERE  Action='Gosub'
    AND IVS.Deleted=0
    AND NOT EXISTS(SELECT TOP 1 1 FROM $(MonitorDB).[dbo].[IvrScript] IV WHERE IVS.TargetId=IV.IvrScriptId)
 
 INSERT INTO ##TEMP
 select IvrStepId AS Id,Action  from $(MonitorDB).dbo.IVRStep IVS WITH (NOLOCK)
   INNER JOIN $(MonitorDB).dbo.IVRScript IV WITH (NOLOCK) ON IV.IvrScriptId=IVS.IvrScriptId AND IV.Deleted=0
   LEFT JOIN $(MonitorDB).dbo.Holiday HOL WITH (NOLOCK) ON IVS.Numbers=HOL.HolidayGroupName AND IV.Deleted=0
   WHERE  Action='Holiday'
    AND IVS.Deleted=0
    AND HOL.HolidayGroupName IS NULL
   
INSERT INTO ##TEMP
 select IVS.IvrStepId AS Id, IVS.Action  from $(MonitorDB).dbo.IVRStep IVS WITH (NOLOCK)
   INNER JOIN $(MonitorDB).dbo.IVRScript IV WITH (NOLOCK) ON IV.IvrScriptId=IVS.IvrScriptId AND IV.Deleted=0
   LEFT JOIN $(MonitorDB).dbo.IVRStep IV2 WITH (NOLOCK) ON IV2.Rank=IVS.Targets AND IV2.IvrScriptId=IV.IvrScriptId AND IV.Deleted=0
   WHERE  IVS.Action='Goto'
    AND IVS.Deleted=0
    AND IV2.Rank IS NULL
	AND IVS.Targets IS NOT NULL AND IVS.Targets<>''

INSERT INTO ##TEMP
 select IVS.IvrStepId AS Id, 'Goto' AS Action  from $(MonitorDB).dbo.IVRStep IVS WITH (NOLOCK)
   INNER JOIN $(MonitorDB).dbo.IVRScript IV WITH (NOLOCK) ON IV.IvrScriptId=IVS.IvrScriptId AND IV.Deleted=0
   LEFT JOIN $(MonitorDB).dbo.IVRStep IV2 WITH (NOLOCK) ON IV2.Rank=IVS.Targets AND IV2.IvrScriptId=IVS.IvrScriptId AND IV2.Deleted=0
   WHERE  1=1
   AND IVS.Action='Holiday'
   AND IVS.Deleted=0
   AND IV2.Rank IS NULL
   AND IVS.Targets IS NOT NULL AND IVS.Targets<>''

   
-- Chyba v přepojení:
 INSERT INTO ##TEMP
 select IVS.IvrStepId AS Id, IVS.Action  from $(MonitorDB).dbo.IVRStep IVS WITH (NOLOCK)
   INNER JOIN $(MonitorDB).dbo.IVRScript IV WITH (NOLOCK) ON IV.IvrScriptId=IVS.IvrScriptId AND IV.Deleted=0
   WHERE  IVS.Action='SingleSteptransfer'
    AND IVS.Deleted=0
	AND (IVS.Numbers LIKE '%+%' OR LEN(Numbers)<3 OR (Numbers IS NULL AND FileName IS NULL))

-- skok na smazaný IVR Skript:
 INSERT INTO ##TEMP
 select PC.IvrStepId AS Id, PC.Action  FROM $(MonitorDB).[dbo].[IvrStep] PC
	  LEFT JOIN $(MonitorDB).[dbo].[IvrScript] IVR WITH (NOLOCK) ON IVR.[IvrScriptId]=PC.[TargetId]
	  LEFT JOIN $(MonitorDB).[dbo].[IvrScript] IVRP WITH (NOLOCK) ON IVRP.[IvrScriptId]=PC.[IvrScriptId]
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
  DECLARE @AgentName AS NVARCHAR(100) = ISNULL((SELECT TOP 1 DisplayName FROM $(MonitorDB).dbo.Agent WHERE AgentId=@AgentId),'')
  DECLARE @SystemName AS NVARCHAR(100) = ISNULL((SELECT TOP 1 SystemName FROM $(MonitorDB).dbo.Agent WHERE AgentId=@AgentId),'')
  DECLARE @UserId AS UniqueIdentifier = (SELECT TOP 1 UserId FROM ASPNET_iCC.dbo.aspnet_Users WHERE UserName=@SystemName)
  DECLARE @Hlaska AS NVARCHAR(200) = 'Agent personalization '+@AgentName+' was deleted'
  DELETE FROM $(MonitorDB).dbo.Perso WHERE AgentId=@AgentId and RefName not in ('ProCaller#RibbonDefinition','ProCaller#EventHandlingDefinition') -- Zatím jenom Perso pro Reactlient
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
	SELECT TOP 1 ' IVRScript='+(SELECT TOP 1 DisplayName FROM $(MonitorDB).[dbo].[IvrScript] IV WITH (NOLOCK) WHERE IV.IVRScriptId=IVS.IVRScriptId)+
	'   IVRStep='+IVS.DisplayName+'   Rank='+CONVERT(nvarchar(6),IVS.Rank)
     FROM $(MonitorDB).[dbo].[IvrStep] IVS WITH (NOLOCK)
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
  SELECT TOP 1 1 FROM $(MonitorDB).dbo.CallEvent CAE with(nolock) 
 LEFT JOIN $(MonitorDB).dbo.IvrStep AS IVRST with(nolock) ON IVRST.IvrStepId=CAE.ReferenceId
  WHERE  CAE.InboundCallId = @InboundCallId AND IVRST.Action='NOP' AND ResultData=@NopValue)
  ,0)

END
GO

--IF object_id('GiveParam') IS NOT NULL
-- DROP  Function  [dbo].[GiveParam]
--GO



--IF object_id('GiveParam3') IS NOT NULL
-- DROP  Function  [dbo].[GiveParam3]
--GO

IF object_id('FSC_GiveParam3') IS NOT NULL
 DROP  Function  [dbo].[FSC_GiveParam3]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <2.9.2021>
-- Description:	<vrací hodnotu požadovaného parametru>
-- =============================================
CREATE FUNCTION [dbo].[FSC_GiveParam3]
(
	-- Add the parameters for the function here
    @ConfigurationName AS NVARCHAR(50)
   ,@ConfigurationValue AS NVARCHAR(MAX) 
   ,@Description AS NVARCHAR(800)

)
RETURNS NVARCHAR(MAX)
AS
BEGIN
  DECLARE @ConfigurationValue2 AS NVARCHAR(MAX) = (SELECT ConfigurationValue FROM $(MonitorDB).[dbo].[CONFIGURATION] WITH(NOLOCK)  WHERE ConfigurationName=@ConfigurationName)
  IF @ConfigurationValue2 IS NULL
  	  EXEC [dbo].[WriteParam] @ConfigurationName,@ConfigurationValue, @Description
  ELSE
  	  SET @ConfigurationValue=@ConfigurationValue2
	RETURN @ConfigurationValue
END
GO


--IF object_id('GiveParam2') IS NOT NULL
-- DROP  PROCEDURE  [dbo].[GiveParam2]
--GO

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
  DECLARE @ConfigurationValue2 AS NVARCHAR(MAX) = (SELECT ConfigurationValue FROM $(MonitorDB).[dbo].[CONFIGURATION]  WITH(NOLOCK) WHERE ConfigurationName=@ConfigurationName)
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


UPDATE $(MonitorDB).[dbo].[InboundCall]
SET CallResult = 'Lost', CallPhase = 'HangupAgent'
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

/**/
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
  declare @TOCC as nvarchar(200) =.dbo.FSC_GiveParam('TOCC')
	IF @TOCC IS NULL
	     BEGIN
		   SET @TOCC  = 'error@atlantis.cz'
		   EXEC [dbo].[WriteParam] 'TOCC', @TOCC, 'E-mail addresses to which recorded problems should be sent'
		 END
  declare @TOCC2 as nvarchar(200) =.dbo.FSC_GiveParam('TOCC2')
	IF @TOCC2 IS NULL AND 1=2
	     BEGIN
		   SET @TOCC2  = 'servis@atlantis.cz'
		   EXEC [dbo].[WriteParam] 'TOCC2', @TOCC2, 'E-mail addresses to which recorded problems should be sent'
		 END
  declare @TOCC3 as nvarchar(200) =.dbo.FSC_GiveParam('TOCC3')
	IF @TOCC3 IS NULL
	     BEGIN
		   SET @TOCC3  = ''
		   EXEC [dbo].[WriteParam] 'TOCC3', @TOCC3, 'E-mail addresses to which recorded problems should be sent'
		 END
--
DECLARE @Inform1 AS Bit, @Inform2 AS Bit, @Inform3 AS Bit
SELECT @Inform1=Inform1,@Inform2=Inform2,@Inform3=Inform3 FROM $(FS_Custom).dbo.Monitor WHERE Displayname=@RecMsg
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

 declare @Company as nvarchar(200) =.dbo.FSC_GiveParam('Company')
 declare @SyncVer as nvarchar(200) = --.dbo.FSC_GiveParam('iCC.ServiceSync')-- Potebuji Description
 (SELECT Description FROM $(MonitorDB).[dbo].[CONFIGURATION] WITH(NOLOCK)  WHERE ConfigurationName='iCC.ServiceSync')
 declare @ProVer as nvarchar(200) = 
 (SELECT Description FROM $(ProServer).[dbo].[CONFIGURATION] WITH(NOLOCK)  WHERE ConfigurationName='Pro.Service')

 SET @RecMsg='iCCServiceSync version: '+RTRIM(@SyncVer)+' ProServer version: '+RTRIM(@ProVer)
 declare @MessageId as uniqueidentifier = (SELECT TOP 1 MessageId FROM $(MonitorDB).[dbo].[Message] WITH(NOLOCK) 
	   WHERE Direction='O' AND MessageType='Email' AND ReceivedSentTime IS NOT NULL AND GatewayId IS NOT NULL ORDER BY ReceivedSentTime DESC)
 declare @GW as uniqueidentifier = CASE WHEN .dbo.FSC_GiveParam('ServiceGateWay')='' THEN
(SELECT TOP 1 [GatewayId] FROM $(MonitorDB).[dbo].[Message] WITH(NOLOCK) WHERE MessageId=@MessageId) ELSE .dbo.FSC_GiveParam('ServiceGateWay') END

 declare @FromField as nvarchar(150) = (SELECT TOP 1 PilotAddress FROM $(MonitorDB).[dbo].[Gateway] WITH(NOLOCK) WHERE GatewayId=@GW)

  declare @Mark as int = 77
  DECLARE @RepeatAfterMess as int
  DECLARE @TimeLocalMess as DateTime
  SELECT TOP 1 @RepeatAfterMess=RepeatAfter, @TimeLocalMess=TimeLocal FROM .dbo.ErrorLog WITH(NOLOCK) WHERE Message=@Message ORDER BY TimeLocal DESC
  -- Pokud mám o tomto problému informovat
  IF @TimeLocalMess IS NULL OR (@RepeatAfterMess>0 AND DATEADD(Minute,@RepeatAfterMess,@TimeLocalMess) <GETDATE())
     BEGIN
	    declare @Now as datetime = GETDATE()
    
	insert into .[dbo].[Errorlog] (TimeLocal, RepeatAfter, Message) values(GETDATE(), @RepeatAfter, @Message)
	--SET @Message='Warning: '+@Message
	SET @RecMsg=@RecMsg+' - This is a diagnostic message for the system administrator'

 IF @GW IS NOT NULL AND (NOT EXISTS(SELECT * FROM $(MonitorDB).dbo.Message as M WITH(NOLOCK) where M.Messagetype='Email'
  AND MessagePhase='Scheduled' AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE())
   AND GatewayId=@GW AND M.TimeUTC<DATEADD(Minute,-10,GETUTCDATE()))) 
	insert into $(MonitorDB).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,'Email','Scheduled','Active', @FromField, @RemoteAddress,@RemoteAddress,  @TOCC ,@GW,99,'O',
		'FSL1: '+@Company+' '+@Message+' '+ISNULL(@Specif,'')+' '+@ProcVer, @RecMsg, @RecMsg, @Mark )
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
declare @RoleAktivniPobocky uniqueidentifier = (select RoleId from $(ProServer).dbo.Role where SystemName = 'AllowedActive')
declare @RoleAdministrace uniqueidentifier = (select RoleId from $(ProServer).dbo.Role where SystemName = 'AllowedAdminRights')

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
from $(MonitorDB).dbo.Agent a
left join $(ProServer).dbo.Credentials b WITH (NOLOCK) ON a.SystemName COLLATE Czech_CI_AS =b.SystemName COLLATE Czech_CI_AS
--=========POZOR NA PODMINKU NA TYM - DLE POTREBY UPRAVIT==========================================================================================================
where (TeamName <> 'Admin') 
--=================================================================================================================================================================
and a.Deleted=0 AND a.SystemName is not null AND b.SystemName is null

/* Původní verze VaK:
select systemname,displayname, newid(),TeamName,
case when Supervisor = 1 then 'Supervizor' else 'Agent' end as Description

--=========POZOR NA PODMINKU NA TYM - DLE POTREBY UPRAVIT========================================================================================================================================================
from $(MonitorDB).dbo.Agent where (TeamName <> 'Admin') and Deleted=0 AND SystemName is not null
--===============================================================================================================================================================================================================

------------vymazání úètù, které už existují z docasne tabulky
delete from #Synchro$(ProServer)
where login in (select B.SystemName from ProServer.dbo.Account a left join ProServer.dbo.Credentials b on a.AccountId=b.AccountId and b.SystemName is not null and a.Deleted=0)
*/

------------- založení úètu
INSERT into $(ProServer).dbo.Account (AccountId,DisplayName,Description,TeamName,Deleted)
select NewAccountId, DisplayName,Description,Team,0 from #SynchroProServer

-------------vložení loginù
insert into $(ProServer).dbo.Credentials (CredentialsId,AccountId,Rank,SystemName,Deleted)
SELECT newid(),NewAccountId,10,Login,0 from  #SynchroProServer

---------vložení oprávnìní na Aktivní poboèky
insert into $(ProServer).dbo.Permission (PermissionId,RoleId,Degree,AccountId,Scope)
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
	select SystemName from $(MonitorDB).dbo.Agent as a with (nolock) where Deleted = 0 and SystemName is not null)

	--obnoveni nesmazanych v tabulce Credentials, kteri jsou v $(MonitorDB).dbo.Agent
	update Proserver.dbo.Credentials 
	set Deleted = 0
	where AccountId in (select AccountId from #ExistsInICC)

	--obnoveni nesmazanych v tabulce Account, kteri jsou v $(MonitorDB).dbo.Agent
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
	select SystemName from $(MonitorDB).dbo.Agent as a with (nolock) where Deleted = 1 and SystemName is not null)
	and not exists (select SystemName from $(MonitorDB).dbo.Agent as a with (nolock) where Deleted = 0 and SystemName is not null)--existuje tedy pouze jako smazany a ne nekolik smazanych a i existujici login
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
DECLARE @Now AS datetime=GETDATE()
DECLARE @TimeLimit AS datetime=DATEADD(Minute,-70,@Now)
DECLARE @TimeLimit2 AS datetime=DATEADD(Minute,-20,@Now)
DECLARE @InboundCallId AS UniqueIdentifier, @State AS NVARCHAR(30), @Activity AS NVARCHAR(30)

SELECT @InboundCallId=InboundCallId , @State=WP.State, @Activity=AG.Activity 
/*,PilotTime,CallPhase,CallResult,Callernumber
   ,AG.DisplayName AS AgentName
   ,DATEDIFF(MINUTE,PilotTime,@Now) AS ActiveMin*/
FROM iCC.[dbo].[InboundCall] IC
 LEFT JOIN iCC.[dbo].Agent AG ON AG.AgentId=IC.AgentId
 LEFT JOIN iCC.[dbo].WorkPlace WP ON WP.WorkPlaceId=IC.WorkPlaceId

WHERE 1=1
  AND Callresult='Active'
  AND NOT(WP.State='Free' AND AG.Activity='PostCall') -- Pracoviště je již uvolněno, ale agent má ještě PostCall
  AND ((PilotTime < @TimeLimit AND IC.AgentId IS NULL)

  OR  (WP.State NOT IN ('Busy','Ring','Transfer','Hold') AND WP.State IS NOT NULL AND IC.AgentId IS NOT NULL
   AND PilotTime < @TimeLimit2)

  OR  (AG.Activity NOT IN ('Ready','PostCall','Pause') AND IC.AgentId IS  NOT NULL AND PilotTime < @TimeLimit2))
-- Tato kombinace je asi OK: WP.State=Hold AG.Activity=Pause
IF  (@InboundCallId IS NOT NULL)
   BEGIN
 	RETURN 'Invalid InCall '+CONVERT(NVARCHAR(40),@InboundCallId)+' WP.State='+ISNULL(@State,'NULL')+' AG.Activity='+ISNULL(@Activity,'NULL')
   END
RETURN ''
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
 
RETURN ISNULL((SELECT TOP 1 0 FROM [$(MonitorDB)].[dbo].[OutboundCall]
WITH(NOLOCK)  WHERE 1=1  AND OutboundListImportId =@OutboundListImportId AND CallResult='Scheduled'),1)
END
GO
IF object_id('Daily_Maintenance') IS NOT NULL
 DROP  Procedure  [dbo].[Daily_Maintenance]
GO
IF object_id('FSC_Daily_Maintenance') IS NOT NULL
 DROP  Procedure  [dbo].[FSC_Daily_Maintenance]
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <12.12.2019>
-- Description:	<Denní údržba nastavení Frontstage>
-- =============================================
-- ALTER
CREATE
 PROCEDURE [dbo].[FSC_Daily_Maintenance]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Vypnuto AS NVARCHAR(5)='false'
	DECLARE @DoplnVelikonoce AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.FSC_GiveParam2 'DoplnVelikonoce', @DoplnVelikonoce OUTPUT,'Automatic replenishment of Easter holidays'
	DECLARE @DoplnMimoPrac AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.FSC_GiveParam2 'DoplnMimoPrac',@DoplnMimoPrac OUTPUT,'Supplementing the indication of non-working hours'
    DECLARE @PracDobaChatu  AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.FSC_GiveParam2 'PracDobaChatu',@PracDobaChatu OUTPUT,'Making adjustments to the working hours of chats'
	DECLARE @DoplnproServer  AS NVARCHAR(5) = @Vypnuto
	EXEC .dbo.FSC_GiveParam2 'DoplnproServer',@DoplnproServer OUTPUT,'Adding SREC rights settings'
    DECLARE @ImportListAge AS NVARCHAR(5) = '4'
	EXEC .dbo.FSC_GiveParam2 'ImportListAge', @ImportListAge OUTPUT,'Maximal age of Import Lists in Months'
    DECLARE @ImportListAgeN AS Integer = IIF(ISNUMERIC(@ImportListAge)=1,CONVERT(Integer,@ImportListAge),4)

	DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)

	DECLARE @Zprava NVARCHAR(200)= 'Entry point'
   EXEC  .[dbo].[WriteEvent] @Loguj,@ProcName,@Zprava

   EXEC  .[dbo].[CustomProc] 'XX',NULL

-- Doplnění velikonoc:
   declare @Holiday as nvarchar(40) =.dbo.FSC_GiveParam('Holiday')
   EXEC .dbo.FSC_DoplnVelikonoce @DoplnVelikonoce,@Holiday
-- Údržba pracovní doby Chatů
IF @PracDobaChatu='true' AND EXISTS(SELECT * FROM $(MonitorDB).dbo.ChatGateCondition WHERE Signal='Closed') AND OBJECT_ID(N'$(FS_Custom)..HolidayPlan', N'U') IS NOT NULL
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
    DECLARE Hol_cursor CURSOR FOR SELECT  HolidayGroupName,RelId  FROM dbo.HolidayPlan WHERE HolidayGroupName=@Holiday
	DECLARE Hol_cursor2 CURSOR FOR  SELECT  HP.HolidayGroupName,HP.RelId  FROM dbo.HolidayPlan HP
             -- LEFT JOIN dbo.HolidayPlan HP2 WITH (NOLOCK) ON HP.RelId=HP2.RelId AND HP2.HolidayGroupName=@Holiday
              LEFT JOIN $(MonitorDB).dbo.Holiday HO WITH (NOLOCK) ON HP.HolidayGroupName COLLATE DATABASE_DEFAULT  =HO.HolidayGroupName
			   COLLATE DATABASE_DEFAULT AND Deleted=0
	--(TimeMode='DayInYear' OR (TimeMode='SingleDay' AND DATEPART(Year,TimeFrom)=DATEPART(Year,@today)
	-- AND DATEPART(Hour,TimeFrom)=0 AND DATEPART(Hour,TimeTo)=23))
	--  AND DATEPART(Month,@today)=DATEPART(Month,TimeFrom) AND DATEPART(Day,@today)=DATEPART(Day,TimeFrom)  AND
 
	  				  WHERE HP.HolidayGroupName<>@Holiday AND HO.HolidayId IS NOT NULL AND Deleted=0

    OPEN Hol_cursor 
	OPEN Hol_cursor2
  -- Teď zkontroluji pracovní doby (ne svátky)
  FETCH NEXT FROM Hol_cursor2 INTO @HolidayGroupName, @RelId   
  WHILE @@FETCH_STATUS = 0  
   BEGIN
    SET @CharDateFrom  = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeFrom FROM $(MonitorDB).dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @CharDateTo   = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeTo FROM $(MonitorDB).dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @PerformChange  = 0
	-- v Holiday najdu pracovní dobu dnešního dne
		SELECT @ChatFrom=TimeFrom,@ChatTo=TimeTo FROM $(MonitorDB).dbo.Holiday WHERE [HolidayGroupName]=@HolidayGroupName AND @today>=CONVERT(Date,TimeFrom) AND @today<=CONVERT(Date,TimeTo)
		IF @ChatFrom IS NOT NULL
		  BEGIN	   
		   -- Teď musím do @Start a @End dosadit datumy z ChatGateCondition
		   SET @ChatFrom = CONVERT(DateTime,@CharDateFrom+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatFrom,126),12,8))
		   SET @ChatTo   = CONVERT(DateTime,@CharDateTo+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatTo,126),12,8))
			UPDATE $(MonitorDB).[dbo].ChatGateCondition
			   SET TimeFrom=@ChatFrom,
				   TimeTo  =@ChatTo 
			 WHERE ChatGateConditionId=@RelId
			SET @Zprava='(1 WT) I change times on ChatGateConditionId='+CONVERT(NVARCHAR(40),@RelId)+' to '+CONVERT(NVARCHAR(40),@ChatFrom)+' - '+CONVERT(NVARCHAR(40),@ChatTo)
			EXEC  .[dbo].[WriteEvent] @Loguj,@ProcName,@Zprava
		  END
     FETCH NEXT FROM Hol_cursor2 INTO @HolidayGroupName, @RelId  
   END
   ------------------------
   
  FETCH NEXT FROM Hol_cursor INTO @HolidayGroupName, @RelId   
  WHILE @@FETCH_STATUS = 0  
   BEGIN
    SET @CharDateFrom  = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeFrom FROM $(MonitorDB).dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @CharDateTo = LEFT(CONVERT(NVARCHAR(24),(SELECT TOP 1 TimeTo FROM $(MonitorDB).dbo.ChatGateCondition WHERE ChatGateConditionId=@RelId) ,126),10)
	SET @ChatFrom=NULL
	-- Zkontroluji, zda dnes není svátek:
	SELECT TOP 1 @ChatFrom=TimeFrom,@ChatTo=TimeTo FROM $(MonitorDB).dbo.Holiday WHERE [HolidayGroupName]=@Holiday AND
	(TimeMode='DayInYear' OR (TimeMode='SingleDay' AND DATEPART(Year,TimeFrom)=DATEPART(Year,@today)
	 AND DATEPART(Hour,TimeFrom)=0 AND DATEPART(Hour,TimeTo)=23))
	  AND DATEPART(Month,@today)=DATEPART(Month,TimeFrom) AND DATEPART(Day,@today)=DATEPART(Day,TimeFrom)
      AND Deleted=0
	IF @ChatFrom IS NOT NULL
	  BEGIN
	    SET @ChatFrom = CONVERT(Datetime,@today) -- Vyrobím čas 0:00
		SET @ChatTo   = @ChatFrom
		SET @PerformChange=1
		--DELETE FROM Hol_cursor2 WHERE @RefId=RefId
		-- Teď musím do @Start a @End dosadit datumy z ChatGateCondition
		SET @ChatFrom = CONVERT(DateTime,@CharDateFrom+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatFrom,126),12,8))
		SET @ChatTo   = CONVERT(DateTime,@CharDateTo+' '+SUBSTRING(CONVERT(NVARCHAR(24),@ChatTo,126),12,8))
		UPDATE $(MonitorDB).[dbo].ChatGateCondition
			SET TimeFrom=@ChatFrom,
				TimeTo  =@ChatTo 
			WHERE ChatGateConditionId=@RelId
        SET @Zprava='(2 HO) I change times on ChatGateConditionId='+CONVERT(NVARCHAR(40),@RelId)+' to '+CONVERT(NVARCHAR(40),@ChatFrom)+' - '+CONVERT(NVARCHAR(40),@ChatTo)
        EXEC  .[dbo].[WriteEvent] @Loguj,@ProcName,@Zprava
	  END
    FETCH NEXT FROM Hol_cursor INTO @HolidayGroupName, @RelId  
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
		UPDATE $(MonitorDB).[dbo].[OutboundListImport]
		  SET  Active=0 
		WHERE Deleted=0
		AND Active=1
		AND TimeUTC<@from1
		AND $(FS_Custom).dbo.[isOutboundImpComplete](OutboundListImportId)=1
	    -- Zruším  neaktivní importy
		UPDATE  $(MonitorDB).[dbo].[OutboundListImport]
			SET Deleted=1
		   WHERE Deleted=0
			AND Active=0
			AND TimeUTC<@from2
            AND $(FS_Custom).dbo.[isOutboundImpComplete](OutboundListImportId)=1
       ---------------------------------- Smazání starých Change Requestů:
	   DELETE FROM $(MonitorDB).dbo.[ChangeRequest]
       WHERE Done=1 AND ChangeRequestTimeUtc < @From1
	   delete from $(MonitorDB).dbo.ChangeRequest 
	   where Command not in ('BulkMessageImport','CampaignImport','OutboundListImport','OutboundListExport','DataQueryExport',
	     'ExportEventsAsCsv') and ChangeRequestTimeUtc < @from3 and Done = 1


	END

IF @DoplnproServer='true'
   BEGIN
	   EXEC PridejPravaPoslechu
	   --EXEC ProServerSync_Toaster Vypuštěno 23.9.2024
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
 SELECT /*TOP 10*/ PilotTime,IC.InboundCallId  FROM $(MonitorDB).dbo.InboundCall IC WITH (NOLOCK)
   LEFT JOIN $(MonitorDB).dbo.callevent ce WITH (NOLOCK) ON IC.InboundCallId=CE.InboundCallId AND CE.referencedata = 'NopOK' and CE.ResultData = 'MIMOPRAC'
   --LEFT JOIN $(MonitorDB).dbo.callevent ce2 WITH (NOLOCK) ON IC.InboundCallId=CE2.InboundCallId AND CE2.referencedata = 'NopOK' and CE2.ResultData = 'WHITELIST'
   WHERE PilotTime>@from AND dbo.IsWorkTime4(PilotTime,'PracDoba')=0.
   AND CE.InboundCallId IS NULL --AND CE2.InboundCallId IS NULL
   OPEN my_cursor 

  FETCH NEXT FROM My_cursor INTO @PilotTime, @InboundcallId    
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @InboundcallId  IS NOT NULL
		BEGIN
		  -- Zapiš do $(MonitorDB).dbo.callevent chybějící záznam
          INSERT INTO $(MonitorDB).[dbo].[CallEvent]
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
       EXEC  .[dbo].[WriteEvent] @Loguj,@ProcName,@Zprava

END
GO

IF object_id('FSC_MessageEvent') IS NOT NULL
 DROP  FUNCTION  [dbo].[FSC_MessageEvent]
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	RecordinLess Calls
-- =============================================
CREATE FUNCTION [dbo].FSC_MessageEvent ()
RETURNS nvarchar(200)
AS
BEGIN
 -- Kontrola chyb v MessageEvent
    declare @Now as datetime = GETDATE()
	declare @OneHourAgo as datetime = DATEADD(Hour, -1, @Now )

    DECLARE @EmlMsg AS nvarchar(200)
    = (SELECT TOP 1 [ResultData] FROM $(MonitorDB).[dbo].[MessageEvent] WITH (NOLOCK) 
	WHERE TimeLocal>@OneHourAgo  AND EventType='Failure'
	AND ResultData NOT LIKE 'One or more recipients rejected%'
	AND ResultData NOT LIKE 'Message ID is empty%'
	AND ResultData NOT LIKE 'At least one recipient is not valid%'
	AND ResultData NOT LIKE 'Thread was interrupted from a waiting state%'
	AND ResultData NOT LIKE 'Temporary server error.%'
	AND ResultData NOT LIKE 'The remote server returned an error%'
	AND ResultData NOT LIKE 'Object reference not set to an instance of an object%')
	IF (@EmlMsg IS NOT NULL) 
	   RETURN 'Emails: '+@EmlMsg 
RETURN ''
END

GO

IF object_id('FSC_NoTemplate') IS NOT NULL
 DROP  FUNCTION  [dbo].[FSC_NoTemplate]
GO


-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	RecordinLess Calls
-- =============================================

CREATE FUNCTION [dbo].FSC_NoTemplate ()
RETURNS nvarchar(200)
AS
BEGIN
 -- Kontrola chybějící šablony
  declare @EightHoursAgo as datetime = DATEADD(Hour, -8, GETDATE() )
  RETURN (SELECT TOP 1 [ResultData] FROM $(MonitorDB).[dbo].[MessageEvent] WITH(NOLOCK) 
		   WHERE TimeLocal>@EightHoursAgo AND EventType='Failure' AND ResultData='NoTemplate' )

END

GO

IF object_id('DBSize') IS NOT NULL
 DROP  FUNCTION  [dbo].DBSize
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-05-09
-- Description:	Kontrola velikosti Express DB:
-- =============================================
CREATE FUNCTION [dbo].DBSize ()
RETURNS nvarchar(200)
AS
BEGIN
 IF @@Version LIKE '%Express%' AND $(MonitorDB).dbo.SpaceUsed()>9850 -- MB
		RETURN 'Database $(MonitorDB) Has almost maximum size '+CAST(CAST(FILEPROPERTY('$(MonitorDB)', 'SpaceUsed') AS INT)/128 AS NVARCHAR(5))+'MB'
RETURN ''
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
  (SELECT TOP 1 CallerNumber FROM  $(MonitorDB).[dbo].[OutboundCall] WITH(NOLOCK) WHERE OutboundCallId=@CallId),
  (SELECT TOP 1 CallerNumber FROM  $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK) WHERE InboundCallId=@CallId))
  DECLARE @TimeUtc AS DateTime=IIF(@Direction='O',
  (SELECT TOP 1 TimeUtc FROM  $(MonitorDB).[dbo].[OutboundCall] WITH(NOLOCK) WHERE OutboundCallId=@CallId),
  (SELECT TOP 1 TimeUtc FROM  $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK) WHERE InboundCallId=@CallId))
  DECLARE @CallResult AS nvarchar(32)=IIF(@Direction='O',
  (SELECT TOP 1 CallResult FROM  $(MonitorDB).[dbo].[OutboundCall] WITH(NOLOCK) WHERE OutboundCallId=@CallId),
  (SELECT TOP 1 CallResult FROM  $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK) WHERE InboundCallId=@CallId))

 DECLARE @CallDuration AS Integer=ISNULL(IIF(@Direction='O',
  (SELECT TOP 1 CallDuration FROM  $(MonitorDB).[dbo].[OutboundCall] WITH(NOLOCK) WHERE OutboundCallId=@CallId),
  (SELECT TOP 1 CallDuration FROM  $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK) WHERE InboundCallId=@CallId))
  ,0)
DECLARE @WaitDuration AS Integer=ISNULL(IIF(@Direction='O',
  0,
  (SELECT TOP 1 DATEDIFF(ss,PilotTime,AnswerTime) FROM  $(MonitorDB).[dbo].[InboundCall] WITH(NOLOCK) WHERE InboundCallId=@CallId))
  ,0)
-- Zkusím najít tu nahrávku
 DECLARE @VoiceRecordID AS UniqueIdentifier=(SELECT TOP 1 VoiceRecordID FROM  $(SREC).[dbo].[VoiceRecord] WITH(NOLOCK)
  WHERE StartTimeUtc>DATEADD(ss,-80,@TimeUtc) AND StartTimeUtc<DATEADD(ss,@WaitDuration+1,@TimeUtc)
  AND RIGHT(RemoteNumber,9)=RIGHT(@CallerNumber,9) --AND AgentName IS NULL --V jedné nahrávce může být více přepojených hovorů
  AND DATEDIFF(ss,StartTimeUtc,EndTimeUtc)>=@CallDuration -- Nahrávka by neměla být kratší než hovor v In/OutboundCall
  )
 IF @VoiceRecordID IS NOT NULL
    BEGIN
	  SET @CallDuration=(SELECT TOP 1 DATEDIFF(ss,StartTimeUtc,EndTimeUtc) AS Duration FROM $(SREC).[dbo].[VoiceRecord] WITH(NOLOCK) WHERE VoiceRecordId=@VoiceRecordId)
	  IF @CallDuration>10 -- Hovory kratší než 10 sekund nebudu párovat
	   BEGIN
		   DECLARE @OutboundCallId AS UniqueIdentifier
		   DECLARE @InboundCallId AS UniqueIdentifier
		   DECLARE @AgentName AS nvarchar(120)=IIF(@Direction='O',
	  (SELECT TOP 1 AG.DisplayName FROM  $(MonitorDB).[dbo].[OutboundCall] OC WITH(NOLOCK) INNER JOIN $(MonitorDB).[dbo].[AGENT] AG  WITH(NOLOCK) ON OC.AgentId=AG.AgentId WHERE OutboundCallId=@CallId),
	  (SELECT TOP 1 AG.DisplayName FROM  $(MonitorDB).[dbo].[InboundCall] IC WITH(NOLOCK) INNER JOIN $(MonitorDB).[dbo].[AGENT] AG  WITH(NOLOCK) ON IC.AgentId=AG.AgentId WHERE InboundCallId=@CallId))

	   IF @Direction='O'
		 SET @OutboundCallId=@CallId
	   ELSE
		 SET @InboundCallId=@CallId
	   INSERT INTO $(MonitorDB).[dbo].[CallRecord] (RecordFileId,InboundCallId,OutboundCallId)
		  VALUES (@VoiceRecordID,@InboundCallId,@OutboundCallId)
	   update $(SREC).[dbo].[VoiceRecord] set AgentName=@AgentName WHERE VoiceRecordId=@VoiceRecordId AND ISNULL(AgentName,'')=''
		IF @Direction='O'
         BEGIN
		     SET @OutboundCallId=@CallId -- Vycpávka kvůli syntaxi
	        -- IF @CallResult<>'Served'
		    --update $(MonitorDB).[dbo].[OutboundCall] set CallResult='Served' WHERE OutboundCallId=@CallId
         END
	   ELSE
	     BEGIN
		   IF @CallResult<>'Served'
		   	 update $(MonitorDB).[dbo].[InboundCall] set CallResult='Served', CallPhase='HangupCaller',CallDuration=@CallDuration WHERE InboundCallId=@CallId
		   --update $(MonitorDB).[dbo].[InboundCall] set CallDuration=@CallDuration WHERE InboundCallId=@CallId
		 END
	   SET @Popis = 'I paired the call '+@Direction+' CallId='+convert(nvarchar(MAX), @CallId)+' with recording VoiceRecordId='+convert(nvarchar(MAX), @VoiceRecordId)
	   EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
      END
  END 
 END 

GO

IF object_id('FSC_DoplnVelikonoce') IS NOT NULL
 DROP  Procedure  [dbo].[FSC_DoplnVelikonoce]
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
		  IF NOT EXISTS(SELECT * FROM $(MonitorDB).dbo.Holiday WITH(NOLOCK) WHERE TimeFrom=@Datum AND HolidayGroupName=@Holiday)
		   INSERT INTO $(MonitorDB).[dbo].[Holiday]
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
	DECLARE @PairingTime AS Integer=.dbo.FSC_GiveParam('PairingTime')

   DECLARE @OutboundcallId AS UniqueIdentifier
   DECLARE @TimeUTCMin AS DateTime=DATEADD(Hour,-10,GETUTCDATE())
   DECLARE @TimeUTCMax AS DateTime=DATEADD(Minute,-@PairingTime,GETUTCDATE()) -- Nechci Jardovi zasahovat do párování
 
     EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, 'Start'


DECLARE My_cursor CURSOR FOR   
 SELECT TOP 100
      OC.[OutboundCallId] 
  FROM $(MonitorDB).[dbo].[OutboundCall] OC WITH(NOLOCK) 
    LEFT JOIN $(MonitorDB).[dbo].[CallRecord] CR WITH (NOLOCK) ON CR.OutboundCallId=OC.OutboundCallId
  --  LEFT JOIN $(SREC).[dbo].[Directory] DI WITH (NOLOCK) ON RIGHT(DI.Number,3) COLLATE Czech_CI_AS =C.Redirector COLLATE Czech_CI_AS
    LEFT JOIN $(MonitorDB).[dbo].[Workplace] WP WITH (NOLOCK) ON WP.WorkplaceId=OC.WorkplaceId
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

IF object_id('FSCInBoundMess') IS NOT NULL
 DROP  FUNCTION  [dbo].[FSCInBoundMess]
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2021-01-04
-- Description:	Kontrola přijatých mailů
-- =============================================
CREATE FUNCTION [dbo].FSCInBoundMess ()
RETURNS nvarchar(200)
AS
BEGIN
--DECLARE @Result as int = 1
  DECLARE @Now AS datetime=GETDATE()
	-- Kontrola přijatých mailů
 -- IF EXISTS(SELECT 1 FROM  $(MonitorDB).[dbo].[Message] M WITH (NOLOCK)
  IF EXISTS(SELECT TOP 1 1 FROM  $(MonitorDB).[dbo].[Message] M WITH (NOLOCK) --(INDEX(AX_Message_AcceptedTime))

    WHERE m.MessagePhase = 'Received'
	AND AcceptedTime IS NULL
	AND m.MessageType = 'Email' AND EndTime IS NULL AND AnsweringTime IS NULL and m.direction = 'I' 
    and .dbo.WorkDayDiff(ReceivedSentTime,2)>2 
    and AgentId IS NULL)
   	  RETURN 'not accepted incomming emails'
 RETURN ''

END

GO


-----------------
IF object_id('ReplaceSmilyes') IS NOT NULL
 DROP  FUNCTION  [dbo].ReplaceSmilyes
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.12.2018>
-- Description:	<Přepisuje smajlíky otazníky (všechny tyto znaky SQL detekuje jako otazník)>
-- =============================================

CREATE function [dbo].[ReplaceSmilyes] (
    @nstring nvarchar(4000)
)
returns NVARCHAR(4000)
as begin
   DECLARE @Result varchar(4000) = '' 
   DECLARE @nchar nvarchar(1)
   DECLARE @position int
   SET @position = 1
   WHILE @position <= LEN(@nstring)
   BEGIN
      SET @nchar = SUBSTRING(@nstring, @position, 1)  
      IF UNICODE(@nchar) between 32 and 400
         SET @Result = @Result + @nchar
      SET @position = @position + 1
   END
return @Result
END
GO



IF object_id('WorkDayDiff') IS NOT NULL
 DROP  FUNCTION  [dbo].WorkDayDiff
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <30.4.2019>
-- Description:	<říká, zda je zadaný čas vzdálen více než určený počet pracovních dní od současnosti>
-- =============================================
CREATE FUNCTION [dbo].[WorkDayDiff]
(
	-- Add the parameters for the function here
	@MyDatime as Datetime
	,@DayDiff as integer
)
RETURNS bit
AS
BEGIN
	--declare @MyDatime as datetime = getdate()
	DECLARE @OutOffRange AS bit=IIF(@MyDatime>DATEADD(Day,@DayDiff*-1,GETDATE()),0,1)
	IF @OutOffRange=0
	  RETURN @OutOffRange ---------------->>>>>>
	DECLARE @WorkDays AS Integer = @DayDiff+1
	DECLARE @TestDiff AS Real=@DayDiff*24*3600
	DECLARE @MyDiff   AS Real=DATEDIFF(Second,@MyDatime,GETDATE())
	DECLARE	@TestDatime as Datetime = DATEADD(Hour,12,CONVERT(Datetime,CONVERT(Date,GETDATE()))) -- Budu testovat poledne
	WHILE @MyDiff>(@TestDiff) AND @WorkDays>0
	  BEGIN	    
	    IF .dbo.MimoPrac(NULL,@TestDatime) = 1 -- Pokud je testovaný den svátek
		  IF CONVERT(Date,@TestDatime)=CONVERT(Date,GETDATE()) -- Dnes odečtu pouze čas od půlnoci
		    SET @MyDiff=@MyDiff-DATEDIFF(Second,CONVERT(Date,GETDATE()),GETDATE())
          ELSE
		    SET @MyDiff=@MyDiff-24*3600 -- Odečtu celý den
        ELSE
		  SET @WorkDays=@WorkDays-1
        SET @TestDatime=DATEADD(DAY,-1,@TestDatime)
	  END
	  SET @OutOffRange=IIF(@MyDiff>@TestDiff,1,0)
	RETURN @OutOffRange
END



GO


IF object_id('HledNesparIn') IS NOT NULL
 DROP  Procedure  [dbo].[HledNesparIn]
GO
IF object_id('FSC_HledNesparIn') IS NOT NULL
 DROP  Procedure  [dbo].[FSC_HledNesparIn]
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 25.01.2021
-- Description:	Vyhledání nespárovaných příchozích hovorů a pokus o dopárování
-- =============================================

CREATE PROCEDURE [dbo].[FSC_HledNesparIn]
AS
BEGIN
    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)
	DECLARE @PairingTime AS Integer=.dbo.FSC_GiveParam('PairingTime')

   DECLARE @InboundcallId AS UniqueIdentifier
   DECLARE @TimeUTCMin AS DateTime=DATEADD(Hour,-10,GETUTCDATE())
   DECLARE @TimeUTCMax AS DateTime=DATEADD(Minute,-@PairingTime,GETUTCDATE()) -- Nechci Jardovi zasahovat do párování
 
     EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, 'Start'


DECLARE My_cursor CURSOR FOR   
 SELECT TOP 100
      IC.[InboundCallId] 
  FROM $(MonitorDB).[dbo].[InboundCall] IC WITH (INDEX(AX_InboundCall_TimeUtc),NOLOCK) 
    LEFT JOIN $(MonitorDB).[dbo].[CallRecord] CR WITH (NOLOCK) ON CR.InboundCallId=IC.InboundCallId
    LEFT JOIN $(SREC).[dbo].[Directory] DI WITH (NOLOCK) ON RIGHT(DI.Number,3) COLLATE Czech_CI_AS =IC.Redirector COLLATE Czech_CI_AS
    LEFT JOIN $(MonitorDB).[dbo].[Workplace] WP WITH (NOLOCK) ON WP.WorkplaceId=IC.WorkplaceId
  WHERE TimeUTC>@TimeUTCMin AND TimeUTC<@TimeUTCMax
  AND CallDuration>1
  AND CR.INboundCallId IS NULL   
  AND CallResult ='served'
  AND LEN(RTRIM(CallerNumber))>6
  AND isnull(DI.Record,1) <>0
    AND (.dbo.CustomCheck2('IC',WP.DisplayName)=1 OR .dbo.CustomCheck2('ID',IC.Redirector)=1 OR $(FS_CUSTOM).dbo.CustomCheck2('IP',LEFT(IC.PilotId,20))=1)
  AND $(FS_CUSTOM).dbo.CustomCheckInt('DU',IC.CallDuration)=1 
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
  UPDATE $(MonitorDB).dbo.Message
  SET  BodyText =  .dbo.ReplaceSmilyes(BodyText),SubjectField = .dbo.ReplaceSmilyes(SubjectField)
  WHERE  (MessageId = @MessageId)
  SET @Popis = 'Transcription of smileys on the message MessageId='+CONVERT(NVARCHAR(50),@MessageId)
  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
END
GO


IF object_id('FSCMonCheck') IS NOT NULL
 DROP  Procedure  [dbo].[FSCMonCheck]
GO

CREATE PROCEDURE [dbo].FSCMonCheck
@Message AS NVARCHAR(200),
@StartTime AS Datetime
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <12.1.2023>
-- Description:	Monitoruje běh kontrolní funkce
-- =============================================

BEGIN
  DECLARE @Loguj AS Bit=1
  DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
  DECLARE @Popis AS nvarchar(MAX)
  DECLARE @ActualTime DateTime=GETDATE()
  DECLARE @RunSec Int = DATEDIFF(SS,@StartTime,@ActualTime)
  SELECT @Message+' '+RIGHT(CONVERT(NVARCHAR(28),@ActualTime,120),8)+' '+
    CONVERT(NVARCHAR(2),@RunSec)+' seconds' AS Message
  IF @RunSec>15
    begin
	  SET @Popis = @Message+CONVERT(NVARCHAR(2),@RunSec)+' seconds'
	  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
    end
END
GO

IF object_id('FSCAgentWPInspect') IS NOT NULL
 DROP  FUNCTION [dbo].[FSCAgentWPInspect]
GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17.2.2023>
-- Description:	<Kontrola stavu agentů>
-- =============================================
CREATE FUNCTION [dbo].[FSCAgentWPInspect]
(

)
RETURNS nvarchar(200)
AS
BEGIN
DECLARE @Counter AS Int =3
DECLARE @State AS NVARCHAR(10)
DECLARE @AgentName AS NVARCHAR(50)
--DECLARE @Agentid AS UniqueIdentifier
DECLARE @AgentIncorStat AS NVARCHAR(200)='Agent %s has an phone status %s'
  WHILE @Counter>0
    BEGIN
	 --SET 
     SELECT TOP 1 @AgentName = RTRIM(AG.Displayname),@State=w.State
       FROM $(MonitorDB).dbo.Agent AS AG  WITH(NOLOCK) 
      LEFT JOIN $(MonitorDB).dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
      LEFT JOIN $(MonitorDB).dbo.InboundCall IC WITH (NOLOCK) ON IC.AgentId=AG.Agentid AND IC.CallResult='Active'
      LEFT JOIN $(MonitorDB).dbo.OutboundCall OC WITH (NOLOCK) ON OC.AgentId=AG.Agentid AND OC.CallResult='Active'
      WHERE AG.Deleted = 0 AND AG.Template=0 AND AG.Activity = 'Ready' AND w.State <> 'Free'
	   AND IC.InboundCallId IS NULL AND OC.OutboundCallId IS NULL
    SET  @Counter= @Counter-1
	IF @AgentName IS NOT NULL 
	  BEGIN
	    IF @Counter=0
		    RETURN FormatMessage(@AgentIncorStat,@AgentName,@State) --==============>>>>>>>>
        --ELSE
        --  WAITFOR DELAY '00:00:02'
      END
	ELSE
	  BREAK
    END

RETURN ''

END
GO
/*
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
   select * into Icc_Catalog.dbo.DataQuery from $(MonitorDB).dbo.DataQuery WHERE DataQueryId=@DataQueryId
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
	   JOIN $(MonitorDB).dbo.DataQuery DGOUT  
       ON DGIN.Dataqueryid = DGOUT.Dataqueryid  
       WHERE  DGOUT.DataQueryId=@DataQueryId 
	  END
    ELSE   -- Záznam v tabulce neexistuje
	  INSERT INTO Icc_Catalog.dbo.DataQuery SELECT * FROM $(MonitorDB).dbo.DataQuery WHERE DataQueryId=@DataQueryId
   END
 -- Dataquerycolumn:
  IF OBJECT_ID(N'Icc_Catalog..DataQueryColumn', N'U') IS NULL -- Tabulka neexistuje
   select * into Icc_Catalog.dbo.DataQueryColumn from $(MonitorDB).dbo.DataQueryColumn WHERE DataQueryId=@DataQueryId
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
	   FROM $(MonitorDB).dbo.DataQueryColumn IDQ
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
	   JOIN $(MonitorDB).dbo.DataQueryColumn DGOUT  
       ON DGIN.DataQueryColumnid = DGOUT.DataQueryColumnid  
       WHERE  DGOUT.DataQueryId=@DataQueryId AND DGIN.[Deleted] = 0
   END
END 
*/

GO
GO


--------------------- Uživatelské procedury: --------------------
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

IF object_id('CustomCheckMain') IS NULL
 BEGIN
  DECLARE @CreateCustom AS NVARCHAR(500)=
 ' 
 CREATE FUNCTION [dbo].[CustomCheckMain]()
   RETURNS NVARCHAR(200)
	 AS
	  BEGIN
		  RETURN ''''
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
	    DECLARE @Nothing AS Integer=0
	  END'
    EXEC (@CreateCustom)
  END
GO


IF object_id('$(MonitorDB).dbo.Commands') IS NOT NULL
  BEGIN
   PRINT 'V iCC existuje tabulka Commands'
   IF (SELECT COUNT(1) FROM $(MonitorDB).dbo.Commands)=0
     BEGIN
	   DROP TABLE $(MonitorDB).dbo.Commands
	   PRINT 'Delete table Commands was performed'
	 END
 END

IF object_id('$(MonitorDB).dbo.Errorlog') IS NOT NULL
  BEGIN
   PRINT 'V iCC existuje tabulka Errorlog'
   IF (SELECT COUNT(1) FROM $(MonitorDB).dbo.Errorlog)=0
     BEGIN
	   DROP TABLE $(MonitorDB).dbo.Errorlog
	   PRINT 'Delete table Errorlog was performed'
	 END
 END
IF object_id('$(MonitorDB).dbo.Eventlog') IS NOT NULL
  BEGIN
   PRINT 'V iCC existuje tabulka Eventlog'
   IF (SELECT COUNT(1) FROM $(MonitorDB).dbo.Eventlog)=0
     BEGIN
	   DROP TABLE $(MonitorDB).dbo.Eventlog
	   PRINT 'Delete table Eventlog was performed'
	 END
 END
IF object_id('$(MonitorDB).dbo.Results') IS NOT NULL
  BEGIN
   PRINT 'V iCC existuje tabulka Results'
   IF (SELECT COUNT(1) FROM $(MonitorDB).dbo.Results)=0
     BEGIN
	   DROP TABLE $(MonitorDB).dbo.Results
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

 EXEC .dbo.ChangeDQ 'FS_CUSTOM.dbo.GiveParam','FS_CUSTOM.dbo.FSC_GiveParam','ServiceAPP'  
 EXEC .dbo.ChangeDQ 'LEFT JOIN .[dbo].[Gateway] GW ON GW.GatewayId=Phase2.GatewayId','INNER JOIN .[dbo].[Gateway] GW ON GW.GatewayId=Phase2.GatewayId AND GW.Deleted=0','ServiceAPP' 
 EXEC .dbo.ChangeDQ 'WHERE Direction=''O'' AND MessagePhase=''Scheduled''','WHERE Direction=''O'' AND MessagePhase=''Scheduled'' AND MessageResult=''Active''','ServiceAPP' 


 PRINT 'Translate to english:'
 UPDATE TOP (500) DQC
SET  DisplayName=TargetColumn
FROM $(MonitorDB).dbo.DataQueryColumn DQC WITH(NOLOCK) 
  inner join $(MonitorDB).dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
  LEFT JOIN $(MonitorDB).[dbo].[Portal] PRT WITH (NOLOCK) ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
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

USE $(MonitorDB)

IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'OnlineStatus' AND Object_ID = Object_ID(N'dbo.IVRENTRY'))
  UPDATE  $(FS_Custom).dbo.Monitor SET RepeatAfterMin = -1 WHERE Command ='FSC_IVRInspect()'

IF 
  NOT EXISTS (SELECT * FROM sys.indexes WHERE name='UQ_AgentId_Profile_RefName_RefId_CtxId' 
    AND object_id = OBJECT_ID ('.dbo.Perso'))  AND
  NOT EXISTS (SELECT * FROM sys.indexes WHERE name='UQ_Perso_AgentId_Profile_RefName_RefId_CtxId' 
    AND object_id = OBJECT_ID ('.dbo.Perso'))
CREATE NONCLUSTERED INDEX [CX_AUQ_Perso_AgentId_Profile_RefName_RefId_CtxId] ON [dbo].[Perso]
(
	[AgentId] ASC,
	[Profile] ASC,
	[RefName] ASC,
	[RefId] ASC,
	[ContextId] ASC
)
INCLUDE([JsonData]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF object_id('FSC_DelDuplIndex') IS NOT NULL
 DROP  PROCEDURE  [dbo].FSC_DelDuplIndex
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <4.01.2024>
-- Description:	<Smazání duplicitního indexu>
-- =============================================
CREATE PROCEDURE [dbo].[FSC_DelDuplIndex]
  @TableName NVARCHAR(30)
  ,@IndexForDel NVARCHAR(50)
  ,@IndexForTest NVARCHAR(50)
AS
BEGIN
IF EXISTS (SELECT name FROM sys.indexes WHERE name = @IndexForDel 
   AND object_id = OBJECT_ID(@TableName))
 AND EXISTS (SELECT name FROM sys.indexes WHERE name = @IndexForTest
    AND object_id = OBJECT_ID(@TableName))
BEGIN
  DECLARE @Command AS NVARCHAR(500)
  SET @Command='DROP INDEX '+RTRIM(@IndexForDel)+' ON '+@TableName
  EXEC SP_EXECUTESQL @Command
  PRINT 'Index '+@IndexForDel+' was dropped'

END
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
 
return (SELECT CAST(FILEPROPERTY('$(MonitorDB)', 'SpaceUsed') AS INT)/128)
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
	CREATE NONCLUSTERED INDEX [CXF_Done_InProgress] ON $(MonitorDB).[dbo].[ChangeRequest]
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

IF ISNULL((select Top 1 1 from sys.indexes i where Name='AX_InboundCall_TimeUtc'),0)=0
 CREATE NONCLUSTERED INDEX [AX_InboundCall_TimeUtc] ON [dbo].[InboundCall]
 (
	[TimeUtc] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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
 SET ConfigurationValue=(SELECT ConfigurationValue FROM .[dbo].[Configuration] WITH(NOLOCK) WHERE ConfigurationName='DropDownProjectsInCallDataQueryId')
WHERE ConfigurationName='DropDownProjectsInCallInfoDataQueryId' AND ConfigurationValue IS NULL  

----- Spoušť dohledového systému
UPDATE .[dbo].[ActionTrigger]
  SET DisplayName='Monitoring System'
  WHERE DisplayName='Kontrola nahrávek ZbH'
IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WITH(NOLOCK) WHERE DisplayName='Monitoring System')
INSERT [dbo].[ActionTrigger] ( [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted]) 
VALUES ( N'Monitoring System', NULL, N'ServiceAPP', N'EXEC [$(FS_custom)].dbo.CheckRecAndEmlActivity2', NULL, NULL, N'Interval', 30, N'DayInWeek', CAST(N'2017-01-02 07:45:00.000' AS DateTime), CAST(N'2017-01-06 20:10:59.900' AS DateTime), NULL, CAST(N'2018-07-09 10:50:27.247' AS DateTime), NULL, 0, 0)

------ Denní údržba
IF NOT EXISTS(SELECT * FROM [dbo].[ActionTrigger] WITH(NOLOCK) WHERE ActionTriggerId= '7a982dcb-e4c5-4a09-86db-52542909b406' )
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
 VALUES (N'7a982dcb-e4c5-4a09-86db-52542909b406', N'Denní údržba', NULL, N'ServiceAPP', N'EXEC $(FS_custom).[dbo].[FSC_Daily_Maintenance]', NULL, NULL, N'PeriodDay', NULL, NULL, NULL, NULL, NULL, CAST(LEFT(CONVERT(NVARCHAR(28),GETDATE()+1,120),10)+' 03:00:00.000' AS DateTime), NULL, 0, 0)


IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Smazání starých událostí')
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
 VALUES (N'8a2405ca-b436-43e5-aa4d-fbd069afaf87', N'Smazání starých událostí', NULL, N'ServiceAPP', N'EXEC  [$(FS_custom)].[dbo].[FSC_DelEventlog]', NULL, NULL, N'PeriodMonth', NULL, NULL, NULL, NULL, NULL, CAST(N'2020-12-31T23:40:00.000' AS DateTime), NULL, 0, 0)

----- Spoušť importní funkce:
IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Selected modules import')
 INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
  VALUES (N'ac26be9c-a3cf-41e6-9472-2cd61177d150', N'Selected modules import', N'Slouží k instalaci komponent z katalogu', N'ServiceAPP', N'EXEC [$(FS_custom)].[dbo].[ImportModul] @RecordId,0', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)


 ----- Spoušť importní Test Gateway:
IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Gateway Test')
 INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
  VALUES (N'19e60d25-6014-48ca-95a9-0e0ffad9e6d4', N'Gateway Test', N'It is for GW testing', N'ServiceAPP', N'EXEC [$(FS_custom)].[dbo].[GatewayTest] @RecordId', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)

IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE ActionTriggerId='873404dd-0641-46b0-b8f4-3f6b33bf348c')
 INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted], [Offset], [LaunchTime])
 VALUES (N'873404dd-0641-46b0-b8f4-3f6b33bf348c', N'Copy selected steps into selected script', NULL, N'ServiceAPP', N'EXEC $(FS_custom).[dbo].[IVRStepCopy] @RecordId', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL)
GO

----------------- Doplnění čísla volajícího do gridu události příchozího hovoru ----------------------
DECLARE @Id AS UNIQUEIDENTIFIER=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WITH(NOLOCK) WHERE DisplayName='Události příchozího hovoru' AND QueryGroup='ServiceAPP' AND Deleted=0)
IF @Id IS NOT NULL AND NOT EXISTS(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WITH(NOLOCK) WHERE DataQueryId=@Id AND QueryText LIKE '%CallerNumber%' )
  BEGIN
   PRINT 'Přidávám CallerNumber do Události příchozího hovoru'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'LEFT JOIN IvrScript AS IVRSC WITH (NOLOCK) ON IVRST.IvrScriptId=IVRSC.IvrScriptId',
	 'LEFT JOIN IvrScript AS IVRSC WITH (NOLOCK) ON IVRST.IvrScriptId=IVRSC.IvrScriptId
	  LEFT JOIN InboundCall AS IC WITH (NOLOCK) ON IC.InboundCallId=CAE.InboundCallId')
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
  UPDATE .dbo.DataQuery SET  QueryGroup='ServiceAPP'
 WHERE  QueryGroup='Supervizor' AND DisplayName IN ('Free agents','Calls Queue investigation','Free agents list',
 'Volní agenti Outbound','Queue investigation')

  UPDATE .dbo.DataQuery SET  QueryGroup='ServiceAPP'
 WHERE  QueryGroup='Admin' AND DisplayName IN ('Admin Commands','Admin Recordingless Calls','Free agents list',
 'Assigned messages to agents','Code Change','Data Queries','Data Queries Columns'
 ,'Data Query usage','Detected problems','E-mails Queue','Free agents for mail'
 ,'Gateways Monitor','Inbound Call Events','Inbound Calls','Issues','IVR Scripts','Outbound Calls'
 ,'IVR Steps','List of Agents','Message Events','Messages','Outbound Call Events','Pharmacies'
 ,'Recordings','Results of Actions','Wallboard','Wallboard Times','Web Admin Changes'
)


----------------- Add Skill level into free agents list ----------------------
DECLARE @Id AS UNIQUEIDENTIFIER=(SELECT TOP 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WITH(NOLOCK) WHERE DisplayName='Free agents'
 AND QueryGroup='ServiceAPP' AND Deleted=0 AND QueryText NOT LIKE '%VolniAgentiCall%' )
IF @Id IS NOT NULL 
  BEGIN
   PRINT 'I improve free agents list'
     UPDATE DQ
     SET  QueryText = 'SELECT * FROM $(FS_Custom).[dbo].VolniAgentiCall()'
     FROM .dbo.DataQuery DQ WITH(NOLOCK) 
     WHERE DataQueryId=@Id
INSERT $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'FreeAgent',N'Select',N'FreeAgent',NULL,NULL,NULL,NULL,NULL,N'FreeAgent',NULL,0,80,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'PbxInKnowledge',N'Text',N'PbxInKnowledge',NULL,NULL,NULL,NULL,NULL,N'PbxInKnowledge',NULL,0,70,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'AgentStatus',N'Text',N'AgentStatus',NULL,NULL,NULL,NULL,NULL,N'AgentStatus',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'PbxState',N'Integer',N'PbxState',NULL,NULL,NULL,NULL,NULL,N'PbxState',NULL,0,60,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'LangKnowledge',N'Text',N'LangKnowledge',NULL,NULL,NULL,NULL,NULL,N'LangKnowledge',NULL,0,80,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@Id,N'WPState',N'Text',N'WPState',NULL,NULL,NULL,NULL,NULL,N'WPState',NULL,0,80,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  END
GO
DECLARE @Id AS UNIQUEIDENTIFIER=(SELECT TOP 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WHERE DataQueryId='a5134a50-8053-4921-bd42-538c7b175934')
IF @Id IS NULL 
  BEGIN
/* ServiceAPP: Volní agenti Outbound */
INSERT  $(MonitorDB).dbo.[DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
 VALUES(N'a5134a50-8053-4921-bd42-538c7b175934',N'Volní agenti Outbound',NULL,N'ServiceAPP',N'AgentName',N'SELECT  
    IIF(ST.Activity=''Ready''
	 --AND PROF.LanguageId IS NOT NULL
	 AND W.State=''Free''
	 AND Skill.PbxOutKnowledge>0
	 AND Skill.PbxOutEnabled>0
	 AND Skill.PbxOutChannel>0
       ,''YES'',''NO '') AS FreeAgent,

     A.DisplayName AS AgentName
     , TeamName
     , P.DisplayName AS ProjectName
	 ,Skill.PbxOutKnowledge 
	 ,Skill.PbxOutEnabled
	 ,Skill.PbxOutChannel
	  ,A.Activity
	  ,W.State
     FROM Agent A  WITH (NOLOCK)   
      LEFT OUTER JOIN Skill  WITH (NOLOCK) ON Skill.AgentId=A.AgentId 
      LEFT OUTER JOIN Project P  WITH (NOLOCK) ON P.ProjectId=Skill.ProjectId
	  LEFT OUTER JOIN Status ST  WITH (NOLOCK) ON ST.StatusId=A.StatusId
	  LEFT OUTER JOIN WorkPlace W WITH (NOLOCK) ON A.WorkplaceId = W.WorkplaceId
     WHERE A.AgentId=Skill.AgentId',0,NULL,NULL,NULL,0,0)
INSERT  $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'05c1baf1-e85b-4a26-b60c-e865909bd671',N'a5134a50-8053-4921-bd42-538c7b175934',N'FreeAgent',N'Select',N'FreeAgent',NULL,NULL,NULL,NULL,NULL,N'FreeAgent',NULL,0,80,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT  $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'117ea6f5-c7b4-4280-acd8-e1e4dd7c73cd',N'a5134a50-8053-4921-bd42-538c7b175934',N'AgentName',N'Text',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,120,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT  $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'65ae6ee6-8548-4af8-8563-8209c9a0c69c',N'a5134a50-8053-4921-bd42-538c7b175934',N'TeamName',N'Select',N'TeamName',NULL,NULL,NULL,NULL,NULL,N'TeamName',NULL,0,80,15,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT  $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'0ff747a6-514d-4550-93fc-a6b3933fe559',N'a5134a50-8053-4921-bd42-538c7b175934',N'ProjectName',N'Text',N'ProjectName',NULL,NULL,NULL,NULL,NULL,N'ProjectName',NULL,0,140,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT  $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'48d8603a-f372-448d-b0d4-f683fb8f22d9',N'a5134a50-8053-4921-bd42-538c7b175934',N'PbxOutKnowledge',N'Integer',N'PbxOutKnowledge',NULL,NULL,NULL,NULL,NULL,N'PbxOutKnowledge',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT  $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'70bd0e91-322f-4a2b-a33e-abdd0a59cc1e',N'a5134a50-8053-4921-bd42-538c7b175934',N'PbxOutEnabled',N'Select',N'PbxOutEnabled',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,70,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT  $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'583dfe13-0e69-44f4-8b39-812b07362973',N'a5134a50-8053-4921-bd42-538c7b175934',N'PbxOutChannel',N'Select',N'PbxOutChannel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,70,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT  $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'48ae8355-58d3-41ab-889a-5d22f7a26c98',N'a5134a50-8053-4921-bd42-538c7b175934',N'Activity',N'Select',N'Activity',NULL,NULL,NULL,NULL,NULL,N'Activity',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT  $(MonitorDB).dbo.[DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'645a49ca-d275-424a-ab36-f8bf42a53468',N'a5134a50-8053-4921-bd42-538c7b175934',N'State',N'Select',N'State',NULL,NULL,NULL,NULL,NULL,N'State',NULL,0,80,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)

  END

    /* ServiceAPP:  */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '8b5d27d3-ffa0-46bc-93d9-d47396bb0241'
DECLARE @DisplayName AS VARCHAR(150) = 'OutboundCalls Distribution'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
  UPDATE .dbo.DataQuery SET  QueryGroup=@QueryGroup
 WHERE DisplayName = @DisplayName AND QueryGroup='Supervizor'

IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)

 BEGIN

/* Supervizor: Odchozí hovory distribuce */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
 VALUES(@DataQueryId,@DisplayName,NULL,N'ServiceAPP',N'ScheduleTime',N'SELECT     C.OutboundCallId
         , A.DisplayName AS AgentName
	 , ISNULL(A.Activity,''N/A'') AS Activity
           ,C.ScheduleTime
           ,IIF(C.ScheduleTime <= GETDATE()OR C.ScheduleTime IS NULL ,''ANO'',''NE'') AS SchedTimeOK
		   ,C.CallType
           ,IIF(C.CallType=''DialOut'',''ANO'',''NE'') AS CallTypeOK
		   ,C.CallResult
           ,IIF(C.CallResult=''Scheduled'',''ANO'',''NE'') AS CallResultOK
		   ,C.CallPhase
           ,IIF(C.CallPhase = ''Enqueue'' OR C.CallPhase = ''AgentOfferMissed'',''ANO'',''NE'') AS CallPhaseOK
		   ,OLI.Active  AS OLIActive
           ,IIF(OLI.Active IS NULL OR OLI.Active = 1,''ANO'',''NE'') AS OLIActiveOK
		   ,OL.Activity AS OLActivity
           ,IIF(OL.Activity = ''Scheduled'' OR OL.Activity IS NULL,''ANO'',''NE'') AS OLActivityOK
		   ,IIF(C.Predistributed = 1 OR OL.PredictorId IS NULL,''ANO'',''NE'') AS PreDisDictOK
		   ,C.Predistributed
		   ,OL.PredictorId
	       ,IIF(C.Predistributed = 0 OR A.Activity=''Ready'',''ANO'',''NE'') AS PreDisAgentOK
		   ,IIF(OL.RankBatch IS NULL OR C.OutboundListImportId IS NULL OR C.Rank <= OLI.RankBarrier,''ANO'',''NE'') AS FollowingOK
		   ,OL.RankBatch
		   ,C.OutboundListImportId
		   ,C.Rank 
		   ,OLI.RankBarrier
		   ,IIF(C.Rank <= OLI.RankBarrier,''ANO'',''NE'') AS UnderBarrier
		   ,IIF(OL.PredictorId IS NULL,''NE'',''ANO'') AS PreDictiveCall

FROM         dbo.OutboundCall AS C INNER JOIN
                      dbo.Project AS P WITH (NOLOCK) ON C.ProjectId = P.ProjectId LEFT OUTER JOIN
                      dbo.OutboundList AS OL WITH (NOLOCK) ON C.OutboundListId = OL.OutboundListId AND OL.Deleted = 0 LEFT OUTER JOIN
                      dbo.OutboundListImport AS OLI WITH (NOLOCK) ON C.OutboundListImportId = OLI.OutboundListImportId AND OLI.Deleted = 0
	   LEFT JOIN Agent AS A WITH (NOLOCK) ON C.AgentId=A.AgentId
',0,NULL,NULL,NULL,0,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'b694e2aa-a3b0-4225-aca3-6419f202446b',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'OutboundCallId',N'Text',N'OutboundCallId',NULL,NULL,NULL,NULL,NULL,N'OutboundCallId',NULL,0,230,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'dc71656b-af69-4d61-8dc6-c2eda22b4acd',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'ScheduleTime',N'DateTimeFromTo',N'ScheduleTime',N'{0:dd.MM. HH:mm}',NULL,NULL,NULL,NULL,N'ScheduleTime',NULL,0,95,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'a7462e7c-027e-4506-8ace-33856d869772',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'SchedTimeOK',N'Select',N'SchedTimeOK',NULL,NULL,NULL,NULL,NULL,N'SchedTimeOK',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'f5b33898-9bea-4ade-815d-e963884d2d72',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'CallType',N'Text',N'CallType',NULL,NULL,NULL,NULL,NULL,N'CallType',NULL,0,80,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'c544ff14-0cbb-44bf-a0a0-1189bbecd919',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'CallTypeOK',N'Select',N'CallTypeOK',NULL,NULL,NULL,NULL,NULL,N'CallTypeOK',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'4ef968dd-4c55-4757-a236-dc7903a18e1e',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'CallResult',N'Text',N'CallResult',NULL,NULL,NULL,NULL,NULL,N'CallResult',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'eb05fc57-2586-4b28-b62e-00748675fc5b',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'CallResultOK',N'Select',N'CallResultOK',NULL,NULL,NULL,NULL,NULL,N'CallResultOK',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'dbbccde5-ceee-4af4-992c-5e68f1ae84e4',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'CallPhase',N'Text',N'CallPhase',NULL,NULL,NULL,NULL,NULL,N'CallPhase',NULL,0,80,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'a51a6462-bcca-499a-bccf-26784170d3ef',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'CallPhaseOK',N'Select',N'CallPhaseOK',NULL,NULL,NULL,NULL,NULL,N'CallPhaseOK',NULL,0,80,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'2c4bf782-a55b-4e08-ab55-e8abfc9a3a7c',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'OLIActive',N'Integer',N'OLIActive',NULL,NULL,NULL,NULL,NULL,N'OLIActive',NULL,0,50,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'efeca87f-8414-4ab2-94c2-fcf2a38eae43',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'OLIActiveOK',N'Select',N'OLIActiveOK',NULL,NULL,NULL,NULL,NULL,N'OLIActiveOK',NULL,0,80,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'7cdb041e-424a-40a0-90a3-95784117c9e4',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'OLActivity',N'Text',N'OLActivity',NULL,NULL,NULL,NULL,NULL,N'OLActivity',NULL,0,80,110,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'574b259c-90e0-49fc-981d-4c10ad2bf77e',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'OLActivityOK',N'Select',N'OLActivityOK',NULL,NULL,NULL,NULL,NULL,N'OLActivityOK',NULL,0,80,120,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'4714b4cc-08a0-436a-8da2-81ef139e8cbd',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'PreDictiveCall',N'Select',N'PreDictiveCall',NULL,NULL,NULL,NULL,NULL,N'PreDictiveCall',NULL,0,60,125,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'691b5ff6-62fc-4dcd-8b1b-808c5381e87f',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'PreDisDictOK',N'Select',N'PreDisDictOK',NULL,NULL,NULL,NULL,NULL,N'PreDisDictOK',NULL,0,80,130,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'92638c8a-bf02-42a5-bfb6-9b11ccdfa505',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'Predistributed',N'Color',N'Predistributed',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,140,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'b3536141-b33c-4aba-83de-5ef46a8174ca',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'PreDisAgentOK',N'Select',N'PreDisAgentOK',NULL,NULL,NULL,NULL,NULL,N'PreDisAgentOK',NULL,0,80,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'81422408-2097-4dcb-a551-7ca8f619c1ec',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'AgentName',N'Text',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,80,152,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'b60c603b-f518-4b4c-8383-8cfdac5564e0',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'Activity',N'Text',N'Activity',NULL,NULL,NULL,NULL,NULL,N'Activity',NULL,0,80,154,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'b5b0fc29-a418-4d3f-adba-0c2630e67afb',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'FollowingOK',N'Select',N'FollowingOK',NULL,NULL,NULL,NULL,NULL,N'FollowingOK',NULL,0,80,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'e01824f1-2ff5-4254-b9f4-1ebdef1e4c78',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'RankBatch',N'Integer',N'RankBatch',NULL,NULL,NULL,NULL,NULL,N'RankBatch',NULL,0,60,170,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'8dcba588-0a5c-4ecf-8def-75fa82d73280',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'Rank',N'Integer',N'Rank',NULL,NULL,NULL,NULL,NULL,N'Rank',NULL,0,60,180,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'05698ceb-7f19-48b8-bc80-6594779be422',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'RankBarrier',N'Integer',N'RankBarrier',NULL,NULL,NULL,NULL,NULL,N'RankBarrier',NULL,0,60,190,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'45f11b11-856d-4faa-870e-4981abebfe9b',N'8b5d27d3-ffa0-46bc-93d9-d47396bb0241',N'UnderBarrier',N'Select',N'UnderBarrier',NULL,NULL,NULL,NULL,NULL,N'UnderBarrier',NULL,0,80,200,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO


  /* ServiceAPP: IVR Skripty */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'b37e3ad0-c8e3-4083-a23a-0e18686076b6'
DECLARE @DisplayName AS VARCHAR(150) = 'IVR Skripty'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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
            ,CAST(IIF(IVR.IvrScriptId=CONVERT(UniqueIdentifier,$(FS_CUSTOM).dbo.FSC_GiveParam(''SELECTED_IVR'')), 1,0) AS bit) AS IsSelected
  		  ,IIF(PC.IvrScriptAId IS NULL AND IVS.TargetId IS NULL,''NO'',''YES'') AS IsUsed
  
          FROM $(MonitorDB).[dbo].[IvrScript] IVR
  			LEFT JOIN $(MonitorDB).[dbo].[PreCondition] PC WITH (NOLOCK) ON PC.IvrScriptAId=IVR.IvrScriptId 
  		    LEFT JOIN $(MonitorDB).[dbo].[IVRStep] IVS WITH (NOLOCK) ON IVS.TargetId=IVR.IvrScriptId 
  
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
    VALUES (@DataQueryId,N'Select IVR Script',N'ImageScript',N'ProvedAkci',N'~/CustomImages/{0}.png',N'RecordId',NULL,NULL,NULL,N'ProvedAkci',NULL,0,80,30,NULL,0,N'exec $(FS_CUSTOM).dbo.SelectIVRScript @Id',NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsSelected',N'Color',N'IsSelected',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,40,N'#E0FFFF',0,NULL,N'info',NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'IsUsed',N'Select',N'IsUsed',NULL,NULL,NULL,NULL,NULL,N'IsUsed',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  
 END
GO
   /* ServiceAPP: IVR Step */
  DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'd45fde09-0bf3-4418-bf50-7f11f3e5c0e5'
  DECLARE @DisplayName AS VARCHAR(150) = 'IVR Step'
  DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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

    /* ServiceAPP: TelefonnĂ­ seznamy */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '1ff2043b-8f15-42a8-bb25-27e584b21061'
DECLARE @DisplayName AS VARCHAR(150) = 'PhoneBooks'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
  UPDATE .dbo.DataQuery SET  QueryGroup=@QueryGroup
 WHERE DisplayName = @DisplayName AND QueryGroup='Kontakty'

IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím požádat o nové iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'DisplayName',N'SELECT 
     PhoneBookId AS RecordId
         , ''1'' AS ProvedAkci
         ,[DisplayName]
        ,[Description]
        ,CAST(IIF(PhoneBookId=CONVERT(UniqueIdentifier,$(FS_Custom).dbo.FSC_GiveParam(''SELECTEDPHONEBOOK'')), 1,0) AS bit) AS IsSelected
    FROM .[dbo].[PhoneBook] WITH (NOLOCK)',0,NULL,NULL,NULL,0)
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

  /* ServiceAPP: Seznam telefonních čísel */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '19627bb1-4299-4a30-87ea-63c2e25fb52c'
DECLARE @DisplayName AS VARCHAR(150) = 'List of telephone numbers'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
  UPDATE .dbo.DataQuery SET  QueryGroup=@QueryGroup
 WHERE DisplayName = @DisplayName AND QueryGroup='Kontakty'

IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
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
      from .[dbo].[PhoneNumber] PN WITH (NOLOCK)
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

  /* ServiceAPP: Seznam telefonních čísel pro export */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'f66ff314-27ab-4330-affa-937b005a0b47'
DECLARE @DisplayName AS VARCHAR(150) = 'List of telephone numbers for export'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
  UPDATE .dbo.DataQuery SET  QueryGroup=@QueryGroup
 WHERE DisplayName = @DisplayName AND QueryGroup='Kontakty'

IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'DisplayName ',N'select PN.PhoneNumberId, PN.DisplayName, PN.Description, [Rank]		 
        ,[Numbers]
        ,[Emails]
  	  ,PB.DisplayName AS PhoneBookName
     from .[dbo].[PhoneNumber] PN WITH (NOLOCK)
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

  /* ServiceAPP: Všechny zprávy */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '05d59721-8eed-493d-a88d-a547153aed49'
DECLARE @DisplayName AS VARCHAR(150) = 'Messages'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF Not EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'ServiceAPP - Messages',@QueryGroup,N'TimeUtc DESC',N'SELECT M.MessageId, M.TimeUtc, M.MessageType, M.MessagePhase, M.Direction,    M.FromField, M.ToField, M.ToCcField,
     M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,  M.ProjectId, M.GatewayId, M.AgentId, M.TeamName, M.LanguageId, M.IssueId,  P.DisplayName AS ProjectName, G.DisplayName AS GatewayName,
      A.DisplayName AS AgentName, L.DisplayName AS LanguageName,  ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,  CAST(CASE WHEN MessageResult=''Active'' THEN 1 ELSE 0 END AS bit) AS IsActive, 
       CAST(CASE WHEN MessagePhase=''Draft'' OR MessagePhase=''Received'' THEN 1 ELSE 0 END AS bit) AS IsNew,
       CAST(CASE WHEN (MessagePhase=''Read'' OR MessagePhase=''Received'') AND ReceivedSentTime<@Today THEN 1 ELSE 0 END AS bit) AS IsLate,
         CAST(CASE WHEN EXISTS(SELECT * From Attachment WHERE M.MessageId=Attachment.MessageId) THEN 1 ELSE 0 END AS bit) AS HasAttachment,
    	  ISU.OpenTime AS IsuOpenTime,
              M.RelatedMessageId,
          M.RemoteAddress
    	   FROM Message AS M   LEFT JOIN Project AS P WITH (NOLOCK) ON M.ProjectId=P.ProjectId 
    	    LEFT JOIN Gateway AS G WITH (NOLOCK) ON M.GatewayId=G.GatewayId 
    		 LEFT JOIN Agent AS A WITH (NOLOCK) ON M.AgentId=A.AgentId
    		  LEFT JOIN Language AS L WITH (NOLOCK) ON M.LanguageId=L.LanguageId
    		  LEFT JOIN Issue AS ISU WITH (NOLOCK) ON M.IssueId=ISU.IssueId
    		    LEFT JOIN ScenarioResult AS SR WITH (NOLOCK) ON SR.MessageId=M.MessageId AND (SR.ScenarioId=  ''f1cb5e2f-543f-4cd5-9df1-5365bde8066e'') ',0,NULL,NULL,NULL,0)
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

DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '9fb476c8-1d02-4d17-820b-e5324fafe087'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF Not EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN

/* ServiceAPP: Code Change */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
 VALUES(N'9fb476c8-1d02-4d17-820b-e5324fafe087',N'Code Change',NULL,N'ServiceAPP',N'Timelocal DESC',N'SELECT DISTINCT
      modify_date AS TimeLocal,
      ''$(FS_CUSTOM)'' AS DB
       ,o.Name ,
       o.type_desc,
	   LEFT(Definition,250) AS Definition
  FROM $(FS_CUSTOM).sys.sql_modules m
       INNER JOIN
       $(FS_CUSTOM).sys.objects o
         ON m.object_id = o.object_id
UNION
SELECT DISTINCT
      modify_date AS TimeLocal,
      ''$(MonitorDB)'' AS DB
       ,o.Name ,
       o.type_desc,
	   LEFT(Definition,250) AS Definition
  FROM $(MonitorDB).sys.sql_modules m
       INNER JOIN
       $(MonitorDB).sys.objects o
         ON m.object_id = o.object_id
',0,NULL,NULL,NULL,0,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'ad77bb61-8e63-4d43-aaaf-034d8fe430a0',N'9fb476c8-1d02-4d17-820b-e5324fafe087',N'TimeLocal',N'DateTimeFromTo',N'TimeLocal',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'TimeLocal',NULL,0,100,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'27a3c9eb-16b5-4993-ae7a-ec75c554a280',N'9fb476c8-1d02-4d17-820b-e5324fafe087',N'Name',N'Text',N'Name',NULL,NULL,NULL,NULL,NULL,N'Name',NULL,0,140,30,NULL,0,NULL,NULL,500,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'd10b025f-ad94-4734-ace3-cdee55e80bc2',N'9fb476c8-1d02-4d17-820b-e5324fafe087',N'DB',N'Select',N'DB',NULL,NULL,NULL,NULL,NULL,N'DB',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'd821f824-a054-44da-ac61-1e9dacc0eeb4',N'9fb476c8-1d02-4d17-820b-e5324fafe087',N'type_desc',N'Text',N'type_desc',NULL,NULL,NULL,NULL,NULL,N'type_desc',NULL,0,150,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'd9e4ded5-3e98-4124-b732-fde188c7f405',N'9fb476c8-1d02-4d17-820b-e5324fafe087',N'Definition',N'Text',N'Definition',NULL,NULL,NULL,NULL,NULL,N'Definition',NULL,0,400,90,NULL,0,NULL,NULL,500,NULL,NULL,NULL, NULL)
 END
GO



  /* ServiceAPP: Všechny případy  */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '34137610-1fb2-4b82-a857-2bf1f3c05d08'
DECLARE @DisplayName AS VARCHAR(150) = 'Všechny případy '
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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
UPDATE $(MonitorDB).[dbo].[Dataquery] SET  Deleted=0 WHERE DataQueryId=@DataQueryId AND Deleted=1

IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN

/* ServiceAPP: Detected problems */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'da89c2b0-f74d-4b41-8589-5491c8239a29',N'Detected problems',NULL,N'ServiceAPP',N'Timelocal DESC',N'SELECT TOP (1000) [Timelocal]
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


  /* ServiceAPP: Issue Events */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '6c5e8e3f-37b1-4fc6-8c7d-233efd017f2b'
DECLARE @DisplayName AS VARCHAR(150) = 'Issue Events'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup='ADMIN' )
  UPDATE .dbo.DataQuery SET  QueryGroup=@QueryGroup
 WHERE DisplayName = @DisplayName AND QueryGroup='ADMIN'

--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
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
    FROM $(MonitorDB).[dbo].[IssueEvent] IE
       LEFT JOIN Issue ISU WITH (NOLOCK) ON ISU.IssueId=IE.IssueId
  	 LEFT JOIN Project PROJ WITH (NOLOCK) ON PROJ.ProjectId=ISU.ProjectId
  	 LEFT JOIN Agent AG WITH (NOLOCK) ON IE.AgentId=AG.AgentId
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
  IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_KontSys' OR HashPage='ServiceAPP_KontSys')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'af62bfee-171b-489b-9e29-19232d11d71d', N'ServiceAPP_KontSys', N'Kontrolní systém', NULL, N'fa fa-phone', NULL, N'ServiceAPPPageNav', 5060, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Eventlog","Css":"","DataQuery":{"Id":"0052e9cb-1dd8-4829-ba19-d5a7d410915a","DisplayName":"Eventlog","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Výsledky akcí","Css":"","DataQuery":{"Id":"4c9e5e61-f17a-4ce1-9bb4-441c8ad8f83e","DisplayName":"Výsledky akcí","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":5,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"ServiceAPP příkazy","Css":"","DataQuery":{"Id":"61c8ebc7-e7be-42b2-88b5-578479d8c30a","DisplayName":"ServiceAPP příkazy","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
  IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Kontrolní systém')=1
    UPDATE dbo.Portal SET  DisplayName='Inspection system'
     WHERE DisplayName='Kontrolní systém' AND HashPage='ServiceAPP_KontSys'
 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
    IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Wallboard' OR HashPage='ServiceAPP_Wallboard')
     INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'77547454-f322-4658-b67f-1a9f038231c5', N'ServiceAPP_Wallboard', N'Wallboardy', NULL, N' fa-bar-chart', NULL, N'ServiceAPPPageNav', 5070, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Wallboard","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"d24df1de-5bdd-455c-aed1-1c45279cbd84","DisplayName":"Wallboard","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Wallboard časy","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"1c043f8c-2616-4293-8467-2422bf171ae7","DisplayName":"Wallboard časy","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
    IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Wallboardy')=1
     UPDATE dbo.Portal SET  DisplayName='Wallboards'
      WHERE DisplayName='Wallboardy' AND HashPage='ServiceAPP_Wallboard'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE PortalId='a941d991-9d2e-427f-b230-443b4445b041')--HashPage='Admin_IVR'OR HashPage='ServiceAPP_IVR')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
    VALUES (N'a941d991-9d2e-427f-b230-443b4445b041', N'ServiceAPP_IVR', N'IVR', NULL, N'fa fa-phone', NULL, N'ServiceAPPPageNav', 5050, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"IVR Skripty","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"b36e3ad0-c8e3-4083-a23a-0e18686076b6","DisplayName":"IVR Skripty","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"IVR Step","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"d45fde09-0bf3-4418-bf50-7f11f3e5c0e5","DisplayName":"IVR Step","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"873404dd-0641-46b0-b8f4-3f6b33bf348c","DisplayName":"Zkopírování vybraných kroků do vybraného skriptu","SpecificName":"ServiceAPP","Glyph":"fa fa-thermometer-full","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-thermometer-full",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
  END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Wallboard' OR HashPage='ServiceAPP_Hovory')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
	 VALUES (N'49dfe157-4a6f-4656-8bde-56499183d4d2', N'ServiceAPP_Hovory', N'Hovory', NULL, N'fa fa-phone', NULL, N'ServiceAPPPageNav', 5010, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Inbound Calls","Css":"","DataQuery":{"Id":"99cecf13-c463-4abd-a52e-ad923d51ac7c","DisplayName":"Inbound Calls","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"ServiceAPP: Události příchozího ","Css":"","DataQuery":{"Id":"354e10a1-14f7-4f66-b1aa-9b7ffee2b91f","DisplayName":"Události příchozího ","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"DataQueryGrid","Path":"A","Index":"E","DisplayName":"ServiceAPP: Outbound Calls","Css":"","DataQuery":{"Id":"ce85ccb8-d497-40ab-a067-e1561d4d7ab6","DisplayName":"Outbound Calls","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"DataQueryGrid","Path":"A","Index":"F","DisplayName":"ServiceAPP: Outbound Call Events","Css":"","DataQuery":{"Id":"354e10a1-14f7-4f66-b1aa-9b7ffee2b91f","DisplayName":"Outbound Call Events","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"ServiceAPP: Recordings","Css":"","DataQuery":{"Id":"68df515a-31d7-4137-b661-9ce2c40a601a","DisplayName":"Recordings","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Hovory' AND HashPage='ServiceAPP_Hovory')=1
      UPDATE dbo.Portal SET  DisplayName='Calls'
       WHERE DisplayName='Hovory' AND HashPage='ServiceAPP_Hovory'
 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_FrontaHovoru' OR HashPage='ServiceAPP_FrontaHovoru')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
     VALUES (N'd0c44ccf-5260-4b1b-8f8e-a52a3fe10073', N'ServiceAPP_FrontaHovoru', N'Fronta hovorů', NULL, N'fa fa-align-left', NULL, N'ServiceAPPPageNav', 5080, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Vyšetřování fronty","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"832e1da3-c87e-4e51-a7a6-ca1ec2abcdfd","DisplayName":"Vyšetřování fronty","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Volní agenti","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"9e103b6f-379b-417c-8ec7-2361ef3124ed","DisplayName":"Volní agenti","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Volní agenti seznam","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"50baed36-ca55-46b5-a971-45996d7b52f0","DisplayName":"Volní agenti seznam","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Fronta hovorů' AND HashPage='ServiceAPP_FrontaHovoru')=1
      UPDATE dbo.Portal SET  DisplayName='Queue of Calls'
       WHERE DisplayName='Fronta hovorů' AND HashPage='ServiceAPP_FrontaHovoru'
  END
 GO
IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
 BEGIN
  IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_FrontaMailu' OR HashPage='ServiceAPP_FrontaMailu')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
	 VALUES (N'16f6e129-53e1-4c83-8340-e85b888f7714', N'ServiceAPP_FrontaMailu', N'Fronta mailů', NULL, N'fa fa-align-left', NULL, N'ServiceAPPPageNav', 5082, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"ServiceAPP: Všechny zprávy e-mailové fronty","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"98e73265-c1e5-4a7c-938f-fd69ccee3439","DisplayName":"Všechny zprávy e-mailové fronty","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"ServiceAPP: VolniAgentiProMail","Css":"col-md-4 col-sm-4 col-xs-4","DataQuery":{"Id":"e67f9717-e912-4f37-8c81-ead7c65c7800","DisplayName":"VolniAgentiProMail","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"ServiceAPP: Přiřazené zprávy agentům","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"f2e2995f-40ad-4fdc-a3ee-27716a48a96b","DisplayName":"Přiřazené zprávy agentům","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null}]')
  IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Fronta mailů' AND HashPage='ServiceAPP_FrontaMailu')=1
      UPDATE dbo.Portal SET  DisplayName='Queue of Emails'
       WHERE DisplayName='Fronta mailů' AND HashPage='ServiceAPP_FrontaMailu'

END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE PortalId='873b377f-11b3-4142-9063-b7db635d52d0')--HashPage='Admin_DQ' OR HashPage='ServiceAPP_DQ')
 BEGIN

INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) VALUES (N'873b377f-11b3-4142-9063-b7db635d52d0', N'ServiceAPP_DQ', N'Data Query', NULL, N'fa fa-calendar', NULL, N'ServiceAPPPageNav', 5030, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Datové dotazy","Css":"","DataQuery":{"Id":"e5fe7ca3-06f1-46a4-9771-09cb4bfc43eb","DisplayName":"Datové dotazy","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Sloupce dotazů","Css":"","DataQuery":{"Id":"d1f1f295-8801-423b-aafd-9222ee4892fc","DisplayName":"Sloupce dotazů","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null}]')
 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Email' OR HashPage='ServiceAPP_Message')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
	 VALUES (N'7f649a00-6cda-47f5-a600-dcd4195f1051', N'ServiceAPP_Message', N'Emaily', NULL, N'fa fa-envelope', NULL, N'ServiceAPPPageNav', 5040, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner hlavni","Css":"col-md-12 col-sm-12 col-xs-12","FixedTopHeight":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Všechny zprávy","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"05d59721-8eed-493d-a88d-a547153aed49","DisplayName":"Všechny zprávy","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"MessageEvent","Css":"","DataQuery":{"Id":"2f0fd1d8-017a-4a7c-be35-a8c02f46007d","DisplayName":"MessageEvent","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":true,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Emaily' AND HashPage='Admin_Email')=1
      UPDATE dbo.Portal SET  DisplayName='Emails'
       WHERE DisplayName='Emaily' AND HashPage='Admin_Email'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE PortalId='01de7c4a-d813-4031-84f6-ee3d561ccab9')--HashPage='Admin_Agenti' OR HashPage='ServiceAPP_Agenti')
     INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
	  VALUES (N'01de7c4a-d813-4031-84f6-ee3d561ccab9', N'ServiceAPP_Agenti', N'Agenti', NULL, N'fa fa-users', NULL, N'ServiceAPPPageNav', 5020, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"List of Agents","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"ec5174c1-ad19-4423-8fff-ae043dc92627","DisplayName":"List of Agents","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Výsledky akcí","Css":"","DataQuery":{"Id":"4c9e5e61-f17a-4ce1-9bb4-441c8ad8f83e","DisplayName":"Výsledky akcí","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Simple","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Agenti' AND HashPage='ServiceAPP_Agenti')=1
      UPDATE dbo.Portal SET  DisplayName='Agents'
       WHERE DisplayName='Agenti' AND HashPage='ServiceAPP_Agenti'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='Admin_Kontakt' OR HashPage='ServiceAPP_Kontakt') 
     INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
	  VALUES (N'014288d4-c3fe-433e-93da-fde0fce3c0e0', N'ServiceAPP_Kontakt', N'ServiceAPP', NULL, N'fa fa-address-card', NULL, N'ServiceAPPPageNav', 5055, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Telefonní seznamy","Css":"","DataQuery":{"Id":"1ff2043b-8f15-42a8-bb25-27e584b21061","DisplayName":"Telefonní seznamy","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Seznam telefonních čísel","Css":"","DataQuery":{"Id":"19627bb1-4299-4a30-87ea-63c2e25fb52c","DisplayName":"Seznam telefonních čísel","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"D","DisplayName":"Seznam telefonních čísel pro export","Css":"","DataQuery":{"Id":"f66ff314-27ab-4330-affa-937b005a0b47","DisplayName":"Seznam telefonních čísel pro export","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='ServiceAPP' AND HashPage='ServiceAPP_Kontakt')=1
      UPDATE dbo.Portal SET  DisplayName='Contacts'
       WHERE DisplayName='ServiceAPP' AND HashPage='ServiceAPP_Kontakt'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
  BEGIN
   IF EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE HashPage='admin_pripady' AND PortalId<>'f007b5da-21c9-499f-b781-88a8950c98a9')
   DELETE FROM $(MonitorDB).dbo.Portal WHERE HashPage='admin_pripady' 
 END
GO
IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
 BEGIN
   IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE PortalId='f007b5da-21c9-499f-b781-88a8950c98a9')-- HashPage='admin_pripady' OR HashPage='ServiceAPP_pripady')
    INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
     VALUES (N'f007b5da-21c9-499f-b781-88a8950c98a9', N'ServiceAPP_pripady', N'Případy', N'Případy', N'fa fa-briefcase', NULL, N'ServiceAPPPageNav', 5045, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Všechny případy ","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"34137610-1fb2-4b82-a857-2bf1f3c05d08","DisplayName":"Všechny případy ","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Issue Events","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"6c5e8e3f-37b1-4fc6-8c7d-233efd017f2b","DisplayName":"Issue Events","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":false,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"MessageSend":null,"SmsSend":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"CallOutBulk":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]')
   IF (SELECT TOP 1 1 FROM [dbo].[Portal] WHERE DisplayName='Případy' AND HashPage='ServiceAPP_pripady')=1
      UPDATE dbo.Portal SET  DisplayName='Issues'
       WHERE DisplayName='Případy' AND HashPage='ServiceAPP_pripady'

 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
 IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE  PortalId='9ff03aae-a127-47e1-8a41-d491de622d2f')--HashPage='admin_ExpImp' OR HashPage='ServiceAPP_ExpImp')
 BEGIN
   INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData]) 
   VALUES (N'9ff03aae-a127-47e1-8a41-d491de622d2f', N'ServiceAPP_expimp', N'Export/Import', N'Export/Import', N'fa fa-exchange', NULL, N'ServiceAPPPageNav', 5090, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":true,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels","ManualActionExecuteTypes":[],"ManualActions":[null,null,null,null,null,null,null,null,null,null],"ManualActionGlyphs":[null,null,null,null,null,null,null,null,null,null],"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true}]')
 END
 GO
 IF OBJECT_ID (N'Portal', N'U') IS NOT NULL 
 IF NOT EXISTS (SELECT TOP 1 1 FROM .[dbo].[Portal] WHERE   PortalId='2b25c09d-ad82-4472-9b38-49fe3074d82b')--HashPage='Admin_Record' OR HashPage='ServiceAPP_Wallboard')
 BEGIN
  INSERT [dbo].[Portal] ([PortalId], [HashPage], [DisplayName], [Description], [Glyph], [KbTagId], [NavGroup], [Rank], [TimeOut], [JsonData])
   VALUES (N'2b25c09d-ad82-4472-9b38-49fe3074d82b', N'ServiceAPP_Record', N'Recordings', N'Recordings', N'fa fa-microphone', NULL, N'ServiceAPPPageNav', 5092, NULL, N'[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"ServiceAPP Recordingless Calls","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"a12aae6c-caef-4ba1-a117-221b2a6c1f75","DisplayName":"ServiceAPP Recordingless Calls","SpecificName":"ServiceAPP","Glyph":"fa fa-database","Flag1":0},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"AgentStatusChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Percents","ManualActionExecuteTypes":[],"ManualActions":null,"ManualActionGlyphs":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionDefinitions":[null,null,null,null,null,null,null,null,null,null],"OriginalDisplayName":"ServiceAPP Recordingless Calls"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true}]')
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
      [JsonData] = '[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"33047afb-6685-4587-9c8f-ab889675a20a","DisplayName":"Export vybraných modulů","SpecificName":"ServiceAPP","Glyph":"fa fa-arrow-left","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Catalog","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"26b70734-8b02-44ad-a71c-90708690c3d3","DisplayName":"Catalog","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"ddc01671-d175-4de6-920f-541c8c4e7c8f","DisplayName":"Přepis vybraných modulů","SpecificName":"ServiceAPP","Glyph":"fa fa-arrow-left","Flag1":0},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]''[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"33047afb-6685-4587-9c8f-ab889675a20a","DisplayName":"Export vybraných modulů","SpecificName":"ServiceAPP","Glyph":"fa fa-arrow-left","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Catalog","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"26b70734-8b02-44ad-a71c-90708690c3d3","DisplayName":"Catalog","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"ddc01671-d175-4de6-920f-541c8c4e7c8f","DisplayName":"Přepis vybraných modulů","SpecificName":"ServiceAPP","Glyph":"fa fa-arrow-left","Flag1":0},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]''[{"Type":"Container","Path":"","Index":"A","DisplayName":"Kontejner","Css":"col-md-12 col-sm-12 col-xs-12"},{"Type":"Navigation","Path":"A","Index":"A","DisplayName":"Navigace","Css":"col-md-12 col-sm-12 col-xs-12","Orientation":"HorizontalPills","ShowLabels":true},{"Type":"DataQueryGrid","Path":"A","Index":"B","DisplayName":"Data Query usage","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6","DisplayName":"Data Query usage","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"33047afb-6685-4587-9c8f-ab889675a20a","DisplayName":"Export vybraných modulů","SpecificName":"ServiceAPP","Glyph":"fa fa-arrow-left","Flag1":"0"},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":["0",0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"},{"Type":"DataQueryGrid","Path":"A","Index":"C","DisplayName":"Catalog","Css":"col-md-12 col-sm-12 col-xs-12","DataQuery":{"Id":"26b70734-8b02-44ad-a71c-90708690c3d3","DisplayName":"Catalog","SpecificName":"ServiceAPP","Glyph":"fa fa-check-square","Flag1":1},"PageSize":20,"FixedSize":false,"FilteredOnly":false,"RefreshPeriod":null,"ShowActionTriggerName":true,"ShowTitle":"Block","ShowHeader":"Block","ShowFilters":"Block","ShowFooter":"Block","OnCallNotify":false,"UseCallId":false,"OnCallAnswer":false,"OnCallEnd":false,"OnStateChange":false,"OnChatAlert":false,"OnChatEnd":false,"OnChatStatusChange":false,"ManualAction1":null,"ManualAction2":null,"ManualAction3":null,"ManualAction4":null,"ManualAction5":null,"ManualAction6":null,"ManualAction7":null,"ManualAction8":null,"ManualAction9":null,"ManualAction10":null,"ManualActions":[{"Id":"ddc01671-d175-4de6-920f-541c8c4e7c8f","DisplayName":"Přepis vybraných modulů","SpecificName":"ServiceAPP","Glyph":"fa fa-arrow-left","Flag1":0},null,null,null,null,null,null,null,null,null],"ResetToggleAfter":false,"ManualAction1Glyph":null,"ManualAction2Glyph":null,"ManualAction3Glyph":null,"ManualAction4Glyph":null,"ManualAction5Glyph":null,"ManualAction6Glyph":null,"ManualAction7Glyph":null,"ManualAction8Glyph":null,"ManualAction9Glyph":null,"ManualAction10Glyph":null,"ManualActionGlyphs":["fa fa-arrow-left",null,null,null,null,null,null,null,null,null],"ManualActionExecuteTypes":[0,0,0,0,0,0,0,0,0,0],"AgentStatusChange":null,"AgentBusyConditionChange":null,"AgentBarDataQueryChange":null,"AgentProjectGroupChange":null,"AgentLangChange":null,"MessageAssignReturn":null,"MessageChangeMeta":null,"MessageForward":null,"MessageReply":null,"IssueAssignReturn":null,"CallInAssignReturn":null,"CallOutAssignReturn":null,"ChatChangeMeta":null,"StatusBlockingChange":null,"QueueWaitingOffset":null,"ColumnsHeaderVerically":null,"HeightOfVerticalColumnsInHeader":null,"ColumnWidthUnit":"Pixels"}]'
   WHERE 1=2 AND HAShPAGe='ServiceAPP_expimp' and NavGroup='ServiceAPPPageNav'
GO

  /* ServiceAPP: Sloupce dotazů */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '1ccce0b7-3447-4822-bc5e-254a07fde056'
UPDATE $(MonitorDB).dbo.Dataquery SET Deleted = 0 WHERE DataQueryId=@DataQueryId
DECLARE @DisplayName AS VARCHAR(150) = 'Sloupce dotazů'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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
    inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
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


  /* ServiceAPP: Datové dotazy */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'bce5b69c-6335-4d01-a620-33c44b891801'
UPDATE $(MonitorDB).dbo.Dataquery SET Deleted = 0 WHERE DataQueryId=@DataQueryId

DECLARE @DisplayName AS VARCHAR(150) = 'Data queries'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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
        FROM $(MonitorDB).[dbo].[DataQuery] WHERE Deleted=0',0,NULL,NULL,NULL,0)
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

  /* ServiceAPP: MessageEvent */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '2f0fd1d8-017a-4a7c-be35-a8c02f46007d'
DECLARE @DisplayName AS VARCHAR(150) = 'MessageEvent'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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
  /* ServiceAPP: Všechny zprávy */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '05d59721-8eed-493d-a88d-a547153aed49'
DECLARE @DisplayName AS VARCHAR(150) = 'Všechny zprávy'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'ServiceAPP - zprávy',@QueryGroup,N'TimeUtc DESC',N'SELECT M.MessageId, M.TimeUtc, M.MessageType, M.MessagePhase, M.Direction,    M.FromField, M.ToField, M.ToCcField,
     M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,  M.ProjectId, M.GatewayId, M.AgentId, M.TeamName, M.LanguageId, M.IssueId,  P.DisplayName AS ProjectName, G.DisplayName AS GatewayName,
      A.DisplayName AS AgentName, L.DisplayName AS LanguageName,  ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,  CAST(CASE WHEN MessageResult=''Active'' THEN 1 ELSE 0 END AS bit) AS IsActive, 
       CAST(CASE WHEN MessagePhase=''Draft'' OR MessagePhase=''Received'' THEN 1 ELSE 0 END AS bit) AS IsNew,
       CAST(CASE WHEN (MessagePhase=''Read'' OR MessagePhase=''Received'') AND ReceivedSentTime<@Today THEN 1 ELSE 0 END AS bit) AS IsLate,
         CAST(CASE WHEN EXISTS(SELECT * From Attachment WHERE M.MessageId=Attachment.MessageId) THEN 1 ELSE 0 END AS bit) AS HasAttachment,
    	  ISU.OpenTime AS IsuOpenTime,
              M.RelatedMessageId,
          M.RemoteAddress
    	   FROM Message AS M   LEFT JOIN Project AS P WITH (NOLOCK) ON M.ProjectId=P.ProjectId 
    	    LEFT JOIN Gateway AS G WITH (NOLOCK) ON M.GatewayId=G.GatewayId 
    		 LEFT JOIN Agent AS A WITH (NOLOCK) ON M.AgentId=A.AgentId
    		  LEFT JOIN Language AS L WITH (NOLOCK) ON M.LanguageId=L.LanguageId
    		  LEFT JOIN Issue AS ISU WITH (NOLOCK) ON M.IssueId=ISU.IssueId
    		    LEFT JOIN ScenarioResult AS SR WITH (NOLOCK) ON SR.MessageId=M.MessageId AND (SR.ScenarioId=  ''f1cb5e2f-543f-4cd5-9df1-5365bde8066e'') ',0,NULL,NULL,NULL,0)
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
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'

 IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId='2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6'/*DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0*/)
 BEGIN

 /* ServiceAPP: Data Query usage */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'2ecaa8bb-0e67-4f5e-817a-7dd0e020c2c6',N'Data Query usage',NULL,N'ServiceAPP',N'PageName,NAVGroup,DataQueryId',N'SELECT 
      [DataQueryId] AS RecordId
      ,ISNULL(PRT.DisplayName,''--- Nepoužito ---'') AS PageName
      ,PRT.NAVGroup
      ,PRT.HashPage
      ,[DataQueryId]
      ,DQ.DisplayName AS QueryName
      ,DQ.[Description]
      ,[QueryGroup]
  FROM $(MonitorDB).[dbo].[DataQuery] DQ
    LEFT JOIN .[dbo].[Portal] PRT WITH (NOLOCK) ON PRT.JsonData LIKE ''%''+CONVERT(NVARCHAR(36),DQ.DataQueryId)+''%''
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
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'a10ad2c8-64cb-4aff-b937-69cffe292dba'

UPDATE $(MonitorDB).[dbo].[Dataquery] SET  Deleted=0 WHERE DataQueryId=@DataQueryId AND Deleted=1
 IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE [DataQueryId]=@DataQueryId/*DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0*/)
 BEGIN

 /* ServiceAPP: Web Admin Changes */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'a10ad2c8-64cb-4aff-b937-69cffe292dba',N'Web Admin Changes',N'over WebAdmin app',N'ServiceAPP',N'TimeUTC DESC',N'SELECT  [WebAdminEventId]
      ,AG.DisplayName AS AgentName
      ,[TimeUtc]
      ,[TableNames]
      ,[RefInserts]
      ,[RefUpdates]
      ,[RefDeletes]
      --,[AgentId]
  FROM .[dbo].[WebAdminEvent] WAE
    LEFT JOIN .[dbo].Agent AG WITH (NOLOCK) ON AG.AgentId=WAE.AgentId
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
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '26b70734-8b02-44ad-a71c-90708690c3d3'
-- IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId  = @DataQueryId)
 BEGIN

 /* ServiceAPP: Catalog */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'26b70734-8b02-44ad-a71c-90708690c3d3',N'Catalog',NULL,N'ServiceAPP',N'HashPage,Section,ModulName',N'SELECT 
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

DECLARE @DisplayName AS VARCHAR(150) = 'ServiceAPP commands'
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '61c8ebc7-e7be-42b2-88b5-578479d8c30a'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId  = @DataQueryId )
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

--DECLARE @DisplayName AS VARCHAR(150) = 'ServiceAPP commands'
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'e99a0890-1e80-4c3f-b007-a50df3438736'
--DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId  = @DataQueryId  AND Deleted=0)
 BEGIN

/* Sup_Portal: Supervisor Commands */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
 VALUES(N'e99a0890-1e80-4c3f-b007-a50df3438736',N'Supervisor Commands',NULL,N'Sup_Portal',N'Description',N'SELECT CommandId AS RecordId
             , ''1'' AS ProvedAkci
             ,Description
        FROM $(FS_Custom).dbo.Commands 
WHERE GroupName=''SUPER''
     ',0,NULL,NULL,NULL,0,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'86350c72-2539-4bc1-83b9-25f2e0767a26',N'e99a0890-1e80-4c3f-b007-a50df3438736',N'Perform',N'ImageScript',N'ProvedAkci',N'~/CustomImages/{0}.png',N'RecordId',NULL,NULL,NULL,N'ProvedAkci',NULL,0,70,3,NULL,0,N'exec $(FS_CUSTOM).dbo.RunScript @Id',NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'2f3df0e6-6a40-4d66-97e7-2f6b54d11ad0',N'e99a0890-1e80-4c3f-b007-a50df3438736',N'Description',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,600,340,NULL,0,NULL,NULL,500,NULL,NULL,NULL, NULL)
 END

GO

 /* ServiceAPP: Wallboard */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '372f67e1-c08d-49da-a1ce-89e875a1d68b'
DECLARE @DisplayName AS VARCHAR(150) = 'Wallboard'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'Wallboard',@QueryGroup,N'Popis',N'SELECT ''Zombie hovory'' AS Popis, COUNT(1) AS Pocet FROM .[dbo].[InboundCall]
    WHERE 1=1
      AND Callresult=''Active''
      AND CallPhase=''Distributing''
      AND PilotTime < DATEADD(Minute,-20,GETDATE())
    UNION ALL
    SELECT ''Změna agenta při distribuci příchozího hovoru za poslední 2 hodiny'' AS Popis, COUNT(1) AS Value
      FROM .[dbo].[CallEvent] CAE
        LEFT JOIN .[dbo].[CallEvent] CAE2 WITH (NOLOCK) ON CAE.InboundCallId=CAE2.InboundCallId
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

  /* ServiceAPP: Wallboard časy */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '1c043f8c-2616-4293-8467-2422bf171ae7'
DECLARE @DisplayName AS VARCHAR(150) = 'Wallboard Times'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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



 /* ServiceAPP: RecordingLess Calls */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'a12aae6c-caef-4ba1-a117-221b2a6c1f75'
DECLARE @DisplayName AS VARCHAR(150) = 'ServiceAPP Recordingless Calls'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId  = @DataQueryId  AND Deleted=0)
 BEGIN
 INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'ServiceAPP Recordingless Calls',N'Recordingless Calls Today',N'ServiceAPP',N'CallTime DESC',N'SELECT * FROM $(FS_Custom).[dbo].[RecordingLessCalls] (DATEADD(Day,-10,@Today), @Now)',0,NULL,NULL,NULL,0)
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
UPDATE $(MonitorDB).dbo.DataQuery
SET  QueryText='SELECT * FROM $(FS_CUSTOM).[dbo].[RecordingLessCalls] (DATEADD(Day,-2,@Today),@Now)'
WHERE DataQueryId  = @DataQueryId  AND Deleted=0 AND QueryText NOT LIKE '%RecordingLessCalls%'

GO


 /* ServiceAPP: Eventlog */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '8cac0b68-a27a-4388-ba71-7bf8b1de42d3'
DECLARE @DisplayName AS VARCHAR(150) = 'Eventlog'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup='ADMIN' )
  UPDATE .dbo.DataQuery SET  QueryGroup=@QueryGroup
 WHERE DisplayName = @DisplayName AND QueryGroup='ADMIN'

IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE (DisplayName = @DisplayName AND QueryGroup=@QueryGroup) OR DataQueryId=@DataQueryId)
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
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WHERE DataQueryId = @DataQueryId)
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
LEFT JOIN Project AS P WITH (NOLOCK) ON M.ProjectId=P.ProjectId
LEFT JOIN Gateway AS G WITH (NOLOCK) ON M.GatewayId=G.GatewayId
LEFT JOIN Agent AS A WITH (NOLOCK) ON M.AgentId=A.AgentId
LEFT JOIN Language AS L WITH (NOLOCK) ON M.LanguageId=L.LanguageId
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

  /* ServiceAPP: VolniAgentiProMail */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'e67f9717-e912-4f37-8c81-ead7c65c7800'
DECLARE @DisplayName AS VARCHAR(150) = 'VolniAgentiProMail'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
--IF EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB)dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB)dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WHERE DataQueryId = @DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,N'ServiceAPP',@QueryGroup,N'AgentName',N'select
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
  /* ServiceAPP: Přiřazené zprávy agentům */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'f2e2995f-40ad-4fdc-a3ee-27716a48a96b'
DECLARE @DisplayName AS VARCHAR(150) = 'Přiřazené zprávy agentům'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WHERE DataQueryId = @DataQueryId)

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
      LEFT JOIN Project AS P WITH (NOLOCK) ON M.ProjectId=P.ProjectId
      LEFT JOIN Gateway AS G WITH (NOLOCK) ON M.GatewayId=G.GatewayId
      LEFT JOIN Agent AS A WITH (NOLOCK) ON M.AgentId=A.AgentId
      LEFT JOIN Language AS L WITH (NOLOCK) ON M.LanguageId=L.LanguageId
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

  /* ServiceAPP: Výsledky akcí */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '4c9e5e61-f17a-4ce1-9bb4-441c8ad8f83e'
DECLARE @DisplayName AS VARCHAR(150) = 'Výsledky akcí'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
--IF EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB)dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB)dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
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
  /* ServiceAPP: Gateways Monitor */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '4eff4b79-581e-41df-a62a-ceaee89ad0f5'
DECLARE @DisplayName AS VARCHAR(150) = 'Gateways Monitor'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'GateWayName',N'SELECT 
    Phase2.GatewayId AS RecordId
    ,Phase2.GatewayId
    ,ISNULL(GW.DisplayName,''BEZ BRÁNY'') AS GateWayName
    ,PilotAddress
    ,Received
    ,Sent
    ,Scheduled
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
	  ,SUM(Scheduled) AS Scheduled
    FROM 
  (SELECT       
  	  GatewayId
      ,SUM(IIF(Direction=''I'',1,0)) AS Received
  	  ,SUM(IIF(Direction=''O'' AND MessagePhase=''Sent'',1,0)) AS Sent
	  ,0 AS Scheduled
       -- ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId=GW.GateWayId AND TimeUTC>@from AND Direction=''O'' AND MessagePhase=''Sent'') AS OdeslanychZprav
     FROM .[dbo].[Message] ME
    WHERE ReceivedSentTime > DATEADD(Hour,-2,@Now)
    GROUP BY GatewayId
   UNION
    SELECT       
  	  GatewayId
      ,0 AS Received
  	  ,0 AS Sent
  	  ,SUM(1) AS Scheduled
     FROM .[dbo].[Message] ME
    WHERE Direction=''O'' AND MessagePhase=''Scheduled''
    GROUP BY GatewayId

    UNION
    SELECT
  	  GatewayId
        ,0 AS Received
  	  ,0 AS Sent
	  ,0 AS Scheduled
       -- ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId=GW.GateWayId AND TimeUTC>@from AND Direction=''O'' AND MessagePhase=''Sent'') AS OdeslanychZprav
     FROM .[dbo].[Gateway] GW WHERE Deleted=0
    ) AS Phase1
    GROUP BY GatewayId
    ) AS Phase2
       INNER JOIN .[dbo].[Gateway] GW WITH (NOLOCK) ON GW.GatewayId=Phase2.GatewayId AND GW.Deleted=0
 
   
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
  INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (N'efdb1df5-bede-4c3b-895c-ea28b2458a14',N'4eff4b79-581e-41df-a62a-ceaee89ad0f5',N'Scheduled',N'Integer',N'Scheduled',NULL,NULL,NULL,NULL,NULL,N'Scheduled',NULL,0,60,35,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
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
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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

/* ServiceAPP: Volní agenti seznam */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'c593a564-8a5f-48dd-a22a-f2a06ea51084'
DECLARE @DisplayName AS VARCHAR(150) = 'Volní agenti seznam'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN

INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'c593a564-8a5f-48dd-a22a-f2a06ea51084',N'Volní agenti seznam',NULL,N'ServiceAPP',N'AgentName',N'	SELECT  DISTINCT
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
  /* ServiceAPP: vysetrovani­ fronty */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '2bd46080-ce8d-4c10-8b4d-3772417f57d8'
DECLARE @DisplayName AS VARCHAR(150) = 'Calls Queue investigation'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
--IF EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím požádat o nové iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM $(MonitorDB).dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup)
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
    FROM $(MonitorDB).dbo.InboundCall IC WITH (NOLOCK)
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
  /* ServiceAPP: Všechny pøíchozí hovory */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '99cecf13-c463-4abd-a52e-ad923d51ac7c'
DECLARE @DisplayName AS VARCHAR(150) = 'Inbound Calls'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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
  /* ServiceAPP: Události pøíchozího hovoru */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '882362dc-f36f-4248-ad4d-64d1a883e91a'
DECLARE @DisplayName AS VARCHAR(150) = 'Inbound Call Events'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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
       LEFT JOIN IvrStep AS IVRST WITH (NOLOCK) ON IVRST.IvrStepId=CAE.ReferenceId
       LEFT JOIN IvrScript AS IVRSC WITH (NOLOCK) ON IVRST.IvrScriptId=IVRSC.IvrScriptId
       LEFT JOIN Project AS PR WITH (NOLOCK) ON PR.ProjectId=CAE.ProjectId
  	 LEFT JOIN Agent AS AG WITH (NOLOCK) ON AG.AgentId=CAE.AgentId
  	 LEFT JOIN Workplace AS WP WITH (NOLOCK) ON WP.WorkPlaceId=CAE.WorkPlaceId
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
  /* ServiceAPP: Recordings */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '68df515a-31d7-4137-b661-9ce2c40a601a'
DECLARE @DisplayName AS VARCHAR(150) = 'Recordings'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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
        ,IIF(AgentName IS NULL,''NO'',''YES'') AS Sparovano
        ,[FileName]
        ,[Direction]
        ,[LocalNumber]
        ,[LocalName]
        ,[RemoteNumber]
        ,[RemoteName]
        ,[ExtensionNumber]
         ,[AgentName]
        ,[StationName]
     FROM $(SREC).[dbo].[VoiceRecord]',0,NULL,NULL,NULL,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'VoiceRecordId',N'Text',N'VoiceRecordId',NULL,NULL,NULL,NULL,NULL,N'VoiceRecordId',NULL,0,230,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Direction',N'Text',N'Direction',NULL,NULL,NULL,NULL,NULL,N'Direction',NULL,0,40,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@DataQueryId,N'Paired',N'Select',N'Sparovano',NULL,NULL,NULL,NULL,NULL,N'Sparovano',NULL,0,80,9,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
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

  /* ServiceAPP: Outbound Calls */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '1c26d83f-642e-4ef7-b31e-e7d5ec74e804'
DECLARE @DisplayName AS VARCHAR(150) = 'Outbound Calls'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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
       IIF (EXISTS(SELECT TOP 1 1 FROM $(MonitorDB).[dbo].[CallRecord] CR WHERE C.OutboundCallId=CR.OutboundCallId),''ANO'',''NE'') AS Sparovano
  ,IssueId
        FROM .dbo.OutboundCall AS C  WITH (NOLOCK)
        LEFT JOIN Project AS P WITH (NOLOCK) ON C.ProjectId=P.ProjectId
        LEFT JOIN Agent AS A WITH (NOLOCK) ON C.AgentId=A.AgentId
        LEFT JOIN Language AS L WITH (NOLOCK) ON C.LanguageId=L.LanguageId
        LEFT JOIN Workplace AS W WITH (NOLOCK) ON C.WorkplaceId=W.WorkplaceId
        LEFT JOIN OutboundList AS OL WITH (NOLOCK) ON OL.OutboundListId = C.OutboundListId
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

  /* ServiceAPP: Outbound Call Events */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '354e10a1-14f7-4f66-b1aa-9b7ffee2b91f'
DECLARE @DisplayName AS VARCHAR(150) = 'Outbound Call Events'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
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
         LEFT JOIN Agent AS AG WITH (NOLOCK) ON AG.AgentId=CAE.AgentId
         LEFT JOIN Agent AS AG2 WITH (NOLOCK) ON AG2.AgentId=CAE.ActorId
        
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
  /* ServiceAPP: Pøehled agentù ServiceAPP */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = 'e61147d7-3aef-402c-b551-e9f8af55847e'
UPDATE $(MonitorDB).dbo.Dataquery SET Deleted = 0 WHERE DataQueryId=@DataQueryId
DECLARE @DisplayName AS VARCHAR(150) = 'List of Agents'
DECLARE @QueryGroup AS VARCHAR(50) = 'ServiceAPP'
--IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
--  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
--IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine])
  VALUES(@DataQueryId,@DisplayName,NULL,@QueryGroup,N'TeamName, AgentName',N' SELECT AG.AgentId ,AG.AgentId AS RecordId,ST.StatusId
            , ''1'' AS RESETPers
  		  , IIF(EXISTS(SELECT TOP 1 1 FROM ASPNET_iCC.dbo.aspnet_Users AU 
  		                 INNER JOIN [ASPNET_iCC].[dbo].[aspnet_PersonalizationPerUser] AP WITH (NOLOCK) ON AU.UserId=AP.UserId WHERE AU.UserName=AG.SystemName
  		  ),''ANO'',''NE'') AS ExPerso
  
            , SystemName
      	,W.Number AS Extension
            ,IIF(AG.Activity=''Logoff'',''NE '',''ANO'') AS V_Praci
      	,AG.DisplayName AS AgentName, AG.TeamName
      --,(SELECT $(FS_Custom).dbo.GetFirstLogonTime(AG.AgentId, @Today)) AS FirstLogonTime
      	--,$(FS_CUSTOM).dbo.GetCurrentStateLength3(AG.AgentId, @Now) AS StateLength
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

/* ServiceAPP: Monitoring System */
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId='77f81f33-c8a9-4883-a480-c3d29d8541cc')
 BEGIN

INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
 VALUES(N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'Monitoring System',NULL,N'ServiceAPP',N'Rank DESC',N'SELECT  *  FROM $(FS_CUSTOM).dbo.Monitor',0,NULL,NULL,NULL,0,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'f662fd34-2447-4651-8e1f-44dc5a07e6c8',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'DisplayName',N'Text',N'DisplayName',NULL,NULL,NULL,NULL,NULL,N'DisplayName',NULL,0,160,10,NULL,0,NULL,NULL,500,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'94374982-4feb-43bb-a398-6865df64b3e0',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'Command',N'Text',N'Command',NULL,NULL,NULL,NULL,NULL,N'Command',NULL,0,120,20,NULL,0,NULL,NULL,500,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'aac25e88-7a22-4620-88cc-7a2975ac7b13',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'ExecDuration',N'Duration',N'ExecDuration',NULL,NULL,NULL,NULL,NULL,N'ExecDuration',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'fbc910c7-c105-47ec-a19b-cb856f658c78',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'LastRunTime',N'DateTimeFromTo',N'LastRunTime',N'{0:dd.MM.yy HH:mm:ss}',NULL,NULL,NULL,NULL,N'LastRunTime',NULL,0,100,35,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'f87826d6-c07f-4154-8fc1-487f663faacd',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'LastMessage',N'Text',N'LastMessage',NULL,NULL,NULL,NULL,NULL,N'LastMessage',NULL,0,200,37,NULL,0,NULL,NULL,500,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'28b95c5d-31c2-4e42-97d6-d4674559c939',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'LastMessTime',N'DateTimeFromTo',N'LastMessTime',N'{0:dd.MM.yy HH:mm}',NULL,NULL,NULL,NULL,N'LastMessTime',NULL,0,85,38,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'b50f7741-d2c0-4dfc-84bc-7e85a32ab8a8',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'RepeatAfterMin',N'Integer',N'RepeatAfterMin',NULL,NULL,NULL,NULL,NULL,N'RepeatAfterMin',NULL,0,60,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'ecb1c38f-be93-42d8-ad18-1c65c8df9e64',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'RunFromHour',N'Integer',N'RunFromHour',NULL,NULL,NULL,NULL,NULL,N'RunFromHour',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'1d2373c4-758f-4c68-abc2-cef2ebfc7c77',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'RunToHour',N'Integer',N'RunToHour',NULL,NULL,NULL,NULL,NULL,N'RunToHour',NULL,0,60,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'4793295e-b4d8-4012-ae2a-800fc9223396',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'Inform1',N'Integer',N'Inform1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,45,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'5fdfcb63-d7d7-4772-8312-b0507e9141c2',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'Inform2',N'Integer',N'Inform2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,45,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'6975b5e9-b0ad-4363-ba18-d04beaa40bbb',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'Inform3',N'Integer',N'Inform3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,45,90,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'5b2da7e0-b149-4eb7-a2ef-2159c4bcb299',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'Rank',N'Integer',N'Rank',NULL,NULL,NULL,NULL,NULL,N'Rank',NULL,0,30,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'ba91cc3e-0b05-4657-a1e9-76f0e2691275',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'Note',N'Text',N'Note',NULL,NULL,NULL,NULL,NULL,N'Note',NULL,0,80,120,NULL,0,NULL,NULL,500,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'c3b00e7a-87d7-4806-9bb9-5c93622b02c9',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'InformBySecondMatch',N'Color',N'InformBySecondMatch',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'82dcc13a-dc41-4e15-b2a4-9ebf69ae8caa',N'77f81f33-c8a9-4883-a480-c3d29d8541cc',N'ReparationProc',N'Text',N'ReparationProc',NULL,NULL,NULL,NULL,NULL,N'ReparationProc',NULL,0,80,160,NULL,0,NULL,NULL,500,NULL,NULL,NULL, NULL)
 END
GO

/*
IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Export vybraných modulů')
INSERT [dbo].[ActionTrigger] ([ActionTriggerId], [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
 VALUES (N'34047afb-6685-4587-9c8f-ab889675a20a', N'Export vybraných modulů', N'Slouží k údržbě katalogu', N'ServiceAPP', N'EXEC [$(FS_CUSTOM)].[dbo].[ExportModul] @RecordId', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO

IF NOT EXISTS(SELECT * FROM .[dbo].[ActionTrigger] WHERE DisplayName='Import vybraných modulů')
INSERT [dbo].[ActionTrigger] ( [DisplayName], [Description], [GroupName], [CommandText], [WorkflowId], [WorkflowXaml], [Model], [Interval], [TimeMode], [TimeFrom], [TimeTo], [ReferenceKey], [LastRunUtc], [LastWorkflowInstanceId], [Suspended], [Deleted])
 VALUES ( N'Import vybraných modulů', N'Slouží k instalaci komponent z katalogu', N'ServiceAPP', N'EXEC [$(FS_CUSTOM)].[dbo].[ImportModul] @RecordId,0', NULL, NULL, N'Manual', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
*/
DECLARE @RoleId AS Uniqueidentifier =(SELECT TOP (1) [RoleId]  FROM $(MonitorDB).[dbo].[Role] WHERE SystemName='RunActionManual')
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

  DELETE 
  FROM $(FS_custom).[dbo].[ErrorLog]
  WHERE Timelocal<DATEADD(Month,-6,GETDATE()) AND RepeatAfter<>-1
  GO


USE $(MonitorDB)
GO
-------------------------  ServiceAPP OPTIMISE ---------------------------

DECLARE @Id AS UNIQUEIDENTIFIER --='22669630-84AA-49FC-9868-96DEE92E5B55'

SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Zprávy opomenuté' AND QueryGroup='ServiceAPP'
 AND QueryText LIKE '%ISNULL(M.SpamLevel,0)>0%' )
IF @Id IS NOT NULL
  BEGIN
   PRINT 'I repair condition in neglected messages'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'ISNULL(M.SpamLevel,0)>0','ISNULL(M.SpamLevel,0)=0')
     FROM .dbo.DataQuery DQ
  WHERE DataQueryId=@Id
  END

  
IF (SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE QueryGroup='ServiceAPP' AND QueryText LIKE '%''ANO''%' AND Deleted=0) IS NOT NULL 
  BEGIN
   PRINT 'I Translate QueryText'
   UPDATE DQ
     SET  QueryText = REPLACE(REPLACE(REPLACE(QueryText,'''ANO''','''YES'''),'''NE ''','''NO'''),'''NE''','''NO''')
     FROM .dbo.DataQuery DQ
	 WHERE QueryGroup='ServiceAPP'
  END
SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName IN ('Přehled agentů ServiceAPP','List of Agents') AND QueryGroup='ServiceAPP' AND QueryText NOT LIKE '%LastInCall%' AND Deleted=0)
IF @Id IS NOT NULL 
  BEGIN
   PRINT 'I add LastCalls into ServiceAPP agents'
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

SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName IN ('Přehled agentů ServiceAPP','List of Agents')
 AND QueryGroup='ServiceAPP' AND QueryText NOT LIKE '%MAX(PilotTime)%' AND Deleted=0)
IF @Id IS NOT NULL 
  BEGIN
   PRINT 'I tune Query ServiceAPP agents'
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
SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Assigned messages to agents' AND QueryGroup='ServiceAPP' AND QueryText NOT LIKE '%SpamLevel%' )
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
 AND QueryGroup='ServiceAPP' AND QueryText NOT LIKE '%Scheduled%' AND Deleted=0)
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
    ,Scheduled
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
	  ,SUM(Scheduled) AS Scheduled
    FROM 
  (SELECT       
  	  GatewayId
      ,SUM(IIF(Direction=''I'',1,0)) AS Received
  	  ,SUM(IIF(Direction=''O'' AND MessagePhase=''Sent'',1,0)) AS Sent
	  ,0 AS Scheduled
       -- ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId=GW.GateWayId AND TimeUTC>@from AND Direction=''O'' AND MessagePhase=''Sent'') AS OdeslanychZprav
     FROM .[dbo].[Message] ME
    WHERE ReceivedSentTime > DATEADD(Hour,-2,@Now)
    GROUP BY GatewayId
   UNION
    SELECT       
  	  GatewayId
      ,0 AS Received
  	  ,0 AS Sent
  	  ,SUM(1) AS Scheduled
     FROM .[dbo].[Message] ME
    WHERE Direction=''O'' AND MessagePhase=''Scheduled''
    GROUP BY GatewayId

    UNION
    SELECT
  	  GatewayId
        ,0 AS Received
  	  ,0 AS Sent
	  ,0 AS Scheduled
       -- ,(SELECT COUNT(1) FROM Message ME WITH (NOLOCK) WHERE ME.GateWayId=GW.GateWayId AND TimeUTC>@from AND Direction=''O'' AND MessagePhase=''Sent'') AS OdeslanychZprav
     FROM .[dbo].[Gateway] GW WHERE Deleted=0
    ) AS Phase1
    GROUP BY GatewayId
    ) AS Phase2
      LEFT JOIN .[dbo].[Gateway] GW WITH (NOLOCK) ON GW.GatewayId=Phase2.GatewayId
 
  '
     FROM .dbo.DataQuery DQ
    WHERE DataQueryId=@Id
  INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (N'efdb1df5-bede-4c3b-895c-ea28b2458a14',N'4eff4b79-581e-41df-a62a-ceaee89ad0f5',N'Scheduled',N'Integer',N'Scheduled',NULL,NULL,NULL,NULL,NULL,N'Scheduled',NULL,0,60,35,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
IF (SELECT TOP 1 DataQueryId FROM .dbo.DataQueryColumn WHERE DisplayName = 'Ex Comm' AND DataQueryId=@Id) IS NULL
  INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
    VALUES (@Id,N'4eff4b79-581e-41df-a62a-ceaee89ad0f5',N'Ex Comm',N'Select',N'ExKom',NULL,NULL,NULL,NULL,NULL,N'ExKom',NULL,0,80,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
/*
  INSERT [DataQueryColumn] ([DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
  VALUES (@Id,N'Select',N'Toggle',N'RecordId',NULL,NULL,N'~/CustomImages/Bullet-{0}.png',NULL,NULL,N'RecordId',NULL,0,50,3,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)

   UPDATE $(MonitorDB).[dbo].[Portal] SET JsonData = REPLACE(JsonData,'"ManualActions":[null,null,null,null,null,null,null,null,null,null]'
  ,'"ManualActions":[{"Id":"19e60d25-6014-48ca-95a9-0e0ffad9e6d4","DisplayName":"Gateway Test","SpecificName":"ServiceAPP","Glyph":"fa fa-thermometer-full   ","Flag1":0},null,null,null,null,null,null,null,null,null]')   
	WHERE HashPage='ServiceAPP_Email' AND NavGroup='ServiceAPPPageNav'
*/
   END



SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName IN ('Inbound Call Events')
 AND QueryGroup='ServiceAPP' AND QueryText NOT LIKE '%WHERE%' AND Deleted=0)
IF @Id IS NOT NULL 
  BEGIN
   PRINT 'I tune Inbound Call Events'
   UPDATE DQ
     SET  QueryText = 'SELECT 
CAE.InboundCallId,
 TimeLocal
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
, IC.CallerNumber 
FROM .dbo.CallEvent AS CAE WITH (NOLOCK)
LEFT JOIN IvrStep AS IVRST  WITH (NOLOCK)ON IVRST.IvrStepId=CAE.ReferenceId
LEFT JOIN IvrScript AS IVRSC  WITH (NOLOCK) ON IVRST.IvrScriptId=IVRSC.IvrScriptId
LEFT JOIN InboundCall AS IC  WITH (NOLOCK) ON IC.InboundCallId=CAE.InboundCallId
LEFT JOIN Project AS PR  WITH (NOLOCK) ON PR.ProjectId=CAE.ProjectId
LEFT JOIN Agent AS AG  WITH (NOLOCK) ON AG.AgentId=CAE.AgentId
LEFT JOIN Workplace AS WP  WITH (NOLOCK) ON WP.WorkPlaceId=CAE.WorkPlaceId
WHERE CAE.InboundCallId IS NOT NULL AND CAE.TimeUTC>DATEADD(Month,-1,@today)  
  '
     FROM .dbo.DataQuery DQ
    WHERE DataQueryId=@Id
END

SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Assigned messages to agents' AND QueryGroup='ServiceAPP' AND QueryText NOT LIKE '%SpamLevel%' )
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





SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Všechny příchozí hovory' AND QueryGroup='ServiceAPP')
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
--  SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Všechny příchozí hovory' AND QueryGroup='ServiceAPP')
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

SET @Id=(SELECT TOP 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName='Všechny zprávy' AND QueryGroup='ServiceAPP')
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
    LEFT JOIN .[dbo].[DataQuery] DQ WITH (NOLOCK) ON DQ.DataQueryId=DQC.DataQueryId
  WHERE DQ.QueryGroup='ServiceAPP' AND UrlFormat LIKE '%Messages/DispFormPlus%')=1
   BEGIN
     PRINT 'I repair link for MessageEditor'
     -- Najdu si správný formát
	 DECLARE @UrlFormat AS NVARCHAR(150)=(SELECT TOP 1 UrlFormat FROM .[dbo].[DataQueryColumn] WHERE UrlFormat LIKE '%MessageEditor%' )
	 IF @UrlFormat IS NOT NULL
	    UPDATE DQC
          SET  UrlFormat = @UrlFormat
			FROM .dbo.DataQueryColumn DQC
			  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
			WHERE DQ.QueryGroup='ServiceAPP' AND UrlFormat LIKE '%Messages/DispFormPlus%'
   END

   PRINT 'Vyhazuji TOP 1000'
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,'TOP 1000','')
     FROM .dbo.DataQuery DQ
  WHERE QueryGroup='ServiceAPP' AND QueryText LIKE '%TOP 1000%'

 -- Nastavení správného formátu datumu v Eventlog u skupiny ServiceAPP:
  PRINT 'Opravuji model v Eventlog'
 UPDATE DQC
SET  Model = 'DateTimeFromTo'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND (DQC.Model='DayTime' ) 


 -- Konverze FullText na Text u skupiny ServiceAPP:
 PRINT 'Konverze FullText na Text:'
 UPDATE DQC
SET  Model='Text'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQC.Model='FullText' 

-- Konverze FullText na Text u skupiny ServiceAPP:
 PRINT 'Konverze FullText Hyperlink na Text:'
 UPDATE DQC
SET  Model='HyperLink'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQC.Model='HyperFullText' 


 -- Nastavení stejné velikosti písmen u skupiny ServiceAPP:
 UPDATE DQ
SET  QueryGroup = 'ServiceAPP'
FROM .dbo.DataQuery DQ
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP'

-- Nastavení Tooltipů
UPDATE DQC
SET  ToolTip = 500
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND (DQC.Model='Text' OR DQC.Model='Hyperlink') AND ISNULL(ToolTip,0)=0

UPDATE DQC
SET  ToolTip = 500
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND (DQC.Model='Text')

UPDATE DQC
SET  Width = 200
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQC.DisplayName='ResultData'

UPDATE DQC
SET  Width = 120
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQC.DisplayName='ResultData'


UPDATE DQC
SET  Width = 35
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQC.DisplayName='Jazyk'

UPDATE DQC
SET  Width = 62
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQC.DisplayName='Pracoviště'

UPDATE DQC
SET  Width = 130
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQC.TargetColumn='GatewayName'



UPDATE DQC
SET  Width = 140
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQC.TargetColumn='IVR Step'

UPDATE DQC
SET  Width = 999
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQ.DisplayName='Eventlog' AND DQC.TargetColumn='Popis'

UPDATE DQC
SET  Width = 600
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQ.DisplayName='ServiceAPP příkazy' AND DQC.TargetColumn='Description'


UPDATE DQC
SET  Width = 600
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQ.DisplayName='Výsledky akcí' AND DQC.TargetColumn='Message'



UPDATE DQC
SET  Model = 'Select'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
AND DQ.QueryGroup='ServiceAPP' AND DQ.DisplayName='Eventlog' AND DQC.TargetColumn='Procedura'



UPDATE DQC
SET  TargetFormat = '{0:dd.MM.yy HH:mm:ss}',
     Width = 100
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE Model LIKE 'DateTime%'
AND DQ.QueryGroup='ServiceAPP'

UPDATE DQC
SET  Width = 160
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE TargetColumn='Subjectfield'
AND DQ.QueryGroup='ServiceAPP'

UPDATE DQC
SET  Width = 200
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE TargetColumn='DisplayName'
AND DQ.QueryGroup='ServiceAPP'
AND DQ.DisplayName='Telefonní seznamy'

UPDATE DQC
SET  CSS = 'success'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE TargetColumn='IsSelected'
AND DQ.QueryGroup='ServiceAPP'
AND DQ.DisplayName='Telefonní seznamy'
AND CSS IS NULL

-- Nastavení šířky id:
UPDATE DQC SET  
     Width = 230
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE TargetColumn LIKE '%Id' AND Model='Text'
AND DQ.QueryGroup='ServiceAPP'

UPDATE DQC SET  
     UrlFormat = REPLACE(UrlFormat,'~/Pages/DataQueryPage.aspx?DataQueryId','/ReactClient/Pages/DataQueryPage.html?Id')
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE UrlColumn IS NOT NULL
AND DQ.QueryGroup='ServiceAPP'

UPDATE DQC SET  
     UrlFormat = REPLACE(UrlFormat,'/Calls/DispFormPlusIn.aspx','/calleditor.html')
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE UrlColumn IS NOT NULL
AND DQ.QueryGroup='ServiceAPP'

UPDATE DQC SET  
     UrlFormat = REPLACE(UrlFormat,'/Calls/DispFormPlusOut.aspx','/calleditor.html')
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE UrlColumn IS NOT NULL
AND DQ.QueryGroup='ServiceAPP'

-- Nastavení šířky ResultText:
UPDATE DQC SET  
     Width = 200
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ WITH (NOLOCK) ON DQC.DataQueryId=DQ.DataQueryId
WHERE TargetColumn = 'ResultData' AND Model='Text'
AND DQ.QueryGroup='ServiceAPP'

UPDATE CONF SET  
     ConfigurationValue = 'error@atlantis.cz'
FROM .dbo.Configuration CONF
 WHERE ConfigurationValue LIKE '%Homolka%' AND ConfigurationName='TOCC' AND GroupName='Zakaznik'


IF (SELECT CONVERT(Real,LEFT(Description,4)) AS Ver
FROM .dbo.Configuration CONF WHERE ConfigurationName = 'iCC.ServiceSync')>3.21
 UPDATE CONF SET  
     ConfigurationName = 'DropDownOutboundListsDataQueryId'
FROM .dbo.Configuration CONF
 WHERE ConfigurationName = 'DropDownOutboundLitstsDataQueryId'

IF EXISTS 
(
  SELECT * 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'Portal'
  AND column_name = 'Title'
)
 BEGIN
	  UPDATE $(MonitorDB).dbo.Portal
	SET  Title = 'Export/Import'
	WHERE [NavGroup]='ServiceAPPPageNav' AND HashPage='ServiceAPP_expimp'

	  UPDATE $(MonitorDB).dbo.Portal
	SET  Title = 'Issues', Description = 'Issues'
	WHERE [NavGroup]='ServiceAPPPageNav' AND HashPage='ServiceAPP_pripady'
 END
  EXEC $(FS_custom).[dbo].[FSC_DelDuplIndexes]
/*
 UPDATE TOP (30) DQ 
  SET deleted=1
 FROM $(MonitorDB).[dbo].[DataQuery] DQ
    LEFT JOIN $(MonitorDB).[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
    LEFT JOIN $(MonitorDB).[dbo].[DataQuery] DQ2 ON DQ.DisplayName=DQ2.DisplayName AND DQ2.DataqueryId<>DQ.DataqueryId
	LEFT JOIN $(MonitorDB).[dbo].[Configuration] CON ON CON.ConfigurationValue=CONVERT(NVARCHAR(38),DQ.DataqueryId)
	WHERE DQ.Deleted=0 AND PRT.JsonData IS NULL AND CON.ConfigurationValue IS NULL AND DQ2.DataqueryId IS NOT NULL AND
	(DQ.QueryGroup='Admin' OR DQ.QueryGroup='ServiceAPP')
*/
---- Překlad do angličtiny:
/**/

GO
USE [msdb]
GO

/****** Object:  Job [DailyMaint]    Script Date: 22. 5. 2023 11:34:46 ******/
DECLARE @DailyMaint AS NVARCHAR(10)='DailyMaint'
IF $(LowPermission)=0 AND NOT EXISTS(SELECT TOP 1 job_id FROM msdb.dbo.sysjobs WHERE (name = @DailyMaint))
 BEGIN
BEGIN TRANSACTION
  
DECLARE @ReturnCode INT
DECLARE @User NVARCHAR(100)=SYSTEM_USER
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 22. 5. 2023 11:34:46 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@DailyMaint, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Daily Maintenance', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@User, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Frontstage Inspection]    Script Date: 22. 5. 2023 11:34:47 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Frontstage Maintenance', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC $(FS_CUSTOM).dbo.FSC_Maintenance', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Maintenance', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		--@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20230518, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959--, 
		--@schedule_uid=N'b90daac0-6302-4d77-b624-313be9ae3399'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
UPDATE iCC.[dbo].[ActionTrigger] SET Suspended = 1 WHERE DisplayName='Denní údržba'
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
END
GO


PRINT 'All commands were completed'

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
	 EXEC('select * into $(Icc_Backup).dbo.'+@TableName+' from $(MonitorDB).dbo.'+@TableName+@WhereCond)-- select * into $(Icc_Backup).dbo.Agent from $(MonitorDB).dbo.Agent

 END
 GO

 IF object_id('$(Icc_Backup)..FSC_Backup_WfmSlot') IS NOT NULL
 BEGIN
  DROP  PROCEDURE [dbo].FSC_Backup_WfmSlot
 END


GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.04.2020>
-- Description:	Záloha 1 (konfigurační) tabulky do iCC_Backup
-- =============================================

CREATE PROCEDURE [dbo].[FSC_Backup_WfmSlot]
AS
BEGIN
  DECLARE @TableName AS NVARCHAR(100) = 'WfmSlot'
  DECLARE @OrigName AS NVARCHAR(100) = '$(Icc_Backup)..'+@TableName
  DECLARE @NewName AS NVARCHAR(100) = @TableName+'_old'
  --PRINT DB_NAME()
 	IF OBJECT_ID(N'$(Icc_Backup)..'+@TableName, N'U') IS NOT NULL -- Tabulka existuje
	  BEGIN
	    IF OBJECT_ID(N'$(Icc_Backup)..'+@TableName+'_old', N'U') IS NOT NULL -- Tabulka existuje 
		  EXEC('DROP TABLE $(Icc_Backup).dbo.'+@TableName+'_old')
	    EXEC sp_rename @OrigName, @NewName
	  END

	 select WFS.* into $(Icc_Backup).dbo.WfmSlot from $(MonitorDB).dbo.WfmSlot WFS
	    LEFT JOIN $(MonitorDB).[dbo].WfmPlan WFP WITH (NOLOCK) ON  WFP.WfmPlanId=WFS.WfmPlanId
	  WHERE 1=1
		AND (WFP.Status LIKE 'Week%' OR WFP.Status LIKE 'Template%')
		AND WFS.Deleted=0

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
EXEC Icc_Backup.dbo.Backup_Table2 'BusyCondition',''
EXEC Icc_Backup.dbo.Backup_Table2 'BusyConditionRule',''
EXEC Icc_Backup.dbo.Backup_Table2 'CallResultDetail',''
EXEC Icc_Backup.dbo.Backup_Table2 'Campaign',''
EXEC Icc_Backup.dbo.Backup_Table2 'ClientAlert',''
EXEC Icc_Backup.dbo.Backup_Table2 'ClientAlertComposition',''
EXEC Icc_Backup.dbo.Backup_Table2 'Configuration',''
EXEC Icc_Backup.dbo.Backup_Table2 'ContactModel',''
EXEC Icc_Backup.dbo.Backup_Table2 'Crew',''
EXEC Icc_Backup.dbo.Backup_Table2 'CrewMember',''
EXEC Icc_Backup.dbo.Backup_Table2 'DataQuery',''
EXEC Icc_Backup.dbo.Backup_Table2 'DataQueryColumn',''
EXEC Icc_Backup.dbo.Backup_Table2 'Device',''
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
EXEC Icc_Backup.dbo.Backup_Table2 'Perso',''
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
EXEC Icc_Backup.dbo.Backup_Table2 'ScenarioConsolidation','' 
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
EXEC Icc_Backup.dbo.Backup_Table2 'WebSiteRouting',''
EXEC Icc_Backup.dbo.Backup_Table2 'WebSiteTemplate',''
EXEC Icc_Backup.dbo.Backup_Table2 'Workflow','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WorkPlace','' 
EXEC Icc_Backup.dbo.Backup_Table2 'WorkflowStep','' 
EXEC Icc_Backup.dbo.FSC_Backup_WfmSlot

 BACKUP DATABASE Icc_Backup TO DISK = @BackupFile
END

GO


/* Smazání nepoužitých/duplicitních ServiceAPP DQ:
Zde se objevují všechny nepoužité, tak někdy pomůže je přidat na příslušnou záložku
SELECT TOP (30) *
 FROM iCC.[dbo].[DataQuery] DQ
    LEFT JOIN iCC.[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
	LEFT JOIN iCC.[dbo].[DataQuery] DQ2 ON DQ.DisplayName=DQ2.DisplayName AND DQ2.DataqueryId<>DQ.DataqueryId
	LEFT JOIN iCC.[dbo].[Configuration] CON ON CON.ConfigurationValue=CONVERT(NVARCHAR(38),DQ.DataqueryId)
	WHERE DQ.Deleted=0 AND PRT.JsonData IS NULL AND DQ2.DataqueryId IS NOT NULL AND CON.ConfigurationValue IS NULL AND
	(DQ.QueryGroup='Admin' OR DQ.QueryGroup='ServiceAPP' OR DQ.QueryGroup='ServiceAPP')
	ORDER BY DQ.DataqueryId

UPDATE TOP (30) DQ 
  SET deleted=1
 FROM iCC.[dbo].[DataQuery] DQ
    LEFT JOIN iCC.[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
    LEFT JOIN iCC.[dbo].[DataQuery] DQ2 ON DQ.DisplayName=DQ2.DisplayName AND DQ2.DataqueryId<>DQ.DataqueryId
	LEFT JOIN iCC.[dbo].[Configuration] CON ON CON.ConfigurationValue=CONVERT(NVARCHAR(38),DQ.DataqueryId)
	WHERE DQ.Deleted=0 AND PRT.JsonData IS NULL AND CON.ConfigurationValue IS NULL AND DQ2.DataqueryId IS NOT NULL AND
	(DQ.QueryGroup='Admin' OR DQ.QueryGroup='ServiceAPP')

UPDATE TOP (1) DQ 
  SET deleted=0
 FROM iCC.[dbo].[DataQuery] DQ
 WHERE DataQueryId='A8AFFA00-F559-4860-983E-0053697529A8'

SELECT TOP (30) *
 FROM $(MonitorDB).[dbo].[DataQuery] DQ
    LEFT JOIN $(MonitorDB).[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
	LEFT JOIN $(MonitorDB).[dbo].[DataQuery] DQ2 ON DQ.DisplayName=DQ2.DisplayName AND DQ2.DataqueryId<>DQ.DataqueryId
	WHERE DQ.Deleted=0 AND PRT.JsonData IS NULL AND DQ.QueryGroup='ServiceAPP' AND DQ2.DataqueryId IS NOT NULL

UPDATE TOP (30) DQ 
  SET deleted=1
 FROM $(MonitorDB).[dbo].[DataQuery] DQ
    LEFT JOIN $(MonitorDB).[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
	WHERE Deleted=0 AND PRT.JsonData IS NULL AND QueryGroup='ServiceAPP'

UPDATE TOP (1) DQ 
  SET deleted=0
 FROM $(MonitorDB).[dbo].[DataQuery] DQ
    LEFT JOIN $(MonitorDB).[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
	WHERE Deleted=1 AND PRT.JsonData IS NOT NULL AND QueryGroup='ServiceAPP'

UPDATE TOP (1) DQ 
  SET deleted=0
 FROM $(MonitorDB).[dbo].[DataQuery] DQ
	WHERE 1=1
	--AND DQ.DataQueryId='b37e3ad0-c8e3-4083-a23a-0e18686076b6'
	AND DQ.DisplayName='IVR Steps'

	

*/
USE $(FS_CUSTOM)
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
,Chained
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
	  ,0 AS Chained
  FROM $(MonitorDB).[dbo].[OutboundCall] OC WITH (NOLOCK)
    LEFT JOIN $(MonitorDB).[dbo].[CallRecord] CR WITH (NOLOCK) ON CR.OutboundCallId=OC.OutboundCallId
    LEFT JOIN $(MonitorDB).[dbo].[Workplace] WP ON WP.WorkplaceId=OC.WorkplaceId
  WHERE DistributionTime>@Today  AND DistributionTime<DATEADD(Hour,-1,@Now)  AND CallDuration>1
  AND CR.OutboundCallId IS NULL 
    AND LEN(RTRIM(CallerNumber))>6
   AND CallResult<>'Canceled'
  AND  WP.Number IS NOT NULL -- Hodnocení hovorů nemá nahrávku ani pracoviště
  AND $(FS_CUSTOM).dbo.CustomCheckInt('DU',OC.CallDuration)=1
  AND .dbo.CustomCheck2('OC',WP.DisplayName)=1
  UNION ALL
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
	  ,ChainedInbound AS Chained
  FROM $(MonitorDB).[dbo].[InboundCall] IC
    LEFT JOIN $(MonitorDB).[dbo].[CallRecord] CR ON CR.InboundCallId=IC.InboundCallId
    LEFT JOIN $(SREC).[dbo].[Directory] DI ON RIGHT(DI.Number,3) COLLATE Czech_CI_AS =IC.Redirector COLLATE Czech_CI_AS
    LEFT JOIN $(MonitorDB).[dbo].[Workplace] WP ON WP.WorkplaceId=IC.WorkplaceId
  WHERE TimeUTC>@Today AND TimeUTC<DATEADD(Hour,-3,@Now) AND CallDuration>1
  AND CR.INboundCallId IS NULL   
  AND CallResult ='served'
  AND LEN(RTRIM(CallerNumber))>6
  --AND Redirector NOT LIKE '7%'
  AND isnull(DI.Record,1) <>0
    AND (.dbo.CustomCheck2('IC',WP.DisplayName)=1 OR .dbo.CustomCheck2('ID',IC.Redirector)=1)
  AND $(FS_CUSTOM).dbo.CustomCheckInt('DU',IC.CallDuration)=1 
  ) AS Phase1 ) AS Phase2
  LEFT JOIN  $(SREC).[dbo].[VoiceRecord] VCR WITH(NOLOCK) ON 
   StartTimeUtc>DATEADD(ss,-30,Phase2.TimeUtc) AND StartTimeUtc<DATEADD(ss,230,Phase2.TimeUtc)
   AND RIGHT(RemoteNumber,9) COLLATE Czech_CI_AS =RIGHT(Phase2.CallerNumber,9) COLLATE Czech_CI_AS --AND AgentName IS NULL --V jedné nahrávce může být více přepojených hovorů
   AND DATEDIFF(ss,StartTimeUtc,EndTimeUtc)>=Phase2.CallDuration

)
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

    UPDATE $(MonitorDB).dbo.Agent
SET  DisplayName=@DisplayNameNew,SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'

   UPDATE $(SREC).dbo.Account
SET  DisplayName=@DisplayNameNew,SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'


  UPDATE $(ProServer).dbo.Agent
SET  DisplayName=@DisplayNameNew,SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'
 
   UPDATE $(ProServer).dbo.Credentials
SET   SystemName=REPLACE(SystemName,@SystemNameOld,@SystemNameNew)
where SystemName like '%'+@SystemNameOld+'%'

   UPDATE $(ProServer).dbo.DataItem
SET   DataValue=REPLACE(DataValue,@SystemNameOld,@SystemNameNew)
where DataValue like '%'+@SystemNameOld+'%'

END

GO

	
IF object_id('DesktopClientAdd') IS NOT NULL
 DROP  Procedure  [dbo].[DesktopClientAdd]
GO

--***** Object:  StoredProcedure [dbo].[DesktopClientAdd]    Script Date: 11.10.2022 10:42:17 *****
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:        Kubát Václav
-- Create date: 12.12.2021
-- Description:   Nastaví konkrétního agenta k hovoru
-- =============================================
CREATE PROCEDURE [dbo].[DesktopClientAdd] 
@MyAgentId uniqueidentifier,
@Domain nvarchar(20),
@NoAddPerso Integer -- Povel k nepťidávání PERSO
AS
BEGIN
    DECLARE @Loguj AS Bit=1
	DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
	DECLARE @Popis AS nvarchar(MAX)

  SET @NoAddPerso=ISNULL(@NoAddPerso,0)
--====================kontrola ProServer.dbo.Credentials nakonec po spusteni skriptu===============================
       -- nemel by existovat ucet bez SystemName, pokud nema Password (WebSite...) -> tedy vysledek idealne 0 radku:
       
       --select * from ProServer.dbo.Credentials c
       --left join ProServer.dbo.Account a on a.AccountId = c.AccountId
       --where c.SystemName is null and c.Deleted = 0 and Password is null



       --INSERT/UPDATE těchto míst
       --       ProServer: [Account] | [Credentials] | [DataItem]
       --       iCC: [Perso] |  [Agent].BarDataQueryId |  [Seating].LoginClientModels (doplneni "ProCaller")
                     

--==========nastaveni hodnot==============
	   declare @TeamName as nvarchar(40)=(SELECT TeamName FROM $(MonitorDB).dbo.Agent WHERE AgentId=@MyAgentId)

       declare @BarDataQueryId as uniqueidentifier = (select top 1 BarDataQueryId from $(MonitorDB).dbo.agent where BarDataQueryId is not null) --statistiky v DC liste
       declare @EventHandlingDefinition as nvarchar (max)
       declare @RibbonDefinition as nvarchar (max)
       --do [DataItem] se vlozi s obecnym loginem NTUSER. Pokud je potreba s loginem (jako napříkald v Alze, coz není obvykle), staci dole zakomentovat/odkomentovat v INSERT
       declare @DataValue as nvarchar(max) = '<?xml version="1.0" encoding="utf-8"?><UserData><IdentityCC>NTUSER</IdentityCC></UserData>'
       declare @DomainUserName as nvarchar(40)
       declare @AgentName as nvarchar(40)

	   --default Perso
       set @EventHandlingDefinition = (SELECT TOP 1 [JsonData]  FROM $(MonitorDB).[dbo].[Perso] PER
	   INNER JOIN $(MonitorDB).dbo.Agent AG ON AG.AgentId=PER.AgentId
       WHERE RefName='ProCaller#EventHandlingDefinition' AND JsonData IS NOT NULL
	   AND AG.TeamName=@TeamName
	   group by JsonData having count(1)>1)

	   IF @EventHandlingDefinition IS NULL
         set @EventHandlingDefinition = (SELECT TOP 1 [JsonData]  FROM $(MonitorDB).[dbo].[Perso] PER
        WHERE RefName='ProCaller#EventHandlingDefinition' AND JsonData IS NOT NULL
	   group by JsonData having count(1)>1)
	   IF @EventHandlingDefinition IS NULL
         set @EventHandlingDefinition = 
         N'{"Reactions":[{"EventType":"ProjectIncomingRinging","Reaction":"StartProcess","ParamTemplate":"http://localhost/ReactClient/Pages/calleditor.html?Id={PbxCallId}"},{"EventType":"DirectIncomingRinging","Reaction":"ShowPopout"},{"EventType":"DirectOutgoingRinging","Reaction":"ShowPopout"},{"EventType":"PrivateOutgoingOffer","Reaction":"ShowPopout"},{"EventType":"PrivateOutgoingRinging","Reaction":"ShowPopout"},{"EventType":"ProjectIncomingRinging","Reaction":"ShowPopout"},{"EventType":"ProjectOutgoingOffer","Reaction":"ShowPopout"},{"EventType":"ChatAlerting","Reaction":"ShowPopout"},{"EventType":"ChatAlerting","Reaction":"PlaySound","ParamTemplate":"file|C:\\Windows\\Media\\Ring06.wav"}]}'
 ------------------------------------------------------------
       set @RibbonDefinition = (SELECT TOP 1 [JsonData]  FROM $(MonitorDB).[dbo].[Perso] PER
	   INNER JOIN $(MonitorDB).dbo.Agent AG ON AG.AgentId=PER.AgentId
       WHERE RefName='ProCaller#RibbonDefinition' AND JsonData IS NOT NULL
	   AND AG.TeamName=@TeamName
	   group by JsonData having count(1)>1)
	   IF @RibbonDefinition IS NULL
         set @RibbonDefinition = (SELECT TOP 1 [JsonData]  FROM $(MonitorDB).[dbo].[Perso] PER
        WHERE RefName='ProCaller#RibbonDefinition' AND JsonData IS NOT NULL
	   group by JsonData having count(1)>1)
	   IF @RibbonDefinition IS NULL 
        set @RibbonDefinition = 
       N'{"SchemaVersion":2,"UsedVersion":2,"Definitions":[{"DisplayName":"Výchozí","Id":"6e55028d-aac3-4b6c-852f-9682850c5748","Options":{"CommunicationInfo":{"VoiceDisplayTemplate":"{Scenario:IntegrationEndpoints} | {ProjectName}","ChatDisplayTemplate":"Chat {ContactName};{ProjectName};{UnreadCount}","MessageDisplayTemplate":"Message {ContactName};{ProjectName}","TaskDisplayTemplate":"Task {ContactName};{ProjectName}"},"SplashHideTimeoutMilliseconds":2000,"ClientAlert":{},"AgentStatus":{"AllowChangeBetweenLogoffStatuses":true,"StatusChangeRequestTimeoutSeconds":20},"AgentWorkplace":{"WorkplaceChangeRequestTimeoutSeconds":20},"UiOptions":{"BootstrapColorMappings":{"success":"#13A10E","danger":"#E81123","primary":"#0078D4","info":"#EAEAEA","warning":"#d6d600","white":"#ffffff","default":"#000000"},"DqBootstrapColorMappings":null},"WebView":{"ChatWindowUrl":"http://10.225.239.102/ReactClient/pages/ChatEditor.html?id={chatId}&Embedded=true"},"VoiceCommandThrottleMilliseconds":3000},"ComponentGroups":[{"Name":null,"Components":[{"Id":"215e57b2-14ea-4021-b822-c0a5084c2f19","CodeName":"OpenUrlButton","IsEnabled":true,"DisplayColorVariant":0,"NavigateUrl":"http://10.225.239.102/ReactClient/Pages/portal.html#agent_home","PictogramUrl":"pack://application:,,,/Resources/LogoFS_32x32.png","Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"3605fec3-16c6-46ef-a173-6a2b2bd9611b","CodeName":"OpenUrlButton","IsEnabled":true,"DisplayColorVariant":0,"NavigateUrl":"http://10.225.239.102/ReactClient/Pages/portal.html#agent_WB","PictogramUrl":"pack://application:,,,/Resources/LogoFS_32x32.png","Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"ec741da3-0d98-43e2-915a-539c44c8ef52","CodeName":"OpenUrlButton","IsEnabled":true,"DisplayColorVariant":0,"NavigateUrl":"https://www.alza.cz","PictogramUrl":"pack://application:,,,/Assets/Images/alza_cz.png","Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"72d54fa5-e1b7-442a-b621-6023b4ff2537","CodeName":"OpenUrlButton","IsEnabled":true,"DisplayColorVariant":0,"NavigateUrl":"https://www.alza.sk","PictogramUrl":"https://cdn.alza.cz/Foto/imggalery/LandingPages/Logomanual/images/alza_cz.png","Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":2,"AppendSeparator":true,"Orientation":0,"Band":0,"BandIndex":0,"Id":"98f58600-e8c9-4367-b559-b0d1ac10847f","CodeName":null,"IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":92.0,"RightSeparator":true,"CompoWidthEstimate":32.0},{"Name":null,"Components":[{"Id":"67882081-7e11-46df-8940-3dae206887b2","CodeName":"WorkplaceStatusDropdown","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":126.0},{"Id":"5e51a3d3-b82e-4a5e-98f6-6b61a958a6d5","CodeName":"WorkplaceDropdown","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ConfirmActionResourceName":"DC_Confirm_WorkplaceSignout","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":126.0},{"Id":"faaaaa5d-58dc-41bf-8990-d2caf8cb4ce6","CodeName":"QuickStatusButton","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","QuickAgentStatusId":"78028459-ca9e-45de-a574-5005f96774bc","QuickAgentStatusResetId":"60fba1e2-08f0-4129-97b3-3041e9ee27b8","QuickAgentStatusPictogram":"","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"a7fb5f17-8cf7-44f2-8bfc-f38d956b9566","CodeName":"QuickStatusButton","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","QuickAgentStatusId":"60fba1e2-08f0-4129-97b3-3041e9ee27b8","QuickAgentStatusResetId":"78028459-ca9e-45de-a574-5005f96774bc","QuickAgentStatusPictogram":"","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":4,"AppendSeparator":true,"Orientation":0,"Band":0,"BandIndex":1,"Id":"22705536-7055-46fc-825b-65c7a09ae586","CodeName":null,"IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":184.0,"RightSeparator":true,"CompoWidthEstimate":32.0},{"Name":null,"Components":[{"Id":"701f7695-1423-4a32-b8f3-d642a1b568fb","CodeName":"BasicCallBar","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":270.0},{"Id":"b9c6eaca-3bf4-4721-ab7c-94f90bb0539e","CodeName":"MicroMuteButton","IsEnabled":true,"DisplayColorVariant":0,"Command":"ToggleRecordingDeviceMute","Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"d38948ac-2ff5-465e-bf81-fe38fac0b2e1","CodeName":"ToggleSoftphone","IsEnabled":true,"DisplayText":"","DisplayColorVariant":0,"Command":"ToggleSoftphone","Size":"Standard","ToolTipResource":"DC_ToggleSoftphone_Toggle_Tooltip","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"bf096e17-8ae1-4ea8-8e40-7c06a62cab32","CodeName":"TransferCallBar","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":270.0},{"Id":"eff4323d-274a-4f3a-b5da-1c3cea093b07","CodeName":"VolumeControl","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":9,"AppendSeparator":true,"Orientation":0,"Band":0,"BandIndex":2,"Id":"9e52b5ee-6b9b-431d-9439-0b4e1369e918","CodeName":null,"IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":414.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Name":null,"Components":[{"Id":"7400caf1-8d28-43f3-ba22-8eb3e4b92fff","CodeName":"InteractionContextInfo","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":435.0},{"Id":"ce3b8e08-0050-42ed-8a5e-8f2e80b8eed6","CodeName":"ClientAlertBoard","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":435.0}],"BlockWidth":-1,"AppendSeparator":true,"Orientation":1,"Band":0,"BandIndex":3,"Id":"11e3611d-1c64-46da-a5af-783f6c37b429","CodeName":null,"IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":435.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Name":"Moje","Components":[{"Id":"fb678d00-28b9-4558-aee2-34b0b450e436","CodeName":"CallDuration","IsEnabled":true,"DisplayText":"Akutální hovor","DisplayColorVariant":0,"Size":"Standard","CellColor":"#404040","ValuePresentation":1,"MarginLeftPx":0.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"ce966fa2-981e-4287-bcc1-cff3118f94a6","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"0a1bc7b8-e87b-4b1b-b47b-ddd6898baa0c","CellViewer":"DqCifernik","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"7361b080-57b7-4031-a2ef-0869d4957045","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"e9c9bbf5-2874-4088-9845-1c867977bffc","CellViewer":"DqCifernik","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":-1,"AppendSeparator":true,"Orientation":1,"Band":0,"BandIndex":4,"Id":"5da8b341-c3da-4601-aadb-241bda550e30","CodeName":null,"IsEnabled":true,"DisplayText":"Moje","DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":180.0,"RightSeparator":true,"CompoWidthEstimate":32.0},{"Name":"","Components":[{"Id":"7bc87002-6ca0-48bd-a88e-4cca3408d50c","CodeName":"DqCell","IsEnabled":true,"DisplayText":"{0} Agentů v pauze","DisplayColorVariant":0,"Size":"Standard","CellColumnId":"0bf0bff9-a0b4-4635-a18f-c1c796e732c8","CellViewer":"DqLabel","CellLabelIcon":2,"ValuePresentation":0,"MarginLeftPx":10.0,"MarginRightPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"63c036bb-f066-4f73-992f-59730ea7402b","CodeName":"DqCell","IsEnabled":true,"DisplayText":"{0} Ztracené h.","DisplayColorVariant":0,"Size":"Standard","CellColumnId":"16033a9a-896f-4d17-9b84-d68ca053ea4d","CellViewer":"DqLabel","CellLabelIcon":1,"ValuePresentation":0,"MarginLeftPx":10.0,"MarginRightPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"52606af8-388e-42c9-8779-c9dbf12f4b94","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"65a8dc06-ced1-497a-bd07-2930d3e20806","CellViewer":"DqProgress","CellColor":"#EE4000","ValuePresentation":0,"MarginLeftPx":10.0,"MarginRightPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":-1,"AppendSeparator":true,"Orientation":1,"Band":0,"BandIndex":5,"Id":"4f906769-384b-49fe-ba6b-ad6ed76dca81","CodeName":null,"IsEnabled":true,"DisplayText":"","DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":140.0,"RightSeparator":true,"CompoWidthEstimate":32.0},{"Name":"ServiceLevel","Components":[{"Id":"d06bf74b-78f8-4712-9496-875abd96231e","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"1fd4ff53-78c8-431d-8a8c-50a35e6f7999","CellViewer":"DqProgress","CellRangeMinimum":0.0,"CellRangeMaximum":100.0,"CellColor":"#8d289f","ValuePresentation":0,"MarginLeftPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"0b988efb-e3ac-4669-adeb-e97330a5bdd9","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"0c07acd8-3c5a-4553-b6f3-985d5f3718b1","CellViewer":"DqProgress","CellRangeMinimum":0.0,"CellRangeMaximum":100.0,"CellColor":"#cc8733","ValuePresentation":0,"MarginLeftPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"57ce23b5-8829-42d3-ac83-b0a2b1c17295","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"f644ffd0-6dc8-4b22-835e-955b458aa7d8","CellViewer":"DqProgress","CellRangeMinimum":0.0,"CellRangeMaximum":100.0,"CellColor":"#2caf2c","ValuePresentation":0,"MarginLeftPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"aafcc296-b022-48f3-bcce-7d06d4b86a02","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"f178b040-66f4-4934-af13-13a9b86037c1","CellViewer":"DqProgress","CellRangeMinimum":0.0,"CellRangeMaximum":100.0,"CellColor":"#cc5233","ValuePresentation":0,"MarginLeftPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"9388dcaa-4b0c-46ed-9678-993b7a3b913f","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"77ecad57-f58e-4276-b115-0f04a48a336a","CellViewer":"DqProgress","CellRangeMinimum":0.0,"CellRangeMaximum":100.0,"CellColor":"#269797","ValuePresentation":0,"MarginLeftPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":-1,"AppendSeparator":true,"Orientation":1,"Band":0,"BandIndex":6,"Id":"8ea40c7c-9da1-4bd9-84b1-726c00d80430","CodeName":null,"IsEnabled":true,"DisplayText":"ServiceLevel","DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":350.0,"RightSeparator":false,"CompoWidthEstimate":32.0}]}],"SelectedDefinitionId":"6e55028d-aac3-4b6c-852f-9682850c5748","RibbonResources":{"ResourceList":[{"Sha256Hash":"647703b726f27267036fad8eaf435fe1d321da7ebf14f8162d959a58732229c9","Id":"6e1d0baa-7a6b-4612-94b2-5b5dcc074f26","Data":"iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAAH/ElEQVR4nO3dTXrbuBIF0HJ/vcUsIbMsJ7MsIYvMG/THZ7baliWKAC7Ac6b5I6tulUDZkasAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgKW+jL2Dv+88/v7/6Pb9+vH3rcS3wrEfyW5WV4YgF8GjhbiUVkuuaOb/DF8DR4t1KKCbXsUpuhy2Aswp4a3RBWdtquR2yAFoVcc8i4EyrZrbrAuhRxFsWAa9YPbPdFsCIQu5ZBDzjKnntsgBGF3PPIuCeq2W16QJIKuYti4BbqXltmdVmCyC1mLcsAmbIaqucNlkAMxR0zxK4JjltsABmK+qeRXANMvru1AUwc2H3LIJ1rZDRM/N52gJYobC3LIJ1rJbPs7J5ygJYrbh7lsDcZPO+lxfAygXeswjmIpeP+eusC1nd959/fl8lVLPTp8e9dAK4aqGdBjLJ4/MOL4CrFnvPIsggi8ezeGgBKPi/WQTjyOK7Izl8egH0Lvh2U+mNtgT6miUPo+blUdEL4KObmaXxtDFj/0fPzD1PLYBeN/LITcwYBF6T3POkzD6TvYcXQOLFV80fCr62Uo/T5ihqAbwyMCuFhHepfU3P6qkLIOmCv7JiYK5o9T6mzFTEAmgxHKsHaFWpfas6v3cJc/XlAki4yKOuFKYVpPZr5ox+de13F8DoizvLFYM1k6v3Z+ScDVsAI8J/9aCl0Y93o2bt0/8NmNqcV/z68fYtcdhWrPVXUu85MR+vulfrT08Aq7363xLAMdT9cyNmrvsCSCj0nkD2k1jrtDr3nrsPF8BVhn9PONtJrG1Vbn17zt/fLf6hGf368fYtLajb9aQG9Stp9dzMWs8W/nMCuOKr/63E4M5Uvyo1fFWvOeyyAGYq/F5aiGeoY1rNNjPU7laPWfShoHfMGJqREoc/9Uu/Kf51AvDq/7mUcCfWM6U2e4l1OqL1THoT8EGzfDRZT6m1WGX4e2j6CLBiI1a8pyMSh3/F437r+/n/CSCxoamufBpIvOfVhr617z///N5q5k3AF1wteIZ/Pc3eA7hKY65wGki8t6vkq6rtN6n9VZXZ4Nms+PyZ+vMQV6vzCFtfmzwCXLlBq9x76uCvUt9ntbpvXwZsYObHgsRrvurQ9+BNwIbODm7rQTD81+ME0NgMp4HEazP4fbyd3XyNu+9ova/y0enyc9/ZPfMI0NmRgBt+WvEIMMCjjwUGn9YsgIF6B9/wc+vU9wA0M5PBX8uZ/XQCWFza8Bv8LBbAotIGv8rwJ7IAFmPweYYvAy7E8PMsJ4AFGHyOsgAmlzb8Bn8uFsCk0ga/yvDPyAKYjMHnTN4EnIjh52xOABMw+LTiBBDO8NOSE0Aog08PFkAYg09PHgGCGH56cwIIYPAZ5dQTQGKQ0yXWzPDnOjsvTgCDGHwSWACdXXHwP7pnyyaDBdDRlYb/q3vd/7plMM5b1bnB1Mz/utLgVx27X7n5Wouf4XH6lwETwz5SYj3Shn/7c4m1Wp1HgEYSwzzDzxbc/g4ngj4sgJNdcfBb+P7zz+8Zr3s2Tb4TMHEIeki8715D1OLePRa8a1WHv6v+CYlCH5dYu5VePT0WnG+rZbP/C5A4FC0k3ueqg5JY6x5a3rf3AA5KDOOqg7/nNHAuC+BJiYNfdb2BsAiO29fsbf8LLcK9UoMShz+lvqNrk1KHs7WeSSeAB4wO90dWDfxRvmx4TPMTQNW8YU0c/KrMeibVKrE+R/Q4kb/d/gaPAf9ICvQmvY5pNUuv1z29Xoy7fCRYWjDuSf3mk5nDPEpiH9P85wRQdc1HgdSwJNfsI+r4up7z50NBKzO0v368fZsptJvUa0492Y3W9QRQlRWQ1EAk1egVqfWtyq1x79P3hwug5YXcu5heUoM5ui4tpNZ6k1TzETN3uUeA1EAmBfFM6Y8yKXkYdR2fngCq1joFpDT6VvJwtJDah6qxvRg1a8MWQFWfgqcG7mqDv5fak81KL05f3cvdBVA19xJIDdqVh38vtT+bFV6gXl4AVeMv8lmpwTL4H0vt12bUR6e/6pHrjlgAVecUOTVIBv9rqb3bO7OPKTP10AKoyrngjySHx/A/J7mXm1d7mjRLUQug6vnipgbG4L8mta97R3qcNkcPL4CqrItPDojhP09ynzdpeX0mf08tgKrxN5IcCIPfRnLP9z7r/+iZuSd6AVS931ByCAx+H8kZ2NvnIXn4qw4sgKp5GtGD4e9P/j7WbQFUaYLBH+vq+bt1NI+HF0DVNZtg8LNcMYO3XsmkBfAEw5/ralncvJrJlxZA1TUKb/DncYU87g1fAFXrFt3gz2nVPN46I5+nLICq9Ypu+Oe3Wib3zsrnaQugao2CG/z1rJDLvTMzeuoCqJq32AZ/fbNmc+/snJ6+AKrmK7Thv5bZ8rlpkdMmC6BqjiIb/GubIaObVllttgCqcgts8NlLzWlV+6w2XQCblAIbfO5JyemmR167LICqscU1+DwjYRH0ymy3BVA1prCGn6NGLYKeme26AKqyPlUIHrFyZrsvgM0VfwQ5c1vpJ2Vthi2AqnMLavDp6azsjs7t0AWwOVrM0cWDVxZBQn4jFsDmkWImFA0+8ugykGEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAm9j8uDeeU7UC5VgAAAABJRU5ErkJggg==","Origin":null}]}}'



-- Nastavení rolí:
declare @RoleExtensionCTI uniqueidentifier = 
(select RoleId from $(ProServer).dbo.Role where SystemName = 'ExtensionCTI')
declare @RoleUseChannels uniqueidentifier =
(select RoleId from $(ProServer).dbo.Role where SystemName = 'UseChannels')
       


--kontrola, zda existuje DQ - pokud ne bud zakomentovat UPDATE nize nebo upravit ID vyse
if not exists (select top 1 1 from $(MonitorDB).dbo.DataQuery where DataQueryId = @BarDataQueryId)
begin
       print '@BarDataQueryId neexistuje - nebudu jej nastavovat'
       SET @BarDataQueryId=NULL
       --RETURN
end
--==============vkladani==============
       if not exists (SELECT top 1 1 FROM [$(ProServer)].[dbo].[AppEnd] where SystemName = 'iCC.DesktopClient')
       begin 
              INSERT INTO [$(ProServer)].[dbo].[AppEnd] ([AppEndId],[DisplayName],[SystemName],[AppGroupName])
              VALUES ('9DE773CB-0500-4B98-A076-25F2CC52274A','iCC.DesktopClient','iCC.DesktopClient','')
       end

       declare @EndAppId as uniqueidentifier = (SELECT top 1 AppEndId FROM [$(ProServer)].[dbo].[AppEnd] where SystemName = 'iCC.DesktopClient')


       --dohledam seznam uzivatelu k zavedeni (pokud jsou ve WA a nejsou v ProServeru nebo Perso)
       declare @NewUsers as table (AgentId uniqueidentifier, Exists_PS bit, Exists_Perso bit)
                 --ti, kteri nejsou v ProServeru a nekteri maji/nemaji Perso
                 insert into @NewUsers
                           select TOP 1
                                         AgentId
                                         ,0 as Exists_PS
                                         ,case when AgentId not in (select AgentId from $(MonitorDB).dbo.Perso where RefName in ('ProCaller#EventHandlingDefinition')) then 0 else 1 end as Exists_Perso
                           from $(MonitorDB).dbo.Agent as a with (nolock) 
                            where Deleted = 0 and Template = 0 and ISNULL(SystemName,'')<>''
                            --and a.LastLogonUtc is not null -- ZbH: Toto bránilo přidání nového uživatele
                           --and exists (select top 1 1 from $(MonitorDB).dbo.Skill s with (nolock) where s.AgentId = a.AgentId) 
                            and not exists (select top 1 1 from $(ProServer).dbo.Agent /*Credentials*/ as c with (nolock) where /*AppEndId = @EndAppId and*/ Deleted = 0
                            and (a.SystemName COLLATE Czech_CI_AS= c.SystemName COLLATE Czech_CI_AS OR a.Agentid=c.Agentid
							OR a.DisplayName COLLATE Czech_CI_AS=c.DisplayName COLLATE Czech_CI_AS)
                                                       )
                           and (AgentId = @MyAgentId OR @MyAgentId IS NULL)

                /* --ti, kteri jsou v PS, ale nemaji Perso
                 insert into @NewUsers
                           select 
                                         AgentId
                                         ,1 as Exists_PS
                                         ,0 Exists_Perso
                           from $(MonitorDB).dbo.Agent as a with (nolock)  where Deleted = 0 and Template = 0 and a.LastLogonUtc is not null and exists (select top 1 1 from $(MonitorDB).dbo.Skill s with (nolock) where s.AgentId = a.AgentId) 
                                         and AgentId not in (select AgentId from $(MonitorDB).dbo.Perso where RefName in ('ProCaller#EventHandlingDefinition'))
                                         and AgentId not in (select AgentId from @NewUsers)
                           --and AgentId = 'CCDB282E-2CF1-4ECD-A12C-FA2C3818AD1B' --fs-sql_demo\kubat
						   */
 --select LastLogonUtc,* from $(MonitorDB).dbo.Agent a 
 --inner join @NewUsers n on n.AgentId = a.AgentId
--where n.AgentId is not null
   DECLARE @CountNewUsers NVARCHAR(5) =CONVERT(NVARCHAR(5),(select count(1) from @NewUsers))
   PRINT 'I have found '+@CountNewUsers+' new agents'

       --doplnim Perso, BarDataQueryId, UseChannels, ProServer 
       while (select count(1) from @NewUsers) >=1
       begin
                 --uzivatel k zavedeni
                 declare @NewUserId as uniqueidentifier = (select top 1 AgentId from @NewUsers)
                 declare @WebAdmin_DisplayName as nvarchar (150) 
                 declare @WebAdmin_TeamName as nvarchar (100) 
                 declare @WebAdmin_SystemName as nvarchar (100)
                 declare @WebAdmin_FullSystemName as nvarchar (100)
                 declare @AgentId as uniqueidentifier 
                 select 
                            @WebAdmin_DisplayName = DisplayName
                           ,@WebAdmin_TeamName = TeamName
                           ,@WebAdmin_SystemName = SystemName
                           ,@AgentId = AgentId
                 from $(MonitorDB).dbo.agent where AgentId = @NewUserId
                 set @AgentName = substring(@WebAdmin_SystemName, charindex('\',@WebAdmin_SystemName)+1,100)
                 if @Domain is NULL set @DomainUserName = @WebAdmin_SystemName /*'NTUSER'*/ ELSE set @DomainUserName = @Domain + '\' + @AgentName
                 --vlozeni Perso do iCC kvuli DesktopClientu
                 if @NoAddPerso=0 AND (select top 1 Exists_Perso from @NewUsers where AgentId = @NewUserId) = 0
                           begin
                                         insert into $(MonitorDB).dbo.[Perso] ([PersoId],[AgentId],[Profile],[RefName],[RefId],[JsonData],[ContextId])
                                         VALUES (NEWID(),@NewUserId,0,'ProCaller#EventHandlingDefinition',NULL,@EventHandlingDefinition,NULL)
                                         insert into $(MonitorDB).dbo.[Perso] ([PersoId],[AgentId],[Profile],[RefName],[RefId],[JsonData],[ContextId])
                                         VALUES (NEWID(),@NewUserId,0,'ProCaller#RibbonDefinition',NULL,@RibbonDefinition,NULL)
                           end
                     
                     --BarDataQueryId v tabulce Agent, doplneni ProCaller do Seating, pokud neni
                     update $(MonitorDB).dbo.Agent
                           set BarDataQueryId = @BarDataQueryId
                     where AgentId = @NewUserId

                     update $(MonitorDB).dbo.Seating 
                     set LoginClientModels = 'ProCaller;WebCaller;WebClient'
                           ,UseClientModels = 'ProCaller;WebCaller;WebClient'
                     where LoginClientModels like '%Web%' and LoginClientModels not like '%ProCaller%'
                     and AgentId = @NewUserId

                 --vlozeni Account do ProServer
                 if (select top 1 Exists_PS from @NewUsers where AgentId = @NewUserId) = 0
                 --declare @ProServer_AccountId as uniqueidentifier = newid ()
				 SET @Popis = 'Insert new agent to ProServer: '+@WebAdmin_DisplayName
	             EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
				 PRINT @Popis

                 INSERT INTO [$(ProServer)].[dbo].[Agent]
                                            ([AgentId]
                                            ,[DisplayName]
                                            ,[Description]
                                            ,[TeamName]
                                            ,[Deleted]
                                            ,[SystemName]
                                            ,[Culture])
                           VALUES
                                            (@AgentId
                                            ,@WebAdmin_DisplayName
                                            ,NULL
                                            ,@WebAdmin_TeamName
                                            ,0
                                            ,@DomainUserName
                                            ,NULL)
               declare @Rank AS Integer = ISNULL((select MAX(Rank) + 5 from $(ProServer).dbo.Credentials
			   WHERE Rank < 8000 ),(select MAX(Rank) + 5 from $(ProServer).dbo.Credentials))
			   
 
                 declare @ProServer_CredentialsId as uniqueidentifier = newid ()
                 INSERT INTO [$(ProServer)].[dbo].[Credentials]
                                            ([CredentialsId]
                                            ,[AgentId]
                                            ,[Rank]
                                            ,[SystemName]
                                            ,[Station]
                                            ,[IP4From]
                                            ,[IP4To]
                                            ,[IP6From]
                                            ,[IP6To]
                                            ,[AppEndId]
                                            ,[Password]
                                            ,[LastLogonUtc]
                                            ,[Deleted])
                           VALUES
                                            (@ProServer_CredentialsId
                                            ,@AgentId
                                            ,@Rank
                                            ,@DomainUserName
                                            ,NULL
                                            ,NULL
                                            ,NULL
                                            ,NULL
                                            ,NULL
                                            ,@EndAppId
                                            ,NULL
                                            ,NULL
                                            ,0)

                 declare @ProServer_DataItemId as uniqueidentifier = newid ()
                 INSERT INTO [$(ProServer)].[dbo].[DataItem]
                                            ([DataItemId]
                                            ,[KeyName]
                                            ,[AgentId]
                                            ,[ExtensionId]
                                            ,[AppEndId]
                                            ,[DataValue]
                                            ,[LastChange])
                           VALUES
                                            (@ProServer_DataItemId
                                            ,'UserData'
                                            ,@AgentId
                                            ,NULL
                                            ,@EndAppId
                                            --,concat('<?xml version="1.0" encoding="utf-8"?><UserData><IdentityCC>',@WebAdmin_SystemName,'</IdentityCC></UserData>')
                                            --,@DataValue
                                            ,REPLACE(@DataValue,'NTUSER',@WebAdmin_SystemName)
                                            ,getdate())
                IF @RoleUseChannels IS NOT NULL
                     INSERT INTO [$(ProServer)].[dbo].[Permission] ([PermissionId],[RoleId],[Degree],[ScopeId],[AgentId],[TeamMask],[Supervisor])
                     VALUES (NEWID (),@RoleUseChannels,3,NULL,@AgentId,null,null)

                     INSERT INTO [$(ProServer)].[dbo].[Permission] ([PermissionId],[RoleId],[Degree],[ScopeId],[AgentId],[TeamMask],[Supervisor])
                     VALUES (NEWID (),@RoleExtensionCTI,3,NULL,@AgentId,null,null)

                 --odstraneni zvedeneho (abych nasledne mohl zavest noveho)
                 delete from @NewUsers where AgentId = @NewUserId
       end
END

GO
