DECLARE @from AS datetime
DECLARE @to AS datetime
--SET @from=convert(datetime, '2016.04.25 00:00')
--SET @to=convert(datetime, '2016.04.26 06:00')
SET @from=GETDATE()-1
SET @to=GETDATE()

SELECT 
  GW.DisplayName AS Gateway
  ,SUM(1)  AS Odesláno
  
  FROM [iCC].[dbo].[Message] ME
  LEFT JOIN [iCC].[dbo].[Gateway] GW ON ME.GatewayId=GW.GatewayId

  WHERE Priority>=0
  AND ReceivedSentTime >= @FROM AND ReceivedSentTime <= @TO
    AND MessagePhase='Sent'
 
   GROUP BY GW.DisplayName 
   ORDER BY GW.DisplayName 