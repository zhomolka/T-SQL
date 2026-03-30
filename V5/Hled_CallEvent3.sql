/****** Script for SelectTopNRows command from SSMS  ******/
--USE iCC_H
--GO
DECLARE @from AS date=convert(datetime, '2018.06.01')
DECLARE @to AS date=convert(datetime, '2018.06.30')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent WHERE Activity='Ready')
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-5
DECLARE @Number AS integer
DECLARE @GroupInterval AS integer=44640
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @Version  AS integer=1
DECLARE @AgentId AS UniqueIdentifier = 'ddbc22e5-af73-4387-a5f4-77cd11740afe' -- Paní Balážová
SET @AgentId ='f0ad4d7e-c9e6-46c2-962e-c178370b3097' -- Paní Ganev

/**/
SET @from=GETDATE()-7--@today--
SET @to=GETDATE()

SELECT DISTINCT TOP 10000 
	  .dbo.FSC_TimeUTC_Local(CAE.[TimeUTC]) AS TimeLocal
	  ,CAE.[ResultData]
      --,CAE.[EventType]
	  ,LL.LiteralText AS Event
	  ,WP.Number AS WPNumber
	  ,IC.Callernumber
	  --,IIF(CAE.WorkplaceId<>IC.WorkplaceId OR IC.WorkplaceId IS NULL,'YES','') AS Divert_Failed
	  ,CAE.InboundCallId
	  ,CAE.OUtboundCallId
	  ,CAE.[TimeUTC]
  
 

   FROM .[dbo].[CallEvent] CAE
  LEFT JOIN .[dbo].[CallEvent] CAE2 ON CAE.InboundCallId=CAE2.InboundCallId AND CAE2.EventType=23 --'Error'
  LEFT JOIN .[dbo].[CallEvent] CAE3 ON CAE.InboundCallId=CAE3.InboundCallId 
  AND CAE.AgentId=CAE3.AgentId AND CAE3.EventType=15 --'AgentMissed'
  LEFT JOIN .[dbo].[CallEvent] CAE4 ON CAE.InboundCallId=CAE4.InboundCallId 
  AND CAE4.ResultData='NormalRelease'
  LEFT JOIN .[dbo].[InboundCall] IC ON CAE.InboundCallId=IC.InboundCallId
  LEFT JOIN Workplace AS WP ON WP.WorkplaceId=CAE.WorkplaceId
  LEFT JOIN LiteralLookup AS LL ON LL.LiteralValue=CAE.EventType AND LiteralGroup=44

  WHERE 1=1
	AND CAE.EventType IN (68,23) --('Distributing','Error')
    AND CAE.[TimeUTC]>@from
	AND (CAE2.InboundCallId IS NOT NULL OR CAE.WorkplaceId<>IC.WorkplaceId OR IC.WorkplaceId IS NULL)
	AND CAE3.InboundCallId IS NULL -- Nešlo o zmeškaný hovor
	AND CAE4.InboundCallId IS NULL -- Nešlo o hovor ukonèený zákazníkem
    AND CAE.InboundCallId IS NOT NULL -- Zatím jen pøíchozí hovory
	--AND OC.CallerNumber='00902297141'
	 --AND ProjectId='5B9F0380-64D3-4151-A91B-372E7ED4A953'
   --AND  EventType='NewCall'
   --AND CAE.AgentId=@AgentId
    --AND  ResultData='Auto'
    --AND  ReferenceData='Update'
    --AND CAE.OutboundCallId IS NOT NULL
	--AND OC.OutboundCallId='a200ac00-2b78-eb11-b7fb-005056a0e001'
	--AND CAE.InboundCallId='7a8fcffc-038d-ee11-a194-001e67a4fc92'
    --AND (SELECT TOP 1 AgentId FROM CallEvent CAE2 WHERE CAE2.OutboundCallId=CAE.OutboundCallId AND CAE2.TimeLocal<CAE.TimeLocal ORDER BY TimeLocal DESC)<>CAE.AgentId
  ORDER BY CAE.[TimeUTC] DESC -- WP.Number --