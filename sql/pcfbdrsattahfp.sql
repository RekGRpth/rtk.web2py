create table if not exists pcfbdrsattahfp (
    id integer not null primary key,
    provider text not null,
    client text not null,
    fio text not null,
    balance numeric not null,
    direction text,
    rayon text,
    service text not null,
    active date,
    tech text,
    tarif text not null,
    address text,
    house text,
    flats integer,
    providers integer,
    date date not null default now()
);
create table if not exists pcfbdrsattahfp_log () inherits (pcfbdrsattahfp);
create or replace function pcfbdrsattahfp_trigger() returns trigger as $body$ declare
begin
    case TG_WHEN
        when 'BEFORE' then
            case TG_OP
                when 'INSERT' then
                    null;
                when 'UPDATE' then
                    if old is distinct from new then
                        insert into pcfbdrsattahfp_log select old.*;
                    end if;
                when 'DELETE' then
                    insert into pcfbdrsattahfp_log select old.*;
            end case;
        when 'AFTER' then
            null;
    end case;
    --if TG_OP in ('DELETE', 'UPDATE') then raise info '%.% % % old %', TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_WHEN, TG_OP, old; end if;
    --if TG_OP in ('INSERT', 'UPDATE') then raise info '%.% % % new %', TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_WHEN, TG_OP, new; end if;
    if TG_OP in ('INSERT', 'UPDATE') then RETURN new; elsif TG_OP = 'DELETE' then RETURN old; end if;
end;$body$ language plpgsql;
create trigger pcfbdrsattahfp_after_trigger after insert or update or delete on pcfbdrsattahfp for each row execute procedure pcfbdrsattahfp_trigger();
create trigger pcfbdrsattahfp_before_trigger before insert or update or delete on pcfbdrsattahfp for each row execute procedure pcfbdrsattahfp_trigger();
