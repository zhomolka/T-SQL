  USE iCC_H
  DECLARE @InstanceExt NVARCHAR(5)='_H'
   -- Pùvodní linky:
  DECLARE @RCLink AS NVARCHAR(100)='ReactClient'
  DECLARE @FSAdmin AS NVARCHAR(100)='FSAdmin'
  DECLARE @iCC AS NVARCHAR(100)= 'iCC'
  DECLARE @FS_Custom AS NVARCHAR(100)='FS_Custom'


  DECLARE @Id AS UNIQUEIDENTIFIER='53380081-770C-4A8B-8297-2C20096EF1C2'
  DECLARE @OrigExpression AS NVARCHAR(100)='ISNULL(M.BodyText, M.BodyHtml) as BodyField'
  DECLARE @NewExpression AS NVARCHAR(100)='LEFT(ISNULL(M.BodyText, M.BodyHtml),150) as BodyField'
  ------------
  -- Správné nové linky:
  DECLARE @RCLinkOK AS NVARCHAR(100)=@RCLink+@InstanceExt
  DECLARE @FSAdminOK AS NVARCHAR(100)=@FSAdmin+@InstanceExt
  DECLARE @iCCOK AS NVARCHAR(100)=@iCC+@InstanceExt
  DECLARE @FS_CustomOK AS NVARCHAR(100)=@FS_Custom+@InstanceExt

  SET @FSAdmin   =@FSAdmin+'/'
  SET @FSAdminOK =@FSAdminOK+'/'
  SET @RCLink    =@RCLink+'/'
  SET @RCLinkOK  =@RCLinkOK+'/'


   BEGIN TRANSACTION
/*
 UPDATE DQC
     SET  UrlFormat = REPLACE(UrlFormat,@FSAdmin,@FSAdminOK)
     FROM .dbo.DataQueryColumn DQC
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND UrlFormat     LIKE '%'+@FSAdmin+'%'
  AND UrlFormat NOT LIKE '%'+@RCLinkOK+'%'*/
----------------------------------------------------
  UPDATE DQC
     SET  UrlFormat = REPLACE(UrlFormat,@RCLink,@RCLinkOK)
     FROM .dbo.DataQueryColumn DQC
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND UrlFormat     LIKE '%'+@RCLink+'%'
  AND UrlFormat NOT LIKE '%'+@RCLinkOK+'%'

  UPDATE DQC
     SET  SQLCMD = REPLACE(SQLCMD,@iCC+'.',@iCCOK+'.')
     FROM .dbo.DataQueryColumn DQC
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND SQLCMD     LIKE '%'+@iCC+'.%'

   UPDATE DQC
     SET  SQLCMD = REPLACE(SQLCMD,@iCC+']',@iCCOK+']')
     FROM .dbo.DataQueryColumn DQC
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND SQLCMD     LIKE '%'+@iCC+']%'

    UPDATE DQC
     SET  SQLCMD = REPLACE(SQLCMD,@FS_Custom+'.',@FS_CustomOK+'.')
     FROM .dbo.DataQueryColumn DQC
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND SQLCMD     LIKE '%'+@FS_Custom+'.%'

   UPDATE DQC
     SET  SQLCMD = REPLACE(SQLCMD,@FS_Custom+']',@FS_CustomOK+']')
     FROM .dbo.DataQueryColumn DQC
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND SQLCMD     LIKE '%'+@FS_Custom+']%'

/*
  -----------------------------------------------------------------------
 UPDATE DQ
     SET  QueryText = REPLACE(QueryText,@iCC+'.',@iCCOK+'.')
     FROM .dbo.DataQuery DQ
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND QueryText     LIKE '%'+@iCC+'.%'
  --AND QueryText NOT LIKE '%'+@iCCOK+'.%'


 SELECT
    'Dataquery' AS MyTable
    ,DisplayName
	,QueryGroup
    ,@FS_Custom AS FS_Custom
	,@FS_CustomOK AS FS_CustomOK
    ,QueryText 
     FROM .dbo.DataQuery DQ
  WHERE 1=1
  AND QueryText     LIKE '%'+@FS_Custom+'.%'
  AND Deleted=0 
  UPDATE DQ
     SET  QueryText = REPLACE(QueryText,@FS_Custom+'.',@FS_CustomOK+'.')
     FROM .dbo.DataQuery DQ
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND QueryText     LIKE '%'+@FS_Custom+'.%'

 UPDATE IVS
     SET  Targets = REPLACE(Targets,@FS_Custom+'.',@FS_CustomOK+'.')
     FROM .dbo.IvrStep IVS
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND Targets     LIKE '%'+@FS_Custom+'.%'

UPDATE IVS
     SET  Targets = REPLACE(Targets,@iCC+'.',@iCCOK+'.')
     FROM .dbo.IvrStep IVS
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND Targets     LIKE '%'+@iCC+'.%'

UPDATE SRO
     SET  OnSaveSqlCmd = REPLACE(OnSaveSqlCmd,@iCC+'.',@iCCOK+'.')
     FROM .dbo.Scenario SRO
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND OnSaveSqlCmd     LIKE '%'+@iCC+'.%'

UPDATE SRO
     SET  OnSaveSqlCmd = REPLACE(OnSaveSqlCmd,@FS_Custom+'.',@FS_CustomOK+'.')
     FROM .dbo.Scenario SRO
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND OnSaveSqlCmd     LIKE '%'+@FS_Custom+'.%'

UPDATE SRO
     SET  OnSaveSqlCmd = REPLACE(OnSaveSqlCmd,@FS_Custom+']',@FS_CustomOK+']')
     FROM .dbo.Scenario SRO
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND OnSaveSqlCmd     LIKE '%'+@FS_Custom+']%'

  --AND QueryText NOT LIKE '%'+@FS_CustomOK+'.%'
/*
   UPDATE DQ
     SET  QueryText = REPLACE(QueryText,@iCC+']',@iCCOK+']')
     FROM .dbo.DataQuery DQ
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND QueryText     LIKE '%'+@iCC+']%'
 -- AND QueryText NOT LIKE '%'+@iCCOK+']%'

  UPDATE DQ
     SET  QueryText = REPLACE(QueryText,@FS_Custom+']',@FS_CustomOK+']')
     FROM .dbo.DataQuery DQ
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND QueryText     LIKE '%'+@FS_Custom+']%'
  --AND QueryText NOT LIKE '%'+@FS_CustomOK+']%'
*/
*/
COMMIT TRANSACTION

--ROLLBACK TRANSACTION
/*
 SELECT  DataQueryId,DisplayName,QueryText
     FROM .dbo.DataQuery DQ
  WHERE 1=1
  --AND DataQueryColumnId=@Id 
  AND QueryText     LIKE '%'+@FS_Custom+']%'
*/
  /*
  UPDATE DQ
     SET  QueryText = REPLACE(QueryText,@OrigExpression,@NewExpression)
     FROM .dbo.DataQuery DQ
  WHERE 1=1
  AND DataQueryId=@Id 
  AND QueryText     LIKE '%'+@OrigExpression+'%'
  AND QueryText NOT LIKE '%'+@NewExpression+'%'
  */
 