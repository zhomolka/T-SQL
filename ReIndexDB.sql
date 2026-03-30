DECLARE @TableName varchar(255) 
DECLARE TableCursor CURSOR FOR 
SELECT table_name FROM information_schema.tables 
WHERE table_type = 'base table' 
OPEN TableCursor 
FETCH NEXT FROM TableCursor INTO @TableName 

WHILE @@FETCH_STATUS = 0 
BEGIN 
BEGIN TRY
       DBCC DBREINDEX(@TableName,' ',90)

 

END TRY
BEGIN CATCH
       PRINT '!! PROBLEM: '+@TableName
END CATCH
FETCH NEXT FROM TableCursor INTO @TableName 
END 
CLOSE TableCursor 
DEALLOCATE TableCursor 