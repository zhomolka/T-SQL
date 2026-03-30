USE [FS_custom]
GO
/****** Object:  UserDefinedFunction [dbo].[rep_Agents_Stat_H]    Script Date: 2019. 10. 11. 9:37:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 04.09.2019
-- Description:	Statistika agentů
-- =============================================
CREATE FUNCTION [dbo].[rep_Agents_Stat]
(	
	@From AS DATETIME, 
	@To AS DATETIME,
	@RoundInterval AS INT
)
RETURNS TABLE 
AS
RETURN 
(
   SELECT 													
	 GroupingDate
	 , AgentId
	 , .dbo.GetFirstLogonTime(AgentId, GroupingDate) AS FirstLoginTime
	 , LastLogoffTime
	 , LoggedDuration	
	 , ReadyDuration	
	 , (LoggedDuration-ReadyDuration) AS NotReadyDuration	
	 , NR1											
	 , NR2
	 , NR3
	 , NR4
	 , NR5
	 , NR6
	 , NR7
	 , NR8
	 , NR9
	 , RD1
	 , RD2
	 , LO1
	 , LO2

FROM													
(																										
SELECT 		-- Agenti										
		  dbo.RoundTime(AE.Timelocal, @RoundInterval) AS GroupingDate	
        ,AgentId
		,SUM(IIF(EventType='AgentStatus' AND ReferenceData <> 'Logoff' and Actor <> 'Reset',ISNULL(Duration, 0),0)) AS LoggedDuration
	    ,MAX(IIF(EventType='AgentStatus' AND ReferenceData = 'Logoff' AND Actor <> 'Reset',TimeLocal,0) ) AS LastLogoffTime
		,SUM(IIF(ReferenceData = 'Ready' and Actor <> 'Reset',ISNULL(Duration, 0),0)) AS ReadyDuration
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(1,'NR') ,ISNULL(Duration, 0),0)) AS NR1
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(2,'NR') ,ISNULL(Duration, 0),0)) AS NR2
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(3,'NR') ,ISNULL(Duration, 0),0)) AS NR3
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(4,'NR') ,ISNULL(Duration, 0),0)) AS NR4
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(5,'NR') ,ISNULL(Duration, 0),0)) AS NR5
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(6,'NR') ,ISNULL(Duration, 0),0)) AS NR6
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(7,'NR') ,ISNULL(Duration, 0),0)) AS NR7
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(8,'NR') ,ISNULL(Duration, 0),0)) AS NR8
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(9,'NR') ,ISNULL(Duration, 0),0)) AS NR9
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(1,'RD') ,ISNULL(Duration, 0),0)) AS RD1
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(2,'RD') ,ISNULL(Duration, 0),0)) AS RD2
        ,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(1,'LO') ,ISNULL(Duration, 0),0)) AS LO1
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId3(2,'LO') ,ISNULL(Duration, 0),0)) AS LO2

	FROM iCC.dbo.AgentEvent AS AE WITH(NOLOCK)													
	WHERE AE.timelocal >= @From AND AE.timelocal <= @To
	GROUP BY dbo.RoundTime(AE.Timelocal, @RoundInterval), AgentId	 										
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
--group by GroupingDate , AgentId											
/*
NR Statusy mají vypadat takto:
 ,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(1) ,ISNULL(Duration, 0),0)) AS NR1
*/
												
)



IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(7) ,ISNULL(Duration, 0),0)) AS NR7
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(8) ,ISNULL(Duration, 0),0)) AS NR8
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(9) ,ISNULL(Duration, 0),0)) AS NR9
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId2(1,'Ready') ,ISNULL(Duration, 0),0)) AS RD1
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId2(2,'Ready') ,ISNULL(Duration, 0),0)) AS RD2
        ,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId2(1,'Logoff') ,ISNULL(Duration, 0),0)) AS LO1
		,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId2(2,'Logoff') ,ISNULL(Duration, 0),0)) AS LO2

	FROM iCC.dbo.AgentEvent AS AE WITH(NOLOCK)													
	WHERE AE.timelocal >= @From AND AE.timelocal <= @To
	GROUP BY dbo.RoundTime(AE.Timelocal, @RoundInterval), AgentId	 										
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
--group by GroupingDate , AgentId											
/*
NR Statusy mají vypadat takto:
 ,SUM(IIF(EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(1) ,ISNULL(Duration, 0),0)) AS NR1
*/
												
)



