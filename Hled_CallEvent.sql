/****** Script for SelectTopNRows command from SSMS  ******/
USE iCC
GO
DECLARE @from AS date=convert(datetime, '2018.06.01')
DECLARE @to AS date=convert(datetime, '2018.06.30')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent WHERE Activity='Ready')
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
DECLARE @Number AS integer
DECLARE @GroupInterval AS integer=44640
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @Version  AS integer=1


/**/
SET @from=GETDATE()-1
SET @to=GETDATE()

SELECT TOP 1000 
      [TimeUtc]
      ,[TimeLocal]
      ,[EventType]
      ,[InboundCallId]
      ,[OutboundCallId]
      ,[ProjectId]
      ,[AgentId]
      ,[WorkplaceId]
      ,[ReferenceData]
      ,[ReferenceId]
      ,[Duration]
      ,[ResultData]
      ,[ActorId]
  FROM [iCC].[dbo].[CallEvent] CAE
  WHERE 1=1
    AND [TimeLocal]>@from
    AND  EventType='IssueChange'
    AND  ResultData='Auto'
    AND  ReferenceData='Update'
    AND OutboundCallId IS NOT NULL
    AND (SELECT TOP 1 AgentId FROM CallEvent CAE2 WHERE CAE2.OutboundCallId=CAE.OutboundCallId AND CAE2.TimeLocal<CAE.TimeLocal ORDER BY TimeLocal DESC)<>CAE.AgentId
  ORDER BY [TimeLocal]