select pm.LRSN, pm.PIN, pm.AIN, pm.displayname as Owner, dbo.stdescr('01-01-2016',fh.fhtype), fr.flagheaderid, 
	fr.FlagValue, fr.duration, fr.startdate, fr.terminationdate, fr.ticklerdate from kcv_flagrole1a fr
join kcv_parcelmaster_short pm on pm.lrsn=fr.objectid and pm.effstatus='A'
join kcv_flagheader1a fh on fh.id=fr.flagheaderid and fh.effstatus='A' and fh.begeffdate=
	(select max(fh_sub.begeffdate) from kcv_flagheader1a fh_sub where fh.id=fh_sub.id)
where fr.objecttype=100002 and fr.effstatus='A' and fr.terminationdate > '01-01-2016' and fr.begeffdate=
	(select max(fr_sub.begeffdate) from kcv_flagrole1a fr_sub where fr.id=fr_sub.id)
	and fh.id in (19) --type of flag
order by pm.displayname, pm.pin
	
	