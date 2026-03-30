USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[WB_OutCalls]    Script Date: 21. 2. 2023 15:05:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2023-02-21
-- Description:	Řádek do Wallboardu o Odchozích hovorech
-- =============================================
CREATE FUNCTION [dbo].[WB_OutCalls] (@today datetime)
RETURNS TABLE
AS
RETURN
     (
 select
IIF(Column1='ServedCalls',6,IIF(Column1='LostCalls',2,IIF(Column1='InCalls',3,IIF(Column1='ServedThreshold',4,IIF(Column1='ServedCallsAfterThreshold',5,6))))) as Rank,
IIF(Column1='ServedCalls','Odchozí hovory',IIF(Column1='LostCalls','Ztracené hovory',IIF(Column1='InCalls','Hovory celkem',IIF(Column1='ServedThreshold','Hovory do 20 sec. / nad 20 sec.',IIF(Column1='ServedCallsAfterThreshold','Hovory do 20 sec. / nad 20 sec.','-----'))))) AS Text
,convert(nvarchar(10),Number) as Number
,'#ccff99' as BackColor
,'#000000' as FrontColor
,IIF(Column1='LostCalls','fa fa-trash','fa fa-phone') as Glyph

 FROM (
select  [Column1], [Number]
from 
    (   -- select relevant columns from source 
        select  ServedCalls
        from (
		SELECT convert(nvarchar(10),ServedCalls) AS ServedCalls 
		from (
		SELECT	
	   ISNULL(SUM(1),0) AS ServedCalls	
FROM ICC.dbo.OutboundCall AS C WITH (NOLOCK)
--left join icc.dbo.Project as P with(nolock) on C.ProjectId = P.ProjectId	
WHERE DistributionTime >= @Today AND TeamName='CC' AND AnswerTime IS NOT NULL
	    ) AS Phase1 
		) AS Corn
    ) as piv
UNPIVOT (
        [Number] 
        for [Column1] in (ServedCalls) 
    ) as unpiv
	) AS Phase2



)


GO

