USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[setProject]    Script Date: 18. 5. 2017 17:47:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Zbynek Homolka
-- Create date: 21. 4. 2017
-- Description:	Nastaví pro příchozí hovor zadaný projekt 
-- =============================================
CREATE PROCEDURE [dbo].[setProject]
	-- Add the parameters for the stored procedure here
	@CallId as uniqueidentifier,
	@ProjectId as uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update icc.dbo.InboundCall set ProjectId = @ProjectId where InboundCallId=@CallId
END

GO

