
/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT
LTRIM(RTRIM(ClassCD)) AS [ClassCD]

FROM KCv_PARCELMASTER1 
WHERE EffStatus= 'A'
ORDER BY [ClassCD]

--Codes PCC (aka Property Class Codes, aka ClassCD)
Select 
tbl_element,
tbl_element_desc
From codes_table
Where code_status='A'
AND tbl_type_code IN ('pcc')


/*
Results
ClassCD
010 Operating Property
020 Commercial
022 Commercial 2
030 Industrial
032 Industrial 2
060 Transient
070 Commercial - Late
090 Exempt PPV
314- Rural ind tract
317- Rural ind sub
322- Ind city lot/tract
336- Ind Imp rural tract
339- Ind Imp rural subdiv
343- Ind Imp lot/tract in city
411- Recreational
413- Rural commercial tract
416- Rural commercial sub
421- Comm lot/tract in city
435- Com Imp rural tracts
438- Com Imp rural subdiv
441- Mixed Use Comm/Ind
442- Com Imp lot/tract in city
451- Comm-Ind imps leased land
512- Rural residential tract
515- Rural residential sub
520- Res lot/tract in city
525- Common areas
526- Residential condo
527- Commercial condo
534- Imp res rural tract
537- Imp res rural sub
541- Imp res lot/tract in city
546- MH personal property
548- NREV
549- Nrev on leased land
550- Res imps on leased land
555- Floathouse-Boathouse
565- MH in courts
667- Operating property
681- Exempt property


*/
