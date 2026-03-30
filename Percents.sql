USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[Percents]    Script Date: 9. 5. 2019 8:50:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <2.5.2019>
-- Description:	<Vrací podíl v procentech>
-- =============================================

CREATE FUNCTION [dbo].[Percents](@Numerator as Real, @Denominator AS Real)
RETURNS Real
AS
BEGIN
	DECLARE @Result as Real
	SET @Denominator = ISNULL(@Denominator,0)
	IF  @Denominator=0
	  RETURN 100
    ELSE
	  BEGIN
	    SET @Numerator = ISNULL(@Numerator,0)
	    SET @Result=ROUND(@Numerator/@Denominator*100,2)
	  END
	RETURN @Result
END
--



GO

