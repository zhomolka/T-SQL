UPDATE FS_custom.dbo.ErrorLog
SET RepeatAfter = -1
WHERE  Message LIKE '%Agent%' and Message LIKE '%_%'

