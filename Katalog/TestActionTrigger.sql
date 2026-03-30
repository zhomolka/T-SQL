USE FS_Custom
GO

UPDATE .dbo.Commands
SET Description=NULL--'Monitoring system'
, GroupName=NULL --'Test' -- 
 WHERE 1=1
 and CommandId='F8FE402B-9DCB-47CD-94E0-4F39C06686A9'

 SELECT *
  FROM [FS_custom].[dbo].[Commands]

 /**/
 /*
 CREATE TRIGGER trgLogColumnValue
ON Commands
AFTER UPDATE
AS
BEGIN
      UPDATE t
        SET Description = ISNULL(t.Description,d.Description)
        FROM dbo.Commands AS t
        INNER JOIN deleted AS d
        ON t.CommandId = d.CommandId;
END;
*/
