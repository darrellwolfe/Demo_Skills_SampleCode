-- !preview conn=con
/*
SELECT *
From tsbv_cadastre AS C

Inner Join tsbv_TagTaxAuthority AS TTA
ON TTA.TAG = c.Tag
Inner Join TafRate AS TR
ON TR.RateValueType = C.ValueType AND TR.ChrgSubCd = 290093
Where C.taxyear = '2023' AND C.AIN = '107763' --AND C.TaxYear = TR.TaxYear
Order by 5

Select *
From TafRate
Where TaxYear = '2023' --AND TafID = 73
Order By TafID
*/

 Select *
FROM TSBv_TagTaxAuthority AS TA
Inner Join Tsbv_Taf AS TF
ON TF.TaxAuthorityID = TA.TaxAuthorityId
/*
Inner Join TSBV_Cadastre AS TC
ON TC.TAG = TA.TAG
*/
Inner Join Tafrate AS TR
ON TR.TAFId = TF.Id AND TR.TaxYear = '2023'
Where TA.Tag = '156000' AND TF.EffStatus = 'A' AND TR.ChrgSubCd = '290093'
Order By TA.TaxAuthorityId
