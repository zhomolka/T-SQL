USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[Rep_Statuses]    Script Date: 12/9/2019 1:26:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <22.10.2019>
-- Description:	<Vrací Seznam stavů>
-- =============================================
CREATE FUNCTION [dbo].[Rep_Statuses] 
(	
	@StatusGroup AS NVARCHAR(2)
)
RETURNS TABLE 
AS
RETURN 
(
 SELECT StatusId,[DisplayName]
   , ROW_NUMBER() OVER (ORDER BY DisplayName) AS Row -- Pro identifikaci statusu pomocí pořadí
   FROM iCC.[dbo].[Status] WHERE (
   @StatusGroup='NR' AND (Activity='Pause' OR Activity='PostCall') OR
   @StatusGroup='RD' AND (Activity='Ready') OR
   @StatusGroup='LO' AND (Activity='Logoff') 
   )
   AND Deleted=0 
   -- Vycpávka pro neexistující stavy - report tyto vycpávky nezobrazuje
   UNION ALL
     SELECT '00000000-0000-0000-0000-000000000000','ž Rezerva',50
   UNION ALL
     SELECT '00000000-0000-0000-0000-000000000000','ž Rezerva',50
   UNION ALL
     SELECT '00000000-0000-0000-0000-000000000000','ž Rezerva',50


)




GO

