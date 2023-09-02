/*
AsTxDBProd
GRM_Main
--Filtered for 2022-2023
*/




SELECT 

parcel.lrsn,
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(a.appeal_id)) AS [AppealID],
apst.tbl_element_desc AS [AppealStatus],
apdt.tbl_element_desc AS [AppealDetermination],
a.year_appealed,
a.PetitionerName,
LTRIM(RTRIM(a.assignedto)) AS [AppraiserInitials],
parcel.ClassCD, 
parcel.DisplayName, 
parcel.SitusAddress, 
a.det_explanation,
FORMAT (a.lastupdate, 'dd/MM/yyyy ') as [LastUpdate],
a.Username,
a.chg_reason,
a.grounds,
a.prior_val AS [Cert Total Value],
(a.prior_val-a.prior_land) AS [Cert Imp],
a.prior_land AS [Cert Land],
a.stated_val AS [Pet. Stated Total Value],
(a.stated_val-a.stated_land) AS [Pet. Stated Imp],
a.stated_land AS [Pet. Stated Land],
a.new_val AS [New Total Value],
(a.new_val-a.land_value) AS [New Imp],
a.land_value AS [New Land],
a.land_use_val,
FORMAT (a.chg_date, 'dd/MM/yyyy ') as [ChangeDate],
FORMAT (a.file_date, 'dd/MM/yyyy ') as [FileDate],
FORMAT (a.hear_date, 'dd/MM/yyyy ') as [HearingDate],
FORMAT (a.final_date, 'dd/MM/yyyy ') as [FinalDate],
FORMAT (a.deter_date, 'dd/MM/yyyy ') as [DeterminationDate],
a.scheduler,
FORMAT (a.values_to_recon, 'dd/MM/yyyy ') as [Values To Reconsider Date],
a.det_req_review,
a.hear_room,
a.petition_to_state,
a.EligibleForPenalty,
a.app_res_cat,
a.local_grounds


FROM KCv_PARCELMASTER1 AS parcel
JOIN appeals AS a ON parcel.lrsn=a.lrsn
--Codes tables join on tbl_element and specify on tbl_type_code
--Appeal Determination Type
JOIN codes_table AS apdt ON a.det_type=apdt.tbl_element AND apdt.tbl_type_code='appealdeter'
--Appeal Status
JOIN codes_table AS apst ON a.appeal_status=apst.tbl_element AND apst.tbl_type_code='appealstatus'


WHERE parcel.EffStatus= 'A'
AND a.status='A'
AND a.year_appealed IN (2022, 2023)
--Filtered for 2022-2023

ORDER BY parcel.neighborhood;
