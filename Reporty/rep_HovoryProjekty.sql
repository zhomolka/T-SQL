USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_HovoryProjekty]    Script Date: 12.10.2023 11:44:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Jiří Stejskal>
-- Create date: <27.4.2016>
-- Description:	<Report projektů a hovorů>

-- =============================================
CREATE FUNCTION [dbo].[rep_HovoryProjekty]
(	
@from datetime,
@to datetime,
@Interval as char(1) -- Možné hodnoty jsou Y,M,W,D,h,t,q,f
)
RETURNS TABLE 
AS
RETURN 
/*
PROJEKTY (podklad pro report managementu)
-	počet příchozí hovorů nad projektem
-	počet přijatých hovorů nad projektem
-	počet přijatých hovorů nad projektem do 20 s
-	počet odchozích hovorů
-	počet odchozích hovorů spojených
*/


(
select 
b.s
,b.E
,p.ProjectId
,p.DisplayName
,(select count(*) from icc.dbo.inboundcall i with (nolock) where PilotTime>=b.s and PilotTime<b.e and p.projectid=i.ProjectId) as PocetPrichozich
,(select SUM(CallDuration) from icc.dbo.inboundcall i with (nolock) where PilotTime>=b.s and PilotTime<b.e and p.projectid=i.ProjectId) as CallsDurationI
,(select count(*) from icc.dbo.inboundcall i with (nolock) where PilotTime>=b.s and PilotTime<b.e and p.projectid=i.ProjectId and AnswerTime is not null) as PocetPrijatych
,(select count(*) from icc.dbo.inboundcall i with (nolock) where PilotTime>=b.s and PilotTime<b.e and p.projectid=i.ProjectId and AnswerTime is not null and QueueDuration<=20) as PocetPrijatychDvacetVterin
,(select count(*) from icc.dbo.OutboundCall o with (nolock) where DistributionTime>=b.s and DistributionTime<b.e and p.ProjectId =o.ProjectId) as PocetOdchozich
,(select SUM(CallDuration) from icc.dbo.OutboundCall o with (nolock) where DistributionTime>=b.s and DistributionTime<b.e and p.ProjectId =o.ProjectId) as CallsDurationO
,(select count(*) from icc.dbo.OutboundCall o with (nolock) where DistributionTime>=b.s and DistributionTime<b.e and p.ProjectId =o.ProjectId and AnswerTime is not null) as PocetOdchozichSpojenych
from
icc.dbo.Rep_DateTime(@from,@to,@Interval) b cross join icc.dbo.Project p with (nolock)
where p.Deleted=0

)

GO

