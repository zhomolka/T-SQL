/****** Script for SelectTopNRows command from SSMS  ******/

DECLARE @from AS datetime=convert(datetime, '2018.02.01')
DECLARE @to AS datetime=convert(datetime, '2018.02.28')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER='ef0de42d-e6c2-4719-a264-9447484f4c8b'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
--USE iCC

SET @from=GETDATE()-1
SET @to=GETDATE()

SELECT TOP (1000) --[CallRecordId],
      IC.PilotTime,
	  DATEDIFF(ss,IC.TimeUTC,StartTimeUTC) AS VCRTime_PilotTime
	  ,DATEDIFF(ss,IC.AnswerTime,.dbo.TimeUTC_Local(StartTimeUTC)) AS VCRTime_AnswerTime
      ,CR.[InboundCallId]
      ,[OutboundCallId]
      ,[RecordFileId]
      ,[Score]
  FROM .[dbo].[CallRecord] CR
    LEFT JOIN .[dbo].InboundCall IC ON IC.InboundCallId=CR.InboundCallId
	LEFT JOIN .[dbo].VoiceRecord VC ON VC.VoiceRecordId=CR.RecordFileId
	WHERE 1=1
	AND CR.[InboundCallId] IS NOT NULL
	AND CR.[InboundCallId]='178ec19c-d11d-ef11-83a6-a4bf016eaf17'
    --AND PilotTime>@from
	ORDER BY Score