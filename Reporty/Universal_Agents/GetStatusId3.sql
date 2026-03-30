USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[GetStatusId3]    Script Date: 22. 10. 2019 17:38:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <31.1.2019>
-- Description:	<Vrací stavy agentů StatusId podle skupina Activity a pořadí>
-- =============================================
CREATE FUNCTION [dbo].[GetStatusId3]
(
	-- Add the parameters for the function here
	@Order as Integer
   ,@StatusGroup AS NVARCHAR(2)
)
RETURNS UniqueIdentifier
AS
BEGIN
   RETURN (SELECT StatusId FROM fs_custom.dbo.Rep_Statuses(@StatusGroup) WHERE Row=@Order)

END



GO

