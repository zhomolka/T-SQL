USE [FS_custom]
GO

/****** Object:  Table [dbo].[Rename]    Script Date: 27. 6. 2023 10:17:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Rename](
	[RenameId] [uniqueidentifier] NOT NULL,
	[OrigName] [nchar](120) NOT NULL,
	[NewName] [nchar](120) NOT NULL,
	[Result] [nchar](2) NULL
) ON [PRIMARY]

GO

