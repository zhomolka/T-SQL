USE iCC
GO
SET STATISTICS TIME ON 
SET DATEFORMAT ymd
DECLARE @from AS datetime=convert(datetime, '2017.06.26')
DECLARE @to AS datetime=convert(datetime, '2017.06.27')
DECLARE @today AS Datetime=CONVERT(Date,GETDATE())
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER=(SELECT TOP 1 AgentId FROM Agent AG LEFT JOIN icc.dbo.Workplace AS W WITH(NOLOCK)  ON AG.WorkplaceId = W.WorkplaceId
WHERE Activity='Ready' AND w.State <> 'Free')
DECLARE @NullId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
DECLARE @Number AS integer
DECLARE @GroupInterval AS integer=1440
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @Version  AS integer=1
DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(Minute,-20,GETDATE())
    SET @to=GETDATE()
  END

EXEC FS_Custom.dbo.FSC_ReleaseWorkplace '9900'
-- SELECT FS_custom.dbo.FSC_DivertInsp(1)
--  EXEC  [FS_custom].[dbo].DesktopClientAdd '79f29001-679d-4214-ac10-f27c0820faa3','RAJAFS'

--EXEC  [FS_custom].[dbo].ImportModul '3F6AA9CD-8FB1-4BE6-804A-54346FE3105C',1
-- exec FS_CUSTOM.dbo.CheckRecAndEmlActivity2
-- EXEC  [FS_custom].[dbo].[Rename_Agent] 'OldSystemName','NewSystemName','NewDisplayName'
 -- exec FS_CUSTOM.dbo.Daily_Maintenance
--exec FS_CUSTOM.dbo.RunScript '62E84A06-6F83-4594-9CCD-A756A096D3B3'
--EXEC [dbo].[Write_Mail] '030c4650-563f-4c73-b418-73855f4e0a68','homolka@atlantis.cz', 'Test','Test' -- Odeslání testovacího mailu
--EXEC FS_CUSTOM.dbo.PridejPravaPoslechu
--EXEC InspectLic
-- select count(*) from Proserver.dbo.extension where Deleted=0 -- Kontrola licencí na ProServeru
/* UPDATE iCC_LE.dbo.Message
  SET  BodyText =  FS_CUSTOM_LE.dbo.ReplaceSmilyes(BodyText),SubjectField =  FS_CUSTOM_LE.dbo.ReplaceSmilyes(SubjectField)
  WHERE ReceivedSentTime>@from

EXEC [FS_custom].[dbo].[UTL_ForceSPRecompilation] 'IsHoliday','',1 
EXEC [FS_custom].[dbo].[ErrorLogProc] 'Test Procedure','Specif','Version','Message',2,60
SELECT * FROM FS_CUSTOM.[dbo].[RecordingLessCalls] (DATEADD(Day,-10,@Today), @Now) ORDER BY CallTime */

GO
