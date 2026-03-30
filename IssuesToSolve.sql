-- Tento dotaz hledá pøípady, které nemìly být podle zákazníka založeny
DECLARE @MeAgentId AS UniqueIdentifier
SET @MeAgentId = '004753cd-e23e-4da2-9b05-dc7127e5adb2'

SELECT IC.RegionalTime,PH.DisplayName,I.IssueId, I.NewTime, I.Activity,
 I.BodyHtml ,CallType, CallPhase,CallResult, CallerNumber, CallDuration, A.DisplayName

FROM Issue as I WITH(NOLOCK)
INNER JOIN InboundCall AS IC WITH(NOLOCK) ON I.IssueId=IC.IssueId
LEFT OUTER JOIN Agent AS A WITH(NOLOCK) ON I.AgentId=A.AgentId
LEFT OUTER JOIN Phase AS PH WITH(NOLOCK) ON I.PhaseId=PH.PhaseId
WHERE IC.RegionalTime>GETDATE()-60  AND (CallDuration=0 OR CallerNumber='0 ')
ORDER BY NewTime