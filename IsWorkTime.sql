USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[IsWorkTime]    Script Date: 10. 10. 2019 17:17:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <5.6.2017>
-- Description:	<říká, zda určený DateTime spadá do základní pracovní doby>
-- =============================================
CREATE FUNCTION [dbo].[IsWorkTime]
(
	-- Add the parameters for the function here
	@MyDatime as Datetime,
	@HolidayGroupName AS NVARCHAR(50)
)
RETURNS integer
AS
BEGIN
	DECLARE @isWorkTime as bit = 0
	DECLARE @Start AS DateTime = (SELECT TOP 1 TimeFrom  FROM  iCC.dbo.Holiday WHERE HolidayGroupName=@HolidayGroupName AND TimeMode='DayInWeek')
	DECLARE @End  AS DateTime = (SELECT  TOP 1 TimeTo  FROM  iCC.dbo.Holiday WHERE HolidayGroupName=@HolidayGroupName AND TimeMode='DayInWeek')
	DECLARE @CharDate AS NVARCHAR(24) = LEFT(CONVERT(NVARCHAR(24),@MyDatime,126),10)
	-- Teď musím do @Start a @End dosadit datum z @MyDatime
	SET @Start = CONVERT(DateTime,@CharDate+' '+SUBSTRING(CONVERT(NVARCHAR(24),@Start,126),12,8))
	SET @End   = CONVERT(DateTime,@CharDate+' '+SUBSTRING(CONVERT(NVARCHAR(24),@End,126),12,8))

	IF @MyDatime BETWEEN  @Start AND @End
	  SET @isWorkTime = 1  -- Pracovní doba
	RETURN @isWorkTime

END



GO

