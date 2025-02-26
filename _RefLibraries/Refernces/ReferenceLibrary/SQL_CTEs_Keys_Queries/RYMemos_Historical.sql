-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


---------------------------------------
--CTE Example with Variables
---------------------------------------

--FIRST Year of Reval Cycle
DECLARE @TaxYear INT = 2023; 
-- Current Tax Year -- Change this to the current tax year
DECLARE @MemoIDYear1 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@TaxYear AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear2 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@TaxYear+1 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear3 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@TaxYear+2 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear4 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@TaxYear+3 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear5 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@TaxYear+4 AS VARCHAR(4)), 2) AS VARCHAR(4));



---------------------------------------
--CTE
---------------------------------------

WITH

CTE_Memos_RY AS (
Select
m.lrsn
,m.memo_id AS RYYear

FROM memos AS m

WHERE m.memo_id LIKE '%RY%'
And m.memo_line_number = '1'
AND m.status = 'A'
)

Select *
From CTE_Memos_RY
















--Where lrsn = 3235
--Where RYYear LIKE '%24'
--And RY_Memos IS NULL
---------------------------------------
--List of Possible Memo IDs
--------------------------------------

/*
Memos should be pulled in by specific memos desired, normally.

Use the Memo ID, Memo Text, and Memo Line number as filters and selects

memo_id	memo_text
6023	63-602W(3) NEW CONSTRUSCTION
602W	63-602W(4) DEV LAND EX
ACC 	CONFIDENTIAL OWNERSHIP
APPR	ALERT
AR  	ASSESSMENT REVIEWS
AR03	2003 ASSESSMENT REVIEWS
B519	HB519
CELL	CELL TOWER INFORMATION
CHI 	COFFEE HUT INFORMATION
FF  	FRONTAGE INFORMATION
HOEX	APP TRACKING
IMP 	IMPROVEMENT INFORMATION                                          
IMp 	Improvement Information
LAND	LAND INFORMATION                                                 
LCA 	LOT CONSOLIDATION AGREEMENT
LIST	INFORMATION ONLY
LOC 	OPT-OUT DWELLING PERMIT
Land	Land Information
M   	MAINTENANCE                                                      
MH90	Mobile Home Conversion Other Info                                
MHM 	MOBILE HOME MODEL
MHPP	MOBILE HOME PRE-PAY
MINF	MOBILE INFORMATION
NC06	NEW CONSTRUCTION
NC07	2007 New Construction
NC08	NEW CONSTRUCTION 2008
NC09	2009 NEW CONSTRUCTION
NC10	2010 NEW CONSTRUCTION
NC11	2011 NEW CONSTRUCTION
NC12	2012 NEW CONSTRUCTION
NC13	2013 NEW CONSTRUCTION
NC14	2014 NEW CONSTRUCTION
NC15	2015 NEW CONSTRUCTION
NC16	2016 NEW CONSTRUCTION
NC17	2017 NEW CONSTRUCTION
NC18	2018 NEW CONSTRUCTION
NC19	2019 NEW CONSTRUCTION
NC20	2020 NEW CONSTRUCTION
NC21	2021 NEW CONSTRUCTION
NC22	2022 NEW CONSTRUCTION
NC23	2023 NEW CONSTRUCTION
NOTE	Internal Notes (Not Public)
OC01	Occupancy Jan 1-15
OC02	Occupancy Jan 16-Feb 15
OC03	Occupancy Feb 16-Mar 15
OC04	Occupancy Mar 16-Apr 15
OC05	Occupancy Apr 16-May 15
OC06	Occupancy May 16-Jun 15
OC07	Occupancy Jun 16-Jul 15
OC08	Occupancy Jul 16-Aug 15
OC09	Occupancy Aug 16-Sep 15
OC10	Occupancy Sep 16-Oct 15
OC11	Occupancy Oct 16-Nov 15
OC12	Occupancy Nov 16-Dec 15
PERM	Permit Notes
PO09	2009 Potential Occupancy                                         
PO10	2010 Potential Occupancy
PO13	
RY00	Reval
RY01	REVAL
RY02	REVAL
RY03	REVAL
RY04	REVAL                                                            
RY05	REVAL
RY06	REVAL
RY07	REVAL
RY08	REVAL
RY09	REVAL
RY10	REVAL
RY11	REVAL
RY12	REVAL
RY13	REVAL
RY14	REVAL
RY15	REVAL
RY16	REVAL
RY17	REVAL
RY18	REVAL
RY19	REVAL
RY20	REVAL
RY21	REVAL
RY22	REVAL
RY23	REVAL
RY99	REVAL
Ry00	Reval
SA  	SALES ANALYSIS
SAMH	SALES ANAYLSIS MH
T   	TIMBER
URD 	INFORMATION
URd 	Info                                                             
Z   	AG/TIMBER INFORMATION
ZS  	SOLID WASTE
imp 	Improvement Information
m   	Maintenance
minf	MOBILE HOME INFORMATION

*/

