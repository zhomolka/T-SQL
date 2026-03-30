DECLARE @DisplayName AS VARCHAR(20) = 'HD Emaily'
DECLARE @Exist AS bit = IIF(EXISTS(SELECT Top 1 DataQueryId FROM iCC.dbo.DataQuery WHERE DisplayName = @DisplayName),1,0)
IF @Exist=0 
 BEGIN

INSERT [DataQuery] ( [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(@DisplayName,N'HD',N'Supervizor',N'TimeUtc DESC',N'SELECT 
M.MessageId, M.TimeUtc, M.SignatureValidity,
CASE 
WHEN M.SignatureValidity=0 THEN ''Email-I-signed-valid''
WHEN M.SignatureValidity>0 THEN ''Email-I-signed-invalid''
ELSE M.MessageType END AS MessageType, 
M.MessagePhase, M.Direction, M.RemoteAddress, M.Priority,
M.FromField, M.ToField, M.ToCcField, M.SubjectField, 
ISNULL(M.BodyText, M.BodyHtml) as BodyField,
M.ProjectId, M.GatewayId, M.AgentId, M.TeamName, M.LanguageId, P.DisplayName AS ProjectName, G.DisplayName AS GatewayName, A.DisplayName AS AgentName, L.DisplayName AS LanguageName,
ISNULL(ReceivedSentTime,DraftTime) AS MessageTime,
CAST(CASE WHEN MessageResult=''Active'' THEN 1 ELSE 0 END AS bit) AS IsActive,
CAST(CASE WHEN MessagePhase=''Draft'' OR MessagePhase=''Received'' THEN 1 ELSE 0 END AS bit) AS IsNew,
CAST(CASE WHEN (MessagePhase=''Read'' OR MessagePhase=''Received'') AND ReceivedSentTime<@Today THEN 1 ELSE 0 END AS bit) AS IsLate,
CAST(CASE WHEN EXISTS(SELECT * From Attachment WITH(NOLOCK) WHERE M.MessageId=Attachment.MessageId) THEN 1 ELSE 0 END AS bit) AS HasAttachment,
X.agreementid as Smlouva,
X.Name
FROM Message AS M WITH(NOLOCK) 
LEFT JOIN Project AS P WITH(NOLOCK) ON M.ProjectId=P.ProjectId
LEFT JOIN Gateway AS G WITH(NOLOCK) ON M.GatewayId=G.GatewayId
LEFT JOIN Agent AS A WITH(NOLOCK) ON M.AgentId=A.AgentId
LEFT JOIN Language AS L WITH(NOLOCK) ON M.LanguageId=L.LanguageId 
LEFT JOIN IssueExtra as X WITH(NOLOCK)ON M.IssueId=X.IssueId 
WHERE MessageType =''Email'' AND MessagePhase <> ''Canceled'' and @SubjectField=''##FullText##'' and @FromField=''##FullText##'' and @ToField=''##FullText##'' and @BodyField=''##FullText##''',0,NULL,NULL,NULL,0)

DECLARE @DataQueryId AS UniqueIdentifier = (SELECT Top 1 DataQueryId FROM iCC.dbo.DataQuery WHERE DisplayName = @DisplayName)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Výběr',N'Toggle',N'MessageId',NULL,NULL,N'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,30,1,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Typ',N'Image',N'MessageType',N'~/CustomImages/{0}.png',N'MessageId',N'~/Pages/Messages/DispFormPlus.aspx?Id={0}',NULL,N'MessageType',N'MessageType',NULL,0,25,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Směr',N'Image',N'Direction',N'~/CustomImages/Dir-{0}.png',N'MessageId',N'/ReactClient/Pages/MessageEditor.html?Id={0}',NULL,N'MessageDirection',N'Direction',NULL,0,25,7,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Příl.',N'Image',N'HasAttachment',N'~/CustomImages/Att-{0}.png',NULL,NULL,NULL,N'Bool',N'HasAttachment',NULL,0,25,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Čas',N'DateTimeFromTo',N'MessageTime',N'{0:dd.MM.yy HH.mm}',NULL,NULL,NULL,NULL,N'MessageTime',NULL,0,80,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Od',N'FullText',N'FromField',NULL,NULL,NULL,N'M.FromField',NULL,N'FromField',NULL,0,120,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Předmět',N'HyperFullText',N'SubjectField',NULL,N'MessageId',N'~/Pages/Messages/DispFormPlus.aspx?Id={0}',N'M.SubjectField',NULL,N'SubjectField',NULL,0,220,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Komu',N'FullText',N'ToField',NULL,NULL,NULL,N'M.ToField',NULL,N'ToField',NULL,0,100,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Stav',N'Select',N'MessagePhase',NULL,NULL,NULL,NULL,N'MessagePhase',N'MessagePhase',NULL,0,60,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Agent',N'Text',N'AgentName',NULL,NULL,NULL,N'AgentId',N'AgentName',N'AgentName',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Tým',N'Text',N'TeamName',NULL,NULL,NULL,NULL,NULL,N'TeamName',NULL,0,80,61,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Projekt',N'ForeignKey',N'ProjectName',NULL,NULL,NULL,N'ProjectId',N'ProjectName',N'ProjectName',NULL,0,100,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Text zprávy',N'FullText',N'BodyField',NULL,NULL,NULL,N'BodyText',NULL,N'BodyField',NULL,0,140,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Kopie',N'Text',N'ToCcField',NULL,NULL,NULL,NULL,NULL,N'ToCcField',NULL,0,80,85,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Nová zpráva',N'Bold',N'IsNew',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,91,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Stará 1D',N'Color',N'IsLate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,92,N'#FFE9D1',0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Aktivní',N'Color',N'IsActive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,93,N'#CCFADF',0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Priorita',N'Integer',N'Priority',NULL,NULL,NULL,NULL,NULL,N'Priority',NULL,0,25,100,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'TimeUtc',N'DateTimeUtc',N'TimeUtc',N'{0:dd.MM. HH:mm}',NULL,NULL,NULL,NULL,N'TimeUtc',NULL,0,60,103,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Adresa',N'Text',N'RemoteAddress',NULL,NULL,NULL,NULL,NULL,N'RemoteAddress',NULL,0,80,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Brána',N'ForeignKey',N'GatewayName',NULL,NULL,NULL,N'GatewayId',N'GatewayName',N'GatewayName',NULL,0,80,160,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Jazyk',N'ForeignKey',N'LanguageName',NULL,NULL,NULL,N'LanguageId',N'LanguageName',N'LanguageName',NULL,0,60,165,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Smlouva',N'Text',N'Smlouva',NULL,NULL,NULL,NULL,NULL,N'Smlouva',NULL,0,80,175,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Jméno',N'Text',N'Name',NULL,NULL,NULL,NULL,NULL,N'Name',NULL,0,80,185,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (@DataQueryId,N'Podpis',N'Select',N'SignatureValidity',NULL,NULL,NULL,NULL,N'SignatureValidity',N'SignatureValidity',NULL,0,40,190,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)

 END