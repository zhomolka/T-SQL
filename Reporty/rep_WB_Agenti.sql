USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_WB_Agenti]    Script Date: 3. 1. 2020 15:10:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2017-01-13
-- Description:	Denní činnost agentů (z Wallboardu)
-- Na přání Davida Pintara přičítám u konečného datumu den, protože mu to takto přijde příhodnější
-- =============================================
CREATE FUNCTION [dbo].[rep_WB_Agenti] (@from datetime,@to datetime)
RETURNS TABLE
AS
RETURN
(
  select WBA.displayName,WBA.GroupName,WBA.PocetPrichodu,WBA.PocetOdchodu,WBA.PocetZprav,WBA.PocetChatu, WBA.Diverted, AP.Pripady AS Pripady from fs_custom.dbo.WallboardAgenti (@from, @To+1) AS WBA
  LEFT JOIN Agenti_Pripady(@from, @To+1) AS AP ON AP.Agent=WBA.displayName
 )




GO

