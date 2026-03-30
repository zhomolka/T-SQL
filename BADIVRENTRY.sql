select COUNT(*) from iCC..callevent where resultdata like 'Divert not arrived to IVR entry 3085 targeted to 3085 liveness=F' 
and CAST(timeutc as date)='2023-06-29'

select COUNT(*) from iCC..callevent where resultdata like 'Divert not arrived to IVR entry 3%' 
and timeutc >'2023-06-29 08:11:00' --sem deaktivoval IvrEntry=3049, 3066, 3067



select deleted, * from iCC..IvrEntry where Number in (3049,3067,3066)
select deleted,* from ProServer..Extension where Number in (3049,3067,3066)


/*
update iCC..IvrEntry
set Deleted=0
where IvrEntryId in ('2415AD27-D75F-4F50-9DE2-0C42C946318D','66E6F2AC-298B-4FCB-A661-0EEF5A381D35','6EA58A65-BFB7-4B53-B92C-29E23E8488E2')

update ProServer..Extension
set Deleted=0
where ExtensionId in ('7E62A51D-539F-4B56-8E97-2F7E88A10FB6','B6C24BCA-ED64-4386-B0A4-6F843C27B61E','17CD4F3A-BE13-4174-963F-886313075F88')
*/