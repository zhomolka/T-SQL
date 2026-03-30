USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_AgentEvents_Stat]    Script Date: 17. 5. 2021 14:29:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 14.5.2021
-- Description:	Statistika událostí agentů (z AgentEvent)
-- =============================================
CREATE FUNCTION [dbo].[rep_AgentEvents_Stat]
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
	 ,AgentId
	 ,TotalDuration+Duration AS TotalDuration
	 ,Duration
FROM													
(
   SELECT 													
	 GroupingDate
	 , AgentId
	 ,ISNULL(SUM(Duration),0) AS TotalDuration 
	 ,ISNULL(DATEDIFF(ss,(SELECT TOP 1 [TimeLocal] FROM [iCC].[dbo].[AgentEvent] AE2 
	 WHERE AE2.EventType='AgentStatus' AND AE2.Agentid=A.Agentid AND Timelocal>@From
	  ORDER BY Timelocal DESC),GETDATE()),0) AS Duration
														
FROM													
(													
													
SELECT 		-- AgentEvent											
		  dbo.RoundTime(TimeLocal, @RoundInterval) AS GroupingDate
        , AE.AgentId
		, Duration
    FROM [iCC].[dbo].[AgentEvent] AE  
	  INNER JOIN [iCC].[dbo].[Agent] AG ON AE.AgentId=AG.AgentId AND AE.ReferenceId=AG.StatusId
	WHERE EventType='AgentStatus' AND AE.AgentId IS NOT NULL
	 AND AE.TimeLocal >= @From AND AE.TimeLocal <= @To 
	 AND AG.Activity<>'Logoff'
	     
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
group by GroupingDate , AgentId 										
) AS B
												
)




GO

