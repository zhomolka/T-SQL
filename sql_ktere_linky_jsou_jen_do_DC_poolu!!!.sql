select number from iCC..Workplace where Pool=1 and Deleted=0 and Number between 801 and 7845
order by Number 

/*
update iCC..Workplace
set Pool=NULL
where WorkplaceId in (select workplaceid from iCC..Workplace where Pool=1 and Deleted=0 and Number between 801 and 845) -- mobilni pobocky
*/

select * from iCC..Seating where WorkplaceId in (select workplaceid from iCC..Workplace where Pool=1 and Deleted=0 and Number between 801 and 845)

801-845 - 10.22.5239.111 mobilni pobocky
846-875 - 51.89.96.176 voice bot pobocky
780-799 - 51.89.96.176 voice bot pobocky