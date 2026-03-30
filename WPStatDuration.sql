USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[WPStatDuration]    Script Date: 17. 10. 2019 15:05:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <17-10-2019>
-- Description:	Vrací délku stavu telefonu
-- ======================================================

CREATE function [dbo].[WPStatDuration] (
 @AgentId AS UNIQUEIDENTIFIER
 ,@State AS nvarchar(32)
 ,@LastCallUtc AS datetime
)
returns Integer
as begin
 DECLARE @Now AS datetime=GETDATE()
 DECLARE @AnswerTime AS datetime=(SELECT Top 1 AnswerTime FROM iCC.dbo.InboundCall WITH(NOLOCK) WHERE AgentId = @AgentId AND CallResult = 'Active')
 DECLARE @DistributionTime AS datetime=(SELECT Top 1 DistributionTime FROM iCC.dbo.OutboundCall WITH(NOLOCK)  WHERE AgentId = @AgentId AND CallResult = 'Active')
 RETURN (	SELECT CASE 
 	 WHEN @AnswerTime IS NOT NULL
		THEN (DATEDIFF(SECOND, IIF(GETDATE()-0.1>@AnswerTime,GETDATE()-0.1,@AnswerTime), @Now)) 
 	 WHEN @DistributionTime IS NOT NULL
		THEN (DATEDIFF(SECOND, IIF(GETDATE()-0.1>@DistributionTime,GETDATE()-0.1,@DistributionTime), @Now))
 	 WHEN @State = 'Free' 
		THEN (SELECT Top 1 DATEDIFF(SECOND, DATEADD(HOUR, DATEDIFF(HH, GETUTCDATE(), GETDATE()), IIF(GETDATE()-0.1>@LastCallUtc,GETDATE()-0.1,@LastCallUtc)), @Now)) 
  	 END AS WorkplaceStatusDuration)

END

GO

