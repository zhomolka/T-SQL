/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @today AS Datetime=CONVERT(Date,GETDATE())
DECLARE @from AS datetime=convert(datetime, '2020.05.14 8:00')
DECLARE @to AS datetime=convert(datetime, '2018.06.30')
DECLARE @AgentId AS UniqueIdentifier = 'ddbc22e5-af73-4387-a5f4-77cd11740afe' -- Paní Balážová
SET @AgentId ='aa40d310-8363-4752-8a85-291c5bc07e24' -- Jana Matìjková 
--SET @AgentId ='97ef6373-30d2-4ff0-a44c-b3a78c33f636' -- Denis Ignatìv 
DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=@today --DATEADD(Day,-1,GETDATE())
    --SET @to=GETDATE()
  END
/**/
SET @to=DATEADD(Hour,6, @from)

SELECT TOP 1000 
      -- [Predistributed]
	  --,[Priority], 
	  dbo.TimeUTC_Local(CAE.[TimeUTC]) AS TimeLocal
	  ,AG.DisplayName AS AgentName
      --,[DistributionTime]
	   --,[ScheduleTime]    


--  , DATEDIFF(ss,TimeUTC,(SELECT TOP 1 TimeUTC FROM [iCC].[dbo].[CallEvent] CAE2 WHERE CAE.AgentId=CAE2.AgentId AND CAE2.TimeUTC>CAE.TimeUTC AND EventType='AgentOffered' ORDER BY [TimeUTC])) AS Pause

       ,ISNULL(IC.[CallerNumber],OC.[CallerNumber]) CallerNumber
      --,[EventType]
	  ,LL.LiteralText AS Event
	  , .dbo.FSC_WaitTime(CAE.TimeUTC,@AgentId) AS Pause
      ,CAE.[InboundCallId]
      ,CAE.[OutboundCallId]
	  ,ISNULL(IC.CallDuration,OC.CallDuration) CallDuration
	  /*
      ,CAE.[ProjectId]
      ,CAE.[AgentId]
      ,CAE.[WorkplaceId]
      ,[ReferenceData]
      ,[ReferenceId]
      ,[Duration]
      ,[ResultData]
      ,[ActorId] */
  FROM [CallEvent] CAE
  LEFT JOIN [OutboundCall] OC ON CAE.OutboundCallId=OC.OutboundCallId
  LEFT JOIN [InboundCall] IC ON CAE.InboundCallId=IC.InboundCallId
  LEFT JOIN [Agent] AG ON CAE.AgentId=AG.AgentId
   LEFT JOIN LiteralLookup AS LL ON CAE.EventType=LL.LiteralValue AND LL.LiteralGroup = 44 AND LL.Culture = 'cs-CZ'
  WHERE 1=1
    AND CAE.[TimeUTC]>@from AND CAE.[TimeUTC]<@To
	 --AND ProjectId='5B9F0380-64D3-4151-A91B-372E7ED4A953'
   --AND  EventType=31 --'AgentResult'
   AND  EventType=22 --'End'
   AND AG.TeamName='ZC (Zlín)'
   --AND CAE.AgentId=@AgentId
    --AND  ResultData='Auto'
    --AND  ReferenceData='Update'
    --AND CAE.OutboundCallId IS NOT NULL
	--AND OutboundCallId='16EAB967-7201-EA11-9E91-00505694C9CF'
    --AND (SELECT TOP 1 AgentId FROM CallEvent CAE2 WHERE CAE2.OutboundCallId=CAE.OutboundCallId AND CAE2.TimeUTC<CAE.TimeUTC ORDER BY TimeUTC DESC)<>CAE.AgentId
  ORDER BY CAE.Agentid,CAE.[TimeUTC]

  /*
  USE [Frontstage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbynìk Homolka>
-- Create date: <14.5.2020>
-- Description:	<øíká, jak dlouho agent èekal na nabídku dalšího hovoru ve stavu 'Ready'>
-- =============================================
ALTER FUNCTION [dbo].[FSC_WaitTime]
(
	-- Add the parameters for the function here
	@Starttime as Datetime,
	@AgentId AS UniqueIdentifier
)
RETURNS integer
AS
BEGIN
	DECLARE @EndTime as Datetime=(SELECT TOP 1 TimeUTC FROM [CallEvent] CAE WHERE CAE.AgentId=@AgentId AND CAE.TimeUTC>@Starttime AND 
	 (EventType=28 /*'AgentOffered'*/ OR EventType=14 /*'AgentRing'*/) ORDER BY [TimeUTC])
	DECLARE @WaitDuration as integer=DATEDIFF(ss,@Starttime,@EndTime)
	IF @WaitDuration>20
	  BEGIN -- Musím ještì odeèíst Not Ready stavy
	     --DECLARE @ReadyStatusId AS UniqueIdentifier=(SELECT TOP 1 [StatusId] FROM [Icc].[dbo].[Status] WHERE Activity='Ready' AND DefaultStatus=1)
	     DECLARE @NRDuration as integer=ISNULL((SELECT SUM(Duration) FROM [AgentEvent] WHERE TimeUTC>@Starttime AND TimeUTC<@EndTime AND AgentId=@AgentId AND 
		   ReferenceData<>'Ready' AND EventType<>2 /*'AgentProjectChannel'*/),0)
		 SET @WaitDuration=@WaitDuration-@NRDuration
	  END
	RETURN @WaitDuration

END


  */