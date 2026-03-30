USE [FSCUSTOM]
GO
/****** Object:  UserDefinedFunction [dbo].[FreeAgentsForCall]    Script Date: 04/26/2018 11:55:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zbynìk Homolka
-- Create date: 26.4.2018
-- =============================================
ALTER FUNCTION [dbo].[FreeAgentsForCall]
	(
		@CallId as uniqueidentifier,
		@Variant as NVARCHAR(1)
	)
RETURNS int
AS
	BEGIN
     declare @Result as bit	= 0
     DECLARE @Redirector as nvarchar(10) = (SELECT TOP 1 Redirector FROM iCC.dbo.InboundCall WHERE InboundCallId=@CallId)
     DECLARE @LanguageId as UniqueIdentifier = (SELECT TOP 1 LanguageId FROM iCC.dbo.InboundCall WHERE InboundCallId=@CallId)
     DECLARE @ProjectId as uniqueidentifier 
     IF @Variant='P'
       SET @ProjectId = (SELECT TOP 1 ProjectId FROM iCC.dbo.ProjectCondition WHERE Redirector=@Redirector)

	
      IF (SELECT TOP 1 1
			 FROM iCC.dbo.Agent A  WITH (NOLOCK)   
			  INNER JOIN iCC.dbo.Skill  WITH (NOLOCK)
		ON Skill.AgentId=A.AgentId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1 AND Skill.ProjectId=@ProjectId
		  INNER JOIN iCC.dbo.Proficiency PF WITH (NOLOCK)
		ON PF.AgentId=A.AgentId AND Skill.PbxInKnowledge>0 AND Skill.PbxInEnabled=1 AND Skill.PbxInChannel=1 AND PF.LanguageId=@LanguageId
			  INNER JOIN iCC.dbo.Workplace W  WITH (NOLOCK) 
		ON A.WorkplaceId = W.WorkplaceId AND W.State = 'Free'		
			  INNER JOIN iCC.dbo.Status ST  WITH (NOLOCK) 
        ON ST.StatusId=A.StatusId AND ST.Activity = 'Ready'
			 WHERE A.Deleted=0 AND A.Template=0 AND A.Activity='Ready')=1
			 SET @Result = 1	
	RETURN @Result
	END 			 
						
