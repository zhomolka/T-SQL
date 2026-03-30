/****** Script for SelectTopNRows command from SSMS  ******/
USE iCC
GO
DECLARE @from AS datetime=convert(datetime, '2024.03.29 8:00')
DECLARE @to AS datetime=convert(datetime, '2024.04.02')
DECLARE @AgentId AS UniqueIdentifier = '22d01bc8-0d1f-4307-bce3-e4f0903f175e' -- Paní Kulhánková
--SET @AgentId ='7239722d-bac8-40f7-8d09-70a749f92b5a' 
DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(DAY,-1,GETDATE())
    SET @to=GETDATE()
  END
SELECT TOP (1000) --[AgentEventId]
      --,[TimeUtc]
      AE.[TimeLocal] AS TimeReady
	  ,AE.[Duration] AS ReadyDuration
      ,AG.DisplayName AS AgentName
	  ,DATEDIFF(ss,AE.TimeUtc,CAE.TimeUtc) AS DistribDuration
      --,[TeamName]
      --,[WorkplaceId]
      --,[ProjectId]
      --,[ReferenceData]
      --,[ReferenceId]
      --,[ResultData]
      --,[Actor]
  FROM [iCC].[dbo].[AgentEvent] AE
    LEFT JOIN [iCC].[dbo].[Agent] AG ON AG.AgentId=AE.AgentId
	LEFT JOIN [iCC].[dbo].[CallEvent] CAE ON CAE.AgentId=AE.AgentId 
	AND CAE.TimeUTC>=AE.TimeUtc AND CAE.TimeUTC<=DATEADD(SS,AE.Duration,AE.TimeUtc)
	  AND CAE.EventType='Distributing' 
  WHERE 1=1
     AND AE.TimeLocal> @from AND AE.TimeLocal< @To
   AND AE.EventType='AgentStatus'
   --AND CAST(TimeLocal AS DATE) = CAST(@From AS DATE)
   AND AE.AgentId=@AgentId
   AND AE.ReferenceData='Ready'
  -- AND Actor<>'RESET'
  --AND AE.ResultData='Phone'
   --AND Duration > 10000
   ORDER BY AE.TimeLocal