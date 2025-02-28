-- !preview conn=conn

/*

-- WHAT IS A cbtyp from the codes_table joined to??
--EXAMPLE: cbtyp       70          Health, Dental Office    
--code        cbtyp       Commercial Building Types     
-- code        grades      Grade Factors for Quality     
--if you use "code" as the tbl_type_code you get a list of what each code is for!! 


To pull all option use
SELECT *
FROM codes_table

To pull specific sub tales(s), use the sytax:
WHERE tbl_type_code= 'SpecificSubtableHere'
Examples:
WHERE code_status= 'A'(only active codes)
WHERE tbl_type_code= 'siterating'
WHERE tbl_type_code= 'siterating' OR tbl_type_code= 'fieldvisit'

Common Options
'siterating'
'fieldvisit'
'impgroup'
'lcmshortdesc' (aka Legends)
'pcc'
'memo'
'mhmake', 'mhmodel', 'mhpark'
'permits'
'pcc' (aka allocation)
'occupancy'
'appealdedtyp'
'appealdeter'
'appealstatus'

Multiple
SELECT c.tbl_type_code AS CodeType, c.tbl_element AS Code#, c.tbl_element_desc AS CodeDescription
FROM codes_table AS c
WHERE c.code_status= 'A' AND c.tbl_type_code IN ('appealdedtyp', 'appealdeter', 'appealstatus')
ORDER BY CodeDescription;

LEFT OUTER JOIN codes_table AS ct ON mh.mh_make=ct.tbl_element AND ct.tbl_type_code='mhmake'



-- Join a to c
Join codes_table AS c
  On a.group_code = c.tbl_element
  And c.code_status = 'A' 
  And tbl_type_code= 'impgroup'
  --c.tbl_type_code AS CodeType
  --c.tbl_element AS Group_Code, 
  --c.tbl_element_desc AS CodeDescription
  
  
*/

SELECT c.tbl_type_code AS CodeType, c.tbl_element AS Group_Code, c.tbl_element_desc AS CodeDescription
FROM codes_table AS c

WHERE code_status= 'A' 
AND tbl_type_code= 'impgroup'
--'lcmshortdesc' (aka Legends)
  And c.code_status = 'A' 

ORDER BY CodeDescription
