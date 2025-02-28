select pm.lrsn, pm.pin, pm.ain, pm.displayname as Owner, ci.* from cadinv ci
left outer join cadvalue cv on cv.cadvaluectrlid=754 and cv.valuetype=0 and cv.cadinvid=ci.id
join kcv_parcelmaster_short pm on pm.lrsn=ci.revobjid
where ci.cadinvctrlid=481 and cv.cadinvid is null
