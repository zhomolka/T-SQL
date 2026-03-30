USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[Rep_ProvozniLE3]    Script Date: 26. 5. 2017 12:42:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <06-10-2015>
-- Description:	<Přijaté hovory>
-- 12.10.2015 ZbH prohodil na žádost Ivety AvailabilityTime a Occupancy 
-- 03.02.2016 ZbH přidal sloupec Do5Sekund
-- 29.2.2016 MiH přidal sloupec VyzvednuteHovoryOUT, DistribuovaneOUT
-- 15.5.2017 ZbH - změna výpočtu Occupancy + PocetHovoruPracDobe - nastavení pracovní doby natvrdo
-- =============================================
CREATE FUNCTION [dbo].[Rep_ProvozniLE3]  
(
	@from AS datetime, 
	@to AS datetime,
	@SL as int,
	@Interval as char(1), -- Možné hodnoty jsou Y,M,W,D,h,t,q,f
	@Linky as char(1)

)
RETURNS 
 @Provozni TABLE 
(
	Col1 NVARCHAR(1)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT @Provozni
    SELECT 1 AS Col1
 
	
	RETURN 
END

GO

