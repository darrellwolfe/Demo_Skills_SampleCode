select pm.lrsn as RevObjID, pm.PIN, pm.AIN, 		
	case when TTA17.TaxAuthorityId is not NULL or Left(ro17.PIN, 1) = '0' then isNULL(v17a1.LandValueAmount,0) else 0 end as LandValue17,	
	case when TTA17.TaxAuthorityId is not NULL or Left(ro17.PIN, 1) = '0' then isNULL(v17a2.ImpValueAmount,0) else 0 end as ImpValue17,	
	case when TTA17.TaxAuthorityId is not NULL or Left(ro17.PIN, 1) = '0' then isNULL(v17a1.LandValueAmount,0) + isNULL(v17a2.ImpValueAmount,0) else 0 end as TotalValue17, 	
	case when TTA18.TaxAuthorityId is not NULL or Left(ro18.PIN, 1) = '0' then isNULL(v18a1.LandValueAmount,0) else 0 end as LandValue18,	
	case when TTA18.TaxAuthorityId is not NULL or Left(ro18.PIN, 1) = '0' then isNULL(v18a2.ImpValueAmount,0) else 0 end as ImpValue18,	
	case when TTA18.TaxAuthorityId is not NULL or Left(ro18.PIN, 1) = '0' then isNULL(v18a1.LandValueAmount,0) + isNULL(v18a2.ImpValueAmount,0) else 0 end as TotalValue18, 	
	case when TTA19.TaxAuthorityId is not NULL or Left(ro19.PIN, 1) = '0' then isNULL(v19a1.LandValueAmount,0) else 0 end as LandValue19,	
	case when TTA19.TaxAuthorityId is not NULL or Left(ro19.PIN, 1) = '0' then isNULL(v19a2.ImpValueAmount,0) else 0 end as ImpValue19,	
	case when TTA19.TaxAuthorityId is not NULL or Left(ro19.PIN, 1) = '0' then isNULL(v19a1.LandValueAmount,0) + isNULL(v19a2.ImpValueAmount,0) else 0 end as TotalValue19 	
		from kcv_parcelmaster_short pm
left outer join kcv_rpannualCadExport17a_landvalsum v17a1 on pm.lrsn = v17a1.revObjId and v17a1.ValueTypeId = 101 --LAND		
left outer join kcv_rpannualCadExport17a_impvalsum v17a2 on pm.lrsn = v17a2.revObjId and v17a2.ValueTypeId = 103 --IMP		
--left outer join kcv_rpannualCadExport17a v17a3 on pm.lrsn = v17a3.revObjId and v17a3.ValueTypeId = 109 --TOTAL		
left outer join KCv_TagTaxAuthority17a TTA17 on v17a1.tagid = TTA17.TAGId and TTA17.EffStatus = 'A' 		
              and TTA17.TaxAuthorityId between 201 and 214		
left outer join kcv_revobj17a ro17 on pm.lrsn = ro17.id		
left outer join kcv_rpannualCadExport18a_landvalsum v18a1 on pm.lrsn = v18a1.revObjId and v18a1.ValueTypeId = 101 --LAND		
left outer join kcv_rpannualCadExport18a_impvalsum v18a2 on pm.lrsn = v18a2.revObjId and v18a2.ValueTypeId = 103 --IMP		
--left outer join kcv_rpannualCadExport18a v18a3 on pm.lrsn = v18a3.revObjId and v18a3.ValueTypeId = 109 --TOTAL		
left outer join KCv_TagTaxAuthority18a TTA18 on v18a1.tagid = TTA18.TAGId and TTA18.EffStatus = 'A' 		
       and TTA18.TaxAuthorityId between 201 and 214		
left outer join kcv_revobj18a ro18 on pm.lrsn = ro18.id		
left outer join kcv_rpannualCadExport19a_landvalsum v19a1 on pm.lrsn = v19a1.revObjId and v19a1.ValueTypeId = 101 --LAND		
left outer join kcv_rpannualCadExport19a_impvalsum v19a2 on pm.lrsn = v19a2.revObjId and v19a2.ValueTypeId = 103 --IMP		
--left outer join kcv_rpannualCadExport19a v19a3 on pm.lrsn = v19a3.revObjId and v19a3.ValueTypeId = 109 --TOTAL		
left outer join KCv_TagTaxAuthority19a TTA19 on v19a1.tagid = TTA19.TAGId and TTA19.EffStatus = 'A' 		
       and TTA19.TaxAuthorityId between 201 and 214		
left outer join kcv_revobj19a ro19 on pm.lrsn = ro19.id		
where --pm.AIN = 127964 and 		
(left(pm.pin,1) = '0' or tta17.id is not null or tta18.id is not null or tta19.id is not null) and 		
	(v17a1.revobjid is not NULL or v17a2.revobjid is not Null or v18a1.revobjid is not NULL or v18a2.revobjid is not Null or    	
		v19a1.revobjid is not NULL or v19a2.revobjid is not Null)
order by pm.PIN		
