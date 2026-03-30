
set @SourceDatabase =   N'Northwind'        -- The name of the Source database
set @SourceSchemaName = N'dbo'              -- The name of the Function SCHEME
set @FunctionName =     N'WriteToTextFile'  -- The name of the Function   
set @TargetDatabase =   N'AdventureWorks'   -- The name of the Target database
  
declare @sql nvarchar(max) 
 
-- If the Function SCHEME does not exist, create it
set @sql = ' use [' +@TargetDatabase +'] ' +
            ' IF NOT EXISTS (SELECT * FROM sys.schemas WHERE lower(name) = lower(''' + @SourceSchemaName + ''')) '+
            ' BEGIN ' +
            '   EXEC('' CREATE SCHEMA '+ @SourceSchemaName +''') ' +
            ' END'
 
exec (@sql);

-- CREATE OR ALTER THE FUNCTION
set @sql = ''
set @sql = @sql + ' use [' + @TargetDatabase +'] ;' +
                    ' declare @sql2 nvarchar(max) ;' + 
                    ' SELECT @sql2 = coalesce(@sql2,'';'' ) + [ROUTINE_DEFINITION] + '' ; '' ' +
                    ' FROM  ['+@sourceDatabase+'].[INFORMATION_SCHEMA].[ROUTINES] '  +
                    ' where ROUTINE_TYPE = ''FUNCTION'' and ROUTINE_SCHEMA = ''' +@SourceSchemaName +''' and lower(ROUTINE_NAME) = lower(N''' + @FunctionName + ''')  ; ' +
                    ' set @sql2 = replace(@sql2,''CREATE FUNCTION'',''CREATE OR ALTER FUNCTION'')' +
                    ' exec (@sql2)'
exec (@sql)