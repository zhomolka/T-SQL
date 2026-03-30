USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[VycistitUQ]    Script Date: 3.3.2023 15:39:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[VycistitUQ]
AS
BEGIN
update icc.dbo.Queue
set CommState=2
where QueueId in
(
select QueueId from icc.dbo.Queue a
left join icc.dbo.OutboundCall o on OutboundCallId=a.CommId
left join icc.dbo.OutboundList l on o.OutboundListId=l.OutboundListId
where ChannelIndex=9 and ScheduleTime<getdate() 
and l.Activity='Scheduled'
and CommState=20
)
/*

update icc.dbo.OutboundCall
set CallPhase='New'
where 
OutboundCallId in
(
select a.OutboundCallId from icc.dbo.OutboundCall a
left join icc.dbo.OutboundList b on a.OutboundListId=b.OutboundListId
left join icc.dbo.OutboundListImport c on c.OutboundListImportId=a.OutboundListImportId
where  CallResult='Scheduled' and b.Activity='Scheduled' and b.Deleted=0 
and c.Deleted=0 and OutboundCallId not in (select commid from icc.dbo.Queue where ChannelIndex=9)
and CallPhase='Enqueue' and b.PredictorId is null
)



delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12)) AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)

waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)


waitfor delay '0:00:05'


delete from icc.dbo.queue
where queueid in (select QueueId
 from icc.dbo.Queue q
left join icc.dbo.OutboundCall o on q.CommId=o.OutboundCallId
where (CommState in (11,12))AND (q.AgentId IS NOT NULL) and CallResultDetailId is not null
)
*/
END
GO

