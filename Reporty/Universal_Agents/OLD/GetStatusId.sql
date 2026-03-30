USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[GetStatusId]    Script Date: 1/4/2019 2:36:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <3.1.2019>
-- Description:	<Vrací NOT READY Agent StatusId podle pořadí>
-- =============================================
CREATE FUNCTION [dbo].[GetStatusId]
(
	-- Add the parameters for the function here
	@Order as Integer
)
RETURNS UniqueIdentifier
AS
BEGIN
	DECLARE @StatusId as UniqueIdentifier = 
 (SELECT StatusId FROM
 (
  -- Spuštěním části níže se objeví statusy v abecedním pořadí
  SELECT [StatusId]
      ,[DisplayName]
	  , ROW_NUMBER() OVER (ORDER BY DisplayName) AS Row
   FROM [iCC].[dbo].[Status] WHERE (Activity='Pause' OR Activity='PostCall') AND Deleted=0 

    ) AS Phase1 WHERE ROW=@Order)	
   RETURN @StatusId

END


