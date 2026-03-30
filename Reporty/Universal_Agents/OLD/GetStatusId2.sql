USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[GetStatusId2]    Script Date: 1/31/2019 14:28:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <31.1.2019>
-- Description:	<Vrací stavy agentů StatusId podle Activity a pořadí>
-- =============================================
CREATE FUNCTION [dbo].[GetStatusId2]
(
	-- Add the parameters for the function here
	@Order as Integer
   ,@Activity as nvarchar(32)
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
   FROM [iCC].[dbo].[Status] WHERE Activity=@Activity AND Deleted=0

    ) AS Phase1 WHERE ROW=@Order)	
   RETURN @StatusId

END



GO

