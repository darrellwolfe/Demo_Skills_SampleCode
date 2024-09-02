-- !preview conn=conn


--CTE_LandDetailsRemAcre AS (
SELECT
lh.RevObjId AS [lrsn]
,ld.LandDetailType
,ld.lcm
,ld.LandType
,ld.LDAcres
,ld.BaseRate

--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND ld.PostingSource='A'
  AND lh.PostingSource=ld.PostingSource
LEFT JOIN codes_table AS sr ON ld.SiteRating = sr.tbl_element
    AND sr.tbl_type_code='siterating  '

WHERE ld.LandType IN ('91')
  AND ld.lcm IN ('3','30')
  AND lh.RevObjId = 532911

--)