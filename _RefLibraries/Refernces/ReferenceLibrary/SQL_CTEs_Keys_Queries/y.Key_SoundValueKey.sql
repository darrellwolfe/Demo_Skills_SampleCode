  CASE
    WHEN i.sound_value_code = '-1' THEN 'Pricing Error'
    WHEN i.sound_value_code = '1' THEN 'Base Rate'
    WHEN i.sound_value_code = '2' THEN 'Adjusted Rate'
    WHEN i.sound_value_code = '3' THEN 'Replacement Rate'
    WHEN i.sound_value_code = '4' THEN 'True Tax'
    WHEN i.sound_value_code = '5' THEN 'No Value'
    WHEN i.sound_value_code = '6' THEN 'Override'
    ELSE NULL
  END AS Sound_Value_Code,