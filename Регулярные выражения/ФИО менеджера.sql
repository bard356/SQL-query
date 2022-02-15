--Запрос: 
 
select distinct
          b.m_id,
          trunc(b.date_d,'mm') as date_d,
          b.responsible,
          b.service_group
          from
            (
            select 
            a.*, 
            row_number() over (partition by a.m_id, trunc(a.date_d,'mm') order by a.date_d desc) as rn
            from
                (
                select 
                nvl(mn.m_id,ca.m_id) as m_id,
                nvl(ca.date_comm,ca.date_change) as date_d,
                ca.responsible,
                sm.service_group
                from crm_att ca
                left join m_id_table mn on ca.m_id = mn.id
                left join manager sm on ca.responsible=concat(concat(regexp_replace(sm.fio,'(.*) (.*) (.*)','\2'), ' '), regexp_replace(sm.fio,'(.*) (.*) (.*)','\1') )
                ) a
            ) b
          where b.rn = 1