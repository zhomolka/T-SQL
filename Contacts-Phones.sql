SELECT        *
FROM            iCC.dbo.Contact
WHERE        (ContactId = 'E39B0200-DA30-44A6-8CF2-1BADF24E985C')

SELECT        PhoneNumberId, DisplayName, Emails, ContactId, Deleted
FROM            PhoneNumber
WHERE        (Emails LIKE 'dosedelova@feico.cz')


