DECLARE @Now AS datetime=GETDATE()
DECLARE @InboundCallId AS UniqueIdentifier= '33efa51c-aac9-ee11-b817-005056a0a12b'
DECLARE @OutboundCallId AS UniqueIdentifier --= '00000000-0000-0000-0000-000000000000'
DECLARE @MessageId AS UniqueIdentifier --= '00000000-0000-0000-0000-000000000000'
DECLARE @ChatId AS UniqueIdentifier --= '00000000-0000-0000-0000-000000000000'
DECLARE @IssueId AS UniqueIdentifier --= '00000000-0000-0000-0000-000000000000'
DECLARE @ContactId AS UniqueIdentifier=FS_Custom.dbo.Vrat_Contact()

SELECT ge.GdprEvidenceId,gl.displayname as typKomunikace,c.FirstName as CisloSmlouvy,c.LastName as TypSmlouvy, companyname as Faze, Department as Castka
,(case when companyName in ('Aktivní','Pozastavená smlouva','Schválená smlouva') then 1 else 2 end) as PoradiFaze
,ge.ContactId
FROM GdprEvidence AS ge 
JOIN GdprLegalisation AS gl ON ge.GdprLegalisationId=gl.GdprLegalisationId
left join Contact as C on C.ContactId=ge.contentContactId 

--JOIN GdprCategory AS gs ON gl.GdprCategoryId=gs.GdprCategoryId
WHERE (ge.ExpireAfter is null or @Now <= ge.ExpireAfter)
and ge.GdprLegalisationId<>'DB1C9D14-D8CA-4470-84FC-944565EF9A84' 

and ge.ContactId=@ContactId -- 'F8FADE0E-24E8-42AA-B5BA-BF95019ADC02'--
--CASE
--		WHEN @InboundCallId IS NOT NULL then (select TOP 1 ic.ContactId from InboundCall ic where ic.InboundCallId=@InboundCallId)
		--WHEN @OutboundCallId IS NOT NULL then (select oc.ContactId from OutboundCall oc where oc.OutboundCallId=@OutboundCallId)
		--WHEN @MessageId IS NOT NULL then (select msg.ContactId from Message msg where msg.MessageId=@MessageId)
		--WHEN @ChatId IS NOT NULL then (select cht.ContactId from Chat cht where cht.ChatId=@ChatId)
		--WHEN @IssueId IS NOT NULL then (select i.ContactId from Issue i where i.IssueId=@IssueId)
		--WHEN @ScenarioResultId IS NOT NULL then dbo.GetContactIdentityFromScenarioResult(@ScenarioResultId)
		/**Pokud se kontakt, ktery ma KontaktModel s "GdprIdentity=1" najde, tak se v ramci hierarchie kontaktu pouzije prvni zaznam(HierarchyLevel=1) hned za vstupnim kontaktem("@ContactId"), v ostatnich pripadech vraci null hodnotu*/
		--WHEN @ContactId IS NOT NULL then (select c.ContactId from dbo.FindContactsHierarchyByIdentityEntity(@ContactId) c where c.HierarchyLevel=1)
		--else NULL
		--end
		