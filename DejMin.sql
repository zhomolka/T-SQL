USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[DejMin]    Script Date: 25.8.2017 13:09:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date: 25.8.2017
-- Description:	Vrací menší ze zadaných hodnot
-- =============================================

CREATE FUNCTION [dbo].[DejMin] (@Value1 REAL, @Value2 REAL) 
RETURNS REAL 
AS 
BEGIN 
 IF @Value1>@Value2
   RETURN @Value2
-- ELSE
   RETURN @Value1 

END



GO

