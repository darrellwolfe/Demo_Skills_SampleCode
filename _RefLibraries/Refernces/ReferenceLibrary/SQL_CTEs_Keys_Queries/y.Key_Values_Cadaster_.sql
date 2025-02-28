
/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())

*/



------------
--CadViewer
------------

Select
pm.lrsn,
pm.pin,
pm.AIN,
pm.PropClassDescr,
pm.neighborhood,
pm.NeighborHoodName,
pm.TAG,
pm.DisplayName,
pm.SitusAddress,
pm.SitusCity,
pm.LegalAcres,
pm.TotalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total,
pm.CostingMethod,
cv.RevObjId,
cv.PIN,
cv.AIN,
cv.ClassCd,
cv.TAGShortDescr,
cv.TAGYear,
cv.AssessmentYear,
cv.CadRollDescr,
cv.RollLevel,
cv.ValueAmount,
cv.CalculatedAmount,
cv.FormattedValueAmount,
cv.ValueTypeShortDescr,
cv.ValueTypeDescr

From TSBv_PARCELMASTER AS pm
Join CadValueTypeAmount_V AS cv ON pm.lrsn = cv.RevObjId

WHERE cv.AssessmentYear IN ('2023','2022','2021','2020','2019','2018')
AND pm.EffStatus = 'A'

Order By cv.ValueTypeDescr 




/*
SELECT 
r.Id, r.AssessmentYear, r.Descr AS AssessmentType,
l.Id, l.CadRollId, l.RollLevel,
i.Id, i.EffStatus, i.TranId, i.CadLevelId, i.RevObjEffStatus, i.PIN, i.AIN, i.GeoCd, i.TAGDescr AS TAG
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId

Select *
From CadRoll
Order by Id DESC

Select *
From CadLevel
Order by CreateLevelDate DESC, LastBuildDate DESC

Select *
From CadInv
Order by CreateLevelDate DESC, LastBuildDate DESC

SELECT 
*
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId

SELECT 
*
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId

Select *
From CadValueTypeAmount_V AS cv
Where cv.AssessmentYear IN ('2023')
    --,'2022','2021','2020','2019','2018')


*/
/*
SELECT 
r.Descr,
l.RollLevel,
l.LevelStatus,
i.TAGId,
i.TAGShortDescr,
i.TaxType,
i.ClassCd,
cv.AssessmentYear,
cv.CadRollId,
cv.CadLevelId,
cv.CadInvId,
cv.RevObjId,
cv.PIN,
cv.AIN,
cv.LevelStatus,
cv.ClassCd,
cv.AddlAttribute,
cv.ValueTypeShortDescr,
cv.ValueTypeDescr,
cv.ValueAmount

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN CadValueTypeAmount_V AS cv
  ON r.Id = cv.CadRollId
  AND l.Id = cv.CadLevelId
  AND i.Id = cv.CadInvId
  AND cv.AssessmentYear IN ('2023')
    --,'2022','2021','2020','2019','2018')


Order By cv.RevObjId


SELECT 
r.Descr,
l.RollLevel,
l.LevelStatus,
i.TAGId,
i.TAGShortDescr,
i.TaxType,
i.ClassCd,
cv.AssessmentYear,
cv.CadRollId,
cv.CadLevelId,
cv.CadInvId,
cv.RevObjId,
cv.PIN,
cv.AIN,
cv.LevelStatus,
cv.ClassCd,
cv.AddlAttribute,
cv.ValueTypeShortDescr,
cv.ValueTypeDescr,
cv.ValueAmount

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN CadValueTypeAmount_V AS cv
  ON r.Id = cv.CadRollId
  AND l.Id = cv.CadLevelId
  AND i.Id = cv.CadInvId
  AND cv.AssessmentYear IN ('2010')
    --,'2022','2021','2020','2019','2018')
  AND cv.ValueTypeShortDescr = 'AssessedByCat'

Order By cv.RevObjId

*/