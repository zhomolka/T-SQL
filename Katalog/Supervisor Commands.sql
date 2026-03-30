/* Sup_Portal: Supervisor Commands */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
 VALUES(N'e99a0890-1e80-4c3f-b007-a50df3438736',N'Supervisor Commands',NULL,N'Sup_Portal',N'Description',N'SELECT CommandId AS RecordId
             , ''1'' AS ProvedAkci
             ,Description
        FROM FS_CUSTOM.dbo.Commands 
WHERE GroupName=''SUPER''
     ',0,NULL,NULL,NULL,0,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity], [DisplayGlyph])
 VALUES (N'86350c72-2539-4bc1-83b9-25f2e0767a26',N'e99a0890-1e80-4c3f-b007-a50df3438736',N'Perform',N'ImageScript',N'ProvedAkci',N'~/CustomImages/{0}.png',N'RecordId',NULL,NULL,NULL,N'ProvedAkci',NULL,0,70,3,NULL,0,N'exec FS_CUSTOM.dbo.RunScript @Id',NULL,NULL,NULL,NULL,NULL, NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity], [DisplayGlyph])
 VALUES (N'2f3df0e6-6a40-4d66-97e7-2f6b54d11ad0',N'e99a0890-1e80-4c3f-b007-a50df3438736',N'Description',N'Text',N'Description',NULL,NULL,NULL,NULL,NULL,N'Description',NULL,0,600,340,NULL,0,NULL,NULL,500,NULL,NULL,NULL, NULL, NULL)

