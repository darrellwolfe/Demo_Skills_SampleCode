select r.* from revobj r
where r.classcd=1306825 and r.begeffdate < '01-02-2018' and r.effstatus='A'
and r.begeffdate=
(select max(r_sub.begeffdate) from revobj r_sub where r_sub.begeffdate < '01-02-2018' and r.id=r_sub.id)


--select * from revobj where id=21672
--select * from systype where id=1200207
--select * from systype where systypecatid=7320 order by shortdescr
