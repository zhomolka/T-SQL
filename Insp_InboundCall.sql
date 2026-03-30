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
USE iCC

SET @from=DATEADD(minute,-30,GETDATE())
SET @to=GETDATE()
/**/
SELECT TOP 1000 inboundcallid,
	   PilotTime,answertime,callresult,callphase
   FROM .[dbo].[InboundCall] IC
   
  WHERE 1=1
   --AND GdprObliviated IS NOT NULL   AND GdprObliviated <>0
   --AND InboundCallId IN ('e7ff33d1-0748-ee11-bd1b-000c290b07fe','c15c9692-a6b8-eb11-a433-8416f9021c38')
    AND PilotTime>@from
	-- HangupAgent
  ORDER BY PilotTime DESC

  SELECT TOP 100 
	   MAX(PilotTime) AS MAXPilotTime
	   ,MAX(answertime) AS MAXanswertime
	   --,callresult,callphase
   FROM .[dbo].[InboundCall] IC
   
  WHERE 1=1
   --AND GdprObliviated IS NOT NULL   AND GdprObliviated <>0
   --AND InboundCallId IN ('e7ff33d1-0748-ee11-bd1b-000c290b07fe','c15c9692-a6b8-eb11-a433-8416f9021c38')
    AND PilotTime>@from
	-- HangupAgent
  --ORDER BY PilotTime DESC