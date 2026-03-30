USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_Emails_Stat]    Script Date: 1/4/2019 2:32:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 10.12.2018
-- Description:	Statistika příchozích hovorů po agentech
-- =============================================
CREATE FUNCTION [dbo].[rep_Emails_Stat]
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
	 ,SUM(EnteredCalls) AS EnteredCalls 
	 ,SUM(ConnectedCalls) AS ConnectedCalls
	 ,SUM(RingingTime) AS RingingTime  
	 ,AVG(RingingTime) AS RingingTimeAVG 
	 ,SUM(LostCalls) AS LostCalls
	 ,SUM(IVRLostCalls) AS IVRLostCalls
	 ,SUM(InTimeCalls) AS InTimeCalls
	 ,SUM(CallDurationIN) AS CallDurationIN
	 ,AVG(CallDurationIN) AS CallDurationINAVG

														
FROM													
(													
													
SELECT 		-- Příchozí hovory											
		  dbo.RoundTime(IC.PilotTime, @RoundInterval) AS GroupingDate
        , AgentId
		, IIF(PilotTime > @From AND PilotTime <= @To,1,0) AS EnteredCalls  
		, IIF(AnswerTime > @From AND AnswerTime <= @To,1,0) AS ConnectedCalls  
		, IIF(AnswerTime > @From AND AnswerTime <= @To,RingDuration,0) AS RingingTime  -- U spojených hovorů
		, IIF(PilotTime > @From AND PilotTime <= @To AND AnswerTime IS NULL ,1,0) AS LostCalls 
		, IIF(PilotTime > @From AND PilotTime <= @To AND EnqueueingTime IS NULL,1,0) AS IVRLostCalls 
		, IIF(AnswerTime > @From AND AnswerTime <= @To AND DateDiff(ss,EnqueueingTime,AnswerTime)<@TimeLimit AND AnswerTime IS NOT NULL,1,0) AS InTimeCalls 
		, IIF(AnswerTime > @From AND AnswerTime <= @To,CallDuration,0) AS CallDurationIN 	
			FROM icc.dbo.InboundCall AS IC WITH(NOLOCK)										
	WHERE PilotTime >= DATEADD(Hour,-1,@From) AND PilotTime <= DATEADD(Hour,1,@To) /*and Ic.AgentId is not null and Ic.CallDuration is not null */
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
group by GroupingDate , AgentId/* ProjectName	*/											

												
)



GO

