USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[SkillChange]    Script Date: 2/5/2020 5:17:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jiří Stejskal
-- Create date: 8.3.2019
-- Description: Měnění skillů podle pracoviště
-- =============================================
CREATE PROCEDURE [dbo].[SkillChange]
@MeAgentId uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @workplaceid uniqueidentifier=(select WorkplaceId from icc.dbo.agent where agentid=@meagentid)
declare @TeamName nvarchar(max)=(select TeamName from icc.dbo.agent where agentid=@meagentid)
If @TeamName in ('Broadcast','Security','Securita','Výluky')
		begin


		declare @WorkplaceDesc nvarchar(max)=(select DisplayName from icc.dbo.Workplace where WorkplaceId=@workplaceid)
		declare @SecuritaTemp uniqueidentifier = 'E160270F-7609-4976-A3A6-95246F262017'
		declare @BroadcastTemp uniqueidentifier ='79908E50-3DB4-447C-B56A-D49CDA4B4A0F'
		declare @VylukyTemp uniqueidentifier = '01508EB8-E82C-47E9-A471-06BF0E1130C1'

			if @WorkplaceDesc like '%výluky%'
				begin 
					delete  from icc.dbo.Skill where agentid =@meagentid
								
								Insert into icc.dbo.Skill ( AgentId
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
								SELECT  
										   @MeAgentId
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
										  ,[TaskChannel]
									  FROM [iCC].[dbo].[Skill] where AgentId=@VylukyTemp
					
				
				end


			if @WorkplaceDesc like '%securita%' or @WorkplaceDesc like '%security%'
				begin 
					delete  from icc.dbo.Skill where agentid =@meagentid
								Insert into icc.dbo.Skill( AgentId
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
								SELECT  
										   @MeAgentId
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
										  ,[TaskChannel]
									  FROM [iCC].[dbo].[Skill] where AgentId=@SecuritaTemp
				end



			if @WorkplaceDesc like '%broadcast%'
				begin 
					delete  from icc.dbo.Skill where agentid =@meagentid
								Insert into icc.dbo.Skill( AgentId
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
								SELECT  
										   @MeAgentId
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
										  ,[TaskChannel]
									  FROM [iCC].[dbo].[Skill] where AgentId=@BroadcastTemp
				end


		

end


END
GO

