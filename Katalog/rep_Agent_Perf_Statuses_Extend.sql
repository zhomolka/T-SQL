USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_Agent_Perf_Statuses_Extend]    Script Date: 17.02.2023 10:43:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17.2.2023>
-- Description:	<Informace o hovorech agentů rozšířené>
-- =============================================

CREATE FUNCTION [dbo].[rep_Agent_Perf_Statuses_Extend]
(	
	@From datetime,
	@To datetime,
	@RoundInterval AS INT,
	@CrewIds AS varchar(4000)
)
RETURNS TABLE 
AS
RETURN 
(
select a.*,CR.CrewNames, ISNULL(InCalls,0)+ISNULL(OutCalls,0) AS Obsazen from fs_custom.dbo.rep_Agent_Perf_Statuses(@From,@To,@RoundInterval) as a
left join FS_custom.dbo.rep_InboundCallsAgents2 (@From,@To,@RoundInterval) IC on IC.AgentId = a.AgentId AND IC.GroupingDate = a.GroupingDate
left join FS_custom.dbo.rep_OutboundCallsAgents2 (@From,@To,@RoundInterval) OC on OC.AgentId = a.AgentId AND OC.GroupingDate = a.GroupingDate
left join
(
 SELECT  AG.[AgentId]	
        ,STUFF((SELECT ' ' + cr.DisplayName 
          FROM icc.dbo.CrewMember AS c
          left join iCC.dbo.Crew as cr on cr.CrewId = c.CrewId
          WHERE c.AgentId = AG.agentid
          FOR XML PATH('')), 1, LEN(SPACE(1)), '') AS CrewNames
  FROM [iCC].[dbo].[Agent] AG
  WHERE Deleted=0 AND Template=0
) AS CR ON a.AgentId=CR.Agentid
INNER JOIN (select DISTINCT Agentid
 FROM [iCC].[dbo].[CrewMember] WHERE CrewId IN 
 (select * from .dbo.String_split_N(@CrewIds,','))
) AS CM ON a.AgentId=CM.Agentid


)



GO

