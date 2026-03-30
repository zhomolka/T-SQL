DECLARE @TableName AS NVARCHAR(50)='DataQueryColumn'
DECLARE @ColumnName AS NVARCHAR(50)='URLFormat'
DECLARE @TestValue AS NVARCHAR(50)='FSADMIN'

SELECT 'SELECT '''+@TableName+''' AS TableName ,  '''+@TestValue+''' AS TestValue, DisplayName,'+@ColumnName+' FROM .[dbo].'+@TableName+
			  ' WHERE Deleted=0 AND ('+@ColumnName+' LIKE ''%'+@TestValue+'.%'' OR '+@ColumnName+' LIKE ''%'+@TestValue+']%''OR '+@ColumnName+' LIKE ''%'+@TestValue+'/%'')'

--SELECT 'DataQueryColumn' AS TableName ,  'FSADMIN' AS TestValue, DisplayName,URLFormat FROM .[dbo].DataQueryColumn WHERE Deleted=0 AND (URLFormat LIKE '%FSADMIN.%' OR URLFormat LIKE '%FSADMIN]%'OR URLFormat LIKE '%FSADMIN/%')
SELECT 'DataQueryColumn' AS TableName ,  'FSAdmin' AS TestValue, DisplayName,UrlFormat FROM .[dbo].DataQueryColumn WHERE Deleted=0 AND (UrlFormat LIKE '%FSAdmin.%' OR UrlFormat LIKE '%FSAdmin]%'OR UrlFormat LIKE '%FSAdmin/%')