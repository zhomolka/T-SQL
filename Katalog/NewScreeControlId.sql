USE [iCC]
GO
DECLARE @ScreenControlIdSource AS UniqueIdentifier='CDBF2007-A7F5-45A7-9EF4-661F3E2998DF'
DECLARE @ScreenControlIdNew AS UniqueIdentifier= 'aa53f8bf-b7d4-4d29-8dad-ba850b04dac7'

INSERT INTO [dbo].[ScreenControlParameter]
SELECT TOP (1000) NewId() AS ScreenControlParameterId
      ,@ScreenControlIdNew AS ScreenControlId
      ,[DisplayName]
      ,[Rank]
      ,[ResultNumber]
      ,[ResultText]
      ,[DefaultItem]
      ,[Glyph]
  FROM [iCC].[dbo].[ScreenControlParameter] WHERE ScreenControlId= @ScreenControlIdSource

