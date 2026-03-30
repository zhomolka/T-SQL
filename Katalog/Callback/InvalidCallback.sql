USE [FS_Custom]
GO
/****** Object:  StoredProcedure [dbo].[InvalidCallback]    Script Date: 8/31/2022 10:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		JaT
-- 2021-02-03 - JaT - len(callernumber) < 12 check
-- =============================================
ALTER PROCEDURE [dbo].[InvalidCallback]
	@CallId as uniqueidentifier
AS
BEGIN

	--declare @CallId as uniqueidentifier = 'F01D2D6C-C964-EB11-ABE0-005056933C48'

	declare @Number as nvarchar(50) = (SELECT CallerNumber FROM icc.dbo.InboundCall with(nolock) WHERE InboundCallId=@CallId)

	if (@number is not null and len(@number) < 9)
		begin
			SELECT 'InvalidNumber' AS 'IVR_Callback'
		end
	else SELECT null AS 'IVR_Callback'



END


