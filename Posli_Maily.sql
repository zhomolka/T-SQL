DECLARE @from AS datetime
DECLARE @to AS datetime
DECLARE @now AS datetime=GETDATE()
DECLARE @MeAgentId AS UniqueIdentifier='4354b36d-e2ab-46ad-bc78-347edcd9b293'
DECLARE @SubjectField AS nvarchar(320)='INFO'
DECLARE @TeamName AS nvarchar(50)='INFO'

USE iCC
--SET @from=convert(datetime, '2015.11.01')
--SET @to=convert(datetime, '2015.11.30')

SET @from=GETDATE()-100
SET @to=GETDATE()
/**/
BEGIN TRANSACTION

UPDATE TOP (2) .[dbo].[Message]
  --SET MessagePhase='Scheduled',MessageResult='Active'
  SET MessagePhase='Closed',MessageResult='Closed'
  WHERE 1=1
    AND TimeUtc>@From
    AND Direction='O'
    --AND MessagePhase='Failed'
    AND MessagePhase='Scheduled'
	AND MessageResult='Closed'
	--AND MessageId='EF2505DB-EB05-EA11-80C5-001E67E7740D'
    
COMMIT TRANSACTION    
--ROLLBACK TRANSACTION    

BEGIN TRANSACTION

UPDATE .[dbo].[Message]
  SET ScheduledTime=DATEADD(ss,10,GETDATE())
  WHERE 1=1
    AND TimeUtc>@From
    AND Direction='O'
    AND MessagePhase='Scheduled'
	AND ScheduledTime>DATEADD(ss,60,GETDATE())
    
COMMIT TRANSACTION    
--ROLLBACK TRANSACTION    