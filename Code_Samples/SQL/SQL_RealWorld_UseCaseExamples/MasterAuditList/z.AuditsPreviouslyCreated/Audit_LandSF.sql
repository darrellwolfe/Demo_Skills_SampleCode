-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

DECLARE @LandModel INT = '702023';


--WITH

--CTE_LandDetails AS (
  SELECT DISTINCT
--COUNT(lh.RevObjId)

lh.RevObjId
,ld.LandType
,TRIM (sr.tbl_element_desc) AS [Legend]
,lh.TotalSqrFeet


  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
  LEFT JOIN codes_table AS sr ON ld.SiteRating = sr.tbl_element
      AND sr.tbl_type_code='siterating'


  
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'

  --Change land model id for current year
    AND lh.LandModelId=@LandModel
    AND ld.LandModelId=@LandModel
    AND ld.LandType IN ('11','9','31','32')
    AND lh.TotalSqrFeet <= 0

Order by lh.RevObjId