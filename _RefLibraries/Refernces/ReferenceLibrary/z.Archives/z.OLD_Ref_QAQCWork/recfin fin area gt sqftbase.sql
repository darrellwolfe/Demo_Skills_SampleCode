-- Where rec finish and finshed area of basement is greater than sq ft of basement

select pm.lrsn, pm.pin, pm.ain, pm.neighborhood, rf.extension, d.rec_area as BasementRecRoomSize, rf.finish_living_area as FinishedAreaSize, 
	rf.base_area as BaseAreaSize, ((d.rec_area+rf.finish_living_area)-rf.base_area) as Result 
		from res_floor rf
join kcv_parcelmaster_short pm on pm.lrsn=rf.lrsn and pm.effstatus='A'
left join dwellings d on d.lrsn=rf.lrsn and d.status='A' and rf.extension=d.extension
	and rf.dwelling_number=d.dwelling_number
where rf.status='A' and rf.floor_key='B' and d.rec_area > 0
order by result desc, pm.pin

/*
select * from dwellings where lrsn=16077 and status='A'  -- rec_area

select * from res_floor where lrsn=16077 and status='A' and floor_key='B'   --base_area  finish_living_area

--select * from dwellings where status='A' and rec_area <> 0 order by rec_area
select * from res_floor where status='A' and floor_key='B' and base_area <> 0 order by base_area
select * from res_floor where status='A' and floor_key='B' and finish_living_area <> 0 order by finish_living_area
*/
