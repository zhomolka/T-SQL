USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[ReplaceSmilyes]    Script Date: 23.04.2019 8:57:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbynìk Homolka>
-- Create date: <14.12.2018>
-- Description:	<Pøepisuje smajlíky otazníky (všechny tyto znaky SQL detekuje jako otazník)>
-- =============================================

CREATE function [dbo].[ReplaceSmilyes] (
    @nstring nvarchar(4000)
)
returns NVARCHAR(4000)
as begin
   DECLARE @Result varchar(4000) = '' 
   DECLARE @nchar nvarchar(1)
   DECLARE @position int
   SET @position = 1
   WHILE @position <= LEN(@nstring)
   BEGIN
      SET @nchar = SUBSTRING(@nstring, @position, 1)  
      IF UNICODE(@nchar) between 32 and 400
         SET @Result = @Result + @nchar
      SET @position = @position + 1
   END
return @Result
END
GO

