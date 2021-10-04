create or replace function pcfbdrsatta_update() returns table (command text, count bigint) as $body$
with s as (
    select      bs.id,
                bp.name::text as provider,
                case when client_id like '0%' then concat('"', client_id, '"') else client_id end::text as client,
                udecodeentities_numeric(regexp_replace(regexp_replace(bc.name, E'[ \t\r\n]+', ' ', 'g'), E' +$', '', 'g'))::text as fio,
                round(balance, 2)::numeric as balance,
                (select array_to_string(array_agg(value), ',') from (select distinct unnest(array_agg(value)) as value from client_entity where client_id = bc.client_id and entity_id = 825 and coalesce(value, '') != '') as foo limit 1)::text as direction,
                (select array_to_string(array_agg(value), ',') from (select distinct unnest(array_agg(value)) as value from client_entity where client_id = bc.client_id and entity_id = 6 and coalesce(value, '') != '') as foo limit 1)::text as rayon,
                t.name::text as service,
                date_active::date as active,
                st.name::text as tech,
                tp.name::text as tarif,
                place_text(place)::text as address,
                now() as date,
                place_text(place_house(place))::text as house
    from        base_clients as bc
    inner join  base_providers as bp using (oper_id)
    inner join  loki_basic_service as bs on base_client_id = bc.id
    inner join  service_types as t on t.id = bs.service_type
    inner join  loki_tariff_plan as tp on tp.id = tariff
    left join   service_tech as st on st.id = tech
    where       true
    and         bc.oper_id in ('NL', 'UG')
    and         case when bc.client_type = 'person' and person_use_srv_as_org then 'ФЛКЦ' when bc.client_type = 'person' then 'ФЛ' else 'ЮЛ' end = 'ФЛ'
    and         coalesce(date_expire, 'infinity') >= now()
    and         date_create <= now()
    and         bs.service_type in (0, 1, 11)
    --and         bs.id = 595673
    --limit       60
), u as (
    update only pcfbdrsatta as t set
        provider = s.provider,
        client = s.client,
        fio = s.fio,
        balance = s.balance,
        direction = s.direction,
        rayon = s.rayon,
        service = s.service,
        active = s.active,
        tech = s.tech,
        tarif = s.tarif,
        address = s.address,
        house = s.house,
        date = s.date
    from s where t.id = s.id
    returning t.id, 'update'::text as command
), i as (
    insert into pcfbdrsatta select s.* from s left join u using (id) where u.id is null returning id, 'insert'::text as command
) select command, count(id) from i group by 1 union select command, count(id) from u group by 1
/*on conflict (id) do update set
    provider = excluded.provider,
    client = excluded.client,
    fio = excluded.fio,
    balance = excluded.balance,
    direction = excluded.direction,
    rayon = excluded.rayon,
    service = excluded.service,
    active = excluded.active,
    tech = excluded.tech,
    tarif = excluded.tarif,
    address = excluded.address*/
$body$ language sql