USE [fs_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[EmailTraffic]    Script Date: 8. 2. 2019 17:00:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[EmailTraffic]
(	
	@From datetime,
	@To datetime, 
	@Interval as char(1) = 'D' -- Možné hodnoty jsou Y,M,W,D
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
	R.S, R.E,
	(SELECT AVG(EmailsReceived) FROM fs_custom.dbo.SnapshotSL WHERE TimeLocal>=R.S AND TimeLocal<R.E) as ReceivedQueue,
	(SELECT AVG(EmailsReceivedSpam) FROM fs_custom.dbo.SnapshotSL WHERE TimeLocal>=R.S AND TimeLocal<R.E) as ReceivedQueueSpam,
	(SELECT AVG(EmailsRead) FROM fs_custom.dbo.SnapshotSL WHERE TimeLocal>=R.S AND TimeLocal<R.E) as ReadQueue,
	(SELECT AVG(EmailsReadSpam) FROM fs_custom.dbo.SnapshotSL WHERE TimeLocal>=R.S AND TimeLocal<R.E) as ReadQueueSpam,
	(SELECT AVG(EmailsInProcess) FROM fs_custom.dbo.SnapshotSL WHERE TimeLocal>=R.S AND TimeLocal<R.E) as InProcessQueue,
	(SELECT COUNT(*) FROM iCC.dbo.Message WITH(NOLOCK) WHERE Direction='I' AND MessageType='Email' AND ReceivedSentTime>=R.S AND ReceivedSentTime<R.E AND ProjectId='E69EAEAA-B5B3-4ED2-9A33-A4C97442FB8C') AS ReceivedSpam,
	(SELECT COUNT(*) FROM iCC.dbo.Message WITH(NOLOCK) WHERE Direction='I' AND MessageType='Email' AND ReceivedSentTime>=R.S AND ReceivedSentTime<R.E AND ProjectId<>'E69EAEAA-B5B3-4ED2-9A33-A4C97442FB8C' AND ProjectId<>'4B928C64-63E4-4C53-8D85-DE5836095C85' ) AS Received,
	(SELECT COUNT(*) FROM iCC.dbo.Message WITH(NOLOCK) WHERE Direction='I' AND MessageType='Email' AND AcceptedTime>=R.S AND AcceptedTime<R.E AND ProjectId<>'4B928C64-63E4-4C53-8D85-DE5836095C85') AS Accepted,
	(SELECT COUNT(*) FROM iCC.dbo.Message WITH(NOLOCK) WHERE Direction='I' AND MessageType='Email' AND AnsweringTime>=R.S AND AnsweringTime<R.E AND ProjectId<>'4B928C64-63E4-4C53-8D85-DE5836095C85') AS Answered,
	(SELECT COUNT(*) FROM iCC.dbo.Message WITH(NOLOCK) WHERE Direction='I' AND MessageType='Email' AND EndTime>=R.S AND EndTime<R.E AND ProjectId='E69EAEAA-B5B3-4ED2-9A33-A4C97442FB8C') AS InEndedSpam,
	(SELECT COUNT(*) FROM iCC.dbo.Message WITH(NOLOCK) WHERE Direction='I' AND MessageType='Email' AND EndTime>=R.S AND EndTime<R.E AND ProjectId<>'E69EAEAA-B5B3-4ED2-9A33-A4C97442FB8C' AND ProjectId<>'4B928C64-63E4-4C53-8D85-DE5836095C85') AS InEnded,
	(SELECT AVG(EmailsDraft) FROM fs_custom.dbo.SnapshotSL WHERE TimeLocal>=R.S AND TimeLocal<R.E) as DraftQueue,
	(SELECT COUNT(*) FROM iCC.dbo.Message WITH(NOLOCK) WHERE Direction='O' AND MessageType='Email' AND DraftTime>=R.S AND DraftTime<R.E AND ProjectId<>'4B928C64-63E4-4C53-8D85-DE5836095C85') AS Drafted,
	(SELECT COUNT(*) FROM iCC.dbo.Message WITH(NOLOCK) WHERE Direction='O' AND MessageType='Email' AND ReceivedSentTime>=R.S AND ReceivedSentTime<R.E AND ProjectId<>'4B928C64-63E4-4C53-8D85-DE5836095C85') AS Sent
FROM iCC.dbo.Rep_DateTime(@From,@To, @Interval) as R
)

GO

