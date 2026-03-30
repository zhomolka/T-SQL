
-- Maže duplicitní záznamy z PhoneNumber
UPDATE iCC.dbo.PhoneNumber SET Deleted = 1 WHERE Rank=2

SELECT * FROM  iCC.dbo.PhoneNumber  WHERE Rank=2
