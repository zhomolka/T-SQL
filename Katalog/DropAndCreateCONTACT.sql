-- Smaze cizi klice v zavislych tabulkach

ALTER TABLE PagingRule DROP CONSTRAINT  FK_PagingRule_MemberContact;
ALTER TABLE PagingRule DROP CONSTRAINT  FK_PagingRule_GroupContact;
ALTER TABLE GdprAuthorisation DROP CONSTRAINT  FK_GdprAuthorisation_Contact;
ALTER TABLE Message DROP CONSTRAINT  FK_Message_Contact;
ALTER TABLE BulkMessage DROP CONSTRAINT  FK_BulkMessage_Contact;
ALTER TABLE Chat DROP CONSTRAINT  FK_Chat_Contact;
ALTER TABLE Issue DROP CONSTRAINT  FK_Issue_Contact;
ALTER TABLE InboundCall DROP CONSTRAINT  FK_InboundCall_Contact;
ALTER TABLE ContactComposition DROP CONSTRAINT  FK_ContactComposition_Contact;
ALTER TABLE ScenarioResult DROP CONSTRAINT  FK_ScenarioResult_Contact;
ALTER TABLE OutboundCall DROP CONSTRAINT  FK_OutboundCall_Contact;
ALTER TABLE PhoneNumber DROP CONSTRAINT  FK_PhoneNumber_Contact;
ALTER TABLE PagingMember DROP CONSTRAINT  FK_PagingMember_Contact;
ALTER TABLE ContactEvent DROP CONSTRAINT  FK_ContactEvent_Contact;
ALTER TABLE Contact DROP CONSTRAINT  FK_Contact_Contact;



-- Drop and Create table Contact ... mely by se obnovit i foreign keys ktery se smazaly vyse

USE [iCC]
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ContactModelId'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Synchronized'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'GdprObliviated'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ObliviateAfter'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ExpireAfter'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ArchiveAfter'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'GdprExpired'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'GdprArchived'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'BlockMarketingUsage'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Deleted'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ExternalKey'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Correlation'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Changed'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'BodyHtml'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'FormDataId'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ParentContactId'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Department'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'CompanyName'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'LastName'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'FirstName'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'TimeUtc'
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ContactId'
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [FK_Contact_ScenarioResult]
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [FK_Contact_ContactModel]
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [FK_Contact_Contact]
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [DF_Contact_Synchronized]
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [DF_Contact_GdprObliviated]
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [DF_Contact_GdprExpired]
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [DF_Contact_GdprArchived]
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [DF_Contact_BlockMarketingUsage]
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [DF_Contact_Deleted]
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [DF_Contact_TimeUtc]
GO

ALTER TABLE [dbo].[Contact] DROP CONSTRAINT [DF_Contact_ContactId]
GO

/****** Object:  Table [dbo].[Contact]    Script Date: 5/25/2020 5:12:46 AM ******/
DROP TABLE [dbo].[Contact]
GO

