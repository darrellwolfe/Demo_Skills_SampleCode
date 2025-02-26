-- !preview conn=conn


SELECT
    ap.assignedto AS AssignedTo,
    CASE
        WHEN ap.assignedto IN ('AAR', 'ARDW', 'DWAR') THEN 'Alex Reichert'
        WHEN ap.assignedto IN ('CMAB', 'RSAB', 'TSAB', 'ACB') THEN 'Andrew Buffin'
        WHEN ap.assignedto = 'AHH' THEN 'Aubrey Hollenbeck'
        WHEN ap.assignedto = 'BGK' THEN 'Bela Kovacs'
        WHEN ap.assignedto = 'BIC' THEN 'Ben Crotinger'
        WHEN ap.assignedto = 'RFS' THEN 'Bob Scott'
        WHEN ap.assignedto = 'BLC' THEN 'Brittany Crane'
        WHEN ap.assignedto IN ('CMG', 'RRCG', 'RSCG', 'CMCG', 'SHCG', 'EHCG', 'JLCG') THEN 'Chanice Giao'
        WHEN ap.assignedto = 'CDE' THEN 'Colette Erickson'
        WHEN ap.assignedto IN ('CCS', 'CS') THEN 'Colton Smith'
        WHEN ap.assignedto = 'CLM' THEN 'Cori Murrell'
        WHEN ap.assignedto IN ('DBDW', 'DGW', 'DWDB', 'DWEM', 'DWTJ') THEN 'Darrell Wolfe'
        WHEN ap.assignedto = 'DEB' THEN 'David Brazzle'
        WHEN ap.assignedto = 'DKB' THEN 'Donna Browne'
        WHEN ap.assignedto IN ('CMDH', 'DHH', 'DDH', 'RSDH', 'RRDH', 'EHDH', 'SHDH', 'GKDH', 'MWDH', 'JLDH') THEN 'Dustin Huddleston'
        WHEN ap.assignedto IN ('DAS', 'DSDB', 'DSTJ') THEN 'Dyson Savage'
        WHEN ap.assignedto = 'EAM' THEN 'Elizabeth Macgregor'
        WHEN ap.assignedto = 'EVH' THEN 'Eric Hart'
        WHEN ap.assignedto IN ('GRK', 'SHGK', 'CMGK', 'BBGK', 'ESGK', 'TSGK') THEN 'Garrett Kreitz'
        WHEN ap.assignedto = 'GRP' THEN 'Gina Price'
        WHEN ap.assignedto = 'HSS' THEN 'Heather Shackelford'
        WHEN ap.assignedto = 'HW' THEN 'Helga Wernicke'
        WHEN ap.assignedto = 'JCL' THEN 'James Labish'
        WHEN ap.assignedto IN ('JCB', 'JB') THEN 'Janice Ball'
        WHEN ap.assignedto IN ('JRT', 'RSJT', 'RRJT') THEN 'Jason Tweedy'
        WHEN ap.assignedto = 'JJP' THEN 'Joe Pounder'
        WHEN ap.assignedto = 'JJR' THEN 'Josiah Roberts'
        WHEN ap.assignedto = 'JGP' THEN 'Justin Parich'
        WHEN ap.assignedto = 'KKC' THEN 'Kathleen Clancy'
        WHEN ap.assignedto = 'KMM' THEN 'Kendall Mallery'
        WHEN ap.assignedto IN ('CMLB', 'LKB', 'TSLB', 'SHLB', 'BBLB', 'RSLB', 'RRLB') THEN 'Landen Butterfield'
        WHEN ap.assignedto = 'LAB' THEN 'Linda Buffington'
        WHEN ap.assignedto IN ('MJV', 'JBMV', 'TJJMV', 'MV', 'DMMV', 'MVDB') THEN 'Matthew Volz'
        WHEN ap.assignedto = 'MYG' THEN 'Michelle Goughnour'
        WHEN ap.assignedto IN ('MPW', 'PF') THEN 'Pat Fitzwater'
        WHEN ap.assignedto = 'PGF' THEN 'Pat Fitzwater'
        WHEN ap.assignedto = 'RRE' THEN 'Robin Egbert'
        WHEN ap.assignedto = 'REJ' THEN 'Rod Jones'
        WHEN ap.assignedto = 'RWR' THEN 'Ryan Rouse'
        WHEN ap.assignedto = 'SLH' THEN 'Shane Harmon'
        WHEN ap.assignedto = 'SHE' THEN 'Shelli Halloran'
        WHEN ap.assignedto = 'SRA' THEN 'Shelly Amos'
        WHEN ap.assignedto IN ('EHTH', 'RRTH', 'TH') THEN 'Taryn Hardway'
        WHEN ap.assignedto = 'TJJ' THEN 'Terry Jensen'
        WHEN ap.assignedto IN ('TKH', 'TKS') THEN 'Tony Harbison'
        WHEN ap.assignedto = 'VMW' THEN 'Vicki Williamson'
        ELSE 'Unknown' -- Default value if no match is found
    END AS Appraiser_User
    
    
FROM APPEALS AS ap
WHERE ap.status = 'A'
AND ap.year_appealed = 2023






