select f.lrsn, pm.pin, pm.ain, pm.neighborhood, f.extension, f.improvement_id, f.feat_code from features f
join kcv_parcelmaster1 pm on pm.lrsn = f.lrsn
where f.feat_code = 'NOFLOOR' and f.status ='A'