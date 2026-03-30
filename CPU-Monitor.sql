

SELECT
    cpu_total =
        CASE WHEN cpu_sql > cpu_total AND cpu_sql <= 99.
            THEN cpu_sql
            ELSE cpu_total
        END,
    cpu_sql
FROM (
    SELECT cpu_total = 100 - x.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle/text())[1]', 'TINYINT')
    FROM (
        SELECT TOP(1) [timestamp], x = CONVERT(XML, record)
        FROM sys.dm_os_ring_buffers
        WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
            AND record LIKE '%<SystemHealth>%'
    ) t
) x
CROSS JOIN (
    SELECT
        cpu_sql = (
                MAX(CASE WHEN counter_name = 'CPU usage %' THEN t.cntr_value * 1. END) /
                MAX(CASE WHEN counter_name = 'CPU usage % base' THEN t.cntr_value END)
            ) * 100
    FROM (
        SELECT TOP(2) cntr_value, counter_name
        FROM sys.dm_os_performance_counters
        WHERE counter_name IN ('CPU usage %', 'CPU usage % base')
            AND instance_name = 'default'
    ) t
) t
