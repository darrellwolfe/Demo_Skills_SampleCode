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

Declare @YearPrev int = @Year - 1; 
Declare @YearPrev2 int = @Year - 2; 
Declare @YearPrev3 int = @Year - 3; 
Declare @YearPrev4 int = @Year - 4; 
Declare @YearPrev5 int = @Year - 5; 

Declare @EffYear0101Current varchar(8) = Cast(@Year as varchar) + '0101'; 
Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; 
Declare @EffYear0101Previous2 varchar(8) = Cast(@YearPrev2 as varchar) + '0101'; 
Declare @EffYear0101Previous3 varchar(8) = Cast(@YearPrev3 as varchar) + '0101'; 
Declare @EffYear0101Previous4 varchar(8) = Cast(@YearPrev4 as varchar) + '0101'; 
Declare @EffYear0101Previous5 varchar(8) = Cast(@YearPrev5 as varchar) + '0101'; 

Declare @ValEffDateCurrent date = Cast(Cast(@Year as varchar) + '-01-01' as date); 
Declare @ValEffDatePrevious date = Cast(Cast(@YearPrev as varchar) + '-01-01' as date); 
Declare @ValEffDatePrevious2 date = Cast(Cast(@YearPrev2 as varchar) + '-01-01' as date); 
Declare @ValEffDatePrevious3 date = Cast(Cast(@YearPrev3 as varchar) + '-01-01' as date); 
Declare @ValEffDatePrevious4 date = Cast(Cast(@YearPrev4 as varchar) + '-01-01' as date); 
Declare @ValEffDatePrevious5 date = Cast(Cast(@YearPrev5 as varchar) + '-01-01' as date); 

Declare @EffYearLike varchar(8) = Cast(@Year as varchar) + '%'; 
Declare @EffYearLikePrevious varchar(8) = Cast(@YearPrev as varchar) + '%'; 
Declare @EffYearLikePrevious2 varchar(8) = Cast(@YearPrev2 as varchar) + '%'; 
Declare @EffYearLikePrevious3 varchar(8) = Cast(@YearPrev3 as varchar) + '%'; 
Declare @EffYearLikePrevious4 varchar(8) = Cast(@YearPrev4 as varchar) + '%'; 
Declare @EffYearLikePrevious5 varchar(8) = Cast(@YearPrev5 as varchar) + '%'; 

Declare @ValueTypehoex int = 305; 
Declare @ValueTypeimp int = 103; 
Declare @ValueTypeland int = 102; 
Declare @ValueTypetotal int = 109; 
Declare @NetTaxableValueImpOnly int = 458; 
Declare @NetTaxableValueTotal int = 455; 
Declare @NewConstruction int = 651; 
Declare @AssessedByCat int = 470; 

With 
CTE_AssessedByCat_Current as (
    Select Distinct
        i.RevObjId as lrsn,
        Trim(i.PIN) as PIN,
        Trim(i.AIN) as AIN,
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
    Group by i.RevObjId, i.PIN, i.AIN, r.AssessmentYear, c.FullGroupCode
),

CTE_AssessedByCat_Previous as (
    Select Distinct
        i.RevObjId as lrsn,
        Trim(i.PIN) as PIN,
        Trim(i.AIN) as AIN,
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
    Group by i.RevObjId, i.PIN, i.AIN, r.AssessmentYear, c.FullGroupCode
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
),

CTE_Districts as (
    Select Distinct
        Case
            When pm.neighborhood >= 9000 then 'Manufactured_Homes'
            When pm.neighborhood >= 6003 then 'District_6'
            When pm.neighborhood = 6002 then 'Manufactured_Homes'
            When pm.neighborhood = 6001 then 'District_6'
            When pm.neighborhood = 6000 then 'Manufactured_Homes'
            When pm.neighborhood >= 5003 then 'District_5'
            When pm.neighborhood = 5002 then 'Manufactured_Homes'
            When pm.neighborhood = 5001 then 'District_5'
            When pm.neighborhood = 5000 then 'Manufactured_Homes'
            When pm.neighborhood >= 4000 then 'District_4'
            When pm.neighborhood >= 3000 then 'District_3'
            When pm.neighborhood >= 2000 then 'District_2'
            When pm.neighborhood >= 1021 then 'District_1'
            When pm.neighborhood = 1020 then 'Manufactured_Homes'
            When pm.neighborhood >= 1001 then 'District_1'
            When pm.neighborhood = 1000 then 'Manufactured_Homes'
            When pm.neighborhood >= 451 then 'Commercial'
            When pm.neighborhood = 450 then 'Specialized_Cell_Towers'
            When pm.neighborhood >= 1 then 'Commercial'
            When pm.neighborhood = 0 then 'PP_N/A_or_Error'
            Else NULL
        End as District,
        pm.neighborhood as GEO,
        Trim(pm.NeighborHoodName) as GEO_Name,
        pm.lrsn
    From TSBv_PARCELMASTER as pm
)

Select 
    '28' as KootenaiCounty,
    d_c.District,
    d_c.GEO,
    d_c.GEO_Name,
    c.lrsn,
    c.PIN,
    c.AIN,
    c.FullGroupCode as FullGroupCodeCurrent,
    k.CodeDescription,
    k.Category,
    k.CodeClass,
    c.AssessmentYear as AssessmentYearCurrent,
    c.Cadaster_Value as CurrentYearValue,
    d_p.District,
    d_p.GEO,
    d_p.GEO_Name,
    p.AIN,
    p.PIN,
    p.FullGroupCode as FullGroupCodePrevious,
    p.AssessmentYear as AssessmentYearPrevious,
    p.Cadaster_Value as PastYearValue,
    (c.Cadaster_Value - p.Cadaster_Value) as ValueChange,
    (Cast(c.Cadaster_Value as decimal(18,2)) / NULLIF(Cast(p.Cadaster_Value as decimal(18,2)), 0)) as PerfOfChange
From CTE_AssessedByCat_Current as c
Left Join CTE_Districts as d_c
    On c.lrsn = d_c.lrsn
Full Outer Join CTE_AssessedByCat_Previous as p
    On c.lrsn = p.lrsn
    And c.FullGroupCode = p.FullGroupCode
Left Join CTE_Districts as d_p
    On p.lrsn = d_p.lrsn
Left Join CTE_AllocationsGroupCodeKey as k
    On k.GroupCode_KC = c.FullGroupCode
Order by d_c.District, d_c.GEO, c.PIN;
