USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_CalEvents_Stat]    Script Date: 1/4/2019 2:34:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 3.1.2019
-- Description:	Statistika přepojených hovorů (z CalEvent)
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
	 ,SUM(TransferedOUTCalls) AS TransferedOUTCalls 

														
FROM													
(													
													
SELECT 		-- CalEvent											
		  dbo.RoundTime(IC.PilotTime, @RoundInterval) AS GroupingDate
        , CAE.AgentId
		, IIF(PilotTime > @From AND PilotTime <= @To,1,0) AS TransferedOUTCalls 
    FROM [iCC].[dbo].[CallEvent] CAE     
	 LEFT JOIN [iCC].[dbo].[InboundCall] IC ON CAE.InboundCallId=IC.InboundCallId 
	WHERE CAE.TimeLocal >= @From AND CAE.TimeLocal <= @To 
		 AND CAE.ResultData='TransferedRelease'
	     AND IC.AgentId IS NOT NULL
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
group by GroupingDate , AgentId /* ProjectName	*/											

												
)



GO

