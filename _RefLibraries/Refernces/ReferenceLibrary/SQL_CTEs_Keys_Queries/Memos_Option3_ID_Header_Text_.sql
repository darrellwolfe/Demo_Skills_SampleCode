DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year


DECLARE @Jan1ThisYear1 DATETIME = CONCAT(@Year, '-01-01 00:00:00');


WITH

CTE_Memos AS (
SELECT
m1.lrsn,
CONCAT(m1.memo_id, ' | ', m2.memo_text) AS MemoHeader,
STRING_AGG(m1.memo_text, ' , ') AS Memo_Text

FROM memos AS m1

JOIN memos AS m2
    ON m1.lrsn = m2.lrsn
    AND m1.memo_id = m2.memo_id
    AND m2.memo_line_number = 1
    AND m2.status = 'A'

WHERE m1.status = 'A'
AND (m1.memo_id IN ('IMP', 'LAND')
    OR m1.memo_id LIKE 'RY%')
AND m1.memo_line_number <> '1'
-- Use for restricting to specific time stamps
--AND m1.last_update >= @Jan1ThisYear1

GROUP BY m1.lrsn, m1.memo_id, m2.memo_text

)


Select Distinct * From CTE_Memos









/*
Memos should be pulled in by specific memos desired, normally.

Use the Memo ID, Memo Text, and Memo Line number as filters and selects



MOST Common:
memo_id	memo_text

IMP 	IMPROVEMENT INFORMATION                                          
LAND	LAND INFORMATION                                                 
SA  	SALES ANALYSIS
SAMH	SALES ANAYLSIS MH
T   	TIMBER
URD 	INFORMATION
CELL	CELL TOWER INFORMATION
CHI 	COFFEE HUT INFORMATION

Year Dependant: xx = year
NC23	2023 NEW CONSTRUCTION
NCxx	20xx NEW CONSTRUCTION
RY23	REVAL
RYxx	REVAL


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
