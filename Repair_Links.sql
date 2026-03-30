USE iCC
GO
SET DATEFORMAT ymd
DECLARE @from AS datetime=convert(datetime, '2017.06.26')
DECLARE @to AS datetime=convert(datetime, '2017.06.27')
DECLARE @Now AS datetime=GETDATE()
DECLARE @LastHour AS datetime=GETDATE()-0.04
DECLARE @LastDay AS date=GETDATE()-1
DECLARE @Number AS integer
DECLARE @GroupInterval AS integer=1440
DECLARE @RoundInterval AS integer=@GroupInterval
DECLARE @Version  AS integer=1
DECLARE @LastTime AS bit=1

IF @LastTime=1
 BEGIN
    SET @from=DATEADD(Day,-10,GETDATE())
    SET @to=GETDATE()
  END

DECLARE @Id AS UNIQUEIDENTIFIER='8549248b-e1ff-e911-80c5-001e67e7740d'
 BEGIN TRANSACTION


 UPDATE DQC
SET  UrlFormat='/ReactClient/Pages/MessageEditor.html?Id={0}'
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
WHERE 1=1
   --AND UrlFormat LIKE '~/%'
   --AND UrlFormat NOT LIKE '%png'
   AND UrlFormat = '~/Pages/Messages/DispFormPlus.aspx?Id={0}'
   AND (QueryGroup LIKE '%Portal' OR QueryGroup LIKE 'ADMIN')
 


COMMIT TRANSACTION

--ROLLBACK TRANSACTION
