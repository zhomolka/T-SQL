/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @from AS datetime=convert(datetime, '2018.09.01')
DECLARE @to AS datetime=convert(datetime, '2018.11.30')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER='ef0de42d-e6c2-4719-a264-9447484f4c8b'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
USE iCC

/*
SET @from=GETDATE()-1
SET @to=GETDATE()
*/
SELECT DISTINCT TOP 100000
      IC.InboundCallId 
	  ,PilotTime
      ,[CallType]
      ,[CallPhase]
      ,[CallResult]
      ,IIF(CallerNumber=' ','SKRYTE',CallerNumber)
    FROM [iCC].[dbo].[InboundCall] IC
  WHERE 1=1
   --AND InboundCallId IN ('e5847637-b18e-e611-80bd-001e67feed3f','31C22EAC-F28A-E611-80F2-F8BC1253A1A4')
    AND PilotTime>@from
	AND ChainingId IS NOT NULL
	--AND CAE.ResultData='TransferedRelease'
  ORDER BY PilotTime