-- Maže duplicity v tabulce PhoneNumber
DELETE FROM PhoneNumber WHERE PhoneNumberId NOT IN
(SELECT  MIN(PhoneNumberId) AS PhoneNumberId
FROM  PhoneNumber 
GROUP BY Emails,DisplayName,Description,Rank,ContactId,Numbers)
