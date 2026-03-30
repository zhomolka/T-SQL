USE [FS_custom]
GO
/****** Object:  StoredProcedure [dbo].[UpdateCallbackRecord]    Script Date: 11. 4. 2019 9:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Peterský>
-- Create date: <listopad 2014>
-- Description:	<Aktivace volání z pøípravného projektu do cílového callback projektu>
-- update JaT 20.6.2017 - pridana zmena faze na Enqueue aby se hovory samy zacaly vytacet
-- =============================================
ALTER PROCEDURE [dbo].[UpdateCallbackRecord] 
	-- Add the parameters for the stored procedure here
	(@OutboundCallId as uniqueidentifier,
	@AgentId as uniqueidentifier
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE iCC.dbo.OutboundCall SET AgentId=@AgentId, 
	Predistributed='True', CallPhase = 'Enqueue', scheduletime=getdate(), EnqueueingTime=getdate() WHERE OutboundCallId=@OutboundCallId
END


