USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[Switchlog]    Script Date: 29. 6. 2017 11:18:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <29.06.2017>
-- Description:	<Přepínání logování>
-- =============================================
CREATE PROCEDURE [dbo].[Switchlog]
@ConfigurationName nvarchar(50),
@ConfigurationValue NVARCHAR(50),
@SwitchOn bit
AS
BEGIN
 DECLARE @ExistValue AS bit = IIF(EXISTS(SELECT * FROM iCC.dbo.Configuration WHERE ConfigurationName=@ConfigurationName AND ConfigurationValue LIKE
  '%'+@ConfigurationValue+'%'),1,0)
  IF @ExistValue=1 AND @SwitchOn=0 -- Vypnutí parametru
    UPDATE iCC.dbo.Configuration
       SET ConfigurationValue= REPLACE (ConfigurationValue, ','+@ConfigurationValue, '')
        WHERE ConfigurationName=@ConfigurationName
  IF @ExistValue=0 AND @SwitchOn=1 -- Zapnutí parametru
    UPDATE iCC.dbo.Configuration
       SET ConfigurationValue=ConfigurationValue+','+@ConfigurationValue
        WHERE ConfigurationName=@ConfigurationName

END


GO

