USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[Upd_Tile]    Script Date: 6/11/2019 4:49:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Upd_Tile]
	@NameLine [varchar](10) ,
	@Rank [int] ,
	@Text [varchar](50) ,
	@Number [nvarchar](10) ,
	@BackColor [varchar](7),
	@FrontColor [varchar](7),
	@Glyph [varchar](30) 

AS
-- =============================================
-- Author:		<Zbynìk Homolka>
-- Create date: <11.6.2019>
-- Description:	<Aktualizuje FS_Custom.dbo.Tiles>
-- =============================================

BEGIN
	IF EXISTS(SELECT 1 FROM FS_custom.dbo.Tiles WHERE NameLine=@NameLine AND Rank=@Rank)
      UPDATE FS_custom.dbo.Tiles
       SET Text = @Text, Number = @Number, BackColor = @BackColor, FrontColor = @FrontColor, Glyph = @Glyph  
       WHERE NameLine=@NameLine AND Rank=@Rank
	ELSE
 	  INSERT INTO FS_custom.dbo.Tiles (NameLine, Rank, Text , Number, BackColor, FrontColor, Glyph)
		values(@NameLine, @Rank, @Text , @Number, @BackColor, @FrontColor, @Glyph )	
  
END

GO

