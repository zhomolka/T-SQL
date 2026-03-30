:setvar FS_CUSTOM FS_CUSTOM -- PCS
:setvar ICC ICC_H
:setvar ProServer ProServer
--:setvar SREC SREC

DECLARE @Retezec AS NVARCHAR(100)='%FS_CUSTOM.%'
DECLARE @Retezec2 AS NVARCHAR(100)='%%' -- If you want not use it set '%%'

USE $(FS_custom)
SELECT DISTINCT
      '$(FS_custom)' AS DB
       ,o.name AS Object_Name,
       o.type_desc,
	   definition
  FROM sys.sql_modules m
       INNER JOIN
       sys.objects o
         ON m.object_id = o.object_id
 WHERE (m.definition LIKE '%ZbH%' OR m.definition LIKE '%Zbynìk%') AND m.definition NOT LIKE '%FSC_%'
    ORDER BY Type_desc,Object_Name

