-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

SELECT * FROM information_schema.columns 
WHERE table_name LIKE 'TIF%';

--Find a table with a Column Name like...
SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'TaxCalcDetail%';
*/


--PTR006
Declare @TaxYear int = 2023;
--{?TaxYear}
Declare @Roll char(1) = 'A';
-- 'Annual' > 'A'
-- 'Occupancy' > 'O'
--'{?Roll}' --PARAMETER


WITH 

CTE_PTR006 AS (

SELECT  
  (select upper(ltrim(rtrim(Descr))) from county where CountyType = 251252	) as County
, cv.RollCaste
, isnull(ptr.Roll,'U') as Roll  --  U=UnknownRoll
, pm.lrsn
, TRIM(pm.ain) AS ain
, TRIM (pm.pin) AS parcel_id
, ptr.AppId
, ptr.AppName1 + ' ' + ptr.AppName2  AS AppName
, ptr.AppName1 + ' ' + ptr.AppName2 + ' ' + rtrim(ltrim(cast(ptr.AppId as char))) AS AppNameAndAppId
, mn.PrimaryOwner as owner1
, mn.owner2
, mn.owner3
, mn.owner4
, mn.owner5
, mn.owner6
, pm.TAG
, pm.MailingAddress
, pm.MailingCity
, pm.MailingState
, pm.MailingZip
, pm.DisplayDescr AS legal
, cast(cv.TaxYear as int) AS TaxYear
, m.id as AdjustmentID
, cast(rsmv.ValueAmount as integer) AS AVamount
, ptr.Sched



, (		SELECT  cast(sum(tr.taxrate * tr.ratebasis)as numeric (10,9))
		FROM TafRate tr 
		INNER JOIN taf v
  		ON v.id = tr.tafid
  		AND v.BegEffYear = (select max(begEffYear) 
  							from taf vsub 
  							where vsub.id = v.id
  							and vsub.BegEffYear <= tr.TaxYear
  							)
  		AND v.EffStatus = 'A'
		INNER JOIN TAGTaxAuthority tt 
  		ON tt.taxAuthorityId = v.TaxAuthorityId
  		AND tt.BegEffYear = (select max(BegEffYear) 
  							 from TAGTaxAuthority ttsub 
  							 where tt.id = ttsub.id
  							 and tt.BegEffYear <= tr.TaxYear  
    							 )
  		AND tt.BegEffYear <= tr.TaxYear  -- to accomodate bad data in Payette	
  		AND tt.effstatus = 'A'	
		INNER JOIN TAG
  		ON tag.id = tt.tagid
  		AND tag.effstatus = 'A'
  		--AND substring(tag.ShortDescr,4,1) = '-'  --NEEDS COMMENTED OUT OTHERWISE RPT DOES NOT WORK FOR KOOTENAI
  		AND tag.ShortDescr is not null		
  		AND tag.BegEffYear = (select max(BegEffYear) 
  							  from TAG tagsub 
  							  where tag.id = tagsub.id 
  							  and tagsub.effstatus = 'A' 	
  							  )
		WHERE tr.TaxYear = @TaxYear
  		AND tr.rateclass = 350143
  		AND tr.ratetypeid = 2
  		AND tag.ShortDescr = pm.tag		
  		AND tr.ratevaluetype in (select id 
  								 from ValueType 
  								 where ShortDescr in ('Net Tax Value','Fire Tax','Flood Tax','Net Imp Only','Net Minus Ag/Tbr') 
  								 or id = 460 --kootenai net tax minus timber
  								 )
		) as TaxRate


, 'PTRLandV' as LandChar
, (select vta.valueamount from ValueTypeAmount vta where vta.HeaderId = cv.CadInvId and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'PTRElgLandV')) as PTRLand
, 'PTRImpV' as ImpChar
, (select vta.valueamount from ValueTypeAmount vta where vta.HeaderId = cv.CadInvId and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'PTRElgImpV')) as PTRImp
, 'PTRHO' as HOChar
, (select vta.valueamount from ValueTypeAmount vta where vta.HeaderId = cv.CadInvId and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'PTRHO')) as HOAmt
, 'PTR' as PTRChar
, (select vta.valueamount from ValueTypeAmount vta where vta.HeaderId = cv.CadInvId and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'PTRBenefit')) as PTRAmt
, 'ACRES' as mLandCharAcre
, (select sum(vta.valueamount) from ValueTypeAmount vta where vta.HeaderId = cv.CadInvId and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'AcresByCat')) as mLandAcre
, 'LM' as mLandChar
, (select SUM(vta.valueamount) 
   from ValueTypeAmount vta 
   where vta.HeaderId = cv.CadInvId 
   and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'AssessedByCat') 
   and vta.AddlObjectId in (select CodesToSysType from codes_table where tbl_type_code = 'impgroup' and field_2 <> '2-imp') 
   ) as mLand
