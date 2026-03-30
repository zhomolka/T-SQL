USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_OutboundCalls]    Script Date: 3.9.2018 16:30:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Michal Pajgrt
-- Create date:  2012-06-26
-- Description:	Odchozi hovory
-- =============================================
CREATE FUNCTION [dbo].[rep_OutboundCalls] (@From datetime, @To datetime)
RETURNS TABLE
AS
RETURN
(
SELECT     OC.OutboundCallId, OC.TimeUtc, OC.CallType, OC.CallPhase, OC.AppResult, OC.CallResult, OC.PbxCallId, OC.CallerNumber, OC.OutboundListId, OC.DisplayName, OC.ProjectId, 
                      OC.PreferredAgentId, OC.Rank, OC.GroupNumber, OC.TimeMode, OC.TimeFrom, OC.TimeTo, OC.EnqueueingTime, OC.ScheduleTime, OC.DistributionTime, 
                      OC.AnswerTime, OC.EndTime, OC.Trial, OC.AgentId, OC.WorkPlaceId, A.DisplayName AS AgentName, P.DisplayName AS ProjectName, 
                      WP.DisplayName AS WorkplaceName, OL.DisplayName AS OutboundListName, PN.Description AS CustomerCode, PN.DisplayName AS CustomerName
FROM         icc.dbo.OutboundCall AS OC LEFT OUTER JOIN
                      icc.dbo.Agent AS A ON A.AgentId = OC.AgentId LEFT OUTER JOIN
                      icc.dbo.Project AS P ON OC.ProjectId = P.ProjectId LEFT OUTER JOIN
                      icc.dbo.Workplace AS WP ON OC.WorkPlaceId = WP.WorkplaceId LEFT OUTER JOIN
                      icc.dbo.OutboundList AS OL ON OC.OutboundListId = OL.OutboundListId LEFT OUTER JOIN
                      icc.dbo.InboundCall AS IC ON CAST(OC.DisplayName AS CHAR(50))= 'Missed ' + Cast(IC.InboundCallId AS CHAR(50)) LEFT OUTER JOIN
                      icc.dbo.PhoneNumber AS PN ON PN.PhoneNumberId = IC.PhoneNumberId
WHERE     (OC.CallResult <> 'Active') and Cast(OC.EnqueueingTime as DATE) >= @From and Cast(OC.EnqueueingTime as DATE) <= @To

);



GO

