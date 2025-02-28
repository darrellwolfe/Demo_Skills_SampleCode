select distinct pm.lrsn, pm.pin, pm.ain, f.feat_code, f.improvement_id, f.extension from features f
join kcv_parcelmaster1 pm on pm.lrsn=f.lrsn and pm.effstatus='A'
join improvements i on i.lrsn=f.lrsn and i.improvement_id=f.improvement_id
	and i.extension = f.extension and i.status='A' and i.sound_value_code = 0
where f.adj_amount1=0 and f.status='A' 