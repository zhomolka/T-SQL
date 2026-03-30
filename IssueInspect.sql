/*
DECLARE @p0 AS UniqueIdentifier='269621dd-87c1-ed11-811e-00505693033a'
SELECT TOP (1) [t0].[InboundCallId], [t0].[TimeUtc], [t0].[CallType], [t0].[CallPhase], [t0].[CallResult], [t0].[AppResult], [t0].[PbxCallId], [t0].[CallerNumber], [t0].[PilotId], [t0].[Priority], [t0].[Redirector], [t0].[PhoneNumberId], [t0].[ContactId], [t0].[ProjectId], [t0].[Skill], [t0].[AnnouncementAId], [t0].[AnnouncementBId], [t0].[AnnouncementWId], [t0].[IvrScriptAId], [t0].[IvrScriptBId], [t0].[IvrScriptWId], [t0].[WaitingQueueId], [t0].[PreferredAgentId], [t0].[IvrResponseA], [t0].[IvrResponseB], [t0].[IvrResponseW], [t0].[PilotTime], [t0].[RegionalTime], [t0].[AnnouncementATime], [t0].[AnnouncementBTime], [t0].[AnnouncementWTime], [t0].[IvrScriptATime], [t0].[IvrScriptBTime], [t0].[IvrScriptWTime], [t0].[QueuePosition], [t0].[QueueLength], [t0].[EnqueueingTime], [t0].[DistributionTime], [t0].[ExpectedDistributionTime], [t0].[AnswerTime], [t0].[EndTime], [t0].[AppResultTime], [t0].[PostCallEndTime], [t0].[AgentId], [t0].[TeamName], [t0].[Predistributed], [t0].[WorkplaceId], [t0].[Correlation], [t0].[LanguageId], [t0].[Proficiency], [t0].[RoutingDuration], [t0].[QueueDuration], [t0].[RingDuration], [t0].[CallDuration], [t0].[HoldDuration], [t0].[PcpWrapDuration], [t0].[IssueId], [t0].[ChainingId], [t0].[ConditionLevel], [t0].[Mark], [t0].[TransferredTo], [t0].[CallKey], [t0].[GdprArchived], [t0].[GdprExpired], [t0].[GdprSensitivity], [t0].[GdprInherit], [t0].[ChainedInbound], [t0].[ChainedOutbound], [t0].[IvrFeedback], [t0].[ArchiveAfter], [t0].[ExpireAfter], [t0].[ObliviateAfter], [t0].[GdprObliviated], [t0].[PostCallProcess], [t0].[CallResultDetailId], [t0].[Rating], [t1].[ProjectGroupName]
FROM [dbo].[InboundCall] AS [t0]
LEFT OUTER JOIN [dbo].[Project] AS [t1] ON [t1].[ProjectId] = [t0].[ProjectId]
WHERE [t0].[InboundCallId] = @p0
GO
*/
-- Toto je asi nejdùležitìjší:
DECLARE @p0 AS NVarChar(10)='PbxIn'
DECLARE @p1 AS NVarChar(10)='Voice'
DECLARE @ProjectId AS UniqueIdentifier='084af56d-c6af-4101-b8c5-364c1bdd2ae9'
DECLARE @p3 AS NVarChar(10)='Fotopráce'
DECLARE @p4 AS UniqueIdentifier='d48076ec-e0c2-4b70-b0b4-917e69af1d6d'
DECLARE @p5 AS NVarChar(10)=Null
DECLARE @p6 AS UniqueIdentifier='17c43403-2dfc-4f54-aa4b-aea037c22052'
SELECT [t0].[TimeMode], [t0].[TimeFrom], [t0].[TimeTo]
FROM [dbo].[IssueCondition] AS [t0]
WHERE 1=1
 AND NOT ([t0].[BlockIssueLookup] = 1) 
 AND (([t0].[Channel] IS NULL) OR ([t0].[Channel] = @p0) OR ([t0].[Channel] = @p1)) 
 AND (([t0].[ProjectId] IS NULL) OR ([t0].[ProjectId] = @ProjectId))
 AND (([t0].[ProjectGroupMask] IS NULL) OR (@p3 LIKE [t0].[ProjectGroupMask]))
 AND (([t0].[AgentId] IS NULL) OR ([t0].[AgentId] = @p4))
 AND (([t0].[TeamMask] IS NULL) OR (@p5 LIKE [t0].[TeamMask])) -- Toto blokovalo vytváøení pøípadù
 AND (([t0].[LanguageId] IS NULL) OR ([t0].[LanguageId] = @p6))

/*
SELECT [t0].[TimeMode], [t0].[TimeFrom], [t0].[TimeTo]
FROM [dbo].[IssueCondition] AS [t0] */