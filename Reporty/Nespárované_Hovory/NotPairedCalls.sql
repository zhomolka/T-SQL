USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[NotPairedCalls]    Script Date: 17. 12. 2020 11:17:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17.12.2020>
-- Description:	<Nespárované hovory>
-- =============================================
CREATE FUNCTION [dbo].[NotPairedCalls]
(	
@From datetime, @To datetime
)
RETURNS TABLE 
AS
RETURN 
(

SELECT * FROM (
SELECT TOP 1000
      'O' AS Direction
	  , NULL AS Redirector
	  , CallerNumber
	  , WP.Number
	  , WP.DisplayName AS WorkPlaceName
      , OC.[OutboundCallId] AS Id
      ,DistributionTime AS CallTime
  FROM iCC.[dbo].[OutboundCall] OC WITH (NOLOCK)
    LEFT JOIN iCC.[dbo].[CallRecord] CR WITH (NOLOCK) ON CR.OutboundCallId=OC.OutboundCallId
    LEFT JOIN iCC.[dbo].[Workplace] WP ON WP.WorkplaceId=OC.WorkplaceId
  WHERE DistributionTime>@From AND DistributionTime<@To
  AND CallDuration>1
  AND CR.OutboundCallId IS NULL 
    AND LEN(RTRIM(CallerNumber))>6
   AND CallResult<>'Canceled'
  UNION
  SELECT TOP 1000
      'I' AS Direction
	  , Redirector
	  , CallerNumber
	  , WP.Number
      , WP.DisplayName AS WorkPlaceName
      , IC.[InboundCallId] AS Id
      ,[PilotTime]  AS CallTime
  FROM iCC.[dbo].[InboundCall] IC
    LEFT JOIN iCC.[dbo].[CallRecord] CR ON CR.InboundCallId=IC.InboundCallId
    LEFT JOIN [SRec].[dbo].[Directory] DI ON RIGHT(DI.Number,3)=IC.Redirector
    LEFT JOIN iCC.[dbo].[Workplace] WP ON WP.WorkplaceId=IC.WorkplaceId
  WHERE PilotTime>@From AND PilotTime<@To
  AND CallDuration>1
  AND CR.INboundCallId IS NULL   
  AND CallResult ='served'
  AND LEN(RTRIM(CallerNumber))>6
  --AND Redirector NOT LIKE '7%'
  AND isnull(DI.Record,1) <>0
    AND (FS_CUSTOM.dbo.CustomCheck2('IC',WP.DisplayName)=1 OR FS_CUSTOM.dbo.CustomCheck2('ID',IC.Redirector)=1)
  ) AS Phase1
 -- ORDER BY CallTime DESC
)


GO

