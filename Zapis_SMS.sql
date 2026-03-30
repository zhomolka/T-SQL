INSERT INTO iCC.dbo.Message(TimeUtc,MessageType,MessagePhase,MessageResult,Direction,IssueId,RemoteAddress,ToField,GatewayId,SubjectField,BodyText)
SELECT 
GETUTCDATE(),'SMS','Scheduled','Active','O',Null,'0724610047','+420724610047','b1eb7484-6358-45db-839f-b8407e53bcde','Test SMS',
'Testovací agent resi pripad Test--------- déle než 250 minut'
