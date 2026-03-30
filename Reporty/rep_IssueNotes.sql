USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_IssueNotes]    Script Date: 9. 3. 2018 9:27:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2018-03-09
-- Description:	Zobrazuje poznámky k případům 
-- =============================================
CREATE FUNCTION [dbo].[rep_IssueNotes] (@from datetime,@to datetime)
RETURNS TABLE
AS
RETURN
(
-- VE FRONTĚ
select 
ISU.IssueId
,AG.displayname as AgentName
,(SELECT COUNT(1) FROM iCC.dbo.Message ME WITH (NOLOCK) WHERE ISU.IssueId=ME.IssueId AND MessageType='Note' AND ME.AgentId=ISU.AgentId) AS NotesCount
,PROJ.DisplayName AS Project
--,PHAS.DisplayName AS Phase
,TOC.DisplayName AS Topic
,SUBTOC.DisplayName AS SubTopic
,'http://frontstageht/ReactClient/Pages/Issueeditor.html?Id='+CONVERT(VARCHAR(36),ISU.IssueId) AS URL

from 
icc.dbo.issue ISU with(nolock)

--left join icc.dbo.IssueExtra IE with(nolock) on ie.Issueid=ISU.IssueId
left join icc.dbo.agent AG with(nolock) on AG.agentid=ISU.agentid 
left join icc.dbo.Topic TOC with(nolock) on TOC.Topicid=ISU.TopicId
left join icc.dbo.SubTopic SUBTOC with(nolock) on SUBTOC.SubTopicid=ISU.SubTopicId
left join icc.dbo.Project PROJ with(nolock) on Proj.ProjectId=ISU.ProjectId
--left join icc.dbo.Phase PHAS with(nolock) on PHAS.PhaseId=ISU.PhaseId

where convert(date,ISU.Newtime)>=convert(date,@from) and convert(date,ISU.Newtime)<=convert(date,@to)
 AND EXISTS(SELECT TOP 1 1 FROM iCC.dbo.Message ME WITH (NOLOCK) WHERE ISU.IssueId=ME.IssueId AND MessageType='Note' AND ME.AgentId=ISU.AgentId)
 )




GO

