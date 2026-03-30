/****** Script for SelectTopNRows command from SSMS  ******/
USE iCC
DECLARE @from AS datetime
DECLARE @to AS datetime
SET @from=convert(datetime, '2018.02.15 10:00')
SET @to=convert(datetime, '2018.02.15 12:00')
DECLARE @LastTime AS bit=1

IF @LastTime=1
  BEGIN
    SET @from=DATEADD(Day,-20,GETDATE())
    SET @to=GETDATE()
  END

SELECT TOP 1000 [MessageId]
  ,(SELECT TOP 1 TimeLocal FROM MessageEvent MEE WITH (NOLOCK) WHERE MEE.MessageId=ME.MessageId AND MEE.EVentType='Sent' AND MEE.ReferenceData='Scheduled') AS Planned
  ,[ReceivedSentTime]
  ,DATEDIFF(SECOND,(SELECT TOP 1 TimeLocal FROM MessageEvent MEE WITH (NOLOCK) WHERE MEE.MessageId=ME.MessageId AND MEE.EVentType='Sent' AND MEE.ReferenceData='Scheduled'),ReceivedSentTime) AS Seconds
, TeamName
      ,[TimeUtc]
	  ,GatewayId
      ,ReadConfirmedTime
	  ,LanguageId
	  ,[Direction]
	  ,[SubjectField]
      ,[MessageType]
      ,[MessagePhase]
      ,[MessageResult]
      --,[DeliverySystemId]
      ,[FromField]
      ,[RemoteAddress]
      ,[ToField]
      ,[ToCcField]
      --,[ToBccField]
      ,[GatewayId]
      --,[PhoneNumberId]
      ,[ContactId]
      ,[Priority]
      ,[ProjectId]
      ,[Skill]
      ,[PreferredAgentId]
      ,[DraftTime]
      ,[ReadConfirmedTime]
      ,[AcceptedTime]
      ,[AnsweringTime]
      ,[EndTime]
      ,[BodyHtml]
      ,[BodyText]
      ,[ImrScriptAId]
      ,[ImrScriptBId]
      ,[ImrScriptWId]
      ,[ImrResponseA]
      ,[ImrResponseB]
      ,[ImrResponseW]
      ,[QueuePosition]
      ,[QueueLength]
      ,[RelatedMessageId]
      ,[CampaignId]
      ,[ScheduledTime]
      ,[AgentId]
      ,[TeamName]
      ,[Correlation]
      ,[LanguageId]
      ,[Proficiency]
      ,[Eml]
      ,[RoutingDuration]
      ,[WorkDuration]
      ,[OpenDuration]
      ,[NetDuration]
      ,[IssueId]
      ,[Mark]
      ,[SpamLevel]
      ,[SignatureValidity]
      ,[CampaignImportId]
      ,[ExtendedFields]
  FROM [iCC].[dbo].[Message] ME
  WHERE 1=1
   AND MessageId='7592e5c0-6325-e911-8105-f8bc1253a1a4'
   AND Direction='O'
   AND MessageResult='Active'
   AND MessagePhase='Scheduled'
   AND GatewayId ='BCE92B79-8116-493D-856E-5465F21B0E53'
   AND CampaignId IS NULL
   AND CampaignImportId IS NULL
   AND Tofield IS NOT NULL
   AND ScheduledTime IS NULL
   