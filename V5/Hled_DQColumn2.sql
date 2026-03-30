/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) 
      DQ.[DataQueryId]
	  ,DQ.[DisplayName] AS QueryName
	  ,DQ.QueryGroup
      ,DQC.[DisplayName]
      ,[Model]
      ,[TargetColumn]
      ,[TargetFormat]
      ,[UrlColumn]
      ,[UrlFormat]
      ,[GuidColumn]
      ,[Convertor]
      ,[SortExpression]
      ,[SortExpressionDesc]
      ,[NoFilter]
      ,[Width]
      ,[Rank]
      ,[Color]
      ,[SqlCmd]
      ,[Css]
      ,[ToolTip]
      ,[LiteralGroup]
      ,[GlyphColumn]
      ,[GlyphFormat]
      ,[GdprSensitivity]
      ,[DisplayGlyph]
  FROM [dbo].[DataQueryColumn] DQC
  LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
  WHERE DQ.QueryGroup='ServiceAPP' AND DQ.Deleted=0
  AND Model = 'Image' 
  AND TargetColumn  = 'HasAttachment'   
  --AND GlyphColumn IS NULL
  --AND URLFormat LIKE '%/RC%'
  --AND UrlColumn IN ('MessageId','InboundCallId','OutboundCallId')
/*
   AND URLFormat IS NOT NULL
  AND URLFormat LIKE '%/RC%'
  AND UrlColumn IN ('MessageId','InboundCallId','OutboundCallId')
  */