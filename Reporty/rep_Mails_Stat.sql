USE [Bonerix]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_Mails_Stat]    Script Date: 3.9.2018 16:48:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 2018-09-03
-- Description:	Statistiky CC o mailech
-- =============================================
CREATE FUNCTION [dbo].[rep_Mails_Stat]
(	
	@From AS DATETIME, 
	@To AS DATETIME,
	@RoundInterval AS INT -- Day = 1440
)
RETURNS TABLE 
AS
RETURN 
(																									
SELECT 		-- Maily											
		 dbo.RoundTime(M.ReceivedSentTime, @RoundInterval) AS GroupingDate											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)<=1,1,0)) AS OdpovedDo1hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)<=2 AND DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)>1,1,0)) AS OdpovedDo2hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)<=3 AND DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)>2,1,0)) AS OdpovedDo3hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)<=4 AND DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)>3,1,0)) AS OdpovedDo4hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)<=5 AND DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)>4,1,0)) AS OdpovedDo5hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)<=6 AND DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)>5,1,0)) AS OdpovedDo6hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)<=24 AND DATEDIFF(Hour,ReceivedSentTime,AnsweringTime)>6,1,0)) AS OdpovedDo24hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,EndTime)<=1,1,0)) AS HotovoDo1hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,EndTime)<=2 AND DATEDIFF(Hour,ReceivedSentTime,EndTime)>1,1,0)) AS HotovoDo2hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,EndTime)<=3 AND DATEDIFF(Hour,ReceivedSentTime,EndTime)>2,1,0)) AS HotovoDo3hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,EndTime)<=4 AND DATEDIFF(Hour,ReceivedSentTime,EndTime)>3,1,0)) AS HotovoDo4hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,EndTime)<=5 AND DATEDIFF(Hour,ReceivedSentTime,EndTime)>4,1,0)) AS HotovoDo5hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,EndTime)<=6 AND DATEDIFF(Hour,ReceivedSentTime,EndTime)>5,1,0)) AS HotovoDo6hod											
		, SUM(IIF(DATEDIFF(Hour,ReceivedSentTime,EndTime)<=24 AND DATEDIFF(Hour,ReceivedSentTime,EndTime)>6,1,0)) AS HotovoDo24hod											

	FROM icc.dbo.Message AS M WITH(NOLOCK)													
	WHERE Direction='I' AND MessageType='Email' AND ReceivedSentTime >= @From AND ReceivedSentTime <= @To 
	 AND (AnsweringTime IS NOT NULL OR EndTime IS NOT NULL)

group by dbo.RoundTime(M.ReceivedSentTime, @RoundInterval) 
/*										
) AS B	*/													
)





GO

