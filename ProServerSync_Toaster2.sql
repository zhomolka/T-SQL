USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[ProServerSync_Toaster2]    Script Date: 07.02.2022 12:30:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ProServerSync_Toaster2]
--@OCId UniqueIdentifier 
AS
-- =============================================
-- Author:		<Václav Kubát>
-- Create date: <6.6.2017>
-- Description:	<Doplnění práv pro Toaster>
-- =============================================

BEGIN

------------smaž úèty, které už tam jsou-----------
declare @RoleAktivniPobocky uniqueidentifier = (select RoleId from proserver.dbo.Role where SystemName = 'ExtensionCTI')
declare @RoleAdministrace uniqueidentifier = (select RoleId from proserver.dbo.Role where SystemName = 'UseChannels')

create table #SynchroProServer
(Login nvarchar(100)
,DisplayName nvarchar(100)
,NewAccountId uniqueidentifier
,Team nvarchar(100)
,Description nvarchar (15)
)

insert into #SynchroProServer
select a.systemname,a.displayname, a.AgentId,a.TeamName,
case when a.Supervisor = 1 then 'Supervizor' else 'Agent' end as Description
from ICC.dbo.Agent a
left join ProServer.dbo.Credentials b on a.SystemName COLLATE Czech_CI_AS =b.SystemName COLLATE Czech_CI_AS
left join ProServer.dbo.Agent AP on a.Agentid =ap.Agentid
--=========POZOR NA PODMINKU NA TYM - DLE POTREBY UPRAVIT==========================================================================================================
where (a.TeamName <> 'Admin') 
--=================================================================================================================================================================
and a.Deleted=0 AND a.SystemName is not null AND b.SystemName is null
and ap.Agentid IS NULL

/* Původní verze VaK:
select systemname,displayname, newid(),TeamName,
case when Supervisor = 1 then 'Supervizor' else 'Agent' end as Description

--=========POZOR NA PODMINKU NA TYM - DLE POTREBY UPRAVIT========================================================================================================================================================
from $(ICC).dbo.Agent where (TeamName <> 'Admin') and Deleted=0 AND SystemName is not null
--===============================================================================================================================================================================================================

------------vymazání úètù, které už existují z docasne tabulky
delete from #SynchroProServer
where login in (select B.SystemName from ProServer.dbo.Account a left join ProServer.dbo.Credentials b on a.AccountId=b.AccountId and b.SystemName is not null and a.Deleted=0)
*/

------------- založení úètu
INSERT into ProServer.dbo.Agent (AgentId,DisplayName,Description,TeamName,Deleted)
select NewAccountId, DisplayName,Description,Team,0 from #SynchroProServer

-------------vložení loginù
insert into ProServer.dbo.Credentials (CredentialsId,AgentId,Rank,SystemName,Deleted)
SELECT newid(),NewAccountId,10,Login,0 from  #SynchroProServer

---------vložení oprávnìní na Aktivní poboèky
insert into ProServer.dbo.Permission (PermissionId,RoleId,Degree,AgentId)
select newid(),@RoleAktivniPobocky,3,NewAccountId from #SynchroProServer

---------vložení oprávnìní na Administrace
insert into ProServer.dbo.Permission (PermissionId,RoleId,Degree,AgentId)
select newid(),@RoleAdministrace,3,NewAccountId from #SynchroProServer

--===================vymazavani smazanych iCC uctu v ProServer================
--nalezeni nesmazanych v iCC a vlozeni do docasne tabulky
-- Pozastaveno z důvodů změny struktury dat 08/2021:
/*create table #ExistsInICC
(AccountId uniqueidentifier)

Insert into #ExistsInICC
select AccountId  from proserver.dbo.credentials as c with (nolock) where SystemName COLLATE Czech_CI_AS in (
	select SystemName from $(ICC).dbo.Agent as a with (nolock) where Deleted = 0 and SystemName is not null)

	--obnoveni nesmazanych v tabulce Credentials, kteri jsou v $(ICC).dbo.Agent
	update Proserver.dbo.Credentials 
	set Deleted = 0
	where AccountId in (select AccountId from #ExistsInICC)

	--obnoveni nesmazanych v tabulce Account, kteri jsou v $(ICC).dbo.Agent
	update Proserver.dbo.Account 
	set Deleted = 0
	where AccountId in (select AccountId from #ExistsInICC)

--nalezeni smazanych v iCC a vlozeni do docasne tabulky (kteri nejsou iCC ucet aplikace)
create table #DeletedInICC
(AccountId uniqueidentifier)

Insert into #DeletedInICC
select c.AccountId from proserver.dbo.credentials as c with (nolock)
	left join proserver.dbo.Account as a on a.AccountId = c.AccountId 
	where c.SystemName COLLATE Czech_CI_AS in (
	select SystemName from $(ICC).dbo.Agent as a with (nolock) where Deleted = 1 and SystemName is not null)
	and not exists (select SystemName from $(ICC).dbo.Agent as a with (nolock) where Deleted = 0 and SystemName is not null)--existuje tedy pouze jako smazany a ne nekolik smazanych a i existujici login
	and a.DisplayName <> 'iCC'

	--smazani v tabulce Credentials
	update Proserver.dbo.Credentials 
	set Deleted = 1
	where AccountId in (select AccountId from #DeletedInICC)

	--smazani v tabulce Account
	update Proserver.dbo.Account 
	set Deleted = 1
	where AccountId in (select AccountId from #DeletedInICC)
drop table #ExistsInICC

drop table #DeletedInICC

 08/2021*/
--------smazání dat tabulek tabulky

drop table #SynchroProServer


END

GO