, 'IM' as mImpChar
, (select SUM(vta.valueamount) 
   from ValueTypeAmount vta 
   where vta.HeaderId = cv.CadInvId 
   and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'AssessedByCat')		
   and vta.AddlObjectId in (select CodesToSysType from codes_table where tbl_type_code = 'impgroup' and field_2 = '2-imp') 
   ) as mImp
, (select SUM(vta.valueamount) 
   from ValueTypeAmount vta 
   where vta.HeaderId = cv.CadInvId 
   and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'SupValCatPro')		
   and vta.AddlObjectId in (select CodesToSysType from codes_table where tbl_type_code = 'impgroup' and field_2 = '2-imp') 
   ) as mImpSuppl  
, (select sum(vta.valueamount) 
   from ValueTypeAmount vta 
   where vta.HeaderId = cv.CadInvId 
   and vta.ValueTypeId in (select id from ValueType where ValueTypeClass = 1200043 and ValueTypeCat = 351181 and id <> (select id from ValueType where ShortDescr = 'HOEligibleByCat'))
   ) as TotalEx  
, (select sum(vta.valueamount) 
   from ValueTypeAmount vta 
   where vta.HeaderId = cv.CadInvId 
   and vta.ValueTypeId in (select id from ValueType where ValueTypeClass = 1200043 and ValueTypeCat = 351181 and id <> (select id from ValueType where ShortDescr = 'HOEligibleByCat'))
   and vta.AddlObjectId in (select id from SysType where SysTypeCatId = 10340 and ShortDescr like '%H')
   ) as TotalHCatEx      
, 'TotHmEx' as mHOChar
, (select vta.valueamount from ValueTypeAmount vta where vta.HeaderId = cv.CadInvId and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'HOEX_Exemption')) as mHOAmt
, 'PTRLand' as LandPtrPctChar
, (select vta.valueamount from ValueTypeAmount vta where vta.HeaderId = cv.CadInvId and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'PTRLand'))  as PTRLandPct
, 'PTRImp' as ImpPtrPctChar
, (select vta.valueamount from ValueTypeAmount vta where vta.HeaderId = cv.CadInvId and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'PTRImp')) as PTRImpPct
, 'HOPct' as HOPctChar
, isnull((select vta.valueamount from ValueTypeAmount vta where vta.HeaderId = cv.CadInvId and vta.ValueTypeId = (select id from ValueType where ShortDescr = 'HOEX_Percent')),100) as HOPct


, case when ptr.Roll in ('A','O') then (Select sum(f.amount) 
										from FnclDetail f
										where f.revobjid = pm.lrsn 
										and f.taxyear = @TaxYear 
										and f.cat = 290021 
										and f.cattype = 290085 
										and f.subcd = 290094 
										) * -1 
	   
	   when ptr.Roll = 'B' and @Roll = 'A' then (Select sum(f.amount) 
												 from FnclDetail f
												 inner join TaxBill tb
												 on tb.id = f.TaxBillId
												 and tb.TaxYear = @TaxYear
												 inner join TaxBillTran tbt
												 on tbt.TaxBillId = tb.Id
												 and tbt.RollCaste = 16001
												 and tbt.Status = 350562												 
												 where f.revobjid = pm.lrsn 
												 and f.taxyear = @TaxYear 
												 and f.cat = 290021 
												 and f.cattype = 290085 
												 and f.subcd = 290094 
												 ) * -1 
	   when ptr.Roll = 'B' and @Roll = 'O' then ((Select sum(f.amount) 
												 from FnclDetail f
												 inner join TaxBill tb
												 on tb.id = f.TaxBillId
												 and tb.TaxYear = @TaxYear
												 inner join TaxBillTran tbt
												 on tbt.TaxBillId = tb.Id
												 and tbt.RollCaste = 16002
												 and tbt.Status = 350562
												 where f.revobjid = pm.lrsn 
												 and f.taxyear = @TaxYear 
												 and f.cat = 290021 
												 and f.cattype = 290085 
												 and f.subcd = 290094 
												 ) * -1 )
												 ---
												 --((Select sum(f.amount) 
												 --from FnclDetail f
												 --inner join TaxBill tb
												 --on tb.id = f.TaxBillId
												 --and tb.TaxYear = @TaxYear
												 --inner join TaxBillTran tbt
												 --on tbt.TaxBillId = tb.Id
												 --and tbt.RollCaste = 16001
												 --and tbt.Status = 350562
												 --where f.revobjid = pm.lrsn 
												 --and f.taxyear = @TaxYear 
												 --and f.cat = 290021 
												 --and f.cattype = 290085 
												 --and f.subcd = 290094 
												 --) * -1 )
												 else 0
												 end as ptrCreditAmt
												 
												 
												 
