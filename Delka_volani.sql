DECLARE @from AS datetime=convert(datetime, '2016.01.01')
DECLARE @to AS datetime=convert(datetime, '2016.12.31')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER='ef0de42d-e6c2-4719-a264-9447484f4c8b'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1

/*
SET @from=GETDATE()-10
SET @to=GETDATE() */

SELECT AVG(CallDuration) AS Delka_volani
      ,AVG(RoutingDuration) AS RoutingDuration
	  ,AVG(QueueDuration) AS QueueDuration
	  ,AVG(RingDuration) AS RingDuration
FROM InboundCall WITH (NOLOCK) 
WHERE TimeUtc >=@from AND TimeUtc<=@to