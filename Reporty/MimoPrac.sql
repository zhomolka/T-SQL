USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[MimoPrac]    Script Date: 8. 3. 2018 9:53:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <4-10-2017>
-- Description:	Posuzuje, zda byl hovor v pracovní době
-- ======================================================

CREATE function [dbo].[MimoPrac] (
    @Redirector NVARCHAR(24),
	@CallTime datetime 
)
returns bit
as begin
--(DATEPART(weekday,i.pilottime) NOT IN (1,7) AND FS_custom.dbo.IsHoliday(i.pilottime)=0 AND (DATEPART(hour,i.pilottime)>=8 AND DATEPART(hour,i.pilottime)<=17
    DECLARE @IsHoliday AS bit = IIF(FS_custom.dbo.IsHoliday(@CallTime)=1 OR DATEPART(weekday,@CallTime)=1,1,0)
	IF @Redirector='9533' -- Call Centrum Brno
	  BEGIN
		--SET @Zacatek=DATETIMEFROMPARTS ( year(ic.pilottime), month(ic.pilottime), day(ic.pilottime), 7, 0, 0, 0 )
		IF @IsHoliday=1 OR DATEPART(weekday,@CallTime)=7
		  BEGIN
		     -- Víkendový a sváteční provoz
		     IF DATETIMEFROMPARTS(year(@CallTime), month(@CallTime), day(@CallTime), 9, 30, 0, 0 )>@CallTime
			   RETURN 1
		     IF DATETIMEFROMPARTS(year(@CallTime), month(@CallTime), day(@CallTime), 20, 0, 0, 0 )<@CallTime
			   RETURN 1
          END
        ELSE
		  BEGIN
		     -- Provoz všedního dne
		     IF DATETIMEFROMPARTS(year(@CallTime), month(@CallTime), day(@CallTime), 7, 0, 0, 0 )>@CallTime
			   RETURN 1
		     IF DATETIMEFROMPARTS(year(@CallTime), month(@CallTime), day(@CallTime), 21, 0, 0, 0 )<@CallTime
			   RETURN 1
		  END
	  END
    ELSE --  9722 -- Dispečink
	  BEGIN
		IF @IsHoliday=1 
		  BEGIN
		     -- sváteční provoz není
			 RETURN 1
          END
        ELSE
		  BEGIN
		     IF DATEPART(weekday,@CallTime)=7 -- Sobota
			  BEGIN
				 IF DATETIMEFROMPARTS(year(@CallTime), month(@CallTime), day(@CallTime), 8, 0, 0, 0 )>@CallTime
				   RETURN 1
				 IF DATETIMEFROMPARTS(year(@CallTime), month(@CallTime), day(@CallTime), 16, 30, 0, 0 )<@CallTime
				   RETURN 1
			  END			   
			 ELSE
		     -- Provoz všedního dne
			  BEGIN
				 IF DATETIMEFROMPARTS(year(@CallTime), month(@CallTime), day(@CallTime), 8, 0, 0, 0 )>@CallTime
				   RETURN 1
				 IF DATETIMEFROMPARTS(year(@CallTime), month(@CallTime), day(@CallTime), 19, 0, 0, 0 )<@CallTime
				   RETURN 1
              END
		  END	    
	  END
return 0
END
GO

