-- Занятие 4
-- Главная задача: сделать RFM-анализ на основе данных по продажам за 2 года (из предыдущего дз).
​
-- Что делаем:
-- 1. Определяем критерии для каждой буквы R, F, M (т.е. к примеру, R – 3 для клиентов, которые покупали <= 30 дней от последней даты в базе, R – 2 для клиентов, которые покупали > 30 и менее 60 дней от последней даты в базе и т.д.)
-- 2. Для каждого пользователя получаем набор из 3 цифр (от 111 до 333, где 333 – самые классные пользователи)
-- 3. Вводим группировку, к примеру, 333 и 233 – это Vip, 1XX – это Lost, остальные Regular ( можете ввести боле глубокую сегментацию)
-- 4. Для каждой группы из п. 3 находим кол-во пользователей, кот. попали в них и % товарооборота, которое они сделали на эти 2 года.
-- 5. Проверяем, что общее кол-во пользователей бьется с суммой кол-во пользователей по группам из п. 3 (если у вас есть логические ошибки в создании групп, у вас не собьются цифры). То же самое делаем и по деньгам.
-- 6. Результаты присылаем.


/* вычисляем значения за 2 года*/
SELECT AVG(o.price), MAX(o.price), MAX(o.o_date), COUNT(o.id_o) FROM orders_2019 o;

/*деление на 3 группы*/
'''with query_user AS (SELECT t1.user_id,
CASE WHEN (t1.frequency='3' AND t1.recency='3' AND t1.monetary='3') OR  
         (t1.frequency='3' AND t1.recency='2' AND t1.monetary='3') THEN 'VIP'
      WHEN t1.recency='1' THEN 'Lost'
      ELSE 'Regular' END AS user_group
 FROM (SELECT user_id, 
CASE WHEN TIMESTAMPDIFF(DAY, MAX(o_date), date('2017-12-31')) <= 30 THEN '3'
      WHEN TIMESTAMPDIFF(DAY, MAX(o_date), date('2017-12-31')) <= 60 THEN '2'
      ELSE '1' END AS recency,
CASE WHEN COUNT(id_o)>=10 THEN '3'
      WHEN COUNT(id_o)>1 THEN '2'
      ELSE '1' END AS frequency,
CASE WHEN MAX(price) >= 5000 THEN '3'
      WHEN MAX(price) > 1000 THEN '2'
      ELSE '1' END AS monetary
FROM orders_2019 o
GROUP BY o.user_id) t1)'''

/*деление на 7 групп*/

with query_user AS (SELECT t1.user_id,
CASE WHEN t1.recency='3' AND t1.frequency='3' AND t1.monetary='3' THEN 'VIP'
      WHEN t1.recency='3' AND t1.frequency='2' AND t1.monetary IN ('1','2','3') THEN 'Developing'
      WHEN t1.recency='3' AND t1.frequency='1' AND t1.monetary IN ('1','2','3') THEN 'Beginner'
      WHEN t1.recency='2' AND t1.frequency='3' AND t1.monetary IN ('1','2','3') THEN 'Loyal sleeping'
      WHEN t1.recency='2' AND t1.frequency IN ('1','2') AND t1.monetary IN ('1','2','3') THEN 'Sleeping'
      WHEN t1.recency='1' AND t1.frequency IN ('2','3') AND t1.monetary IN ('1','2','3') THEN 'Loyal without activity'  
      ELSE 'Lost' END AS user_group
 FROM (SELECT user_id, 
CASE WHEN TIMESTAMPDIFF(DAY, MAX(o_date), date('2017-12-31')) <= 30 THEN '3'
      WHEN TIMESTAMPDIFF(DAY, MAX(o_date), date('2017-12-31')) <= 60 THEN '2'
      ELSE '1' END AS recency,
CASE WHEN COUNT(id_o)>=10 THEN '3'
      WHEN COUNT(id_o)>1 THEN '2'
      ELSE '1' END AS frequency,
CASE WHEN MAX(price) >= 5000 THEN '3'
      WHEN MAX(price) > 1000 THEN '2'
      ELSE '1' END AS monetary
FROM orders_2019 o
GROUP BY o.user_id) t1)

SELECT q.user_group, COUNT(DISTINCT o.user_id) AS num_user, SUM(o.price) AS group_to,
CONCAT(ROUND(SUM(o.price)*100/(SELECT sum(o.price) FROM orders_2019 o), 2), '%') AS percent_of_total_to
FROM orders_2019 o
LEFT JOIN query_user q ON o.user_id=q.user_id
GROUP BY q.user_group;

/*проверка данных*/

SELECT COUNT(DISTINCT o.user_id) , sum(o.price) FROM orders_2019 o;