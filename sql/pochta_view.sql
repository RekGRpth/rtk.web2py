--with s as (
--with s as (
--drop view pochta_view
create or replace view pochta_view as
select      --debt_date_start as date,
            --replace(round(saldo, 2)::text, '.', ',') as "СУММА",
            round(saldo, 2) as saldo,
            ts.user_id as phone,
            client_id as account,
            udecodeentities_numeric(regexp_replace(regexp_replace((bc.name), E'[ \t\r\n]+', ' ', 'g'), E' +$', '', 'g')) as fio,
            place_text(place) as address
from        base_clients as bc
inner join  debt_clients_by_saldo_cache as sc using (oper_id, client_id)
inner join  telephone_services as ts using (oper_id, client_id)
left join   loki_basic_service as lbs on lbs.id = ts.basicservice_ptr_id
where       bc.oper_id = 'RC'
and         coalesce(ts.date_expire, 'infinity') >= now()
and         client_type = 'person'
and         coalesce(none_client, 0) = 0
and         coalesce(ignore_debt, 0) = 0
--and         debt_date_start <= '01.08.2021'
and         saldo < 0.0
--limit       10
/*


) select    basicservice_ptr_id,
            user_id,
            client_id as "Лицевой",
            udecodeentities_numeric(regexp_replace(regexp_replace((bc.name), E'[ \t\r\n]+', ' ', 'g'), E' +$', '', 'g')) as "Наименование",
            --replace(round(get_saldo(bc, '2019-12-01'), 2)::text, '.', ',') as "Начало",
            round(get_saldo(bc, _dt), 2) as "Начало",
            round(get_saldo(bc), 2) as "Текущее"
from        s
inner join  base_clients as bc using (oper_id, client_id)
) select    "Начало" as "СУММА",
            s.user_id as "номер телефона",
            "Лицевой" as "Лицевой счет",
            "Наименование" as "ФИО",
            place_text(place) as "Адрес"
            --replace("Текущее"::text, '.', ',') as "Текущее"
from        s
left join   loki_basic_service as lbs on lbs.id = s.basicservice_ptr_id
where       "Текущее" < 0.0
limit       10
*/