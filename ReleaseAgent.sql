USE [iCC]
GO
DECLARE @AgentName AS VARCHAR(24)
SET @AgentName = 'Monika Stanieková'
-- Naètení od obsluhy
--accept l_dept number format '99' prompt 'Department #: '

SELECT 'Provádím nápravu agenta '+@AgentName+' - èekám 30sekund.' AS Zpráva
--PRINT 'Provádím nápravu pracovištì '+@Workplace+' - èekám 30sekund.'
WAITFOR DELAY '00:00:01'
RAISERROR('',10,1) WITH NOWAIT

BEGIN Transaction
UPDATE [dbo].[Agent] SET Deleted=1 WHERE DisplayName = @AgentName
COMMIT TRANSACTION

WAITFOR DELAY '00:00:30'

BEGIN Transaction
UPDATE [dbo].[Agent] SET Deleted=0 WHERE DisplayName = @AgentName
COMMIT TRANSACTION

SELECT 'Konec operace. ' AS Zpráva


GO