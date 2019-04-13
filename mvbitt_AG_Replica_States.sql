/******************************************
mvbitt_AG - Marcus Vinícius Bittencourt

Description: Displays and store a view of replica states, time behind primary and queue e rate.

Output: the output is configurated to save result in a table into the control database

The first and new versions will be available at http://isqlserver.wordpress.com
where you can download new versions for free, read posts and get more info on the findings. 
To contribute code and see your name in the change log, submit your improvements &
ideas to mailto:mvbitt@gmail.com

Versions:

v0.1: Creation

v0.2:

GO
************************************************************************/


insert into mvbitt.dbo.hadr_database_replica_states
SELECT DB_NAME(database_id) database_name, Convert(VARCHAR(20),last_commit_time,22) last_commit_time
,CAST(CAST(((DATEDIFF(s,last_commit_time,GetDate()))/3600) as varchar) + ' hour(s), ' + CAST((DATEDIFF(s,last_commit_time,GetDate())%3600)/60 as varchar) + ' min, '+ CAST((DATEDIFF(s,last_commit_time,GetDate())%60) as varchar) + ' sec' as VARCHAR(30)) time_behind_primary
,log_send_queue_size, log_send_rate, redo_queue_size, redo_rate
,CONVERT(VARCHAR(20),DATEADD(mi,(redo_queue_size/redo_rate/60.0),GETDATE()),22) estimated_completion_time
,CAST((redo_queue_size/redo_rate/60.0) as decimal(10,2)) [estimated_recovery_time_minutes]
,(redo_queue_size/redo_rate) [estimated_recovery_time_seconds]
,synchronization_state_desc,synchronization_health_desc, getdate() as collection_time
FROM sys.dm_hadr_database_replica_states
WHERE last_redone_time is not null