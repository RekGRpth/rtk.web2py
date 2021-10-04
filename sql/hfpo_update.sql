update      hfpo
set         house = concat_ws(', ', 'Тюменская область', house)
--from        hfpo
where       house not like 'Тюменская область,%'
--limit       10
--delete from pdrhpfcticatictic where house not like 'Тюменская область,%'
--delete from pcfbdrsattahfp where house not like 'Тюменская область,%'

create or replace function hfpo_trigger() returns trigger as $body$ declare
begin
    if TG_WHEN in ('BEFORE') and TG_OP in ('INSERT', 'UPDATE') and new.house not like 'Тюменская область,%' then
        new.house = concat_ws(', ', 'Тюменская область', new.house);
    end if;
    if TG_OP in ('INSERT', 'UPDATE') then RETURN new; elsif TG_OP = 'DELETE' then RETURN old; end if;
end;$body$ language plpgsql;
create trigger hfpo_after_trigger after insert or update or delete on hfpo for each row execute procedure hfpo_trigger();
create trigger hfpo_before_trigger before insert or update or delete on hfpo for each row execute procedure hfpo_trigger();
