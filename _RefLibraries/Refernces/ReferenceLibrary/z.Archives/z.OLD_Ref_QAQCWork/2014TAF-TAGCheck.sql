select lrsn, pin, ain, displayname, pm.begeffdate, pm.classcd from kcv_parcelmaster_short pm
join map2014_tag_xref_t x on pm.tag=x.tag and x.tif_id > 0
left outer join kcv_tifrole1a tr on tr.objectid=pm.lrsn and tr.effstatus='A'
where pm.effstatus='A' and tr.id is null and pm.pin not like 'EMS%'
order by pm.pin