, (Select cast(sum(round(tbc.ValueAmount * tbc.TaxRate,2))as decimal(7,2))  
   from TaxBillChrg tbc 
   inner join TaxBillTran tbt
   on tbt.id = tbc.TaxBillTranId
   and tbt.RollCaste = cv.RollCaste   
   and tbt.Status = 350566 
   and tbt.TranDate = (select max(TranDate) from TaxBillTran tbtsub where tbtsub.TaxBillId = tbt.TaxBillId and tbtsub.Status = 350566)
   where tbc.revobjid = pm.lrsn 
   and tbc.rateyear = @TaxYear 
   and tbc.AmountType = 350384
   and tbc.Chrgsubcd in (290094)
   and tbc.Inst = 1
   ) as ptrTaxAmt  
   
   
, (Select sum(tbc2.Amount)  
   from TaxBillChrg tbc2 
   inner join TaxBillTran tbt2
   on tbt2.id = tbc2.TaxBillTranId
   and tbt2.RollCaste = cv.RollCaste   
   and tbt2.Status = 350566 
   and tbt2.TranDate = (select max(TranDate) from TaxBillTran tbt2sub where tbt2sub.TaxBillId = tbt2.TaxBillId and tbt2sub.Status = 350566)
   where tbc2.revobjid = pm.lrsn 
   and tbc2.rateyear = @TaxYear 
   --and tbc2.AmountType = 350384
   and tbc2.RateValueType < 1000  --exclude specials
   and tbc2.SourceValueType not in (select id from ValueType where ShortDescr = 'HOEX_Exemption' )
   and tbc2.Chrgsubcd in (290093,290215,291123)
   ) as Remaining_Tax   
   
   
, (		SELECT  tr.RateValueType
		FROM TafRate tr 
		INNER JOIN taf v
		ON v.id = tr.tafid
		AND v.BegEffYear = (select max(begEffYear) 
							from taf vsub 
							where vsub.id = v.id
							and vsub.BegEffYear <= tr.TaxYear
							)
		AND v.EffStatus = 'A'
		INNER JOIN TAGTaxAuthority tt 
		ON tt.taxAuthorityId = v.TaxAuthorityId
		AND tt.BegEffYear = (select max(BegEffYear) 
							 from TAGTaxAuthority ttsub 
							 where tt.id = ttsub.id
							 and tt.BegEffYear <= tr.TaxYear  
							 )
		AND tt.BegEffYear <= tr.TaxYear  -- to accomodate bad data in Payette	
		AND tt.effstatus = 'A'	
		INNER JOIN TAG
		ON tag.id = tt.tagid
		AND tag.effstatus = 'A'
		--AND substring(tag.ShortDescr,4,1) = '-'  --COMMENT OUT IN ORDER FOR REPORT TO RUN CORRECTLY FOR KOOTENAI
		AND tag.ShortDescr is not null		
		AND tag.BegEffYear = (select max(BegEffYear) 
							  from TAG tagsub 
							  where tag.id = tagsub.id 
							  and tagsub.effstatus = 'A' 	
							  )
		WHERE tr.TaxYear = @TaxYear
		AND tr.rateclass = 350143
		AND tr.ratetypeid = 2
		AND tr.ratevaluetype in (select id from ValueType where ShortDescr = 'Net Imp Only')		
		AND tag.ShortDescr = pm.tag
		) as HasSpecialRate
, case when ptr.PTRApp = '1'  and ptr.Vet100 = '1' then '*PTR AND Veterans 100' + '%' + 'SCD*'
       when ptr.PTRApp = '0'  and ptr.Vet100 = '1' then '*Veterans 100' + '%' + ' SCD*'
       when ptr.PTRApp = '1'  and ptr.Vet100 = '0' then ''
       else ''
  end as AppType		
  
  



