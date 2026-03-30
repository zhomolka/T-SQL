USE [FS_custom]
GO
/****** Object:  UserDefinedFunction [dbo].[IsHoliday]    Script Date: 21. 2. 2018 17:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <8.2.2016>
-- Description:	<říká, zda spadá zadaný čas do svátku>
-- =============================================
ALTER FUNCTION [dbo].[IsHoliday]
(
	-- Add the parameters for the function here
	@MyDatime as Datetime,
	@HolidayGroupName AS NVARCHAR(50)
)
RETURNS integer
AS
BEGIN
	DECLARE @isHol as integer = 0
	IF EXISTS((SELECT * FROM
	(SELECT TimeFrom AS Start, TimeTo AS MyEnd FROM  iCC.dbo.Holiday WHERE HolidayGroupName=@HolidayGroupName and TimeMode='SingleDay'
	   UNION
	SELECT DATEADD(YEAR,YEAR(@MyDatime) - YEAR(TimeFrom),TimeFrom) AS Start, DATEADD(YEAR,YEAR(@MyDatime) - YEAR(TimeTo),TimeTo) AS MyEnd
    FROM  iCC.dbo.Holiday WHERE HolidayGroupName=@HolidayGroupName and TimeMode='DayInYear') AS Holidays
	   WHERE @MyDatime>=Start and @MyDatime<=MyEnd))
	BEGIN
	  SET @isHol = 1  -- Je svátek
	END
	RETURN @isHol
	
	-- Return the result of the function
	--SET @isHol = 1
	--RETURN @isHol

END

