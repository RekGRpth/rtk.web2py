create or replace function pdrhpfticatictic_update() returns table (command text, count bigint) as $body$
with s as (
    with s as (
        select      provider,
                    (with s as (with s as (with s as (select array_agg(direction) as s) select unnest(s) as s from s) select unnest(string_to_array(s, ',')) as s from s where s != '' group by 1) select array_to_string(array_agg(s), ',') as s from s limit 1) as direction,
                    (with s as (with s as (with s as (select array_agg(rayon) as s) select unnest(s) as s from s) select unnest(string_to_array(s, ',')) as s from s where s != '' group by 1) select array_to_string(array_agg(s), ',') as s from s limit 1) as rayon,
                    house,
                    providers,
                    flats,
                    sum(case service when 'Телефония' then 1 else 0 end) as telephone,
                    sum(case service when 'Интернет с динамическим IP' then 1 else 0 end) as inet_dynamic_ip,
                    sum(case service when 'Кабельное TV' then 1 else 0 end) as cable_tv,
                    max(active) as active
        from only   pcfbdrsattahfp
        where       house is not null
        group by    1, 4, 5, 6
    ) select    *,
                round(flats - telephone::numeric, 2) as telephone_free,
                round(flats - inet_dynamic_ip::numeric, 2) as inet_dynamic_ip_free,
                round(flats - cable_tv::numeric, 2) as cable_tv_free,
                round(telephone::numeric / flats * 100 , 2)as telephone_penetration,
                round(inet_dynamic_ip::numeric / flats * 100, 2) as inet_dynamic_ip_penetration,
                round(cable_tv::numeric / flats * 100, 2) as cable_tv_penetration,
                now() as date
    from        s
    --limit       10
), u as (
    update only pdrhpfticatictic as t set
        provider = s.provider,
        direction = s.direction,
        rayon = s.rayon,
        providers = s.providers,
        flats = s.flats,
        telephone = s.telephone,
        inet_dynamic_ip = s.inet_dynamic_ip,
        cable_tv = s.cable_tv,
        active = s.active,
        telephone_free = s.telephone_free,
        inet_dynamic_ip_free = s.inet_dynamic_ip_free,
        cable_tv_free = s.cable_tv_free,
        telephone_penetration = s.telephone_penetration,
        inet_dynamic_ip_penetration = s.inet_dynamic_ip_penetration,
        cable_tv_penetration = s.cable_tv_penetration,
        date = s.date
    from s where t.house = s.house
    returning t.house, 'update'::text as command
), i as (
    insert into pdrhpfticatictic select s.* from s left join u using (house) where u.house is null returning house, 'insert'::text as command
) select command, count(house) from i group by 1 union select command, count(house) from u group by 1
$body$ language sql