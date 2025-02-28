SELECT
  CASE
    WHEN nc.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN nc.neighborhood >= 6003 THEN 'District_6'
    WHEN nc.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN nc.neighborhood = 6001 THEN 'District_6'
    WHEN nc.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN nc.neighborhood >= 5003 THEN 'District_5'
    WHEN nc.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN nc.neighborhood = 5001 THEN 'District_5'
    WHEN nc.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN nc.neighborhood >= 4000 THEN 'District_4'
    WHEN nc.neighborhood >= 3000 THEN 'District_3'
    WHEN nc.neighborhood >= 2000 THEN 'District_2'
    WHEN nc.neighborhood >= 1021 THEN 'District_1'
    WHEN nc.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN nc.neighborhood >= 1001 THEN 'District_1'
    WHEN nc.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN nc.neighborhood >= 451 THEN 'Commercial'
    WHEN nc.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN nc.neighborhood >= 1 THEN 'Commercial'
    WHEN nc.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS [District],
  nc.neighborhood AS [GEO],
  nc.neigh_name AS [GEO_Name],
  nri.res_model_serial AS [Res_Model_#],
  nri.value_mod_default AS [Res_Default_Mod],
  nri.value_mod_other AS [Res_Other_Mod],
  nci.com_model_serial AS [Com_Model_#],
  nci.com_other_mod AS [Com_Other_Mod],
  nci.commercial_mod AS [Com_Comercial_Mod],
  nci.industrial_mod AS [Com_Industrial_Mod]
  

FROM neigh_control AS nc
FULL JOIN neigh_com_impr AS nci ON nc.neighborhood = nci.neighborhood
  AND nci.status = 'A'
FULL JOIN neigh_res_impr AS nri ON nc.neighborhood = nri.neighborhood
  AND nri.status = 'A'
  
WHERE nc.inactivate_date > '20240101'
  AND nc.neighborhood <> '0'