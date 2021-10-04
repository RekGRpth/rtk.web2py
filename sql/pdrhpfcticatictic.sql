create table if not exists pdrhpfcticatictic (
    provider text not null,
    direction text,
    rayon text,
    house text not null primary key,
    providers integer,
    flats integer,
    capacity numeric,
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
create table if not exists pdrhpfcticatictic_log () inherits (pdrhpfcticatictic);
create or replace function pdrhpfcticatictic_trigger() returns trigger as $body$ declare
begin
    case TG_WHEN
        when 'BEFORE' then
            case TG_OP
                when 'INSERT' then
                    null;
                when 'UPDATE' then
                    if old is distinct from new then
                        insert into pdrhpfcticatictic_log select old.*;
                    end if;
                when 'DELETE' then
                    insert into pdrhpfcticatictic_log select old.*;
            end case;
        when 'AFTER' then
            null;
    end case;
    --if TG_OP in ('DELETE', 'UPDATE') then raise info '%.% % % old %', TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_WHEN, TG_OP, old; end if;
    --if TG_OP in ('INSERT', 'UPDATE') then raise info '%.% % % new %', TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_WHEN, TG_OP, new; end if;
    if TG_OP in ('INSERT', 'UPDATE') then RETURN new; elsif TG_OP = 'DELETE' then RETURN old; end if;
end;$body$ language plpgsql;
create trigger pdrhpfcticatictic_after_trigger after insert or update or delete on pdrhpfcticatictic for each row execute procedure pdrhpfcticatictic_trigger();
create trigger pdrhpfcticatictic_before_trigger before insert or update or delete on pdrhpfcticatictic for each row execute procedure pdrhpfcticatictic_trigger();
