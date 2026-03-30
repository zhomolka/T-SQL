SELECT        C.OutboundCallId AS CallId, C.CallType, C.Predistributed, C.AgentId, C.PreferredAgentId, C.ProjectId, C.Skill, C.LanguageId, C.Proficiency, C.CallerNumber, C.PbxCallId, C.Priority, C.CallResult, C.CallPhase, 
                         CASE WHEN C.Predistributed = 1 THEN 3 ELSE 1 END AS Urgency, DATEADD(ss, - P.WaitingOffset, GETDATE()) AS ScoredTime, DATEADD(ss, - P.WaitingOffset, C.EnqueueingTime) AS EnterTime
FROM            dbo.OutboundCall AS C INNER JOIN
                         dbo.Project AS P ON C.ProjectId = P.ProjectId LEFT OUTER JOIN
                         dbo.OutboundList AS OL ON C.OutboundListId = OL.OutboundListId AND OL.Deleted = 0 LEFT OUTER JOIN
                         dbo.OutboundListImport AS OLI ON C.OutboundListImportId = OLI.OutboundListImportId AND OLI.Deleted = 0
WHERE        (C.CallType = 'DialOut') AND (C.CallResult = 'Scheduled') AND (C.EnqueueingTime IS NOT NULL) AND (C.CallPhase <> 'New') AND (C.CallPhase <> 'Manual') AND (C.ScheduleTime IS NULL OR
                         C.ScheduleTime <= GETDATE()) AND (OL.Activity IS NULL OR
                         OL.Activity = 'Scheduled') AND (OLI.Active IS NULL OR
                         OLI.Active = 1)