/*

lrsn	memo_id	memo_line_number	memo_text	last_update	status
0	IMP 	1	IMPROVEMENT INFORMATION                                          	10/20/2003 0:00	A

*/




/*

---------------------------------------
--Older Examples
---------------------------------------


memo_id	memo_text
NC23	2023 NEW CONSTRUCTION

--Simple Pull, either stand alone or as a CTE
Select
m.lrsn,
m.memo_id AS [MemoId],
m.memo_text AS [2023NewConstruction]

FROM memos AS m
WHERE m.memo_id='NC23'
AND m.status = 'A'

--Full Pull

SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
m.memo_id AS [MemoId],
m.memo_text AS [2023NewConstruction],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
LTRIM(RTRIM(parcel.TAG)) AS [TAG],
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity]


FROM KCv_PARCELMASTER1 AS parcel
JOIN memos AS m ON parcel.lrsn=m.lrsn

WHERE parcel.EffStatus= 'A'
AND m.memo_id='NC23'
AND m.memo_line_number='1'

ORDER BY parcel.neighborhood, parcel.pin;




--Reval Audit
SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
LTRIM(RTRIM(parcel.TAG)) AS [TAG],
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
--If exists, include
ry18.memo_text AS [RY18],
ry19.memo_text AS [RY19],
ry20.memo_text AS [RY20],
ry21.memo_text AS [RY21],
ry22.memo_text AS [RY22],
ry23.memo_text AS [RY23],
ry24.memo_text AS [RY24],
ry25.memo_text AS [RY25],
ry26.memo_text AS [RY26],
ry27.memo_text AS [RY27]

FROM KCv_PARCELMASTER1 AS parcel
--JOINS
LEFT JOIN memos AS ry18 ON ry18.lrsn=parcel.lrsn AND ry18.memo_id='RY18'AND ry18.memo_line_number='1'
LEFT JOIN memos AS ry19 ON ry19.lrsn=parcel.lrsn AND ry19.memo_id='RY19'AND ry19.memo_line_number='1'
LEFT JOIN memos AS ry20 ON ry20.lrsn=parcel.lrsn AND ry20.memo_id='RY20'AND ry20.memo_line_number='1'
LEFT JOIN memos AS ry21 ON ry21.lrsn=parcel.lrsn AND ry21.memo_id='RY21'AND ry21.memo_line_number='1'
LEFT JOIN memos AS ry22 ON ry22.lrsn=parcel.lrsn AND ry22.memo_id='RY22'AND ry22.memo_line_number='1'
LEFT JOIN memos AS ry23 ON ry23.lrsn=parcel.lrsn AND ry23.memo_id='RY23'AND ry23.memo_line_number='1'
LEFT JOIN memos AS ry24 ON ry24.lrsn=parcel.lrsn AND ry24.memo_id='RY24'AND ry24.memo_line_number='1'
LEFT JOIN memos AS ry25 ON ry25.lrsn=parcel.lrsn AND ry25.memo_id='RY25'AND ry25.memo_line_number='1'
LEFT JOIN memos AS ry26 ON ry26.lrsn=parcel.lrsn AND ry26.memo_id='RY26'AND ry26.memo_line_number='1'
LEFT JOIN memos AS ry27 ON ry27.lrsn=parcel.lrsn AND ry27.memo_id='RY27'AND ry27.memo_line_number='1'



--One INteresting UseCase Example is the "PermitsDetailed_NotCompleted.sql"

--NOTES, CONCAT allows one line of notes instead of duplicate rows

LTRIM(RTRIM(CONCAT(
m2.memo_text,
'.', 
m3.memo_text,
'.', 
m4.memo_text,
'.', 
m5.memo_text,
'.', 
m6.memo_text,
'.', 
m7.memo_text
))) AS [MemoText],

FROM KCv_PARCELMASTER1 AS parcel
JOIN permits AS p ON parcel.lrsn=p.lrsn
JOIN field_visit AS f ON p.field_number=f.field_number
LEFT JOIN memos AS m2 ON parcel.lrsn=m2.lrsn AND m2.memo_id = 'PERM' AND m2.memo_line_number = '2'
LEFT JOIN memos AS m3 ON parcel.lrsn=m3.lrsn AND m3.memo_id = 'PERM' AND m3.memo_line_number = '3'
LEFT JOIN memos AS m4 ON parcel.lrsn=m4.lrsn AND m4.memo_id = 'PERM' AND m4.memo_line_number = '4'
LEFT JOIN memos AS m5 ON parcel.lrsn=m2.lrsn AND m2.memo_id = 'PERM' AND m2.memo_line_number = '5'
LEFT JOIN memos AS m6 ON parcel.lrsn=m3.lrsn AND m3.memo_id = 'PERM' AND m3.memo_line_number = '6'
LEFT JOIN memos AS m7 ON parcel.lrsn=m4.lrsn AND m4.memo_id = 'PERM' AND m4.memo_line_number = '7'
LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'

*/





