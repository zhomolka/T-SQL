 UPDATE TOP (1) DQC
SET  DisplayName=TargetColumn
FROM .dbo.DataQueryColumn DQC
  inner join .dbo.DataQuery DQ on DQC.DataQueryId=DQ.DataQueryId
  LEFT JOIN .[dbo].[Portal] PRT ON PRT.JsonData LIKE '%'+CONVERT(NVARCHAR(36),DQ.DataQueryId)+'%'
WHERE DQ.Deleted=0 AND PRT.NAVGroup='AdminPageNav'
	AND DQ.QueryGroup IN ('Admin','Kontakty','Supervizor') AND TargetColumn<>DQC.DisplayName AND DQC.DisplayName NOT LIKE '$%'
