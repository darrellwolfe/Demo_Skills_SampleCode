select pm.id as PMID, 
pm.machinename as MName, 
pm.ismachineup as ISOn,
pm.ismachineinuse as Used,
--isnull(pq.id, 0) as PQID,
--isnull(rtrim(pq.name), ' ') as Name,
isnull(rtrim(pq.longdescr), ' ') as Dscrptn,
isnull(rtrim(st.descr), ' ') as LastStatus,
--isnull(rtrim(ph.descr), ' ') as LastStep,
isnull(rtrim(ps.processcount), 0) as Processed,
isnull(rtrim(ps.totalcount), 0) as Total,
isnull(pq.dateassigned, '01-JAN-04'  ) as DateAssigned,
isnull(rtrim(up.userlogin), ' ') as UserName
from processmachine pm

left join processqueue pq
     on pm.id = pq.pmid
	and pq.tranid = (select max(pq2.tranid) from processqueue pq2 where pq2.pmid = pm.id)

left join processstatus ps
     on pq.id = ps.processqueueid

left join processhist ph
     on pq.id = ph.processqueueid
	and ph.id = (select max(ph2.id) from processhist ph2 where ph2.processqueueid = ph.processqueueid)

left join systype st
     on ps.pstatus = st.id
	and st.effstatus = 'A'
	and st.begeffdate = (select max(stsub.begeffdate) from systype stsub where stsub.id = st.id)

left join userprofile up
     on pq.userprofileid = up.id
	and up.effstatus = 'A'
--	and up.begeffdate = (select max(up2.begeffdate) from userprofile up2 where up2.id = up.id)

where pm.id in 
             (select top 3 id from processmachine
              order by tranid desc)
     --and pm.id = pq.pmid      
group by pm.id, pm.machinename, pm.ismachineup, pm.ismachineinuse, pq.id, pq.name,  pq.longdescr, st.descr, ps.processcount, ps.totalcount,pq.dateassigned, up.userlogin
order by pm.id
