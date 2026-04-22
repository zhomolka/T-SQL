
:setvar Version 22.04.2026
:r C:\\Atlantis\\Scripts\\setvar.txt
:on error exit
PRINT 'Script is running on == $(MonitorDB) =='

DECLARE @FSVersion AS NVARCHAR(2) = 'V2'

DECLARE @LowPermission AS bit = $(LowPermission) -- 0 = normální oprávnìní, 1 = nízké oprávnìní

USE $(MonitorDB)
GO
/* =========  Konec zavadìèe ========= */

DELETE TOP (1) FROM Monitor WHERE MonitorId='C6CB3049-B92B-4CF5-A7D0-05B0637D4A98'


GO