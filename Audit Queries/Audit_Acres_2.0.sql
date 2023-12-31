-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

View all four acre categories
Look for Legal acres not matching Market Acres or Land Base (Aggregate Acres).

*/

SELECT DISTINCT
parcel.lrsn
,TRIM(parcel.pin) AS PIN
,TRIM(parcel.ain) AS AIN
,parcel.neighborhood AS GEO
,parcel.Acres AS LegalAcres
,lh.TotalMktAcreage
,lh.TotalUseAcreage
,ag.AggregateSize AS LandBase_FarmTotal
-- Add a calculated column named 'CalculatedAcres' to the 'parcel' table
,(parcel.Acres - lh.TotalMktAcreage) AS LegalAcres_vs_MarketAcres
,(parcel.Acres - ag.AggregateSize) AS LegalAcres_vs_LandBase
,lh.LandModelId
,lh.NbhdWhenPriced
,CONVERT(VARCHAR, lh.LastUpdate, 101) AS LastUpdate


FROM KCv_PARCELMASTER1 AS parcel

JOIN LandHeader AS lh ON parcel.lrsn=lh.RevObjId 
    AND lh.EffStatus='A' 
    AND lh.PostingSource='A'
-- Filter the LandModelId by the current (or desired) LandModel 702023 is TaxYear 2023
    AND lh.LandModelId='702023'

JOIN LBAggregateSize AS ag ON lh.Id=ag.LandHeaderId 
      AND ag.EffStatus='A'
      AND ag.PostingSource='A'


WHERE parcel.EffStatus= 'A'
-- Filter the calculated columns to only include instances where one of the three is not a 0 or null.
AND ((parcel.Acres - lh.TotalMktAcreage) <> 0 AND (parcel.Acres - lh.TotalMktAcreage) IS NOT NULL)
AND ((parcel.Acres - ag.AggregateSize) <> 0 AND (parcel.Acres - ag.AggregateSize) IS NOT NULL)

ORDER BY GEO, PIN;
