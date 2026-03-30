/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000
      [TimeUTC] AS OutBoundTime
      , FR.Time AS FRTime
      --,FR.LocalNumber AS FRNumber
      --,WP.Number 
      ,OC.CallDuration AS OCCallDuration
      ,FR.Length AS FRCallDuration
      ,[CallType]
      ,[CallPhase]
      ,[CallResult]
      ,[AppResult]
      ,[PbxCallId]
      ,[CallerNumber]
      ,[OutboundListId]
      ,[Priority]
      ,OC.[DisplayName]
      ,[PhoneNumberId]
      ,[ContactId]
      ,[ProjectId]
      ,[Skill]
      ,[PreferredAgentId]
      ,[Rank]
      ,[GroupNumber]
      ,[TimeMode]
      ,[TimeFrom]
      ,[TimeTo]
      ,[EnqueueingTime]
      ,[ScheduleTime]
      ,[RegionalTime]
      ,[DistributionTime]
      ,[AnswerTime]
      ,[EndTime]
      ,[AppResultTime]
      ,[PostCallEndTime]
      ,[Trial]
      ,[AgentId]
      ,[TeamName]
      ,[Predistributed]
      ,[Correlation]
      ,[LanguageId]
      ,[Proficiency]
      ,[OutboundListImportId]
      ,[RingDuration]
      ,[CallDuration]
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
      ,[CallResultDetailId]
      ,[ExtendedFields]
  FROM [iCC].[dbo].[OutboundCall] OC
  INNER JOIN [iCC].[dbo].[CallRecord] CL ON OC.OutboundCallId=CL.OutboundCallId
  INNER JOIN [ProNGX].[dbo].[FileRecord] FR ON  FR.FileRecordId=CL.RecordFileId 
  AND FR.Direction='O'
  --AND FR.Time BETWEEN OC.TimeUTC-0.1 AND OC.TimeUTC+0.1

  --AND FR.LocalNumber=WP.Number
  WHERE TimeUTC>GETDATE()-1 
  --AND ISNULL(CallDuration,0)=0
   ORDER BY TimeUTC
   /* Pro kontrolu navázat spojení pøes CallRecord */