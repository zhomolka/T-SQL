USE [FS_Custom]
GO
/****** Object:  UserDefinedFunction [dbo].[CallbackCheck_AltiTest]    Script Date: 8/31/2022 10:45:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author: Jiří Stejskal>
-- Create date: <9.12.2014>
-- Description:	<zjišťuje zda je číslo OK>
-- =============================================
ALTER FUNCTION [dbo].[CallbackCheck_AltiTest](
@NEWCALLERNUMBER as nvarchar(32)
)
RETURNS NVARCHAR(30)

AS
BEGIN
declare @CHECK as nvarchar(30)

SET @CHECK = CASE WHEN LEN(@NEWCALLERNUMBER) = 10 and  ISNUMERIC(@NEWCALLERNUMBER)=1 THEN  'OK'  ELSE  'KO' END
 
RETURN @CHECK

END 







