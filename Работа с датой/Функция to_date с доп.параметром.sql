-- используем параметр NLS_DATE_LANGUAGE функции to_date для перевода месяца и преобразования в число

select 
to_date('01.Jan.2021','DD.MON.YYYY','NLS_DATE_LANGUAGE=AMERICAN') as date_new
from table

-- на выходе получаем date_new = '01.01.2021'