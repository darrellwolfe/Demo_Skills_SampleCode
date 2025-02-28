select distinct a.lrsn, pm.pin, pm.ain, pm.neighborhood,
--a.group_code, 
a.last_update_long from val_detail a 
join kcv_parcelmaster1 pm on pm.lrsn=a.lrsn and pm.effstatus='A'
where a.group_code in ('98','99') --and a.method in ('C') 
	and a.last_update_long=
		(select max(a_sub.last_update_long) from val_detail a_sub where a.lrsn=a_sub.lrsn) 
order by a.lrsn