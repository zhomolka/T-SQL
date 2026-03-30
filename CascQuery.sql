DECLARE @TODAY AS Date
SET  @TODAY=CONVERT(Date,GETDATE())
select 
AG1.TeamName
 ,'12' as rank
 , 'Poèet odchozích' as Label
 , (SELECT convert(nvarchar(10),count(*))  from icc.dbo.outboundcall o with (nolock)  
	left join icc.dbo.agent a with (nolock) on a.AgentId=o.AgentId
	where projectid is not null and distributiontime >=@today and a.TeamName=AG1.TeamName) AS value /*and a.TeamName='CC'*/
	from Icc.dbo.Agent AS AG1 where AgentId='37b436a2-2825-429b-8c5e-c4354a587242'