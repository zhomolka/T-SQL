/****** Script for SelectTopNRows command from SSMS  ******/
USE Frontstage
DECLARE @from AS datetime=convert(datetime, '2023.12.21 7:00')
DECLARE @to AS datetime=convert(datetime, '2023.12.24 10:00')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER='ef0de42d-e6c2-4719-a264-9447484f4c8b'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1

/*
SET @from=GETDATE()-1
SET @to=GETDATE()

SELECT --TOP 1000 
  COUNT(1)
	  -- PilotTime
	  --,EndTime
   --   ,[TimeUtc]
   FROM .[dbo].[InboundCall] IC WITH (NOLOCK)
    -- LEFT JOIN [iCC].[dbo].[Workplace] WP ON IC.WorkplaceId=WP.WorkplaceId
  WHERE 1=1
   --AND InboundCallId IN ('e5847637-b18e-e611-80bd-001e67feed3f','31C22EAC-F28A-E611-80F2-F8BC1253A1A4')
    AND PilotTime>DATEADD(Minute,-30,@from) AND PilotTime<@from
	AND @from BETWEEN PilotTime AND EndTime
  --ORDER BY PilotTime
*/

 SELECT S
 /**/
 ,( SELECT
   COUNT(1)
   FROM .[dbo].[InboundCall] IC WITH (NOLOCK)

  WHERE 1=1

    AND PilotTime>DATEADD(Minute,-30,S) AND PilotTime<S
	AND S BETWEEN PilotTime AND EndTime

 ) AS ActiveCalls

  FROM Rep_DateTime(@from,@To,'t')
  ORDER BY S