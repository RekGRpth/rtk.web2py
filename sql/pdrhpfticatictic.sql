create table if not exists pdrhpfticatictic (
    provider text not null,
    direction text,
    rayon text,
    house text not null primary key,
    providers integer,
    flats integer,
    telephone integer,
    inet_dynamic_ip integer,
    cable_tv integer,
    active date,
    telephone_free numeric,
    inet_dynamic_ip_free numeric,
    cable_tv_free numeric,
    telephone_penetration numeric,
    inet_dynamic_ip_penetration numeric,
    cable_tv_penetration numeric,
    date date not null default now()
);
create table if not exists pdrhpfticatictic_log () inherits (pdrhpfticatictic);
create or replace function pdrhpfticatictic_trigger() returns trigger as $body$ declare
begin
    case TG_WHEN
        when 'BEFORE' then
            case TG_OP
                when 'INSERT' then
                    null;
                when 'UPDATE' then
                    if old is distinct from new then
                        insert into pdrhpfticatictic_log select old.*;
                    end if;
                when 'DELETE' then
                    insert into pdrhpfticatictic_log select old.*;
            end case;
        when 'AFTER' then
            null;
    end case;
    --if TG_OP in ('DELETE', 'UPDATE') then raise info '%.% % % old %', TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_WHEN, TG_OP, old; end if;
    --if TG_OP in ('INSERT', 'UPDATE') then raise info '%.% % % new %', TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_WHEN, TG_OP, new; end if;
    if TG_OP in ('INSERT', 'UPDATE') then RETURN new; elsif TG_OP = 'DELETE' then RETURN old; end if;
end;$body$ language plpgsql;
create trigger pdrhpfticatictic_after_trigger after insert or update or delete on pdrhpfticatictic for each row execute procedure pdrhpfticatictic_trigger();
create trigger pdrhpfticatictic_before_trigger before insert or update or delete on pdrhpfticatictic for each row execute procedure pdrhpfticatictic_trigger();
