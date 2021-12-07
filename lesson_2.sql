SELECT EXTRACT(year FROM o.o_date), EXTRACT(month FROM o.o_date), SUM(price) FROM orders_2019 o
GROUP BY EXTRACT(year FROM o.o_date), EXTRACT(month FROM o.o_date);

WITH table_user AS (SELECT o.user_id, o.o_date,
LEAD (o.o_date) OVER (PARTITION BY o.user_id ORDER BY o.o_date) AS next_date,
ROW_NUMBER() OVER (PARTITION BY o.user_id ORDER BY o.o_date) AS num_order
 FROM (SELECT DISTINCT  o.user_id, o.o_date FROM orders_2019 o WHERE o.price IS NOT NULL) o
 WHERE o.o_date IS NOT NULL)


SELECT t1.*, t1.next_date-t1.o_date AS diff_day FROM table_user t1
INNER JOIN (SELECT user_id, COUNT(id_o) FROM orders_2019
WHERE user_id IS NOT NULL AND id_o IS NOT NULL AND price IS NOT NULL 
GROUP BY user_id
HAVING COUNT(id_o)>1) t2 ON t2.user_id = t1.user_id
WHERE t1.num_order=1 AND t1.next_date IS NOT null
ORDER BY t1.user_id;

