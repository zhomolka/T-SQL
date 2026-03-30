/* Admin: Admin Recordingless Calls */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
 VALUES(N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'Admin Recordingless Calls',N'Recordingless Calls Today',N'Admin',N'CallTime DESC',N'SELECT IIF(VCR.VoiceRecordId IS NULL,''NO'',''YES'') ExRecord
,Direction 
,Redirector
,CallerNumber
,Number
,WorkPlaceName
,CallTime
,CallId
,StartTimeUTC
FROM (
SELECT * FROM (
SELECT TOP 1000
      ''O'' AS Directionx
	  , NULL AS Redirector
	  , CallerNumber
	  , WP.Number
	  , WP.DisplayName AS WorkPlaceName
      , OC.[OutboundCallId] AS CallId
      ,DistributionTime AS CallTime
	  ,TimeUTC
	  ,CallDuration
  FROM .[dbo].[OutboundCall] OC WITH (NOLOCK)
    LEFT JOIN .[dbo].[CallRecord] CR WITH (NOLOCK) ON CR.OutboundCallId=OC.OutboundCallId
    LEFT JOIN .[dbo].[Workplace] WP ON WP.WorkplaceId=OC.WorkplaceId
  WHERE DistributionTime>@Today AND DistributionTime<DATEADD(Hour,-1,@Now)  AND CallDuration>1
  AND CR.OutboundCallId IS NULL 
    AND LEN(RTRIM(CallerNumber))>6
   AND CallResult<>''Canceled''
  AND  WP.Number IS NOT NULL -- Hodnocení hovorů nemá nahrávku ani pracoviště
  UNION
  SELECT TOP 1000
      ''I'' AS Directionx
	  , Redirector
	  , CallerNumber
	  , WP.Number
      , WP.DisplayName AS WorkPlaceName
      , IC.[InboundCallId] AS CallId
      ,[PilotTime]  AS CallTime
	  ,TimeUTC
	  ,CallDuration	  
  FROM .[dbo].[InboundCall] IC
    LEFT JOIN .[dbo].[CallRecord] CR ON CR.InboundCallId=IC.InboundCallId
    LEFT JOIN [SRec].[dbo].[Directory] DI ON RIGHT(DI.Number,3)=IC.Redirector
    LEFT JOIN .[dbo].[Workplace] WP ON WP.WorkplaceId=IC.WorkplaceId
  WHERE TimeUTC>@Today AND TimeUTC<@Now   AND CallDuration>1
  AND CR.INboundCallId IS NULL   
  AND CallResult =''served''
  AND LEN(RTRIM(CallerNumber))>6
  --AND Redirector NOT LIKE ''7%''
  AND isnull(DI.Record,1) <>0
    AND (FS_CUSTOM.dbo.CustomCheck2(''IC'',WP.DisplayName)=1 OR FS_CUSTOM.dbo.CustomCheck2(''ID'',IC.Redirector)=1)
  ) AS Phase1 ) AS Phase2
  LEFT JOIN  [SREC].[dbo].[VoiceRecord] VCR WITH(NOLOCK) ON StartTimeUtc>DATEADD(ss,-300,Phase2.TimeUtc) AND StartTimeUtc<DATEADD(ss,90,Phase2.TimeUtc)
   AND RIGHT(RemoteNumber,9)=RIGHT(Phase2.CallerNumber,9) --AND AgentName IS NULL --V jedné nahrávce může být více přepojených hovorů
   AND DATEDIFF(ss,StartTimeUtc,EndTimeUtc)>=Phase2.CallDuration',0,NULL,NULL,NULL,0,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'356889fb-b72b-4cdd-b4a3-210ffe83f968',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'ExRecord',N'Select',N'ExRecord',NULL,NULL,NULL,NULL,NULL,N'ExRecord',NULL,0,80,5,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'e2b9c1ce-c986-4a5b-8fd6-f425a48075d8',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'CallTime',N'DateTimeFromTo',N'CallTime',N'{0:dd.MM. HH:mm:ss}',NULL,NULL,NULL,NULL,N'CallTime',NULL,0,95,8,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'78cfb51d-532e-4a1d-a123-8cf8d3acca4a',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'StartTimeUTC',N'DateTimeUtc',N'StartTimeUTC',N'{0:dd.MM. HH:mm:ss}',NULL,NULL,NULL,NULL,N'StartTimeUTC',NULL,0,95,9,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'f8ab2090-b9fc-4842-bf99-8f32942f7526',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'Direction',N'Select',N'Direction',NULL,NULL,NULL,NULL,NULL,N'Direction',NULL,0,80,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'7f1dee4f-e552-4983-a9a4-a0a11339d2fe',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'Redirector',N'Select',N'Redirector',NULL,NULL,NULL,NULL,NULL,N'Redirector',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'bdf1b9a8-9a37-4647-83cb-bda8e24f2bb8',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'CallerNumber',N'Text',N'CallerNumber',NULL,NULL,NULL,NULL,NULL,N'CallerNumber',NULL,0,80,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'eb500b00-ed8f-4029-a760-fa4df36a4882',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'Number',N'Select',N'Number',NULL,NULL,NULL,NULL,NULL,N'Number',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'f28d0016-555e-4970-8ffc-ee8ab4825091',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'WorkPlaceName',N'Text',N'WorkPlaceName',NULL,NULL,NULL,NULL,NULL,N'WorkPlaceName',NULL,0,80,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'aace9b2d-9beb-48c7-b091-af1a1c8b3e07',N'a12aae6c-caef-4ba1-a117-221b2a6c1f75',N'CallId',N'Text',N'CallId',NULL,NULL,NULL,NULL,NULL,N'CallId',NULL,0,120,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)

