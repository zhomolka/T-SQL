-- BACKUP Table:
/*
select * into iCC_Backup.dbo.OutboundCall from iCC.dbo.OutboundCall
WHERE CallResult = 'HangupAgent' AND CallPhase = 'NoResult'
*/
DECLARE @Now AS datetime=GETDATE()
DECLARE @TimeLimit AS datetime=DATEADD(Minute,-30,@Now)
BEGIN TRANSACTION

UPDATE [iCC].[dbo].[InboundCall]
SET CallResult = 'NoResult', CallPhase = 'HangupAgent'
WHERE 1=1
  AND Callresult='Active'
  AND CallPhase='Distributing'
  AND PilotTime < @TimeLimit

 
 -- COMMIT TRANSACTION
ROLLBACK TRANSACTION
