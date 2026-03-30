USE iCC
DECLARE @from AS datetime
DECLARE @to AS datetime
DECLARE @now AS datetime=GETDATE()
DECLARE @MeAgentId AS UniqueIdentifier='4354b36d-e2ab-46ad-bc78-347edcd9b293'
DECLARE @SubjectField AS nvarchar(320)='INFO'
DECLARE @TeamName AS nvarchar(50)='INFO'
DECLARE @Counter AS Int = 1

--SET @from=convert(datetime, '2015.11.01')
--SET @to=convert(datetime, '2015.11.30')

SET @from=GETDATE()-2
SET @to=GETDATE()
/**/

WHILE @Counter<6
  BEGIN
UPDATE TOP (1) .[dbo].[Message]
  SET MessagePhase='Scheduled',MessageResult='Active'
  --SET MessagePhase='Closed',MessageResult='Closed'
  WHERE 1=1
    AND TimeUtc>@From
    AND Direction='O'
  AND MessagePhase='Failed'
    --  AND MessagePhase='Scheduled'
	--AND MessageId='59680C28-C515-EA11-A2C8-00155D0A712D'
	SET @Counter=@Counter+1
	WAITFOR DELAY '00:00:01'
   END   
