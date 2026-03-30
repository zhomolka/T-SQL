USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[ExtendedHoliday]    Script Date: 22. 2. 2018 8:54:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <21.2.2018>
-- Description:	<říká, zda zadaný čas spadá do intervalu >konec prac doby před volným dnem a do začátku prac. doby po volném dni>
-- =============================================
CREATE FUNCTION [dbo].[ExtendedHoliday]
(
	-- Add the parameters for the function here
	@MyDatime as Datetime
)
RETURNS integer
AS
BEGIN
	DECLARE @isHol as integer = 0
	DECLARE @HolidayGroupName AS NVARCHAR(50)='SvatkyCZ'
	DECLARE @PracDoba AS NVARCHAR(50)='PracDoba'
	DECLARE	@TestDatime as Datetime
	DECLARE	@PracDobaFrom as Datetime = (SELECT TOP 1 TimeFrom FROM  iCC.dbo.Holiday WHERE HolidayGroupName=@PracDoba)
	DECLARE	@PracDobaTo as Datetime = (SELECT TOP 1 TimeTo FROM  iCC.dbo.Holiday WHERE HolidayGroupName=@PracDoba)
	IF DATEPART (weekday, @MyDatime) IN (1,7) OR dbo.IsHoliday(@MyDatime,@HolidayGroupName)=1 -- Pokud je dnes svátek
	  SET @isHol = 1  -- Je svátek	 
	ELSE
	  BEGIN
	    SET @TestDatime = DATEADD(DAY,1,@MyDatime)
		IF (DATEPART (weekday, @TestDatime) IN (1,7) OR dbo.IsHoliday(@TestDatime,@HolidayGroupName)=1) /* Pokud je zítra volný den */
		  AND dbo.TimeCompare2(@TestDatime,'>',@PracDobaTo)=1
		  	  SET @isHol = 1  -- Je svátek	
        ELSE
		  BEGIN
	        SET @TestDatime = DATEADD(DAY,-1,@MyDatime)
		    IF (DATEPART (weekday, @TestDatime) IN (1,7) OR dbo.IsHoliday(@TestDatime,@HolidayGroupName)=1) /* Pokud byl včera volný den */
		      AND dbo.TimeCompare2(@TestDatime,'<',@PracDobaFrom)=1
		  	  SET @isHol = 1  -- Je svátek	
		  END
	  END
	RETURN @isHol
END


GO

