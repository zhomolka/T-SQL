--USE [iCC_TVP]
--GO
--Declare @DisplayName varchar(50) = '%Microsoft:0b829af9-2a46-45dc-a763-fdee7fdc2b7b%'
Declare @DisplayName varchar(50) = '%Google:111812585893180359840%'
Declare @AgentId uniqueidentifier = (select top 1 AgentId from credentials where Deleted=0 and (SystemName like @DisplayName ))
declare @RoleExtensionCTI uniqueidentifier = 
(select RoleId from Role where SystemName = 'ExtensionCTI')
declare @RoleUseChannels uniqueidentifier =
(select RoleId from Role where SystemName = 'UseChannels')
--select 'Inspect please User''s Windows account !!!'

select * from Agent where agentid=@AgentId and deleted=0
select * from DataQuery where DataQueryId = (select bardataqueryid from .Agent where agentid=@AgentId and deleted=0)
select 'PERSO' AS Section,* from Perso where AgentId=@AgentId
 and refname in (2050,2051) --and JsonData Not like '%PageSize%'

--select 'SREC' AS Section,* from SREC.dbo.Account where SystemName like @DisplayName

select 'PRO.UseChannels' AS Section,* from Permission where RoleId=@RoleUseChannels and AgentId=@AgentId
select 'PRO.ExtensionCTI' AS Section,* from Permission where RoleId=@RoleExtensionCTI and AgentId=@AgentId

--select 'PRO.Agent' AS Section,* from ProServer..Agent where SystemName like @DisplayName
select 'PRO.Credentials' AS Section,* from Credentials where SystemName like @DisplayName
select 'PRO.DataItem' AS Section,* from DataItem where DataValue like @DisplayName OR AgentId=@AgentId
/*
select RefName,AG.DisplayName AS AgentName,JsonData,PER.AgentId from iCC..Perso AS PER
  LEFT JOIN iCC..AGENT AS AG ON PER.AgentId=AG.AgentId
where RefName LIKE 'Pro%'
ORDER BY JsonData
*/
GO
