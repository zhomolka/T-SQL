USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_PCS_PersonalStatCount]    Script Date: 30. 1. 2018 7:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Hemerka
-- Create date: 2014-04
-- Description:	PČS - osobní statistiky agenta
-- Upravil: ZbH 7.11.2017
-- =============================================
CREATE FUNCTION [dbo].[rep_PCS_PersonalStatCount]
(	
	@From AS DATETIME, 
	@To AS DATETIME,
	@RoundInterval AS INT,
	@Version AS INT -- 1 = původní verze pro osobní statistiky agenta, 2 = Vyhodnocení podle bran
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
													
SELECT 													
	 GroupingDate
	, AgentId												
	,max(AgentName) as AgentName
	,MAX(AgentTeamName) as AgentTeamName
	,ProjectName
	,SUM(CASE WHEN (StatusName = 'TalkTimeIN' OR StatusName = 'TalkTimeOUT') AND Language = 'Czech'  THEN 1 ELSE 0 END) AS  HovoryCZ												
	,SUM(CASE WHEN (StatusName = 'TalkTimeIN' OR StatusName = 'TalkTimeOUT') AND Language = 'English'  THEN 1 ELSE 0 END) AS  HovoryEN													 																					
	--,(SELECT COUNT(*) FROM Message AS M WHERE dbo.RoundTime(M.ReadConfirmedTime, @RoundInterval) = A.GroupingDate AND M.ReadConfirmedTime>= @From AND M.ReadConfirmedTime <= @TO AND M.AgentId IS NOT NULL) as ReadMailCount 												
	,SUM(ReadMailCount) AS  ReadMailCount
	,SUM(ReceivedMailCount) AS  ReceivedMailCount												
	--,(SELECT COUNT(*) FROM Message AS M WHERE dbo.RoundTime(M.AnsweringTime, @RoundInterval) = A.GroupingDate AND M.AnsweringTime>= @From AND M.AnsweringTime <= @TO AND M.AgentId IS NOT NULL) as AnsweredMailCount												
	-- Zde byl problém v tom, že je filtr nastaven na ReceiveSentTime. Když někdo odpoví v jiném čase, záznam se tu již neobjevil:
	--,SUM(CASE WHEN (StatusName = 'Message' and Direction = 'I' and AnsweringTime is not null )  THEN 1 ELSE 0 END) AS  AnsweredMailCount
	,SUM(REMessage) as AnsweredMailCount
	/*
	,SUM(CASE WHEN StatusName = 'Message' and Direction = 'I' THEN ReceiveAcceptTime ELSE 0 END) AS SUMReceiveAcceptTime												
	,SUM(CASE WHEN StatusName = 'Message' and Direction = 'I' THEN ReceiveReplayTime ELSE 0 END) AS SUMReceiveReplayTime
	,SUM(CASE WHEN StatusName = 'Message' and Direction = 'I' THEN AcceptReplayTime ELSE 0 END) AS SUMAcceptReplayTime
	,SUM(CASE WHEN StatusName = 'Message' and Direction = 'I' THEN ReceiveCloseTime ELSE 0 END) AS SUMReceiveCloseTime	*/
	,SUM(ISNULL(SPAMMarked,0)) as SPAMMarked
	,SUM(NewMessage) as NewMessage
	,SUM(ClosedMessage) as ClosedMessage
	,SUM(FWMessage) as FWMessage
													
FROM													
(													
													
SELECT 		-- Příchozí hovory											
		  dbo.RoundTime(IC.EnqueueingTime, @RoundInterval) AS GroupingDate											
		, NULL	AS ReadConfirmTimeGrouped										
		, EnqueueingTime AS TimeLocal											
		, IC.AgentId as AgentId										
		, A.DisplayName AS AgentName											
		, A.TeamName AS AgentTeamName											
		, P.DisplayName as ProjectName											
		, CallDuration AS TalkTimeIN											
		, NULL AS TalkTimeOut											
		, 'TalkTimeIN' AS StatusName											
		, Null as Direction											
		, L.DisplayName as language											
		, NULL as ReadConfirmedTime											
		, NULL as AcceptedTime											
		, NULL as AnsweringTime											
		, 0 as ReceiveAcceptTime											
		, 0 as ReceiveReplayTime											
		, 0 as AcceptReplayTime											
		, 0 as  ReceiveCloseTime	
		, 0 as SPAMMarked	
		, 0  AS NewMessage	
		, 0 AS ClosedMessage	
		, 0 AS FWMessage	
		, 0 AS REMessage	
		, 0 AS ReadMailCount
	    , 0 AS ReceivedMailCount							
			FROM icc.dbo.InboundCall AS IC WITH(NOLOCK)										
	LEFT JOIN icc.dbo.Agent AS A WITH(NOLOCK) ON A.AgentId = IC.AgentId												
	Left join icc.dbo.Language as L with(nolock) on IC.LanguageId = L.LanguageId												
	left join icc.dbo.Project as P with(nolock) on IC.ProjectId = P.ProjectId												
	WHERE EnqueueingTime >= @From AND EnqueueingTime <= @To and Ic.AgentId is not null and Ic.CallDuration is not null												
													
	UNION ALL											
													
	SELECT 		-- Odchozí hovory										
		  dbo.RoundTime(OC.EnqueueingTime, @RoundInterval) AS GroupingDate											
		  , NULL AS ReadConfirmTimeGrouped											
		, EnqueueingTime AS TimeLocal											
		, OC.AgentId as AgentId											
		, A.DisplayName AS AgentName											
		, A.TeamName AS AgentTeamName											
		, P.DisplayName as ProjectName											
		, NULL AS TalkTimeIN											
		, CallDuration AS TalkTimeOut											
		, 'TalkTimeOUT' AS StatusName											
		, Null as Direction											
		, L.DisplayName as language											
		, NULL as ReadConfirmedTime											
		, NULL as AcceptedTime											
		, NULL as AnsweringTime											
		, 0 as ReceiveAcceptTime											
		, 0 as ReceiveReplayTime											
		, 0 as AcceptReplayTime											
		, 0 as  ReceiveCloseTime	
		, 0 as SPAMMarked	
		, 0  AS NewMessage	
		, 0 AS ClosedMessage
		, 0 AS FWMessage	
		, 0 AS REMessage	
		, 0 AS ReadMailCount
        , 0 AS ReceivedMailCount							
			FROM icc.dbo.OutboundCall AS OC WITH(NOLOCK)										
	LEFT JOIN icc.dbo.Agent AS A WITH(NOLOCK) ON A.AgentId = OC.AgentId												
	Left join icc.dbo.Language as L with(nolock) on OC.LanguageId = L.LanguageId												
	left join icc.dbo.Project as P with(nolock) on OC.ProjectId = P.ProjectId												
	WHERE EnqueueingTime >= @From AND EnqueueingTime <= @To and OC.AgentId is not null and OC.CallDuration is not null												
union ALL												
SELECT 		-- Maily											
		  dbo.RoundTime(M.ReceivedSentTime, @RoundInterval) AS GroupingDate											
		  , dbo.RoundTime(M.ReadConfirmedTime, @RoundInterval) AS ReadConfirmTimeGrouped											
		, ReceivedSentTime AS TimeLocal											
		, M.AgentId	as AgentId										
		, A.DisplayName AS AgentName											
		, A.TeamName AS AgentTeamName											
		, IIF(@Version=1,P.DisplayName,GW.DisplayName) as ProjectName											
		, NULL AS TalkTimeIN											
		, NULL AS TalkTimeOut											
		, IIF(M.Direction = 'O',IIF(M.RelatedMessageId IS NULL,'NewMessage','FWMessage'),'Message') AS StatusName											
		, M.Direction as Direction											
		, L.DisplayName as language											
		, ReadConfirmedTime										
		, AcceptedTime										
		, AnsweringTime										
		, CASE WHEN AcceptedTime is not null THEN DATEDIFF(SS, ReceivedSentTime, AcceptedTime) ELSE 0 END as 	ReceiveAcceptTime									
		, CASE WHEN AnsweringTime is not null THEN DATEDIFF(SS, ReceivedSentTime, AnsweringTime) ELSE 0 END as 	ReceiveReplayTime
		, CASE WHEN AnsweringTime is not null THEN DATEDIFF(SS, AcceptedTime, AnsweringTime) ELSE 0 END as 	AcceptReplayTime											
		, CASE WHEN EndTime is not null THEN DATEDIFF(SS, ReceivedSentTime, EndTime) ELSE 0 END as 	ReceiveCloseTime											
		, 0 AS SPAMMarked										
	    , IIF(M.Direction = 'O' AND M.RelatedMessageId IS NULL,1,0)  AS NewMessage	
		, 0 AS ClosedMessage
		, IIF(M.Direction = 'O' AND M.RelatedMessageId IS NOT NULL AND SubjectField LIKE 'FW:%',1,0)  AS FWMessage
		, IIF(M.Direction = 'O' AND M.RelatedMessageId IS NOT NULL AND SubjectField LIKE 'RE:%',1,0)  AS REMessage
		, 0 AS ReadMailCount
		, 0 AS ReceivedMailCount
			FROM icc.dbo.Message AS M WITH(NOLOCK)													
	LEFT JOIN icc.dbo.Agent AS A WITH(NOLOCK) ON A.AgentId = M.AgentId												
	Left join icc.dbo.Language as L with(nolock) on M.LanguageId = L.LanguageId												
	left join icc.dbo.Project as P with(nolock) on M.ProjectId = P.ProjectId	
	left join icc.dbo.Gateway as GW with(nolock) on M.GatewayId = GW.GatewayId											
	WHERE /*M.Direction = 'I' and */ ReceivedSentTime >= @From AND ReceivedSentTime <= @To and M.AgentId is not null	
	  AND MessageType='Email'											

union ALL	-- Události zpráv											
SELECT 													
		  dbo.RoundTime(Timelocal, @RoundInterval) AS GroupingDate											
		  , dbo.RoundTime(Timelocal, @RoundInterval) AS ReadConfirmTimeGrouped											
		, TimeLocal											
		, ME.AgentId	as AgentId										
		, A.DisplayName AS AgentName											
		, A.TeamName AS AgentTeamName											
		, IIF(@Version=1,P.DisplayName,GW.DisplayName) as ProjectName											
		, NULL AS TalkTimeIN											
		, NULL AS TalkTimeOut											
		, 'Message' AS StatusName											
		, M.Direction as Direction											
		, L.DisplayName as language											
		, ReadConfirmedTime										
		, AcceptedTime										
		, AnsweringTime										
		, 0 as 	ReceiveAcceptTime									
		, 0 as 	ReceiveReplayTime
		, 0 as 	AcceptReplayTime											
		, 0 as 	ReceiveCloseTime											
		, IIF(EventType='SpamMarked',1,0) AS SPAMMarked										
	    , 0 AS NewMessage	
		, IIF(EventType='Closing',1,0)  AS ClosedMessage -- 
		, 0  AS FWMessage
		, 0  AS REMessage
		, IIF(EventType='Reading',1,0) AS ReadMailCount
		, IIF(EventType='Accepting',1,0) AS ReceivedMailCount
			FROM icc.dbo.MessageEvent AS ME WITH(NOLOCK)	
	LEFT JOIN icc.dbo.Message AS M WITH(NOLOCK)	ON M.MessageId = ME.MessageId																									
	LEFT JOIN icc.dbo.Agent AS A WITH(NOLOCK) ON A.AgentId = ME.AgentId												
	Left join icc.dbo.Language as L with(nolock) on M.LanguageId = L.LanguageId												
	left join icc.dbo.Project as P with(nolock) on M.ProjectId = P.ProjectId	
	left join icc.dbo.Gateway as GW with(nolock) on M.GatewayId = GW.GatewayId											
	WHERE  Timelocal >= @From AND Timelocal <= @To and ME.AgentId is not null	
	  AND M.MessageType='Email'											
													
) AS A	
WHERE (@Version=1 OR StatusName NOT IN ('TalkTimeOUT','TalkTimeIN'))												
group by GroupingDate, AgentId, ProjectName												
													
)


GO

