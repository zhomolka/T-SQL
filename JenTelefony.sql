-- Napravuje pole ToCcField tam, kde obsahuje pouze telefonní èíslo
BEGIN TRANSACTION

UPDATE MessA SET ToCCField=ISNULL((SELECT TOP 1 ToCcField FROM iCC.dbo.Message AS MessB WHERE MessageType ='Email'  AND CHARINDEX('<',ToCcField)>0 AND ToCCField  LIKE
 RTRIM(MessA.ToCcField)+'%') ,ToCCField)
FROM Message AS MessA
WHERE MessageType ='Email'  AND ToCCField LIKE '+%' AND CHARINDEX('<',ToCcField)=0 

COMMIT TRANSACTION
--ROLLBACK TRANSACTION
----------------------------------------  Kontrola:
SELECT * FROM iCC.dbo.Message WHERE MessageType ='Email'  AND ToCCField LIKE '+%'
-- AND CHARINDEX('<',ToCcField)=0 
