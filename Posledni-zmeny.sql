USE FS_custom
SELECT name, create_date, modify_date 
FROM sys.objects
WHERE modify_date>convert(Datetime,'2017.04.01') ORDER BY Name