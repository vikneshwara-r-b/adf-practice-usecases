/*
SQL scripts to accompany the following exercise

Create a master table which tracks table data load status
Create a pipeline boolean variable called status
Use Until Activity and Lookup Activity to identify if data in a table is processed or not using master table
If data processing is completed set status variable to false and Invoke Exercise 1 
*/
create table master_load_status_tracker(tableName varchar(50), refreshStatus varchar(10));

insert into master_load_status_tracker(tableName, refreshStatus) values('salesitems', 'N');

select * from master_load_status_tracker;

select refreshStatus as status from master_load_status_tracker
where tablename = 'salesitems';

update master_load_status_tracker set refreshStatus='Y'
where tablename = 'salesitems' 
and refreshStatus='N';

update master_load_status_tracker set refreshStatus='N'
where tablename = 'salesitems' 
and refreshStatus='Y';