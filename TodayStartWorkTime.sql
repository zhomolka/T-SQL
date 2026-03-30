USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[TodayStartWorkTime]    Script Date: 10. 10. 2019 17:23:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <10.10.2019>
-- Description:	<vrací počátek dnešní základní pracovní doby>
-- =============================================
CREATE FUNCTION [dbo].[TodayStartWorkTime]
(
	-- Add the parameters for the function here
	@HolidayGroupName AS NVARCHAR(50)
)
RETURNS Datetime
AS
BEGIN
	DECLARE @StartWorkTime AS DateTime = (SELECT TOP 1 TimeFrom  FROM  iCC.dbo.Holiday WHERE HolidayGroupName=@HolidayGroupName AND TimeMode='DayInWeek')
	IF @StartWorkTime IS NULL
      SET @StartWorkTime = CONVERT(date,GETDATE())
	ELSE
	 BEGIN
		DECLARE @CharDate AS NVARCHAR(24) = LEFT(CONVERT(NVARCHAR(24),GETDATE(),126),10)
	    -- Teď musím do @Start dosadit datum z @CharDate
	    SET @StartWorkTime = CONVERT(DateTime,@CharDate+' '+SUBSTRING(CONVERT(NVARCHAR(24),@StartWorkTime,126),12,8))
	 END
	RETURN @StartWorkTime
END



GO

