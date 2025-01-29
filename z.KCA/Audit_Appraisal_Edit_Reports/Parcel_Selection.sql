SELECT 
    p.neighborhood AS GEO,    
    p.lrsn AS LRSN,
    TRIM(p.AIN) AS AIN,
    TRIM(p.pin) AS PIN,
    TRIM(p.SitusAddress) AS Situs_Address,
    p.DisplayDescr AS Legal_Description,
    TRIM(p.DisplayName) AS Owner_Name,
    TRIM(p.ClassCd) AS PCC,
    p.CostingMethod AS Valuation_Method,
    p.LegalAcres AS Legal_Acres,
    ps.set_id AS Parcel_Set_Name

FROM TSBv_PARCELMASTER AS p
    FULL JOIN Parcel_Set AS ps ON p.lrsn = ps.lrsn

WHERE p.EffStatus = 'A'
    AND p.CostingMethod <> 'P'

ORDER BY p.AIN
;