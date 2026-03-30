USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[HtmlToText]    Script Date: 1/8/2021 2:19:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbynìk Homolka>
-- Create date: <8.1.2021>
-- Description:	<Convert BodyHtMl to BodyText)>
-- =============================================

CREATE function [dbo].[HtmlToText] (
    @nstring nvarchar(MAX)
)
returns NVARCHAR(MAX)
as begin
   DECLARE @Result varchar(MAX) = '' 
   DECLARE @nchar nvarchar(1)
   DECLARE @position int
   DECLARE @Textposition int = -1
   SET @position = 1
   WHILE @position <= LEN(@nstring)
   BEGIN
      SET @nchar = SUBSTRING(@nstring, @position, 1)  
      IF @nchar='<' OR @nchar='&' SET @Textposition  = -1
	  ELSE
	   IF @nchar='>' SET @Textposition = 1
	   ELSE
	     IF @Textposition>0
           SET @Result = @Result + @nchar
      SET @position = @position + 1
	  IF SUBSTRING(@nstring, @position, 3)='v\:' SET @Textposition = -1
   END
return @Result
END
GO

