USE [FS_Custom]
GO

/****** Object:  Table [dbo].[HPTBI_Plants2]    Script Date: 5/10/2018 08:05:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[HPTBI_Branches2](
    [BranchesId] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Rok] [int] NULL,
	[Mesic] [int] NULL,
	[Datum] [smalldatetime] NULL,
	[AgentName] [nvarchar](50) NULL,
	[Pobocka] [nvarchar](50) NULL,
	[ProjectName] [nvarchar](50) NOT NULL,
	--[PocetPrichodu] [int] NULL,
	[PocetPrijatych] [int] NULL,
	[PocetOdchozich] [int] NULL,
	--[SL] [int] NULL,
	--[SLdo20s] [int] NULL,
	--[Pocetdo20s] [int] NULL,
	[OdchoziZpravy] [int] NULL,
	--[PripadyUzavrene] [int] NULL,
	--[PripadyUzavrenyJinym] [int] NULL,
	[PripadyNove] [int] NULL,
	--[PocetChatu] [int] NULL
CONSTRAINT [PK_Branches] PRIMARY KEY CLUSTERED 
(
	[BranchesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[HPTBI_branches2] ADD  CONSTRAINT [DF_branches_BranchesId]  DEFAULT (newid()) FOR [BranchesId]
GO


