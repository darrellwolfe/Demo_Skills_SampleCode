-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

DECLARE @LandModelId INT = '702023';

-- Parcel Master;

WITH

CTE_WorksheetMarketValues AS(
SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_inc AS Worksheet_Land_Market,
    (r.income_value - r.land_mkt_val_cost) AS Worksheet_Imp_Market,
    r.income_value AS Worksheet_Total_Market

FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status = 'W'
AND r.method = 'I' 
--AND r.land_model = @LandModelId

UNION ALL

SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_cost AS Worksheet_Land_Market,
    r.cost_value AS Worksheet_Imp_Market,
    (r.cost_value + r.land_mkt_val_cost) AS Worksheet_Total_Market
    
FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status='W'
AND r.method = 'C' 
--AND r.land_model = @LandModelId
--ORDER BY GEO, PIN;
)

Select *
From CTE_WorksheetMarketValues
Where lrsn = 70807

