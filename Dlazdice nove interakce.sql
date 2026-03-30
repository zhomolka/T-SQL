/* Port_Nove: Dlazdice nove interakce */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
 VALUES(N'ab452193-8a50-4480-864a-09a94897fe44',N'Dlazdice nove interakce',NULL,N'Port_Nove',N'Rank',N'/*Outbound-New.png*/
SELECT 1 as [Rank]
	,''Call'' as Text
	,'''' as Number
	,'''' as BackgroundImage
	,''#333333'' as BackColor
	,''#ffffff'' as FrontColor
	,''fa fa-phone'' as Glyph
	,''OutCallEditor.html?Predist=true'' as Url

Union all
/*Email-New.png*/
SELECT 2 as [Rank]
	,''Mail'' as Text
	,'''' as Number
	,'''' as BackgroundImage
	,''#333333'' as BackColor
	,''#ffffff'' as FrontColor
	,''fa fa-envelope-o'' as Glyph
	,''MessageEditor.html?Plus=true&MsgType=Email'' as Url
		
Union all
/*Issue-New.png*/
SELECT 3 as [Rank]
	,''Issue'' as Text
	,'''' as Number
	,'''' as BackgroundImage
	,''#333333'' as BackColor
	,''#ffffff'' as FrontColor
	,''fa fa-folder-open-o'' as Glyph
	,''IssuEeditor.html'' as Url
		
Union all
/*SMS-New.png*/
SELECT 4 as [Rank]
	,''SMS'' as Text
	,'''' as Number
	,'''' as BackgroundImage
	,''#333333'' as BackColor
	,''#ffffff'' as FrontColor
	,''fa fa-mobile'' as Glyph
	,''MessageEditor.html?Plus=true&MsgType=SMS'' as Url
		
Union all
/*Note-New.png*/
SELECT 5 as [Rank]
	,''Note'' as Text
	,'''' as Number
	,'''' as BackgroundImage
	,''#333333'' as BackColor
	,''#ffffff'' as FrontColor
	,''fa fa-sticky-note-o'' as Glyph
	,''MessageEditor.html?Plus=true&MsgType=Note'' as Url
		
Union all
/*Task-New.pn*/
SELECT 6 as [Rank]
	,''Task'' as Text
	,'''' as Number
	,'''' as BackgroundImage
	,''#333333'' as BackColor
	,''#ffffff'' as FrontColor
	,''fa fa-calendar-o'' as Glyph
	,''MessageEditor.html?Plus=true&MsgType=Task'' as Url',0,NULL,NULL,NULL,0,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'2c3cdf09-449c-42cb-9dc7-96d2b032d496',N'ab452193-8a50-4480-864a-09a94897fe44',N'Rank',N'Integer',N'Rank',NULL,NULL,NULL,NULL,NULL,N'Rank',NULL,0,60,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'15bdda4a-0538-4516-bb21-e97ab73810eb',N'ab452193-8a50-4480-864a-09a94897fe44',N'Text',N'Text',N'Text',NULL,NULL,NULL,NULL,NULL,N'Text',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'3dd66227-56a9-4a58-a38a-bed4e91f5835',N'ab452193-8a50-4480-864a-09a94897fe44',N'Number',N'Text',N'Number',NULL,NULL,NULL,NULL,NULL,N'Number',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'2d7afe3d-74ff-4a7a-996a-78cfd52e228e',N'ab452193-8a50-4480-864a-09a94897fe44',N'BackColor',N'Text',N'BackColor',NULL,NULL,NULL,NULL,NULL,N'BackColor',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'432a7306-2210-4515-bead-034efd759a9c',N'ab452193-8a50-4480-864a-09a94897fe44',N'FrontColor',N'Text',N'FrontColor',NULL,NULL,NULL,NULL,NULL,N'FrontColor',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'3a717344-2b91-4c3f-98cc-2cb533b5314d',N'ab452193-8a50-4480-864a-09a94897fe44',N'Glyph',N'Text',N'Glyph',NULL,NULL,NULL,NULL,NULL,N'Glyph',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'804388e1-0865-4f5c-a5ad-303e7c576ee8',N'ab452193-8a50-4480-864a-09a94897fe44',N'Url',N'Text',N'Url',NULL,N'Url',N'http://FrontStage/ReactClient/Pages/{0}',NULL,NULL,N'Url',NULL,0,80,70,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'eb80aea1-317f-49c2-93af-7dcbc4a23ac5',N'ab452193-8a50-4480-864a-09a94897fe44',N'BackgroundImage',N'Text',N'BackgroundImage',NULL,NULL,NULL,NULL,NULL,N'BackgroundImage',NULL,0,300,80,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)

