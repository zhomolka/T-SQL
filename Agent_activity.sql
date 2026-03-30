USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[Agent_activity]    Script Date: 25. 4. 2022 12:50:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 25.04.2022
-- Description:	Agents report se stavy
-- =============================================
CREATE FUNCTION [dbo].[Agent_activity]
(	
	@From AS DATETIME,
	@To AS DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
SELECT  DISTINCT
Phase1.GroupingDate
 , AgentName
 , TeamName
 , (SELECT TOP 1 [WorkplaceId] FROM [iCC].[dbo].[AgentEvent] AE WHERE Timelocal>=CONVERT(Date,Phase1.GroupingDate) AND Timelocal<=Phase1.GroupingDate
   AND Phase1.AgentId=AE.AgentId ORDER BY TimeLocal DESC) AS WorkplaceId

 ---------------------------------------------------------------------------------
FROM (SELECT Cas.S AS GroupingDate,
   A.AgentId
   ,A.DisplayName AS AgentName
   ,  TeamName
   --, A.WorkplaceId
   --, A.LastCallUtc
   --, A.StatusId
   --, FS_Custom.dbo.TimeUTC_Local(A.LastCallUtc) AS LastCallTime
   --,A.EmailCount
   ,a.deleted as AgentDeleted
	FROM iCC.dbo.Rep_DateTime(@From,@To,'f') AS Cas -- WHERE FS_Custom.[dbo].[IsWorkTime](S,'PracDoba')=1
	 cross join icc.dbo.Agent a with (nolock)
		   where a.Deleted=0 AND Template=0 AND TeamName<>'ADMIN' AND LEFT(TeamName,7)<>'lékárny'
		   AND TeamName<>'IT'
 
 ) AS Phase1
  ---------------------------------------------------------------------------------
     --LEFT JOIN FS_CUSTOM.dbo.rep_inboundCalls_Stat(@From, @To,1440,20)  AS IC ON IC.AgentId=Phase1.AgentId AND IC.GroupingDate=Phase1.GroupingDate AND IC.AgentId IS NOT NULL
     --LEFT JOIN FS_CUSTOM.dbo.rep_OutboundCalls_Stat(@From, @To,1440,20) AS OC ON OC.AgentId=Phase1.AgentId AND OC.GroupingDate=Phase1.GroupingDate AND OC.AgentId IS NOT NULL
     --LEFT JOIN FS_CUSTOM.dbo.rep_Emails_Stat(@From, @To,1440) AS ME ON ME.AgentId=Phase1.AgentId AND ME.GroupingDate=Phase1.GroupingDate AND ME.AgentId IS NOT NULL
     --LEFT JOIN FS_CUSTOM.dbo.rep_EmailsDone_Stat(@From, @To,1440) AS MD ON MD.AgentId=Phase1.AgentId AND MD.GroupingDate=Phase1.GroupingDate AND MD.AgentId IS NOT NULL
     --LEFT JOIN FS_CUSTOM.dbo.rep_Agents_Stat(@From, @To,1440) AS AG ON AG.AgentId=Phase1.AgentId AND AG.GroupingDate=Phase1.GroupingDate AND AG.AgentId IS NOT NULL
      --LEFT JOIN FS_CUSTOM.dbo.rep_CalEvents_Stat(@From, @To,1440) AS CAE ON CAE.AgentId=Phase1.AgentId AND CAE.GroupingDate=Phase1.GroupingDate AND CAE.AgentId IS NOT NULL
    -- LEFT JOIN iCC.dbo.Workplace AS WP ON WP.WorkplaceId=Phase1.WorkplaceId 
	 --LEFT JOIN iCC.dbo.Status AS ST WITH(NOLOCK)  ON Phase1.StatusId=ST.StatusId
)





GO

