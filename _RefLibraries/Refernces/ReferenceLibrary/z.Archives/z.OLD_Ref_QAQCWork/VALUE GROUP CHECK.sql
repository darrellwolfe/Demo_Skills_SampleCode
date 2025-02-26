select pm.lrsn, pm.pin, pm.ain, pm.displayname, pm.effstatus, r.* from KCv_RevObjSite1a r
left outer join kcv_parcelmaster_short pm on pm.lrsn=r.revobjid
where (r.shortdescr <> 'Default' and r.shortdescr <> 'SPASS') 

select pm.lrsn, pm.pin, pm.ain, pm.displayname, pm.effstatus, r.* from KCv_RevObjSite1a r
left outer join kcv_parcelmaster_short pm on pm.lrsn=r.revobjid
where (sitetype <> 15905 and sitetype <> 15908)

select pm.lrsn, pm.pin, pm.ain, pm.displayname, pm.effstatus, r.* from KCv_RevObjSite1a r
left outer join kcv_parcelmaster_short pm on pm.lrsn=r.revobjid
where (descr <> 'Default Value Group' and descr <> 'Special Assessment')







