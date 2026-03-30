USE [FS_custom]
GO

/****** Object:  StoredProcedure [dbo].[RecreateIndex]    Script Date: 29. 5. 2018 10:18:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RecreateIndex]
AS
BEGIN

IF EXISTS (SELECT * FROM iCC.sys.fulltext_indexes where object_id = object_id(N'ICC.DBO.MESSAGE',N'U'))
  DROP FULLTEXT INDEX ON iCC.dbo.Message
--GO  


CREATE FULLTEXT INDEX ON iCC.[dbo].[Message](
[BodyHtml] LANGUAGE 'Neutral', 
[BodyText] LANGUAGE 'Neutral', 
[FromField] LANGUAGE 'Neutral',
[RemoteAddress] LANGUAGE 'Neutral',  
[SubjectField] LANGUAGE 'Neutral', 
[ToBccField] LANGUAGE 'Neutral', 
[ToCcField] LANGUAGE 'Neutral', 
[ToField] LANGUAGE 'Neutral')
KEY INDEX [PK_Message]ON ([MainFullText], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
--GO
END
GO

