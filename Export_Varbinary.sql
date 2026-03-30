--SELECT value_in_use FROM sys.configurations WHERE name = 'Ole Automation Procedures';
/*sp_configure 'show advanced options', 1;
RECONFIGURE;
sp_configure 'Ole Automation Procedures', 0;
RECONFIGURE;*/
DECLARE @BinaryData VARBINARY(MAX), @Object AS Integer
SELECT @BinaryData = BinaryContent FROM .[dbo].[Attachment] ATC

  where AttachmentId='304226B7-B464-EE11-83C0-005056013ADB'

DECLARE @FilePath NVARCHAR(255) = 'C:\Atlantis-install\VYVOJ\MyFile.bin'
DECLARE @File AS VARBINARY(MAX) = @BinaryData

-- Uložení do souboru
EXEC sp_OACreate 'ADODB.Stream', @Object OUT
EXEC sp_OASetProperty @Object, 'Type', 1
EXEC sp_OAMethod @Object, 'Open'
EXEC sp_OAMethod @Object, 'Write', NULL, @File
EXEC sp_OAMethod @Object, 'SaveToFile', NULL, @FilePath, 2
EXEC sp_OAMethod @Object, 'Close'
EXEC sp_OADestroy @Object
