update pcfbdrsatta set direction = regexp_replace(direction, E',$', '') where direction like '%,';
update pcfbdrsatta set rayon = regexp_replace(rayon, E',$', '') where rayon like '%,';

update pcfbdrsattahfp set direction = regexp_replace(direction, E',$', '') where direction like '%,';
update pcfbdrsattahfp set rayon = regexp_replace(rayon, E',$', '') where rayon like '%,';

update pdrhpfcticatictic set direction = regexp_replace(direction, E',$', '') where direction like '%,';
update pdrhpfcticatictic set rayon = regexp_replace(rayon, E',$', '') where rayon like '%,';

update pdrhpfticatictic set direction = regexp_replace(direction, E',$', '') where direction like '%,';
update pdrhpfticatictic set rayon = regexp_replace(rayon, E',$', '') where rayon like '%,';

update hfpo set flats = 1 where flats = 0;
update hfpo set providers = 1 where flats = 0;