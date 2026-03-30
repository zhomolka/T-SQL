-- Zálohuje èásti tabulek a potom je pøípadnì maže 
DECLARE @from AS datetime=convert(datetime, '2017.01.05')
DECLARE @to AS datetime=convert(datetime, '2017.02.21')
DECLARE @cfrom AS NVARCHAR(100)='convert(datetime, '''+CONVERT ( nvarchar(10), @from , 102 )+''')'
DECLARE @cto AS NVARCHAR(100)='convert(datetime, '''+CONVERT ( nvarchar(10), @To , 102 )+''')'

DECLARE @MyTable AS NVARCHAR(40)='Issue'--'InboundCall' --
DECLARE @Command AS NVARCHAR(300)
DECLARE @Perform AS bit =0

--DECLARE @Condition AS NVARCHAR(300)=' WHERE SubjectField LIKE '+'''Test Atlantis%'''+'AND TimeUtC> '+@cfrom+' AND TimeUtC< '+@cto
DECLARE @Condition AS NVARCHAR(300)=' WHERE WorkplaceId='+'''8AB373B0-2440-4829-9CDA-05EB3BC9B9F0'''+' AND CallResult<>'+'''Served'''
--DECLARE @Condition AS NVARCHAR(300)=' WHERE SubjectField LIKE '+'''Test Atlantis%'''+'AND TimeUtC> '+@cfrom+' AND TimeUtC< '+@cto

--SELECT @Condition
--RETURN
--AND TimeUtc BETWEEN @from AND @to - toto je pomalé
--SELECT 'select * into Icc_Backup.dbo.'+@MyTable+' from iCC.dbo.'+@MyTable+@Condition
/*
*/
--EXEC('select * into Icc_Backup.dbo.'+@MyTable+' from iCC.dbo.'+@MyTable+@Condition)
-- Pro maily:
IF @MyTable='Issue' AND @Perform=1
  BEGIN
    --EXEC('select * into Icc_Backup.dbo.Attachment from iCC.dbo.Attachment WHERE MessageId IN (SELECT MessageId from Icc.dbo.Message'+@Condition+')')
    --EXEC('select * into Icc_Backup.dbo.MessageEvent from iCC.dbo.MessageEvent WHERE MessageId IN (SELECT MessageId from Icc.dbo.Message'+@Condition+')')
	select * into Icc_Backup.dbo.Issue from iCC.dbo.Issue
   WHERE IssueId IS NOT NULL
   AND ProjectId<>'e0deaf60-28a0-4bee-b6d5-af9e7561cd06'
  --AND PH.[DisplayName] LIKE 'Vyøešeno%'
  --AND AG.DisplayName= 'Bajnoková Marcela'
  AND TimeUtc<convert(datetime, '2017.01.01')
  --AND TimeUtc>convert(datetime, '2016.12.01')
  AND Activity<>'Closed'


  END
IF @MyTable='InboundCall'
  BEGIN
    EXEC('select * into Icc_Backup.dbo.CallEvent from iCC.dbo.CallEvent WHERE InboundCallId IN (SELECT InboundCallId from Icc.dbo.InboundCall'+@Condition+')')
    EXEC('select * into Icc_Backup.dbo.ScenarioResult from iCC.dbo.ScenarioResult WHERE InboundCallId IN (SELECT InboundCallId from Icc.dbo.InboundCall'+@Condition+')')
    EXEC('select * into Icc_Backup.dbo.ScenarioResultValue from iCC.dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
    WHERE InboundCallId IN (SELECT InboundCallId from Icc.dbo.InboundCall'+@Condition+'))')
    EXEC('select * into Icc_Backup.dbo.Issue from iCC.dbo.Issue WHERE FormDataid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
    WHERE InboundCallId IN (SELECT InboundCallId from Icc.dbo.InboundCall'+@Condition+'))')
    -- InboundCall nebudu již kvùli ChainingId zálohovat
  END


BEGIN TRANSACTION


IF @MyTable='Issue'
  BEGIN
    --EXEC('DELETE FROM iCC.dbo.Attachment WHERE MessageId IN (SELECT MessageId from Icc.dbo.Message'+@Condition+')')
    --EXEC('DELETE FROM iCC.dbo.MessageEvent WHERE MessageId IN (SELECT MessageId from Icc.dbo.Message'+@Condition+')')
 UPDATE iCC.dbo.Issue
SET Activity='Closed',PhaseId='92FF6440-83F2-4339-8DA8-6AC519E09C94'
  WHERE IssueId IS NOT NULL
   AND ProjectId<>'e0deaf60-28a0-4bee-b6d5-af9e7561cd06'
  --AND PH.[DisplayName] LIKE 'Vyøešeno%'
  --AND AG.DisplayName= 'Bajnoková Marcela'
  AND TimeUtc<convert(datetime, '2017.01.01')
  --AND TimeUtc>convert(datetime, '2016.12.01')
  AND Activity<>'Closed'

  END

IF @MyTable='InboundCall'
  BEGIN
    EXEC('update iCC.dbo.Issue set formdataid = null WHERE FormDataid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
    WHERE InboundCallId IN (SELECT InboundCallId from Icc.dbo.InboundCall'+@Condition+'))')
    EXEC('DELETE FROM iCC.dbo.ScenarioResultValue WHERE scenarioresultid IN (SELECT scenarioresultid from Icc.dbo.ScenarioResult
    WHERE InboundCallId IN (SELECT InboundCallId from Icc.dbo.InboundCall'+@Condition+'))')
    EXEC('update icc.dbo.CallEvent set InboundCallId = null where InboundCallId IN (SELECT InboundCallId from Icc.dbo.InboundCall'+@Condition+')')
    EXEC('DELETE FROM iCC.dbo.ScenarioResult WHERE InboundCallId IN (SELECT InboundCallId from Icc.dbo.InboundCall'+@Condition+')')
    EXEC('update icc.dbo.InboundCall set ChainingId = null where ChainingId IN (SELECT InboundCallId from Icc.dbo.InboundCall'+@Condition+')')
  END
  
--EXEC('DELETE FROM iCC.dbo.'+@MyTable+@Condition)

--COMMIT TRANSACTION
ROLLBACK TRANSACTION
/*
*/




