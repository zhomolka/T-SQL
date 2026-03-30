/****** Script for SelectTopNRows command from SSMS  ******/
USE iCC
GO
DECLARE @from AS date=convert(datetime, '2018.06.01')
DECLARE @to AS date=convert(datetime, '2018.06.30')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent WHERE Activity='Ready')
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
DECLARE @Number AS integer
DECLARE @GroupInterval AS integer=44640
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @Version  AS integer=1
DECLARE @AgentId AS UniqueIdentifier = 'ddbc22e5-af73-4387-a5f4-77cd11740afe' -- Paní Balážová
SET @AgentId ='f0ad4d7e-c9e6-46c2-962e-c178370b3097' -- Paní Ganev

/**/
SET @from=GETDATE()-50
SET @to=GETDATE()

SELECT TOP 1000 
       [Predistributed]
	  ,[Priority] 
	  ,[TimeLocal]
          , IVRST.DisplayName AS Ivrkrok
      --,[DistributionTime]
	   ,[ScheduleTime]    
  , DATEDIFF(MINUTE,ScheduleTime,ISNULL(TimeLocal,GETDATE())) AS Delay
  , CallDuration
       ,[CallerNumber]

  
      ,[EventType]
      ,[InboundCallId]
      ,CAE.[OutboundCallId]
      ,CAE.[ProjectId]
      ,CAE.[AgentId]
      ,CAE.[WorkplaceId]
      ,[ReferenceData]
      ,[ReferenceId]
      ,[Duration]
      ,[ResultData]
      ,[ActorId]
  FROM [iCC].[dbo].[CallEvent] CAE
  LEFT JOIN [iCC].[dbo].[OutboundCall] OC ON CAE.OutboundCallId=OC.OutboundCallId
  LEFT JOIN IvrStep AS IVRST ON IVRST.IvrStepId=CAE.ReferenceId

  WHERE 1=1
	AND EventType='Error' --and ResultData like 'Divert not arrived%'
    --AND [TimeLocal]>@from
	--AND OC.CallerNumber='00902297141'
	 --AND ProjectId='5B9F0380-64D3-4151-A91B-372E7ED4A953'
   --AND  EventType='NewCall'
   --AND CAE.AgentId=@AgentId
    --AND  ResultData='Auto'
    --AND  ReferenceData='Update'
    --AND CAE.OutboundCallId IS NOT NULL
	--AND OC.OutboundCallId='a200ac00-2b78-eb11-b7fb-005056a0e001'
	AND CAE.InboundCallId='4DFB82F5-DCB3-EB11-B7FB-005056A0E001'
    --AND (SELECT TOP 1 AgentId FROM CallEvent CAE2 WHERE CAE2.OutboundCallId=CAE.OutboundCallId AND CAE2.TimeLocal<CAE.TimeLocal ORDER BY TimeLocal DESC)<>CAE.AgentId
  ORDER BY [TimeLocal]