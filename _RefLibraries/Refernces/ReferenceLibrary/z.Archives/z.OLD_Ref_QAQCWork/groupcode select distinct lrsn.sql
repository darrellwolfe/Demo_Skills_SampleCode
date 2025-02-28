select distinct a.lrsn, pm.pin, pm.ain, pm.neighborhood, a.extension, a.group_code
		from allocations a
join kcv_parcelmaster_short pm on pm.lrsn=a.lrsn and pm.effstatus='A'
where a.group_code = '31H' AND a.last_update >'20180101' AND a.status ='A' 
