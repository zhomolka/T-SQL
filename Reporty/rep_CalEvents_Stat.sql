USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_CalEvents_Stat]    Script Date: 5. 5. 2022 11:45:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 5.5.2022
-- Description:	Statistika událostí hovorů po agentech
-- =============================================
CREATE FUNCTION [dbo].[rep_CalEvents_Stat]
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
	 ,SUM(LostCallsAG) AS LostCallsAG 

														
FROM													
(													
													
SELECT 		-- Příchozí hovory											
		  dbo.RoundTime(TimeLocal, @RoundInterval) AS GroupingDate
        , AgentId
		, 1  AS LostCallsAG
		FROM [iCC].[dbo].[CallEvent] AS CAE WITH(NOLOCK)										
	WHERE EventType='AgentMissed' AND TimeLocal >= @From AND TimeLocal <= @To /*and Ic.AgentId is not null and Ic.CallDuration is not null */
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
group by GroupingDate , AgentId/* ProjectName	*/											

												
)





GO

