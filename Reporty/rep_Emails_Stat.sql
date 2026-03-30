USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_Emails_Stat]    Script Date: 21. 10. 2019 17:00:01 ******/
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
	@RoundInterval AS INT
)
RETURNS TABLE 
AS
RETURN 

(
   SELECT 													
	 GroupingDate
	 , AgentId
	 ,SUM(InCommingEmails) AS InCommingEmails
	 ,SUM(OutGoingEmails) AS OutGoingEmails														
FROM													
(																										
SELECT 		-- Maily											
		  dbo.RoundTime(M.endtime, @RoundInterval) AS GroupingDate	
        ,AgentId
		,IIF(MessagePhase <> 'Canceled' -- Mail nebyl zrušený
          and endtime is not null and endtime >= @from -- V určeném časovém rozsahu
           and agentid is not null 	               -- s přiděleným agentem
			,1 ,0) AS DoneEmails
		, IIF(M.Direction = 'I' AND ReceivedSentTime >= @From ,1,0) AS InCommingEmails											
	    , IIF(M.Direction = 'O' AND ReceivedSentTime >= @From AND M.AgentId IS NOT NULL ,1,0) AS OutGoingEmails	
        /*
		, IIF((m.agentid is not null
		and (m.direction = 'I' and not exists(select top 1 1 from icc.dbo.message with(nolock) where RelatedMessageId = m.MessageId and direction = 'O'
		and receivedsenttime >= DATEADD(Month,-3,getdate()))) or (direction = 'O') and m.endtime is not null and m.endtime >= @from)			
		 ,1 ,0 ) AS DoneEmails	-- */
	FROM icc.dbo.Message AS M WITH(NOLOCK)													
	WHERE ReceivedSentTime >= @From AND ReceivedSentTime <= @To AND MessageType='Email'											
) AS A	
--WHERE (GroupingDate>=@From AND GroupingDate<=@To)												
group by GroupingDate , AgentId/* ProjectName	*/												

												
)




GO

