USE [fs_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[TestHoliday]    Script Date: 20. 8. 2019 10:41:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <20.8.2019>
-- Description:	<je volán z IMR skriptu>
-- =============================================
CREATE FUNCTION [dbo].[TestHoliday]
(
	-- Add the parameters for the function here
)
RETURNS integer
AS
BEGIN
  RETURN FS_Custom.dbo.IsHoliday(GETDATE(),'OUT_OF_OFFICE')
END


GO

