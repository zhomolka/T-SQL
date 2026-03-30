/*
Postup založení agenta v Alza

- vytvoøit win úèty
- založit v WebAdmin FS

*/


--vstupni/hlavni parametry
	--EndAppId (DesktopClient)  ... SELECT  [AppEndId] FROM [ProServer].[dbo].[AppEnd]
	declare @EndAppId as uniqueidentifier = '9DE773CB-0500-4B98-A076-25F2CC52274A'

	--!!!!nastaveni a info, ktereho uzivatele brat pro vytvoreni noveho jako sablonu pro Perso
	declare @WebAdmin_TemplateUser as uniqueidentifier = '9a3df49b-b09c-44d4-9344-dbd751a2362c'--Gorner

--dohledam seznam uzivatelu k zavedeni (pokud jsou ve WA a nejsou v ProServeru nebo Perso)
declare @NewUsers as table (AgentId uniqueidentifier, Exists_PS bit, Exists_Perso bit)
	--ti, kteri nejsou v ProServeru a nekteri maji/nemaji Perso
	insert into @NewUsers
		select 
			AgentId
			,0 as Exists_PS
			,case when AgentId not in (select AgentId from iCC.dbo.Perso where RefName in ('ProCaller#EventHandlingDefinition')) then 0 else 1 end as Exists_Perso
		from iCC.dbo.Agent as a with (nolock) where Deleted = 0 and Template = 0 and isnull(replace(a.SystemName,'SR-DC1-ATLAPP1\',''),'') <> '' and not exists (
		select top 1 1 from ProServer.dbo.Credentials as c with (nolock) where AppEndId = '9DE773CB-0500-4B98-A076-25F2CC52274A' and Deleted = 0
			and replace(a.SystemName,'SR-DC1-ATLAPP1\','') = replace(c.SystemName,'ALZ\','')
			)
			and TeamName <> 'admin' and SystemName not like '%agent%' and SystemName not like '%wallboard%' and SystemName not like '%\ext%'
	--ti, kteri jsou v PS, ale nemaji Perso
	insert into @NewUsers
		select 
			AgentId
			,1 as Exists_PS
			,0 Exists_Perso
		from iCC.dbo.Agent as a with (nolock) where Deleted = 0 and Template = 0 and isnull(replace(a.SystemName,'SR-DC1-ATLAPP1\',''),'') <> ''
			and AgentId not in (select AgentId from iCC.dbo.Perso where RefName in ('ProCaller#EventHandlingDefinition'))
			and AgentId not in (select AgentId from @NewUsers)
			and TeamName <> 'admin' and SystemName not like '%agent%' and SystemName not like '%wallboard%' and SystemName not like '%\ext%'


while (select count(1) from @NewUsers) >=1
begin
	--uzivatel k zavedeni
	declare @NewUser as uniqueidentifier = (select top 1 AgentId from @NewUsers)
	declare @WebAdmin_DisplayName as nvarchar (150) 
	declare @WebAdmin_TeamName as nvarchar (100) 
	declare @WebAdmin_SystemName as nvarchar (100)
	declare @WebAdmin_FullSystemName as nvarchar (100)
	select 
		@WebAdmin_DisplayName = DisplayName
		,@WebAdmin_TeamName = TeamName
		,@WebAdmin_SystemName = replace(SystemName,'sr-dc1-atlapp1\','')
		,@WebAdmin_FullSystemName = SystemName
	from icc.dbo.agent where AgentId = @NewUser

	--vlozeni Perso do iCC kvuli DesktopClientu
	if (select top 1 Exists_Perso from @NewUsers where AgentId = @NewUser) = 0
		begin
			insert into iCC.dbo.Perso
			select 
			NEWID()
			,@NewUser
			,Profile
			,RefName
			,RefId
			,JsonData
			,ContextId
			from iCC.dbo.Perso where AgentId = @WebAdmin_TemplateUser  and RefName in ('ProCaller#EventHandlingDefinition','ProCaller#RibbonDefinition')
		end

	--vlozeni Account do ProServer
	if (select top 1 Exists_PS from @NewUsers where AgentId = @NewUser) = 0
	declare @ProServer_FullSystemName as nvarchar (100) = CONCAT ('ALZ\',@WebAdmin_SystemName)
	declare @ProServer_AccountId as uniqueidentifier = newid ()
	INSERT INTO [ProServer].[dbo].[Account]
			   ([AccountId]
			   ,[DisplayName]
			   ,[Description]
			   ,[TeamName]
			   ,[Deleted]
			   ,[SystemName]
			   ,[Culture])
		 VALUES
			   (@ProServer_AccountId
			   ,@WebAdmin_DisplayName
			   ,NULL
			   ,@WebAdmin_TeamName
			   ,0
			   ,@ProServer_FullSystemName
			   ,NULL)


	declare @ProServer_CredentialsId as uniqueidentifier = newid ()
	INSERT INTO [ProServer].[dbo].[Credentials]
			   ([CredentialsId]
			   ,[AccountId]
			   ,[Rank]
			   ,[SystemName]
			   ,[Station]
			   ,[IP4From]
			   ,[IP4To]
			   ,[IP6From]
			   ,[IP6To]
			   ,[AppEndId]
			   ,[Password]
			   ,[LastLogonUtc]
			   ,[Deleted])
		 VALUES
			   (@ProServer_CredentialsId
			   ,@ProServer_AccountId
			   ,(select top 1 Rank + 5 from ProServer.dbo.Credentials order by Rank desc)
			   ,@ProServer_FullSystemName
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,@EndAppId
			   ,NULL
			   ,NULL
			   ,0)

	declare @ProServer_DataItemId as uniqueidentifier = newid ()
	INSERT INTO [ProServer].[dbo].[DataItem]
			   ([DataItemId]
			   ,[KeyName]
			   ,[AccountId]
			   ,[ExtensionId]
			   ,[AppEndId]
			   ,[DataValue]
			   ,[LastChange])
		 VALUES
			   (@ProServer_DataItemId
			   ,'UserData'
			   ,@ProServer_AccountId
			   ,NULL
			   ,@EndAppId
			   ,concat('<?xml version="1.0" encoding="utf-8"?><UserData><IdentityCC>',@WebAdmin_FullSystemName,'</IdentityCC></UserData>')
			   ,getdate())

	--odstraneni zvedeneho (abych nasledne mohl zavest noveho)
	delete from @NewUsers where AgentId = @NewUser
end
