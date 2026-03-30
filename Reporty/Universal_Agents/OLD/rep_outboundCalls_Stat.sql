USE [FS_custom]
GO
/****** Object:  UserDefinedFunction [dbo].[rep_outboundCalls_Stat]    Script Date: 1/10/2019 4:31:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 10.12.2018
-- Description:	Statistika příchozích hovorů po agentech
-- =============================================
CREATE FUNCTION [dbo].[rep_outboundCalls_Stat]
(	
	@From AS DATETIME, 
	@To AS DATETIME,
	@RoundInterval AS INT,
	@TimeLimit AS INT -- Časový limit pro příjem hovoru
)
RETURNS TABLE 
AS
RETURN 
(
   SELECT 													
	 GroupingDate
	 , AgentId
	 ,SUM(ConnectedCallsOUT) AS ConnectedCallsOUT
	 ,SUM(LostCallsOUT) AS LostCallsOUT
	 ,SUM(CallDurationOUT) AS CallDurationOUT
	 ,AVG(CallDurationOUT) AS CallDurationOUTAVG
														
FROM													
(													
													
	SELECT 		-- Odchozí hovory										
		  dbo.RoundTime(OC.EnqueueingTime, @RoundInterval) AS GroupingDate	
		, AgentId
		, IIF(AnswerTime > @From AND AnswerTime <= @To AND AnswerTime IS NOT NULL,1,0) AS ConnectedCallsOUT  
		, IIF(dialtime > @From AND dialtime <= @To AND dialtime IS NOT NULL AND AnswerTime IS NULL ,1,0) AS LostCallsOUT 
		, IIF(AnswerTime > @From AND AnswerTime <= @To AND AnswerTime IS NOT NULL,CallDuration,NULL) AS CallDurationOUT 
			FROM icc.dbo.OutboundCall AS OC WITH(NOLOCK)										
	WHERE EnqueueingTime >= DATEADD(Hour,-1,@From) AND EnqueueingTime <= DATEADD(Hour,1,@To)-- and OC.AgentId is not null and OC.CallDuration is not null		
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
group by GroupingDate , AgentId/* ProjectName	*/											

												
)



