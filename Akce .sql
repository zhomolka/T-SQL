/* Agenti: SPAM CeWe  */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'79e3348d-1aaf-44e4-b0ce-7837a693e802',N'SPAM CeWe ',NULL,N'Agenti',N'Emails',N'SELECT Convert(nvarchar(10),IIF(Deleted=0,1,0)) as Stav, PhoneNumberId AS RecordId ,Emails
  FROM [iCC].[dbo].[PhoneNumber] WHERE DisplayName=''Spam''',0,NULL,NULL,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'89fcbe73-da28-4f31-9c81-3e1a983e4820',N'79e3348d-1aaf-44e4-b0ce-7837a693e802',N'E-Mail',N'Select',N'Emails',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,200,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat])
 VALUES (N'b8ec3dcb-c0b5-4a6a-a7d7-357090a4b966',N'79e3348d-1aaf-44e4-b0ce-7837a693e802',N'Smazat',N'ImageScript',N'Stav',N'~/CustomImages/{0}.png',N'RecordId',NULL,NULL,NULL,N'Stav',NULL,0,80,20,NULL,0,N'exec fs_custom.dbo.DelBlackItem @Id ',NULL,NULL,NULL,NULL,NULL)

