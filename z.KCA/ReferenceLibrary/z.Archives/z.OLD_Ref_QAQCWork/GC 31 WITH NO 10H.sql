select distinct a.lrsn, pm.pin, pm.ain, pm.neighborhood, a.extension, a.group_code		
		from allocations a
join kcv_parcelmaster_short pm on pm.lrsn=a.lrsn and pm.effstatus='A'		
left join allocations a1 on a1.lrsn=a.lrsn and a1.group_code='10H' and a1.status='A'		
where a.group_code = '31H' AND a.last_update >'20180101' AND a.status ='A' and a1.lrsn is null		
