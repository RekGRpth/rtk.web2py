select      (select array_to_string(array_agg(value), ',') from (select distinct unnest(array_agg(value)) as value from client_entity where client_id = bc.client_id and entity_id = 825 and coalesce(value, '') != '') as foo limit 1)::text as direction,
            *
from        base_clients as bc
where       client_id in ('7955301')

select      *
from        client_entity
where       client_id in ('7955301')
and         value != ''