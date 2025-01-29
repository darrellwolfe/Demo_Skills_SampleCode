/*

AsTxDBProd
GRM_Main

--These codes are from the CadRoll table for 2018
WHERE r.Id IN ('538', '539', '540', '541')

--These codes are from the CadRoll table for 2019
WHERE r.Id IN ('542', '543', '544', '545')

--These codes are from the CadRoll table for 2020
WHERE r.Id IN ('549', '548', '547', '546')

--These codes are from the CadRoll table for 2021
WHERE r.Id IN ('550', '551', '552', '553') 

CadastreTaxRollwithValues2022
--These codes are from the CadRoll table for 2022
WHERE r.Id IN ('558', '556', '555', '554') 
It looks like 557 was replaced by 558

--These codes are from the CadRoll table for 2023
Maybe ??????
WHERE r.Id IN ('559', '560', 'xxx', 'xxx') 
--2023 Annual and Real

--These codes are from the CadRoll table for 2024
Maybe ??????
WHERE r.Id IN ('xxx', 'xxx', 'xxx', 'xxx') 


*/





Select *
From CadValueTypeAmount_V













------------------------------------
-- Exploration Below
-----------------------------------

Select *
From CadValueTypeAmount_V


/*
Select
vta.Id,
vta.ValueTypeId,
vta.ValueAmount,
vta.CalculatedAmount,
vt.ValType,
vt.ValueChar,
vt.ValDesc




From 
ValueTypeAmount AS vta
--TaxCalcDetail
Join
ValueTypes AS vt ON vt.ValType=vta.ValueTypeId
Where vt.ValType LIKE '%455%'





Select 

tcd.RateValueType,
tcd.ValueAmount,
rvt.RelationType,
rvt.RateValueType,
rvt.SuppValuetype,
rvt.HOValueType,
rvt.BaseValueType,
rvt.IncrValueType,
rvt.AnnexValueType

From TaxCalcDetail AS tcd

Join TSB_AB_RateValueTypes AS rvt ON tcd.RateValueType = rvt.RateValueType




*/



SELECT 
r.Id AS [CadRollID], 
r.AssessmentYear, 
LTRIM(RTRIM(r.Descr)) AS [AssessmentRollType],
LTRIM(RTRIM(i.TAGDescr)) AS [TAG],
LTRIM(RTRIM(i.GeoCd)) AS [GEO],
LTRIM(RTRIM(i.pin)) AS [PIN], 
LTRIM(RTRIM(i.ain)) AS [AIN], 
--Join Values
tcd.RevObjId AS [LRSN],
tcd.TAGId,
tcd.TAFId,
tcd.TIFId,
tcd.SourceValueType,
tcd.RateValueType,
tcd.ValueAmount,
tcd.TaxRate,
tcd.Amount,
tcd.AmountType,
tcd.ValueTypeAmountId

--Let's do a RowNumber instead of max

FROM CadRoll AS r
JOIN CadLevel AS l ON r.Id = l.CadRollId
JOIN CadInv AS i ON l.Id = i.CadLevelId
JOIN TaxCalcDetail AS tcd ON tcd.CadInvId = i.Id
  AND i.RevObjId=tcd.RevObjId
--TaxCalcHeader.Id = TaxCalcDetail.TaxCalcHeaderId
--TaxCalcDetail.RevObjId = table.lrsn

--These codes are from the CadRoll table for 
-- 2023 Annual and Real
WHERE r.Id IN ('559', '560')
-- 'xxx', 'xxx') 

ORDER BY r.Id, i.GeoCd, i.PIN;





--------------------------
--Explore ValueTypes which I think is the Aumentum Valuation table. 
--------------------------

Select Distinct *
From ValueTypes
Order By ValDesc DESC

--------------------------
--Explore ValueTypes which I think is the Aumentum Valuation table. 
--------------------------

Select Distinct
ValType,
ValueChar,
ValDesc

From ValueTypes

Where ValDesc LIKE 'Net%'

GROUP BY
ValType,
ValueChar,
ValDesc

Order By ValDesc DESC


--------------------------
--Explore ValueTypes which I think is the Aumentum Valuation table. 
--------------------------


Select
tcd.RevObjId AS [LRSN],
tcd.TAGId,
tcd.TAFId,
tcd.TIFId,
tcd.SourceValueType,
tcd.RateValueType,
tcd.ValueTypeAmountId,
vt.ValType,
vt.ValueChar,
vt.ValDesc,
tcd.ValueAmount,
tcd.TaxRate,
tcd.Amount,
tcd.AmountType


From ValueTypes AS vt

ValueTypeAmount AS vta ON vt.id=vta.ValueTypeId


JOIN TaxCalcDetail AS tcd ON ValType.Id = tcd.ValueTypeAmountId









--------------------------
--Trail Run
--------------------------

-- !preview conn=con

-- SELECT * FROM information_schema.columns 
-- WHERE column_name LIKE '%Net Taxable%';

Select Distinct *
From TaxCalcDetailInst

/*

tcd.RevObjId AS [LRSN]
tcd.TADId
tcd.TAFId
tcd.TIFId
tcd.SourceValueType
tcd.RateValueType
tcd.ValueAmount
tcd.TaxRate
tcd.Amount
tcd.AmountType
tcd.ValueTypeAmountId

TaxCalcDetail AS tcd 

TaxCalcHeader.Id = TaxCalcDetail.TaxCalcHeaderId
TaxCalcDetail.CadInvId = CadInv.Id
TaxCalcDetail.RevObjId
--Should be LRSN


TaxCalcHeaderId








*/







/*

First Attempt, but 'valuation' is a ProVal table, not an Aumentum table.
SELECT 
r.Id AS [CadRollID], 
r.AssessmentYear, 
LTRIM(RTRIM(r.Descr)) AS [AssessmentRollType],
v.valuation_comment AS [Val Comment],
v.eff_year AS [Tax Year],
MAX(v.last_update) AS [Last Update],
LTRIM(RTRIM(i.TAGDescr)) AS [TAG],
LTRIM(RTRIM(i.GeoCd)) AS [GEO],
parcel.ClassCD AS [Property_ClassCD],
LTRIM(RTRIM(i.pin)) AS [PIN], 
LTRIM(RTRIM(i.ain)) AS [AIN], 
--Join Values
v.land_assess AS [Assessed Land],
v.imp_assess AS [Assessed Imp],
(v.imp_assess + v.land_assess) AS [Assessed Total Value]


FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN KCv_PARCELMASTER1 AS parcel ON TRIM(i.pin)=TRIM(parcel.pin)
JOIN valuation AS v ON parcel.lrsn = v.lrsn


--These codes are from the CadRoll table for 2023
WHERE r.Id IN ('559', '560')
-- 'xxx', 'xxx') 
-- 2023 Annual and Real
AND parcel.EffStatus = 'A' 
AND v.status = 'A' 
AND v.eff_year BETWEEN 20230101 AND 20231231

GROUP BY r.Id,
r.AssessmentYear,
r.Descr,
i.TAGDescr,
i.GeoCd,
parcel.ClassCD,
i.pin,
i.ain,
v.land_assess,
v.imp_assess,
(v.imp_assess + v.land_assess),
v.valuation_comment,
v.eff_year
ORDER BY r.Id, i.GeoCd, i.PIN;
*/