select pm.lrsn, pm.pin, pm.ain, pm.neighborhood,
--i.*,f.*, f2.* 
i.imp_type, i.improvement_id, f.feat_code as feat_code1, f2.feat_code as feat_code2
from improvements i
join kcv_parcelmaster1 pm on pm.lrsn=i.lrsn and effstatus='A'
join features f on f.lrsn=i.lrsn and i.extension=f.extension 
	and i.improvement_id = f.improvement_id
	and (f.feat_code='finishhi' or f.feat_code='finishlo')
	and f.status='A'
join features f2 on f2.lrsn=i.lrsn and i.extension=f2.extension 
	and i.improvement_id = f.improvement_id
	and f2.feat_code='E'
	and f2.status='A'
where i.imp_type='polebldg' and i.status='A'
order by pm.lrsn
