BEGIN
       -- Emaily ve stavu naplánovnáno staší, než pùl hodiny
       declare @pocetNaplanovanychMailu int = (SELECT count(distinct a.messageID)
                                          FROM [iCC].[dbo].[Message] a join icc.dbo.MessageEvent b on a.MessageId = b.messageid
                                          where messagephase = 'scheduled' and Eventtype = 'Sent' and b.TimeLocal < (select dateadd(mi, -30, getdate())))
       -- Složení textu do tìla mailu s parametrem
       declare @teloMailu nvarchar(300) = 'Poèet naplánovaných emailù je ' + convert(nvarchar(10), @pocetNaplanovanychMailu) + '. Bylo by dobré provìøit, zda jsou emaily naplánované zámìrnì. Emaily jsou naplánované déle, jak pùl hodiny a aktuálnì nikde ve firmì neplánují maily pro pozdìjší odeslání. Pokud se tak v budoucnu bude dít, je tøeba upravit logiku kontrolního JOBU na JARILU, který odesílá tuto notifikaci.'
       -- Procedura pro odeslání mailu v pøípadì, že bude splnìna podmínka
if (@pocetNaplanovanychMailu > 0)
BEGIN
       EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'FrontstageMail',
        @recipients = 'Zbynek.Malek@homecredit.cz; Martin.Skala@homecredit.cz',
        @subject = 'V aplikaci FrontstageCZ jsou neodeslané naplánované emaily',
             @importance  = 'High',
             @body = @teloMailu
END
END
