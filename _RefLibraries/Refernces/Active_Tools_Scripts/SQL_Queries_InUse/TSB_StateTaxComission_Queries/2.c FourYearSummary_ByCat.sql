-- Connection: conn=conn
/*
AsTxDBProd
GRM_Main

---------
-- Select All
---------
Select Distinct *
From TSBv_PARCELMASTER as pm
Where pm.EffStatus = 'A'

I ran this one script in Power Query,
then used it as a reference "ref" to build the individual buckets

-- To Find Cadaster Types
Select Distinct
    vt.id,
    vt.ShortDescr,
    vt.Descr
From ValueType as vt
-- Where vt.Descr like '%by%'
Order by vt.Descr;
*/

Declare @Year int = 2024; -- Input THIS year here

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrev2 int = @Year - 2; -- Input the year here
Declare @YearPrev3 int = @Year - 3; -- Input the year here
Declare @YearPrev4 int = @Year - 4; -- Input the year here
Declare @YearPrev5 int = @Year - 5; -- Input the year here

Declare @EffYear0101Current varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous2 varchar(8) = Cast(@YearPrev2 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous3 varchar(8) = Cast(@YearPrev3 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous4 varchar(8) = Cast(@YearPrev4 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous5 varchar(8) = Cast(@YearPrev5 as varchar) + '0101'; -- Generates '20230101' for the previous year

Declare @ValEffDateCurrent date = Cast(Cast(@Year as varchar) + '-01-01' as date); -- Generates '2023-01-01' for the current year
Declare @ValEffDatePrevious date = Cast(Cast(@YearPrev as varchar) + '-01-01' as date); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious2 date = Cast(Cast(@YearPrev2 as varchar) + '-01-01' as date); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious3 date = Cast(Cast(@YearPrev3 as varchar) + '-01-01' as date); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious4 date = Cast(Cast(@YearPrev4 as varchar) + '-01-01' as date); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious5 date = Cast(Cast(@YearPrev5 as varchar) + '-01-01' as date); -- Generates '2022-01-01' for the previous year

Declare @EffYearLike varchar(8) = Cast(@Year as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious2 varchar(8) = Cast(@YearPrev2 as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious3 varchar(8) = Cast(@YearPrev3 as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious4 varchar(8) = Cast(@YearPrev4 as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious5 varchar(8) = Cast(@YearPrev5 as varchar) + '%'; -- Generates '2023%' for the previous year

Declare @ValueTypehoex int = 305;
-- 305 HOEX_Exemption Homeowner Exemption
Declare @ValueTypeimp int = 103;
-- 103 Imp Assessed Improvement Assessed
Declare @ValueTypeland int = 102;
-- 102 Land Assessed Land Assessed
Declare @ValueTypetotal int = 109;
-- 109 Total Value Total Value
Declare @NetTaxableValueImpOnly int = 458;
-- 458 Net Imp Only Net Taxable Value Imp Only
Declare @NetTaxableValueTotal int = 455;
-- 455 Net Tax Value Net Taxable Value
Declare @NewConstruction int = 651;
-- 651 NewConstByCat New Construction
Declare @AssessedByCat int = 470;
-- 470 AssessedByCat Assessed Value

With 

CTE_AssessedByCat_Current as (
    Select Distinct
        r.AssessmentYear,
        Trim(c.FullGroupCode) as FullGroupCode,
        Sum(c.ValueAmount) as Cadaster_Value
    From CadRoll r
    Join CadLevel l on r.Id = l.CadRollId
    Join CadInv i on l.Id = i.CadLevelId
    Join tsbv_cadastre as c 
        On c.CadRollId = r.Id
        And c.CadInvId = i.Id
        And c.ValueType = @AssessedByCat
    Where r.AssessmentYear in (@Year)
        And Cast(i.ValEffDate as date) = @ValEffDateCurrent
    Group by r.AssessmentYear, c.FullGroupCode
),

CTE_AssessedByCat_Previous as (
    Select Distinct
        r.AssessmentYear,
        Trim(c.FullGroupCode) as FullGroupCode,
        Sum(c.ValueAmount) as Cadaster_Value
    From CadRoll r
    Join CadLevel l on r.Id = l.CadRollId
    Join CadInv i on l.Id = i.CadLevelId
    Join tsbv_cadastre as c 
        On c.CadRollId = r.Id
        And c.CadInvId = i.Id
        And c.ValueType = @AssessedByCat
    Where r.AssessmentYear in (@YearPrev)
        And Cast(i.ValEffDate as date) = @EffYear0101Previous
    Group by r.AssessmentYear, c.FullGroupCode
),

CTE_AssessedByCat_Previous2 as (
    Select Distinct
        r.AssessmentYear,
        Trim(c.FullGroupCode) as FullGroupCode,
        Sum(c.ValueAmount) as Cadaster_Value
    From CadRoll r
    Join CadLevel l on r.Id = l.CadRollId
    Join CadInv i on l.Id = i.CadLevelId
    Join tsbv_cadastre as c 
        On c.CadRollId = r.Id
        And c.CadInvId = i.Id
        And c.ValueType = @AssessedByCat
    Where r.AssessmentYear in (@YearPrev2)
        And Cast(i.ValEffDate as date) = @EffYear0101Previous2
    Group by r.AssessmentYear, c.FullGroupCode
),

CTE_AssessedByCat_Previous3 as (
    Select Distinct
        r.AssessmentYear,
        Trim(c.FullGroupCode) as FullGroupCode,
        Sum(c.ValueAmount) as Cadaster_Value
    From CadRoll r
    Join CadLevel l on r.Id = l.CadRollId
    Join CadInv i on l.Id = i.CadLevelId
    Join tsbv_cadastre as c 
        On c.CadRollId = r.Id
        And c.CadInvId = i.Id
        And c.ValueType = @AssessedByCat
    Where r.AssessmentYear in (@YearPrev3)
        And Cast(i.ValEffDate as date) = @EffYear0101Previous3
    Group by r.AssessmentYear, c.FullGroupCode
),

CTE_AllocationsGroupCodeKey as (
    Select 
        c.tbl_type_code as CodeType,
        Trim(c.tbl_element) as GroupCode_KC,
        Left(Trim(c.tbl_element),2) as GroupCode_STC,
        Trim(c.tbl_element_desc) as CodeDescription,
        Case 
            When Trim(c.tbl_element_desc) like '%EXEMPT%' then 'Exempt_Property'
            When Trim(c.tbl_element_desc) like '%OPERATING%' then 'Operating_Property'
            When Trim(c.tbl_element_desc) like '%QIE%' then 'Qualified_Improvement_Expenditure'
            When Trim(c.tbl_element) like '%P%' then 'Business_Personal_Property'
            When Left(Trim(c.tbl_element),2) in ('98','99') then 'Non-Allocated_Error'
            When Left(Trim(c.tbl_element),2) in ('25','26','27') then 'Condos'
            When Left(Trim(c.tbl_element),2) in ('81') then 'Exempt_Property'
            When Left(Trim(c.tbl_element),2) in ('19') then 'RightOfWay_ROW_Cat19'
            When Left(Trim(c.tbl_element),2) in ('49','50','51') then 'Imp_On_LeasedLand'
            When Left(Trim(c.tbl_element),2) in ('45') then 'Operating_Property'
            When Left(Trim(c.tbl_element),2) in ('12','15','20','34','37','41') then 'Residential'
            When Left(Trim(c.tbl_element),2) in ('30','31','32') then 'Non-Res'
            When Left(Trim(c.tbl_element),2) in ('13','16','21','35','38','42','14','17','22','36','39','43') then 'Commercial_Industrial'
            When Left(Trim(c.tbl_element),2) in ('46','47','48','55','65') then 'Mobile_Home'
            When Left(Trim(c.tbl_element),2) in ('01','03','04','05','06','07','08','09','10','11','33') then 'Timber_Ag'
            Else 'Other'
        End as Category,
        Case
            When Trim(c.tbl_element) in ('25', '26', '26H', '27', '30', '31H', '32', '33', '34H', '35', '36', '37H', '38', '39', '41H', '42', '43', '45', '46H', '47H', '48H', '49H', '50H', '51', '51P', '55H', '56P', '56Q', '56Q2', '56Q3', '57P', '58P', '58Q', '58Q2', '58Q3', '58Q4', '59P', '59Q', '59Q2', '59Q3', '59Q4', '63P', '63Q', '63Q2', '63Q3', '63Q4', '65H', '66P', '67', '67L', '67P', '68P', '68Q', '68Q2', '68Q3', '68Q4', '69P', '69Q', '69Q2', '69Q3', '69Q4', '70P', '71P', '71Q', '71Q2', '71Q3', '71Q4', '72P', '72Q', '72Q2', '72Q3', '72Q4', '75P', '81', '81P') then 'GC_Improvement'
            When Trim(c.tbl_element) in ('01', '03', '04', '05', '06', '07', '09', '10', '10H', '11', '12', '12H', '13', '14', '15', '15H', '16', '17', '18', '19', '20', '20H', '21', '22', '25L', '26LH', '27L', '81L') then 'GC_Land'
            Else 'OtherCode'
        End as CodeClass
    From codes_table as c
    Where c.tbl_type_code = 'impgroup'
)

Select 
    '28' as KootenaiCounty,
    c.FullGroupCode as FullGroupCodeCurrent,
    k.CodeDescription,
    k.Category,
    k.CodeClass,
    c.AssessmentYear as AssessmentYearCurrent,
    c.Cadaster_Value as CurrentYearValue,
    p.FullGroupCode as FullGroupCodePrevious,
    p.AssessmentYear as AssessmentYearPrevious,
    p.Cadaster_Value as PastYearValue,
    (c.Cadaster_Value - p.Cadaster_Value) as ValueChange,
    (Cast(c.Cadaster_Value as decimal(18,2)) / NULLIF(Cast(p.Cadaster_Value as decimal(18,2)), 0)) as PerfOfChange,
    p2.FullGroupCode as FullGroupCodePrevious2,
    p2.AssessmentYear as AssessmentYearPrevious2,
    p2.Cadaster_Value as PastYearValue2,
    (p.Cadaster_Value - p2.Cadaster_Value) as ValueChange_2_3,
    (Cast(p.Cadaster_Value as decimal(18,2)) / NULLIF(Cast(p2.Cadaster_Value as decimal(18,2)), 0)) as PerfOfChange_2_3,
    p3.FullGroupCode as FullGroupCodePrevious3,
    p3.AssessmentYear as AssessmentYearPrevious3,
    p3.Cadaster_Value as PastYearValue3,
    (p2.Cadaster_Value - p3.Cadaster_Value) as ValueChange_3_4,
    (Cast(p2.Cadaster_Value as decimal(18,2)) / NULLIF(Cast(p3.Cadaster_Value as decimal(18,2)), 0)) as PerfOfChange_3_4
From CTE_AssessedByCat_Current as c
Full Outer Join CTE_AssessedByCat_Previous as p
    On c.FullGroupCode = p.FullGroupCode
Full Outer Join CTE_AssessedByCat_Previous2 as p2
    On c.FullGroupCode = p2.FullGroupCode
Full Outer Join CTE_AssessedByCat_Previous3 as p3
    On c.FullGroupCode = p3.FullGroupCode
Left Join CTE_AllocationsGroupCodeKey as k
    On k.GroupCode_KC = c.FullGroupCode
