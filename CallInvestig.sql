declare @cid as uniqueidentifier
select @cid = (select Top 1 InboundCallId FROM InboundCall WHERE CallerNumber = '0271004247' order by TimeUtc desc)
declare @srv as uniqueidentifier
select @srv = (Select Top 1 ScenarioResultId from ScenarioResult where InboundCallId = @cid)
declare @iid as uniqueidentifier = (SELECT IssueId FROM InboundCall WHERE InboundCallId=@cid)
select 
 PilotTime
, CallType
, CallPhase
, CallResult
, CallerNumber
, P.DisplayName AS ProjectName
, L.Culture
, Redirector
, PL.Number
, IVR.DisplayName
,InboundCallId
from InboundCall AS I
LEFT JOIN Project AS P ON P.ProjectId = I.ProjectId
LEFT JOIN Language AS L ON L.LanguageId = I.LanguageId
LEFT JOIN Pilot AS PL ON PL.PilotId = I.PilotId
LEFT JOIN IvrScript AS IVR ON IVR.IvrScriptId = I.IvrScriptAId
where InboundCallId=@cid
--where CallerNumber = '0271004246' order by PilotTime desc

SELECT * FROM Issue WHERE IssueId = @iid

SELECT TOP 1000 CE.TimeLocal, CE.EventType, A.DisplayName, W.DisplayName, P.DisplayName, CE.ReferenceData, C.CallerNumber, CE.ResultData
  FROM CallEvent as CE
  left join InboundCall as C on C.InboundCallId = CE.InboundCallId
  left join Workplace as W on W.WorkplaceId= CE.WorkplaceId
  left join Project as P on P.ProjectId= CE.ProjectId
  left join Agent as A on A.AgentId = CE.AgentId
  where (CE.InboundCallId=@cid)
  order by CE.TimeUtc
  
 
  --SELECT [iCC].[dbo].[GetScenarioResultFullText] (@srv)
  select * from ScenarioResultValue where ScenarioResultId = @srv
