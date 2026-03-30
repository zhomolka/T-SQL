SELECT --TOP (1) PERCENT 
	ReportPath, 
	TimeStart, 
	TimeEnd, 
	UserName, 
	RequestType, 
	Format, 
	TimeDataRetrieval, 
	TimeProcessing, 
	TimeRendering, 
	[Source]
FROM         
	[ReportServer$MSSQL_B].[dbo].ExecutionLog2
WHERE 1=1     
 --AND	(ReportPath = N'/SummaryByProject')
ORDER BY 
	TimeStart DESC
