USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[WorkDayDiff]    Script Date: 30. 4. 2019 14:55:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <30.4.2019>
-- Description:	<říká, zda je zadaný čas vzdálen více než určený počet pracovních dní od současnosti>
-- =============================================
CREATE FUNCTION [dbo].[WorkDayDiff]
(
	-- Add the parameters for the function here
	@MyDatime as Datetime
	,@DayDiff as integer
)
RETURNS bit
AS
BEGIN
	--declare @MyDatime as datetime = getdate()
	DECLARE @OutOffRange AS bit=IIF(@MyDatime>DATEADD(Day,@DayDiff*-1,GETDATE()),0,1)
	IF @OutOffRange=0
	  RETURN @OutOffRange ---------------->>>>>>
	DECLARE @WorkDays AS Integer = @DayDiff+1
	DECLARE @TestDiff AS Real=@DayDiff*24*3600
	DECLARE @MyDiff   AS Real=DATEDIFF(Second,@MyDatime,GETDATE())
	DECLARE	@TestDatime as Datetime = DATEADD(Hour,12,CONVERT(Datetime,CONVERT(Date,GETDATE()))) -- Budu testovat poledne
	WHILE @MyDiff>(@TestDiff) AND @WorkDays>0
	  BEGIN	    
	    IF FS_custom.dbo.MimoPrac(@TestDatime) = 1 -- Pokud je testovaný den svátek
		  IF CONVERT(Date,@TestDatime)=CONVERT(Date,GETDATE()) -- Dnes odečtu pouze čas od půlnoci
		    SET @MyDiff=@MyDiff-DATEDIFF(Second,CONVERT(Date,GETDATE()),GETDATE())
          ELSE
		    SET @MyDiff=@MyDiff-24*3600 -- Odečtu celý den
        ELSE
		  SET @WorkDays=@WorkDays-1
        SET @TestDatime=DATEADD(DAY,-1,@TestDatime)
	  END
	  SET @OutOffRange=IIF(@MyDiff>@TestDiff,1,0)
	RETURN @OutOffRange
END



GO

