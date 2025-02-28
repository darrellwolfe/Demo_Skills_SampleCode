SELECT
    Initial AS EmployeeInitials,
    CASE
        WHEN Initial IN ('AAR', 'ARDW', 'DWAR') THEN 'Alex Reichert'
        WHEN Initial IN ('CMAB', 'RSAB', 'TSAB', 'ACB') THEN 'Andrew Buffin'
        WHEN Initial = 'AHH' THEN 'Aubrey Hollenbeck'
        WHEN Initial = 'BGK' THEN 'Bela Kovacs'
        WHEN Initial = 'BIC' THEN 'Ben Crotinger'
        WHEN Initial = 'RFS' THEN 'Bob Scott'
        WHEN Initial = 'BLC' THEN 'Brittany Crane'
        WHEN Initial IN ('CMG', 'RRCG', 'RSCG', 'CMCG', 'SHCG', 'EHCG', 'JLCG') THEN 'Chanice Giao'
        WHEN Initial = 'CDE' THEN 'Colette Erickson'
        WHEN Initial IN ('CCS', 'CS') THEN 'Colton Smith'
        WHEN Initial = 'CLM' THEN 'Cori Murrell'
        WHEN Initial IN ('DBDW', 'DGW', 'DWDB', 'DWEM', 'DWTJ') THEN 'Darrell Wolfe'
        WHEN Initial = 'DEB' THEN 'David Brazzle'
        WHEN Initial = 'DKB' THEN 'Donna Browne'
        WHEN Initial IN ('CMDH', 'DHH', 'DDH', 'RSDH', 'RRDH', 'EHDH', 'SHDH', 'GKDH', 'MWDH', 'JLDH') THEN 'Dustin Huddleston'
        WHEN Initial IN ('DAS', 'DSDB', 'DSTJ') THEN 'Dyson Savage'
        WHEN Initial = 'EAM' THEN 'Elizabeth Macgregor'
        WHEN Initial = 'EVH' THEN 'Eric Hart'
        WHEN Initial IN ('GRK', 'SHGK', 'CMGK', 'BBGK', 'ESGK', 'TSGK') THEN 'Garrett Kreitz'
        WHEN Initial = 'GRP' THEN 'Gina Price'
        WHEN Initial = 'HSS' THEN 'Heather Shackelford'
        WHEN Initial = 'HW' THEN 'Helga Wernicke'
        WHEN Initial = 'JCL' THEN 'James Labish'
        WHEN Initial IN ('JCB', 'JB') THEN 'Janice Ball'
        WHEN Initial IN ('JRT', 'RSJT', 'RRJT') THEN 'Jason Tweedy'
        WHEN Initial = 'JJP' THEN 'Joe Pounder'
        WHEN Initial = 'JJR' THEN 'Josiah Roberts'
        WHEN Initial = 'JGP' THEN 'Justin Parich'
        WHEN Initial = 'KKC' THEN 'Kathleen Clancy'
        WHEN Initial = 'KMM' THEN 'Kendall Mallery'
        WHEN Initial IN ('CMLB', 'LKB', 'TSLB', 'SHLB', 'BBLB', 'RSLB', 'RRLB') THEN 'Landen Butterfield'
        WHEN Initial = 'LAB' THEN 'Linda Buffington'
        WHEN Initial IN ('MJV', 'JBMV', 'TJJMV', 'MV', 'DMMV', 'MVDB') THEN 'Matthew Volz'
        WHEN Initial = 'MYG' THEN 'Michelle Goughnour'
        WHEN Initial IN ('MPW', 'PF') THEN 'Pat Fitzwater'
        WHEN Initial = 'PGF' THEN 'Pat Fitzwater'
        WHEN Initial = 'RRE' THEN 'Robin Egbert'
        WHEN Initial = 'REJ' THEN 'Rod Jones'
        WHEN Initial = 'RWR' THEN 'Ryan Rouse'
        WHEN Initial = 'SLH' THEN 'Shane Harmon'
        WHEN Initial = 'SHE' THEN 'Shelli Halloran'
        WHEN Initial = 'SRA' THEN 'Shelly Amos'
        WHEN Initial IN ('EHTH', 'RRTH', 'TH') THEN 'Taryn Hardway'
        WHEN Initial = 'TJJ' THEN 'Terry Jensen'
        WHEN Initial IN ('TKH', 'TKS') THEN 'Tony Harbison'
        WHEN Initial = 'VMW' THEN 'Vicki Williamson'
        ELSE 'Unknown' -- Default value if no match is found
    END AS EmployeeName
FROM YourTableName;





