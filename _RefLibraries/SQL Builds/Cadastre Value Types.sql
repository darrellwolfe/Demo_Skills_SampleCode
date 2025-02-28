



SELECT DISTINCT 
vt.Id,
vt.ShortDescr,
vt.Descr
FROM ValueType AS vt

WHERE vt.Id = 109

/*
455	Net Tax Value	Net Taxable Value
109	Total Value	Total Value -- aka Assessed Value
320	Total Exemptions	Total Exemptions
105	PP Assessed	Personal Property Assessed
262	PPPAssessed	Personal Property Assessed Prorated

*/