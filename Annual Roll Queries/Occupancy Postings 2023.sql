-- !preview conn=con

SELECT 
p.AIN,
p.neighborhood AS [GEO],
v.status,
v.last_update,
v.update_user_id,
v.imp_val,
v.land_market_val,
v.eff_year,
v.valuation_comment,
m.memo_text

FROM valuation AS v
JOIN TSBv_PARCELMASTER AS p ON v.lrsn = p.lrsn
JOIN memos AS m ON v.lrsn = m.lrsn
AND m.memo_id = 'NC23'
AND m.memo_line_number = '2'

WHERE (v.valuation_comment = '06- Occupancy'
  OR v.valuation_comment = '38- Subsequent Assessment')
AND v.eff_year LIKE '2023%'
AND v.status = 'A'

ORDER BY 
v.eff_year,
v.valuation_comment,
p.AIN
