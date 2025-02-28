select i.lrsn, pm.pin, pm.ain, pm.displayname, pm.effstatus as Owner, i.image_path, i.image_date, i.image_seq_number from image_index i
join kcv_parcelmaster_short pm on pm.lrsn=i.lrsn
where i.image_path like '0000\%' order by pm.pin

