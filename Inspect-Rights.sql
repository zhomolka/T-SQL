--SELECT DISTINCT class_desc FROM fn_builtin_permissions(default) ORDER BY class_desc;  
SELECT * FROM fn_my_permissions ( NULL , 'DATABASE' ) WHERE permission_name='VIEW DEFINITION'