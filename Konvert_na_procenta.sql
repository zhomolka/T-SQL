DECLARE @DataQueryId AS UniqueIdentifier = '85d24cf5-bd97-4a05-b44d-58764b13a92e'
declare @coef as float = (select SUM(width)/100.00 from DataQueryColumn where DataQueryId = @DataQueryId and width is not null AND Deleted=0)
update DataQueryColumn set Width = round(Width/@coef,0) where DataQueryId = @DataQueryId and Width is not null
update DataQueryColumn set Width = 0 where DataQueryId = @DataQueryId and Deleted=1
declare @Sirky as integer = (select SUM(width) from DataQueryColumn where DataQueryId = @DataQueryId and width is not null AND Deleted=0)
PRINT 'Souèet šíøek sloupcù = '+CONVERT(NVARCHAR(5),@Sirky)