
declare @OutboundCallId as uniqueidentifier = (select top 1 outboundcallid from iCC.dbo.OutboundCall where EndTime is null and AnswerTime is null order by NEWID ())--'9461D9A5-4A60-E911-841F-000C29EBD3F9'

select 
(select case when Activity = 'Scheduled' then 'OK' else Activity end from icc.dbo.OutboundList where OutboundListId = o.OutboundListId) as OL_Activity
,case when (select Active from iCC.dbo.OutboundListImport where OutboundListImportId = o.OutboundListImportId) = 0 then 'Import not Active' else 'OK' end OLI_Activity
,case when (CallPhase = 'Enqueue' and CallResult = 'Scheduled') then 'OK' else CONCAT (CallPhase,' / ',CallResult) end as Meta
,case when (select PbxOutDistribute from iCC.dbo.Project p where p.ProjectId = o.ProjectId ) = 1 then 'OK' else 'Project Blocked' end as ProjectActive
,(case when o.ScheduleTime < getdate() then 'OK' else cast (o.ScheduleTime as nvarchar (40)) end) as ScheduleTime
,case when (select ConfigurationValue from icc.dbo.Configuration where ConfigurationName = 'UseUnifiedQueue') = 'false' then '---' when (select CommId from icc.dbo.Queue where CommId = o.OutboundCallId) is not null then 'OK' else 'Not in Queue' end as InQueueExists
,case when Predistributed = 1 then 'Predistributed' else 'OK' end NoPredist
,case 
	when (Predistributed = 0 and (select top 1  AgentId from icc.dbo.Skill where AgentId in (select a.AgentId from icc.dbo.Agent as a 
												left join icc.dbo.Workplace as w on w.WorkplaceId = a.WorkplaceId
												where a.Activity = 'Ready' and w.State = 'Free' and w.Offer = 'None'
												and a.StatusId in (select StatusId from icc.dbo.Status where Deleted = 0 and activity = 'Ready'))
								and ProjectId = o.ProjectId and PbxOutKnowledge >= isnull(o.Skill,0) and PbxOutEnabled = 1 and PbxOutChannel = 1) is not null )
		then 'OK' 
	when (Predistributed = 1 and (select top 1  AgentId from icc.dbo.Skill where AgentId in (select a.AgentId from icc.dbo.Agent as a 
												left join icc.dbo.Workplace as w on w.WorkplaceId = a.WorkplaceId
												where a.Activity = 'Ready' and w.State = 'Free' and w.Offer = 'None'
												and a.StatusId in (select StatusId from icc.dbo.Status where Deleted = 0 and (CallPreDistribute = 1 or activity = 'Ready')))
								and ProjectId = o.ProjectId and PbxOutKnowledge >= isnull(o.Skill,0) and PbxOutEnabled = 1 and PbxOutChannel = 1) is not null )
		then 'OK' 
	else 'No agent available' end as AgentsAvailable
--,(select count(AgentId) from icc.dbo.Skill where AgentId in (select a.AgentId from icc.dbo.Agent as a 
--												left join icc.dbo.Workplace as w on w.WorkplaceId = a.WorkplaceId
--												where a.Activity = 'Ready' and w.State = 'Free' and w.Offer = 'None'
--												and a.StatusId in (select StatusId from icc.dbo.Status where Deleted = 0 and activity = 'Ready'))
--								and ProjectId = o.ProjectId and PbxOutKnowledge >= isnull(o.Skill,0) and PbxOutEnabled = 1 and PbxOutChannel = 1) as AgentsAvailable_Count

,case 
	when (select PredictorId from icc.dbo.OutboundList where OutboundListId = o.OutboundListId) is NULL then '---'
	when (Predistributed = 0 and ((select count(AgentId)  AgentId from icc.dbo.Skill where AgentId in (select a.AgentId from icc.dbo.Agent as a 
												left join icc.dbo.Workplace as w on w.WorkplaceId = a.WorkplaceId
												where a.Activity = 'Ready' and w.State = 'Free' and w.Offer = 'None'
												and a.StatusId in (select StatusId from icc.dbo.Status where Deleted = 0 and activity = 'Ready' and PredictiveDistribute = 1))
								and ProjectId = o.ProjectId and PbxOutKnowledge >= isnull(o.Skill,0) and PbxOutEnabled = 1 and PbxOutChannel = 1)
								- (select ConfigurationValue from iCC.dbo.Configuration where ConfigurationName = 'PredictiveAgentBuffer') >0 ))
		then 'OK'
	when (Predistributed = 0 and ((select count(AgentId)  AgentId from icc.dbo.Skill where AgentId in (select a.AgentId from icc.dbo.Agent as a 
												left join icc.dbo.Workplace as w on w.WorkplaceId = a.WorkplaceId
												where a.Activity = 'Ready' and w.State = 'Free' and w.Offer = 'None'
												and a.StatusId in (select StatusId from icc.dbo.Status where Deleted = 0 and (CallPreDistribute = 1 or activity = 'Ready') and PredictiveDistribute = 1))
								and ProjectId = o.ProjectId and PbxOutKnowledge >= isnull(o.Skill,0) and PbxOutEnabled = 1 and PbxOutChannel = 1)
								- (select ConfigurationValue from iCC.dbo.Configuration where ConfigurationName = 'PredictiveAgentBuffer') >0 ))
		then 'OK'
	else 'No predictive agent available' end as Predictive_AgentsAvailable
,case
	when (select PredictorId from icc.dbo.OutboundList where OutboundListId = o.OutboundListId) is NULL then '---'
	else cast((select count(AgentId) from icc.dbo.Skill where AgentId in (select a.AgentId from icc.dbo.Agent as a 
												left join icc.dbo.Workplace as w on w.WorkplaceId = a.WorkplaceId
												where a.Activity = 'Ready' and w.State = 'Free' and w.Offer = 'None'
												and a.StatusId in (select StatusId from icc.dbo.Status where Deleted = 0 and activity = 'Ready' and PredictiveDistribute = 1))
								and ProjectId = o.ProjectId and PbxOutKnowledge >= isnull(o.Skill,0) and PbxOutEnabled = 1 and PbxOutChannel = 1) - (select ConfigurationValue from iCC.dbo.Configuration where ConfigurationName = 'PredictiveAgentBuffer') as nvarchar (3)) end as Predictive_AgentsAvailable_Count


--dovolatelnost
--Status Activity = 'Ready'
--Status pro prediktiv

--DODELAT podminka na existujiciho agenta podle kap. pravidel - ze nema zadnou interakci
from iCC.dbo.OutboundCall as o 
where OutboundCallId = @OutboundCallId
