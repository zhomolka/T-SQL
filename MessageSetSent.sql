DECLARE @from AS datetime=convert(datetime, '2017.06.14')
DECLARE @to AS datetime=convert(datetime, '2018.11.23 9:30')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER='ef0de42d-e6c2-4719-a264-9447484f4c8b'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1

DECLARE @Id AS UNIQUEIDENTIFIER='450244d1-fde0-e811-80d3-001e67f74984'
 BEGIN TRANSACTION
UPDATE iCC.dbo.Message
SET MessagePhase='Closed',MessageResult='Closed'
WHERE 1=1
 AND Direction='O'
  AND  MessagePhase='Answering'--'Sent'--


COMMIT TRANSACTION

--ROLLBACK TRANSACTION
