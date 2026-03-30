SELECT        C.OutboundCallId AS CallId, C.CallType, C.Predistributed, C.AgentId, C.PreferredAgentId, C.ProjectId, C.Skill, C.LanguageId, C.Proficiency, C.CallerNumber, C.PbxCallId, C.Priority, C.CallResult, C.CallPhase, 
                         CASE WHEN C.Predistributed = 1 THEN 3 ELSE 1 END AS Urgency, DATEADD(ss, - P.WaitingOffset, GETDATE()) AS ScoredTime, DATEADD(ss, - P.WaitingOffset, C.EnqueueingTime) AS EnterTime
FROM            dbo.OutboundCall AS C INNER JOIN
                         dbo.Project AS P ON C.ProjectId = P.ProjectId LEFT OUTER JOIN
                         dbo.OutboundList AS OL ON C.OutboundListId = OL.OutboundListId AND OL.Deleted = 0 LEFT OUTER JOIN
                         dbo.OutboundListImport AS OLI ON C.OutboundListImportId = OLI.OutboundListImportId AND OLI.Deleted = 0
WHERE        (C.CallType = 'DialOut') AND (C.CallResult = 'Scheduled') AND (C.CallPhase = 'Enqueue' OR
                         C.CallPhase = 'AgentOfferMissed') AND (C.ScheduleTime IS NULL OR
                         C.ScheduleTime <= GETDATE()) AND (OL.Activity IS NULL) AND (OLI.Active IS NULL OR
                         OLI.Active = 1) AND (OL.RankBatch IS NULL) OR
                         (C.CallType = 'DialOut') AND (C.CallResult = 'Scheduled') AND (C.CallPhase = 'Enqueue' OR
                         C.CallPhase = 'AgentOfferMissed') AND (C.ScheduleTime IS NULL OR
                         C.ScheduleTime <= GETDATE()) AND (OL.Activity = 'Scheduled') AND (OLI.Active IS NULL OR
                         OLI.Active = 1) AND (OL.RankBatch IS NULL) AND (C.Predistributed = 1) OR
                         (C.CallType = 'DialOut') AND (C.CallResult = 'Scheduled') AND (C.CallPhase = 'Enqueue' OR
                         C.CallPhase = 'AgentOfferMissed') AND (C.ScheduleTime IS NULL OR
                         C.ScheduleTime <= GETDATE()) AND (OL.Activity = 'Scheduled') AND (OLI.Active IS NULL OR
                         OLI.Active = 1) AND (OL.RankBatch IS NULL) AND (OL.PredictorId IS NULL) OR
                         (C.CallType = 'DialOut') AND (C.CallResult = 'Scheduled') AND (C.CallPhase = 'Enqueue' OR
                         C.CallPhase = 'AgentOfferMissed') AND (C.ScheduleTime IS NULL OR
                         C.ScheduleTime <= GETDATE()) AND (OL.Activity IS NULL) AND (OLI.Active IS NULL OR
                         OLI.Active = 1) AND (C.OutboundListImportId IS NULL) OR
                         (C.CallType = 'DialOut') AND (C.CallResult = 'Scheduled') AND (C.CallPhase = 'Enqueue' OR
                         C.CallPhase = 'AgentOfferMissed') AND (C.ScheduleTime IS NULL OR
                         C.ScheduleTime <= GETDATE()) AND (OL.Activity = 'Scheduled') AND (OLI.Active IS NULL OR
                         OLI.Active = 1) AND (C.Predistributed = 1) AND (C.OutboundListImportId IS NULL) OR
                         (C.CallType = 'DialOut') AND (C.CallResult = 'Scheduled') AND (C.CallPhase = 'Enqueue' OR
                         C.CallPhase = 'AgentOfferMissed') AND (C.ScheduleTime IS NULL OR
                         C.ScheduleTime <= GETDATE()) AND (OL.Activity = 'Scheduled') AND (OLI.Active IS NULL OR
                         OLI.Active = 1) AND (OL.PredictorId IS NULL) AND (C.OutboundListImportId IS NULL) OR
                         (C.CallType = 'DialOut') AND (C.CallResult = 'Scheduled') AND (C.CallPhase = 'Enqueue' OR
                         C.CallPhase = 'AgentOfferMissed') AND (C.ScheduleTime IS NULL OR
                         C.ScheduleTime <= GETDATE()) AND (OL.Activity IS NULL) AND (OLI.Active IS NULL OR
                         OLI.Active = 1) AND (C.Rank <= OLI.RankBarrier) OR
                         (C.CallType = 'DialOut') AND (C.CallResult = 'Scheduled') AND (C.CallPhase = 'Enqueue' OR
                         C.CallPhase = 'AgentOfferMissed') AND (C.ScheduleTime IS NULL OR
                         C.ScheduleTime <= GETDATE()) AND (OL.Activity = 'Scheduled') AND (OLI.Active IS NULL OR
                         OLI.Active = 1) AND (C.Predistributed = 1) AND (C.Rank <= OLI.RankBarrier) OR
                         (C.CallType = 'DialOut') AND (C.CallResult = 'Scheduled') AND (C.CallPhase = 'Enqueue' OR
                         C.CallPhase = 'AgentOfferMissed') AND (C.ScheduleTime IS NULL OR
                         C.ScheduleTime <= GETDATE()) AND (OL.Activity = 'Scheduled') AND (OLI.Active IS NULL OR
                         OLI.Active = 1) AND (OL.PredictorId IS NULL) AND (C.Rank <= OLI.RankBarrier)