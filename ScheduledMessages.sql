DECLARE @from AS datetime
DECLARE @to AS datetime
--SET @from=convert(datetime, '2016.04.25 00:00')
--SET @to=convert(datetime, '2016.04.26 06:00')
SET @from=GETDATE()-0.5
SET @to=GETDATE()

SELECT 
  GW.DisplayName AS Gateway
  ,SUM(1)  AS Naplánováno
  
  FROM [iCC].[dbo].[Message] ME
  LEFT JOIN [iCC].[dbo].[Gateway] GW ON ME.GatewayId=GW.GatewayId
  WHERE Priority>=0
  --AND TimeUTC >= @FROM AND TimeUTC <= @TO
    AND MessagePhase='Scheduled' 
   GROUP BY GW.DisplayName 
   ORDER BY GW.DisplayName 
   ----------------------------------
   SELECT 
  GW.DisplayName AS Gateway
  ,SUM(1)  AS Odesláno
  
  FROM [iCC].[dbo].[Message] ME
  LEFT JOIN [iCC].[dbo].[Gateway] GW ON ME.GatewayId=GW.GatewayId

  WHERE Priority>=0
  AND ReceivedSentTime >= @FROM AND ReceivedSentTime <= @TO
    AND MessagePhase='Sent'
 
   GROUP BY GW.DisplayName 

   UNION ALL
     SELECT 
  '---- CELKEM ----' AS Gateway
  ,SUM(1)  AS Odesláno
  
  FROM [iCC].[dbo].[Message] ME
  LEFT JOIN [iCC].[dbo].[Gateway] GW ON ME.GatewayId=GW.GatewayId

  WHERE Priority>=0
  AND ReceivedSentTime >= @FROM AND ReceivedSentTime <= @TO
    AND MessagePhase='Sent'
ORDER BY GW.DisplayName 
 

-----------------------------------------------------------------------------
/*
 BEGIN TRANSACTION
UPDATE iCC.dbo.Message
SET GatewayId = '980de814-f009-4e08-9fa6-45c728b3de96'
WHERE  GatewayId IS NULL
  AND TimeUTC >= GETDATE()-2
  AND MessageType='Email'
  AND Direction='O'

COMMIT TRANSACTION

--ROLLBACK TRANSACTION
*/
