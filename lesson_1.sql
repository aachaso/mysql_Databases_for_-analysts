-- 2. Проанализировать, какой период данных выгружен 
SELECT distinct month(o_date), year(o_date) FROM base_for_analytics.orders_20190822;

-- 3. Посчитать кол-во строк, кол-во заказов и кол-во уникальных пользователей, кот совершали заказы.
select count(*) FROM base_for_analytics.orders_20190822;

select count(id_o) FROM base_for_analytics.orders_20190822;

select count(distinct user_id) FROM base_for_analytics.orders_20190822;

-- 4. По годам и месяцам посчитать средний чек, среднее кол-во заказов на пользователя, сделать вывод , как изменялись это показатели Год от года.
select *,
lag (mean_price) over (order by o_year, o_month) as previous_mean_price,
lag (mean_order_user) over (order by o_year, o_month) as previous_mean_order_user
from (select distinct year(o_date) as o_year, month(o_date) as o_month, round(avg(price),2) as mean_price, 
count(distinct id_o)/count(distinct user_id) as mean_order_user
from base_for_analytics.orders_20190822
group by year(o_date), month(o_date)
order by  year(o_date), month(o_date)) t1;

-- 5. Найти кол-во пользователей, кот покупали в одном году и перестали покупать в следующем. 

with query_user as (select distinct user_id, year(o_date) as year_date FROM base_for_analytics.orders_20190822)

select count(*) from (select user_id from 
(select distinct t1.user_id,  
case when t1.year_date > t2.year_date then 1 else 0 end as mark 
from query_user as t1
left join query_user as t2
on t1.user_id = t2.user_id
-- and t1.year_date > t2.year_date
) t3
group by user_id
having sum(mark) = 0) t4;

-- 6. Найти ID самого активного по кол-ву покупок пользователя.
select distinct user_id, count(distinct id_o) from orders_20190822
group by user_id
order by count(distinct id_o) desc
limit 1;

-- 7. Найти коэффициенты сезонности по месяцам. 
with query_c_season as (select year(o_date) as year_date, month(o_date) as month_date, price FROM base_for_analytics.orders_20190822)


select t1.year_date, t1.month_date, sum(t1.price)/t2.avg_year
from query_c_season t1 
left join (select year_date, sum(price)/count(distinct month_date) as avg_year from query_c_season group by year_date) t2
on t1. year_date=t2.year_date
group by year_date, month_date
; 

select *
from orders_20190822
where year(o_date)='2015';