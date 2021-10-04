create or replace function pcfbdrsattahfp_update() returns table (command text, count bigint) as $body$
with s as (
    select      distinct on (p.id)
                p.id,
                p.provider,
                p.client,
                p.fio,
                p.balance,
                p.direction,
                p.rayon,
                p.service,
                p.active,
                p.tech,
                p.tarif,
                p.address,
                h.house,
                h.flats,
                h.providers,
                now() as date
    from only   pcfbdrsatta as p
    left JOIN   string as h ON p.house = h.house
    --limit       20
), u as (
    update only pcfbdrsattahfp as t set
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
        flats = s.flats,
        providers = s.providers,
        date = s.date
    from s where t.id = s.id
    returning t.id, 'update'::text as command
), i as (
    insert into pcfbdrsattahfp select s.* from s left join u using (id) where u.id is null returning id, 'insert'::text as command
) select command, count(id) from i group by 1 union select command, count(id) from u group by 1
$body$ language sql