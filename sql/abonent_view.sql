--drop view abonent_view
create or replace view abonent_view as
with s as (
select      distinct
            --date_create::date,
            --date_expire::date,
            --bill_date,
            --contract_date,
            --row_number() OVER () as id,
            coalesce((select case when contract_number like '4T#%' then contract_number else concat('4T#', contract_number) end from contract_contracts as cc where cc.oper_id = bc.oper_id and cc.client_id = bc.client_id and contract_type ~* 'sov_contract' order by contract_date desc limit 1), concat('4T#', bc.client_id)) as contract_number,
            udecodeentities_numeric(regexp_replace(regexp_replace((bc.name), E'[ \t\r\n]+', ' ', 'g'), E' +$', '', 'g')) as fio,
            address_jur,
            trim((string_to_array(inn, '/'))[1]) as inn,
            trim((string_to_array(inn, '/'))[2]) as kpp,
            2 as diplomat,
            case when client_type = 'person' then 1 else 2 end as status,
            1 as resident,
            643 as "national",
            (select to_char(contract_date, 'DD.MM.YYYY 00:00') from contract_contracts as cc where cc.oper_id = bc.oper_id and cc.client_id = bc.client_id and contract_type ~* 'sov_contract' order by contract_date desc limit 1) as contract_date,
            null::text as contract_expire,
            case when client_type = 'person' then 8 else 1 end as contract_type,
            '71 401' as contract_place,
            1 as agreement,
            1 as doc_type,
            doc_seq,
            doc_num,
            to_char(doc_date, 'DD.MM.YYYY 00:00') as doc_date,
            doc_agent
from        base_clients as bc
inner join  telephone_services as s using (oper_id, client_id)
left join   abonent_person as a on a.abonent_ptr_id = bc.abonent
left join   bill_bills as bb on bb.oper_id = bc.oper_id and bb.client_id = bc.client_id and bill_type ~* 'invoice_SOV' and bill_date between date_trunc('month', now()) - interval '1 month' and date_trunc('month', now()) - interval '1 sec'
left join   contract_contracts as cc on cc.oper_id = bc.oper_id and cc.client_id = bc.client_id and contract_type ~* 'sov_contract'
where       bc.oper_id = 'RC'
and         date_create < date_trunc('month', now()) - interval '1 sec'
and         coalesce(date_expire, 'infinity') > date_trunc('month', now()) - interval '1 month'
and         (date_create >= date_trunc('month', now()) - interval '1 month' or contract_date between date_trunc('month', now()) - interval '1 month' and date_trunc('month', now()) - interval '1 sec')
and         coalesce(none_client, 0) = 0
and         client_type != 'card'
and         (bb.bill_id is not null or cc.contract_id is not null)
--limit       10
order by    1
) select row_number() OVER () as id, * from s;

/*-- Function: beeline.abonent(text, date, date)

-- DROP FUNCTION beeline.abonent(text, date, date);

CREATE OR REPLACE FUNCTION beeline.abonent(
    IN _code text,
    IN _from date,
    IN _till date)
  RETURNS TABLE("Порядковый номер позиции в файле" bigint, "Номер договора" text, "Наименование" text, "Юридический адрес" text, "ИНН" text, "КПП" text, "Дипломат" integer, "Юр. Статус" integer, "Резидент" integer, "Национальная принадлежность" integer, "Дата заключения договора" text, "Дата расторжения договора" text, "Тип договора" integer, "Место заключения договора" text, "Факт согласия абонента на использ" integer, "Тип паспорта" integer, "Серия паспорта" text, "Номер паспорта" text, "Дата выдачи" text, "Кем выдан" text) AS
$BODY$
    with s as (
    select      distinct 
                --case when bc.oper_id ='RC' and contract_type != 'sov_contract_org' then concat(p.code, '#', bc.client_id) else case when contract_number is not null then case when contract_number like p.code||'#%' then contract_number else concat(p.code, '#', contract_number) end else concat(p.code, '#', bc.client_id) end end as "Номер договора",
                --case when contract_number is not null then case when contract_number like p.code||'#%' then contract_number else concat(p.code, '#', contract_number) end else concat(p.code, '#', bc.client_id) end as "Номер договора",
                --concat(p.code, '#', bc.client_id) as "Номер договора",
                coalesce((select case when contract_number like p.code||'#%' then contract_number else concat(p.code, '#', contract_number) end from contract_contracts as cc where cc.oper_id = bc.oper_id and cc.client_id = bc.client_id and contract_type ~* 'sov_contract' order by contract_date desc limit 1), concat(p.code, '#', bc.client_id)) as "Номер договора",
                udecodeentities_numeric(regexp_replace(regexp_replace((bc.name), E'[ \t\r\n]+', ' ', 'g'), E' +$', '', 'g')) as "Наименование",
                address_jur as "Юридический адрес",
                trim((string_to_array(inn, '/'))[1]) as "ИНН",
                trim((string_to_array(inn, '/'))[2]) as "КПП",
                2 as "Дипломат",
                case when client_type = 'person' then 1 else 2 end as "Юр. Статус",
                1 as "Резидент",
                643 as "Национальная принадлежность",
                (select to_char(contract_date, 'DD.MM.YYYY 00:00') from contract_contracts as cc where cc.oper_id = bc.oper_id and cc.client_id = bc.client_id and contract_type ~* 'sov_contract' order by contract_date desc limit 1) as "Дата заключения договора",
                null::text as "Дата расторжения договора",
                case when client_type = 'person' then 8 else 1 end as "Тип договора",
                '71 401' as "Место заключения договора",
                1 as "Факт согласия абонента на использование сведений о нем системах информационно-справочного обслуживания",
                1 as "Тип паспорта",
                doc_seq as "Серия паспорта",
                doc_num as "Номер паспорта",
                to_char(doc_date, 'DD.MM.YYYY 00:00') as "Дата выдачи",
                doc_agent as "Кем выдан"
    from        base_clients as bc
    inner join  provider as p using (oper_id)
    inner join  telephone_services as s using (oper_id, client_id)
    left join   abonent_person as a on a.abonent_ptr_id = bc.abonent
    left join   bill_bills as bb on bb.oper_id = bc.oper_id and bb.client_id = bc.client_id and bill_type ~* 'invoice_SOV' and bill_date between _from and _till
    left join   contract_contracts as cc on cc.oper_id = bc.oper_id and cc.client_id = bc.client_id and contract_type ~* 'sov_contract'
    where       code = _code
    and         date_create < _till
    and         coalesce(date_expire, 'infinity') > _from
    and         (date_create >= _from or contract_date between _from and _till)
    --and         (bb.bill_id is null or (bill_type ~* 'invoice_SOV' and bill_date between _from and _till))
    --and         (cc.contract_id is null or contract_type ~* 'sov_contract')
    and         coalesce(none_client, 0) = 0
    and         client_type != 'card'
    and         (bb.bill_id is not null or cc.contract_id is not null)
    --and         bc.client_id = '7338130'
    ) select row_number() OVER () as "Порядковый номер позиции в файле", * from s;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION beeline.abonent(text, date, date)
  OWNER TO beeline;
*/