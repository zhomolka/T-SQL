USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_CC_Calls_Mails_Stat]    Script Date: 9. 3. 2018 13:25:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 2018-01-30
-- Description:	Statistiky CC o hovorech a mailech
-- =============================================
CREATE FUNCTION [dbo].[rep_CC_Calls_Mails_Stat]
(	
	@From AS DATETIME, 
	@To AS DATETIME,
	@RoundInterval AS INT,
	@TimeLimit AS INT, -- Časový limit pro příjem hovoru
	@ProjectFilter AS NVARCHAR(50)
)
RETURNS TABLE 
AS
RETURN 
(

/*  Toto nedávalo smysl, protože tady stejně nespočítám údaje za skupiny a celý report
 SELECT *
   --, 1 AS Obsluznost	
   --   T
   , ROUND(CONVERT(REAL,ConnectedCalls)/CONVERT(REAL,IIF(ConnectedCalls+LostCalls=0,1,ConnectedCalls+LostCalls)),2) AS Obsluznost	
   , ROUND((CONVERT(REAL,InTimeCalls)/CONVERT(REAL,ISNULL(NULLIF(ConnectedCalls+LostCalls,0),1)))/0.9,2) AS SLA	
   --, ROUND((CONVERT(REAL,AnswerTimeLength)/CONVERT(REAL,ISNULL(NULLIF(AnswerCount,0),1))),2) AS AVGAnswer	
   --, ROUND((CONVERT(REAL,ProcessTimeLength)/CONVERT(REAL,ISNULL(NULLIF(ProcessCount,0),1))),2) AS AVGProcess									
FROM													
(	*/												
  SELECT 													
	 GroupingDate
	 ,SUM(ConnectedCalls) AS ConnectedCalls 
	 ,SUM(LostCalls) AS LostCalls
	 ,SUM(IVRLostCalls) AS IVRLostCalls
	 ,SUM(InTimeCalls) AS InTimeCalls
	 ,SUM(CallDurationIN) AS CallDurationIN
	 ,SUM(Offered) AS Offered
	 ,SUM(AbandOffered) AS AbandOffered
	 ,SUM(HandledByAgents) AS HandledByAgents
	 ,SUM(ConnectedCallsOUT) AS ConnectedCallsOUT
	 ,SUM(LostCallsOUT) AS LostCallsOUT
	 ,SUM(CallDurationOUT) AS CallDurationOUT

     ,SUM(InCommingEmails) AS InCommingEmails										
	 ,SUM(OutGoingEmails) AS OutGoingEmails	
	 ,SUM(OutGoingSMSes) AS OutGoingSMSes		 
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
		  dbo.RoundTime(IC.PilotTime, @RoundInterval) AS GroupingDate
		, IIF(AnswerTime > @From AND AnswerTime <= @To,1,0) AS ConnectedCalls  
		, IIF(EnqueueingTime > @From AND EnqueueingTime <= @To AND EnqueueingTime IS NOT NULL AND AnswerTime IS NULL
		 AND FS_Custom.dbo.TimeCompare2(EnqueueingTime,'>',(SELECT TOP 1 TimeFrom FROM [iCC].[dbo].[Holiday] WHERE HolidayGroupName='PRACSALONELITE'))=1 
		 AND FS_Custom.dbo.TimeCompare2(EnqueueingTime,'<',(SELECT TOP 1 TimeTo   FROM [iCC].[dbo].[Holiday] WHERE HolidayGroupName='PRACSALONELITE'))=1
		 ,1,0) AS LostCalls 
		, IIF(PilotTime > @From AND PilotTime <= @To AND EnqueueingTime IS NULL,1,0) AS IVRLostCalls 
		--, IIF(AnswerTime > @From AND AnswerTime <= @To AND DateDiff(ss,EnqueueingTime,AnswerTime)<@TimeLimit AND AnswerTime IS NOT NULL,1,0) AS InTimeCalls -- Dr.MAX
		, IIF(IC.EnqueueingTime >= @FROM AND IC.EnqueueingTime <=@TO AND CallResult = 'Served' AND ISNULL(QueueDuration,0)<@TimeLimit, 1, 0) AS InTimeCalls -- SLABase -- ČSA
		, IIF(AnswerTime > @From AND AnswerTime <= @To,CallDuration,0) AS CallDurationIN 
		, IIF(IC.EnqueueingTime >= @FROM AND IC.EnqueueingTime <=@TO AND (EnqueueingTime IS NOT NULL OR DistributionTime IS NOT NULL), 1, 0) AS Offered
		, IIF(IC.EnqueueingTime >= @FROM AND IC.EnqueueingTime <=@TO AND CallResult = 'Lost' AND QueueDuration > 10 /* @TimeLimit*/ /* @CallLengthTreshold */, 1, 0) AS AbandOffered -- ČSA
		, IIF(IC.EnqueueingTime >= @FROM AND IC.EnqueueingTime <=@TO AND CallResult <> 'Lost' , 1, 0) AS HandledByAgents /* Nejsem si úplně jist, zda je to stejné jako Served - poslední stav je už pouze Active */


		, 0 AS ConnectedCallsOUT  
		, 0 AS LostCallsOUT 
		, 0 AS CallDurationOUT 
													
		, 0 AS InCommingEmails											
	    , 0 AS OutGoingEmails
		, 0 AS OutGoingSMSes											
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
	WHERE PilotTime >= DATEADD(Hour,-1,@From) AND PilotTime <= DATEADD(Hour,1,@To) 
	AND ProjectId IN (SELECT * FROM [FS_custom].dbo.[Return_Ids](@ProjectFilter))
	AND IC.CallPhase NOT IN ('IvrScriptA', 'Pilot') AND NOT EXISTS (SELECT TOP 1 1 FROM icc.dbo.InboundCall WITH (NOLOCK) WHERE ChainingId = IC.InboundCallId) -- Filtr ČSA
	/*and Ic.AgentId is not null and Ic.CallDuration is not null */
											
	UNION ALL											
													
	SELECT 		-- Odchozí hovory										
		  dbo.RoundTime(OC.EnqueueingTime, @RoundInterval) AS GroupingDate											
		,0 AS ConnectedCalls  
		,0 AS LostCalls 
		,0 AS IVRLostCalls 
		,0 AS InTimeCalls 
		,0 AS CallDurationIN 		
	    ,0 AS Offered 
		,0 AS AbandOffered 
		,0 AS HandledByAgents 	
	
		
		, IIF(AnswerTime > @From AND AnswerTime <= @To AND AnswerTime IS NOT NULL,1,0) AS ConnectedCallsOUT  
		, IIF(EnqueueingTime > @From AND EnqueueingTime <= @To AND EnqueueingTime IS NOT NULL AND AnswerTime IS NULL ,1,0) AS LostCallsOUT 
		, IIF(AnswerTime > @From AND AnswerTime <= @To AND AnswerTime IS NOT NULL,CallDuration,0) AS CallDurationOUT 

		, 0 AS InCommingEmails											
	    , 0 AS OutGoingEmails
		, 0 AS OutGoingSMSes											
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
	WHERE EnqueueingTime >= DATEADD(Hour,-1,@From) AND EnqueueingTime <= DATEADD(Hour,1,@To)
		AND ProjectId IN (SELECT * FROM [FS_custom].dbo.[Return_Ids](@ProjectFilter))
	-- and OC.AgentId is not null and OC.CallDuration is not null		
	
										
union ALL												
SELECT 		-- Maily											
		  dbo.RoundTime(M.ReceivedSentTime, @RoundInterval) AS GroupingDate											
		,0 AS ConnectedCalls  
		,0 AS LostCalls 
		,0 AS IVRLostCalls 
		,0 AS InTimeCalls 
		,0 AS CallDurationIN 		
		, 0 AS ConnectedCallsOUT  
		, 0 AS LostCallsOUT 
		, 0 AS CallDurationOUT 
	    ,0 AS Offered 
		,0 AS AbandOffered 
		,0 AS HandledByAgents 		

		, IIF(M.Direction = 'I' AND MessageType='Email' AND ReceivedSentTime >= @From ,1,0) AS InCommingEmails											
	    , IIF(M.Direction = 'O' AND MessageType='Email' AND ReceivedSentTime >= @From AND AgentId IS NOT NULL ,1,0) AS OutGoingEmails
        , IIF(M.Direction = 'O' AND MessageType='SMS' AND ReceivedSentTime >= @From AND AgentId IS NOT NULL ,1,0) AS OutGoingSMSes											
		--, IIF(M.Direction = 'I'AND MessageType='Email' AND ((EndTime >= @To  OR EndTime IS NULL) AND ReceivedSentTime < @To) ,1,0) AS ElaborateEmails -- historické informace
		, IIF(M.Direction = 'I' AND MessageType='Email' AND EndTime IS NULL AND ReceivedSentTime < @To ,1,0) AS ElaborateEmails	-- informace v okamžiku tisku
	    , IIF(M.Direction = 'I' AND MessageType='Email' AND ISNULL(SpamLevel,0)=0,CONVERT(Real,DATEDIFF(second,ReceivedSentTime,AnsweringTime))/86400,NULL) AS AnswerTimeLength
		, IIF(M.Direction = 'I' AND MessageType='Email' AND ISNULL(SpamLevel,0)=0,CONVERT(Real,DATEDIFF(second,ReceivedSentTime,EndTime))/86400,NULL) AS ProcessTimeLength
	    , IIF(M.Direction = 'I' AND MessageType='Email' AND ISNULL(SpamLevel,0)=0 AND AnsweringTime IS NOT NULL,1,0) AS AnswerCount
		, IIF(M.Direction = 'I' AND MessageType='Email' AND ISNULL(SpamLevel,0)=0 AND EndTime IS NOT NULL,1,0) AS ProcessCount
		,0 AS SPAMMarked	
				FROM icc.dbo.Message AS M WITH(NOLOCK)													
	--LEFT JOIN icc.dbo.Agent AS A WITH(NOLOCK) ON A.AgentId = M.AgentId												
	--Left join icc.dbo.Language as L with(nolock) on M.LanguageId = L.LanguageId												
	--left join icc.dbo.Project as P with(nolock) on M.ProjectId = P.ProjectId	
	--left join icc.dbo.Gateway as GW with(nolock) on M.GatewayId = GW.GatewayId											
	WHERE ReceivedSentTime >= DATEADD(Month,-3,@From) AND ReceivedSentTime <= @To /*and M.AgentId is not null	*/
	  AND ProjectId IN (SELECT * FROM [FS_custom].dbo.[Return_Ids](@ProjectFilter))
	  											
	
union ALL	-- Události zpráv											
SELECT 	
		  dbo.RoundTime(ME.TimeLocal, @RoundInterval) AS GroupingDate											
		,0 AS ConnectedCalls  
		,0 AS LostCalls 
		,0 AS IVRLostCalls 
		,0 AS InTimeCalls 
		,0 AS CallDurationIN 
	    ,0 AS Offered 
		,0 AS AbandOffered 
		,0 AS HandledByAgents 
					
		, 0 AS ConnectedCallsOUT  
		, 0 AS LostCallsOUT 
		, 0 AS CallDurationOUT 
	    , 0 AS InCommingEmails											
	    , 0 AS OutGoingEmails	
		, 0 AS OutGoingSMSes											
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
--	LEFT JOIN icc.dbo.Agent AS A WITH(NOLOCK) ON A.AgentId = ME.AgentId												
--	Left join icc.dbo.Language as L with(nolock) on M.LanguageId = L.LanguageId												
--	left join icc.dbo.Project as P with(nolock) on M.ProjectId = P.ProjectId	
--	left join icc.dbo.Gateway as GW with(nolock) on M.GatewayId = GW.GatewayId											
	WHERE  Timelocal >= @From AND Timelocal <= @To 
	  AND M.MessageType='Email'											
		/*	*/												
) AS A	
WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
group by GroupingDate /*, AgentId, ProjectName	*/	
/*										
) AS B	*/													
)




GO

