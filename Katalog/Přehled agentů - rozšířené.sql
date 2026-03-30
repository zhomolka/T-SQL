/* Port_SupervisorPage: Přehled agentů - rozšířené */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
 VALUES(N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'Přehled agentů - rozšířené',N'Agenti - Aktuální plachta s přehledem agentů',N'Port_SupervisorPage',N'WorkplaceStatus desc, StatusName',N'
SELECT AG.AgentId
    ,AG.AgentId as RecordId
    ,ST.StatusId
            ,W.Number AS Extension
            ,AG.DisplayName AS AgentName

            ,AG.teamname as TeamName
            --,AG.GroupName as GroupName 
            ,ST.DisplayName AS StatusName
            ,W.State AS WorkplaceStatus
            ,curr.ActualStatusDuration as StateLength 
            ,fs_custom.dbo.TimeUTC_Local(ag.LastLogonUtc) as LastLogonUtc
            ,b.DisplayName as BusyConditionName
            ,case when ag.Activity <> ''Logoff'' then ''Online'' else ''Offline'' end as [Online]
       
            ,CAST(CASE WHEN AG.Activity = ''Ready'' /*AND w.State = ''Free''*/ THEN 1 ELSE 0 END AS bit) AS IsFree
            ,CAST(CASE WHEN AG.Activity = ''Pause'' THEN 1 ELSE 0 END AS bit) AS IsPause
            ,CAST(CASE WHEN AG.Activity = ''PostCall'' THEN 1 ELSE 0 END AS bit) AS IsPCP
				
			,(case 
                when w.State = ''Busy'' and q.InActive > 0 then ''IN''
                when w.State = ''Busy'' and q.OutActive > 0 then ''OUT''
                when q.ChatActive > 0 and ag.activity <> ''Logoff'' then ''CHAT''
                when q.MailActive > 0 and ag.activity <> ''Logoff'' then ''MAIL''
                else ''-''
            end) as ActualIanteraction

                    ,CASE WHEN VoiceChannel = 1 THEN ''PbxIn_ON'' WHEN VoiceChannel = 0 THEN  ''PbxIn_OFF'' ELSE ''PbxIn_ELSE'' END as [Agent_Voice]
                    ,CASE WHEN VoiceEnabled = 1 THEN ''PbxIn_ON_Sup'' WHEN VoiceEnabled = 0 THEN  ''PbxIn_OFF_Sup'' ELSE ''PbxIn_ELSE_Sup'' END as [Sup_Voice]
                    ,CASE WHEN MessageChannel = 1 THEN ''Email_ON'' WHEN MessageChannel = 0 THEN  ''Email_OFF'' ELSE ''Email_ELSE'' END as [Agent_Message]
                    ,CASE WHEN MessageEnabled = 1 THEN ''Email_ON_Sup'' WHEN MessageEnabled = 0 THEN  ''Email_OFF_Sup'' ELSE ''Email_ELSE_Sup'' END as [Sup_Message]
                    ,CASE WHEN ChatChannel = 1 THEN ''WebIM_ON'' WHEN ChatChannel = 0 THEN  ''WebIM_OFF'' ELSE ''WebIM_ELSE'' END as [Agent_Chat]
                    ,CASE WHEN ChatEnabled = 1 THEN ''WebIM_ON_Sup'' WHEN ChatEnabled = 0 THEN  ''WebIM_OFF_Sup'' ELSE ''WebIM_ELSE_Sup'' END as [Sup_Chat]
		,InboundTotal
		,OutboundTotal
		,MessageTotal
		,ChatTotal
	   FROM icc.dbo.Agent AS AG  WITH(NOLOCK)
    left JOIN icc.dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
    inner JOIN icc.dbo.Status AS ST WITH(NOLOCK)  ON AG.StatusId=ST.StatusId
    left join icc.dbo.BusyCondition as b on b.BusyConditionId = ag.BusyConditionId
    left join icc.dbo.Proficiency as p on p.AgentId = ag.AgentId and LanguageId = ''aae9b56e-c8fc-4cd2-9bab-1e39e546d092''
	inner join (SELECT * FROM [FS_custom].[dbo].[AgentsCurrStatusDuration] (@Now)) as curr on curr.AgentId = AG.AgentId
	left join (
		select 
			a.AgentId,COUNT(1) as  InboundTotal
		from iCC.dbo.agent a with (nolock) 
		left join iCC.dbo.InboundCall i with (nolock) on i.AgentId = a.AgentId AND I.DistributionTime>=@Today AND I.CallResult=''Served''
		where I.DistributionTime>=@Today AND I.CallResult=''Served''
		group by a.AgentId) as i on i.AgentId = ag.AgentId
	left join (
		select 
			a.AgentId,COUNT(1) as OutboundTotal
		from iCC.dbo.agent a with (nolock) 
		left join icc.dbo.OutboundCall o with (nolock) on o.AgentId = a.AgentId AND O.DistributionTime>=@Today
		where O.DistributionTime>=@Today
		group by a.AgentId) as o on o.AgentId = ag.AgentId
	left join (
		select 
			a.AgentId,COUNT(1) as MessageTotal
		from iCC.dbo.agent a with (nolock) 
		left join iCC.dbo.Message m with (nolock) on m.AgentId = a.AgentId and m.ReceivedSentTime>=@Today AND M.MessageResult=''Closed''
		where m.ReceivedSentTime>=@Today AND M.MessageResult=''Closed''
		group by a.AgentId) as m on m.AgentId = ag.AgentId
	left join (
		select 
			a.AgentId,COUNT(1) as ChatTotal
		from iCC.dbo.agent a with (nolock) 
		left join iCC.dbo.Chat ch with (nolock) on ch.AgentId = a.AgentId and ch.DistributionTime>=@Today
		where ch.DistributionTime>=@Today
		group by a.AgentId) as ch on ch.AgentId = ag.AgentId
	left join (select 
				AgentId
				,sum(case when q.ChannelIndex = 0 and q.commstate = 11 then 1 else 0 end) as InActive
				,sum(case when q.ChannelIndex = 9 and q.commstate = 11 then 1 else 0 end) as OutActive
				,sum(case when q.ChannelIndex = 8 and q.commstate = 11 then 1 else 0 end) as ChatActive
				,sum(case when q.ChannelIndex = 11 and q.commstate = 11 then 1 else 0 end) as MailActive
				from icc.dbo.Queue as q with (nolock)
				where AgentId is not null
				group by AgentId) as q on q.AgentId = AG.AgentId
',0,NULL,NULL,NULL,0,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'0f9d0ee9-4f34-431e-9a7b-8aea2cbf1a96',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'X',N'Toggle',N'AgentId',NULL,NULL,N'~/CustomImages/Bullet-{0}.png',NULL,NULL,NULL,NULL,0,20,1,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'982bf2f7-201c-433a-a84a-29dcfdfd3250',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$Cmn_Agent',N'HyperLink',N'AgentName',NULL,N'AgentId',N'/ReactClient/Pages/DataQueryPage.html?Id=73342443-45f0-4c26-aa6c-37335adb34a4&filtername=AgentId&filtervalue={0}&PageSize=50',NULL,NULL,N'AgentName',NULL,0,140,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'141b4202-824f-4b04-910a-a5cd8b8acef6',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$Cmn_Team',N'Select',N'TeamName',NULL,NULL,NULL,NULL,NULL,N'TeamName',NULL,0,50,50,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'85f51d2b-e69d-4821-b5c2-b2968db3b54b',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$Cmn_WorkplaceState',N'Select',N'WorkplaceStatus',NULL,NULL,NULL,NULL,N'WorkplaceState',N'WorkplaceStatus',NULL,0,60,120,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'c80780f2-9a5c-4a30-bc32-985e6d3c72b2',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$Cmn_AgentState',N'ForeignKey',N'StatusName',NULL,NULL,NULL,N'StatusId',NULL,N'StatusName',NULL,0,75,140,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'c12b0198-7dc5-48a2-a3d3-c29c48b4350c',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$Cmn_Active',N'Text',N'ActualIanteraction',NULL,NULL,NULL,NULL,NULL,N'ActualIanteraction',NULL,0,50,145,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'08f79e0f-f770-46b5-970c-b15213754a9b',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$Cmn_StateLength',N'Duration',N'StateLength',NULL,NULL,NULL,NULL,N'DurationHMMSS',N'StateLength',NULL,0,65,150,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'd952935c-876e-4d8b-ad8e-3b76681aa273',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$Cmn_LogonTime',N'DateTimeFromTo',N'LastLogonUtc',N'{0:HH:mm}',NULL,NULL,NULL,NULL,N'LastLogonUtc',NULL,0,65,180,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'236cef9c-45d1-4406-9b4e-402ac9f08620',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'IsFree',N'Color',N'IsFree',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,220,N'#CCFADF ',0,NULL,N'success',NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'c960a10a-8279-423c-868f-c863b8a12171',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'IsPause',N'Color',N'IsPause',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,239,N'#FF6347',0,NULL,N'danger',NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'8d3207f4-b106-4f40-9e8d-74b912315356',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'IsPCP',N'Color',N'IsPCP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,259,N'#FFA500',0,NULL,N'warning',NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'7fe2d6f5-3d45-4500-a07b-ffcd8f0834fe',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$Cmn_Workplace',N'Text',N'Extension',NULL,NULL,NULL,NULL,NULL,N'Extension',NULL,0,60,279,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'63c1c200-7622-422a-a99e-c25d87a00894',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$Cmn_BusyCondition',N'Text',N'BusyConditionName',NULL,NULL,NULL,NULL,NULL,N'BusyConditionName',NULL,0,150,289,NULL,0,NULL,NULL,100,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'3faa35e9-8f29-4c32-bf44-53602b54e7f1',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'Agent_Inbound',N'Image',N'Agent_Voice',N'~/CustomImages/New/{0}.png',NULL,NULL,NULL,NULL,N'Agent_Voice',NULL,0,80,410,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'712a3525-8abc-4b6e-af79-08b4b31c2579',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'Sup_Inbound',N'Image',N'Sup_Voice',N'~/CustomImages/New/{0}.png',NULL,NULL,NULL,NULL,N'Sup_Voice',NULL,0,80,420,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'96a30abe-2330-44bd-a115-96e326b333f7',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'Agent_Mail',N'Image',N'Agent_Message',N'~/CustomImages/New/{0}.png',NULL,NULL,NULL,NULL,N'Agent_Message',NULL,0,80,430,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'bd7caead-f135-46bf-b903-96cb0d1983f1',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'Sup_Message',N'Image',N'Sup_Message',N'~/CustomImages/New/{0}.png',NULL,NULL,NULL,NULL,N'Sup_Message',NULL,0,80,440,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'6e0db46e-a662-473e-814e-aa872d227327',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'Agent_Chat',N'Image',N'Agent_Chat',N'~/CustomImages/New/{0}.png',NULL,NULL,NULL,NULL,N'Agent_Chat',NULL,0,80,450,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'8223f33f-8530-48ab-b2f2-fe2513e51be3',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'Sup_Chat',N'Image',N'Sup_Chat',N'~/CustomImages/New/{0}.png',NULL,NULL,NULL,NULL,N'Sup_Chat',NULL,0,80,460,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'f0c04474-cdb0-4a8e-9e2d-cda8ec421f66',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$Cmn_Online',N'Image',N'Online',N'~/CustomImages/New/{0}.png	',NULL,NULL,NULL,NULL,N'Online',NULL,0,60,500,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'7ed0bf9f-e7ef-47c1-8a2e-34d002623481',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$CallsIN',N'Integer',N'InboundTotal',NULL,NULL,NULL,NULL,NULL,N'InboundTotal',NULL,0,60,510,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'7fac187b-9e22-4b77-bac6-73385e6b2fa1',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$CallsOUT',N'Integer',N'OutboundTotal',NULL,NULL,NULL,NULL,NULL,N'OutboundTotal',NULL,0,60,520,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'96639e1f-a99f-4a5c-abb6-87278626a3e5',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$MessageTotal',N'Integer',N'MessageTotal',NULL,NULL,NULL,NULL,NULL,N'MessageTotal',NULL,0,60,530,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'47c1bd11-5fd4-4720-8063-3b1d7435ba98',N'528d3bd2-5a4a-4c31-a04f-e11f6ce7fcf4',N'$ChatTotal',N'Integer',N'ChatTotal',NULL,NULL,NULL,NULL,NULL,N'ChatTotal',NULL,0,60,540,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)

