USE iCC
DECLARE @p0 VarChar(8000)= 'O'
DECLARE @p1 NVarChar (4000)= 'Active'
DECLARE @p2 NVarChar (4000)=  'Scheduled'
DECLARE @p3 UniqueIdentifier = '409b14f2-a09c-41d7-a59d-0a25f6980ebd'
DECLARE @p4 NVarChar (4000) = 'Scheduled'
DECLARE @p5 DateTime = CONVERT(Datetime,'2019.05.30 17:39:07')

SELECT TOP (20) [t3].[MessageId], [t3].[RelatedMessageId], [t3].[value] AS [HasEml]
FROM (

    SELECT t0.MessageId, t0.RelatedMessageId, 
        (CASE 
            WHEN [t0].[Eml] IS NOT NULL THEN 1
            ELSE 0
         END) AS [value], [t0].[Direction], [t0].[MessageResult], [t0].[MessagePhase], [t0].[GatewayId], [t0].[CampaignId], [t1].[Activity], [t0].[CampaignImportId], [t2].[Active], [t0].[Eml], [t0].[ToField], [t0].[ToCcField], [t0].[ScheduledTime], [t0].[EndTime], [t0].[TimeUtc]
    FROM [dbo].[Message] AS [t0]
    LEFT OUTER JOIN [dbo].[Campaign] AS [t1] ON [t1].[CampaignId] = [t0].[CampaignId]
    LEFT OUTER JOIN [dbo].[CampaignImport] AS [t2] ON [t2].[CampaignImportId] = [t0].[CampaignImportId]
    ) AS [t3]
WHERE ([t3].[Direction] = @p0) AND ([t3].[MessageResult] = @p1) AND ([t3].[MessagePhase] = @p2) AND ([t3].[GatewayId] = @p3) AND (([t3].[CampaignId] IS NULL) OR ([t3].[Activity] IS NULL) OR ([t3].[Activity] = @p4)) AND (([t3].[CampaignImportId] IS NULL) OR ([t3].[Active] = 1)) AND (([t3].[Eml] IS NOT NULL) OR ([t3].[ToField] IS NOT NULL) OR ([t3].[ToCcField] IS NOT NULL)) AND (([t3].[ScheduledTime] IS NULL) OR ([t3].[ScheduledTime] <= @p5))
ORDER BY [t3].[EndTime], [t3].[TimeUtc]
