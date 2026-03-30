-- BACKUP Table:
/*
select * into iCC_Backup.dbo.OutboundCall from iCC.dbo.OutboundCall
WHERE CallResult = 'HangupAgent' AND CallPhase = 'NoResult'
*/

BEGIN TRANSACTION

UPDATE [iCC].[dbo].[OutboundCall]
SET CallResult = 'NoResult', CallPhase = 'HangupAgent'
WHERE CallResult = 'HangupAgent' AND CallPhase = 'NoResult'

 
 COMMIT TRANSACTION
 --ROLLBACK TRANSACTION
