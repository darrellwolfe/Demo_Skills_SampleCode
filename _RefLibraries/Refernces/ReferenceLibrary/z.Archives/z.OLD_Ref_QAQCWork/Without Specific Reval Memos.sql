
select distinct pm.lrsn, pm.pin, pm.ain, pm.begeffdate, pi.neighborhood from kcv_parcelmaster1e pm
left outer join parcelinfo pi on pi.lrsn=pm.lrsn
where pm.pin not like 'E%' and pm.pin not like 'UP%' and pm.pin not like 'G%'
	and pm.effstatus='A'
	and pm.lrsn not in 
	(select distinct lrsn from memos where memo_id in ('RY08','RY09','RY10','RY11','RY12'))
order by pi.neighborhood, pm.pin
