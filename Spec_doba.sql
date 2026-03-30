USE [Icc]
GO

INSERT [dbo].[Holiday] ([HolidayId], [DisplayName], [HolidayGroupName], [TimeMode], [TimeFrom], [TimeTo], [Deleted]) VALUES (N'98fc0c9c-1eaf-46ae-a038-0a7544b38cd2', N'SPEC_DOBA1 So-Ne', N'SPEC_DOBA1_HOD', N'DayInWeek', CAST(0x0000A6D80083D600 AS DateTime), CAST(0x0000A6D90128A162 AS DateTime), 0)
GO
INSERT [dbo].[Holiday] ([HolidayId], [DisplayName], [HolidayGroupName], [TimeMode], [TimeFrom], [TimeTo], [Deleted]) VALUES (N'9218cc73-d930-4de3-b6a3-350f9d80e45e', N'SPEC_DOBA1 Po-Pá', N'SPEC_DOBA1_HOD', N'DayInWeek', CAST(0x0000A6D300735B40 AS DateTime), CAST(0x0000A6D701186CF2 AS DateTime), 0)
GO
INSERT [dbo].[Holiday] ([HolidayId], [DisplayName], [HolidayGroupName], [TimeMode], [TimeFrom], [TimeTo], [Deleted]) VALUES (N'c960e44f-8107-4a91-9425-9f398678caac', N'SPEC_DOBA1_OBDOBI', N'SPEC_DOBA1_OBDOBI', N'SingleDay', CAST(0x0000A6D600735B40 AS DateTime), CAST(0x0000A6E501396272 AS DateTime), 0)

INSERT [dbo].[IVRScript] ([IvrScriptId], [DisplayName], [Description], [IvrMachine])
 VALUES (N'fe1c2270-c161-45d9-8fe4-3ad0f9f41941', N'SPECDOBA', N'', N'Integrated')
GO
INSERT [dbo].[IVRStep] ([IvrStepId], [IvrScriptId], [DisplayName], [Rank], [Action], [TimeOut], [WaitTimeOut], [FileName], [MultiLanguage], [Retries], [ResultDigits], [SkipDigits], [ReplayDigits], [Targets], [TargetId], [Numbers], [TimeMode], [TimeFrom], [TimeTo], [Culture], [Deleted], [TargetOnTimeOut], [TargetOnSuccess], [TargetOnFailure]) VALUES (N'0eedbf32-e62b-4a3d-8957-1e1a43bc3960', N'fe1c2270-c161-45d9-8fe4-3ad0f9f41941', N'Speciální prac. doba?', 20, N'Holiday', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, N'6000', NULL, N'SPEC_DOBA1_OBDOBI', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[IVRStep] ([IvrStepId], [IvrScriptId], [DisplayName], [Rank], [Action], [TimeOut], [WaitTimeOut], [FileName], [MultiLanguage], [Retries], [ResultDigits], [SkipDigits], [ReplayDigits], [Targets], [TargetId], [Numbers], [TimeMode], [TimeFrom], [TimeTo], [Culture], [Deleted], [TargetOnTimeOut], [TargetOnSuccess], [TargetOnFailure])
 VALUES (N'00edbf32-e62b-4a3d-8957-1e1a43bc3960', N'fe1c2270-c161-45d9-8fe4-3ad0f9f41941', N'Spec. doba', 6000, N'NOP', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL,NULL, NULL, N'SPEC_DOBA1', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[IVRStep] ([IvrStepId], [IvrScriptId], [DisplayName], [Rank], [Action], [TimeOut], [WaitTimeOut], [FileName], [MultiLanguage], [Retries], [ResultDigits], [SkipDigits], [ReplayDigits], [Targets], [TargetId], [Numbers], [TimeMode], [TimeFrom], [TimeTo], [Culture], [Deleted], [TargetOnTimeOut], [TargetOnSuccess], [TargetOnFailure]) VALUES (N'95163851-1127-4abe-aada-24b05575c72b', N'fe1c2270-c161-45d9-8fe4-3ad0f9f41941', N'Speciální prac. doba?', 6020, N'Holiday', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, N'100', NULL, N'SPEC_DOBA1_HOD', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[IVRStep] ([IvrStepId], [IvrScriptId], [DisplayName], [Rank], [Action], [TimeOut], [WaitTimeOut], [FileName], [MultiLanguage], [Retries], [ResultDigits], [SkipDigits], [ReplayDigits], [Targets], [TargetId], [Numbers], [TimeMode], [TimeFrom], [TimeTo], [Culture], [Deleted], [TargetOnTimeOut], [TargetOnSuccess], [TargetOnFailure]) VALUES (N'0e2048d1-d44e-4e10-94b2-e48736bfa28e', N'fe1c2270-c161-45d9-8fe4-3ad0f9f41941', N'Uzel', 6030, N'TerminateRequest', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[IVRStep] ([IvrStepId], [IvrScriptId], [DisplayName], [Rank], [Action], [TimeOut], [WaitTimeOut], [FileName], [MultiLanguage], [Retries], [ResultDigits], [SkipDigits], [ReplayDigits], [Targets], [TargetId], [Numbers], [TimeMode], [TimeFrom], [TimeTo], [Culture], [Deleted], [TargetOnTimeOut], [TargetOnSuccess], [TargetOnFailure]) VALUES (N'937734fd-2432-4131-8ec4-619256c1a4f1', N'fe1c2270-c161-45d9-8fe4-3ad0f9f41941', N'KONEC', 6040, N'Hangup', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL)
GO

GO