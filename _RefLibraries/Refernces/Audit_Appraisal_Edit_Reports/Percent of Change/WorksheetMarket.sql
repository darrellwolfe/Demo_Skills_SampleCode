-- !preview conn=con

DECLARE @Certified_Year INT = '20230101';

SELECT DISTINCT
    p.lrsn AS [LRSN],
    TRIM(p.pin) AS [PIN], 
    TRIM(p.ain) AS [AIN], 
    CASE
      WHEN p.CostingMethod = 'C' THEN 'Cost'
      WHEN p.CostingMethod = 'I' THEN 'Income'
      ELSE 'Other'
    END AS [Pricing_Method],
    FORMAT(
      CASE
        WHEN p.CostingMethod = 'C' THEN r.land_mkt_val_cost
        WHEN p.CostingMethod = 'I' THEN r.land_mkt_val_inc
          ELSE NULL
    END,'C0') AS [Worksheet_Land_Value],
    FORMAT(
      CASE
        WHEN p.CostingMethod = 'C' THEN r.cost_value
        WHEN p.CostingMethod = 'I' THEN (r.income_value-r.land_mkt_val_inc)
          ELSE NULL
    END,'C0') AS [Worksheet_Imp_Value],
    FORMAT(
      CASE
        WHEN p.CostingMethod = 'C' THEN (r.cost_value+r.land_mkt_val_cost)
        WHEN p.CostingMethod = 'I' THEN r.income_value
          ELSE NULL
    END,'C0') AS [Worksheet_Total_Value] 

FROM TSBv_PARCELMASTER AS p
JOIN valuation AS v ON p.lrsn = v.lrsn
JOIN reconciliation AS r ON p.lrsn = r.lrsn
JOIN memos AS m ON m.lrsn = p.lrsn
  AND (m.memo_id = 'NC23'
    OR m.memo_id = 'NC24')
  AND p.EffStatus = 'A'
  AND r.date_cert = '0'
  AND v.eff_year = @Certified_Year