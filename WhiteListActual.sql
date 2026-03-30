USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[WhiteListActual]    Script Date: 21. 9. 2018 9:38:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[WhiteListActual]
--@OCId UniqueIdentifier 
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <20.9.2018>
-- Description:	<Doplnění Whitelist o nové lékárny>
-- =============================================

BEGIN

DECLARE @NullId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @ContactId AS UniqueIdentifier=@NullId
DECLARE @Pokracuj AS bit = 1


WHILE (@ContactId IS NOT NULL) 
 BEGIN  
   SET @ContactId = (SELECT TOP 1 CO.ContactId FROM [Icc].[dbo].[Contact] CO LEFT JOIN [Icc].[dbo].[ContactComposition] CC ON CO.ContactId=CC.ContactId  AND PhoneBookId='73bbafcc-f657-4775-97dd-71554bb4ee2b'
 WHERE CC.ContactId IS NULL AND CO.Model='Pharmacy')
   IF  @ContactId IS NOT NULL
     BEGIN
	  INSERT INTO [iCC].[dbo].[ContactComposition]
			   (
				[PhoneBookId]
			   ,[ContactId])
		   VALUES
			   (
			   '73bbafcc-f657-4775-97dd-71554bb4ee2b', -- Whitelist
			   @ContactId)
 	END
  END
 END




GO

