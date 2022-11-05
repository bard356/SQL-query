-- создаем представление в виде view
 create or replace view retention_month(first_month, cohort_month, cohort_users, uid, revenue) as
WITH data AS (
    SELECT data.uid,
           date_trunc('month', data.pay_time)::date                           AS cohort_month, -- приводим к месяцу в формате строки дату оплат
           date_trunc('month', f.first_time)::date                            AS first_month, -- приводим к месяцу в формате строки дату первой оплаты
           round(((date(data.pay_time) - date(f.first_time)) / 28)::double precision) AS cohort_lifetime,  -- срок жизни пользователя в месяцах
           data.pay_sum
    FROM (SELECT f_1.uid, -- идентификатор пользователя
                 f_1.pay_time, -- время оплаты
                 f_1.pay_sum -- выручка в рублях
          FROM orders f_1
                   JOIN tariffs t ON f_1.feature_tariff_id = t.id
          WHERE t.description::text = ANY (ARRAY ['в мес.'::character varying::text])) data -- выбираем тариф (название тарифа)
             JOIN (SELECT f_1.uid,
                          min(f_1.pay_time) AS first_time -- находим первую дату оплаты - месяц когорты пользователей
                   FROM orders f_1
                            JOIN tariffs t ON f_1.feature_tariff_id = t.id
                   WHERE t.description::text = ANY (ARRAY ['в мес.'::character varying::text]) -- выбираем тариф (название тарифа)
                   GROUP BY f_1.uid) f ON data.uid = f.uid
), -- считаем  пользователей по когортам
     cohort_orders AS (
         SELECT data.first_month,
                count(DISTINCT data.uid) AS cohort_users
         FROM data
         GROUP BY data.first_month
     ), -- считаем  пользователей по когортам и по месяцам жизни
     cohorts AS (
         SELECT data.first_month,
                data.cohort_month,
                count(DISTINCT data.uid) AS uid,
                sum(data.pay_sum)        AS revenue
         FROM data
         GROUP BY data.first_month, data.cohort_month
     )
-- итоговая витрина с данными для визуализации когортного анализа     
SELECT cohorts.first_month,
       cohorts.cohort_month,
       cohort_orders.cohort_users,
       cohorts.uid,
       cohorts.revenue
FROM cohorts
         JOIN cohort_orders ON cohorts.first_month = cohort_orders.first_month;
         
-- при необъходимости, выдаем права 
alter table retention_month
    owner to "user_name";