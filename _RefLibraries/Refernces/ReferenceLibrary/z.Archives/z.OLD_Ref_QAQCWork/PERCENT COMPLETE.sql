select i.lrsn, pm.pin, pm.ain, pm.neighborhood, i.improvement_id, i. imp_type,i.pct_complete
	from improvements i
join kcv_parcelmaster_short pm on pm.lrsn=i.lrsn and pm.effstatus='A'
where improvement_id <> 'D' and
 pct_complete < '100' and pct_complete <> 0 and status = 'A' order by neighborhood