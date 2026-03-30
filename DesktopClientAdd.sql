:setvar ICC ICC

USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[DesktopClientAdd]    Script Date: 28.02.2022 9:04:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:        Kubát Václav
-- Create date: 12.12.2021
-- Description:   Nastaví konkrétního agenta k hovoru
-- =============================================
CREATE PROCEDURE [dbo].[DesktopClientAdd] 
@MyAgentId uniqueidentifier,
@Domain nvarchar(20)
AS
BEGIN
/*
--====================kontrola ProServer.dbo.Credentials nakonec po spusteni skriptu===============================
       -- nemel by existovat ucet bez SystemName, pokud nema Password (WebSite...) -> tedy vysledek idealne 0 radku:
       
       select * from ProServer.dbo.Credentials c
       left join ProServer.dbo.Account a on a.AccountId = c.AccountId
       where c.SystemName is null and c.Deleted = 0 and Password is null

*/
/*
	INSERT/UPDATE těchto míst
		ProServer: [Account] | [Credentials] | [DataItem]
		iCC: [Perso] |  [Agent].BarDataQueryId |  [Seating].LoginClientModels (doplneni "ProCaller")
			
*/
--==========nastaveni hodnot==============
	declare @BarDataQueryId as uniqueidentifier = (select top 1 BarDataQueryId from icc..agent where BarDataQueryId is not null) --statistiky v DC liste
	declare @EventHandlingDefinition as nvarchar (max)
	declare @RibbonDefinition as nvarchar (max)
	--do [DataItem] se vlozi s obecnym loginem NTUSER. Pokud je potreba s loginem (jako napříkald v Alze, coz není obvykle), staci dole zakomentovat/odkomentovat v INSERT
	declare @DataValue as nvarchar(max) = '<?xml version="1.0" encoding="utf-8"?><UserData><IdentityCC>NTUSER</IdentityCC></UserData>'
	declare @DomainUserName as nvarchar(40)
	declare @AgentName as nvarchar(40)

	--default Perso, !!!!!!!KDYZTAK ZAKOMENTOVAT NEBO VYBRAT JINE PERSO!!!!!!!!!!
	set @EventHandlingDefinition = ISNULL((SELECT TOP 1 [JsonData]  FROM $(iCC).[dbo].[Perso] 
	WHERE RefName='ProCaller#EventHandlingDefinition' AND JsonData IS NOT NULL),
	N'{"Reactions":[{"EventType":"ProjectIncomingRinging","Reaction":"StartProcess","ParamTemplate":"http://localhost/ReactClient/Pages/calleditor.html?Id={PbxCallId}"},{"EventType":"DirectIncomingRinging","Reaction":"ShowPopout"},{"EventType":"DirectOutgoingRinging","Reaction":"ShowPopout"},{"EventType":"PrivateOutgoingOffer","Reaction":"ShowPopout"},{"EventType":"PrivateOutgoingRinging","Reaction":"ShowPopout"},{"EventType":"ProjectIncomingRinging","Reaction":"ShowPopout"},{"EventType":"ProjectOutgoingOffer","Reaction":"ShowPopout"},{"EventType":"ChatAlerting","Reaction":"ShowPopout"},{"EventType":"ChatAlerting","Reaction":"PlaySound","ParamTemplate":"file|C:\\Windows\\Media\\Ring06.wav"}]}'
	)
	set @RibbonDefinition = ISNULL((SELECT TOP 1 [JsonData]  FROM $(iCC).[dbo].[Perso] 
	WHERE RefName='ProCaller#RibbonDefinition' AND JsonData IS NOT NULL),
	 N'{	"Options": {		"CommunicationInfo": {			"VoiceDisplayTemplate": "{ProjectName};{LanguageName};{ContactName};{PilotNumber};{DisplayName};{SourceNumber}",			"ChatDisplayTemplate": "{ContactName};{ProjectName};{UnreadCount}",			"TaskDisplayTemplate": "Task {ContactName};{ProjectName}",			"MessageDisplayTemplate": "Message {ContactName};{ProjectName}"		},		"WebView": {			"ChatWindowUrl": "http://192.168.1.23/ReactClient/pages/ChatEditor.html?id={chatId}&Embedded=true"		},		"ClientAlert": {			"ShiftIntervalInSeconds": 5,			"AlertListMaxAgeThresholdSeconds": 60		},		"AgentStatus": {			"AllowChangeBetweenLogoffStatuses": true		},	},	"ComponentGroups": [		{			"Name": null,			"Components": [				{					"CodeName": "OpenUrlButton",					"IsEnabled": true,					"NavigateUrl": "http://localhost/ReactClient/Pages/portal.html#Agent_Domu",					"PictogramUrl": "pack://application:,,,/Resources/LogoFS_32x32.png"				},				{					"CodeName": "OpenUrlButton",					"IsEnabled": true,					"NavigateUrl": "http://localhost/ReactClient/Pages/portal.html#Agent_Wallboard",					"PictogramUrl": "pack://application:,,,/Resources/LogoFS_32x32.png"				},				{					"CodeName": "OpenUrlButton",					"IsEnabled": true,					"NavigateUrl": "",					"PictogramUrl": ""				},				{					"CodeName": "OpenUrlButton",					"IsEnabled": true,					"NavigateUrl": "",					"PictogramUrl": ""				}			],			"BlockWidth": 2,			"AppendSeparator": true		},		{			"Name": null,			"Components": [				{					"CodeName": "WorkplaceStatusDropdown",					"IsEnabled": true				},				{					"CodeName": "WorkplaceDropdown",					"IsEnabled": true,					"ConfirmActionResourceName": "DC_Confirm_WorkplaceSignout"				},				{					"CodeName": "QuickStatusButton",					"IsEnabled": true,					"QuickAgentStatusId": "60FBA1E2-08F0-4129-97B3-3041E9EE27B8",					"QuickAgentStatusResetId": "78028459-CA9E-45DE-A574-5005F96774BC",					"QuickAgentStatusPictogram": "\ue8f8"				},				{					"CodeName": "QuickStatusButton",					"IsEnabled": true,					"QuickAgentStatusId": "78028459-CA9E-45DE-A574-5005F96774BC",					"QuickAgentStatusResetId": "60fba1e2-08f0-4129-97b3-3041e9ee27b8",					"QuickAgentStatusPictogram": "\ue821"				}			],			"BlockWidth": 4,			"AppendSeparator": true		},		{			"Name": null,			"Components": [				{					"CodeName": "BasicCallBar",					"IsEnabled": true				},				{					"CodeName": "MicroMuteButton",					"IsEnabled": true,					"Command": "ToggleRecordingDeviceMute"				},				{					"CodeName": "FluentRoundButton",					"Content": "\ue93a",					"IsEnabled": true,					"Command": "ToggleSoftphone",					"ToolTipResource": "DC_ToggleSoftphone_Toggle_Tooltip"				},				{					"CodeName": "TransferCallBar",					"IsEnabled": true				},				{					"CodeName": "VolumeControl"				}			],			"BlockWidth": 9,			"AppendSeparator": true		},		{			"Name": null,			"Components": [				{					"CodeName": "InteractionContextInfo"				},				{					"CodeName": "ClientAlertBoard"				}			],			"BlockWidth": -1,			"AppendSeparator": true,			"Orientation": "Vertical"		},		{			"Name": "Chat",			"Components": [				{					"CodeName": "BasicChatBar",					"UseSingleItemShortcut": true				}			],			"BlockWidth": 3,			"AppendSeparator": true,			"Orientation": "Vertical"		},		{			"Name": "Today",			"Components": [				{					"CodeName": "DqCell",					"CellColumnId": "7A0947E0-E5CD-47BA-A985-84592BA8F098",					"CellViewer": "DqButton"				},				{					"CodeName": "DqCell",					"CellColumnId": "CE959C62-E2B5-469A-8946-1CBCF71E50C0",					"CellViewer": "DqButton"				},				{					"CodeName": "DqCell",					"CellColumnId": "3C4B0225-002B-43AD-B39A-97CB4FF36595",					"CellViewer": "DqButton"				}			],			"BlockWidth": -1,			"AppendSeparator": true,			"Orientation": "Vertical"		},		{			"Name": "Today",			"Components": [				{					"CodeName": "DqCell",					"CellColumnId": "7F45D4F5-BE16-4AF4-AF9D-EF80226ECC72",					"CellViewer": "DqLabel",					"CellLabelIcon": "Up"				},				{					"CodeName": "DqCell",					"CellColumnId": "0E004BCF-01C4-42DB-AC29-0FC3A1D72D09",					"CellViewer": "DqLabel",					"CellLabelIcon": "Ok"				},				{					"CodeName": "DqCell",					"CellColumnId": "8A7F0256-B722-467D-8EDB-DDD395B1A5DF",					"CellViewer": "DqLabel",					"CellLabelIcon": "Nok"				}			],			"BlockWidth": -1,			"AppendSeparator": true,			"Orientation": "Vertical"		},		{			"Name": "Actual",			"Components": [				{					"CodeName": "DqCell",					"CellColumnId": "6A242A56-EC26-40F3-A4E7-673616891E9D",					"CellViewer": "DqCifernik"				},				{					"CodeName": "DqCell",					"CellColumnId": "9BC51157-7429-4579-95D0-F214F593F50B",					"CellViewer": "DqCifernik"				}			],			"BlockWidth": -1,			"AppendSeparator": true,			"Orientation": "Vertical"		},		{			"Name": "",			"Components": [				{					"CodeName": "CallDuration",					"ValuePresentation": "Progress",					"Caption": "Délka hovoru",					"MarginLeftPx": 10,					"CellColor": "#404040"				}			],			"BlockWidth": -1,			"AppendSeparator": true,			"Orientation": "Vertical"		},		{			"Name": "",			"Components": [				{					"CodeName": "DqCell",					"CellColumnId": "cd53b31d-d17e-4d42-89b2-4132457a3169",					"CellViewer": "DqProgress",					"CellRangeMinimum": "0",					"CellRangeMaximum": "100",					"MarginLeftPx": 10				}			],			"BlockWidth": -1,			"AppendSeparator": true,			"Orientation": "Vertical"		}	]}'
	 )
