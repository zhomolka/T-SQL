select
Schedule.ScheduleID as SQLAgent_Job_Name, [Catalog].Name as reportname,
Subscriptions.Description as sub_desc, 
Subscriptions.DeliveryExtension as sub_delExt, 
[catalog].path as reportpath
from reportserver.dbo.reportschedule inner join reportserver.dbo.Schedule 
on ReportSchedule.ScheduleID = Schedule.ScheduleID 
inner join reportserver.dbo.Subscriptions 
on ReportSchedule.SubscriptionID = Subscriptions.SubscriptionID 
inner join reportserver.dbo.[Catalog] 
on ReportSchedule.ReportID = [Catalog].ItemID 
and Subscriptions.Report_OID = [Catalog].ItemID
-- Spuštìní Subscription:
exec msdb.dbo.sp_start_job @job_name='CF177627-1A4A-4C29-8788-0585E5666D7A'