create or replace view entity as
select      b.id,
            a.id as type,
            a.name,
            b.name as value
from        base_client_entity as a
inner join  base_client_entity as b on b.parent_id = a.id
--where       a.id in (825, 6)
--limit       10