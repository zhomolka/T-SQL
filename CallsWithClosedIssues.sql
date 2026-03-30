-- Tento dotaz hledá hovory, které byly párovány s uzavøenými pøípady
DECLARE @MeAgentId AS UniqueIdentifier
SET @MeAgentId = '004753cd-e23e-4da2-9b05-dc7127e5adb2'

SELECT I.CloseTime,IC.PilotTime,PH.DisplayName,I.IssueId, I.NewTime, I.Activity,
 I.BodyHtml ,CallType, CallPhase,CallResult, CallerNumber, CallDuration, A.DisplayName

FROM InboundCall AS IC WITH(NOLOCK)
INNER JOIN Issue as I  WITH(NOLOCK) ON I.IssueId=IC.IssueId
LEFT OUTER JOIN Agent AS A WITH(NOLOCK) ON I.AgentId=A.AgentId
LEFT OUTER JOIN Phase AS PH WITH(NOLOCK) ON I.PhaseId=PH.PhaseId
WHERE IC.PilotTime>GETDATE()-60  AND (I.CloseTime<IC.PilotTime)
ORDER BY NewTime