USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_IVR_HolidayCheck]    Script Date: 27. 1. 2020 14:43:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Kubát Václav>
-- Create date: <27. 1. 2020>
-- Description:	Podkladovy dotaz pro report - pro kontrolu nastaveni stavku a casovych podminek v IVR
-- ======================================================
CREATE FUNCTION [dbo].[rep_IVR_HolidayCheck]
(	
	@IvrScript as nvarchar (30)
	--@IvrScriptId as uniqueidentifier
	,@MyDateTime as datetime
)
RETURNS TABLE 
AS
RETURN 
(
/*
declare @IvrScript as uniqueidentifier = (select top 1 IvrScriptId from iCC.dbo.IvrScript where Deleted = 0 and DisplayName like '%Hlavní IVR%')
declare @MyDateTime as datetime = '2020-04-12 09:49:16.510'
*/


select
--DATEPART(weekday,@MyDateTime) as WeekDay_SQL ,
--cast(case when ([Action] in ('Holiday') or TimeMode is not null) then 1 else 0 end as bit) as Check,

cast(case when [Action] = 'Holiday' then [FS_custom].[dbo].[HolidayGroupCheck](Numbers,@MyDateTime) else NULL end as bit) as HolidayGroupCheck
,cast(case when [Action] <> 'Holiday' and TimeMode is not null 
	then 
		case
			when (TimeMode = 'SingleDay' and TimeFrom <= @MyDateTime and TimeTo >= @MyDateTime) 
			then 1
			when (TimeMode = 'DayInYear' and DATEADD(YEAR,YEAR(@MyDateTime) - YEAR(TimeFrom),TimeFrom) <= @MyDateTime and DATEADD(YEAR,YEAR(@MyDateTime) - YEAR(TimeTo),TimeTo) >= @MyDateTime) 
			then 1
			when (TimeMode = 'DayInWeek' and DATEPART(weekday,TimeFrom) <=  DATEPART(weekday,@MyDateTime) and DATEPART(weekday,TimeTo) >=  DATEPART(weekday,@MyDateTime)
					and cast(TimeFrom as time) <=  cast(@MyDateTime  as time) and cast(TimeTo  as time) >=  cast(@MyDateTime  as time)) 
			then 1
			when (TimeMode = 'NotDayInWeek' and 
			--kontrola v ten den, ale cas mimo rozsah casu
				((DATEPART(weekday,TimeFrom) >  DATEPART(weekday,@MyDateTime) and DATEPART(weekday,TimeTo) <  DATEPART(weekday,@MyDateTime)
					and (cast(TimeFrom as Time) > cast (@MyDateTime as Time) or cast(TimeTo as Time) < cast (@MyDateTime as Time)))
			--kontrola mimo ty dny v tydnu
				or
				(DATEPART(weekday,TimeFrom) >  DATEPART(weekday,@MyDateTime) and DATEPART(weekday,TimeTo) <  DATEPART(weekday,@MyDateTime)))
				)
			then 1
	else 0
end	
else NULL 
end as bit ) as HolidayCheck
,s.DisplayName as Name
,Rank
,Action
,i.DisplayName as [Target]
,TimeOut
,WaitTimeOut
,FileName
,MultiLanguage
,Retries
,ResultDigits
,SkipDigits
,ReplayDigits
,Targets
,Numbers
,TargetOnTimeOut
,TargetOnSuccess
,TargetOnFailure
,TimeMode
,TimeFrom
,TimeTo
,Culture
from icc.dbo.IvrStep as s with (nolock)
left join iCC.dbo.IvrScript as i with (nolock) on i.IvrScriptId = s.TargetId
where s.IvrScriptId = (select top 1 IvrScriptId from icc.dbo.IvrScript where DisplayName = @IvrScript and Deleted = 0)


)

GO

