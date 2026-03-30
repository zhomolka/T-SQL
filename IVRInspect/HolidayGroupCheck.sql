USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[HolidayGroupCheck]    Script Date: 27. 1. 2020 14:43:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Kubát Václav>
-- Create date: <27. 1. 2020>
-- Description:	Posuzuje, zda casova podminka vyhovuje podminkam pro dane HolidayGroupName
-- ======================================================

CREATE function [dbo].[HolidayGroupCheck] (
    @HolidayGroupName NVARCHAR(30),
	@MyDateTime datetime 
)
RETURNS bit
AS
BEGIN


--declare @MyDateTime as datetime = '2020-02-01 08:49:16.510'
--declare @HolidayGroupName as NVARCHAR(30) = 'OUT_OF_OFFICE'
DECLARE @isHol as bit = 0

set @isHol = case
	when exists 
		(select top 1 1 from iCC.dbo.Holiday where TimeMode = 'SingleDay' and TimeFrom <= @MyDateTime and TimeTo >= @MyDateTime and HolidayGroupName = @HolidayGroupName) 
	then 1
	when exists 
		(select top 1 1 from iCC.dbo.Holiday where TimeMode = 'DayInYear' and DATEADD(YEAR,YEAR(@MyDateTime) - YEAR(TimeFrom),TimeFrom) <= @MyDateTime and DATEADD(YEAR,YEAR(@MyDateTime) - YEAR(TimeTo),TimeTo) >= @MyDateTime and HolidayGroupName = @HolidayGroupName) 
	then 1
	when exists 
		(select top 1 1 from iCC.dbo.Holiday where TimeMode = 'DayInWeek' and DATEPART(weekday,TimeFrom) <=  DATEPART(weekday,@MyDateTime) and DATEPART(weekday,TimeTo) >=  DATEPART(weekday,@MyDateTime) and HolidayGroupName = @HolidayGroupName
			and cast(TimeFrom as time) <=  cast(@MyDateTime  as time) and cast(TimeTo  as time) >=  cast(@MyDateTime  as time)) 
	then 1
	when exists
		(select top 1 1 from iCC.dbo.Holiday where TimeMode = 'NotDayInWeek' and 
			--kontrola v ten den, ale cas mimo rozsah casu
				((DATEPART(weekday,TimeFrom) >  DATEPART(weekday,@MyDateTime) and DATEPART(weekday,TimeTo) <  DATEPART(weekday,@MyDateTime)
					and (cast(TimeFrom as Time) > cast (@MyDateTime as Time) or cast(TimeTo as Time) < cast (@MyDateTime as Time)))
			--kontrola mimo ty dny v tydnu
				or
				(DATEPART(weekday,TimeFrom) >  DATEPART(weekday,@MyDateTime) and DATEPART(weekday,TimeTo) <  DATEPART(weekday,@MyDateTime)))
				and HolidayGroupName = @HolidayGroupName
				)
	then 1
else 0
end

--select @isHol

/*
select distinct timemode from icc.dbo.holiday where holidaygroupname = 'OUT_OF_OFFICE'
*/

RETURN @ishol

END


GO

