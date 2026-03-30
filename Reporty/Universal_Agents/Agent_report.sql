USE [FS_custom]
GO
/****** Object:  UserDefinedFunction [dbo].[Agent_report]    Script Date: 21. 10. 2019 16:58:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 04.09.2019
-- Description:	Agents report se stavy
-- =============================================
CREATE FUNCTION [dbo].[Agent_report]
(	
	@From AS DATETIME,
	@To AS DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
SELECT  
Phase1.GroupingDate
,ConnectedCalls
,CallDurationIn
,LostCalls
,(ConnectedCallsOUT+LostCallsOUT) AS OutboundCalls
/*
CallDurationOut,
CallDurationINAVG,
(EnteredCalls-ConnectedCalls) AS AbandonedCalls,

RingingTimeAVG,
CallDurationOUTAVG */
 , AgentName
 , AG.Agentid
 , TeamName
 --,(CallDurationIn+CallDurationOut) AS CallDurationTotal
 ,DoneEmails
 ,OutGoingEmails
 ,FirstLoginTime
 ,LoggedDuration
 ,LastLogoffTime
 ,ReadyDuration
 ,NotReadyDuration
 --,TransferedINCalls
 --,TransferedOUTCalls
 ,IIF(LoggedDuration=0,NULL,NR1) AS NR1 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
 ,IIF(LoggedDuration=0,NULL,NR2) AS NR2 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
 ,IIF(LoggedDuration=0,NULL,NR3) AS NR3 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
 ,IIF(LoggedDuration=0,NULL,NR4) AS NR4 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
 ,IIF(LoggedDuration=0,NULL,NR5) AS NR5 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
 ,IIF(LoggedDuration=0,NULL,NR6) AS NR6 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
 ,IIF(LoggedDuration=0,NULL,NR7) AS NR7 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
-- ,IIF(LoggedDuration=0,NULL,NR8) AS NR8 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
-- ,IIF(LoggedDuration=0,NULL,NR9) AS NR9 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
 ,IIF(LoggedDuration=0,NULL,RD1) AS RD1 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
 ,IIF(LoggedDuration=0,NULL,RD2) AS RD2 -- Ay se do průměrů nepočítaly dny nepřítomnosti operátora
 ,LO1
 ,LO2
 ,WP.DisplayName AS WorkPlaceName
 ,WP.State AS WorkPlaceState
 ,FS_Custom.dbo.WPStatDuration (Phase1.AgentId,WP.State,LastCallUtc) AS WPStatDuration
 ,ST.DisplayName AS StatusName
 ,ST.Color
 ,fs_custom.dbo.GetCurrentStateLength2(Phase1.AgentId, GETDATE()) AS StateLength
 ,LastCallTime
 ,EmailCount

 ---------------------------------------------------------------------------------
