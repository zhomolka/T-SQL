USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_CC_Calls_Mails_Stat]    Script Date: 14. 2. 2018 15:51:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 2014-04
-- Description:	Statistiky CC o hovorech a mailech
-- 14.10.2019 Byly zapracovány speciální požadavky Dr.MAX na obsah jednotlivých sloupců
-- Do 31.8.2019 byla pracovní doba 8-17 a od 1.9. 8-19
-- =============================================
CREATE FUNCTION [dbo].[rep_CC_Calls_Mails_Stat]
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

/*
declare @From AS DATETIME = '2013-02-18' 													
declare @To AS DATETIME = '2013-02-25'													
declare	@Roundinterval AS INT = 86400												
*/		
  SELECT *
   --, 1 AS Obsluznost	
   , ROUND(CONVERT(REAL,ConnectedCalls)/CONVERT(REAL,FS_Custom.dbo.IsZero(ConnectedCalls+LostCalls,1)),2) AS Obsluznost	
   , ROUND((CONVERT(REAL,POD20)/CONVERT(REAL,ISNULL(NULLIF(ConnectedCalls,0),1))),2) AS SLA	
    --, ROUND((CONVERT(REAL,InTimeCalls)/CONVERT(REAL,ISNULL(NULLIF(ConnectedCalls+LostCalls,0),1)))/0.9,2) AS SLA	
   --, ROUND((CONVERT(REAL,AnswerTimeLength)/CONVERT(REAL,ISNULL(NULLIF(AnswerCount,0),1))),2) AS AVGAnswer	
   --, ROUND((CONVERT(REAL,ProcessTimeLength)/CONVERT(REAL,ISNULL(NULLIF(ProcessCount,0),1))),2) AS AVGProcess									
