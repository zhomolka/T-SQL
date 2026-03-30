USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[ReturnMail2]    Script Date: 6. 10. 2016 10:45:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jan Techl
-- Create date: 21.9.2016
-- Description:	Replacing the previous procedure dbo.Return_Mail as it did not handle the wrong input for substring function and caused error
-- =============================================
CREATE FUNCTION [dbo].[ReturnMail2] 
(
	-- Add the parameters for the function here
	@cTofield Varchar(max)

)
RETURNS Varchar(max)
AS
BEGIN
	declare @leftPosition as int = charindex('<',@cTofield)
	declare @rightPosition as int = charindex('>',@cTofield)
	declare @email as varchar(max)

	IF @leftPosition = 0 or @leftPosition is null
	SET	@email = @cToField
	
	ELSE 

	SELECT @email = SUBSTRING(@cTofield, @leftPosition+1, CASE WHEN (@rightPosition - @leftPosition -1) < 0 THEN 0 ELSE (@rightPosition - @leftPosition -1) END)
	
	
	-- Return the result of the function
	RETURN @email

END

GO

