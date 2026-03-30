--GRANT SELECT ON Object::dbo.FSC_Monitor TO admin-fs;
--GRANT SELECT ON OBJECT::dbo.FSC_Monitor TO dbo;
SELECT name 
FROM sys.database_principals 
WHERE name = 'dbo';
SELECT SUSER_NAME() AS CurrentLogin, USER_NAME() AS CurrentUser, ORIGINAL_LOGIN() AS OriginalLogin;
GRANT SELECT ON dbo.FSC_Monitor TO [admin-fs];

SELECT name 
FROM sys.database_principals 
WHERE name = 'admin-fs';