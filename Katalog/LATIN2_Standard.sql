USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[LATIN2_Standard]    Script Date: 5/4/2021 2:06:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[LATIN2_Standard]
@Chatid AS Uniqueidentifier
AS
-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <3.3.2021>
-- Description:	<Provádí konverzi řetězců LATIN2 do standardní formy: znaky s diakritikou atd.
-- =============================================

BEGIN
  DECLARE @Loguj AS Bit=1
  DECLARE @ProcName AS Varchar(20) = SUBSTRING(object_name(@@PROCID),1,20)
  DECLARE @Popis AS nvarchar(MAX)
   UPDATE iCC.dbo.Chat
  
SET Bodytext=
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([BodyText],
	  '&amp;#253;','ý'),
	  '&amp;#221;','Ý'),
	  '&amp;#225;','á'),
	  '&amp;#193;','Á'),
	  '&#x17E;','ž'),
	  '&#x17D;','Ž'),
	  '&amp;#233;','é'),
	  '&amp;#201;','É'),
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
	  '&amp;#243;','ó'),
	  '&amp;#244;','ô'),
	  '&amp;#250;','ú'),
	  '&#x10F;','ď'),
	  '&#x165;','ť'),
	  '&#x13E;','ľ'),
	  '&#x1F60A;',':)'),  
	  '&#x263A;',':)'), 
	  '&#x1F642;',':)'), 
	  '&#x1F614;',':('), 
	  '&amp;#214;','Ö'),  
	  '&#x2B;','+'), 
	  '&amp;#168;','¨'),  	   
	  '&amp;#205;','Í'), 
	  '&amp;#39;', 'I'''),
	  '&amp;#237;','í')
	    WHERE  (Chatid = @Chatid)
  SET @Popis = 'Konverze na chatu Chatid='+CONVERT(NVARCHAR(50),@Chatid)
  EXEC  .[dbo].[WriteEvent] @Loguj, @ProcName, @Popis
END

GO

