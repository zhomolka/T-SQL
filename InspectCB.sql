DECLARE @Id uniqueidentifier='80e644c4-bb61-ee11-a194-001e67a4fc92'
DECLARE @callernumber as nvarchar(48) = (select top 1 callernumber from iCC.dbo.InboundCall WHERE InboundCallId=@Id)
DECLARE @Project as uniqueidentifier = (select top 1 ProjectId from iCC.dbo.InboundCall WHERE InboundCallId=@Id)
--Zpìtné volání za ztracený hovor v 03.10.2023 9:06:14
SELECT * FROM iCC.dbo.OutboundCall 
	WHERE CallerNumber like '%'+@callernumber 
		AND CallResult='Scheduled'
		and (DisplayName = 'Callback' OR DisplayName LIKE 'Zpìtné volání%')
		and projectid = @Project
		and exists (select * from iCC.dbo.CallEvent as ce 
						where ce.OutboundCallId = OutboundCallId 
							and EventType = 'CallBack'
							and ReferenceData = 'Ivr'
			)