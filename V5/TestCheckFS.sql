declare @Now as datetime = GETDATE()
	declare @Pred15min as datetime = DATEADD(MINUTE, -15, @Now )	-- Pøed 15 min

	declare @Interval as int = 30;
	declare @Debug as bit = 0


	declare @Last as datetime = DATEADD(MINUTE, -@Interval, @Now ) -- Posledních 30minut
	declare @WeekAgo as datetime = DATEADD(DAY, -7, @Now )
	declare @DayAgo as datetime = DATEADD(DAY, -2, @Now )
	declare @Yesterday as datetime = DATEADD(DAY, -1, @Now )
	declare @LastWeekAgo as datetime = DATEADD(DAY, -7, @Last )
	declare @OneHourAgo as datetime = DATEADD(Hour, -1, @Now )
    DECLARE @from AS datetime=DATEADD(Hour,-3,GETDATE())
  --  DECLARE @to AS datetime=DATEADD(Minute,-@PairingTime,GETDATE())
    DECLARE @UTCDif AS Integer = (SELECT TOP 1 DATEDIFF(HOUR,PilotTime,TimeUTC) FROM Frontstage.dbo.InboundCall WITH (NOLOCK) ORDER BY TIMEUTC DESC)
    DECLARE @fromUTC AS datetime=DATEADD(Hour,@UTCDif,@from)
   -- DECLARE @toUTC AS datetime=DATEADD(Hour,@UTCDif,@to)
    --declare @T as nvarchar(120) = CONVERT(nvarchar(20), DATEADD(MINUTE, -@Interval, @Today), 20) + ' - ' + CONVERT(nvarchar(20), @Today, 8)
	declare @Activity as nvarchar(32)
	declare @LastRecording AS Datetime
	declare @LastinCall AS Datetime
	declare @Severity AS Integer
	declare @OpakpoMin AS Integer = 30 -- Opakuj chybové hlášení po x minutách
	--exec FSCMonCheck 'Starting part completed',@StartTime
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
--DECLARE Mon_cursor CURSOR FOR   
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
