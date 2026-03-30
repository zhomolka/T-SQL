USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[LostCalls]    Script Date: 5. 2. 2021 11:26:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Zbyněk Homolka
-- Create date:  2020-12-23
-- Description:	Ztracené hovory
-- =============================================
CREATE FUNCTION [dbo].[LostCalls] (
	
	@From AS DATETIME, 
	@To AS DATETIME

)
RETURNS TABLE
AS
RETURN
(
  SELECT 
	   PilotTime AS LastCall
       --   ,MAX(InboundCallId) AS InboundCallId
	  , IC.CallerNumber
	  , QueueDuration
	  , ISNULL(AG.DisplayName,'--- Bez Agenta ---') AS AgentName
	  , CNT.Department AS RCICO
      , IIF(OC.CallDuration>3,'Vyřízen','Nevyřízen') AS CallResult
   FROM iCC.[dbo].[InboundCall] IC with(nolock)
     LEFT JOIN iCC.[dbo].[OutboundCall] OC with(nolock) ON IC.CallerNumber=OC.CallerNumber AND OC.DistributionTime>PilotTime
	 left join icc.dbo.PhoneNumber PN with(nolock) on PN.Numbers=IC.CallerNumber 
	 left join icc.dbo.Contact CNT with(nolock) on PN.ContactId=CNT.ContactId 
	 left join icc.dbo.agent AG with(nolock) on AG.agentid=OC.agentid 
    WHERE PilotTime>@From AND PilotTime<@To AND IC.EnqueueingTime IS NOT NULL
   AND IC.CallResult ='lost'
  
-- WHERE FS_CUSTOM.dbo.CallExist(CallerNumber,LastCall)=0

);


GO

