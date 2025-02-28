
select distinct pm.LRSN, pm.PIN, pm.AIN, pm.neighborhood, ld.landtype from landdetail ld
join landheader lh on lh.id=ld.landheaderid and lh.effstatus='A' and lh.begeffdate=
	(select max(lh_sub.begeffdate) from landheader lh_sub where
		lh.id=lh_sub.id)
join kcv_parcelmaster_short pm on pm.lrsn=lh.revobjid and pm.effstatus='A'
	and (pm.neighborhood between '2000' and '2999')
where ld.landtype='32' and ld.effstatus='A' and ld.begeffdate=
	(select max(ld_sub.begeffdate) from landdetail ld_sub where 
		ld.id=ld_sub.id and ld.landheaderid=ld_sub.landheaderid and ld.landlinenumber=ld_sub.landlinenumber)
	and lh.revobjid in 
(select distinct i.LRSN --, pm.PIN, pm.AIN, i.imp_type 
	from improvements i
join kcv_parcelmaster_short pm on pm.lrsn=i.lrsn and pm.effstatus='A'
where i.status='A' and i.imp_type='DWELL')
order by pm.pin
