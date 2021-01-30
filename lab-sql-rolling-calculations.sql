#Task 1
drop view if exists customer_activity; 
create or replace view customer_activity as
select customer_id, convert(rental_date, date) as Activity_date,
date_format(convert(rental_date,date), '%M') as Activity_Month,
date_format(convert(rental_date,date), '%m') as Activity_Month_number,
date_format(convert(rental_date,date), '%Y') as Activity_year
from rental;
create view monthly_active_users as
select Activity_year, Activity_Month, Activity_Month_number, count(customer_id) as Active_users from customer_activity
group by Activity_year, Activity_Month
order by Activity_year asc, Activity_Month_number asc;
select * from monthly_active_users;
#Task 2
with cte_view as (select 
   Activity_year, 
   Activity_month,
   Active_users, 
   lag(Active_users,1) over (order by Activity_year, Activity_Month_number) as Last_month
from monthly_active_users)
select Activity_year, Activity_month, Active_users, Last_month, (Active_users - Last_month) as Difference from cte_view;
#Task 3
with cte_view as (select 
   Activity_year, 
   Activity_month,
   Active_users, 
   lag(Active_users,1) over (order by Activity_year, Activity_Month_number) as Last_month
from monthly_active_users)
select Activity_year, Activity_month, Active_users, Last_month, (((Active_users-last_month)/last_month)*100) as percentage_change from cte_view;
#Task 4
drop view distinct_customers;
create view distinct_customers as
select distinct(customer_id) as Active_id, Activity_year, Activity_month, Activity_month_number from customer_activity;

drop view if exists retained_customers;
create view retained_customers as 
select 
   d1.Activity_year,
   d1.Activity_month,
   count(distinct d1.Active_id) as Retained_customers
   from distinct_customers as d1
left join distinct_customers as d2
on d1.Active_id = d2.Active_id 
and d2.Activity_month_number = d1.Activity_month_number + 1 
group by d1.Activity_year, d1.Activity_month_number
order by d1.Activity_year, d1.Activity_month_number;

select * from retained_customers;

