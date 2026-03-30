USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[GetStateLength_2]    Script Date: 25. 1. 2016 13:47:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE	 FUNCTION [dbo].[GetStateLength_2]
(
	@STATEID uniqueidentifier,
	@AGENTID uniqueidentifier,
	@FROM datetime,
	@TO datetime
)
RETURNS int
AS
BEGIN

/*
declare @stateid uniqueidentifier='2506d0dc-8df8-40ff-9ab2-20e68878e9ef'
declare @agentid uniqueidentifier='4F34188A-F894-46C9-90A5-087F44F89B40'
declare @from datetime=CAST(getdate() as date)
declare @to datetime=getdate()
*/
	DECLARE @Result AS INT
	DECLARE @LastTime as datetime
	DECLARE @LastStatus as int

	
	select @LastStatus = (case when (select Top 1 referenceId from icc.dbo.AgentEvent with (nolock) where AgentId=@AGENTID AND EventType = 'AgentStatus' AND Duration IS NULL AND TimeLocal >= @FROM AND TimeLocal <= @TO order by TimeLocal desc)=@STATEID then 1 else 0 end)
	
	select @LastTime = (select Top 1 timelocal from icc.dbo.AgentEvent with (nolock) where AgentId=@AGENTID AND EventType = 'AgentStatus' AND ReferenceId = @STATEID AND Duration IS NULL AND TimeLocal >= @FROM AND TimeLocal <= @TO order by TimeLocal desc)
	if @LastStatus = 1 
	begin
	SELECT @Result =
	                          /* 25.1.2016 ZbH nahradil GETDATE() výrazem TimeLocal*/
	(SELECT ISNULL((SELECT MAX(DATEDIFF(SECOND, @LastTime, TimeLocal)) FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE AgentId = @AGENTID 
	AND EventType = 'AgentStatus' AND ReferenceId = @STATEID AND Duration IS NULL AND TimeLocal >= @FROM AND TimeLocal <= @TO), 0) 
+	
	(SELECT ISNULL(SUM(Duration),0) FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE AgentId = @AGENTID 
	AND EventType = 'AgentStatus' AND ReferenceId = @STATEID AND TimeLocal >= @FROM AND TimeLocal <= @TO))
	end
	if @LastStatus = 0
	begin 
	
	SELECT @Result =
	
	(
	(SELECT ISNULL(SUM(Duration),0) FROM icc.dbo.AgentEvent WITH (NOLOCK) WHERE AgentId = @AGENTID 
	AND EventType = 'AgentStatus' AND ReferenceId = @STATEID AND TimeLocal >= @FROM AND TimeLocal <= @TO))
	end
	--select @Result,@lasttime,@laststatus
		
	RETURN @Result

END

GO

