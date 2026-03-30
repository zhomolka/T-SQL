USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[RoundTime]    Script Date: 16. 3. 2018 9:31:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[RoundTime] (@Time datetime, @RoundTo int) 
RETURNS datetime 
AS 
BEGIN 
   DECLARE @RoundedTime datetime 
  
   SET @RoundedTime= 
   
   CASE WHEN @RoundTo = 1 THEN dateadd(MI, datediff(MI, 0, @Time), 0)		-- vynulovani sekund - zaokrouhleni na minuty
		WHEN @RoundTo = 5 THEN dateadd(MINUTE, datediff(MI, 0, @Time)  + CASE WHEN DATEPART(MINUTE, @Time) > 0 THEN -(DATEPART(MINUTE, @Time) % 5) ELSE 0 END, 0)		-- zakrouhleni dolu na 5minut
		WHEN @RoundTo = 10 THEN dateadd(MINUTE, datediff(MI, 0, @Time) + CASE WHEN DATEPART(MINUTE, @Time) > 0 THEN -(DATEPART(MINUTE, @Time) % 10) ELSE 0 END, 0)		-- zakrouhleni dolu na 10minut
		WHEN @RoundTo = 15 THEN dateadd(MINUTE, datediff(MI, 0, @Time) + CASE WHEN DATEPART(MINUTE, @Time) > 0 THEN -(DATEPART(MINUTE, @Time) % 15) ELSE 0 END, 0)		-- zakrouhleni dolu na 15minut
		WHEN @RoundTo = 30 THEN dateadd(MINUTE, datediff(MI, 0, @Time) + CASE WHEN DATEPART(MINUTE, @Time) > 0 THEN -(DATEPART(MINUTE, @Time) % 30) ELSE 0 END, 0)		-- zakrouhleni dolu na 30minut
		WHEN @RoundTo = 60 THEN dateadd(HH, datediff(HH, 0, @Time), 0)		-- vynulovani minut - zaokrouhleni na hodiny
		WHEN @RoundTo = 1440 THEN dateadd(DD, datediff(DD, 0, @Time), 0)	-- vynulovani hodin - zaokrouhleni na den
		WHEN @RoundTo = 10080 THEN dateadd(WW, datediff(WW, 0, @Time), 0)	-- zaokrouhleni na kalendarni tyden
		WHEN @RoundTo = 44640 THEN dateadd(MM, datediff(MM, 0, @Time), 0)	-- zaokrouhleni na kalendarni mesic
		
		ELSE convert(smalldatetime,ROUND(cast(Cast(@Time as smalldatetime) as float) * ((24.0*60*60)/@RoundTo),0)/((24.0*60*60)/@RoundTo)) -- vychozi zaokrouhleni dle minut
	END
	
   RETURN @RoundedTime 

END

GO

