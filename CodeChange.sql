USE $(FS_CUSTOM)
DECLARE @from AS datetime=convert(datetime, '2019.04.01')
DECLARE @to AS datetime=convert(datetime, '2019.04.01')
DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(Day,-10,GETDATE())
    SET @to=GETDATE()
  END

SELECT --DISTINCT
modify_date, Name, Definition  FROM sys.sql_modules m
       INNER JOIN sys.objects o ON m.object_id = o.object_id

		 WHERE 1=1 
		 AND modify_date>@from 
		 --AND definition LIKE '%Zbynìk%'
		 --AND Name='aholdFillVars'
		 ORDER BY modify_date DESC