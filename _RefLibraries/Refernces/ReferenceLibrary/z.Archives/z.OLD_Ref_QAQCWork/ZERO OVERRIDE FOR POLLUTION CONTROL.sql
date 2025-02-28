
select pm.lrsn, pm.pin, pm.ain, pm.displayname as Owner, pm.classcd, m.descr as Modifier, rosmv.valueamount as OverrideValue from kcv_parcelmaster_short pm
join kcv_revobjsite1a ros on ros.revobjid=pm.lrsn and ros.sitetype=15905 
      and ros.effstatus='A'
join kcv_revobjsitemodifier1a rosm on rosm.revobjsiteid=ros.id and rosm.modifierid=12
      and rosm.effstatus='A' and rosm.expirationyear > 2018
join modifier m on m.id=12 and m.effstatus='A'
join kcv_revobjsitemodifiervalue1a rosmv on rosmv.revobjsitemodifierid=rosm.id
      and rosmv.valueamount <> 100
order by pm.pin
