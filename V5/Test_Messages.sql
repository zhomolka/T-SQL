DECLARE @today AS Datetime=CONVERT(Date,GETDATE())
DECLARE @MeAgentId AS UNIQUEIDENTIFIER='75803fd5-e533-4e35-88b1-da7c5c1bca3d'
SELECT
M.MessageId, M.TimeUtc, M.MessagePhase, M.Direction,M.MessageResult,
M.FromField, M.ToField, M.RemoteAddress, M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,
M.ProjectId, M.EndTime, M.AgentId, M.TeamName, P.DisplayName AS ProjectName, G.DisplayName AS GatewayName, A.DisplayName AS AgentName, 
ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,
CAST(CASE WHEN MessageResult=0 and MessagePhase <> 9 and cast(ReceivedSentTime as date)=cast(@Today as date)THEN 1 ELSE 0 END AS bit) AS IsActive,
CAST(CASE WHEN MessagePhase in (1,7) THEN 1 ELSE 0 END AS bit) AS IsNew,
CAST(CASE WHEN MessagePhase in (8,9) THEN 1 ELSE 0 END AS bit) AS IsWaiting,
CAST(CASE WHEN MessageResult=0 and MessagePhase <> 9 and cast(ReceivedSentTime as date)<cast(@Today as date) THEN 1 ELSE 0 END AS bit) AS IsLate,
  CAST(CASE WHEN isnull(HasAtt,0) >0 THEN 1 ELSE 0 END AS bit) AS HasAttachment,
(K.FirstName+' '+K.LastName) as Contact,m.ContactId,
Ph.DisplayName as IssuePhase, I.DisplayName as IssueNumber, M.IssueId
FROM Message AS M WITH (NOLOCK)
LEFT JOIN Project AS P  WITH (NOLOCK) ON M.ProjectId=P.ProjectId
LEFT JOIN Gateway AS G  WITH (NOLOCK) ON M.GatewayId=G.GatewayId
LEFT JOIN Agent AS A  WITH (NOLOCK) ON M.AgentId=A.AgentId
LEFT JOIN Contact AS K WITH(NOLOCK) ON m.ContactId=K.ContactId
left join Issue as I with(nolock) on i.issueid = m.issueid
left join phase as PH with(nolock) on ph.PhaseId = i.PhaseId
INNER JOIN Skill S with(nolock) ON  S.AgentId = @MeAgentId AND P.ProjectId= S.ProjectId and EmailEnabled = 1
left join (SELECT MessageId, count(*) as HasAtt From Attachment a with(nolock) group by MessageId) as Att on M.MessageId=ATt.MessageId

WHERE MessageType = 1 /*and P.ProjectId IN (SELECT ProjectId from Skill S with (nolock) where AgentId = @MeAgentId and EmailEnabled = 1)*/ 
--@SubjectField='##FullText##' and @FromField='##FullText##' and @BodyField='##FullText##'
and ((select workplaceid from Agent where AgentId = @MeAgentId ) is not null)
and M.Messageid='4272be5f-7759-ef11-991a-000d3ab84c63'
