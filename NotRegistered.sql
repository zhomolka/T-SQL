USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[NotRegistered]    Script Date: 06.09.2022 16:02:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <6.9.2022>
-- Description:	<vrací počet nezaregistrovaných poboček>
-- =============================================
CREATE FUNCTION [dbo].[NotRegistered]
(
)
RETURNS Integer
AS
BEGIN
	RETURN (select count(*) AS Pocet from Proserver.dbo.extension EX
       where EX.Deleted=0 AND Suspended=0 AND OnLineStatus=10)
END
GO

