USE [FS_Custom]
GO

/****** Object:  StoredProcedure [dbo].[SyncProServer]    Script Date: 3.7.2018 17:01:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Stejskal, Kubát>
-- Create date: <3.7.2018>
-- Description:	<Synchronizace uctu a opravneni v ProServer dle iCC>
-- =============================================
CREATE PROCEDURE [dbo].[SyncProServer]
AS
BEGIN

	SET NOCOUNT ON;


    
------------smaž účty, které už tam jsou-----------
declare @RoleAktivniPobocky uniqueidentifier = (select RoleId from proserver.dbo.Role where DisplayName = 'Aktivní pobočky')
declare @RoleAdministrace uniqueidentifier = (select RoleId from proserver.dbo.Role where DisplayName = 'Práva k administraci')

create table #SynchroProServer
(Login nvarchar(100)
,DisplayName nvarchar(100)
,NewAccountId uniqueidentifier
,Team nvarchar(100)
,Description nvarchar (15)
)

insert into #SynchroProServer
select systemname,displayname, newid(),TeamName,
case when Supervisor = 1 then 'Supervizor' else 'Agent' end as Description
from icc.dbo.Agent where Deleted=0

------------vymazání účtů, které už existují z docasne tabulky
delete from #SynchroProServer
where login in (select B.SystemName from ProServer.dbo.Account a left join ProServer.dbo.Credentials b on a.AccountId=b.AccountId and b.SystemName is not null and a.Deleted=0)

------------- založení účtu
INSERT into ProServer.dbo.Account (AccountId,DisplayName,Description,TeamName,Deleted)
select NewAccountId, DisplayName,Description,Team,0 from #SynchroProServer

-------------vložení loginů
insert into ProServer.dbo.Credentials (CredentialsId,AccountId,Rank,SystemName,Deleted)
SELECT newid(),NewAccountId,10,Login,0 from  #SynchroProServer

---------vložení oprávnění na Aktivní pobočky
insert into ProServer.dbo.Permission (PermissionId,RoleId,Degree,AccountId,Scope)
select newid(),@RoleAktivniPobocky,1,NewAccountId,'*' from #SynchroProServer

---------vložení oprávnění na Administrace
insert into ProServer.dbo.Permission (PermissionId,RoleId,Degree,AccountId,Scope)
select newid(),@RoleAdministrace,1,NewAccountId,'UseChannels' from #SynchroProServer

--===================vymazavani smazanych uctu z iCC v ProServer================
--nalezeni nesmazanych v iCC a vlozeni do docasne tabulky
create table #ExistsInICC
(AccountId uniqueidentifier)

Insert into #ExistsInICC
select AccountId from proserver.dbo.credentials as c with (nolock) where SystemName in (
	select SystemName from icc.dbo.Agent as a with (nolock) where Deleted = 0 and SystemName is not null)

	--obnoveni nesmazanych v tabulce Credentials, kteri jsou v iCC.dbo.Agent
	update Proserver.dbo.Credentials 
	set Deleted = 0
	where AccountId in (select AccountId from #ExistsInICC)

	--obnoveni nesmazanych v tabulce Account, kteri jsou v iCC.dbo.Agent
	update Proserver.dbo.Account 
	set Deleted = 0
	where AccountId in (select AccountId from #ExistsInICC)

--nalezeni smazanych v iCC a vlozeni do docasne tabulky (kteri nejsou iCC ucet aplikace)
create table #DeletedInICC
(AccountId uniqueidentifier)

Insert into #DeletedInICC
select c.AccountId from proserver.dbo.credentials as c with (nolock)
	left join proserver.dbo.Account as a on a.AccountId = c.AccountId
	where SystemName in (
	select SystemName from icc.dbo.Agent as a with (nolock) where Deleted = 1 and SystemName is not null)
	and a.DisplayName <> 'iCC'

	--smazani v tabulce Credentials
	update Proserver.dbo.Credentials 
	set Deleted = 1
	where AccountId in (select AccountId from #DeletedInICC)

	--smazani v tabulce Account
	update Proserver.dbo.Account 
	set Deleted = 1
	where AccountId in (select AccountId from #DeletedInICC)

--------smazání dat tabulek tabulky

drop table #SynchroProServer

drop table #ExistsInICC

drop table #DeletedInICC
END

GO

