:r C:\\Atlantis\\Scripts\\setvar.txt

DECLARE @TableName AS NVARCHAR(50)='Start'
DECLARE @ColumnName AS NVARCHAR(50)
DECLARE @TestValue AS NVARCHAR(50)
DECLARE @Command AS NVARCHAR(500)
DECLARE @Counter AS Integer = 0 
DECLARE @RowsCount AS Integer = 0 

DECLARE @ControlTable TABLE (TableName NVARCHAR(50), ColumnName NVARCHAR(50))
--============================================================================================================
/* Definice kontroly               TableName   ColumnName  (v kterých tabulkách a sloupcích má test probíhat)*/
insert into @ControlTable values                        
                                ('DataQuery','QueryText'),
								('DataQueryColumn','UrlFormat'), 
								('DataQueryColumn','SQLCMD'),
								('ActionTrigger','CommandText'),
								('WorkflowStep','Targets'),
						        ('IvrStep','Targets'),
								('IvrStep','FileName'), 
                                ('WorkflowStep','ReferenceText'), 
							    ('Scenario','OnSaveSqlCmd'),
							    ('Scenario','OnCreateSqlCmd')

--============================================================================================================
/* Definice testovaných hodnot    TestValue  - ty se v èástech kódu nemají vyskytovat  */
DECLARE @ValueTable TABLE (TestValue NVARCHAR(50))
insert into @ValueTable values ('iCC'),('FS_Custom'),('FSAdmin'),('ReactClient'),('phant240')
DECLARE @ValuesCount AS Integer = 0 
SET @ValuesCount = (SELECT COUNT(*) FROM @ValueTable)
SET @RowsCount = (SELECT COUNT(*) FROM @ControlTable)
DECLARE @ValCounter AS Integer = 0 
DECLARE @Value1 AS NVARCHAR(50)=(SELECT TOP 1 TestValue FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY TestValue) AS Row FROM @ValueTable) AS Phase1 WHERE Row=1)
DECLARE @Value2 AS NVARCHAR(50)=(SELECT TOP 1 TestValue FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY TestValue) AS Row FROM @ValueTable) AS Phase1 WHERE Row=2)
DECLARE @Value3 AS NVARCHAR(50)=(SELECT TOP 1 TestValue FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY TestValue) AS Row FROM @ValueTable) AS Phase1 WHERE Row=3)
DECLARE @Value4 AS NVARCHAR(50)=(SELECT TOP 1 TestValue FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY TestValue) AS Row FROM @ValueTable) AS Phase1 WHERE Row=4)
DECLARE @Value5 AS NVARCHAR(50)=(SELECT TOP 1 TestValue FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY TestValue) AS Row FROM @ValueTable) AS Phase1 WHERE Row=5)


USE $(FS_CUSTOM)
SELECT DISTINCT
      '$(FS_CUSTOM)' AS DB
       ,o.name AS Object_Name,
       o.type_desc,
	   definition
  FROM sys.sql_modules m
       INNER JOIN
       sys.objects o
         ON m.object_id = o.object_id
 WHERE m.definition COLLATE DATABASE_DEFAULT Like '%'+@Value1+'.%' COLLATE DATABASE_DEFAULT OR
       m.definition COLLATE DATABASE_DEFAULT Like '%'+@Value1+']%' COLLATE DATABASE_DEFAULT OR
       m.definition COLLATE DATABASE_DEFAULT Like '%'+@Value2+'.%' COLLATE DATABASE_DEFAULT OR
       m.definition COLLATE DATABASE_DEFAULT Like '%'+@Value2+']%' COLLATE DATABASE_DEFAULT OR
	   m.definition COLLATE DATABASE_DEFAULT Like '%'+@Value3+'.%' COLLATE DATABASE_DEFAULT OR
       m.definition COLLATE DATABASE_DEFAULT Like '%'+@Value3+']%' COLLATE DATABASE_DEFAULT OR
	   m.definition COLLATE DATABASE_DEFAULT Like '%'+@Value4+'.%' COLLATE DATABASE_DEFAULT OR
       m.definition COLLATE DATABASE_DEFAULT Like '%'+@Value4+']%' COLLATE DATABASE_DEFAULT OR
	   m.definition COLLATE DATABASE_DEFAULT Like '%'+@Value5+'.%' COLLATE DATABASE_DEFAULT OR
       m.definition COLLATE DATABASE_DEFAULT Like '%'+@Value5+']%' COLLATE DATABASE_DEFAULT 

    ORDER BY Type_desc,Object_Name
/**/

USE $(iCC)

--SELECT *,ROW_NUMBER() OVER (ORDER BY TableName,ColumnName) AS Row FROM @ControlTable
--RETURN
/*
  SELECT  DataQueryColumnId,DisplayName,SqlCmd,UrlFormat
  FROM .[dbo].[DataQueryColumn]
    WHERE SQLCmd LIKE '%'+@iCC+'.%' OR SQLCmd LIKE '%'+@FS_Custom+'.%' or SQLCmd LIKE '%'+@iCC+']%' OR SQLCmd LIKE '%'+@FS_Custom+']%'
		 OR UrlFormat LIKE @RCLink OR UrlFormat LIKE @FSAdmin

SELECT  DataQueryId,DisplayName,QueryText
  FROM .[dbo].[DataQuery]
     WHERE QueryText LIKE '%'+@iCC+'.%' OR QueryText LIKE '%'+@FS_Custom+'.%' or QueryText LIKE '%'+@iCC+']%' OR QueryText LIKE '%'+@FS_Custom+']%'
*/

  WHILE @Counter<=@RowsCount
    BEGIN
	  IF @Counter>0
	    BEGIN
	     SET @ValCounter=0
	     WHILE @ValCounter<@ValuesCount
		  BEGIN
		 	SET @ValCounter=@ValCounter+1
			 SELECT TOP 1 @TestValue  = TestValue
			 FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY TestValue) AS Row FROM @ValueTable) AS Phase1 WHERE ROW=@ValCounter
 
			 BEGIN
			  SET @Command='SELECT '''+@TableName+''' AS TableName ,  '''+@TestValue+''' AS TestValue, DisplayName,'+@ColumnName+',* FROM .[dbo].'+@TableName+
			  ' WHERE Deleted=0 AND ('+@ColumnName+' LIKE ''%'+@TestValue+'.%'' OR '+@ColumnName+' LIKE ''%'+@TestValue+']%''OR '+@ColumnName+' LIKE ''%'+@TestValue+'/%'')' 
			  EXEC (@Command)
			 END
          END
         END
      SET @Counter=@Counter+1
	  SELECT TOP 1
	      @TableName  = TableName,
	      @ColumnName = ColumnName
         FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY TableName,ColumnName) AS Row FROM @ControlTable) AS Phase2 WHERE ROW=@Counter
      --DELETE FROM @ControlTable WHERE @TableName  = TableName AND @ColumnName = ColumnName
	  --SET @TestValue=@iCC
	END

--SELECT * FROM FS_Custom.dbo.InspectColumn('DataQuery','QueryText',@iCC) -- toto mi nedovolilo spustit
--, ROW_NUMBER() OVER (ORDER BY DisplayName) AS Row