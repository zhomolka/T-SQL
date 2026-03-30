/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @from AS datetime = convert(datetime, '2018.02.05 06:00')
DECLARE @to AS datetime = convert(datetime, '2018.02.05 11:00')
DECLARE @AgentId AS UniqueIdentifier = '488763b2-3384-4420-b518-742de765e1fc' -- Jakub Pokorný

/**/
SET @from=GETDATE()-1
SET @to=GETDATE()


SELECT TOP 1000 [OutboundCallId]
      ,CD.DisplayName
      ,[ScheduleTime]      
      ,[RegionalTime]
	  ,[CallerNumber]
	  ,OC.[DisplayName]
	  ,OC.[CallResult] AS OC_CallResult
	  ,CD.[CallResult] AS CD_CallResult
      ,[RingDuration]
      ,[CallDuration]      
      ,[TimeUtc]
      ,[CallType]
      ,[CallPhase]
       ,[AppResult]
      ,[PbxCallId]
      
      ,[OutboundListId]
      ,[Priority]
      ,[PhoneNumberId]
      ,[ContactId]
      ,OC.[ProjectId]
      ,[Skill]
      ,[PreferredAgentId]
      --,[Rank]
      ,[GroupNumber]
      ,[TimeMode]
      ,[TimeFrom]
      ,[TimeTo]
      ,[EnqueueingTime]
      ,[DistributionTime]
      ,[AnswerTime]
      ,[EndTime]
      ,[AppResultTime]
      ,[PostCallEndTime]
      ,[Trial]
      ,[AgentId]
      ,[TeamName]
      ,[Predistributed]
      ,[WorkplaceId]
      ,[Correlation]
      ,[LanguageId]
      ,[Proficiency]
      ,[OutboundListImportId]
      ,[HoldDuration]
      ,[PcpWrapDuration]
      ,[IssueId]
      ,[ChainingId]
      ,[ConditionLevel]
      ,[Mark]
      ,[IvrScriptAId]
      ,[IvrScriptATime]
      ,[IvrResponseA]
      ,[TransferredTo]
      ,[DialTime]

      ,[ExtendedFields]
 FROM [iCC].[dbo].[OutboundCall] as oc with (nolock) 
  left join iCC.dbo.Project as p with (nolock) on p.ProjectId = oc.ProjectId
  left join iCC.dbo.CallResultDetail as CD with (nolock) on OC.CallResultDetailId = CD.CallResultDetailId
  --LEFT JOIN icc.dbo.Contact AS C ON OC.ContactId=C.ContactId
 --left join iCC.dbo.Agent as a on oc.PreferredAgentId = a.AgentId

  WHERE 1=1    
  AND OC.CallResult <> CD.CallResult 
  AND CD.[CallResult]='NoAnswer'
  AND OC.[CallResult]='Scheduled'
   --AND oc.ProjectId='50666A6A-0638-4582-971C-3224450E1266'
   --AND OutboundCallId='18892cf4-834f-e811-80e4-001e67d77d2e'
   --AND OutboundListId='35dac85c-a199-4523-81e4-079443fcaf2a'
  -- AND CallerNumber IS NOT NULL
  --AND CallerNumber ='0602348633'
   --AND CallResult<>'Failed' AND CallResult<>'Completed'
   --AND CallResult = 'Scheduled'
   --AND CallDuration IS NULL
    --AND CallPhase='Enqueue'
   --AND TimeUTC>@from AND TimeUTC<@To
    --AND AgentId=@AgentId
  --OR TimeUTC>GETDATE()-0.2
  --AND OutboundCallId IN ('03491e00-844f-e811-80e4-001e67d77d2e','4f146771-cdcd-e611-9f09-c81f66e8a47f')
  --AND TimeUTC>GETDATE()-5
  --AND  P.ProjectGroupName='Komercni CC'
  
  ORDER BY TimeUTC DESC