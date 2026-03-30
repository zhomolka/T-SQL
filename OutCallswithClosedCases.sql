-- Tento dotaz hledá odchozí hovory, které byly párovány s uzavøenými pøípady
DECLARE @MeAgentId AS UniqueIdentifier
SET @MeAgentId = 'fc5dbd4d-8343-4b2e-ab56-be404d4118b7'

SELECT I.IssueId,I.CloseTime AS IssueCloseTime,OC.RegionalTime AS CallTime ,PH.DisplayName AS IssueStatus,I.NewTime AS IssueNewTime, I.Activity AS IssueActivity,
 CallType, CallPhase,CallResult, CallerNumber, CallDuration, A.DisplayName AS AgentName, CE.ReferenceData,CE.EventType, CE.TimeLocal AS CallEventTime,CE.*

FROM OutboundCall AS OC WITH(NOLOCK)
INNER JOIN Issue as I  WITH(NOLOCK) ON I.IssueId=OC.IssueId
LEFT OUTER JOIN Agent AS A WITH(NOLOCK) ON I.AgentId=A.AgentId
LEFT OUTER JOIN Phase AS PH WITH(NOLOCK) ON I.PhaseId=PH.PhaseId
LEFT OUTER JOIN CallEvent AS CE WITH(NOLOCK) ON OC.OutboundCallId=CE.OutboundCallId
WHERE OC.RegionalTime>GETDATE()-20  AND (I.CloseTime<OC.RegionalTime) AND EventType='IssueChange' AND I.AgentId=@MeAgentId
ORDER BY CallEventTime

-- operátor Pirochová: 'fc5dbd4d-8343-4b2e-ab56-be404d4118b7'