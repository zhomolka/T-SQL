DECLARE @Now AS datetime=GETDATE()
DECLARE @Count AS Int = 1

  WHILE @Count > 0
     BEGIN		
			select @now as TimeStamp, 
				SUM( CASE WHEN CallResult='Scheduled' AND CallPhase='New' THEN 1 ELSE 0 END) as ScheduledNew,
				SUM( CASE WHEN CallResult='Scheduled' AND CallPhase='Enqueue' THEN 1 ELSE 0 END) as ScheduledEnqueue,
				SUM( CASE WHEN 'Active'=CallResult AND CallPhase='PredictiveDial' THEN 1 ELSE 0 END) as ActivePredictiveDial,
				SUM( CASE WHEN 'Active'=CallResult AND CallPhase='Answered' THEN 1 ELSE 0 END) as ActiveAnswered,
				SUM( CASE WHEN 'Active'=CallResult AND CallPhase='AgentRing' THEN 1 ELSE 0 END) as ActiveAgentRing,
				SUM( CASE WHEN 'Active'=CallResult AND CallPhase='AgentTalk' THEN 1 ELSE 0 END) as ActiveAgentTalk,
				SUM( CASE WHEN 'Lost'=CallResult AND CallPhase='PredictiveDial' THEN 1 ELSE 0 END) as LostPredictiveDial,
				SUM( CASE WHEN 'Lost'=CallResult AND CallPhase='Answered' THEN 1 ELSE 0 END) as LostAnswered,
				SUM( CASE CallResult WHEN 'NoResult' THEN 1 ELSE 0 END) as NoResult,
				SUM( CASE WHEN  CallResult='Failed' OR CallResult='TalkError' THEN 1 ELSE 0 END)   as Failed,
				SUM( CASE CallResult WHEN 'Busy' THEN 1 ELSE 0 END) as Busy,
				SUM( CASE CallResult WHEN 'NoAnswer' THEN 1 ELSE 0 END) as NoAnswer,
				SUM( CASE CallResult WHEN 'Canceled' THEN 1 ELSE 0 END) as Canceled,
				SUM( CASE CallResult WHEN 'Completed' THEN 1 ELSE 0 END) as Completed
			from icc.dbo.OutboundListImport OLI WITH(NOLOCK) 
			  INNER JOIN icc.dbo.OutboundCall O WITH(NOLOCK) ON OLI.OutboundListImportId=O.OutboundListImportId 
			  WHERE OLi.Deleted = 0 and OLi.Active = 1
			--where o.OutboundListImportId in (select OutboundListImportId from icc.dbo.OutboundListImport as i where i.Deleted = 0 and i.Active = 1)
			SET @Count=@Count-1
   END