USE [FS_custom]
GO
/****** Object:  UserDefinedFunction [dbo].[IsHoliday]    Script Date: 21. 2. 2018 17:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <18.10.2019>
-- Description:	<Zjišťuje, zda se jedná o ztracený hovor >
-- =============================================
CREATE FUNCTION [dbo].[IsLost]
(
	 @From AS Datetime
	,@To AS Datetime
	,@pilottime AS Datetime
	,@EnqueueingTime AS Datetime
	,@EndTime AS Datetime
	,@CallResult AS NVARCHAR(50)
)
RETURNS Integer
AS
BEGIN  
   RETURN IIF(@pilottime > @From AND @pilottime <= @To AND @EnqueueingTime IS NOT NULL AND DATEDIFF(SECOND, @EnqueueingTime, @EndTime) > 3
		and @CallResult='Lost'  
		--and FS_custom.dbo.IsWhiteList2(IC.InboundCallId)=0
		--AND FS_Custom.dbo.IsWorkTime3(IC.InboundCallId,IC.PilotTime)=1
		,1,0)
END




