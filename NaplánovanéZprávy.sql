DECLARE @from AS datetime
DECLARE @to AS datetime
--SET @from=convert(datetime, '2016.04.25 00:00')
--SET @to=convert(datetime, '2016.04.26 06:00')
SET @from=GETDATE()-2
SET @to=GETDATE()

SELECT 
 MessageId
 , GW.DisplayName AS Gateway
 , MessageType
  ,TimeUTC  
  ,ScheduledTime
  ,SubjectField
  ,RemoteAddress
  , MessagePhase
  , MessageResult
  
  FROM .[dbo].[Message] ME
  LEFT JOIN .[dbo].[Gateway] GW ON ME.GatewayId=GW.GatewayId
  WHERE 1=1
  --AND TimeUTC >= @FROM AND TimeUTC <= @TO
    AND MessagePhase='Scheduled' 
	--AND MessageType='Email'
	AND ME.Direction='O'
   --GROUP BY GW.DisplayName 
   ORDER BY /*GW.DisplayName,*/ TimeUTC DESC
   ----------------------------------
 