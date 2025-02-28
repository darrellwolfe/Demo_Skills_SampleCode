
SELECT 
    p.lrsn AS [LRSN],
    TRIM(p.pin) AS [PIN], 
    TRIM(p.ain) AS [AIN], 
    p.neighborhood AS [GEO],
    TRIM(a.appeal_id) AS [Appeal_ID],
    apst.tbl_element_desc AS [Appeal_Status],
    apdt.tbl_element_desc AS [Appeal_Determination],
    a.year_appealed AS [Appeal_Year],
    a.PetitionerName AS [Apellant_Name],
    TRIM(a.assignedto) AS [Assigned_Appraiser],
    p.ClassCD AS [PCC], 
    FORMAT (a.lastupdate, 'MM/dd/yyyy') AS [Last_Update],
    a.Username AS [Last_Update_User],
    a.local_grounds AS [Verbal_Written],  
    a.grounds AS [Appeal_Type],
    
    a.prior_land AS [Cert_Land],
    (a.prior_val-a.prior_land) AS [Cert_Imp],
    a.prior_val AS [Cert_Total_Value],
   
    a.stated_land AS [Apellant_Stated_Land],
    (a.stated_val-a.stated_land) AS [Apellant_Stated_Imp],
    a.stated_val AS [Apellant_Stated_Total_Value],
    
    a.land_value AS [Determined_Land],    
    (a.new_val-a.land_value) AS [Determined_Imp],
    a.new_val AS [Determined_Total_Value],
    a.det_type,
    FORMAT (a.file_date, 'MM/dd/yyyy') AS [Filed_with_Clerk_Date],    
    FORMAT (a.chg_date, 'MM/dd/yyyy') AS [Sent_to_Board_Date],
    FORMAT (a.hear_date, 'MM/dd/yyyy') AS [Hearing_Date],
    FORMAT (a.final_date, 'MM/dd/yyyy') AS [Determination_Date],
    FORMAT (a.deter_date, 'MM/dd/yyyy') AS [Revalued_Date]


FROM KCv_PARCELMASTER1 AS p
    JOIN appeals AS a ON p.lrsn=a.lrsn
    JOIN codes_table AS apdt ON a.det_type=apdt.tbl_element 
        AND apdt.tbl_type_code='appealdeter'
    JOIN codes_table AS apst ON a.appeal_status=apst.tbl_element 
        AND apst.tbl_type_code='appealstatus'

WHERE p.EffStatus= 'A'
    AND a.status='A'
    AND a.year_appealed = '2024'
    AND apst.tbl_element_desc = 'Determined'
    AND apdt.tbl_element_desc IN ('BOE','SBTA')

ORDER BY Appeal_Determination
;
