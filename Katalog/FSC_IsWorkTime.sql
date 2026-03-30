
/****** Object:  UserDefinedFunction [dbo].[IsWorkTime]    Script Date: 10. 10. 2019 17:17:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <5.6.2017>
-- Description:	<říká, zda určený DateTime spadá do základní pracovní doby>
-- Changes: Chmelíková: Přidaná kontrola na víkendy a svátky
-- =============================================
CREATE FUNCTION [dbo].[fsc_IsWorkTime]
(
	-- Add the parameters for the function here
	@MyDatime as Datetime,
	@HolidayGroupName AS NVARCHAR(50)
)
RETURNS integer
AS
BEGIN
	DECLARE @Work as bit=0
	DECLARE @isWorkTime as bit = 0
	DECLARE @isWorkingday as bit = 0
	DECLARE @isHol as integer = 0
	DECLARE @Start AS DateTime = (SELECT TOP 1 TimeFrom  FROM  Holiday WHERE HolidayGroupName=@HolidayGroupName AND TimeMode='DayInWeek')
	DECLARE @End  AS DateTime = (SELECT  TOP 1 TimeTo  FROM  Holiday WHERE HolidayGroupName=@HolidayGroupName AND TimeMode='DayInWeek')
	DECLARE @CharDate AS NVARCHAR(24) = LEFT(CONVERT(NVARCHAR(24),@MyDatime,126),10)
	DECLARE @StartDay AS INT= DATEPART(WEEKDAY,(SELECT TOP 1 TimeFrom  FROM  Holiday WHERE HolidayGroupName=@HolidayGroupName AND TimeMode='DayInWeek'))
	DECLARE @EndDay  AS INT = DATEPART(WEEKDAY,(SELECT  TOP 1 TimeTo  FROM  Holiday WHERE HolidayGroupName=@HolidayGroupName AND TimeMode='DayInWeek'))
	DECLARE @MyDay  AS INT=	DATEPART(WEEKDAY,@MyDatime)
	
	-- Teď musím do @Start a @End dosadit datum z @MyDatime
	SET @Start = CONVERT(DateTime,@CharDate+' '+SUBSTRING(CONVERT(NVARCHAR(24),@Start,126),12,8))
	SET @End   = CONVERT(DateTime,@CharDate+' '+SUBSTRING(CONVERT(NVARCHAR(24),@End,126),12,8))


	IF @MyDatime BETWEEN  @Start AND @End
	  SET @isWorkTime = 1  -- Pracovní doba

	IF @MyDay BETWEEN  @Startday AND @Endday
	  SET @isWorkingday = 1  -- Pracovní den


	--is Holiday
	IF EXISTS((SELECT * FROM
	(SELECT TimeFrom AS Start, TimeTo AS MyEnd FROM  Holiday WHERE HolidayGroupName=@HolidayGroupName and TimeMode='SingleDay'
	   UNION
	SELECT DATEADD(YEAR,YEAR(@MyDatime) - YEAR(TimeFrom),TimeFrom) AS Start, DATEADD(YEAR,YEAR(@MyDatime) - YEAR(TimeTo),TimeTo) AS MyEnd
    FROM  Holiday WHERE HolidayGroupName=@HolidayGroupName and TimeMode='DayInYear') AS Holidays
	   WHERE @MyDatime>=Start and @MyDatime<=MyEnd))
	BEGIN
	  SET @isHol = 1  -- Je svátek
	END


	IF @isWorkingday=1and @isWorkTime=1 and @isHol=0
		SET @Work = 1
		ELSE set @work=0

	RETURN @work

END



GO

