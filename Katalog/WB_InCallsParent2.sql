USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[WB_InCallsParent2]    Script Date: 21. 2. 2023 15:05:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[WB_InCallsParent2] ()
-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2019-10-10
-- Description:	Řádek do Wallboardu o Příchozích hovorech
-- =============================================

RETURNS 
 @results TABLE 
(
	-- Add the column definitions for the TABLE variable here
	Rank int, 
	Text NVARCHAR(100),
	Number NVARCHAR(20),
	BackColor NVARCHAR(20),
	FrontColor NVARCHAR(20),
	Glyph NVARCHAR(20)
	)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	DECLARE @today AS Datetime=FS_CUSTOM.dbo.[TodayStartWorkTime]('PRACDOBA')
    INSERT @results select * FROM .dbo.WB_InCalls2(@today) WHERE Rank<4
	INSERT @results select * FROM .dbo.WB_OutCalls(@today)	
	RETURN 
END

GO

