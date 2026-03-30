USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[GiveDuration]    Script Date: 17. 5. 2021 9:39:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17.5.2021>
-- Description:	<čas ve formátu 00:00:00>
-- =============================================
CREATE FUNCTION [dbo].[GiveDuration]
(
	-- Add the parameters for the function here
	@Duration AS Integer
)
RETURNS NVARCHAR(8)
AS
BEGIN
	DECLARE @seconds AS Integer = @Duration 
	DECLARE @minutes AS Integer = @seconds / 60 
	DECLARE @hours   AS Integer = @minutes / 60 
	DECLARE @Result AS NVARCHAR(8) = ''
	SET @minutes = @minutes % 60 
	SET @seconds = @seconds % 60 
	SET @Result = RIGHT('0'+CONVERT(NVARCHAR(2),@hours),2)+':'+
	              RIGHT('0'+CONVERT(NVARCHAR(2),@minutes),2)+':'+
	              RIGHT('0'+CONVERT(NVARCHAR(2),@seconds),2) 
	RETURN @Result
END

GO

