/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) --[SubscriptionID]
       Name
      ,[OwnerID]
      ,[Report_OID]
      ,[Locale]
      ,[InactiveFlags]
      ,[ExtensionSettings]
      ,SUBS.[ModifiedByID]
      ,SUBS.[ModifiedDate]
      ,SUBS.[Description]
      ,[LastStatus]
      ,[EventType]
      ,[MatchData]
      ,[LastRunTime]
      ,[Parameters]
      ,[DataSettings]
      ,[DeliveryExtension]
      ,[Version]
      ,[ReportZone]
  FROM [ReportServer$MSSQL_B].[dbo].[Subscriptions] SUBS
  LEFT JOIN [ReportServer$MSSQL_B].[dbo].[Catalog] AS CAT ON SUBS.Report_OID=CAT.ItemId

  /* Disable cizí Subscription:
    UPDATE TOP (1) [ReportServer$MSSQL_B].[dbo].[Subscriptions]
     SET InactiveFlags=4
	 WHERE InactiveFlags=0 AND Report_OID='ED9B7019-1DBF-453E-A3B6-94AF6DDC81A6'

  */