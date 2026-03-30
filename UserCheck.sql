:r C:\\Atlantis\\Scripts\\setvar.txt

--Declare @DisplayName varchar(50) = '%tereza.slavickova%'
Declare @DisplayName varchar(50) = '%mmichnova%' -- '%dsekulova%' -- 
select 'If user has not Domain account inspect please User''s Windows account !!!'

select * from $(ICC)..Agent where SystemName like @DisplayName and deleted=0
DECLARE @Agentid AS Uniqueidentifier
Declare @DisplayNameA varchar(50)
select TOP 1 @Agentid=Agentid,@DisplayNameA=DisplayName from $(ICC)..Agent where SystemName like @DisplayName and deleted=0

DECLARE @Agentidp AS Uniqueidentifier=(select TOP 1 Agentid from $(Proserver)..Agent where SystemName like @DisplayName
 OR DisplayName=@DisplayNameA)
select * from $(ICC)..DataQuery where DataQueryId = (select TOP 1 bardataqueryid from $(ICC)..Agent where SystemName like @DisplayName and deleted=0)
select 'PERSO' AS Section,* from $(ICC)..Perso where AgentId=@Agentid and RefName like 'Pro%' 

IF  EXISTS (SELECT * FROM sys.databases WHERE name = N'$(SREC)')
  select 'SREC' AS Section,* from $(SREC).dbo.Account where SystemName like @DisplayName
ELSE
  select 'SREC DB does not exists' 

select 'PRO.Agent' AS Section,* from $(Proserver)..Agent where AgentId=@Agentidp
select 'PRO.Credentials' AS Section,'If user has local Account he will need also Domain one here:'
select 'PRO.Credentials' AS Section,* from $(Proserver)..Credentials where AgentId=@Agentidp AND Deleted=0

select 'PRO.DataItem' AS Section,* from $(Proserver)..DataItem where Agentid=@Agentidp
--DataValue like @DisplayName
  --                  OR (DataValue like '%NTUSER%' AND Agentid=@Agentidp)
/*
select RefName,AG.DisplayName AS AgentName,JsonData,PER.AgentId from $(ICC)..Perso AS PER
  LEFT JOIN $(ICC)..AGENT AS AG ON PER.AgentId=AG.AgentId
where RefName LIKE 'Pro%'
ORDER BY JsonData
*/
GO
