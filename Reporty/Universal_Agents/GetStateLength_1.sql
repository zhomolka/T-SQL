USE [iCC]
GO

/****** Object:  UserDefinedFunction [dbo].[GetStateLength_1]    Script Date: 02/23/2018 10:12:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetStateLength_1]
(
	@STATEID uniqueidentifier,
	@AGENTID uniqueidentifier,
	@FROM datetime,
	@TO datetime
)
RETURNS int
AS
BEGIN
	DECLARE @Result AS INT
	
	SELECT @Result =
	/*
	(SELECT ISNULL((SELECT MAX(DATEDIFF(SECOND, TimeLocal, GETDATE())) FROM AgentEvent WITH (NOLOCK) WHERE AgentId = @AGENTID 
	AND EventType = 'AgentStatus' AND ReferenceId = @STATEID AND Duration IS NULL AND TimeLocal >= @FROM AND TimeLocal <= @TO), 0) 
+	*/
	(SELECT ISNULL(SUM(Duration),0) FROM AgentEvent WITH (NOLOCK) WHERE AgentId = @AGENTID 
	AND EventType = 'AgentStatus' AND ReferenceId = @STATEID AND TimeLocal >= @FROM AND TimeLocal <= @TO and  ReferenceData <> 'Logoff' and Actor <> 'Reset')
	RETURN @Result

END



GO

