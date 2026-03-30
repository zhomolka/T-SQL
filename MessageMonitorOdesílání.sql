/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @from AS datetime
DECLARE @to AS datetime
--SET @from=convert(datetime, '2016.04.25 00:00')
--SET @to=convert(datetime, '2016.04.26 06:00')
SET @from=GETDATE()-1
SET @to=GETDATE()

SELECT 
  SUM(IIF(MessagePhase='Sent',1,0))  AS Sent
  ,SUM(IIF(MessagePhase='Scheduled',1,0)) AS Scheduled
  FROM [iCC].[dbo].[Message]
  WHERE Priority>=0
  AND ReceivedSentTime >= @FROM AND ReceivedSentTime <= @TO
    AND (MessagePhase='Sent' OR MessagePhase='Scheduled')
 