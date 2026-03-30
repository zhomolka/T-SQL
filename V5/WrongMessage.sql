/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @from AS datetime=convert(datetime, '2015.11.01')
DECLARE @to AS datetime=convert(datetime, '2015.11.01')
DECLARE @today AS Date=GETDATE()
DECLARE @LastWeek AS date=GETDATE()-7
DECLARE @ThisWeek AS date=GETDATE()-3
DECLARE @ThisMonth AS date=GETDATE()-7
DECLARE @MeAgentId AS UNIQUEIDENTIFIER='ef0de42d-e6c2-4719-a264-9447484f4c8b'
DECLARE @NullId AS UniqueIdentifier= '00000000-0000-0000-0000-000000000000'
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
--USE iCC

SET @from=GETDATE()-10
SET @to=GETDATE()

SELECT TOP (1000) 
     IIF(PN1.Emails LIKE '% %' OR PN1.Emails LIKE '%[%]%' OR PN2.Emails LIKE '% %' OR PN2.Emails LIKE '%[%]%','MOŽNÁ CHYBA','') AS Status
	 ,IIF(PR.Deleted=1,'Zrušený projekt u pøípadu',IIF(ISU.ProjectId IS NULL AND ISU.IssueId IS NOT NULL,'Chybí projekt u pøípadu','')) AS StatusISU
	 ,IIF(PN3.Emails LIKE '% %','Mezera ve Phonenumber.Emails:'+PN3.Emails+':','') AS StatusPN
	 ,ISU.ProjectId
     ,ME.[IssueId]
     ,ME.[ContactId]
	  ,ME.[PhoneNumberId]
      ,ME.[TimeUtc]
      ,ME.RemoteAddress
	  ,PN1.Emails
	  ,PN1.Numbers
	  ,PN2.Emails
	  ,PN2.Numbers
	  ,PN1.Deleted AS Del1
	  ,PN2.Deleted AS Del2

   FROM .[dbo].[Message] ME
   LEFT JOIN .[dbo].[Contact] CON ON CON.ContactId=ME.ContactId
   LEFT JOIN .[dbo].[PhoneNumber] PN1 ON PN1.ContactId=CON.ContactId 
   LEFT JOIN .[dbo].[PhoneNumber] PN2 ON PN2.PhoneNumberId=ME.PhoneNumberId
   LEFT JOIN .[dbo].[PhoneNumber] PN3 ON PN3.PhoneNumberId=ME.PhoneNumberId 
   LEFT JOIN .[dbo].[Issue] ISU ON ME.IssueId=ISU.IssueId
   LEFT JOIN .[dbo].[Project] PR ON PR.ProjectId=ISU.ProjectId
   WHERE 1=1
     AND MessageId='74C1CE6F-0AA9-4154-913D-2EC05FEB6F5A'
    --AND ME.TimeUTC>@From
	--AND (RemoteAddress='patrik.popovic@mediaprintkapa.cz')
   --AND PN1.Emails LIKE '% %' OR PN1.Emails LIKE '%[%]%' OR PN2.Emails LIKE '% %' OR PN2.Emails LIKE '%[%]%'
   ORDER BY ME.TimeUtc
/*  Náprava:
    BEGIN TRANSACTION
  UPDATE ISU
       SET  ProjectId = ME.ProjectId
	FROM .[dbo].[Issue] ISU
    inner join .[dbo].[Message] ME on ME.IssueId=ISU.IssueId
   WHERE 1=1
     AND MessageId='050857c1-51bb-ed11-8447-000c291825ce'
	 AND ISU.ProjectId IS NULL
  COMMIT TRANSACTION

--	 ROLLBACK TRANSACTION
*/