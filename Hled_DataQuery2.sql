/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [DataQueryId]
      ,[DisplayName]
      ,[Description]
      ,[QueryGroup]
      ,[QuerySortExpression]
      ,[QueryText]
      ,[ManualFilter]
      ,[SnapshotInterval]
      ,[TimeLine]
      ,[Deleted]
      ,[CacheInterval]
      ,[LogLevel]
      ,[DataQuerySourceId]
      ,[DataQueryWhereJSON]
  FROM .[dbo].[DataQuery] WHERE 1=1
  --AND DisplayName LIKE '%Command%'
    AND Dataqueryid='e67f9717-e912-4f37-8c81-ead7c65c7800'