USE [FS_custom]
GO
/****** Object:  StoredProcedure [dbo].[NewAgent]    Script Date: 7. 11. 2022 14:51:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <29.08.2022>
-- Description:	<Vytváří nového agenta>
-- =============================================
ALTER PROCEDURE [dbo].[NewAgent]
@AgentName NVARCHAR(120)
,@Number  NVARCHAR(16)
AS
BEGIN
  -- Agent table:
  DECLARE @AgentId AS UniqueIdentifier = (SELECT AgentId FROM iCC.dbo.Agent WHERE DisplayName=@AgentName AND Deleted=0)
  DECLARE @SystemName AS NVARCHAR(200)
  DECLARE @Region AS NVARCHAR(2) = SUBSTRING(@AgentName,5,2)
  DECLARE @GroupName AS NVARCHAR(50) = 'lékárny_region_'+@Region
  DECLARE @cLekarny AS NVARCHAR(3) = SUBSTRING(@AgentName,1,3)
  DECLARE @ProjectId AS UniqueIdentifier = (SELECT ProjectId FROM iCC.dbo.Project WHERE DisplayName=@AgentName AND Deleted=0)
  DECLARE @WpName AS NVARCHAR(5) = ISNULL( @Number,'6'+@cLekarny+'1')
  IF @Number IS NULL OR @Number = '' SET @Number=@WpName
  DECLARE @Redirector AS NVARCHAR(5) = '70'+@cLekarny
  DECLARE @LanguageId AS UniqueIdentifier = 'AAE9B56E-C8FC-4CD2-9BAB-1E39E546D092'
  DECLARE @WorkplaceId AS UniqueIdentifier = (SELECT WorkplaceId FROM iCC.dbo.Workplace 
          WHERE DisplayName=@WpName AND Deleted=0)
 IF ISNULL((SELECT TOP 1 1 FROM iCC.dbo.Redirector WHERE DisplayName=@AgentName AND Deleted=0),0)=0
    BEGIN
INSERT INTO iCC.[dbo].[Redirector]
            ([RedirectorId]
           ,[DisplayName]
           ,[Number]
           ,[LanguageId]
           ,[Proficiency]
 )
     VALUES
           (NewId()
           ,LEFT(@AgentName,50)
           ,@Redirector
           ,@LanguageId
           ,1
 )

	END

 IF @WorkplaceId IS NULL
    BEGIN
	  SET @WorkplaceId = NewId()
 INSERT INTO iCC.[dbo].[Workplace]
           ([WorkplaceId]
           ,[DisplayName]
           ,[Number]
           --,[Computer]
           ,[State]
           ,[Offer]
           ,[CtiModel]
           ,[OfferModel]
           ,[LoggedClientModel]
           ,[UsedClientModels]
           ,[MaxRinging]
           ,[MaxOffering]
           ,[Blocking]
           ,[AutoLogoff]
           ,[Deleted]
           ,[ExternalNumber]
           ,[TransferBlockUtc]
           ,[TransferFailedBlocking]
           ,[ExternalState]
           ,[Voice]
           ,[Message]
           ,[Chat]
           ,[BlockPlanning]
           ,[SoftPhoneJson]
           ,[OnLineStatus]
           ,[GroupName]
           ,[Pool])
          SELECT TOP 1
           @WorkplaceId,
            @WpName,
            @Number, 
           --,<Computer, nvarchar(128),>
           State, 
           Offer, 
           CtiModel,
           OfferModel,
           LoggedClientModel, 
           UsedClientModels, 
           MaxRinging,
           MaxOffering,
           Blocking,
           AutoLogoff, 
           Deleted, 
           ExternalNumber, 
           TransferBlockUtc, 
           TransferFailedBlocking, 
           ExternalState, 
           Voice, 
           Message, 
           Chat, 
           BlockPlanning,
           SoftPhoneJson, 
           0, 
           GroupName, 
           Pool 
    FROM [iCC].[dbo].[Workplace] WHERE Number<@Number  AND Deleted=0
    ORDER BY Number DESC	

	END
IF @AgentId IS NULL
 BEGIN
   SET @AgentId=NewId()
   SET @SystemName='cz11w90008ap01p\region'+@Region+'.'+SUBSTRING(@AgentName,1,3)
   INSERT INTO iCC.[dbo].[Agent]
           ([AgentId]
           ,[SystemName]
           ,[DisplayName]
		   ,[TeamName]
           ,[GroupName]
           ,[Supervisor]
           ,[Activity]
           ,[StatusId]
           ,[WorkplaceId]
           ,[ReturnMessagesOnLogoff]
           ,[ReturnTasksOnLogoff]
           ,[PbxInCount]
           ,[PbxInConsumption]
           ,[EmailCount]
           ,[EmailConsumption]
           ,[SmsCount]
           ,[SmsConsumption]
           ,[FaxCount]
           ,[FaxConsumption]
           ,[BusinessIMCount]
           ,[BusinessIMConsumption]
           ,[SocialWallCount]
           ,[SocialWallConsumption]
           ,[SocialIMCount]
           ,[SocialIMConsumption]
           ,[SocialMsgCount]
           ,[SocialMsgConsumption]
           ,[WebIMCount]
           ,[WebIMConsumption]
           ,[PbxOutCount]
           ,[PbxOutConsumption]
           ,[VisitorCount]
           ,[VisitorConsumption]
           ,[TaskCount]
           ,[TaskConsumption]
           ,[Template]
           ,[MaxMissedCalls]
           ,[MaxSignalDuration]
           ,[ActiveCallBlocksChat]
           ,[GdprArchiver]
           ,[GdprMaster]
           ,[UsePersonalPcp]
           ,[BusyConditionId]
             )
     VALUES
           (@AgentId
           ,@SystemName
           ,@AgentName
           ,'lékárny'
           ,@GroupName
           ,0
           ,'Ready'           
           ,'60FBA1E2-08F0-4129-97B3-3041E9EE27B8'
           ,@WorkplaceId
           ,1
           ,0
           ,0
           ,0
           ,0
           ,101
           ,0
           ,100
           ,0
           ,100
           ,0
           ,100
           ,0
           ,0
           ,0
           ,100
           ,0
           ,0
           ,0
           ,100
           ,0
           ,0
           ,0
           ,0
           ,0
           ,100
           ,0
           ,3
           ,60
           ,0
           ,0
           ,0
           ,0
           ,'BAE94699-A432-4972-8AE0-B795D3C5FBEF'
 )
  END
   IF ISNULL((SELECT TOP 1 1 FROM iCC.dbo.Seating WHERE AgentId=@AgentId AND WorkplaceId=@WorkplaceId),0)=0
    BEGIN
INSERT INTO iCC.[dbo].[Seating]
           ([SeatingId]
           ,[AgentId]
           ,[WorkplaceId]
           ,[KnowledgeOffset]
           ,[LoginClientModels]
           ,[UseClientModels]
)
     VALUES
           (NewId()
           ,@AgentId
           ,@WorkplaceId
           ,0
           ,'WebCaller;WebClient'
           ,'WebCaller;WebClient'
)
	END
 IF ISNULL((SELECT TOP 1 1 FROM iCC.dbo.Proficiency WHERE AgentId=@AgentId),0)=0
    BEGIN
INSERT INTO iCC.[dbo].[Proficiency]
           ([ProficiencyId]
           ,[AgentId]
           ,[LanguageId]
           ,[VoiceKnowledge]
           ,[VoiceEnabled]
           ,[VoiceChannel]
           ,[MessageKnowledge]
           ,[MessageEnabled]
           ,[MessageChannel]
           ,[ChatKnowledge]
           ,[ChatEnabled]
           ,[ChatChannel])
     VALUES
           (NewId()
           ,@AgentId
           ,@LanguageId
           ,100
           ,1
           ,1
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0

)
	END

  IF @ProjectId IS NULL --RETURN --===============>>>>>>>>>>>>>>>>
    BEGIN
	  SET @ProjectId=NewId()
      INSERT INTO iCC.[dbo].[Project]
           ([ProjectId]
           ,[DisplayName]
           ,ProjectGroupName
           ,ProjectTypeName
           ,Description
           ,WaitingOffset
           ,[EmailTimeOffset]
           ,[SmsTimeOffset]
           ,[FaxTimeOffset]
		  ,[NormalCallDuration]
		  ,[WarnCallDuration]
		  ,[AlarmCallDuration]
		  ,[ManualDispatch]
		  ,[BusinessIMTimeOffset]
		  ,[SocialIMTimeOffset]
		  ,[WebIMTimeOffset]
		  ,[TaskTimeOffset]
		  ,[PbxInDistribute]
		  ,[PbxOutDistribute]
		  ,[MessageDistribute]
		  ,[TaskDistribute]
		  ,[IMDistribute]

           )
     SELECT TOP 1
       @ProjectId AS ProjectId
	  ,@AgentName AS DisplayName
      ,ProjectGroupName
	  ,ProjectTypeName
	  ,@Redirector
      ,WaitingOffset
      ,[EmailTimeOffset]
      ,[SmsTimeOffset]
      ,[FaxTimeOffset]
      ,[NormalCallDuration]
      ,[WarnCallDuration]
      ,[AlarmCallDuration]
      ,[ManualDispatch]
      ,[BusinessIMTimeOffset]
      ,[SocialIMTimeOffset]
      ,[WebIMTimeOffset]
      ,[TaskTimeOffset]
      ,[PbxInDistribute]
      ,[PbxOutDistribute]
      ,[MessageDistribute]
      ,[TaskDistribute]
      ,[IMDistribute]
       
    FROM [iCC].[dbo].[Project] WHERE Projectgroupname='Lékárny' AND Deleted=0
    ORDER BY DisplayName DESC	
  END

  IF ISNULL((SELECT TOP 1 1 FROM iCC.dbo.Skill WHERE AgentId=@AgentId AND ProjectId=@ProjectId),0)=0
    BEGIN
	INSERT INTO iCC.[dbo].[Skill]
           ([SkillId]
           ,[AgentId]
           ,[ProjectId]
           ,[PbxInKnowledge]
           ,[PbxInEnabled]
           ,[PbxInChannel]
           ,[EmailKnowledge]
           ,[EmailEnabled]
           ,[EmailChannel]
           ,[SmsKnowledge]
           ,[SmsEnabled]
           ,[SmsChannel]
           ,[FaxKnowledge]
           ,[FaxEnabled]
           ,[FaxChannel]
           ,[BusinessIMKnowledge]
           ,[BusinessIMEnabled]
           ,[BusinessIMChannel]
           ,[SocialWallKnowledge]
           ,[SocialWallEnabled]
           ,[SocialWallChannel]
           ,[SocialIMKnowledge]
           ,[SocialIMEnabled]
           ,[SocialIMChannel]
           ,[SocialMsgKnowledge]
           ,[SocialMsgEnabled]
           ,[SocialMsgChannel]
           ,[WebIMKnowledge]
           ,[WebIMEnabled]
           ,[WebIMChannel]
           ,[PbxOutKnowledge]
           ,[PbxOutEnabled]
           ,[PbxOutChannel]
           ,[VisitorKnowledge]
           ,[VisitorEnabled]
           ,[VisitorChannel]
           ,[TaskKnowledge]
           ,[TaskEnabled]
           ,[TaskChannel])
     VALUES
           (NewId()
           ,@AgentId
           ,@ProjectId
           ,100
           ,1
           ,1
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
)
	END



IF ISNULL((SELECT TOP 1 1 FROM iCC.dbo.[ProjectCondition] WHERE ProjectId=@ProjectId ),0)=0
    BEGIN
INSERT INTO iCC.[dbo].[ProjectCondition]
           ([ProjectConditionId]
           ,[DisplayName]
           ,[Rank]
           ,[ProjectId]
           ,[Skill]
		   ,Redirector
           ,[IvrResponseA])
     SELECT TOP 1
       NewId() AS ProjectConditionId
	  ,@AgentName AS DisplayName
      ,Rank+1 AS Rank
	  ,@ProjectId AS ProjectId
      ,[Skill]
	  ,@Redirector
      ,[IvrResponseA]
    FROM [iCC].[dbo].[ProjectCondition] WHERE IvrResponseA='LEKARNY'  --AND Deleted=0
    ORDER BY Rank DESC	
  END
END


