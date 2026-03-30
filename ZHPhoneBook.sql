select C.ContactId, C.Model, C.Changed, C.FirstName, C.LastName, C.CompanyName, C.Department, 
(CASE WHEN C.FormDataId IS NULL THEN C.BodyHtml ELSE dbo.GetScenarioResultFullText(C.FormDataId) END) AS DataText,
C.ParentContactId, dbo.ConcatName(PC.FirstName,PC.LastName,PC.CompanyName) ParentName,
dbo.GetContactNumber(C.ContactId,1) AS Number1,
dbo.GetContactNumber(C.ContactId,2) AS Number2,
dbo.GetContactNumber(C.ContactId,3) AS Number3
,PB.DisplayName AS PhoneBookName
from Contact AS C with(nolock)
left join Contact AS PC with(nolock) on PC.ContactId=C.ParentContactId AND PC.Deleted=0
left join ContactComposition as cc with(nolock) on cc.ContactId = c.ContactId 
left join PhoneBook as PB with(nolock) on cc.PhoneBookId = PB.PhoneBookId

where C.Deleted=0 
and C.LastName='Homolka'
--and cc.PhoneBookId = '1F663A6E-0896-4FD5-80FF-43DE3057CCF4'