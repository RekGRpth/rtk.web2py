--drop view bill_view_rtk
create or replace view bill_view_rtk as
select      row_number() OVER () as id,
            contract_number,
            contract_date,
            udecodeentities_numeric(regexp_replace(regexp_replace(bc.name, E'[ \t\r\n]+', ' ', 'g'), E' +$', '', 'g')) as client_name
from        base_clients as bc
inner join  contract_contracts as cc using (oper_id, client_id)
inner join  bill_bills as bb using (oper_id, client_id)
where       oper_id = 'RC'
and         contract_type ~* 'rt_contract'
and         (bill_type ~* 'invoice_RTK' or bill_type ~* 'invoice_USI') and bill_date between date_trunc('month', now()) - interval '1 month' and date_trunc('month', now()) - interval '1 sec'
--limit       10

/*
--drop view bill_view
create or replace view bill_view_rtk as
with s as (
select      distinct 
            --'FN816' as contract,
            coalesce((select case when contract_number like '4T#%' then contract_number else concat('4T#', contract_number) end from contract_contracts as cc where cc.oper_id = bc.oper_id and cc.client_id = bc.client_id and contract_type ~* 'rt_contract' order by contract_date desc limit 1), concat('4T#', bc.client_id)) as contract_number,
            bill_number::text,
            bill_number::text as akt_number,
            to_char(bill_date, 'DD.MM.YYYY 00:00') as bill_date,
            to_char(bill_date, 'DD.MM.YYYY 00:00') as payment_date,
            0 as currency,
            1 as nds,
            case service_type when '3_rtk' then '14' when '3_rtk' then '12' when '4_rtk' then '10' end as service,
            to_char(bill_date, 'DD.MM.YYYY 00:00') as service_date,
            round(bgs.service_sum, 2) as service_sum,
            round(coalesce(quantity, 1), 2) as quantity,
            '71 401' as place,
            1 as incl_nds,
            'GI' as bill_type,
            null::text as mod_time,
            null::text as mod_period,
            null::text as mod_number
from        base_clients as bc
inner join  bill_bills as bb using (oper_id, client_id)
inner join  bill_bill_services as bbs using (oper_id, client_id, bill_id)
inner join  bill_given_services as bgs using (oper_id, client_id, service_id)
where       oper_id = 'RC'
and         bill_type ~* 'invoice_RTK' and bill_date between date_trunc('month', now()) - interval '1 month' and date_trunc('month', now()) - interval '1 sec'
and         coalesce(none_client, 0) = 0
and         client_type != 'card'
order by    2
--limit       10
) select row_number() OVER () as id, * from s;
*/
/*-- Function: beeline.bill(text, date, date)

-- DROP FUNCTION beeline.bill(text, date, date);

CREATE OR REPLACE FUNCTION beeline.bill(
    IN _code text,
    IN _from date,
    IN _till date)
  RETURNS TABLE("Порядковый номер позиции в файле" bigint, "Номер Агентского Договора" text, "Номер клиентского договора" text, "No счет фактуры" text, "No акта" text, "Дата счета" text, "Срок оплаты" text, "Код валюты счета" integer, "Код НДС" integer, "Код услуги" text, "Дата услуги" text, "Стоимость" numeric, "Количество" numeric, "Место оказания услуги" text, "Вкл. НДС" integer, "Тип счета" text, "Дата исправления" text, "Отчётный период исправления" text, "Номер исправляемого счета" text) AS
$BODY$
    with s as (
    select      distinct 
                p.contract as "Номер Агентского Договора",
                --case when bc.oper_id ='RC' and contract_type != 'sov_contract_org' then concat(p.code, '#', bc.client_id) else case when contract_number is not null then case when contract_number like p.code||'#%' then contract_number else concat(p.code, '#', contract_number) end else concat(p.code, '#', bc.client_id) end end as "Номер клиентского договора",
                --coalesce((select case when bc.oper_id = 'XXI' or (bc.oper_id = 'RC' and contract_type != 'sov_contract_org') then concat(p.code, '#', regexp_replace(bc.client_id, E'^0+', '')) else case when contract_number like p.code||'#%' then contract_number else concat(p.code, '#', contract_number) end end from contract_contracts as cc where cc.oper_id = bc.oper_id and cc.client_id = bc.client_id and contract_type ~* 'sov_contract' order by contract_date desc limit 1), concat(p.code, '#', regexp_replace(bc.client_id, E'^0+', ''))) as "Номер клиентского договора",
                coalesce((select case when contract_number like p.code||'#%' then contract_number else concat(p.code, '#', contract_number) end from contract_contracts as cc where cc.oper_id = bc.oper_id and cc.client_id = bc.client_id and contract_type ~* 'sov_contract' order by contract_date desc limit 1), concat(p.code, '#', bc.client_id)) as "Номер клиентского договора",
                --concat(p.code, '#', bc.client_id) as "Номер клиентского договора",
                bill_number::text as "No счет фактуры",
                bill_number::text as "No акта",
                to_char(bill_date, 'DD.MM.YYYY 00:00') as "Дата счета",
                to_char(bill_date, 'DD.MM.YYYY 00:00') as "Срок оплаты",
                0 as "Код валюты счета",
                1 as "Код НДС",
                case service_type when '3_vk' then '14' when '3_sov' then '12' when '4_sov' then '10' end as "Код услуги",
                to_char(bill_date, 'DD.MM.YYYY 00:00') as "Дата услуги",
                round(bgs.service_sum, 2) as "Стоимость",
                round(coalesce(quantity, 1), 2) as "Количество",
                '71 401' as "Место оказания услуги",
                1 as "Вкл. НДС",
                'GI' as "Тип счета",
                null::text as "Дата исправления",
                null::text as "Отчётный период исправления",
                null::text as "Номер исправляемого счета"
    from        base_clients as bc
    inner join  provider as p using (oper_id)
    --inner join  telephone_services as s using (oper_id, client_id)
    inner join  bill_bills as bb using (oper_id, client_id)
    inner join  bill_bill_services as bbs using (oper_id, client_id, bill_id)
    inner join  bill_given_services as bgs using (oper_id, client_id, service_id)
    --left join   contract_contracts as cc on cc.oper_id = bc.oper_id and cc.client_id = bc.client_id and contract_type ~* 'sov_contract'
    where       code = _code
    --and         date_create < _till
    --and         coalesce(date_expire, 'infinity') > _from
    and         bill_type ~* 'invoice_SOV' and bill_date between _from and _till
    --and         (cc.contract_id is null or contract_type ~* 'sov_contract')
    and         coalesce(none_client, 0) = 0
    and         client_type != 'card'
    --and         bc.client_id = '7352220'
    --limit       10
    ) select row_number() OVER () as "Порядковый номер позиции в файле", * from s;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION beeline.bill(text, date, date)
  OWNER TO beeline;
*/