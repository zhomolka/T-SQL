 DECLARE @Id AS UNIQUEIDENTIFIER='22669630-84AA-49FC-9868-96DEE92E5B55'

 DECLARE @to AS datetime=DATEADD(Month,-9,GETDATE())
 BEGIN TRANSACTION


COMMIT TRANSACTION

DELETE FROM iCC.dbo.ChangeRequest
WHERE ChangeRequestTimeUtc<@to

--ROLLBACK TRANSACTION
/*
 DELETE QU FROM iCC.dbo.Queue  QU
    LEFT JOIN .[dbo].[InboundCall] IC ON QU.CommId=IC.InboundCallId
	LEFT JOIN .[dbo].[OutboundCall] OC ON QU.CommId=OC.OutboundCallId
	LEFT JOIN .[dbo].[Message] ME ON QU.CommId=ME.MessageId
	LEFT JOIN .[dbo].[Chat] CH ON QU.CommId=CH.ChatId

WHERE --ME.Messageresult='Closed'
 ChannelIndex IN (1,11) /* Emaily*/ AND (ME.Messageresult<>'Active' OR ME.MessageId IS NULL)

DELETE FROM iCC.dbo.PhoneNumber
WHERE DisplayName='BlackListNew'

DELETE FROM ASPNET_iCC.dbo.aspnet_PersonalizationAllUsers
WHERE PathId=@Id

DELETE PC FROM iCC.dbo.PhoneComposition PC
  inner join iCC.dbo.PhoneNumber PN on PN.PhoneNumberId=PC.PhoneNumberId
WHERE PN.DisplayName='BlackListNew'

*/