-- Nastavení rolí:
declare @RoleExtensionCTI uniqueidentifier = 
(select RoleId from proserver.dbo.Role where SystemName = 'ExtensionCTI')
declare @RoleUseChannels uniqueidentifier =
 (select RoleId from proserver.dbo.Role where SystemName = 'UseChannels')
	


--kontrola, zda existuje DQ - pokud ne bud zakomentovat UPDATE nize nebo upravit ID vyse
if not exists (select top 1 1 from $(iCC).dbo.DataQuery where DataQueryId = @BarDataQueryId)
begin
	print '@BarDataQueryId neexistuje - nebudu jej nastavovat'
	SET @BarDataQueryId=NULL
	--RETURN
end
--==============vkladani==============
	if not exists (SELECT top 1 1 FROM [ProServer].[dbo].[AppEnd] where SystemName = 'iCC.DesktopClient')
	begin 
		INSERT INTO [ProServer].[dbo].[AppEnd] ([AppEndId],[DisplayName],[SystemName],[AppGroupName])
		 VALUES ('9DE773CB-0500-4B98-A076-25F2CC52274A','iCC.DesktopClient','iCC.DesktopClient','')
	end

	declare @EndAppId as uniqueidentifier = (SELECT top 1 AppEndId FROM [ProServer].[dbo].[AppEnd] where SystemName = 'iCC.DesktopClient')


	--dohledam seznam uzivatelu k zavedeni (pokud jsou ve WA a nejsou v ProServeru nebo Perso)
	declare @NewUsers as table (AgentId uniqueidentifier, Exists_PS bit, Exists_Perso bit)
		   --ti, kteri nejsou v ProServeru a nekteri maji/nemaji Perso
		   insert into @NewUsers
				 select 
						AgentId
						,0 as Exists_PS
						,case when AgentId not in (select AgentId from $(iCC).dbo.Perso where RefName in ('ProCaller#EventHandlingDefinition')) then 0 else 1 end as Exists_Perso
				 from $(iCC).dbo.Agent as a with (nolock) 
				 where Deleted = 0 and Template = 0 
				 --and a.LastLogonUtc is not null -- ZbH: Toto bránilo přidání nového uživatele
				 --and exists (select top 1 1 from $(iCC).dbo.Skill s with (nolock) where s.AgentId = a.AgentId) 
				 and not exists (select top 1 1 from ProServer.dbo.Credentials as c with (nolock) where AppEndId = @EndAppId and Deleted = 0
								and a.SystemName = c.SystemName
								)
				and AgentId = @MyAgentId

		   --ti, kteri jsou v PS, ale nemaji Perso
		   insert into @NewUsers
				 select 
						AgentId
						,1 as Exists_PS
						,0 Exists_Perso
				 from $(iCC).dbo.Agent as a with (nolock)  where Deleted = 0 and Template = 0 and a.LastLogonUtc is not null and exists (select top 1 1 from $(iCC).dbo.Skill s with (nolock) where s.AgentId = a.AgentId) 
						and AgentId not in (select AgentId from $(iCC).dbo.Perso where RefName in ('ProCaller#EventHandlingDefinition'))
						and AgentId not in (select AgentId from @NewUsers)
				--and AgentId = 'CCDB282E-2CF1-4ECD-A12C-FA2C3818AD1B' --fs-sql_demo\kubat
 
 --select LastLogonUtc,* from $(iCC).dbo.Agent a 
 --inner join @NewUsers n on n.AgentId = a.AgentId
 --where n.AgentId is not null
   DECLARE @CountNewUsers NVARCHAR(5) =CONVERT(NVARCHAR(5),(select count(1) from @NewUsers))
   PRINT 'I have found '+@CountNewUsers+' new agents'

	--doplnim Perso, BarDataQueryId, UseChannels, ProServer 
	while (select count(1) from @NewUsers) >=1
	begin
		   --uzivatel k zavedeni
		   declare @NewUserId as uniqueidentifier = (select top 1 AgentId from @NewUsers)
		   declare @WebAdmin_DisplayName as nvarchar (150) 
		   declare @WebAdmin_TeamName as nvarchar (100) 
		   declare @WebAdmin_SystemName as nvarchar (100)
		   declare @WebAdmin_FullSystemName as nvarchar (100)
		   declare @AgentId as uniqueidentifier 
		   select 
				 @WebAdmin_DisplayName = DisplayName
				 ,@WebAdmin_TeamName = TeamName
				 ,@WebAdmin_SystemName = SystemName
				 ,@AgentId = AgentId
		   from $(iCC).dbo.agent where AgentId = @NewUserId
		   set @AgentName = substring(@WebAdmin_SystemName, charindex('\',@WebAdmin_SystemName)+1,100)
		   if @Domain is NULL set @DomainUserName = 'NTUSER' ELSE set @DomainUserName = @Domain + '\' + @AgentName
		   --vlozeni Perso do iCC kvuli DesktopClientu
		   if (select top 1 Exists_Perso from @NewUsers where AgentId = @NewUserId) = 0
				 begin
						insert into $(iCC).dbo.[Perso] ([PersoId],[AgentId],[Profile],[RefName],[RefId],[JsonData],[ContextId])
						 VALUES (NEWID(),@NewUserId,0,'ProCaller#EventHandlingDefinition',NULL,@EventHandlingDefinition,NULL)
						insert into $(iCC).dbo.[Perso] ([PersoId],[AgentId],[Profile],[RefName],[RefId],[JsonData],[ContextId])
						 VALUES (NEWID(),@NewUserId,0,'ProCaller#RibbonDefinition',NULL,@RibbonDefinition,NULL)
				 end
			
			--BarDataQueryId v tabulce Agent, doplneni ProCaller do Seating, pokud neni
			update $(iCC).dbo.Agent
				set BarDataQueryId = @BarDataQueryId
			where AgentId = @NewUserId

			update $(iCC).dbo.Seating 
			set LoginClientModels = 'ProCaller;WebCaller;WebClient'
				,UseClientModels = 'ProCaller;WebCaller;WebClient'
			where LoginClientModels like '%Web%' and LoginClientModels not like '%ProCaller%'
			 and AgentId = @NewUserId

		   --vlozeni Account do ProServer
		   if (select top 1 Exists_PS from @NewUsers where AgentId = @NewUserId) = 0
		   --declare @ProServer_AccountId as uniqueidentifier = newid ()
		   INSERT INTO [ProServer].[dbo].[Agent]
						   ([AgentId]
						   ,[DisplayName]
						   ,[Description]
						   ,[TeamName]
						   ,[Deleted]
						   ,[SystemName]
						   ,[Culture])
				 VALUES
						   (@AgentId
						   ,@WebAdmin_DisplayName
						   ,NULL
						   ,@WebAdmin_TeamName
						   ,0
						   ,@DomainUserName
						   ,NULL)
 
 
		   declare @ProServer_CredentialsId as uniqueidentifier = newid ()
		   INSERT INTO [ProServer].[dbo].[Credentials]
						   ([CredentialsId]
						   ,[AgentId]
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
						   ,@AgentId
						   ,(select MAX(Rank) + 5 from ProServer.dbo.Credentials)
						   ,@DomainUserName
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
						   ,[AgentId]
						   ,[ExtensionId]
						   ,[AppEndId]
						   ,[DataValue]
						   ,[LastChange])
				 VALUES
						   (@ProServer_DataItemId
						   ,'UserData'
						   ,@AgentId
						   ,NULL
						   ,@EndAppId
						   --,concat('<?xml version="1.0" encoding="utf-8"?><UserData><IdentityCC>',@WebAdmin_SystemName,'</IdentityCC></UserData>')
						   --,@DataValue
						   ,REPLACE(@DataValue,'NTUSER',@WebAdmin_SystemName)
						   ,getdate())
 
			INSERT INTO [ProServer].[dbo].[Permission] ([PermissionId],[RoleId],[Degree],[ScopeId],[AgentId],[TeamMask],[Supervisor])
			VALUES (NEWID (),@RoleUseChannels,3,NULL,@AgentId,null,null)

			INSERT INTO [ProServer].[dbo].[Permission] ([PermissionId],[RoleId],[Degree],[ScopeId],[AgentId],[TeamMask],[Supervisor])
			VALUES (NEWID (),@RoleExtensionCTI,3,NULL,@AgentId,null,null)

		   --odstraneni zvedeneho (abych nasledne mohl zavest noveho)
		   delete from @NewUsers where AgentId = @NewUserId
	end
END

GO

