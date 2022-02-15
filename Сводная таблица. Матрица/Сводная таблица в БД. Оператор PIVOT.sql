-- Запрос:

select * from
		(select 
		 t.business,
		 t.service_group,
		 month,
		 t.litry_4 
		 from (select 
		 	    business, 
		 	    service_group, 
		 	    to_char(month,'MM') as month, 
		 	    litry_4 
		       from ag_30_hist) 
		 t) pvt

		       pivot
				 (
				 sum(pvt.litry_4) as "Сумма"
				 for month in ('01' AS ЯНВ,
				'02' AS ФЕВ,
				'03' AS МРТ,
				'04' AS АПР,
				'05' AS МАЙ,
				'06' AS ИЮН,
				'07' AS ИЮЛ,
				'08' AS АВГ,
				'09' AS СЕН,
				'10' AS ОКТ,
				'11' AS НОЯ,
				'12' AS ДЕК)
				 )