USE [FS_custom]
GO

/****** Object:  Table [dbo].[Tiles]    Script Date: 6/11/2019 2:13:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Tiles](
	[NameLine] [varchar](10) NOT NULL,
	[Rank] [int] NOT NULL,
	[Text] [varchar](50) NOT NULL,
	[Number] [nvarchar](10) NULL,
	[BackColor] [varchar](7) NOT NULL,
	[FrontColor] [varchar](7) NOT NULL,
	[Glyph] [varchar](40) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