--  Final Table Joins

FROM Modifier m

INNER JOIN revobjSiteModifier rsm
  on rsm.modifierid = m.id
  and rsm.effStatus = 'A'
  and rsm.ExpirationYear = @TaxYear
  and rsm.begTaxYear = (select max(begTaxYear) from revobjSiteModifier rsmsub where rsmsub.id = rsm.id and left(begtaxyear,4) = @TaxYear)

INNER JOIN tsbv_ParcelMasterLimited pm 
  ON pm.revobjsiteid = rsm.revobjSiteId 

INNER JOIN revobjSiteModifierValue rsmv
  on rsmv.revobjSiteModifierId = rsm.id
  and rsmv.valuetypeid = (select id from ValueType where ShortDescr = 'PTRBenefit')
  and rsmv.effStatus = 'A'
  and rsmv.begTaxYear = (select max(begTaxYear) from revobjSiteModifierValue rsmvsub where rsmvsub.id = rsmv.id)

INNER JOIN dbo.TSBv_cadastre cv 
  ON cv.lrsn = pm.lrsn
  and cv.TypeCode = 'PTRBenefit'
  --and cv.rollcaste = 16002 
  and	cv.taxyear = rsm.ExpirationYear

INNER JOIN tsb_MultipleNames mn
  ON mn.lrsn = cv.lrsn

LEFT OUTER JOIN tsb_PTRWeb ptr
  ON pm.pin in (ptr.PIN1, ptr.PIN2, ptr.PIN3, ptr.PIN4)
  and ptr.TaxYear = rsm.ExpirationYear

WHERE m.ID = (select distinct id from Modifier where ShortDescr in ('PTRBenefit','PTR'))
  and m.EffStatus = 'A'
  and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id)
  and rsm.ExpirationYear = @TaxYear
  and (@Roll = 'A' and cv.RollCaste = 16001
       or 
       @Roll = 'O' and cv.RollCaste = 16002
       )

--AND PM.pin = 'B00000344955'

-- order by 3 DESC
),

CTE_Cert AS (
  SELECT 
    lrsn,
    --Certified Values
    v.land_market_val AS CertValue_Land_NoEx,
    v.imp_val AS CertValue_Imp,
    (v.imp_val + v.land_market_val) AS CertValue_Total,
    v.eff_year AS Tax_Year,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
    AND v.status = 'A'
),

CTE_Assessed AS (
  SELECT 
    lrsn,
    --Assessed Values
    v.land_assess AS AssessedValue_Land_wEx,
    v.imp_assess AS AssessedValue_Imp,
    (v.imp_assess + v.land_assess) AS AssessedValue_Total,
    v.eff_year AS Tax_Year,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
    AND v.status = 'A'
)



SELECT
ptr006.lrsn
,ptr006.ain AS AIN
,ptr006.parcel_id AS PIN
,ptr006.AppId
,ptr006.AppName
,ptr006.TaxRate
--,ptr006.PTRLand
--,ptr006.PTRImp
--,ptr006.HOAmt
--,ptr006.mLandAcre
,ptr006.PTRAmt
,ptr006.Remaining_Tax
,ptr006.ptrCreditAmt
,ptr006.mLand
,ptr006.mImp

, ISNULL(ass.AssessedValue_Land_wEx, 0) AS AssessedValue_Land_wEx
, ISNULL(ass.AssessedValue_Imp, 0) AS AssessedValue_Imp
, ISNULL(ass.AssessedValue_Total, 0) AS AssessedValue_Total

, CASE 
  WHEN (ISNULL(ptr006.mLand, 0) - ISNULL(ass.AssessedValue_Land_wEx, 0)) = 0 THEN 'OK'
  ELSE 'Check'
END AS 'Check_Land'

, CASE 
  WHEN (ISNULL(ptr006.mImp, 0) - ISNULL(ass.AssessedValue_Imp, 0)) = 0 THEN 'OK'
  ELSE 'Check'
END AS 'Check_Imp'


FROM CTE_PTR006 AS ptr006

LEFT JOIN CTE_Assessed AS ass
  ON ptr006.lrsn = ass.lrsn
  AND RowNumber = 1


--WHERE ptr006.parcel_id = 'B00000344955'


