/* Portal_AgentPage: Agenti , čas ve stavu */
INSERT [DataQuery] ([DataQueryId], [DisplayName], [Description], [QueryGroup], [QuerySortExpression], [QueryText], [ManualFilter], [SnapshotInterval], [CacheInterval], [TimeLine], [Deleted], [LogLevel])
 VALUES(N'2402c221-4e84-4571-8163-dd55774b630b',N'Agenti , čas ve stavu',N'Dnešní přehled - stavy agentů, hovory, emaily',N'Portal_AgentPage',N'Number ASC',N'SELECT 
jmeno+'' H:''+ cast(t1 as varchar) + char(160)+''ZH:'' + cast(t2 as varchar) + char(160)+''@:'' + cast(t3 as varchar) Number
,Text
,FrontColor
,BackColor
,Glyph
FROM (
SELECT
                (select COUNT(1) from icc.dbo.InboundCall i where i.agentid = a.agentid and i.EndTime >= @Today  and i.CallResult = ''Served'' and i.AgentId is not null) t1
                               
                ,(select COUNT(1) from icc.dbo.InboundCall i where i.agentid = a.agentid and i.EndTime >= @Today  and i.CallResult = ''Lost'') t2
 
                ,(select COUNT(1) from icc.dbo.message m where m.agentid = a.agentid and m.EndTime >= @Today ) t3
 
	, a.DisplayName as jmeno
	,(select case 
   when w.State IN (''Busy'',''Transfer'',''Ring'') then (
   
   CASE 
 	 WHEN EXISTS (SELECT Top 1 AnswerTime FROM InboundCall WITH(NOLOCK) WHERE AgentId = a.AgentId AND CallResult = ''Active'') 
		THEN (SELECT Top 1 DATEDIFF(SECOND, AnswerTime, @Now) FROM InboundCall WITH(NOLOCK)  WHERE AgentId = a.AgentId AND CallResult = ''Active'') 
 	 WHEN EXISTS (SELECT Top 1 AnswerTime FROM OutboundCall WITH(NOLOCK)  WHERE AgentId = a.AgentId AND CallResult = ''Active'') 
		THEN (SELECT Top 1 DATEDIFF(SECOND, AnswerTime, @Now) FROM OutboundCall WITH(NOLOCK)  WHERE AgentId = a.AgentId AND CallResult = ''Active'')
   end
   ) else 
	
	
	(SELECT COALESCE(adur.Pripraven, adur.Prestavka, adur.Administrativa, adur.Vyplnuji, adur.Obed,adur.Skoleni, adur.Odhlasen) )
	end) as Text
  ,''#000000'' as FrontColor
  ,(select case 
   when w.State IN (''Busy'',''Transfer'',''Ring'') then ''#ff0000''  -- červená
   when s.DisplayName = ''Aktivní'' then ''#66cc66''  -- zelená
   when s.DisplayName =''Přestávka'' then ''#ffcc00''  -- oranžová
   when s.DisplayName = ''Administrativa'' then ''#33ccff'' -- modrá
   when s.DisplayName = ''Vyplňuji'' then ''#FFFFFF'' -- bílá
   when s.DisplayName = ''Oběd'' then ''#FFFFCC''  -- žlutá
   when s.DisplayName = ''Školení'' then ''#FFFFFF'' -- bílá
   when s.DisplayName = ''Odhlášen'' then ''#BEBEBE'' end -- šedá



  ) as BackColor

  ,(select case (s.Activity)
   when ''Ready'' then ''fa fa-user''  --nejaka zelena
   when ''Pause'' then ''fa fa-user-o''  -- do červenarůžova
   when ''PostCall'' then ''fa fa-user-md'' -- svetle modra
   when ''Logoff'' then ''fa fa-user-times''  --šedá
   end) as Glyph
 
  FROM icc.dbo.Agent as a with (nolock) 
  left join iCC.dbo.Status s with (nolock) on s.StatusId = a.StatusId
  left join iCC.dbo.Workplace w with (nolock) on w.WorkplaceId = a.WorkplaceId
  left join FS_custom.dbo.AgentsStatusDuration_Actual(@Now) as adur on adur.AgentId = a.AgentId
  WHERE a.Deleted = 0 AND a.Template=0 and a.TeamName = ''CC Kolín'' ) A ',0,NULL,NULL,NULL,0,0)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'5a7cd6dd-e953-44c0-bc34-2cda6cd812dc',N'2402c221-4e84-4571-8163-dd55774b630b',N'Text',N'Duration',N'Text',NULL,NULL,NULL,NULL,N'DurationDHHMMSS',N'Text',NULL,0,80,10,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'896594ee-e207-4858-8bc4-e253f6428785',N'2402c221-4e84-4571-8163-dd55774b630b',N'Number',N'Text',N'Number',NULL,NULL,NULL,NULL,NULL,N'Number',NULL,0,80,20,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'83417727-ce9a-4914-8be4-95d6a8f767c7',N'2402c221-4e84-4571-8163-dd55774b630b',N'FrontColor',N'Text',N'FrontColor',NULL,NULL,NULL,NULL,NULL,N'FrontColor',NULL,0,80,30,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)
INSERT [DataQueryColumn] ([DataQueryColumnId], [DataQueryId], [DisplayName], [Model], [TargetColumn], [TargetFormat], [UrlColumn], [UrlFormat], [GuidColumn], [Convertor], [SortExpression], [SortExpressionDesc], [NoFilter], [Width], [Rank], [Color], [Deleted], [SqlCmd], [Css], [ToolTip], [LiteralGroup], [GlyphColumn], [GlyphFormat], [GdprSensitivity])
 VALUES (N'f51643eb-0f95-4d7c-98a0-ace61aa642f7',N'2402c221-4e84-4571-8163-dd55774b630b',N'BackColor',N'Text',N'BackColor',NULL,NULL,NULL,NULL,NULL,N'BackColor',NULL,0,80,40,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL, NULL)

