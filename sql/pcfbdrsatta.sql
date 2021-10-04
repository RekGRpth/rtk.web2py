create table if not exists pcfbdrsatta (
    id integer not null primary key,
    provider text not null,
    client text not null,
    fio text not null,
    balance numeric not null,
    direction text,
    rayon text,
    service text not null,
    active date not null,
    tech text,
    tarif text not null,
    address text,
    date date not null default now(),
    house text
);
create table if not exists pcfbdrsatta_log () inherits (pcfbdrsatta);
create or replace function pcfbdrsatta_trigger() returns trigger as $body$ declare
begin
    case TG_WHEN
        when 'BEFORE' then
            case TG_OP
                when 'INSERT' then
                    null;
                when 'UPDATE' then
                    if old is distinct from new then
                        insert into pcfbdrsatta_log select old.*;
                    end if;
                when 'DELETE' then
                    insert into pcfbdrsatta_log select old.*;
            end case;
        when 'AFTER' then
            null;
    end case;
    --if TG_OP in ('DELETE', 'UPDATE') then raise info '%.% % % old %', TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_WHEN, TG_OP, old; end if;
    --if TG_OP in ('INSERT', 'UPDATE') then raise info '%.% % % new %', TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_WHEN, TG_OP, new; end if;
    if TG_OP in ('INSERT', 'UPDATE') then RETURN new; elsif TG_OP = 'DELETE' then RETURN old; end if;
end;$body$ language plpgsql;
create trigger pcfbdrsatta_after_trigger after insert or update or delete on pcfbdrsatta for each row execute procedure pcfbdrsatta_trigger();
create trigger pcfbdrsatta_before_trigger before insert or update or delete on pcfbdrsatta for each row execute procedure pcfbdrsatta_trigger();
/*drop materialized view if exists service_mv cascade;
create materialized view service_mv as
select      row_number() OVER (PARTITION BY true) as id,
            bp.name::text as provider,--"Провайдер",
            case when client_id like '0%' then concat('"', client_id, '"') else client_id end::text as client,--"Лицевой",
            udecodeentities_numeric(regexp_replace(regexp_replace(bc.name, E'[ \t\r\n]+', ' ', 'g'), E' +$', '', 'g')) as fio,--"ФИО",
            round(balance, 2) as balance,--"Баланс",
            (select array_to_string(array_agg(value), ',') from (select distinct unnest(array_agg(value)) as value from client_entity where client_id = bc.client_id and entity_id = 825) as foo limit 1) as direction,--"Направление",
            (select array_to_string(array_agg(value), ',') from (select distinct unnest(array_agg(value)) as value from client_entity where client_id = bc.client_id and entity_id = 6) as foo limit 1) as rayon,--"Район",
            t.name::text as service,--"Услуга",
            date_active::date as active,--"Дата",
            st.name::text as tech,--"Технология",
            tp.name::text as tarif,--"Тариф",
            place_text(place) as address--"Адрес"
from        base_clients as bc
inner join  base_providers as bp using (oper_id)
inner join  loki_basic_service as bs on base_client_id = bc.id
inner join  service_types as t on t.id = bs.service_type
inner join  loki_tariff_plan as tp on tp.id = tariff
left join   service_tech as st on st.id = tech
where       true
and         bc.oper_id in ('NL')
and         case when bc.client_type = 'person' and person_use_srv_as_org then 'ФЛКЦ' when bc.client_type = 'person' then 'ФЛ' else 'ЮЛ' end = 'ФЛ'
and         coalesce(date_expire, 'infinity') >= now()
and         bs.service_type in (0, 1, 11)
--limit       10
;
create or replace view service as select * from service_mv;
*/