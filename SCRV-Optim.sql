
SELECT 
C.InboundCallId, C.TimeUtc, C.CallPhase, C.CallResult, C.CallerNumber, 
C.ProjectId, C.LanguageId, C.AgentId, C.WorkplaceId,
C.CallDuration, C.PilotTime, C.ChainingId,
TransferredTo as TransferredTo,  cnt.ContactId, 
P.DisplayName AS ProjectName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName, W.DisplayName AS WorkplaceName,
CAST(CASE WHEN CallResult='Active' THEN 1 ELSE 0 END AS bit) AS IsActive,
CAST(CASE WHEN CallResult='Lost' THEN 1 ELSE 0 END AS bit) AS IsLost,
--icc.dbo.GetTargetColumnText(sr.ScenarioResultId,'qual_code') as QC,
--icc.dbo.GetTargetColumnText(sr.ScenarioResultId,'qual_subcode') as QSC,
--icc.dbo.GetTargetColumnText(sr.ScenarioResultId,'qual_note') as QNote,
SRV1.ResultText as QC,
SRV2.ResultText as QSC,
SRV3.ResultText as QNote,


--pcnt.Description as ParentCustomer,
cnt.Description as ParentCustomer,
--concat(cnt.FirstName,' ',cnt.LastName) as ContactName
cnt.FirstName as ContactName
,FS_custom.dbo.GetTargetColumnTextLt2(sr2.ScenarioResultId,'offer_topic%') collate Czech_CI_AS as offer_topic
FROM InboundCall AS C WITH (NOLOCK)
--left join PhoneNumber as pn with (nolock) on pn.PhoneNumberId=c.PhoneNumberId
left join Contact as cnt with (nolock) on cnt.ContactId=c.ContactId
--left join Contact as pcnt with (nolock) on pcnt.ContactId=cnt.ParentContactId
LEFT JOIN Project AS P WITH (NOLOCK) ON C.ProjectId=P.ProjectId
LEFT JOIN Agent AS A WITH (NOLOCK) ON C.AgentId=A.AgentId
LEFT JOIN Language AS L WITH (NOLOCK) ON C.LanguageId=L.LanguageId
LEFT JOIN Workplace AS W WITH (NOLOCK) ON C.WorkplaceId=W.WorkplaceId
left join ScenarioResult as sr WITH (NOLOCK) on c.InboundCallId = sr.InboundCallId and sr.ScenarioId = '94d8c53e-7ee7-4925-b49e-08ebd2025bc7'
left join ScenarioResult as sr2  WITH (NOLOCK) on c.InboundCallId = sr2.InboundCallId and sr2.ScenarioId = '2ea67bbb-a518-4956-9413-ef5060aa6ef3' 
left join ScenarioResultValue SRV1 WITH (NOLOCK) on SRV1.ScenarioResultId=sr.ScenarioResultId AND SRV1.TargetColumn='qual_code' and SRV1.ResultText is not null
left join ScenarioResultValue SRV2 WITH (NOLOCK) on SRV2.ScenarioResultId=sr.ScenarioResultId AND SRV2.TargetColumn='qual_subcode' and SRV2.ResultText is not null
left join ScenarioResultValue SRV3 WITH (NOLOCK) on SRV3.ScenarioResultId=sr.ScenarioResultId AND SRV3.TargetColumn='qual_note' and SRV3.ResultText is not null

WHERE C.AgentId = @MeAgentId 