FROM													
(													
  SELECT 													
	 GroupingDate
	 ,SUM(ConnectedCalls) AS ConnectedCalls 
	 ,SUM(POD20) AS POD20 
     ,SUM(NAD20) AS NAD20				 

	 ,SUM(LostCalls) AS LostCalls
	 ,SUM(IVRLostCalls) AS IVRLostCalls
	 ,SUM(IVRLostCallsCC) AS IVRLostCallsCC
	 ,SUM(IVRLostCallsLEK) AS IVRLostCallsLEK	 	

	 ,SUM(InTimeCalls) AS InTimeCalls
	 ,SUM(CallDurationIN) AS CallDurationIN

	 ,SUM(ConnectedCallsOUT) AS ConnectedCallsOUT
	 ,SUM(LostCallsOUT) AS LostCallsOUT
	 ,SUM(CallDurationOUT) AS CallDurationOUT

     ,SUM(InCommingEmails) AS InCommingEmails										
	 ,SUM(OutGoingEmails) AS OutGoingEmails											
	 ,SUM(ElaborateEmails) AS ElaborateEmails
	 ,ROUND(AVG(AnswerTimeLength),2) AS AVGAnswerTimeLength
	 ,ROUND(AVG(ProcessTimeLength),2) AS AVGProcessTimeLength
	 ,SUM(AnswerTimeLength) AS AnswerTimeLength
	 ,SUM(ProcessTimeLength) AS ProcessTimeLength
	 ,SUM(AnswerCount) AS AnswerCount
	 ,SUM(ProcessCount) AS ProcessCount

	 ,SUM(SPAMMarked) AS SPAMMarked
	
													
FROM													
(													
													
SELECT 		-- Příchozí hovory	
           --AND FS_Custom.dbo.IsWhiteList2(InboundCallId)=0 										
		  dbo.RoundTime(IC.PilotTime, @RoundInterval) AS GroupingDate
		, FS_Custom.dbo.IsConnected(@From, @To,AnswerTime,TeamName) AS ConnectedCalls  
        , IIF(AnswerTime > @From AND AnswerTime <= @To AND TeamName='CC' AND (isnull(QueueDuration,0)+isnull(RingDuration,0)) > 20,1,0) as NAD20
        , IIF(AnswerTime > @From AND AnswerTime <= @To AND TeamName='CC' AND (isnull(QueueDuration,0)+isnull(RingDuration,0)) <= 20,1,0) as POD20
		    
		, IIF(FS_Custom.[dbo].[IsLost](@From,@To,pilottime,EnqueueingTime,EndTime,CallResult)=1 
		and FS_custom.dbo.IsWhiteList2(IC.InboundCallId)=0
		AND FS_Custom.dbo.IsWorkTime3(IC.InboundCallId,IC.PilotTime)=1 
		,1,0) AS LostCalls 

		--, IIF(EnqueueingTime > @From AND EnqueueingTime <= @To AND EnqueueingTime IS NOT NULL AND AnswerTime IS NULL,1,0) AS LostCalls 
		, IIF(PilotTime > @From AND PilotTime <= @To AND (EnqueueingTime IS NULL OR DATEDIFF(SECOND, EnqueueingTime, EndTime) <= 3)
		,1,0) AS IVRLostCalls 
		, IIF(PilotTime > @From AND PilotTime <= @To AND (EnqueueingTime IS NULL OR DATEDIFF(SECOND, EnqueueingTime, EndTime) <= 3) 
		     AND Redirector LIKE '26%' 
			 ,1,0) AS IVRLostCallsCC 
		, IIF(PilotTime > @From AND PilotTime <= @To AND (EnqueueingTime IS NULL OR DATEDIFF(SECOND, EnqueueingTime, EndTime) <= 3) 
		     AND Redirector LIKE '70%' 
			 AND FS_Custom.dbo.IsWorkTime3(IC.InboundCallId,IC.PilotTime)=1
			 ,1,0) AS IVRLostCallsLEK 
        , IIF(AnswerTime > @From AND AnswerTime <= @To AND TeamName='CC' AND (isnull(QueueDuration,0)+isnull(RingDuration,0)) <= @TimeLimit,1,0) AS InTimeCalls 
		--, IIF(AnswerTime > @From AND AnswerTime <= @To AND DateDiff(ss,EnqueueingTime,AnswerTime)<@TimeLimit AND AnswerTime IS NOT NULL,1,0) AS InTimeCalls 
		, IIF(AnswerTime > @From AND AnswerTime <= @To AND TeamName='CC',CallDuration,0) AS CallDurationIN 	

		, 0 AS ConnectedCallsOUT  
		, 0 AS LostCallsOUT 
		, 0 AS CallDurationOUT 
													
		, 0 AS InCommingEmails											
	    , 0 AS OutGoingEmails											
		, 0 AS ElaborateEmails	
	    , 0 AS AnswerTimeLength
		, 0 AS ProcessTimeLength
		, 0 AS AnswerCount
		, 0 AS ProcessCount

		, 0 AS SPAMMarked						
			FROM icc.dbo.InboundCall AS IC WITH(NOLOCK)										
	--LEFT JOIN icc.dbo.Agent AS A WITH(NOLOCK) ON A.AgentId = IC.AgentId												
	--Left join icc.dbo.Language as L with(nolock) on IC.LanguageId = L.LanguageId												
	--left join icc.dbo.Project as P with(nolock) on IC.ProjectId = P.ProjectId												
	WHERE PilotTime >= DATEADD(Hour,-1,@From) AND PilotTime <= DATEADD(Hour,1,@To) /*and Ic.AgentId is not null and Ic.CallDuration is not null */
	    --and fs_custom.dbo.isWorkTime(PilotTime,'PRACDOBA')=1 -- Pouze hovory v pracovní době
		--and fs_custom.dbo.isHoliday(PilotTime,'SvatkyCZ')=0 -- Svátky ne 
		--and NOT(DATEPART (weekday, PilotTime) IN (1,7))  -- víkendy ne
		--AND FS_CUSTOM.dbo.iSCCCALL(TeamName,ProjectId,CallResult)=1
		--AND ISNULL(TeamName,'') NOT LIKE 'lékár%' -- Hovory lékáren tu nemají být
		--and A.TeamName not like 'lékárny%'
		--and ((IIF(A.TeamName like 'lékárny%',(CONVERT(varchar(12),IC.PilotTime, 108)),'00:00:00') < '19:00:00' ) OR ((IIF(A.TeamName like 'lékárny%',(CONVERT(varchar(12),IC.PilotTime, 108)),'10:00:00') > '08:00:00'  )))
		-- omezení na pracovní dobu lékáren (nakonec lékárny vyřazeny z reportu kompletně)
		 --AND FS_Custom.dbo.IsLekarna(TeamName,ProjectId)=0

									
	UNION ALL											
													
	SELECT 		-- Odchozí hovory										
		  dbo.RoundTime(OC.DistributionTime, @RoundInterval) AS GroupingDate											
		,0 AS ConnectedCalls 
		,0 AS POD20 
        ,0 AS NAD20				 
		,0 AS LostCalls 
		,0 AS IVRLostCalls 
		,0 AS IVRLostCallsCC 
		,0 AS IVRLostCallsLEK
		,0 AS InTimeCalls 
		,0 AS CallDurationIN 		
		
		, IIF(AnswerTime > @From AND AnswerTime <= @To AND AnswerTime IS NOT NULL,1,0) AS ConnectedCallsOUT  
		, IIF(ISNULL(DistributionTime, ScheduleTime) <= @To /*AND EnqueueingTime IS NOT NULL*/ AND AnswerTime IS NULL ,1,0) AS LostCallsOUT -- DistributionTime
		, IIF(AnswerTime > @From AND AnswerTime <= @To AND AnswerTime IS NOT NULL,CallDuration,0) AS CallDurationOUT 

		, 0 AS InCommingEmails											
	    , 0 AS OutGoingEmails											
		, 0 AS ElaborateEmails	
	    , 0 AS AnswerTimeLength
		, 0 AS ProcessTimeLength
		, 0 AS AnswerCount
		, 0 AS ProcessCount

		,0 AS SPAMMarked
			FROM icc.dbo.OutboundCall AS OC WITH(NOLOCK)										
	--LEFT JOIN icc.dbo.Agent AS A WITH(NOLOCK) ON A.AgentId = OC.AgentId												
	--Left join icc.dbo.Language as L with(nolock) on OC.LanguageId = L.LanguageId												
	--left join icc.dbo.Project as P with(nolock) on OC.ProjectId = P.ProjectId												
	WHERE DistributionTime >= @From AND DistributionTime <= @To-- and OC.AgentId is not null and OC.CallDuration is not null		
	--and A.TeamName not like 'lékárny%'
										
union ALL												
SELECT 		-- Maily											
		  dbo.RoundTime(M.ReceivedSentTime, @RoundInterval) AS GroupingDate											
		,0 AS ConnectedCalls  
		,0 AS POD20 
        ,0 AS NAD20				 
		,0 AS LostCalls 
		,0 AS IVRLostCalls 
        ,0 AS IVRLostCallsCC
		,0 AS IVRLostCallsLEK
		,0 AS InTimeCalls 
		,0 AS CallDurationIN 		
		, 0 AS ConnectedCallsOUT  
		, 0 AS LostCallsOUT 
		, 0 AS CallDurationOUT 
	
		, IIF(M.Direction = 'I' AND ReceivedSentTime >= @From ,1,0) AS InCommingEmails											
	    , IIF(M.Direction = 'O' AND ReceivedSentTime >= @From AND M.AgentId IS NOT NULL ,1,0) AS OutGoingEmails											
		--, IIF(M.Direction = 'I' AND ((EndTime >= @To  OR EndTime IS NULL) AND ReceivedSentTime < @To) ,1,0) AS ElaborateEmails -- historické informace
		, IIF(M.Direction = 'I' AND EndTime IS NULL AND ReceivedSentTime < @To ,1,0) AS ElaborateEmails	-- informace v okamžiku tisku
	    , IIF(M.Direction = 'I' AND ISNULL(SpamLevel,0)=0,CONVERT(Real,DATEDIFF(second,ReceivedSentTime,AnsweringTime))/86400,NULL) AS AnswerTimeLength
		, IIF(M.Direction = 'I' AND ISNULL(SpamLevel,0)=0,CONVERT(Real,DATEDIFF(second,ReceivedSentTime,EndTime))/86400,NULL) AS ProcessTimeLength
	    , IIF(M.Direction = 'I' AND ISNULL(SpamLevel,0)=0 AND AnsweringTime IS NOT NULL,1,0) AS AnswerCount
		, IIF(M.Direction = 'I' AND ISNULL(SpamLevel,0)=0 AND EndTime IS NOT NULL,1,0) AS ProcessCount
		,0 AS SPAMMarked	
				FROM icc.dbo.Message AS M WITH(NOLOCK)													
	--LEFT JOIN icc.dbo.Agent AS A WITH(NOLOCK) ON A.AgentId = M.AgentId												
	--Left join icc.dbo.Language as L with(nolock) on M.LanguageId = L.LanguageId												
	--left join icc.dbo.Project as P with(nolock) on M.ProjectId = P.ProjectId	
	--left join icc.dbo.Gateway as GW with(nolock) on M.GatewayId = GW.GatewayId											
	WHERE ReceivedSentTime >= DATEADD(Month,-3,@From) AND ReceivedSentTime <= @To /*and M.AgentId is not null	*/
	  AND MessageType='Email'-- and A.TeamName not like 'lékárny%'											
	
union ALL	-- Události zpráv											
SELECT 	
		  dbo.RoundTime(ME.TimeLocal, @RoundInterval) AS GroupingDate											
		,0 AS ConnectedCalls 
		,0 AS POD20 
        ,0 AS NAD20				 		 
		,0 AS LostCalls 
		,0 AS IVRLostCalls 
		,0 AS IVRLostCallsCC
	    ,0 AS IVRLostCallsLEK
		,0 AS InTimeCalls 
		,0 AS CallDurationIN 		
		, 0 AS ConnectedCallsOUT  
		, 0 AS LostCallsOUT 
		, 0 AS CallDurationOUT 
	    , 0 AS InCommingEmails											
	    , 0 AS OutGoingEmails											
		, 0 AS ElaborateEmails	
	    , 0 AS AnswerTimeLength
		, 0 AS ProcessTimeLength
	    , 0 AS AnswerCount
		, 0 AS ProcessCount
												
		, IIF(EventType='SpamMarked',1,0) AS SPAMMarked										
		--, IIF(EventType='Closing',1,0)  AS ClosedMessage -- 
		--, IIF(EventType='Reading',1,0) AS ReadMailCount
		--, IIF(EventType='Accepting',1,0) AS ReceivedMailCount
			FROM icc.dbo.MessageEvent AS ME WITH(NOLOCK)	
	LEFT JOIN icc.dbo.Message AS M WITH(NOLOCK)	ON M.MessageId = ME.MessageId																									
	--LEFT JOIN icc.dbo.Agent AS A WITH(NOLOCK) ON A.AgentId = ME.AgentId												
--	Left join icc.dbo.Language as L with(nolock) on M.LanguageId = L.LanguageId												
--	left join icc.dbo.Project as P with(nolock) on M.ProjectId = P.ProjectId	
--	left join icc.dbo.Gateway as GW with(nolock) on M.GatewayId = GW.GatewayId											
	WHERE  Timelocal >= @From AND Timelocal <= @To 	
	  AND M.MessageType='Email'	--and A.TeamName not like 'lékárny%'										
		/*	*/												
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
group by GroupingDate /*, AgentId, ProjectName	*/											
) AS B														
)


