select * from
(select 
rank() OVER (ORDER BY agentid) as rank
, jmeno as 'jmeno'
, count(prichozi) as 'prichozi'
, count(OdchozichCelkem) as 'OdchozichCelkem'
, count(UskutecneneOdchozi) as 'UskutecneneOdchozi'
	,CAST(MIN(CAST(Administrativni AS INT)) AS BIT) as 'Administrativni'
	,CAST(MIN(CAST(Maily AS INT)) AS BIT) as 'Maily'
	,CAST(MIN(CAST(Obed AS INT)) AS BIT) as 'Obed'
	,CAST(MIN(CAST(Osobni AS INT)) AS BIT) as 'Osobni'
	,CAST(MIN(CAST(OsobniRozvoj AS INT)) AS BIT) as 'OsobniRozvoj'
	,CAST(MIN(CAST(Pripraven AS INT)) AS BIT) as 'Pripraven'
	,CAST(MIN(CAST(RadimSe AS INT)) AS BIT) as 'RadimSe'
	,CAST(MIN(CAST(Vyplnuji AS INT)) AS BIT) as 'Vyplnuji'
	,CAST(MIN(CAST(Výpomoc AS INT)) AS BIT) as 'Výpomoc'

,(count(prichozi)+count(OdchozichCelkem))as 'soucet',Status  
from
(
select

a.AgentId
,a.DisplayName as 'jmeno'
,i.InboundCallId as 'prichozi'
,NULL as 'OdchozichCelkem'
,NULL as 'UskutecneneOdchozi'
,s.DisplayName as 'status'
	,CAST(CASE WHEN s.displayname = 'Administrativní' THEN 1 ELSE 0 END AS bit) AS Administrativni
	,CAST(CASE WHEN s.displayname = 'Maily' THEN 1 ELSE 0 END AS bit) AS Maily
	,CAST(CASE WHEN s.displayname = 'Obìd' THEN 1 ELSE 0 END AS bit) AS Obed
	,CAST(CASE WHEN s.displayname = 'Osobní' THEN 1 ELSE 0 END AS bit) AS Osobni
	,CAST(CASE WHEN s.displayname = 'Osobní rozvoj' THEN 1 ELSE 0 END AS bit) AS OsobniRozvoj
	,CAST(CASE WHEN s.displayname = 'Pøipraven' THEN 1 ELSE 0 END AS bit) AS Pripraven
	,CAST(CASE WHEN s.displayname = 'Radím se' THEN 1 ELSE 0 END AS bit) AS RadimSe
	,CAST(CASE WHEN s.displayname = 'Vyplòuji' THEN 1 ELSE 0 END AS bit) AS Vyplnuji
	,CAST(CASE WHEN s.displayname = 'Výpomoc' THEN 1 ELSE 0 END AS bit) AS Výpomoc
from Agent a WITH(NOLOCK) 
	left join InboundCall i WITH(NOLOCK)  on a.AgentId=i.AgentId
	left join status s WITH(NOLOCK) on s.StatusId=a.StatusId
where convert(date,i.RegionalTime)=convert(date,getdate()) and a.TeamName ='DIGI' 
	and s.StatusId not in ('50823A9F-2A07-4542-ADBC-D96C97E6E431','E8AD6B58-B5CC-478F-9BAE-D6C8D8DC1AAE')

union all

select 
a.AgentId
,a.DisplayName as 'jmeno'
,null as 'prichozi'
,(SELECT COUNT(*) FROM icc.dbo.OutboundCall WITH(NOLOCK) WHERE a.AgentId=o.AgentId AND 
		 DistributionTime IS NOT NULL ) 
	as 'OdchozichCelkem'
,(SELECT COUNT(*) FROM icc.dbo.OutboundCall WITH(NOLOCK) WHERE a.AgentId=o.AgentId AND 
		 DistributionTime IS NOT NULL AND CallDuration >=5 ) 
	as 'UskutecneneOdchozi'
,s.DisplayName as 'status'
	,CAST(CASE WHEN s.displayname = 'Administrativní' THEN 1 ELSE 0 END AS bit) AS Administrativni
	,CAST(CASE WHEN s.displayname = 'Maily' THEN 1 ELSE 0 END AS bit) AS Maily
	,CAST(CASE WHEN s.displayname = 'Obìd' THEN 1 ELSE 0 END AS bit) AS Obed
	,CAST(CASE WHEN s.displayname = 'Osobní' THEN 1 ELSE 0 END AS bit) AS Osobni
	,CAST(CASE WHEN s.displayname = 'Osobní rozvoj' THEN 1 ELSE 0 END AS bit) AS OsobniRozvoj
	,CAST(CASE WHEN s.displayname = 'Pøipraven' THEN 1 ELSE 0 END AS bit) AS Pripraven
	,CAST(CASE WHEN s.displayname = 'Radím se' THEN 1 ELSE 0 END AS bit) AS RadimSe
	,CAST(CASE WHEN s.displayname = 'Vyplòuji' THEN 1 ELSE 0 END AS bit) AS Vyplnuji
	,CAST(CASE WHEN s.displayname = 'Výpomoc' THEN 1 ELSE 0 END AS bit) AS Výpomoc
from Agent a WITH(NOLOCK) 
	left join OutboundCall o WITH(NOLOCK)  on a.AgentId=o.AgentId
	left join status s WITH(NOLOCK) on s.StatusId=a.StatusId
where convert(date,o.RegionalTime)=convert(date,getdate())  and o.DisplayName<>'FCR' and  CallDuration IS NOT NULL and a.TeamName ='DIGI' 
	and s.StatusId not in ('50823A9F-2A07-4542-ADBC-D96C97E6E431','E8AD6B58-B5CC-478F-9BAE-D6C8D8DC1AAE')
) as pohled

group by AgentId, jmeno, status
) as hlavni
where rank <= 25