FROM (SELECT Cas.S AS GroupingDate,
   A.AgentId
   ,A.DisplayName AS AgentName
   ,  TeamName
   , A.WorkplaceId
   , A.LastCallUtc
   , A.StatusId
   , FS_Custom.dbo.TimeUTC_Local(A.LastCallUtc) AS LastCallTime
   ,A.EmailCount
	FROM iCC.dbo.Rep_DateTime(@From,@To,'D') AS Cas -- WHERE FS_Custom.[dbo].[IsWorkTime](S,'PracDoba')=1
	 cross join icc.dbo.Agent a with (nolock)
		   where a.Deleted=0 AND Template=0 AND TeamName<>'ADMIN'
 ) AS Phase1
  ---------------------------------------------------------------------------------
     LEFT JOIN FS_CUSTOM.dbo.rep_inboundCalls_Stat(@From, @To,1440,20)  AS IC ON IC.AgentId=Phase1.AgentId AND IC.GroupingDate=Phase1.GroupingDate AND IC.AgentId IS NOT NULL
     LEFT JOIN FS_CUSTOM.dbo.rep_OutboundCalls_Stat(@From, @To,1440,20) AS OC ON OC.AgentId=Phase1.AgentId AND OC.GroupingDate=Phase1.GroupingDate AND OC.AgentId IS NOT NULL
     LEFT JOIN FS_CUSTOM.dbo.rep_Emails_Stat(@From, @To,1440) AS ME ON ME.AgentId=Phase1.AgentId AND ME.GroupingDate=Phase1.GroupingDate AND ME.AgentId IS NOT NULL
     LEFT JOIN FS_CUSTOM.dbo.rep_EmailsDone_Stat(@From, @To,1440) AS MD ON MD.AgentId=Phase1.AgentId AND MD.GroupingDate=Phase1.GroupingDate AND MD.AgentId IS NOT NULL
     LEFT JOIN FS_CUSTOM.dbo.rep_Agents_Stat(@From, @To,1440) AS AG ON AG.AgentId=Phase1.AgentId AND AG.GroupingDate=Phase1.GroupingDate AND AG.AgentId IS NOT NULL
      --LEFT JOIN FS_CUSTOM.dbo.rep_CalEvents_Stat(@From, @To,1440) AS CAE ON CAE.AgentId=Phase1.AgentId AND CAE.GroupingDate=Phase1.GroupingDate AND CAE.AgentId IS NOT NULL
     LEFT JOIN iCC.dbo.Workplace AS WP ON WP.WorkplaceId=Phase1.WorkplaceId 
	 LEFT JOIN iCC.dbo.Status AS ST WITH(NOLOCK)  ON Phase1.StatusId=ST.StatusId
)




laceId
   , A.LastCallUtc
   , A.StatusId
   , FS_Custom.dbo.TimeUTC_Local(A.LastCallUtc) AS LastCallTime
   ,A.EmailCount
	FROM iCC.dbo.Rep_DateTime(@From,@To,'D') AS Cas -- WHERE FS_Custom.[dbo].[IsWorkTime](S,'PracDoba')=1
	 cross join icc.dbo.Agent a with (nolock)
		   where a.Deleted=0 AND Template=0 AND TeamName<>'ADMIN'
 ) AS Phase1
  ---------------------------------------------------------------------------------
     LEFT JOIN FS_CUSTOM.dbo.rep_inboundCalls_Stat(@From, @To,1440,20)  AS IC ON IC.AgentId=Phase1.AgentId AND IC.GroupingDate=Phase1.GroupingDate AND IC.AgentId IS NOT NULL
     LEFT JOIN FS_CUSTOM.dbo.rep_OutboundCalls_Stat(@From, @To,1440,20) AS OC ON OC.AgentId=Phase1.AgentId AND OC.GroupingDate=Phase1.GroupingDate AND OC.AgentId IS NOT NULL
     LEFT JOIN FS_CUSTOM.dbo.rep_Emails_Stat(@From, @To,1440) AS ME ON ME.AgentId=Phase1.AgentId AND ME.GroupingDate=Phase1.GroupingDate AND ME.AgentId IS NOT NULL
     LEFT JOIN FS_CUSTOM.dbo.rep_EmailsDone_Stat(@From, @To,1440) AS MD ON MD.AgentId=Phase1.AgentId AND MD.GroupingDate=Phase1.GroupingDate AND MD.AgentId IS NOT NULL
     LEFT JOIN FS_CUSTOM.dbo.rep_Agents_Stat(@From, @To,1440) AS AG ON AG.AgentId=Phase1.AgentId AND AG.GroupingDate=Phase1.GroupingDate AND AG.AgentId IS NOT NULL
      --LEFT JOIN FS_CUSTOM.dbo.rep_CalEvents_Stat(@From, @To,1440) AS CAE ON CAE.AgentId=Phase1.AgentId AND CAE.GroupingDate=Phase1.GroupingDate AND CAE.AgentId IS NOT NULL
     LEFT JOIN iCC.dbo.Workplace AS WP ON WP.WorkplaceId=Phase1.WorkplaceId 
	 LEFT JOIN iCC.dbo.Status AS ST WITH(NOLOCK)  ON Phase1.StatusId=ST.StatusId
)




