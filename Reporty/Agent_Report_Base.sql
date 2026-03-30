--Toto je balíèek pro agentský report:
-- Pro View:
SELECT   StatusId, replace([DisplayName], '$', '') AS DisplayName, Activity, 
iif(activity = 'Ready', 'RD', iif(Activity = 'postcall', 'PC',
iif(activity = 'Pause', 'NR', 'LO')))
+ cast(ROW_NUMBER() OVER (PARTITION BY Activity
ORDER BY DisplayName) AS varchar(3)) AS Row
FROM     iCC.dbo.status
WHERE   Deleted = 0

-- Základní skript:

select
groupingdate,Agent, agentid
,SUM(isnull(LoggedDuration,0)) as LoggedDuration
,SUM(isnull(ReadyDuration,0)) as ReadyDuration
,Max(LastLogoffTime) as LastLogoffTime
,SUM(isnull(LO1,0)) as LO1
,SUM(isnull(LO2,0)) as LO2
,SUM(isnull(NR1,0)) as NR1
,SUM(isnull(NR2,0)) as NR2
,SUM(isnull(NR3,0)) as NR3
,SUM(isnull(NR4,0)) as NR4
,SUM(isnull(NR5,0)) as NR5
,SUM(isnull(NR6,0)) as NR6
,SUM(isnull(NR7,0)) as NR7
,SUM(isnull(NR8,0)) as NR8
,SUM(isnull(NR9,0)) as NR9
,SUM(isnull(NR10,0)) as NR10
,SUM(isnull(NR11,0)) as NR11
,SUM(isnull(NR12,0)) as NR12
,SUM(isnull(NR13,0)) as NR13
,SUM(isnull(NR14,0)) as NR14
,SUM(isnull(RD1,0)) as RD1
,SUM(isnull(RD2,0)) as RD2
,SUM(isnull(RD3,0)) as RD3
,SUM(isnull(PC1,0)) as PC1

 

from(

 

select groupingdate, Agent, agentid, LoggedDuration, ReadyDuration, LastLogoffTime,
NR1,NR2, NR3, NR4, NR5, NR6, NR7, NR8, NR9, NR10, NR11, NR12, NR13, NR14, RD1, RD2, RD3, PC1, LO1, LO2

 

from
(SELECT         -- Agenti                                        
          dbo.RoundTime(AE.Timelocal, 1440) AS GroupingDate    
        ,ae.AgentId as Agentid
        ,a.DisplayName as Agent
        ,isnull(A.TeamName, 'without Team') as Team
        ,SUM(IIF( ReferenceData <> 'Logoff' ,ISNULL(Duration, 0),0)) AS LoggedDuration
        ,SUM(ISNULL(Duration, 0)) AS Duration
        ,SUM(iif(ReferenceData='ready',    ISNULL(Duration, 0),0)) as ReadyDuration
        ,MAX(IIF( ReferenceData = 'Logoff' ,TimeLocal,0) ) AS LastLogoffTime
        ,S.DisplayName as Status
        ,V.Row as Status2
        ,S.StatusId as Statusid
        ,ReferenceData
        

 

    FROM iCC.dbo.AgentEvent AS AE WITH(NOLOCK)            
    left join icc.dbo.Agent as A with(nolock) on ae.Agentid=A.agentid    
    left join iCC.dbo.Status as S on S.StatusId = AE.ReferenceId
    left join fs_custom.dbo.View_rep_Statuses as V on V.StatusId=S.StatusId
    WHERE AE.timelocal >= '2021/05/01' AND AE.timelocal <= '2021/06/01'  and EventType='AgentStatus' and Actor <> 'Reset' --and a.AgentId = '5C6750A3-E668-4B51-B7D8-0727545F6EC8'
    GROUP BY dbo.RoundTime(AE.Timelocal, 1440), ae.AgentId, a.DisplayName, a.TeamName, S.StatusId, S.DisplayName, V.Row, ReferenceData         
    --order by ReferenceData, S.DisplayName 
) as P
PIVOT  
(  
sum(Duration) 
FOR Status2 IN  
(NR1,NR2, NR3, NR4, NR5, NR6, NR7, NR8, NR9, NR10, NR11, NR12, NR13, NR14, RD1, RD2, RD3, PC1, LO1, LO2)
) AS pvt 

 

) as A
group by groupingdate,Agent, agentid
 







