USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[GetCurrentStateLength2]    Script Date: 02/20/2018 17:00:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[GetCurrentStateLength2]
(
	@AgentId uniqueidentifier,
	@Now datetime
)
RETURNS int
AS
BEGIN
	DECLARE @Result AS INT
	
	SELECT @Result = DATEDIFF(SECOND, 
	(SELECT MAX(Timelocal) FROM icc.dbo.AgentEvent WITH(NOLOCK) WHERE AgentId = @AgentId AND Duration IS NULL AND EventType = 'AgentStatus' 
	    AND Actor <> 'Reset' /*AND ReferenceId = (SELECT StatusId FROM icc.dbo.Agent WITH(NOLOCK) WHERE AgentId = @AGENTID)*/)
	, @Now)

	
	RETURN @Result

END

GO