/****** Object:  Table [dbo].[Contact]    Script Date: 5/25/2020 5:12:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Contact](
	[ContactId] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[TimeUtc] [datetime] NOT NULL,
	[FirstName] [nvarchar](60) NULL,
	[LastName] [nvarchar](80) NULL,
	[CompanyName] [nvarchar](120) NULL,
	[Department] [nvarchar](60) NULL,
	[ParentContactId] [uniqueidentifier] NULL,
	[FormDataId] [uniqueidentifier] NULL,
	[BodyHtml] [nvarchar](max) NULL,
	[Description] [nvarchar](300) NULL,
	[Changed] [datetime] NULL,
	[Correlation] [uniqueidentifier] NULL,
	[ExternalKey] [nvarchar](48) NULL,
	[Deleted] [bit] NOT NULL,
	[BlockMarketingUsage] [bit] NOT NULL,
	[GdprArchived] [bit] NOT NULL,
	[GdprExpired] [bit] NOT NULL,
	[ArchiveAfter] [datetime] NULL,
	[ExpireAfter] [datetime] NULL,
	[ObliviateAfter] [datetime] NULL,
	[GdprObliviated] [bit] NOT NULL,
	[Synchronized] [bit] NOT NULL,
	[ContactModelId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Contact] PRIMARY KEY CLUSTERED 
(
	[ContactId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Contact] ADD  CONSTRAINT [DF_Contact_ContactId]  DEFAULT (newid()) FOR [ContactId]
GO

ALTER TABLE [dbo].[Contact] ADD  CONSTRAINT [DF_Contact_TimeUtc]  DEFAULT (getutcdate()) FOR [TimeUtc]
GO

ALTER TABLE [dbo].[Contact] ADD  CONSTRAINT [DF_Contact_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [dbo].[Contact] ADD  CONSTRAINT [DF_Contact_BlockMarketingUsage]  DEFAULT ((0)) FOR [BlockMarketingUsage]
GO

ALTER TABLE [dbo].[Contact] ADD  CONSTRAINT [DF_Contact_GdprArchived]  DEFAULT ((0)) FOR [GdprArchived]
GO

ALTER TABLE [dbo].[Contact] ADD  CONSTRAINT [DF_Contact_GdprExpired]  DEFAULT ((0)) FOR [GdprExpired]
GO

ALTER TABLE [dbo].[Contact] ADD  CONSTRAINT [DF_Contact_GdprObliviated]  DEFAULT ((0)) FOR [GdprObliviated]
GO

ALTER TABLE [dbo].[Contact] ADD  CONSTRAINT [DF_Contact_Synchronized]  DEFAULT ((0)) FOR [Synchronized]
GO

ALTER TABLE [dbo].[Contact]  WITH CHECK ADD  CONSTRAINT [FK_Contact_Contact] FOREIGN KEY([ParentContactId])
REFERENCES [dbo].[Contact] ([ContactId])
GO

ALTER TABLE [dbo].[Contact] CHECK CONSTRAINT [FK_Contact_Contact]
GO

ALTER TABLE [dbo].[Contact]  WITH CHECK ADD  CONSTRAINT [FK_Contact_ContactModel] FOREIGN KEY([ContactModelId])
REFERENCES [dbo].[ContactModel] ([ContactModelId])
GO

ALTER TABLE [dbo].[Contact] CHECK CONSTRAINT [FK_Contact_ContactModel]
GO

ALTER TABLE [dbo].[Contact]  WITH CHECK ADD  CONSTRAINT [FK_Contact_ScenarioResult] FOREIGN KEY([FormDataId])
REFERENCES [dbo].[ScenarioResult] ([ScenarioResultId])
GO

ALTER TABLE [dbo].[Contact] CHECK CONSTRAINT [FK_Contact_ScenarioResult]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primární klíč' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ContactId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Čas založení záznamu' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'TimeUtc'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Jméno (křestní), případně jména.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'FirstName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Příjmení.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'LastName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Název společnosti.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'CompanyName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'název oddělení.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Department'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nadřazený konakt, ke kterému údaje patří. NULL znamená kontakt bez hlavičky.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ParentContactId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Doplňující data ve formě scénářového výsledku. Jeden kontakt může mít jen jednu sadu dat.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'FormDataId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Text volné poznámky k položce.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'BodyHtml'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Popis, pole pro všeobecné použití.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Čas poslední změny (v údajích kontaktu, nikoli ve formlářových datech).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Changed'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifikátor pro integraci s externími systémy.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Correlation'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pole pro uložení externího klíče kontaktu, používané pro synchronizaci s externími datovými zdroji.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ExternalKey'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indikace smazané položky.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Deleted'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indikace, že se kontakt nesmí používat pro marketingové účely a má se blokovat jeho zahrnutí do hromadných kampaní (true - nepoužívat, false - možno používat).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'BlockMarketingUsage'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Položka je archivována.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'GdprArchived'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Položka je zapomenuta.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'GdprExpired'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Čas, po kterém má být provedena archivace.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ArchiveAfter'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Čas, po kterém má být provedena expirace.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ExpireAfter'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Čas, po kterém má být vystaven CHR WipeCtc.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ObliviateAfter'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Položka je smazána.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'GdprObliviated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Záznam byl synchronizován.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'Synchronized'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Určuje, jaká je struktura, názvy a nastavení GDPR pro daný typ kontaktního údaje.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact', @level2type=N'COLUMN',@level2name=N'ContactModelId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'A table of hierarchically grouped contact information about people, organizations, and organizational units.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contact'
GO

