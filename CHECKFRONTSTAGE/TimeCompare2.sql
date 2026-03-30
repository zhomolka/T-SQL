USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[TimeCompare2]    Script Date: 22. 2. 2018 8:55:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <22.2.2018>
-- Description:	<Porovnává čas Datetime1  s časem Datetime2>
-- =============================================

CREATE FUNCTION [dbo].[TimeCompare2](@DateTime1 as DateTime, @OPERATOR AS NVARCHAR(1) , @DateTime2 as DateTime)
RETURNS int
AS
BEGIN
	DECLARE @CompareValid as int = 0
	IF  @OPERATOR='<'
	  SET @CompareValid=IIF(LEFT(CONVERT(NVARCHAR(8),@DateTime1,108),5)<=LEFT(CONVERT(NVARCHAR(8),@DateTime2,108),5),1,0)
    ELSE
	  SET @CompareValid=IIF(LEFT(CONVERT(NVARCHAR(8),@DateTime1,108),5)>=LEFT(CONVERT(NVARCHAR(8),@DateTime2,108),5),1,0)
	RETURN @CompareValid
END
--


GO

