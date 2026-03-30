USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_inboundCalls_Stat]    Script Date: 03/14/2019 10:50:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 10.12.2018
-- Description:	Statistika příchozích hovorů po agentech
-- =============================================
CREATE FUNCTION [dbo].[rep_inboundCalls_Stat]
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
	 ,SUM(TransferedINCalls) AS TransferedINCalls 
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
		, CASE WHEN PilotTime > @From AND PilotTime <= @To THEN 1 ELSE 0 END  AS EnteredCalls  
		, CASE WHEN AnswerTime > @From AND AnswerTime <= @To THEN 1 ELSE 0 END  AS ConnectedCalls  
		, CASE WHEN AnswerTime > @From AND AnswerTime <= @To AND ChainingId IS NOT NULL THEN 1 ELSE 0 END  AS TransferedINCalls 
		, CASE WHEN AnswerTime > @From AND AnswerTime <= @To THEN RingDuration ELSE 0 END  AS RingingTime  -- U spojených hovorů
		, CASE WHEN PilotTime > @From AND PilotTime <= @To AND AnswerTime IS NULL THEN 1 ELSE 0 END  AS LostCalls 
		, CASE WHEN PilotTime > @From AND PilotTime <= @To AND EnqueueingTime IS NULL THEN 1 ELSE 0 END  AS IVRLostCalls 
		, CASE WHEN AnswerTime > @From AND AnswerTime <= @To AND DateDiff(ss,EnqueueingTime,AnswerTime)<@TimeLimit AND AnswerTime IS NOT NULL THEN 1  ELSE 0 END  AS InTimeCalls 
		, CASE WHEN AnswerTime > @From AND AnswerTime <= @To THEN CallDuration ELSE 0 END  AS CallDurationIN 	
			FROM icc.dbo.InboundCall AS IC WITH(NOLOCK)										
	WHERE PilotTime >= DATEADD(Hour,-1,@From) AND PilotTime <= DATEADD(Hour,1,@To) /*and Ic.AgentId is not null and Ic.CallDuration is not null */
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
group by GroupingDate , AgentId/* ProjectName	*/											

												
)




GO

