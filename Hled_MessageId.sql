--SELECT TOP 1 CONVERT(NVARCHAR(MAX),EML) FROM Icc_Backup.dbo.Message
--SELECT TOP 1 SUBSTRING(REPLACE(EML,'0','0'),500,1000) FROM Icc_Backup.dbo.Message
--SELECT TOP 1 SUBSTRING(EML,500,1000) FROM Icc_Backup.dbo.Message
--SELECT TOP 1 CHARINDEX(CONVERT(NVARCHAR(MAX),EML,2),'Message-id') FROM Icc_Backup.dbo.Message
--SELECT TOP 1 CONVERT(NVARCHAR(MAX),EML,2) FROM Icc_Backup.dbo.Message
DECLARE @ProvedUpdate AS Binary = 0
DECLARE @Start AS Integer = 1930
DECLARE @Len AS Integer = 50
SELECT TOP 1 REPLACE(SUBSTRING(EML, @Start,@Len),'0','0') FROM Icc.dbo.Message WHERE SUBSTRING(EML, @Start,@Len) LIKE '%Message-id:<%'
-- Text Message-id: konèí na pozici 1888

IF @ProvedUpdate=1
 BEGIN
 BEGIN TRANSACTION
   UPDATE ME
      --SET  EML = (SELECT TOP 1 EML FROM Icc_Backup.dbo.Message)
	  SET  EML = SUBSTRING(EML,1,@Start+11)+CONVERT(Varbinary(1),'XXX')+SUBSTRING(EML,@Start+12,100000)
     FROM iCC.dbo.Message ME
  WHERE MessageId = 'fa9ca75b-c35a-e911-90ff-005056011652'

COMMIT TRANSACTION

--ROLLBACK TRANSACTION
END