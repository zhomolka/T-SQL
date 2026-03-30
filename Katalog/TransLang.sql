USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[TransLang]    Script Date: 11. 9. 2018 15:45:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:
-- Description:	Vrací překlad z ENG (FS) do určeného Culture
-- =============================================


CREATE FUNCTION [dbo].[TransLang]
(
	@Text as NVARCHAR(50),
	@Culture as varchar(5)

)									
RETURNS nvarchar(MAX)
AS
BEGIN

   RETURN (SELECT TOP 1 DisplayName FROM [iCC].[dbo].[LiteralLookup] LL WITH (NOLOCK) WHERE LL.LiteralText=@Text AND LL.Culture=@Culture
)
 		
END
GO

