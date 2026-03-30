DECLARE @TODAY AS Date
-- SET  @TODAY=GETDATE()-0.2
-- SET  @TODAY=CONVERT(datetime,'2016.01.13')
SET  @TODAY=CONVERT(datetime,'2016.02.01 09:30')
 

SELECT 
      [CallerNumber]
      ,CE.ResultData      
      ,[CallPhase]
      ,[CallResult]
      ,[Redirector]
	  ,[QueueLength]
      ,[PilotTime]      
      ,[AppResult]
	  ,IC.InboundCallId
      ,[PilotId]
      ,[Priority]
      ,[IvrScriptAId]
      ,[IvrScriptBId]
      ,[IvrScriptWId]
      ,[WaitingQueueId]
      ,[PreferredAgentId]
      ,[IvrResponseA]
      ,[IvrResponseB]
      ,[RegionalTime]
      ,[AnnouncementATime]
      ,[AnnouncementBTime]
      ,[AnnouncementWTime]
      ,[IvrScriptATime]
      ,[IvrScriptBTime]
      ,[IvrScriptWTime]
      ,[QueuePosition]
      ,[EnqueueingTime]
      ,[DistributionTime]
      ,[ExpectedDistributionTime]
      ,[AnswerTime]
      ,[EndTime]
      ,[AppResultTime]
      ,[PostCallEndTime]
      ,[TeamName]
      ,[Predistributed]
      ,[Correlation]
      ,[LanguageId]
      ,[Proficiency]
      ,[RoutingDuration]
      ,[QueueDuration]
      ,[RingDuration]
      ,[CallDuration]
      ,[HoldDuration]
      ,[PcpWrapDuration]
      ,[IssueId]
      ,[ChainingId]
      ,[ConditionLevel]
      ,[Mark]
  FROM [iCC].[dbo].[InboundCall] IC INNER JOIN CallEvent CE ON Ic.InboundCallId=CE.InboundCallId WHERE IC.TimeUtc>=@TODAY and CallerNumber='0956772000' and IC.InboundCallId='714CF42C-BEC8-E511-8DE9-0050568E4C40'
  ORDER BY IC.RegionalTime
GO


