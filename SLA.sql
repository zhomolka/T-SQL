USE [FS_Custom]
GO

/****** Object:  UserDefinedFunction [dbo].[SLA]    Script Date: 28.08.2019 16:24:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Zbyněk Homolka>
-- Create date: <2.5.2019>
-- Description:	<Vrací podíl v procentech>
-- =============================================

CREATE FUNCTION [dbo].[SLA](@TimeFrom as DateTime, @Section AS VARCHAR(2))
RETURNS Real
AS
BEGIN
	DECLARE @Result as Real =
 	(SELECT  ROUND(FS_Custom.dbo.Percents(IN_SLA,Celkem),0) AS Value FROM
	(select 
		    SUM(1)  AS Celkem
		   ,SUM(IIF(AnswerTime is not null AND ISNULL(i.QueueDuration,0) /*+ISNULL(i.RingDuration,0)*/ <=20,1,0)) AS IN_SLA
		from icc.dbo.InboundCall i with (nolock)
	where i.PilotTime>=@TimeFrom and CallResult<>'Active' and EnqueueingTime is not null and .dbo.TestSection(@Section,'P',PilotId)=1) AS Phase1 )
	RETURN @Result
END
--



GO

