DECLARE @from AS datetime
DECLARE @to AS datetime
--SET @from=convert(datetime, '2016.04.25 00:00')
--SET @to=convert(datetime, '2016.04.26 06:00')
SET @from=GETDATE()-3
SET @to=GETDATE()
DECLARE @Id AS UNIQUEIDENTIFIER='22669630-84AA-49FC-9868-96DEE92E5B55'
 BEGIN TRANSACTION
UPDATE iCC.dbo.Message
SET  BodyText =  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(BodyText,'&aacute;','á'),'&yacute;','ý'),'&uacute;','ú'),'&iacute;','í'),'&#225;','á'),'&#237;','í'),'&scaron;','š')
WHERE    TimeUTC >= @FROM AND TimeUTC <= @TO
--AND MessageId='620b7af4-c7a1-e711-b1bb-0050568306ce'

COMMIT TRANSACTION

--ROLLBACK TRANSACTION
-- &#225;
--From: Vymáhán&#237; HC <vymahanihc@homecredit.cz>Sent: 22. 9. 2017 11:06:35To: vymahaniehcs@homecredit.skCc: Subject: FW: 10Co 243/2016From: "CEO Land Solution spol. s r. o." <rastislav.rehak@corge.sk>Sent: 21.9.2017 15:08:08To: HOME CREDIT <upominka@homecredit.cz>Cc: Subject: 10Co 243/2016       	        		Bez virù. www.avast.com 		 	    
-- &scaron;