
select
I.IssueId,i.TopicId,i.SubTopicId, I.NewTime, I.Activity, I.Priority, 
P.DisplayName as ProjectName, T.DisplayName as TopicName, ST.DisplayName as SubTopicName, PH.DisplayName as PhaseName, I.PhaseId,

--(select top 1 displayName from iCC.dbo.Agent where agentId=ie.AutorId) as AutorName,
AUT.displayName  as AutorName,

a.DisplayName as Resitel

--(SELECT TOP 1 IE2A.DisplayName FROM iCC.dbo.IssueEvent AS IE2 LEFT JOIN iCC.dbo.Agent AS IE2A ON IE2.AgentId=IE2A.AgentId WHERE I.IssueId=IE2.IssueId AND EventType='ClosedIssue' ORDER BY IE2.TimeUtc DESC) as ClosedAgentName
,IE2A.DisplayName as ClosedAgentName

,ie.Predat,
CAST(CASE WHEN I.PhaseID='B750378B-67F3-4434-98EB-CCA1A7E6F174' THEN 1 ELSE 0 END AS bit) AS Escalated
,CAST(CASE WHEN I.PhaseID='78B2953D-D870-4F78-AB52-3DE00CF59B40' THEN 1 ELSE 0 END AS bit) AS Doplnit
,CAST(CASE WHEN I.PhaseID='BFC21976-8923-41E9-BAA7-43298621531E' THEN 1 ELSE 0 END AS bit) AS Returned

--,CAST(CASE WHEN exists (select top 1 * from icc.dbo.message m where MessagePhase='Received' and MessageResult='Active' and m.IssueId=i.IssueId)THEN 1 ELSE 0 END AS bit) AS NewMessage
,CAST(CASE WHEN ME.Issueid IS NOT NULL THEN 1 ELSE 0 END AS bit) AS NewMessage

,ie.[PreferredAgent]
,ie.[Poznamka]
,ie.CisloSmlouvy

FROM iCC.dbo.Issue as I

LEFT JOIN iCC.dbo.Topic AS T ON I.TopicId=T.TopicId
left join iCC.dbo.issueextra as ie on ie.issueid = i.IssueId
LEFT JOIN iCC.dbo.SubTopic AS ST ON I.SubTopicId =ST.SubTopicId
LEFT JOIN iCC.dbo.Phase AS PH ON I.PhaseId = PH.PhaseId
LEFT JOIN iCC.dbo.Project AS P ON I.ProjectId=P.ProjectId
LEFT JOIN iCC.dbo.Contact AS C ON I.ContactId=C.ContactId 
LEFT JOIN ICC.dbo.Agent as A on a.agentid=i.AgentId

LEFT JOIN ICC.dbo.Agent as AUT on AUT.agentid=ie.AutorId
LEFT JOIN iCC.dbo.IssueEvent AS IE2 ON I.IssueId=IE2.IssueId AND IE2.EventType='ClosedIssue'
LEFT JOIN iCC.dbo.Agent AS IE2A ON IE2.AgentId=IE2A.AgentId 
LEFT JOIN (select DISTINCT IssueId from icc.dbo.message m 
where MessagePhase='Received' and MessageResult='Active' AND IssueId IS NOT NULL) AS ME ON I.IssueId=ME.IssueId


WHERE @MeAgentId<>'42d6f0e7-58ed-45aa-9eb5-51216d6aaeeb' AND
I.phaseid in ('FC3E61D6-B07E-49D5-8547-CC1B30DA3A48','CFEF356E-9658-46F2-B739-4956B72809C4') 
and (
i.SubTopicId in (select referenceid from iCC.dbo.Permission as p left join iCC.dbo.Scope b on p.ScopeId=b.ScopeId
where p.roleid='0460c8f3-b7bc-41f1-ba28-e422da73f2f4' and (p.TeamMask = @MeTeamName or p.AgentId = @MeAgentId or (p.TeamMask IS NULL AND p.AgentId IS NULL)
))
or i.AgentId = @MeAgentid
)
and @Poznamka='##FullText##'and @CisloSmlouvy='##FullText##' 
/**/