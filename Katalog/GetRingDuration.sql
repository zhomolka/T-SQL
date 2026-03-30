USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[GetRingDuration]    Script Date: 10/27/2020 3:34:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <27.10.2020>
-- Description:	<Vrací skutečnou RingDuration>
-- =============================================
CREATE FUNCTION [dbo].[GetRingDuration]
(
	-- Add the parameters for the function here
	@RingDuration as Integer
)
RETURNS Integer
AS
BEGIN
 RETURN @RingDuration%(SELECT AVG(MaxRinging) FROM iCC.dbo.Workplace WHERE Deleted=0)  

END


GO

