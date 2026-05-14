
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
  EXEC $(FS_custom).[dbo].[DelDuplIndexes]
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
		@command=N'EXEC $(FS_CUSTOM).dbo.Maintenance', 
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

 IF object_id('$(Icc_Backup)..Backup_WfmSlot') IS NOT NULL
 BEGIN
  DROP  PROCEDURE [dbo].Backup_WfmSlot
 END


GO
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <14.04.2020>
-- Description:	Záloha 1 (konfigurační) tabulky do iCC_Backup
-- =============================================

CREATE PROCEDURE [dbo].[Backup_WfmSlot]
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
EXEC Icc_Backup.dbo.Backup_WfmSlot

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
       N'{"SchemaVersion":2,"UsedVersion":2,"Definitions":[{"DisplayName":"Výchozí","Id":"6e55028d-aac3-4b6c-852f-9682850c5748","Options":{"CommunicationInfo":{"VoiceDisplayTemplate":"{Scenario:IntegrationEndpoints} | {ProjectName}","ChatDisplayTemplate":"Chat {ContactName};{ProjectName};{UnreadCount}","MessageDisplayTemplate":"Message {ContactName};{ProjectName}","TaskDisplayTemplate":"Task {ContactName};{ProjectName}"},"SplashHideTimeoutMilliseconds":2000,"ClientAlert":{},"AgentStatus":{"AllowChangeBetweenLogoffStatuses":true,"StatusChangeRequestTimeoutSeconds":20},"AgentWorkplace":{"WorkplaceChangeRequestTimeoutSeconds":20},"UiOptions":{"BootstrapColorMappings":{"success":"#13A10E","danger":"#E81123","primary":"#0078D4","info":"#EAEAEA","warning":"#d6d600","white":"#ffffff","default":"#000000"},"DqBootstrapColorMappings":null},"WebView":{"ChatWindowUrl":"http://10.225.239.102/ReactClient/pages/ChatEditor.html?id={chatId}&Embedded=true"},"VoiceCommandThrottleMilliseconds":3000},"ComponentGroups":[{"Name":null,"Components":[{"Id":"215e57b2-14ea-4021-b822-c0a5084c2f19","CodeName":"OpenUrlButton","IsEnabled":true,"DisplayColorVariant":0,"NavigateUrl":"http://10.225.239.102/ReactClient/Pages/portal.html#agent_home","PictogramUrl":"pack://application:,,,/Resources/LogoFS_32x32.png","Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"3605fec3-16c6-46ef-a173-6a2b2bd9611b","CodeName":"OpenUrlButton","IsEnabled":true,"DisplayColorVariant":0,"NavigateUrl":"http://10.225.239.102/ReactClient/Pages/portal.html#agent_WB","PictogramUrl":"pack://application:,,,/Resources/LogoFS_32x32.png","Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"ec741da3-0d98-43e2-915a-539c44c8ef52","CodeName":"OpenUrlButton","IsEnabled":true,"DisplayColorVariant":0,"NavigateUrl":"https://www.alza.cz","PictogramUrl":"pack://application:,,,/Assets/Images/alza_cz.png","Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"72d54fa5-e1b7-442a-b621-6023b4ff2537","CodeName":"OpenUrlButton","IsEnabled":true,"DisplayColorVariant":0,"NavigateUrl":"https://www.alza.sk","PictogramUrl":"https://cdn.alza.cz/Foto/imggalery/LandingPages/Logomanual/images/alza_cz.png","Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":2,"AppendSeparator":true,"Orientation":0,"Band":0,"BandIndex":0,"Id":"98f58600-e8c9-4367-b559-b0d1ac10847f","CodeName":null,"IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":92.0,"RightSeparator":true,"CompoWidthEstimate":32.0},{"Name":null,"Components":[{"Id":"67882081-7e11-46df-8940-3dae206887b2","CodeName":"WorkplaceStatusDropdown","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":126.0},{"Id":"5e51a3d3-b82e-4a5e-98f6-6b61a958a6d5","CodeName":"WorkplaceDropdown","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ConfirmActionResourceName":"DC_Confirm_WorkplaceSignout","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":126.0},{"Id":"faaaaa5d-58dc-41bf-8990-d2caf8cb4ce6","CodeName":"QuickStatusButton","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","QuickAgentStatusId":"78028459-ca9e-45de-a574-5005f96774bc","QuickAgentStatusResetId":"60fba1e2-08f0-4129-97b3-3041e9ee27b8","QuickAgentStatusPictogram":"","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"a7fb5f17-8cf7-44f2-8bfc-f38d956b9566","CodeName":"QuickStatusButton","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","QuickAgentStatusId":"60fba1e2-08f0-4129-97b3-3041e9ee27b8","QuickAgentStatusResetId":"78028459-ca9e-45de-a574-5005f96774bc","QuickAgentStatusPictogram":"","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":4,"AppendSeparator":true,"Orientation":0,"Band":0,"BandIndex":1,"Id":"22705536-7055-46fc-825b-65c7a09ae586","CodeName":null,"IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":184.0,"RightSeparator":true,"CompoWidthEstimate":32.0},{"Name":null,"Components":[{"Id":"701f7695-1423-4a32-b8f3-d642a1b568fb","CodeName":"BasicCallBar","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":270.0},{"Id":"b9c6eaca-3bf4-4721-ab7c-94f90bb0539e","CodeName":"MicroMuteButton","IsEnabled":true,"DisplayColorVariant":0,"Command":"ToggleRecordingDeviceMute","Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"d38948ac-2ff5-465e-bf81-fe38fac0b2e1","CodeName":"ToggleSoftphone","IsEnabled":true,"DisplayText":"","DisplayColorVariant":0,"Command":"ToggleSoftphone","Size":"Standard","ToolTipResource":"DC_ToggleSoftphone_Toggle_Tooltip","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"bf096e17-8ae1-4ea8-8e40-7c06a62cab32","CodeName":"TransferCallBar","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":270.0},{"Id":"eff4323d-274a-4f3a-b5da-1c3cea093b07","CodeName":"VolumeControl","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":9,"AppendSeparator":true,"Orientation":0,"Band":0,"BandIndex":2,"Id":"9e52b5ee-6b9b-431d-9439-0b4e1369e918","CodeName":null,"IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":414.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Name":null,"Components":[{"Id":"7400caf1-8d28-43f3-ba22-8eb3e4b92fff","CodeName":"InteractionContextInfo","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":435.0},{"Id":"ce3b8e08-0050-42ed-8a5e-8f2e80b8eed6","CodeName":"ClientAlertBoard","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":435.0}],"BlockWidth":-1,"AppendSeparator":true,"Orientation":1,"Band":0,"BandIndex":3,"Id":"11e3611d-1c64-46da-a5af-783f6c37b429","CodeName":null,"IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":435.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Name":"Moje","Components":[{"Id":"fb678d00-28b9-4558-aee2-34b0b450e436","CodeName":"CallDuration","IsEnabled":true,"DisplayText":"Akutální hovor","DisplayColorVariant":0,"Size":"Standard","CellColor":"#404040","ValuePresentation":1,"MarginLeftPx":0.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"ce966fa2-981e-4287-bcc1-cff3118f94a6","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"0a1bc7b8-e87b-4b1b-b47b-ddd6898baa0c","CellViewer":"DqCifernik","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"7361b080-57b7-4031-a2ef-0869d4957045","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"e9c9bbf5-2874-4088-9845-1c867977bffc","CellViewer":"DqCifernik","ValuePresentation":0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":-1,"AppendSeparator":true,"Orientation":1,"Band":0,"BandIndex":4,"Id":"5da8b341-c3da-4601-aadb-241bda550e30","CodeName":null,"IsEnabled":true,"DisplayText":"Moje","DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":180.0,"RightSeparator":true,"CompoWidthEstimate":32.0},{"Name":"","Components":[{"Id":"7bc87002-6ca0-48bd-a88e-4cca3408d50c","CodeName":"DqCell","IsEnabled":true,"DisplayText":"{0} Agentů v pauze","DisplayColorVariant":0,"Size":"Standard","CellColumnId":"0bf0bff9-a0b4-4635-a18f-c1c796e732c8","CellViewer":"DqLabel","CellLabelIcon":2,"ValuePresentation":0,"MarginLeftPx":10.0,"MarginRightPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"63c036bb-f066-4f73-992f-59730ea7402b","CodeName":"DqCell","IsEnabled":true,"DisplayText":"{0} Ztracené h.","DisplayColorVariant":0,"Size":"Standard","CellColumnId":"16033a9a-896f-4d17-9b84-d68ca053ea4d","CellViewer":"DqLabel","CellLabelIcon":1,"ValuePresentation":0,"MarginLeftPx":10.0,"MarginRightPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"52606af8-388e-42c9-8779-c9dbf12f4b94","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"65a8dc06-ced1-497a-bd07-2930d3e20806","CellViewer":"DqProgress","CellColor":"#EE4000","ValuePresentation":0,"MarginLeftPx":10.0,"MarginRightPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":-1,"AppendSeparator":true,"Orientation":1,"Band":0,"BandIndex":5,"Id":"4f906769-384b-49fe-ba6b-ad6ed76dca81","CodeName":null,"IsEnabled":true,"DisplayText":"","DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":140.0,"RightSeparator":true,"CompoWidthEstimate":32.0},{"Name":"ServiceLevel","Components":[{"Id":"d06bf74b-78f8-4712-9496-875abd96231e","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"1fd4ff53-78c8-431d-8a8c-50a35e6f7999","CellViewer":"DqProgress","CellRangeMinimum":0.0,"CellRangeMaximum":100.0,"CellColor":"#8d289f","ValuePresentation":0,"MarginLeftPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"0b988efb-e3ac-4669-adeb-e97330a5bdd9","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"0c07acd8-3c5a-4553-b6f3-985d5f3718b1","CellViewer":"DqProgress","CellRangeMinimum":0.0,"CellRangeMaximum":100.0,"CellColor":"#cc8733","ValuePresentation":0,"MarginLeftPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"57ce23b5-8829-42d3-ac83-b0a2b1c17295","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"f644ffd0-6dc8-4b22-835e-955b458aa7d8","CellViewer":"DqProgress","CellRangeMinimum":0.0,"CellRangeMaximum":100.0,"CellColor":"#2caf2c","ValuePresentation":0,"MarginLeftPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"aafcc296-b022-48f3-bcce-7d06d4b86a02","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"f178b040-66f4-4934-af13-13a9b86037c1","CellViewer":"DqProgress","CellRangeMinimum":0.0,"CellRangeMaximum":100.0,"CellColor":"#cc5233","ValuePresentation":0,"MarginLeftPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0},{"Id":"9388dcaa-4b0c-46ed-9678-993b7a3b913f","CodeName":"DqCell","IsEnabled":true,"DisplayColorVariant":0,"Size":"Standard","CellColumnId":"77ecad57-f58e-4276-b115-0f04a48a336a","CellViewer":"DqProgress","CellRangeMinimum":0.0,"CellRangeMaximum":100.0,"CellColor":"#269797","ValuePresentation":0,"MarginLeftPx":10.0,"RightSeparator":false,"CompoWidthEstimate":32.0}],"BlockWidth":-1,"AppendSeparator":true,"Orientation":1,"Band":0,"BandIndex":6,"Id":"8ea40c7c-9da1-4bd9-84b1-726c00d80430","CodeName":null,"IsEnabled":true,"DisplayText":"ServiceLevel","DisplayColorVariant":0,"Size":"Standard","ValuePresentation":0,"HeightPx":90.0,"WidthPx":350.0,"RightSeparator":false,"CompoWidthEstimate":32.0}]}],"SelectedDefinitionId":"6e55028d-aac3-4b6c-852f-9682850c5748","RibbonResources":{"ResourceList":[{"Sha256Hash":"647703b726f27267036fad8eaf435fe1d321da7ebf14f8162d959a58732229c9","Id":"6e1d0baa-7a6b-4612-94b2-5b5dcc074f26","Data":"iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAAH/ElEQVR4nO3dTXrbuBIF0HJ/vcUsIbMsJ7MsIYvMG/THZ7baliWKAC7Ac6b5I6tulUDZkasAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgKW+jL2Dv+88/v7/6Pb9+vH3rcS3wrEfyW5WV4YgF8GjhbiUVkuuaOb/DF8DR4t1KKCbXsUpuhy2Aswp4a3RBWdtquR2yAFoVcc8i4EyrZrbrAuhRxFsWAa9YPbPdIQu5ZBDzjKnntsgBGF3PPIuCeq2W16QJIKuYti4BbqXltmdVmCyC1mLcsAmbIaqucNlkAMxR0zxK4JjltsABmK+qeRXANMvru1AUwc2H3LIJ1rZDRM/N52gJYobC3LIJ1rJbPs7J5ygJYrbh7lsDcZPO+lxfAygXeswjmIpeP+eusC1nd959/fl8lVLPTp8e9dAK4aqGdBjLJ4/MOL4CrFnvPIsggi8ezeGgBKPi/WQTjyOK7Izl8egH0Lvh2U+mNtgT6miUPo+blUdEL4KObmaXxtDFj/0fPzD1PLYBeN/LITcwYBF6T3POkzD6TvYcXQOLFV80fCr62Uo/T5ihqAbwyMCuFhHepfU3P6qkLIOmCv7JiYK5o9T6mzFTEAmgxHKsHaFWpfas6v3cJc/XlAki4yKOuFKYVpPZr5ox+de13F8DoizvLFYM1k6v3Z+ScDVsAI8J/9aCl0Y93o2bt0/8NmNqcV/z68fYtcdhWrPVXUu85MR+vulfrT08Aq7363xLAMdT9cyNmrvsCSCj0nkD2k1jrtDr3nrsPF8BVhn9PONtJrG1Vbn17zt/fLf6hGf368fYtLajb9aQG9Stp9dzMWs8W/nMCuOKr/63E4M5Uvyo1fFWvOeyyAGYq/F5aiGeoY1rNNjPU7laPWfShoHfMGJqREoc/9Uu/Kf51AvDq/7mUcCfWM6U2e4l1OqL1THoT8EGzfDRZT6m1WGX4e2j6CLBiI1a8pyMSh3/F437r+/n/CSCxoamufBpIvOfVhr617z///N5q5k3AF1wteIZ/Pc3eA7hKY65wGki8t6vkq6rtN6n9VZXZ4Nms+PyZ+vMQV6vzCFtfmzwCXLlBq9x76uCvUt9ntbpvXwZsYObHgsRrvurQ9+BNwIbODm7rQTD81+ME0NgMp4HEazP4fbyd3XyNu+9ova/y0enyc9/ZPfMI0NmRgBt+WvEIMMCjjwUGn9YsgIF6B9/wc+vU9wA0M5PBX8uZ/XQCWFza8Bv8LBbAotIGv8rwJ7IAFmPweYYvAy7E8PMsJ4AFGHyOsgAmlzb8Bn8uk0ga/yvDPyAKYjMHnTN4EnIjh52xOABMw+LTiBBDO8NOSE0Aog08PFkAYg09PHgGCGH56cwIIYPAZ5dQTQGKQ0yXWzPDnOjsvTgCDGHwSWACdXXHwP7pnyyaDBdDRlYb/q3vd/7plMM5b1bnB1Mz/utLgVx27X7n5Wouf4XH6lwETwz5SYj3Shn/7c4m1Wp1HgEYSwzzDzxbc/g4ngj4sgJNdcfBb+P7zz+8Zr3s2Tb4TMHEIeki8715D1OLePRa8a1WHv6v+CYlCH5dYu5VePT0WnG+rZbP/C5A4FC0k3ueqg5JY6x5a3rf3AA5KDOOqg7/nNHAuC+BJiYNfdb2BsAiO29fsbf8LLcK9UoMShz+lvqNrk1KHs7WeSSeAB4wO90dWDfxRvmx4TPMTQNW8YU0c/KrMeibVKrE+R/Q4kb/d/gaPAf9ICvQmvY5pNUuv1z29Xoy7fCRYWjDuSf3mk5nDPEpiH9P85wRQdc1HgdSwJNfsI+r4up7z50NBKzO0v368fZsptJvUa0492Y3W9QRQlRWQ1EAk1egVqfWtyq1x79P3hwug5YXcu5heUoM5ui4tpNZ6k1TzETN3uUeA1EAmBfFM6Y8yKXkYdR2fngCq1joFpDT6VvJwtJDah6qxvRg1a8MWQFWfgqcG7mqDv5fak81KL05f3cvdBVA19xJIDdqVh38vtT+bFV6gXl4AVeMv8lmpwTL4H0vt12bUR6e/6pHrjlgAVecUOTVIBv9rqb3bO7OPKTP10AKoyrngjySHx/A/J7mXm1d7mjRLUQug6vnipgbG4L8mta97R3qcNkcPL4CqrItPDojhP09ynzdpeX0mf08tgKrxN5IcCIPfRnLP9z7r/+iZuSd6AVS931ByCAx+H8kZ2NvnIXn4qw4sgKp5GtGD4e9P/j7WbQFUaYLBH+vq+bt1NI+HF0DVNZtg8LNcMYO3XsmkBfAEw5/ralncvJrJlxZA1TUKb/DncYU87g1fAFXrFt3gz2nVPN46I5+nLICq9Ypu+Oe3Wib3zsrnaQugao2CG/z1rJDLvTMzeuoCqJq32AZ/fbNmc+/snJ6+AKrmK7Thv5bZ8rlpkdMmC6BqjiIb/GubIaObVllttgCqcgts8NlLzWlV+6w2XQCblAIbfO5JyemmR167LICqscU1+DwjYRH0ymy3BVA1prCGn6NGLYKeme26AKqyPlUIHrFyZrsvgM0VfwQ5c1vpJ2Vthi2AqnMLavDp6azsjs7t0AWwOVrM0cWDVxZBQn4jFsDmkWImFA0+8ugykGEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAm9j8uDeeU7UC5VgAAAABJRU5ErkJggg==","Origin":null}]}}'



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
