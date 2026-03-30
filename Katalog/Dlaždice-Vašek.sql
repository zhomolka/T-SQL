-- CONVERSION INTO CORRECT CODEPAGE WAS PERFORMED
-------------------------------------------------
USE iCC
  /* Port_WB: WB_CC 1. radek */
DECLARE @DataQueryId AS UNIQUEIDENTIFIER = '84099442-da04-46b3-afe1-618ba8be996c'
DECLARE @DisplayName AS VARCHAR(150) = 'WB_CC 1. radek'
DECLARE @QueryGroup AS VARCHAR(50) = 'Wallboard'
IF EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DataQueryId=@DataQueryId)
  SET @DataQueryId=NewId() -- Musím pozadat o nove iD
IF NOT EXISTS(SELECT Top 1 DataQueryId FROM .dbo.DataQuery WHERE DisplayName = @DisplayName AND QueryGroup=@QueryGroup AND Deleted=0)
 BEGIN
  INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
  VALUES(@DataQueryId,@DisplayName,N'WB_CC 1. radek',@QueryGroup,N'Rank',N'SELECT * FROM [FS_custom].[dbo].[WB_Tile_1_new] (@Now)',0,NULL,NULL,NULL,0,0)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
    VALUES (@DataQueryId,N'Rank',N'Integer',N'Rank',NULL,NULL,NULL,NULL,NULL,N'Rank',NULL,0,60,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
    VALUES (@DataQueryId,N'Text',N'Text',N'Text',NULL,NULL,NULL,NULL,NULL,N'Text',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
    VALUES (@DataQueryId,N'Number',N'Text',N'Number',NULL,NULL,NULL,NULL,NULL,N'Number',NULL,0,60,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
    VALUES (@DataQueryId,N'BackColor',N'Text',N'BackColor',NULL,NULL,NULL,NULL,NULL,N'BackColor',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
    VALUES (@DataQueryId,N'FrontColor',N'Text',N'FrontColor',NULL,NULL,NULL,NULL,NULL,N'FrontColor',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
  INSERT [DataQueryColumn] ( [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
    VALUES (@DataQueryId,N'Glyph',N'Text',N'Glyph',NULL,NULL,NULL,NULL,NULL,N'Glyph',NULL,0,80,60,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
  
 END
GO
