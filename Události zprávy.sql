/* ADMIN: Události zprávy */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted])
 VALUES(N'cb3d4ff6-770e-4337-a973-9b06133a5703',N'Události zprávy',NULL,N'ADMIN',N'TimeLocal',N'SELECT  [TimeLocal]
      ,[EventType]
      ,[MessageId]
      ,PR.DisplayName AS ProjectName
      ,AG.DisplayName AS AgentName
      ,[ReferenceData]
      ,[ReferenceId]
      ,[Duration]
      ,[ResultData]
  FROM [iCC].[dbo].[MessageEvent] AS ME WITH (NOLOCK)
  LEFT JOIN Agent AS AG WITH (NOLOCK) ON ME.AgentId=AG.AgentId
  LEFT JOIN Project AS PR WITH (NOLOCK) ON ME.ProjectId=PR.ProjectId
',0,NULL,NULL,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
 VALUES (N'483838ed-2a2e-4a58-901a-987e8761438b',N'cb3d4ff6-770e-4337-a973-9b06133a5703',N'MessageId',N'Text',N'MessageId',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,220,5,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
 VALUES (N'c21131b9-5f70-4475-bdef-8fdd1b10829e',N'cb3d4ff6-770e-4337-a973-9b06133a5703',N'TimeLocal',N'DateTimeFromTo',N'TimeLocal',N'{0:dd.MM.yy. HH:mm}',NULL,NULL,NULL,NULL,N'TimeLocal',NULL,0,80,10,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
 VALUES (N'434556b2-9f84-4184-9d72-4273d72fb8f1',N'cb3d4ff6-770e-4337-a973-9b06133a5703',N'EventType',N'Text',N'EventType',NULL,NULL,NULL,NULL,NULL,N'EventType',NULL,0,100,20,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
 VALUES (N'bc333ce3-f6a4-4952-87eb-7b29095a7bd5',N'cb3d4ff6-770e-4337-a973-9b06133a5703',N'ProjectName',N'Text',N'ProjectName',NULL,NULL,NULL,NULL,NULL,N'ProjectName',NULL,0,80,30,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
 VALUES (N'13615d55-8f6d-493c-b7e0-ceb5d0212165',N'cb3d4ff6-770e-4337-a973-9b06133a5703',N'AgentName',N'Text',N'AgentName',NULL,NULL,NULL,NULL,NULL,N'AgentName',NULL,0,80,40,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
 VALUES (N'12c14ff4-3ed1-4560-b88e-7eae8204f178',N'cb3d4ff6-770e-4337-a973-9b06133a5703',N'ReferenceData',N'Text',N'ReferenceData',NULL,NULL,NULL,NULL,NULL,N'ReferenceData',NULL,0,80,50,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
 VALUES (N'3c13bf8e-1549-4b70-8363-b2d5be25f894',N'cb3d4ff6-770e-4337-a973-9b06133a5703',N'Duration',N'Duration',N'Duration',NULL,NULL,NULL,NULL,NULL,N'Duration',NULL,0,60,60,NULL,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted])
 VALUES (N'09a42619-480f-4d37-a393-9974460026a1',N'cb3d4ff6-770e-4337-a973-9b06133a5703',N'ResultData',N'Text',N'ResultData',NULL,NULL,NULL,NULL,NULL,N'ResultData',NULL,0,80,70,NULL,0)

