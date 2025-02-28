-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

---------
--Select All
---------
Select Distinct *
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

[KCfx_RPPPAnnualCadExport_c]
[KCfx_CadExport_a_all]
[KCfx_A_TAGTANSList]
[KCfx_RPAnnualCadExport_c]
[KCfx_NewConstBuild]
[KCfx_A_TAGTA_PIN_HOValue]
[KCfx_bkp_tatotals]
[KCfx_TaxAuthority_a]
[KCfx_a_tagtaNewConst]
[KCfx_TagTaxAuthority_a]
[KCfx_a_tagtaLandUse]
[KCfx_a_tagtaannex]
[KCfx_a_tagtadeannex]
[KCfx_a_tagtaNonRes]
[KCfx_a_tagtaHB519]
[KCfx_A_TAGTAHB475]


*/


Select
sm.definition
,sm.object_id
,sm.uses_ansi_nulls
,sm.uses_quoted_identifier
,sm.is_schema_bound

From sys.sql_modules AS sm
Join sys.objects AS o On sm.object_id = o.object_id

Where o.name = 'KCfx_A_TAGTAHB475' 
And o.type In ('FN', 'IF', 'TF')  -- FN = Scalar function, IF = Inline table-valued function, TF = Multi-statement table-valued function

