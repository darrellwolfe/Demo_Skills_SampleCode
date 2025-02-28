-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

Select *
From improvements AS i
Where status = 'A'
--And imp_type = 'DWELL'
And i.ovrride_phys_depr = 1



/*

Select *
From improvements
Where imp_type = 'DWELL'
And status = 'A'
And grade = 15

Select *
From A_CVTAG_VIEW --- Does not run in 2023, written 2009

Select *
From improvements
Where lrsn = 37109
And status = 'A'

Select *
From improvements
Where status = 'A'

Select *
From improvements
Where status = 'A'
--And override_phy_depr > 1 -- does not work

Select *
From improvements
Where status = 'A'
And imp_type = 'DWELL'

Select *
From improvements AS i
Where status = 'A'
--And imp_type = 'DWELL'
And i.ovrride_phys_depr = 1


*/