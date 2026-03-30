/* Autoreply Holiday () */
INSERT [ImrScript] ([ImrScriptId], [DisplayName], [Description], [ScenarioId], [Deleted])
 VALUES(N'3a5df7e4-fb42-4894-a5c9-19ecdc3e601c',N'Autoreply Holiday',N'Posílá zprávu ve svátek',N'623860de-3600-4f4b-83f7-cb0766942b63',0)
INSERT [ImrStep] ([ImrStepId] ,[ImrScriptId] ,[DisplayName] ,[Rank] ,[Action] ,[Parameters] ,[TargetId] ,[TextMatchId] ,[TimeMode] ,[TimeFrom] ,[TimeTo] ,[LanguageId] ,[Deleted] )
 VALUES (N'0042390f-1cf7-44ed-bdef-23f26c4afe5b',N'3a5df7e4-fb42-4894-a5c9-19ecdc3e601c',N'Test svátku',10,N'SwitchDb',N'##None##',N'SELECT FS_Custom.dbo.TestHoliday()',NULL,NULL,NULL,NULL,NULL,NULL,0)
INSERT [ImrStep] ([ImrStepId] ,[ImrScriptId] ,[DisplayName] ,[Rank] ,[Action] ,[Parameters] ,[TargetId] ,[TextMatchId] ,[TimeMode] ,[TimeFrom] ,[TimeTo] ,[LanguageId] ,[Deleted] )
 VALUES (N'042e80ed-7103-4cd0-9d10-a342dcacc74a',N'3a5df7e4-fb42-4894-a5c9-19ecdc3e601c',N'Vyskoč po chybě',15,N'Goto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)
INSERT [ImrStep] ([ImrStepId] ,[ImrScriptId] ,[DisplayName] ,[Rank] ,[Action] ,[Parameters] ,[TargetId] ,[TextMatchId] ,[TimeMode] ,[TimeFrom] ,[TimeTo] ,[LanguageId] ,[Deleted] )
 VALUES (N'40a04c73-e823-437b-b78c-63fbe75e038b',N'3a5df7e4-fb42-4894-a5c9-19ecdc3e601c',N'Pošli zprávu',20,N'Reply',NULL,NULL,N'b4b403dd-83c2-e911-80db-002590440ff4',NULL,NULL,NULL,NULL,NULL,0)
INSERT [ImrStep] ([ImrStepId] ,[ImrScriptId] ,[DisplayName] ,[Rank] ,[Action] ,[Parameters] ,[TargetId] ,[TextMatchId] ,[TimeMode] ,[TimeFrom] ,[TimeTo] ,[LanguageId] ,[Deleted] )
 VALUES (N'b879b506-6064-485c-8965-86be70a3a430',N'3a5df7e4-fb42-4894-a5c9-19ecdc3e601c',N'Konec',30,N'Goto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)

