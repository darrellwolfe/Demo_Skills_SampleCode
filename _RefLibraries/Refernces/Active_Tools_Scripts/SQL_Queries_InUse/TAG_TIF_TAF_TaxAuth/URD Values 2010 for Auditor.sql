
Select
v.lrsn,
v.eff_year,
v.valuation_comment,
--Assessed (after timber exemptions)
v.land_assess,
v.imp_assess,
v.land_assess+v.imp_assess AS [Total Assessed],

--Certified (before timber exemptions)
v.land_market_val,
v.imp_val,
v.land_market_val+v.imp_val AS [Total Certified],

v.last_update


From valuation AS v

Where v.status = 'A'
  And v.eff_year = '20100101'
--TaxAuthority
