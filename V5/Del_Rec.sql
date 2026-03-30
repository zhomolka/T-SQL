 --USE Frontstage
 DECLARE @Id AS UNIQUEIDENTIFIER='77F81F33-C8A9-4883-A480-C3D29D8541CC'
DECLARE @from AS date=convert(datetime, '2017.06.26')
 DECLARE @to AS datetime=DATEADD(Month,-9,GETDATE())
 IF 1=1
 BEGIN
    SET @from=DATEADD(Day,-5,GETDATE())
    SET @to=GETDATE()
  END

 BEGIN TRANSACTION

 /*
 DELETE FROM DataqueryColumn
wHERE 1=1
    AND Dataqueryid=@Id
*/


 DELETE TOP (10000) FROM Message
wHERE 1=1
  AND TimeUtc>@from
   AND Gatewayid='f8e38ef1-e6cb-4514-9764-580707b02a04'
  AND SubjectField LIKE 'Undelivered Mail Returned t%'
  AND Direction='I'

--COMMIT TRANSACTION

ROLLBACK TRANSACTION
/*

DELETE TOP (700) DQC
FROM DataQueryColumn DQC
  inner join DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE /*DQ.Deleted=0 AND*/ QueryGroup='ServiceAPP' AND QueryGroup IS NOT NULL
	--AND Dataqueryid=@Id

 DELETE TOP (50) FROM Dataquery
wHERE 1=1
    AND QueryGroup='ServiceAPP'
	--AND Dataqueryid=@Id

DELETE TOP (13) FROM [Portal]
wHERE 1=1
  AND Navgroup='AdminPageNav'
  AND  HashPage='Admin_Agenti' --OR HashPage='ServiceAPP_KontSys'


 DELETE FROM Portal
wHERE 1=1
    AND Navgroup='AdminPageNav'

	 DELETE FROM Dataquery
wHERE 1=1
    AND QueryGroup='ServiceAPP'



 DELETE QU FROM .dbo.Queue  QU
    LEFT JOIN .[dbo].[InboundCall] IC ON QU.CommId=IC.InboundCallId
	LEFT JOIN .[dbo].[OutboundCall] OC ON QU.CommId=OC.OutboundCallId
	LEFT JOIN .[dbo].[Message] ME ON QU.CommId=ME.MessageId
	LEFT JOIN .[dbo].[Chat] CH ON QU.CommId=CH.ChatId

WHERE --
 ChannelIndex IN (1,11) /* Emaily*/ AND (ME.Messageresult=2 OR ME.MessageId IS NULL)
 --ME.Messageresult<>'Active'


DELETE FROM iCC.dbo.ChangeRequest
WHERE ChangeRequestTimeUtc<@to

DELETE FROM iCC.dbo.PhoneNumber
WHERE DisplayName='BlackListNew'

DELETE FROM ASPNET_iCC.dbo.aspnet_PersonalizationAllUsers
WHERE PathId=@Id

DELETE PC FROM iCC.dbo.PhoneComposition PC
  inner join iCC.dbo.PhoneNumber PN on PN.PhoneNumberId=PC.PhoneNumberId
WHERE PN.DisplayName='BlackListNew'

*/