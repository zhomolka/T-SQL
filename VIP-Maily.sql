DECLARE @from AS datetime
DECLARE @to AS datetime
DECLARE @today AS date
--SET @from=convert(datetime, '2015.11.01')
--SET @to=convert(datetime, '2015.11.30')

SET @from=GETDATE()-10
SET @to=GETDATE()
SET @today=GETDATE()

SELECT  M.MessageId, M.TimeUtc, M.MessageType, M.MessagePhase, M.Direction,    
M.RemoteAddress as FromField, FS_Custom.dbo.Return_Mail(M.ToField) AS ToField, FS_Custom.dbo.Return_Mail(M.ToCcField) AS ToCcField, M.SubjectField, ISNULL(M.BodyText, M.BodyHtml) as BodyField,  
M.ProjectId, M.GatewayId, M.AgentId, M.TeamName, M.LanguageId, M.IssueId,  
P.DisplayName AS ProjectName, G.DisplayName AS GatewayName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName,  
ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,  
CAST(CASE WHEN MessageResult='Active' THEN 1 ELSE 0 END AS bit) AS IsActive,  
CAST(CASE WHEN MessagePhase='Draft' OR MessagePhase='Received' THEN 1 ELSE 0 END AS bit) AS IsNew,  
CAST(CASE WHEN (MessagePhase='Read' OR MessagePhase='Received') AND ReceivedSentTime<@Today THEN 1 ELSE 0 END AS bit) AS IsLate,  
CAST(CASE WHEN EXISTS(SELECT * From Attachment WHERE M.MessageId=Attachment.MessageId) THEN 1 ELSE 0 END AS bit) AS HasAttachment  
FROM Message AS M   LEFT JOIN Project AS P ON M.ProjectId=P.ProjectId  LEFT JOIN Gateway AS G ON M.GatewayId=G.GatewayId  
LEFT JOIN Agent AS A ON M.AgentId=A.AgentId  LEFT JOIN Language AS L ON M.LanguageId=L.LanguageId  
LEFT JOIN ScenarioResult AS SR ON SR.MessageId=M.MessageId
WHERE (MessageType ='Email') AND MessagePhase IN ('Read','Active','Draft') AND (P.ProjectTypeName = 'VIP')

SELECT * FROM Message WHERE SubjectField='[SUSPECTED SPAM] zásilka è.05891190209'