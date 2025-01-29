  
  
  
  --ACRES Calcs Legal, Site, Cat19 Waste, see CTE for details
  pmd.LegalAcres,
  CAST (1 AS int) AS [Site_1_Acre],
  c19.[Cat19Waste],

  CASE
    WHEN pmd.LegalAcres > 1
      THEN (((CAST(pmd.LegalAcres AS DECIMAL (10,2))) - (CAST(c19.[Cat19Waste] AS DECIMAL (10,2))))-1)
    ELSE 0
  END AS [Remaining_Acres],