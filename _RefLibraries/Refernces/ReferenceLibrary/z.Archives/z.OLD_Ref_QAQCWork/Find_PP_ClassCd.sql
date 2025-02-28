select r.id as LRSN, r.PIN, r.AIN, r.ClassCd, r.BegEffDate from revobj r
	join KC_Find_PP_ClassCd F on F.LRSN=R.id and f.classcdcnt > 1
	where r.pin like 'E%' 
	and r.begeffdate >= '01-01-2009' and r.begeffdate <= '12-31-2009' 
	and r.classcd in (102720,2000074,2000077,102730,2000075,2000076)
	order by r.id, r.pin, r.ain, r.classcd, r.begeffdate
--	order by ain
