update navigation
set url = replace(url,'Pages/Report.aspx?ItemPath=%2fDrmaxSK-custom%2f', 'report/DrmaxSK-custom/')
where  GroupName = 'REPORTS' --and navigationid = '2984ABCF-8B30-4B55-8127-A95163ABF621'

 

update navigation
set url = replace(url,'Pages/Report.aspx?ItemPath=%2fiCCDefaultReports%2f', 'report/iCCDefaultReports/')
where  GroupName = 'REPORTS'

 

update DataQueryColumn
set UrlFormat = 'http://srpacsql7083/{0}'
where DataQueryColumnId = 'D448ABCF-7A13-4FC4-89E5-A2C0FB711ED8'