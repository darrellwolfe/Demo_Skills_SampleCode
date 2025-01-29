SELECT msn as Model_number, 
                table_type, 
                year_group, 
                neighborhood,
                rent_class,
                    CASE prop_type
                        WHEN 21 THEN 'Duplex'
                        WHEN 22 THEN 'TRIPLEX'
                        WHEN 23 THEN 'FOURPLEX'
                    END AS BUILDING_CLASS,
                df1 AS '1/1',
                df2 AS '2/1',
                df3 AS '2/1.5+',
                df4 AS '3/1',
                df5 AS '3/1.5+',
                df6 AS '3/2',
                df7 AS '4/2'
            FROM dbo.income_factors
            WHERE table_type LIKE 'GIM' 
                AND version_num = 4 
                AND msn = 300024 
                AND neighborhood = '2998'
                AND rent_class = '3'
                AND prop_type = '21'