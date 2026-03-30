USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[Latin2Convr]    Script Date: 25.06.2021 9:32:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <24.06.2021>
-- Description:	<Provádí konverzi řetězců LATIN2 do standardní formy: znaky s diakritikou atd.
-- =============================================

CREATE function [dbo].[Latin2Convr] (
    @nstring nvarchar(4000),
	@Substr AS NVARCHAR(6)
)
returns NVARCHAR(4000)
as begin
  --Někde je @Substr='' , někde 'amp;'
  DECLARE @Result varchar(4000) = 

REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(--REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@nstring,
	  '&'+@Substr+'#253;','ý'),
	  '&'+@Substr+'#221;','Ý'),
	  '&'+@Substr+'#225;','á'),
	  '&'+@Substr+'#228;','ä'),
	  '&'+@Substr+'#224;','á'),
	  '&'+@Substr+'#193;','Á'),
	  '&#x17E;','ž'),
	  '&#x17D;','Ž'),
	  '&'+@Substr+'#233;','é'),
	  '&'+@Substr+'#234;','ě'),
	  '&'+@Substr+'#43;','+'),
	  '&'+@Substr+'#201;','É'),
	  '&#x161;','š'),
	  '&#x160;','Š'),
	  '&#x159;','ř'),
	  '&#x11B;','ě'),
	  '&#x11A;','Ě'),
	  '&#x16F;','ů'),
	  '&#x16E;','ů'),	  
	  '&#x148;','ň'),
	  '&#x10D;','č'),
	  '&#x10C;','Č'),
	  '&'+@Substr+'#243;','ó'),
	  '&'+@Substr+'#244;','ô'),
	  '&'+@Substr+'#250;','ú'),
	  '&'+@Substr+'#218;','Ú'),
	  '&#x10F;','ď'),
	  '&#x165;','ť'),
	  '&#x13E;','ľ'),
	  '&nbsp;','€'),
	  '&#x1F60A;',':)'),  
	  '&#x263A;',':)'), 
	  '&#x1F642;',':)'), 
	  '&#x1F614;',':('), 
	  '&'+@Substr+'#214;','Ö'),  
	  '&'+@Substr+'#215;','×'),  
	  '&#x2B;','+'), 
	  '&'+@Substr+'#168;','¨'), 
	  '&'+@Substr+'#167;','§'), 
      '&'+@Substr+'#180;','´'), 	  
	  '&'+@Substr+'#205;','Í'), 
	  '&'+@Substr+'#209;','Ň'), 
	  '&quot;','"'), 
	  '&'+@Substr+'#39;', 'I'''),
	  '&'+@Substr+'#239;','í'),
	  '&'+@Substr+'#237;','í')

 return @Result
END
GO

