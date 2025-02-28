---552829	MZZ24W06311E	333728


select * from improvements where lrsn=552829 and status='A' --year_built > 2004
select * from res_floor where lrsn=552829 and status='A'  --base_area < 501 & floor_key =1.0

--select * from 


select distinct i.lrsn, pm.pin, pm.ain, pm.displayname as Owner, --i.year_built, 
	rf.floor_key, rf.base_area--, a.group_code
	from improvements i
join res_floor rf on rf.lrsn=i.lrsn and rf.status='A' and rf.base_area < 501 and rf.floor_key='1.0'
join allocations a on a.lrsn=i.lrsn and a.status='A' and a.extension=i.extension and a.improvement_id=i.improvement_id
join kcv_parcelmaster_short pm on pm.lrsn=i.lrsn and pm.effstatus='A' and pm.pin not like 'L%' 
	and pm.neighborhood between '1000' and '9999'
where i.status='A' and i.year_built > 2004 and i.imp_type in ('MH','M','DWELL')
order by pm.pin--, a.group_code

