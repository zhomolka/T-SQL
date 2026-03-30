USE FS_Custom_TVP
-----------------------------------------------------------------------------------------------------------------------------------------------------
   declare @ProcVer as nvarchar(35) = ' Inspection function ver: 15.2.23'
	DECLARE @StartTime AS Datetime = GETDATE()
	declare @Today as datetime = GETDATE()

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

	--declare @TOCC as nvarchar(200) = 'kubat@atlantis.cz;homolka@atlantis.cz;roman.dolezal@digi2go.cz'
	declare @Mark as int = 77
	/*IF (NOT EXISTS(SELECT TOP 1 1 FROM $(ICC).dbo.Holiday as H where H.HolidayGroupName='INSPECTION' AND H.TimeMode='SingleDay' ))
	  insert into $(ICC).dbo.Holiday([DisplayName],[HolidayGroupName],[TimeMode],[TimeFrom],[TimeTo])
		values('CheckRecAndEml','INSPECTION','SingleDay',CONVERT(DateTime,'2018.08.01 8:00'),CONVERT(DateTime,'2018.08.01 17:00')) */


	--IF(EXISTS(SELECT * FROM $(ICC).dbo.Holiday as H where H.HolidayGroupName='INSPECTION' AND H.TimeMode='SingleDay' AND (.dbo.TimeCompare2(H.TimeFrom,'>',GETDATE())=1 OR .dbo.TimeCompare2(H.TimeTo,'<',GETDATE())=1))) RETURN
	IF(EXISTS(SELECT * FROM ICC.dbo.Holiday as H WITH (NOLOCK) where H.HolidayGroupName=@Holiday AND H.TimeMode='SingleDay' AND CAST(H.TimeFrom as DATE)=CAST(@Today AS DATE))) RETURN
	IF(EXISTS(SELECT * FROM ICC.dbo.Holiday as H WITH (NOLOCK) where H.HolidayGroupName=@Holiday AND H.TimeMode='DayInYear' AND DATEPART(DAY,H.TimeFrom)=DATEPART(DAY,@Today) AND DATEPART(MONTH,H.TimeFrom)=DATEPART(MONTH,@Today))) RETURN
	-- Pokud tam jsou mé neodeslané maily mladší 24hodin, neodesílám další
	IF(EXISTS(SELECT * FROM ICC.dbo.Message as M WITH (NOLOCK) where M.Messagetype='Email' AND MessagePhase='Scheduled' AND M.Mark=@Mark AND M.TimeUTC>DATEADD(DAY,-1,GETUTCDATE()))) RETURN


	declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Today )	-- Pøed 15 min

	declare @Interval as int = 30;
	declare @Debug as bit = 0

	declare @Now as datetime = GETDATE()
	declare @Last as datetime = DATEADD(MINUTE, -@Interval, @Now ) -- Posledních 30minut
	declare @WeekAgo as datetime = DATEADD(DAY, -7, @Now )
	declare @DayAgo as datetime = DATEADD(DAY, -2, @Now )
	declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
	declare @LastWeekAgo as datetime = DATEADD(DAY, -7, @Last )
	declare @OneHourAgo as datetime = DATEADD(Hour, -1, @Now )
    DECLARE @from AS datetime=DATEADD(Hour,-3,GETDATE())
    DECLARE @UTCDif AS Integer = (SELECT TOP 1 DATEDIFF(HOUR,PilotTime,TimeUTC) FROM ICC.dbo.InboundCall WITH (NOLOCK) ORDER BY TIMEUTC DESC)
    DECLARE @fromUTC AS datetime=DATEADD(Hour,@UTCDif,@from)
    declare @T as nvarchar(120) = CONVERT(nvarchar(20), DATEADD(MINUTE, -@Interval, @Today), 20) + ' - ' + CONVERT(nvarchar(20), @Today, 8)
	declare @Activity as nvarchar(32)
	declare @LastRecording AS Datetime
	declare @LastinCall AS Datetime
	declare @Severity AS Integer
	declare @OpakpoMin AS Integer = 30 -- Opakuj chybové hlášení po x minutách
