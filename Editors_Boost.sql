USE iCC
GO
IF (SELECT TOP 1 1 FROM sys.indexes WHERE name = 'AX_ScenarioResultValue_ScenarioResultId_ScreenControlId')>0
  BEGIN
    PRINT 'Index exists'
    ALTER INDEX [AX_ScenarioResultValue_ScenarioResultId_ScreenControlId] ON [dbo].[ScenarioResultValue] REBUILD PARTITION = ALL WITH ( PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, ONLINE = OFF, SORT_IN_TEMPDB = OFF)
    ALTER INDEX [AX_ScenarioResultValue_ScenarioResultId_ScreenControlId] ON [dbo].[ScenarioResultValue] REORGANIZE WITH ( LOB_COMPACTION = ON)
  END
ELSE
 IF NOT EXISTS (SELECT TOP 1 1 FROM sys.indexes WHERE name = 'CX_ScenarioResultId_ScreenControlId') 
  CREATE NONCLUSTERED INDEX CX_ScenarioResultId_ScreenControlId
  ON [dbo].[ScenarioResultValue] ([ScenarioResultId],[ScreenControlId])
GO