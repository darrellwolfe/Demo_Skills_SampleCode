select d.lrsn, pm.pin, pm.ain, pm.neighborhood, d.extension, d.cvt_ext_lvg_units
	from dwellings d
join kcv_parcelmaster_short pm on pm.lrsn=d.lrsn and pm.effstatus='A'
where d.status='A' and d.cvt_ext_lvg_units not in (0)
order by pm.neighborhood, pm.ain, d.extension