declare @LastMessage AS NVARCHAR(50)
declare @InformBySecondMatch AS bit

   ------------ OBECNÁ SEKCE:
DECLARE @StartProcTime DateTime
declare @MonitorId AS UniqueIdentifier
declare @ExecDuration AS Integer
declare @Command AS NVARCHAR(500)
declare @DisplayName AS NVARCHAR(50)
declare @Hour as Integer = DATEPART(HOUR,@Now)
SELECT @Hour AS Actual_Hour
--------------------------------------------------------------------------
SELECT DisplayName,RunFromHour,RunToHour,RepeatAfterMin,LastRunTime,LastMessage,ExecDuration,
DATEADD(MINUTE,RepeatAfterMin,LastRunTime) AS LimTime,@Now AS ActualTime,
IIF(@Hour >= RunFromHour AND @Hour <= RunToHour AND 
(LastRunTime IS NULL OR DATEADD(MINUTE,RepeatAfterMin,LastRunTime)<@Now)
    AND Command is not NULL and RepeatAfterMin <>-1,'YES','NO') AS Run
--------------------------------------------------------------------------
FROM FSCMonitor

DECLARE Mon_cursor CURSOR FOR   
SELECT TOP 1000 [MonitorId]
      ,[Command]
	  ,DisplayName
	  ,LastMessage
	  ,InformBySecondMatch
      --,[Inform1]
      --,[Inform2]
      --,[Inform3]
      --,[Rank]
  FROM .[dbo].[FSCMonitor]
  WHERE @Hour BETWEEN RunFromHour AND RunToHour AND (LastRunTime IS NULL OR DATEADD(MINUTE,RepeatAfterMin,LastRunTime)<@Now)
    AND Command is not NULL and RepeatAfterMin <>-1

  OPEN Mon_cursor 
  FETCH NEXT FROM Mon_cursor INTO @MonitorId,@Command,@DisplayName,@LastMessage,@InformBySecondMatch

  WHILE @@FETCH_STATUS = 0  AND DATEDIFF(SS,@StartTime,GETDATE())<25
    BEGIN
	  SET @StartProcTime=GETDATE()
	  --SET @EmlMsg=.[dbo].InspectCallEvent()
	  SET @Command='SET @EmlMsg=.[dbo].'+LTRIM(@Command)
      EXEC SP_EXECUTESQL @Command, N'@EmlMsg NVARCHAR(300) OUTPUT', @EmlMsg OUTPUT
	  IF ISNULL(@EmlMsg,'')<>'' AND (ISNULL(@InformBySecondMatch,0)=0 OR @EmlMsg=@LastMessage)
	    BEGIN		  
 		  SET @Severity = (SELECT IIF(@EmlMsg LIKE '%!!!%',10,0 ))
		  EXEC [dbo].[ErrorLogProc] @EmlMsg,@Specif,@ProcVer,@DisplayName,@Severity,10

		END
		SET @ExecDuration=DATEDIFF(SS,@StartProcTime,GETDATE())
		UPDATE .dbo.FSCMonitor
          SET LastRunTime  = GETDATE()
		     ,ExecDuration = @ExecDuration
		     ,LastMessTime = IIF(ISNULL(@EmlMsg,'')='',NULL,GETDATE())
		     ,LastMessage  = @EmlMsg
          WHERE MonitorId =@MonitorId
         SELECT @DisplayName+' had duration '+CONVERT(NVARCHAR(2),@ExecDuration)+' seconds' AS Test,@EmlMsg AS Message

		FETCH NEXT FROM Mon_cursor INTO @MonitorId,@Command,@DisplayName, @LastMessage,@InformBySecondMatch
    END
  CLOSE Mon_cursor;  
  DEALLOCATE Mon_cursor;
----------------------------------------------------------------------------------------
