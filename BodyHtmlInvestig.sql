USE iCC
GO
DECLARE @MessagId AS UniqueIdentifier= 'f9d62c5b-1ca6-ec11-b804-005056a0e001' -- 3e6c3dbe-42ba-ec11-b807-005056a0a12b
DECLARE @BodyHTML AS nvarchar(MAX)
DECLARE @BodyHTMLNew AS nvarchar(MAX)
DECLARE @EML AS nvarchar(MAX)
DECLARE @EMLNew AS nvarchar(MAX)
DECLARE @FirstPos AS Integer
DECLARE @LastPos AS Integer
-- Kdyz jsem konvertoval EML na varchar(max) a potom zpet na varbinary(MAX) a zapsal do DB, bylo vse OK

SET @EML=(SELECT TOP 1 convert(nvarchar(max),EML,0 ) --AS [Style 0, varbinary to character] -- Cyrillic_General_CI_AI
  FROM [iCC].[dbo].[Message] ME   
  WHERE ME.MessageId=@MessagId) 
SET @FirstPos=CHARINDEX ( '<img class' , @EML )
IF @FirstPos <> 0
  SET @LastPos=CHARINDEX ( '>' , @EML,@FirstPos )

SELECT @FirstPos AS FirstPos,@LastPos AS LastPos ,@EML AS EML

IF @FirstPos <> 0 AND @LastPos <> 0 --AND 1=2
  BEGIN
	SET @EMLNew=SUBSTRING(@EML,1,@FirstPos-1)+SUBSTRING(@EML,@LastPos+1,999999)
    SELECT @EMLNew


	 UPDATE iCC.dbo.Message 
	 SET  Eml=convert(varbinary(MAX),@EMLNew)
	 WHERE MessageId=@MessagId
	 AND 1=2
 END