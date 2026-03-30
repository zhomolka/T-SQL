DECLARE @TODAY AS Date
-- SET  @TODAY=GETDATE()-0.2
-- SET  @TODAY=CONVERT(datetime,'2016.01.13')
SET  @TODAY=CONVERT(Date,GETDATE())
 

SELECT 
      [CallerNumber]
      ,CE.ResultData      
      ,[CallPhase]
      ,[CallResult]
      ,[Redirector]
      ,[PilotTime]      
      ,[AppResult]
      ,[PilotId]
      ,[Priority]
      ,[IvrScriptAId]
      ,[IvrScriptBId]
      ,[IvrScriptWId]
      ,[WaitingQueueId]
      ,[PreferredAgentId]
      ,[IvrResponseA]
      ,[IvrResponseB]
      ,[IvrRepsonseW]
      ,[RegionalTime]
      ,[AnnouncementATime]
      ,[AnnouncementBTime]
      ,[AnnouncementWTime]
      ,[IvrScriptATime]
      ,[IvrScriptBTime]
      ,[IvrScriptWTime]
      ,[QueuePosition]
      ,[QueueLength]
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
  FROM [iCC].[dbo].[InboundCall] IC INNER JOIN CallEvent CE ON Ic.InboundCallId=CE.InboundCallId WHERE IC.TimeUtc>=@TODAY AND Redirector='577'
  ORDER BY IC.RegionalTime
GO


