select pm.LRSN, pm.pin, pm.ain, pm.displayname, ros.id as RevObjSiteId, ros.begeffdate, ros.shortdescr,
      ros.valchangereason, ros.tranid from revobjsite ros
join kcv_parcelmaster_short pm on pm.lrsn=ros.revobjid and pm.effstatus='A'
where ros.valchangereason not in (0,2000015) and ros.effstatus='A' and ros.begeffdate=
      (select max(ros_sub.begeffdate) from revobjsite ros_sub where ros.id=ros_sub.id)
order by pm.pin