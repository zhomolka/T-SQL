USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[rep_EmailDetail]    Script Date: 8. 2. 2019 17:07:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <16.3.2017>
-- Description:	<Detailní přehled e-mailů>
-- =============================================
CREATE FUNCTION [dbo].[rep_EmailDetail]
(	
	@From datetime,
	@To datetime
)
RETURNS TABLE 
AS
RETURN 
(
select ReceivedSentTime,
  ME.MessagePhase,
  ME.TeamName,
  ME.FromField,
  ME.RemoteAddress,
  IIF(ME.RelatedMessageId IS NULL,1,0) AS Unikatni,
  GW.DisplayName AS GWName,
  --ISU.FormDataId,
  --iCC.[dbo].[GetTargetColumnText] (ISU.FormDataId, 'cislo_sml' ) AS Smlouva
 CON.CompanyName AS Smlouva

 FROM iCC.dbo.MESSAGE AS ME WITH (NOLOCK)
   LEFT JOIN iCC.dbo.Gateway AS GW  WITH (NOLOCK) ON GW.GatewayId=ME.GatewayId
   --LEFT JOIN iCC.dbo.Issue AS ISU  WITH (NOLOCK) ON ISU.IssueId=ME.IssueId
  LEFT JOIN iCC.dbo.Contact AS CON  WITH (NOLOCK) ON CON.ContactId=ME.ContactId
 where ReceivedSentTime>=@From AND ReceivedSentTime<=@To
 AND ME.Direction='I'
)


GO

