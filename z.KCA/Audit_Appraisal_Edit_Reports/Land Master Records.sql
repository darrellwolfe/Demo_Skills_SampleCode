DECLARE @NewModelYear INT = '702024';

SELECT
  lve.neighborhood AS [GEO],
  CASE
    WHEN lve.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN lve.neighborhood >= 6003 THEN 'District_6'
    WHEN lve.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN lve.neighborhood = 6001 THEN 'District_6'
    WHEN lve.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN lve.neighborhood >= 5003 THEN 'District_5'
    WHEN lve.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN lve.neighborhood = 5001 THEN 'District_5'
    WHEN lve.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN lve.neighborhood >= 4000 THEN 'District_4'
    WHEN lve.neighborhood >= 3000 THEN 'District_3'
    WHEN lve.neighborhood >= 2000 THEN 'District_2'
    WHEN lve.neighborhood >= 1021 THEN 'District_1'
    WHEN lve.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN lve.neighborhood >= 1001 THEN 'District_1'
    WHEN lve.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN lve.neighborhood >= 451 THEN 'Commercial'
    WHEN lve.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN lve.neighborhood >= 1 THEN 'Commercial'
    WHEN lve.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS [District],
  nc.neigh_name AS [GEO_Name],
  lve.land_type AS [Land_Type],
  lt.land_type_desc AS [Land_Type_Descr],
  lve.lcm AS [Pricing_Method],
  lm.method_desc AS [Pricing_Method_Descr],
  lve.df1 AS [Legend_1],
  lve.df2 AS [Legend_2],
  lve.df3 AS [Legend_3],
  lve.df4 AS [Legend_4],
  lve.df5 AS [Legend_5],
  lve.df6 AS [Legend_6],
  lve.df7 AS [Legend_7],
  lve.df8 AS [Legend_8],
  lve.df9 AS [Legend_9],
  lve.df10 AS [Legend_10],
  lve.df11 AS [Legend_11],
  lve.df12 AS [Legend_12],
  lve.df13 AS [Legend_13],
  lve.df14 AS [Legend_14],
  lve.df15 AS [Legend_15],
  lve.df16 AS [Legend_16],
  lve.df17 AS [Legend_17],
  lve.df18 AS [Legend_18],
  lve.df19 AS [Legend_19],
  lve.df20 AS [Legend_20],
  lve.df21 AS [Legend_21]

FROM land_methods AS lm
  JOIN land_val_element AS lve ON lm.method_number = lve.lcm
    AND lve.model_ser_numb = @NewModelYear
    AND lve.land_ve_status = 'A'
  JOIN land_types AS lt ON lve.land_type = lt.land_type
  JOIN neigh_control AS nc ON lve.neighborhood = nc.neighborhood
    AND nc.inactivate_date = '99991231'
    AND nc.neighborhood <> '0'

ORDER BY
  nc.neighborhood ASC