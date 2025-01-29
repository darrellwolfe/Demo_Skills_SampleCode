select * from markethistory 
	where begeffdate > '2009-12-31' and begeffdate < '2011-01-01' 
		and nbhdnumber='2507' and adjsaleprice > 0
/*
insert into markethistory_081011_bak select * from markethistory
	where begeffdate > '2009-12-31' and begeffdate < '2011-01-01' 
		and nbhdnumber='2507' and adjsaleprice > 0
*/

update markethistory set consideration = adjsaleprice 
	where begeffdate > '2009-12-31' and begeffdate < '2011-01-01' 
		and nbhdnumber='2507' and adjsaleprice > 0
