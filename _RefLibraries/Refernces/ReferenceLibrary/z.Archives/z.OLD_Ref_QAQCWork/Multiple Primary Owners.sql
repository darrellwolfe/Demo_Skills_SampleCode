--PINs with multiple or missing primary owner
--(the missing primary owner issue is due to a known bug in GRM, 
--which has not yet been scheduled into a release)

select * from (

SELECT ro.id, ro.pin, ro.EffStatus, lpr1.PrimaryOwnerCt

FROM RevObj ro

JOIN ( SELECT lpr.objectid, COUNT(lpr.objectid) PrimaryOwnerCt

FROM legalpartyrole lpr 

WHERE lpr.effstatus ='A'

AND lpr.lproletype = 100701

AND lpr.objecttype = 100002

AND lpr.begeffdate = (SELECT MAX(begeffdate) FROM legalpartyrole WHERE ID = lpr.ID )

AND lpr.primelegalparty = 1

GROUP BY lpr.objectid

HAVING COUNT(lpr.objectid) > 1

) lpr1

ON lpr1.objectid = ro.id

WHERE ro.begeffdate = (SELECT max(begeffdate) FROM RevObj WHERE ID = ro.id)

UNION

SELECT ro.id, ro.pin, ro.effstatus, 0

FROM RevObj ro

WHERE ro.begeffdate = (SELECT MAX(begeffdate) FROM RevObj WHERE ID = ro.id)

AND ro.id NOT IN ( SELECT lpr.objectid

FROM legalpartyrole lpr 

WHERE lpr.effstatus = 'A'

AND lpr.lproletype = 100701

AND lpr.objecttype = 100002

AND lpr.begeffdate = ( SELECT MAX(begeffdate) from legalpartyrole where id = lpr.id)

AND lpr.primelegalparty=1

GROUP BY lpr.objectid

HAVING COUNT(lpr.objectid) >= 1)

) a

where effstatus = 'A'

