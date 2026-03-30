DECLARE @MeAgentId uniqueidentifier='0f52fd52-34ed-43c8-8c57-0253351d2a56'
select case when Activity = 'Logoff' then 'Logoff' else 'OK' end AS AgentStat from icc.dbo.Agent where AgentId = @MeAgentId
SELECT * FROM [FS_custom].[dbo].[Tile_SWPhoneCheck] (@MeAgentId)
		select OnLineStatus from ProServerB.dbo.Extension as e with (nolock)
		where Number = (select Number from iCC.dbo.Agent a with (nolock) 
														inner join iCC.dbo.Workplace as w with (nolock) on w.WorkplaceId = a.workplaceid
														where AgentId = @MeAgentId)	
