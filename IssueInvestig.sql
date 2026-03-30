/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @from AS datetime=convert(datetime, '2015.11.01')
DECLARE @to AS datetime=convert(datetime, '2015.11.01')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER='ef0de42d-e6c2-4719-a264-9447484f4c8b'
DECLARE @NullId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
USE iCC

SET @from=GETDATE()-10
SET @to=GETDATE()

SELECT TOP (1000) ISU.[IssueId]
,[NewTime]
      ,ISU.[TimeUtc] AS ISU_TimeUtc
	 ,IIF(IC.InboundCallId IS NULL,'O','I') AS Direction
	 ,ISNULL(IC.[TimeUtc],OC.[TimeUtc])  AS Call_TimeUtc
	 ,ISNULL(IC.InboundCallId,OC.OutboundCallId) AS CallId
	  ,ISU.[ContactId] AS ISU_ContactId 
	 -- ,ISNULL(IC.[ContactId],IC.[ContactId]) AS Call_ContactId
      --,[DisplayName]
      ,[Activity]
      ,[PhaseId]
      ,[TopicId]
      ,[SubTopicId]
      ,ISU.[AgentId]
      ,[OriginalProjectId]
      ,[FormDataId]
      ,[BodyHtml]      
      ,[OpenTime]
      ,[HoldTime]
      ,[WaitTime]
      ,[CloseTime]
      ,[NewClosed]
      ,[Reactivated]
      ,[Escalated]
      ,[OpenDuration]
      ,[NetDuration]
       ,[IssueKey]
  FROM [iCC].[dbo].[Issue] ISU
    LEFT JOIN InboundCall IC ON ISU.IssueId=IC.IssueId 
	LEFT JOIN OutboundCall OC ON ISU.IssueId=OC.IssueId 
   WHERE 1=1
     --AND ContactId IS NULL
	 --AND Activity='Open'
    AND ISU.IssueId='9092D521-3F6A-E811-B2A8-0050568E4C40'
   -- AND ISU.TimeUTC>@From
   --AND DisplayName = ''
   ORDER BY ISU.TimeUtc