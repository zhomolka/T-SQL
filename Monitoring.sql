
:setvar Version 22.04.2026
:r C:\\Atlantis\\Scripts\\setvar.txt
:on error exit
PRINT 'Script is running on == $(MonitorDB) =='

DECLARE @FSVersion AS NVARCHAR(2) = 'V2'
-- EXEC CheckSys

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
-- OBECNÁ SEKCE:
-- Podpůrné procedury
-- ServiceAPP: Monitoring System	

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
VALUES (NEWID(), N'System messages inspection', N'SystemTest()',  60, 9, 21, 1, 'Sys_Ack')
  END
GO


IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Monitor] WHERE Command = 'CorrectFin()')
  BEGIN 
INSERT [dbo].[Monitor] ([MonitorId], [DisplayName], [Command],  [RepeatAfterMin], [RunFromHour], [RunToHour], [Inform1], [ReparationProc]) 
VALUES (NEWID(), N'Correct finish of procedure inspection', N'CorrectFin()',  60, 8, 21, 1, 'Fin_Add')
  END
GO


IF object_id('MonCheck') IS NOT NULL
 DROP  Procedure  [dbo].[MonCheck]
GO

CREATE PROCEDURE [dbo].MonCheck
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
)
AS
BEGIN
  declare @FromField as nvarchar(100)
  ,@GW as uniqueidentifier
  ,@TOCC as nvarchar(200) =.dbo.GiveParam('TOCC')
	IF @TOCC IS NULL
	     BEGIN
		   SET @TOCC  = 'error@atlantis.cz'
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
		 END
--
DECLARE @Inform1 AS Bit, @Inform2 AS Bit, @Inform3 AS Bit
SELECT @Inform1=Inform1,@Inform2=Inform2,@Inform3=Inform3 FROM $(FS_Custom).dbo.Monitor WHERE Displayname=@RecMsg
--SET @Inform1=ISNULL(@Inform1,1) -- Pokud test ještě není v seznamu -- Vypuštěno 1.2.24

 declare @RemoteAddress as nvarchar(200) = CASE WHEN @Inform1=1 THEN @TOCC ELSE CASE WHEN @Inform2=1 THEN @TOCC2 ELSE @TOCC3 END END
 SET @TOCC=CASE WHEN @Inform1=1 THEN @TOCC ELSE '' END 
 SET @TOCC=@TOCC+CASE WHEN @Inform2=1 THEN @TOCC2 ELSE '' END 
 SET @TOCC=@TOCC+CASE WHEN @Inform3=1 THEN @TOCC3 ELSE '' END 
 SET @TOCC=REPLACE(@TOCC,@RemoteAddress,'') -- Vyhodím @RemoteAddress, která mail již dostane

 declare @Company as nvarchar(200) =.dbo.GiveParam('Company')
 declare @SyncVer as nvarchar(200)

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
/*  Dočasné vyřazení systému zpráv
 IF 1=1 
	insert into $(MonitorDB).dbo.Message(TimeUtc, MessageType, MessagePhase, MessageResult, FromField, RemoteAddress, ToField, ToccField, GatewayId, Priority, Direction, SubjectField, BodyHtml, BodyText, Mark)
		values(@Now,'Email','Scheduled','Active', @FromField, @RemoteAddress,@RemoteAddress,  @TOCC ,@GW,99,'O',
		'FSL1: '+@Company+' '+@Message+' '+ISNULL(@Specif,'')+' '+@ProcVer, @RecMsg, @RecMsg, @Mark )
*/
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
    /* Dočasné vyřazení
	IF (EXISTS(SELECT * FROM $(MonitorDB).dbo.Message as M WITH (NOLOCK) where M.Messagetype='Email' AND MessagePhase='Scheduled' AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE()))) 
	  BEGIN
	    EXEC  .[dbo].[WriteEvent] 1,'CheckSys','End of procedure'
	    RETURN --====================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	  END */



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
    DECLARE @UTCDif AS Integer = 1 -- (SELECT TOP 1 DATEDIFF(HOUR,PilotTime,TimeUTC) FROM $(MonitorDB).dbo.InboundCall WITH (NOLOCK) ORDER BY TIMEUTC DESC)
    DECLARE @fromUTC AS datetime=DATEADD(Hour,@UTCDif,@from)
    DECLARE @toUTC AS datetime=DATEADD(Hour,@UTCDif,@to)
    declare @T as nvarchar(120) = CONVERT(nvarchar(20), DATEADD(MINUTE, -@Interval, @Today), 20) + ' - ' + CONVERT(nvarchar(20), @Today, 8)
	declare @Activity as nvarchar(32)
	declare @LastRecording AS Datetime
	declare @LastinCall AS Datetime
	declare @Severity AS Integer
	declare @OpakpoMin AS Integer = 30 -- Opakuj chybové hlášení po x minutách
	exec MonCheck 'Starting part completed',@StartTime

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
		  EXEC [dbo].[ErrorLogProc] @EmlMsg,@Specif,@ProcVer,@DisplayName,@Severity,10

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

--PRINT 'End of CheckSys';





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




-------------------------------------------------------------
--------------------- Podpůrné procedury --------------------
-------------------------------------------------------------



IF object_id('IsZero') IS NOT NULL
 DROP  FUNCTION  [dbo].IsZero
GO
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2024-01-15
-- Description:	Omezení testovacích výpočtů v podkladových dotazech
-- =============================================

CREATE FUNCTION [dbo].[IsZero] (
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



IF object_id('Fin_Add') IS NOT NULL
 DROP  PROCEDURE  [dbo].[Fin_Add]
GO

CREATE  PROCEDURE [dbo].[Fin_Add]
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

 

IF object_id('Sys_Ack') IS NOT NULL
 DROP  PROCEDURE  [dbo].[Sys_Ack]
GO

CREATE  PROCEDURE [dbo].[Sys_Ack]
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

IF object_id('Stat_Res') IS NOT NULL
 DROP  PROCEDURE  [dbo].Stat_Res
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


IF object_id('DiskSpace') IS NOT NULL
 DROP  FUNCTION  [dbo].DiskSpace
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


IF object_id('DelEventlog') IS NOT NULL
 DROP  PROCEDURE  [dbo].[DelEventlog]
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
  DECLARE @ConfigurationValue2 AS NVARCHAR(MAX) = (SELECT ConfigurationValue FROM $(MonitorDB).[dbo].[CONFIGURATION] WITH(NOLOCK)  WHERE ConfigurationName=@ConfigurationName)
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
  DECLARE @ConfigurationValue2 AS NVARCHAR(MAX) = (SELECT ConfigurationValue FROM $(MonitorDB).[dbo].[CONFIGURATION]  WITH(NOLOCK) WHERE ConfigurationName=@ConfigurationName)
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



IF object_id('IndexReorganize') IS NOT NULL
 DROP  PROCEDURE  [dbo].IndexReorganize
GO

CREATE PROCEDURE dbo.IndexReorganize
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
     THROW 50000, 'Plánovaný konec skriptu', 1; /* --´====================================== */


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

