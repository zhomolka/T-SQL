USE [FS_custom]
GO

/****** Object:  UserDefinedFunction [dbo].[Wallboard_CC]    Script Date: 8. 3. 2018 13:59:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ZbH 4.1.2016 přidal do jmenovatele select '4' as rank, 
-- Výraz: and callphase in ('AgentRingFirst','AgentRingMissed','AgentRingNext','HangupAgent','HangupCaller','WaitingQueue')
-- Stejný jako v čitateli, protože se tam údajně objevovalo SL20 108%
-- ZbH 27.1.2016 a  1.2.2016 nahradil výraz TeamName='CC' výrazem TeamName='DIGI', protože tým CC neexistuje

CREATE FUNCTION [dbo].[Wallboard_CC] 
(	
	@today as datetime,
	@now as datetime,
	@meAgentId as uniqueidentifier
)
RETURNS TABLE 
AS
RETURN 
												
/* 
declare @today as datetime = '2015-11-26'
declare	@now as datetime = '2013-011-26 16:04'
declare	@meAgentId as uniqueidentifier = '4354b36d-e2ab-46ad-bc78-347edcd9b293'
--*/



(
select 1 as rank, 'Příchozí celkem' as Label, convert(nvarchar(10),count(*)) as value from icc.dbo.inboundcall with (nolock) 
	where  projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and pilottime >=  @today and Redirector='9533'
	union all
	select 2 as rank, 'Příchozí celkem v prac době' as Label, convert(nvarchar(10),count(*)-FS_custom.dbo.CountCalls(9533,@today,@today+1)) as value from icc.dbo.inboundcall with (nolock) 
	where  projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and pilottime >=  @today and Redirector='9533'
	union all

		select 3 as rank, 'Počet obsloužených' as Label, convert(nvarchar(10),count(*)) as value from icc.dbo.inboundcall with (nolock) 
	where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and pilottime >=@today and AnswerTime is not null and Redirector='9533'
		union all
select 4 as rank, 'Zvednuté hovory' as Label, convert(nvarchar(10), count(*)*100/
	case when
		(select count(*) from icc.dbo.inboundcall with (nolock) 
		where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
			and pilottime >=@today  and Redirector='9533'and projectid is not null)=0
	then 1 else
		(select count(*) from icc.dbo.inboundcall with (nolock) 
		where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
			and pilottime >=@today  and Redirector='9533'and projectid is not null)
	end
	) +'%'  as Value
	 from icc.dbo.inboundcall with (nolock) 
	 where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and pilottime >=@today  and Redirector='9533' and answertime is not null

	 union all
	 select 5 as rank, 'Ztracené hovory' as Label, convert(nvarchar(10), count(*)*100/
		case when
			(select count(*) from icc.dbo.inboundcall with (nolock) 
			where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
				and pilottime >=@today   and Redirector='9533' and projectid is not null)=0
		then 1 else
			(select count(*) from icc.dbo.inboundcall with (nolock) 
			where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
				and pilottime >=@today   and Redirector='9533' and projectid is not null)
		end
		) +'%'  as Value
	from icc.dbo.inboundcall with (nolock) 
	where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and pilottime >=@today  and Redirector='9533' and answertime is  null and projectid is not null
	union all
SELECT 6 as rank ,'Počet ve frontě' as Label, 
	convert(nvarchar(10),COUNT(*)) AS Value FROM icc.dbo.InboundCall WITH(NOLOCK) 
	WHERE CallResult='Active' AND CallPhase='WaitingQueue' and Redirector='9533' and 
	projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
	
		
	/*union	
	select '4' as rank ,'Zpětná volání' as Label,
	count(OutboundCallId)  as Value from icc.dbo.OutboundCall with (NoLock) where callphase in ('Enqueue','AgentOfferMissed') and CallResult in('Prepared','Scheduled') 
	*/
	union
	select 7 as rank ,'Čas ve frontě' as Label,convert(nvarchar(10),	
	DATEDIFF(ss,
		CAST(CASE WHEN (SELECT MIN(EnqueueingTime) FROM icc.dbo.InboundCall WITH(NOLOCK) 
		WHERE projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
			and CallResult='Active' AND CallPhase='WaitingQueue' and Redirector='9533' AND PilotTime>(getdate()-1)) is null THEN getdate() 
		ELSE (SELECT MIN(EnqueueingTime) FROM icc.dbo.InboundCall WITH(NOLOCK) 
		WHERE projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
			and CallResult='Active' and Redirector='9533' AND CallPhase='WaitingQueue' AND PilotTime>(getdate()-1)) END AS datetime)
	,getdate()))  as Value
	
	union
	select 8 as rank ,'Volní agenti' as Label,	
	convert(nvarchar(10),COUNT(*))  as Value FROM icc.dbo.Agent AS A WITH(NOLOCK) 
					INNER JOIN icc.dbo.Workplace AS W  WITH(NOLOCK) ON A.WorkplaceId=W.WorkplaceId
					WHERE A.Activity='Ready' AND  A.StatusId = '60FBA1E2-08F0-4129-97B3-3041E9EE27B8' and W.State='Free' AND W.Offer='None' and a.TeamName='DIGI' 
						and a.AgentId <> '4354b36d-e2ab-46ad-bc78-347edcd9b293' and GroupName <> 'ENERGY'


	union all
	select 9 as rank, 'SL (20s)' as Label,convert(nvarchar(20),count(*)*100/
	case when
			(select count(*) from icc.dbo.inboundcall with (nolock) 
			where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
				and pilottime >=@today  and Redirector='9533'
				and callphase in ('AgentRingFirst','AgentRingMissed','AgentRingNext','HangupAgent','HangupCaller','WaitingQueue'))=0
		then 1 else
			(select count(*) from icc.dbo.inboundcall with (nolock) 
			where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
				and pilottime >=@today  and Redirector='9533'
				and callphase in ('AgentRingFirst','AgentRingMissed','AgentRingNext','HangupAgent','HangupCaller','WaitingQueue'))
		end
		)+'%'  as Value
	 from icc.dbo.inboundcall with (nolock) 
	 where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and pilottime >=@today and Redirector='9533' and answertime is not null and (QueueDuration <=20 or QueueDuration is null)
		and	callphase in ('AgentRingFirst','AgentRingMissed','AgentRingNext','HangupAgent','HangupCaller','WaitingQueue')
	 
	union all
	select 10 as rank, 'SL hodina (20s)' as Label,convert(nvarchar(10),count(*)*100/
		case when
			(select count(*) from icc.dbo.inboundcall with (nolock) 
			where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
				and pilottime >=dateadd(hh,-1,getdate()) and Redirector='9533' and projectid is not null)=0
		then 1 else(select count(*) from icc.dbo.inboundcall with (nolock) 
		where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
				and pilottime >=dateadd(hh,-1,getdate()) and Redirector='9533' and projectid is not null)
		end
		)+'%'  as Value
	from icc.dbo.inboundcall with (nolock) 
	where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and pilottime >=dateadd(hh,-1,getdate()) and Redirector='9533' and answertime is not null and (QueueDuration <=20 or QueueDuration is null)
union all

	 	/*
	select '9' as rank, 'Příchozí do 20s',convert(nvarchar(10),count(*))  as Value  from icc.dbo.inboundcall with (nolock) 
	where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and pilottime >=@today  and Redirector='9533'and answertime is not null and (QueueDuration <=20 or QueueDuration is null)
	union all
	(select '9' as rank, 'Příchozí po IVR', convert(nvarchar(10),count(*)) from icc.dbo.inboundcall with (nolock) 
	where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and pilottime >=@today  and Redirector='9533'and 
		callphase in ('AgentRingFirst','AgentRingMissed','AgentRingNext','HangupAgent','HangupCaller','WaitingQueue'))
	union all

	
	select '1' as rank, 'Počet příchozích' as Label, convert(nvarchar(10),count(*)) as value from icc.dbo.inboundcall with (nolock) 
	where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and projectid is not null  and Redirector='9533' and pilottime >=  @today
	union all	*/


 	select 11 as rank, 'Počet odchozích' as Label, convert(nvarchar(10),count(*)) as value from icc.dbo.outboundcall o with (nolock)  
	left join icc.dbo.agent a with (nolock) on a.AgentId=o.AgentId
	where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and projectid is not null and distributiontime >=@today and a.TeamName='DIGI'

	union all
 	select 12 as rank, 'Uskutečněné odchozí' as Label, convert(nvarchar(10),count(*)) as value from icc.dbo.outboundcall o with (nolock)  
	left join icc.dbo.agent a with (nolock) on a.AgentId=o.AgentId
	where projectid not in (SELECT [RejectedProject] FROM [FS_custom].[dbo].[RejectedProjects]) --nezobrazovane projekty
		and projectid is not null and distributiontime >=@today and a.TeamName='DIGI' and AnswerTime is not null
)


--callphase in ('AgentRingFirst','AgentRingMissed','AgentRingNext','HangupAgent','HangupCaller','WaitingQueue')
/*  Původní verze:
	select '12' as rank, 'Počet odchozích' as Label, convert(nvarchar(10),count(*)) as value from icc.dbo.outboundcall o with (nolock)  
	left join icc.dbo.agent a with (nolock) on a.AgentId=o.AgentId
	where projectid is not null and distributiontime >=@today and a.TeamName='CC'
	 
-- Verze s kontrolou týmu supervizora:
	    select '12' as rank,'Počet odchozích' as Label,
    (SELECT Value FROM
      (select AG1.TeamName
       ,(SELECT convert(nvarchar(10),count(*))  from icc.dbo.outboundcall o with (nolock)  
	     left join icc.dbo.agent a with (nolock) on a.AgentId=o.AgentId
	  where projectid is not null and distributiontime >=@today and a.TeamName=AG1.TeamName) AS value /*and a.TeamName='CC'*/
	from Icc.dbo.Agent AS AG1 where AgentId=@meAgentId ) AS Value) /* '37b436a2-2825-429b-8c5e-c4354a587242' - Iveta Šlapalová*/
*/

GO

