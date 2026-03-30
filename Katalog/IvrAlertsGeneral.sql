USE [FSCUSTOM]
GO

/****** Object:  StoredProcedure [dbo].[IvrAlertsGeneral]    Script Date: 10/19/2022 11:42:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		ZbH
-- Create date: 12.10.22
-- Description:	Nastavení IVR dle formuláře
-- =============================================
CREATE PROCEDURE [dbo].[IvrAlertsGeneral] 
	@ScenarioResultId uniqueidentifier,
	@IvrStepId uniqueidentifier
AS
BEGIN

--DECLARE @ScenarioResultId as uniqueidentifier = '217659c5-1dce-e911-80cf-005056b84c65'

DECLARE @Alert as int = (select TOP 1 ResultNumber from icc.dbo.ScenarioResultValue where ScenarioResultId=@ScenarioResultId and TargetColumn='Alert')
DECLARE @From as datetime = (select TOP 1 ResultTime from icc.dbo.ScenarioResultValue where ScenarioResultId=@ScenarioResultId and TargetColumn='from')
DECLARE @To as datetime = (select TOP 1 ResultTime from icc.dbo.ScenarioResultValue where ScenarioResultId=@ScenarioResultId and TargetColumn='to')
DECLARE @TTS as nvarchar(max) = (select TOP 1 ResultText from icc.dbo.ScenarioResultValue where ScenarioResultId=@ScenarioResultId and TargetColumn='TTS')

IF @Alert=50
UPDATE iCC.dbo.IvrStep SET FileName='>eliska8ka> '+@TTS, TimeFrom=@From, TimeTo=@To  WHERE IvrStepId=@IvrStepId
ELSE
UPDATE iCC.dbo.IvrStep SET FileName='alert/'+convert(nvarchar(20),@Alert), TimeFrom=@From, TimeTo=@To  WHERE IvrStepId=@IvrStepId


END

GO

