DECLARE @DataQueryColumnId AS UniqueIdentifier
DECLARE @UrlColumn AS NVARCHAR(80)
DECLARE @UrlFormat AS NVARCHAR(250),@UrlFormatCor AS NVARCHAR(250)

 DECLARE My_cursor CURSOR FOR   
 SELECT /*TOP 10*/ DataQueryColumnId,UrlColumn,UrlFormat FROM [DataQueryColumn] DQC
  LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
  WHERE UrlFormat IS NOT NULL -- AND Model IN ('HyperLink','Image')  
  AND DQ.QueryGroup='ServiceAPP' 
  AND UrlColumn IN ('MessageId','IssueId','InboundCallId','OutboundCallId') 

   OPEN my_cursor 

  FETCH NEXT FROM My_cursor INTO @DataQueryColumnId,@UrlColumn,@UrlFormat  
  WHILE @@FETCH_STATUS = 0  
    BEGIN
 	  IF @UrlColumn  IS NOT NULL
		BEGIN
		  IF NOT EXISTS(SELECT TOP 1 UrlFormat FROM [DataQueryColumn] DQC
                   LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
                   WHERE DQ.QueryGroup<>'ServiceAPP' AND UrlColumn=@UrlColumn AND UrlFormat=@UrlFormat) -- AND Model='HyperLink' 
            BEGIN
		      SET @UrlFormatCor=(SELECT TOP 1 UrlFormat FROM [DataQueryColumn] DQC
                   LEFT JOIN [DataQuery] DQ ON DQ.DataQueryId=DQC.DataQueryId
                   WHERE DQ.QueryGroup<>'ServiceAPP'  AND UrlColumn=@UrlColumn) -- AND Model='HyperLink' 
              IF @UrlFormatCor IS NOT NULL
			      UPDATE DataQueryColumn SET UrlFormat = @UrlFormatCor WHERE DataQueryColumnId=@DataQueryColumnId
		    END
		END
		FETCH NEXT FROM My_cursor INTO @DataQueryColumnId,@UrlColumn,@UrlFormat  
    END
  CLOSE My_cursor;  
  DEALLOCATE My_cursor;

