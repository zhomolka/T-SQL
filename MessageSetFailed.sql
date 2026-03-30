DECLARE @from AS datetime=convert(datetime, '2017.06.14')
DECLARE @to AS datetime=convert(datetime, '2018.11.23 9:30')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER='ef0de42d-e6c2-4719-a264-9447484f4c8b'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1

DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(Day,-30,GETDATE())
    SET @to=GETDATE()
  END


DECLARE @Id AS UNIQUEIDENTIFIER='652393B0-F0EE-E811-B917-0050568306CE'
 BEGIN TRANSACTION
 /*
UPDATE iCC.dbo.Message
SET MessagePhase='Canceled'--'Failed' 
WHERE MessagePhase='Scheduled' AND Direction='O' AND  TimeUTC <= @From
*/
UPDATE iCC.dbo.Message
SET MessagePhase='Sent'--'Failed' 
WHERE MessagePhase='Scheduled' AND Direction='O'
 AND MessageResult='Closed'
-- AND  TimeUTC <= @From

COMMIT TRANSACTION

--ROLLBACK TRANSACTION
