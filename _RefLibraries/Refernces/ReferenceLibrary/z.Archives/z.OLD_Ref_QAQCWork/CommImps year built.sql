select pm.lrsn, pm.pin, pm.ain, pm.displayname as Owner, pm.neighborhood,
	left(extensions.extension,1) as Extension,left(allocations.method,1) as Method,
		case 
--		when left(extensions.extension,1)='R' and allocations.method='C'
--			then cast(sum(allocations.cost_value)  as bigint)
--		when left(extensions.extension,1)='R' and allocations.method='I'
--			then cast(sum(allocations.income_value)  as bigint) 
		when left(extensions.extension,1)='C' and allocations.method='C'
			then cast(sum(allocations.cost_value) as bigint)
		when left(extensions.extension,1)='C' and allocations.method='I'
			then cast(sum(allocations.income_value) as bigint)
		else
			cast(sum(allocations.cost_value) as bigint)
		end as newconstr
 from kcv_parcelmaster_short pm
 join kcv_tagtaxauthority1a tta on tta.tagid=pm.tagid and tta.effstatus='A'
	and tta.taxauthorityid=202
	join extensions on extensions.lrsn = pm.lrsn 
		and extensions.status = 'A'
		and left(extensions.extension,1) in ('C') 
	join improvements on improvements.lrsn = pm.lrsn
		and improvements.status = 'A' 
		and (improvements.year_built = '2015') -- year=current year - 1
		and improvements.extension = extensions.extension 
	join allocations on allocations.lrsn = pm.lrsn and allocations.status='A'
		and allocations.extension=improvements.extension
		and improvements.improvement_id=allocations.improvement_id
		and left(allocations.group_code,2) not in ('67','81')	
group by pm.lrsn, pm.pin, pm.ain, pm.displayname,pm.neighborhood,
	left(extensions.extension,1),allocations.method
order by pm.pin
