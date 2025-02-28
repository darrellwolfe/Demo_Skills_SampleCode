-- !preview conn=con
SELECT
  ld.Id,
  ld.LandType AS [Land_Type],
  ld.lcm AS [Pricing_Method],
  CASE
    WHEN ld.SiteRating LIKE '1D' THEN 'No View' 
    WHEN ld.SiteRating LIKE '1F' THEN 'Average View' 
    WHEN ld.SiteRating LIKE '1P' THEN 'Good View' 
    WHEN ld.SiteRating LIKE '1S' THEN 'Excellent View' 
    WHEN ld.SiteRating LIKE '2D' THEN 'Legend 1' 
    WHEN ld.SiteRating LIKE '2F' THEN 'Legend 2' 
    WHEN ld.SiteRating LIKE '2P' THEN 'Legend 3' 
    WHEN ld.SiteRating LIKE '2S' THEN 'Legend 4' 
    WHEN ld.SiteRating LIKE '3D' THEN 'Legend 5' 
    WHEN ld.SiteRating LIKE '3F' THEN 'Legend 6' 
    WHEN ld.SiteRating LIKE '3P' THEN 'Legend 7' 
    WHEN ld.SiteRating LIKE '3S' THEN 'Legend 8' 
    WHEN ld.SiteRating LIKE '4D' THEN 'Legend 9' 
    WHEN ld.SiteRating LIKE '4F' THEN 'Legend 10' 
    WHEN ld.SiteRating LIKE '4P' THEN 'Legend 11' 
    WHEN ld.SiteRating LIKE '4S' THEN 'Legend 12' 
    WHEN ld.SiteRating LIKE '5A' THEN 'Legend 13' 
    WHEN ld.SiteRating LIKE 'CS' THEN 'Legend 14' 
    WHEN ld.SiteRating LIKE 'DA' THEN 'Legend 15' 
    WHEN ld.SiteRating LIKE 'DB' THEN 'Legend 16' 
    WHEN ld.SiteRating LIKE 'GA' THEN 'Legend 17' 
    WHEN ld.SiteRating LIKE 'GB' THEN 'Legend 18' 
    WHEN ld.SiteRating LIKE 'GC' THEN 'Legend 19' 
    WHEN ld.SiteRating LIKE '7' THEN 'Legend 20' 
    WHEN ld.SiteRating LIKE '8' THEN 'Legend 21' 
    ELSE ld.SiteRating
    END AS [SiteRating]
    
FROM LandDetail AS ld


WHERE ld.Id = '525012'