select a.lrsn, pm.pin, pm.ain, pm.neighborhood, --a.extension, 
	a.group_code, count(*) as AllocationCount		
		from allocations a
join kcv_parcelmaster_short pm on pm.lrsn=a.lrsn and pm.effstatus='A'		
--left join allocations a1 on a1.lrsn=a.lrsn and a1.group_code='10H' and a1.status='A'		
where a.group_code in ('10H','12H','15H','20H') and a.last_update >'20180101' AND a.status ='A' --and a1.lrsn is null
group by a.lrsn, pm.pin, pm.ain, pm.neighborhood, a.group_code		
order by allocationcount desc, pm.pin
