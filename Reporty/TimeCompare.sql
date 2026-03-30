USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[TimeCompare]    Script Date: 19. 2. 2018 16:19:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <15.2.2018>
-- Description:	<Porovnává čas Datetime položky s časem NVARCHAR>
-- =============================================

CREATE FUNCTION [dbo].[TimeCompare](@DateTime as DateTime, @OPERATOR AS NVARCHAR(1) , @NVARCHAR AS NVARCHAR(5))
RETURNS int
AS
BEGIN
	DECLARE @CompareValid as int = 0
	DECLARE @MyTime as  NVARCHAR(5)
	SET @MyTime=LEFT(CONVERT(NVARCHAR(8),@DateTime,108),5)
	SET @NVARCHAR=RTRIM(LTRIM(@NVARCHAR))
	SET @NVARCHAR=@NVARCHAR+IIF(ISNULL(CHARINDEX(':',@NVARCHAR),0)>0,'',':00')
	SET @NVARCHAR=IIF(LEN(@NVARCHAR)<5,'0','')+@NVARCHAR
	SET @NVARCHAR=@NVARCHAR+IIF(LEN(@NVARCHAR)<5,'0','')
	IF  @OPERATOR='<'
	  SET @CompareValid=IIF(@MyTime<=@NVARCHAR,1,0)
    ELSE
	  SET @CompareValid=IIF(@MyTime>=@NVARCHAR,1,0)	
	RETURN @CompareValid
END
--

GO

