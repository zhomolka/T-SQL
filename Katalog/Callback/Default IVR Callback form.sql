/* Default IVR Callback form () */
INSERT [Scenario] ([ScenarioId], [DisplayName], [Description], [GroupName], [OnSaveSqlCmd], [OnCreateSqlCmd], [Deleted], [GdprInheritInboundCall], [GdprInheritOutboundCall], [GdprInheritMessage], [GdprInheritChat], [GdprInheritIssue], [GdprInheritContact], [LogLevel] )
 VALUES(N'b5db8ae5-9774-473e-8b3f-fcc047b14d51',N'Default IVR Callback form',NULL,N'IVR',NULL,NULL,0,0,0,0,0,0,0,0)
/* Scenario:Default IVR Callback form Screen:Tab 1 () */
INSERT [Screen] ([ScreenId] ,[ScenarioId] ,[DisplayName] ,[Description] ,[Rank] ,[FinishButton] ,[SaveButton]  ,[ConditionText] ,[Feature] ,[Deleted] )
 VALUES (N'8b5c128a-84e8-417e-aa3e-c608cdfb4604',N'b5db8ae5-9774-473e-8b3f-fcc047b14d51',N'Tab 1',NULL,1,0,0,N'',NULL,0)
INSERT [ScreenControl] ([ScreenControlId], [ScreenId] ,[DisplayName] ,[Description] ,[TargetColumn] ,[Rank] ,[ControlType] ,[ControlNumber] ,[ControlText] ,[ReadOnly] ,[MandatoryField], [ShowInList] ,[Deleted], [GdprSensitivity], [ExportField] )
 VALUES (N'1e58bea6-69cf-4aac-ba39-b8a540b03ca9',N'8b5c128a-84e8-417e-aa3e-c608cdfb4604',N'IVR_CallerNumber',NULL,N'IVR_CallerNumber',10,N'TextArea',0,N'0',0,0,0,0,0,0)
INSERT [ScreenControl] ([ScreenControlId], [ScreenId] ,[DisplayName] ,[Description] ,[TargetColumn] ,[Rank] ,[ControlType] ,[ControlNumber] ,[ControlText] ,[ReadOnly] ,[MandatoryField], [ShowInList] ,[Deleted], [GdprSensitivity], [ExportField] )
 VALUES (N'7694af62-4144-42ce-a239-528b6a17d247',N'8b5c128a-84e8-417e-aa3e-c608cdfb4604',N'IVR_Callback',NULL,N'IVR_Callback',20,N'TextArea',0,N'0',0,0,0,0,0,0)
INSERT [ScreenControl] ([ScreenControlId], [ScreenId] ,[DisplayName] ,[Description] ,[TargetColumn] ,[Rank] ,[ControlType] ,[ControlNumber] ,[ControlText] ,[ReadOnly] ,[MandatoryField], [ShowInList] ,[Deleted], [GdprSensitivity], [ExportField] )
 VALUES (N'f47a5e86-cf97-4d27-892d-91767d877d65',N'8b5c128a-84e8-417e-aa3e-c608cdfb4604',N'IVR_CB_CHECK',NULL,N'IVR_CB_CHECK',30,N'TextArea',0,N'0',0,0,0,0,0,0)
INSERT [ScreenControl] ([ScreenControlId], [ScreenId] ,[DisplayName] ,[Description] ,[TargetColumn] ,[Rank] ,[ControlType] ,[ControlNumber] ,[ControlText] ,[ReadOnly] ,[MandatoryField], [ShowInList] ,[Deleted], [GdprSensitivity], [ExportField] )
 VALUES (N'd374f63d-1e19-4dee-9939-8a78dfd5f12b',N'8b5c128a-84e8-417e-aa3e-c608cdfb4604',N'IVR_NewCallerNumber',NULL,N'IVR_NewCallerNumber',50,N'TextArea',0,N'0',0,0,0,0,0,0)
/* Update podmíněných ScreenControlId */


