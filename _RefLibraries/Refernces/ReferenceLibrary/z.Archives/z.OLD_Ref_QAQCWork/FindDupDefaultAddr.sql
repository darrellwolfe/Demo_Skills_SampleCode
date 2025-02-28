select lp.DisplayName, cr.EffStatus CR_EffStatus, cr.BegEffDate CRBegEffDate, rtrim(c.Recipient) + ', ' + rtrim(c.DeliveryAddr) + ', ' + rtrim(c.LastLine) Address, cr.id CR_ID, cr.DefaultAddr CR_DefaultAddr, c.id C_ID, c.effStatus C_EffStatus, c.begeffdate C_BegEffDate, c.tranid C_TranId, c.commtype

from legalParty lp 

inner join (

            select distinct(cr.OBjectId)

            from CommRole cr 

            where    cr.ObjectType = 100001 and cr.effstatus='A'

                        and cr.begeffdate=(select max(crsub.begeffdate) from commRole crsub where crsub.id=cr.id)

                        and cr.defaultAddr = 1

            group by objectid

            having count(Objectid) > 1) cr1 

            on cr1.objectId = lp.id

inner join commRole cr 

            on cr.objectId = lp.id

            and cr.ObjectType = 100001 and cr.effstatus='A'

            and cr.begeffdate=(select max(crsub.begeffdate) from commRole crsub where crsub.id=cr.id)

            and cr.defaultAddr = 1

inner join comm c 

            on c.id = cr.CommId

            and c.effstatus='A'

            and c.begeffdate=(select max(csub.begeffdate) from comm csub where csub.id=c.id)

order by lp.displayname, cr.BegEffDate
