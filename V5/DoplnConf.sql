:setvar Version 16.1.24
:setvar FS_CUSTOM Frontstage
:setvar ICC Frontstage
:setvar ProServer ProServer
:setvar SREC SREC

ALTER PROCEDURE [dbo].[FSC_DelDuplIndexes]
AS
-- =============================================
-- Author:		Zbynìk Homolka
-- Create date: 4.1.2024
-- Description:	Maže duplicitní index Frontstage
-- =============================================
BEGIN
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'ContactComposition','UQ_PhoneBookId_ContactId','UQ_ContactComposition_PhoneBookId_ContactId'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'Skill','UQ_AgentId_ProjectId','UQ_Skill_AgentId_ProjectId'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'GdprSensitivity','UQ_Sensitivity','UQ_GdprSensitivity_Sensitivity'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'PhaseTransition','UQ_FromPhaseId_ToPhaseId','UQ_PhaseTransition_FromPhaseId_ToPhaseId'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'Portal','UQ_HashPage','UQ_Portal_HashPage'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'BusyConditionRule','UQ_CommCh_AgentCh','UQ_BusyConditionRule_CommCh_AgentCh'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'CrewMember','UQ_CrewId_AgentId','UQ_CrewMember_CrewId_AgentId'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'GdprEvidence','AX_GdprEvidence_GdprEvidenceId','PK_GdprEvidence'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'Perso','UQ_AgentId_Profile_RefName_RefId_CtxId','UQ_Perso_AgentId_Profile_RefName_RefId_CtxId'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'PhoneComposition','UQ_PhoneBookId_PhoneNumberId','UQ_PhoneComposition_PhoneBookId_PhoneNumberId'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'Proficiency','UQ_AgentId_LanguageId','UQ_Proficiency_AgentId_LanguageId'
	EXEC $(ICC).[dbo].[FSC_DelDuplIndex] 'Queue','UQ_CommId','UQ_Queue_CommId'

END 


GO
