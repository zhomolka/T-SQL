USE [iCC]
GO

SELECT [WorkplaceId]
      ,[DisplayName]
      ,[Number]
      ,[Computer]
      ,[State]
      ,[Offer]
      ,[CtiModel]
      ,[OfferModel]
      ,[LoggedClientModel]
      ,[UsedClientModels]
      ,[MaxRinging]
      ,[MaxOffering]
      ,[Blocking]
      ,[AutoLogoff]
      ,[Deleted]
      ,[ExternalNumber]
      ,[TransferBlockUtc]
  FROM [dbo].[Workplace] WHERE Number IN (9647,9633)
GO


