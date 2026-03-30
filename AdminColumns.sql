SELECT 
      DQ.DataQueryId
	  ,DQC.DisplayName AS ColDispName
	  ,DQC.TargetColumn
      ,ISNULL(PRT.DisplayName,'--- Nepoužito ---') AS PageName
      ,QUERYGROUP
	    --,PRT.NAVGroup
      ,PRT.HashPage
      ,DQ.DisplayName AS QueryName
      ,DQ.[Description]
      ,[QueryGroup]
  FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
    LEFT JOIN .[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
	WHERE DQ.Deleted=0 AND PRT.NAVGroup='AdminPageNav'
	AND DQ.QueryGroup IN ('Admin','Kontakty','Supervizor') AND TargetColumn<>DQC.DisplayName AND DQC.DisplayName NOT LIKE '$%'
	ORDER BY PageName,DQC.DisplayName