USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[CallExist]    Script Date: 5. 2. 2021 11:21:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <19.11.2020>
-- Description:	Kontroluje, zda na CallerNumber existuje po určeném čase hovor
-- =============================================
CREATE FUNCTION [dbo].[CallExist]
(
	-- Add the parameters for the function here
	@CallerNumber  AS NVARCHAR(50)
	,@LastCall as Datetime
)
RETURNS integer
AS
BEGIN
	DECLARE @exCall as integer = 0
	IF (SELECT TOP 1 1 FROM  ICC.dbo.InboundCall WITH (NOLOCK) 
	  WHERE TimeUTC>DATEADD(Hour,-2,@LastCall) AND @CallerNumber=CallerNumber and PilotTime>@LastCall AND (CallResult='Served' OR CallResult='Active'))=1
	  OR
	  (SELECT TOP 1 1 FROM  ICC.dbo.OutboundCall WITH (NOLOCK) 
	  WHERE @CallerNumber=CallerNumber and DistributionTime>@LastCall)=1
		BEGIN
		  SET @exCall = 1  -- Hovor existuje
		END
	RETURN @exCall

END

GO

