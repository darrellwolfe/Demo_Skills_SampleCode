


Select 
y.AIN,
y.PIN,
y.DisplayDescr_freeform,
RTRIM(y.TIF_ShortDescr) As From_TIF,
RTRIM(y.TIF_Descr) As From_TIF_Descr,
RTRIM(y.RP_TIF_ShortDescr) As To_TIF,
RTRIM(y.RP_TIF_Descr) As To_TIF_Descr,
y.RP_AIN,
y.RP_EffStatus,
y.RP_PIN,
y.RP_DisplayDescr_freeform 

From
  (
  Select z.*
  From
    (
    Select *
    From KC_MAP_pp2real_v
    Where  tif_descr <> RP_Tif_descr
    And EffStatus = 'a'
    )AS z
  Where z.RP_PIN <> 'No_ref'
  ) AS y
