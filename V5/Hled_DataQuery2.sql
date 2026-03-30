/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) DQ.[DataQueryId]
      ,DQ.[DisplayName]
      ,[Description]
      ,[QueryGroup]
      ,[QuerySortExpression]
      ,[QueryText]
      ,[ManualFilter]
      ,[SnapshotInterval]
      ,[TimeLine]
      ,DQ.[Deleted]
      ,[CacheInterval]
      ,[LogLevel]
      ,[DataQuerySourceId]
      ,[DataQueryWhereJSON]
  FROM [DataQuery] DQ
  LEFT JOIN DataQueryColumn DQC ON DQC.DataQueryid=DQ.DataQueryid
  WHERE 1=1
  --AND DisplayName LIKE '%Command%'
  -- AND QueryGroup='ServiceAPP'
  AND DQC.DataQueryId IS NOT NULL
  --AND DisplayName='Monitoring system'
 AND DQ.DataQueryId='73342443-45f0-4c26-aa6c-37335adb34a4'
 