select pm.lrsn, pm.pin, pm.ain, fr.* from kcv_flagrole1a fr
join kcv_parcelmaster_short pm on pm.lrsn=fr.objectid and fr.objecttype=100002
where fr.flagheaderid=19 and fr.effstatus='A'
order by pm.pin
