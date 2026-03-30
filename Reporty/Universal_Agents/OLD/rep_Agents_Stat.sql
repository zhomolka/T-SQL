USE [FS_custom]
GO
/****** Object:  UserDefinedFunction [dbo].[rep_Agents_Stat]    Script Date: 03/14/2019 17:37:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 20.12.2018
-- Description:	Statistika agentů
-- Zbytek výpočtů převzít z Universal_Agents
-- =============================================
ALTER FUNCTION [dbo].[rep_Agents_Stat]
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
	 , NR10
	 , NR11 
	 , NR12
	 , NR13 
	 , NR14


FROM													
(																										
SELECT 		-- Agenti										
		  dbo.RoundTime(AE.Timelocal, @RoundInterval) AS GroupingDate	
        ,AgentId
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceData <> 'Logoff' and Actor <> 'Reset' THEN ISNULL(Duration, 0) ELSE 0 END ) AS LoggedDuration
	    ,MAX(CASE WHEN EventType='AgentStatus' AND ReferenceData = 'Logoff' AND Actor <> 'Reset' THEN TimeLocal ELSE 0 END  ) AS LastLogoffTime
		,SUM(CASE WHEN ReferenceData = 'Ready' and Actor <> 'Reset' THEN ISNULL(Duration, 0) ELSE 0 END ) AS ReadyDuration
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(1)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR1
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(2)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR2
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(3)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR3
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(4)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR4
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(5)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR5
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(6)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR6
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(7)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR7
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(8)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR8
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(9)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR9
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(10)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR10
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(11)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR11
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(12)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR12
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(13)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR13
		,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(14)  THEN ISNULL(Duration, 0) ELSE 0 END ) AS NR14
		
	FROM iCC.dbo.AgentEvent AS AE WITH(NOLOCK)													
	WHERE AE.timelocal >= @From AND AE.timelocal <= @To
	GROUP BY dbo.RoundTime(AE.Timelocal, @RoundInterval), AgentId	 										
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
--group by GroupingDate , AgentId											
/*
NR Statusy mají vypadat takto:
 ,SUM(CASE WHEN EventType='AgentStatus' AND ReferenceId = .dbo.GetStatusId(1) ,ISNULL(Duration, 0),0)) AS NR1
*/
												
)



