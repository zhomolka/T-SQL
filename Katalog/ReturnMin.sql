USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[ReturnMin]    Script Date: 30. 1. 2020 8:35:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 30.1.2020
-- Description:	Převádí časový interval ve znakovém vyjádření na počet minut
-- =============================================

CREATE FUNCTION [dbo].[ReturnMin]
(
  @Interval as char(1) -- Možné hodnoty jsou Y,M,W,D,h,t,q,f
)
RETURNS int
AS
BEGIN
	-- Return the result of the function	
	RETURN 
	CASE  
     WHEN @Interval='Y' THEN 535680 
     WHEN @Interval='M' THEN 44640 
     WHEN @Interval='W' THEN 10080 
     WHEN @Interval='D' THEN 1440 
	 WHEN @Interval='h' THEN 60 
	 WHEN @Interval='t' THEN 30 
     WHEN @Interval='q' THEN 15 
	 WHEN @Interval='f' THEN 5 
	 ELSE 1   
    END 

END

GO

