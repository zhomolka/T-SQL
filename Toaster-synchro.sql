declare @PermissionAktivniPobocky uniqueidentifier ='b9fe4b50-08f4-4b37-96fb-677cb5a7430c'
declare @PermissionAdministrace uniqueidentifier='6506af88-c35b-4f53-8127-af3a76472c2e' 

create table #SynchroProServer
(Login nvarchar(100)
,DisplayName nvarchar(100)
,NewAccountId uniqueidentifier
,Team nvarchar(100)
)

insert into #SynchroProServer
select systemname,displayname, newid(),TeamName from icc.dbo.Agent where TeamName like '%tlm%' and Deleted=0

------------vymazání úètù, které už existují
delete from #SynchroProServer
where login in (select B.SystemName from ProServer.dbo.Account a left join ProServer.dbo.Credentials b on a.AccountId=b.AccountId and b.SystemName is not null and a.Deleted=0)

------------- založení úètu
INSERT into ProServer.dbo.Account
select NewAccountId, displayName,null,Team,0 from #SynchroProServer



-------------vložení loginù
insert into ProServer.dbo.Credentials
SELECT newid(),NewAccountId,10,login,null, null, null,null,null, null, null,null,0 from  #SynchroProServer


---------vložení oprávnìní na Aktivní poboèky
insert into ProServer.dbo.Permission
select newid(),@PermissionAktivniPobocky,1,NewAccountId,null,'*' from #SynchroProServer

---------vložení oprávnìní na Administrace
insert into ProServer.dbo.Permission
select newid(),@PermissionAdministrace,1,NewAccountId,null,'UseChannels' from #SynchroProServer

--------smazání dat ze synchro tabulky
delete from #SynchroProServer

drop table #SynchroProServer
