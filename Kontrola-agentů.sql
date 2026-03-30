USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[AgentsOfflineProject]    Script Date: 8. 11. 2017 16:58:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:  Jan Techl
-- Create date: 27.7.2017
-- Description:     IVR check, whether any agents with skills for particular project project are logged on
-- =============================================
CREATE PROCEDURE [dbo].[AgentsOfflineProject]

@project uniqueidentifier

AS
BEGIN
       SET NOCOUNT ON;

--declare @project as uniqueidentifier = '222b7323-41a9-4c4c-8e40-a596ec70e936'

declare @AgentOnline as int = (select count(a.agentid) from icc.dbo.Agent a left join icc.dbo.Skill s on a.AgentId = s.AgentId left join icc.dbo.workplace wp on a.WorkplaceId = wp.WorkplaceId where s.ProjectId = @project and s.PbxInChannel = 1 and a.Activity = 'Ready' and wp.State = 'Free')

if(@AgentOnline<>0) RETURN

SELECT 'A' as IVR_AgentsOffline

END


GO





