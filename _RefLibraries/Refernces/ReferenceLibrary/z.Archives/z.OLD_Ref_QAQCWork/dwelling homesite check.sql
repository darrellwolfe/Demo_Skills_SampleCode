select distinct pm.lrsn, pm.pin, pm.ain --, i.*, lh.*, ld.* 			
	from kcv_parcelmaster_short pm		
join improvements i on i.lrsn=pm.lrsn and i.status='A'			
	and i.imp_type='DWELL'		
left outer join landheader lh on lh.revobjid=pm.lrsn			
	and lh.effstatus='A' and lh.postingsource='A' and lh.begeffdate=		
		(select max(lh_sub.begeffdate) from landheader lh_sub	
			where lh.revobjid=lh_sub.revobjid)
left outer join landdetail ld on ld.landheaderid=lh.id and ld.effstatus='A'			
	and ld.postingsource='A' and ld.landtype in (‘11’,'9','90','CA')		
where pm.effstatus='A' and ld.id is null and left(pm.pin,1) <> 'L'			
order by pm.pin			
