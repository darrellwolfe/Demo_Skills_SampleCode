-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT 
val_year
,val_field
,val_element
,CASE
  WHEN LEFT(TRIM(val_element), 6) = 'MHOMED' THEN 'Single'
  WHEN LEFT(TRIM(val_element), 6) = 'MHOMES' THEN 'Double'
  WHEN LEFT(TRIM(val_element), 6) = 'MHOMET' THEN 'Triple'
  ELSE NULL
END AS MH_Type

,CASE
  WHEN RIGHT(TRIM(val_element), 1) = '2' THEN 'Low'
  WHEN RIGHT(TRIM(val_element), 1) = '3' THEN 'Fair'
  WHEN RIGHT(TRIM(val_element), 1) = '4' THEN 'Average'
  WHEN RIGHT(TRIM(val_element), 1) = '5' THEN 'Good'
  WHEN RIGHT(TRIM(val_element), 1) = '6' THEN 'Very_Good'
  WHEN RIGHT(TRIM(val_element), 1) = '7' THEN 'Excellent'
  ELSE NULL
END AS Grade

,df1 AS SF1
,(df2 * 0.01) AS Rate1
,df3 AS SF2
,(df4 * 0.01) AS Rate2
,df5 AS SF3
,(df6 * 0.01) AS Rate3
,df7 AS SF4
,(df8 * 0.01) AS Rate4
,df9 AS SF5
,(df10 * 0.01) AS Rate5
,df11 AS SF6
,(df12 * 0.01) AS Rate6
,df13 AS SF7
,(df14 * 0.01) AS Rate7
,df15 AS SF8
,(df16 * 0.01) AS Rate8
,df17 AS SF9
,(df18 * 0.01) AS Rate9
,df19 AS SF10
,(df20 * 0.01) AS Rate10
,df21 AS SF11
,(df22 * 0.01) AS Rate11
,df23 AS SF12
,(df24 * 0.01) AS Rate12
,df25 AS SF13
,(df26 * 0.01) AS Rate13
,df27 AS SF14
,(df28 * 0.01) AS Rate14

FROM val_element_table 
WHERE val_year = 2023
AND val_element LIKE 'MHOME%'
AND val_sub_element = 'base'
ORDER BY 1, 2;
