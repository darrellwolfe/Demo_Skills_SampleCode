-- !preview conn=con
/*
AsTxDBProd
GRM_Main

Table follows pattern:
KCv_TAGLevyRate...
KCv_TAGLevyRate19a
KCv_TAGLevyRate20a
KCv_TAGLevyRate21a
KCv_TAGLevyRate22a

Therefore...
KCv_TAGLevyRate23a
KCv_TAGLevyRate24a
KCv_TAGLevyRate25a
KCv_TAGLevyRate26a
*/

SELECT DISTINCT
TRIM(TAGDescr) AS TAGDescr,
TRIM(SUBSTRING(TAGDescr, 1, 3) + '-' + SUBSTRING(TAGDescr, 4, 3)) AS TAG,
LevyRate

FROM KCv_TAGLevyRate22a -- Change to KCv_TAGLevyRate23a in Fall 2023
ORDER BY TAGDescr
