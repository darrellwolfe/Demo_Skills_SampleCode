select distinct a.lrsn, pm.pin, pm.ain, a.group_code, a2.group_code, a3.group_code from allocations a
join kcv_parcelmaster1 pm on pm.lrsn=a.lrsn
join allocations a2 on a2.lrsn=a.lrsn and a2.group_code in ('12','12R') and
	a2.status='A' and
	a2.last_update=(select max(a2_sub.last_update) from allocations a2_sub 
		where a.lrsn=a2_sub.lrsn and a.group_code = a2_sub.group_code)
left outer join allocations a3 on a3.lrsn=a.lrsn and a3.group_code in ('10','10R') and
	a3.status='A' and
	a3.last_update=(select max(a3_sub.last_update) from allocations a3_sub 
		where a.lrsn=a3_sub.lrsn and a.group_code = a3_sub.group_code)
where a.group_code in ('01','02','03','04','05','06','07','08','09') and
	a.status='A' and
	a.last_update=(select max(a_sub.last_update) from allocations a_sub 
		where a.lrsn=a_sub.lrsn and a.group_code=a_sub.group_code)
order by a.lrsn
