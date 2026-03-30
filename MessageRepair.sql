DECLARE @from AS datetime
DECLARE @to AS datetime
DECLARE @now AS datetime=GETDATE()
DECLARE @MeAgentId AS UniqueIdentifier='4354b36d-e2ab-46ad-bc78-347edcd9b293'
DECLARE @SubjectField AS nvarchar(320)='INFO'
DECLARE @TeamName AS nvarchar(50)='INFO'

USE iCC
--SET @from=convert(datetime, '2015.11.01')
--SET @to=convert(datetime, '2015.11.30')

SET @from=GETDATE()-3
SET @to=GETDATE()
BEGIN TRANSACTION

UPDATE [iCC].[dbo].[Message]
  SET MessagePhase='Sent'
      ,MessageResult='Closed'
  WHERE 1=1
	   AND MessageId='90B4B647-E15C-E811-80D2-001E67F74983'

 --   AND TimeUtc>@From
 --   AND Direction='O'
 --   AND MessagePhase='Failed'
    
COMMIT TRANSACTION    
--ROLLBACK TRANSACTION    