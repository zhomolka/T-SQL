USE [FSCUSTOM]
GO
/****** Object:  UserDefinedFunction [dbo].[WorkDayDiff2]    Script Date: 06/09/2021 16:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <9.6.2021>
-- Description:	<říká, zda je čas @MyDatime1 vzdálen více než určený počet pracovních dnů od @MyDatime2>
-- =============================================
ALTER FUNCTION [dbo].[WorkDayDiff2]
(
	-- Add the parameters for the function here
	@MyDatime1 as Datetime
    ,@MyDatime2 as Datetime	
	,@DayDiff as integer
)
RETURNS bit
AS
BEGIN
	--declare @MyDatime as datetime = getdate()
	DECLARE @OutOffRange AS bit=IIF(@MyDatime2<DATEADD(Day,@DayDiff,@MyDatime1),0,1)
	IF @OutOffRange=0
	  RETURN @OutOffRange ---------------->>>>>>
	DECLARE @WorkDays AS Integer = @DayDiff+1
	DECLARE @TestDiff AS Real=@DayDiff*24*3600
	DECLARE @MyDiff   AS Real=DATEDIFF(Second,@MyDatime1,@MyDatime2)
	DECLARE	@TestDatime as Datetime = DATEADD(Hour,12,CONVERT(Datetime,CONVERT(Date,@MyDatime2))) -- Budu testovat poledne
	WHILE @MyDiff>(@TestDiff) AND @WorkDays>0
	  BEGIN	    
	    IF .dbo.MimoPrac(@TestDatime) = 1 -- Pokud je testovaný den svátek
		  IF CONVERT(Date,@TestDatime)=CONVERT(Date,@MyDatime2) -- Dnes odečtu pouze čas od půlnoci
		    SET @MyDiff=@MyDiff-DATEDIFF(Second,CONVERT(Date,@MyDatime2),@MyDatime2)
          ELSE
		    SET @MyDiff=@MyDiff-24*3600 -- Odečtu celý den
        ELSE
		  SET @WorkDays=@WorkDays-1
        SET @TestDatime=DATEADD(DAY,-1,@TestDatime)
	  END
	  SET @OutOffRange=IIF(@MyDiff>@TestDiff,1,0)
	RETURN @OutOffRange
END



