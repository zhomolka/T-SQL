:r C:\\Atlantis\\Scripts\\setvar.txt


DECLARE @Retezec AS NVARCHAR(100)='%.Eventlog%'
DECLARE @Retezec2 AS NVARCHAR(100)='%%' -- If you want not use it set '%%'
DECLARE @Retezec3 AS NVARCHAR(100)='%%' -- If you want not use it set '%%'


USE $(ICC)
SELECT DISTINCT
       '$(ICC)' AS DB
       ,o.name AS Object_Name,
       o.type_desc,
	   definition
  FROM sys.sql_modules m
       INNER JOIN
       sys.objects o
         ON m.object_id = o.object_id
 WHERE m.definition LIKE @Retezec AND m.definition LIKE @Retezec2  
   ORDER BY Type_desc,Object_Name

 SELECT DISTINCT
       'iCC triggers' AS Zone
       ,o.name AS Object_Name,
       o.type_desc,
	   definition
  FROM sys.sql_modules m
       INNER JOIN sys.objects o ON m.object_id = o.object_id
	   INNER JOIN sys.triggers TR ON TR.object_id = o.object_id
 WHERE m.definition LIKE @Retezec AND m.definition LIKE @Retezec2 ;

 SELECT *
        FROM .[dbo].[ActionTrigger]
  WHERE CommandText LIKE @Retezec AND CommandText LIKE @Retezec2 AND Deleted=0

  SELECT *
        FROM .[dbo].[WorkflowStep]
  WHERE Targets LIKE @Retezec AND Targets LIKE @Retezec2 AND Deleted=0


  SELECT  *
  FROM .[dbo].[DataQueryColumn] DQC
   LEFT JOIN .[dbo].[DataQuery] DQ ON DQ.DataqueryId=DQC.DataqueryId AND DQ.Deleted=0
    WHERE SQLCmd LIKE @Retezec AND SQLCmd LIKE @Retezec2 AND DQC.Deleted=0
	    AND DQ.DataqueryId IS NOT NULL

SELECT TOP 1000 [DataQueryId]
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
  FROM .[dbo].[DataQuery]
     WHERE QueryText LIKE @Retezec AND Deleted=0 AND QueryText LIKE @Retezec2 AND QueryText LIKE @Retezec3

	 SELECT TOP 1000 [IvrStepId]
      ,[IvrScriptId]
      ,[DisplayName]
      ,[Rank]
      ,[Action]
      ,[TimeOut]
      ,[WaitTimeOut]
      ,[FileName]
      ,[MultiLanguage]
      ,[Retries]
      ,[ResultDigits]
      ,[SkipDigits]
      ,[ReplayDigits]
      ,[Targets]
      ,[TargetId]
      ,[Numbers]
      ,[TimeMode]
      ,[TimeFrom]
      ,[TimeTo]
      ,[Culture]
      ,[Deleted]
  FROM .[dbo].[IvrStep]
   WHERE (Targets LIKE @Retezec OR FileName LIKE @Retezec) AND Deleted=0

    SELECT TOP 1000 [ImrStepId]
      ,IM.[ImrScriptId]
      ,IM.[DisplayName]
	  ,IMS.[DisplayName]
      ,[Rank]
      ,[Action]
      ,[Targets]
      ,[TargetId]
      ,[TimeMode]
      ,[TimeFrom]
      ,[TimeTo]

  FROM .[dbo].[ImrStep] IMS
    LEFT JOIN .[dbo].[IMRScript] IM ON IM.IMRScriptId=IMS.IMRScriptId AND IM.Deleted=0
   WHERE Targets LIKE @Retezec AND IMS.Deleted=0 AND IM.IMRScriptId IS NOT NULL


   SELECT TOP (1000) [ScenarioId]
      ,[DisplayName]
      ,[Description]
      ,[GroupName]
      ,[OnSaveSqlCmd]
      ,[OnCreateSqlCmd]
  FROM .[dbo].[Scenario]
     WHERE OnSaveSqlCmd LIKE @Retezec AND Deleted=0 OR OnCreateSqlCmd LIKE @Retezec AND Deleted=0

   SELECT  Tables.Name TableName,
      Triggers.name TriggerName,
      Triggers.crdate TriggerCreatedDate,
      Comments.Text TriggerCode
FROM sysobjects Triggers
      Inner Join sysobjects Tables On Triggers.parent_obj = Tables.id
      Inner Join syscomments Comments On Triggers.id = Comments.id
WHERE      Triggers.xtype = 'TR'
   AND Comments.Text LIKE @Retezec 
      --And Tables.xtype = 'U'
ORDER BY Tables.Name, Triggers.name

 
   
SELECT TOP (1000) [ScreenControlParameterId]
      ,[ScreenControlId]
      ,[DisplayName]
      ,[Rank]
      ,[ResultNumber]
      ,[ResultText]
      ,[DefaultItem]
      ,[Glyph]
  FROM .[dbo].[ScreenControlParameter]
    WHERE  ResultText LIKE @Retezec 

SELECT TOP (1000) [NavigationId]
      ,[GroupName]
      ,[DisplayName]
      ,[Rank]
      ,[Url]
      ,[Options]
      ,[Description]
      ,[Icon]
      ,[Glyph]
  FROM .[dbo].[Navigation]
    WHERE Url LIKE @Retezec 

SELECT TOP 1000 [MessageId]
,SubjectField
  FROM .[dbo].[Message]
  WHERE MessageType Like 'Tmp%' AND MessageResult = 0 /*'Active'*/
  AND (SubjectField LIKE @Retezec OR SubjectField LIKE @Retezec2 AND @Retezec2<>'%%')



USE $(ProServer)
SELECT DISTINCT
       'ProServer triggers' AS Zone
       ,o.name AS Object_Name,
       o.type_desc,
	   definition
  FROM sys.sql_modules m
       INNER JOIN sys.objects o ON m.object_id = o.object_id
	   INNER JOIN sys.triggers TR ON TR.object_id = o.object_id
 WHERE m.definition LIKE @Retezec AND m.definition LIKE @Retezec2 ;
