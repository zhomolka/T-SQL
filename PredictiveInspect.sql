  DECLARE @OutboundListId UniqueIdentifier ='7ca7ae75-f6c6-4f01-b68e-06706f72cdcb'

select 
				SUM( CASE WHEN CallResult='Scheduled' AND CallPhase='New' THEN 1 ELSE 0 END) as ScheduledNew,
				SUM( CASE WHEN 'Active'=CallResult AND CallPhase='PredictiveDial' THEN 1 ELSE 0 END) as ActivePredictiveDial,
				SUM( CASE WHEN 'Active'=CallResult AND CallPhase='Answered' THEN 1 ELSE 0 END) as ActiveAnswered,
				SUM( CASE WHEN 'Active'=CallResult AND CallPhase='AgentRing' THEN 1 ELSE 0 END) as ActiveAgentRing
			from icc.dbo.OutboundCall as o WITH(NOLOCK) 
			where OutboundListId=@OutboundListId and (CallResult='Scheduled' or CallResult='Active')

/*zobrazeni volnych agentu v zavislosti na nastavenem bufferu*/
		case when ((SUM( CASE WHEN A.Activity='Ready' and s.PredictiveDistribute=1 AND W.State='Free' AND W.Offer='None' THEN 1 ELSE 0 END)) is null)
				then 0--pokud nejsou prihlaseni agenti, bude 0 volnych
			when (SUM( CASE WHEN A.Activity='Ready' and s.PredictiveDistribute=1 AND W.State='Free' AND W.Offer='None' THEN 1 ELSE 0 END)) >(@PredictiveAgentBuffer)
				then ((SUM( CASE WHEN A.Activity='Ready' and s.PredictiveDistribute=1 AND W.State='Free' AND W.Offer='None' THEN 1 ELSE 0 END)) - (@PredictiveAgentBuffer))--pokud je volnych agentu vic, nez je nastaven buffer, ukaze se jejich zbytek po odecteni bufferu
			else 0 --pokud bude agentu mene nebo stejne jako buffer, bude se zobrazovat jako 0
		end as ReadyFree

			from icc.dbo.Agent A WITH(NOLOCK)
		inner join icc.dbo.Workplace W WITH(NOLOCK) on A.WorkplaceId=W.WorkplaceId
		left join icc.dbo.InboundCall as i with (nolock) on i.AgentId = a.AgentId and i.CallResult = 'Active' 
		left join icc.dbo.OutboundCall as o with (nolock) on o.AgentId = a.AgentId and o.CallResult = 'Active' 
		left join icc.dbo.Status s with (nolock) on s.StatusId=a.StatusId
		where A.Deleted=0 AND A.Template=0 AND A.Activity<>'Logoff'
		and a.StatusId in (select StatusId from icc.dbo.Status with (nolock) where   Deleted = 0)
		and a.AgentId in (select x.agentid from @OLPredictiveAgents as x)

