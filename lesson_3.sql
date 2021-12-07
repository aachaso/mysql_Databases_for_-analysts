-- В качестве ДЗ делам прогноз ТО на 05.2017. В качестве метода прогноза - считаем сколько денег тратят группы клиентов в день:

-- 1. Группа часто покупающих (3 и более покупок) и которые последний раз покупали не так давно. 
-- Считаем сколько денег оформленного заказа приходится на 1 день. Умножаем на 30.

'''SELECT SUM(o.price), COUNT(o.o_date), SUM(o.price)/COUNT(o.o_date) AS sum_o_of_day 
FROM (SELECT * FROM orders_2019 o1 WHERE MONTH(o1.o_date) IN (4) AND year(o1.o_date) = 2017 
      GROUP BY o1.user_id HAVING COUNT(o1.id_o)>2
      ORDER BY o1.user_id) o;'''

SELECT COUNT(DISTINCT o.user_id), COUNT(DISTINCT o.id_o), SUM(o.price)/COUNT(o.o_date) * 30 AS avg_m_s FROM orders_2019 o WHERE o.o_date < date('2017-05-01') AND 
o.user_id IN (SELECT o.user_id FROM orders_2019 o WHERE o.o_date < DATE('2017-05-01')
GROUP BY o.user_id
HAVING COUNT(o.id_o)>2 AND TIMESTAMPDIFF(DAY, MAX(o.o_date), date('2017-05-01')) < 90);

-- 2. Группа часто покупающих, но которые не покупали уже значительное время. 
-- Так же можем сделать вывод, из такой группы за след месяц сколько купят и на какую сумму. (постараться продумать логику)

SELECT COUNT(DISTINCT o.user_id), COUNT(DISTINCT o.id_o), SUM(o.price)/COUNT(DISTINCT o.user_id) AS avg_m_s FROM orders_2019 o WHERE o.o_date >= date('2017-05-01') AND o.o_date < DATE('2017-06-01')
AND o.user_id IN (SELECT o.user_id FROM orders_2019 o WHERE o.o_date < DATE('2017-05-01')
GROUP BY o.user_id
HAVING COUNT(o.id_o)>2 AND TIMESTAMPDIFF(DAY, MAX(o.o_date), date('2017-05-01')) >= 90);

-- 3. Отдельно разобрать пользователей с 1 и 2 покупками за все время, прогнозируем их.
SELECT COUNT(DISTINCT o.user_id), COUNT(DISTINCT o.id_o), SUM(o.price)/COUNT(DISTINCT o.user_id) AS avg_m_s 
FROM orders_2019 o WHERE o.o_date >= date('2017-05-01') AND o.o_date < DATE('2017-06-01')
AND o.user_id IN (SELECT o.user_id FROM orders_2019 o WHERE o.o_date < DATE('2017-05-01')
GROUP BY o.user_id
HAVING COUNT(o.id_o)<=2);

-- 4. В итоге у вас будет прогноз ТО и вы сможете его сравнить с фактом и оценить грубо разлет по данным
SELECT t1.*
FROM (SELECT SUM(o.price), COUNT(DISTINCT o.id_o) FROM orders_2019 o WHERE o.o_date = DATE('2017-05-01')) t1;