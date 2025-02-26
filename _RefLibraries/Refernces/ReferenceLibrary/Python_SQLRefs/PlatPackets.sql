Select Distinct 
    RevObjId AS lrsn,
    TRIM(PIN) AS PIN, 
    TRIM(AIN) AS AIN, 
    CAST(LEFT(Prop_Class_Descr,3) AS INT) AS PCC,
    TRIM(Prop_Class_Descr) AS Prop_Class_Descr,
    Acres, 
    Cat19AC, 
    CASE WHEN ACRES >= 1 THEN 1 ELSE ACRES - Cat19Ac END AS SITE, 
    CASE WHEN ACRES > 1 THEN ACRES - 1 - CAT19AC ELSE 0 END AS REMACRES 

From 
    KC_MAP_PlatReportBase_v 
Where 
    EffStatus = 'A' 
    --AND PIN like ? 
    --AND AIN NOT IN ({','.join(['?' for _ in AIN_Exclude])})

Order by 
    PIN ASC


/*
"""
Connect to the database, 
pull a simple SQL query with two columns,
then the  for row in rows assigns those columns as variables 
"""

# Establish the database connection
conn = connect_to_database(db_connection_string)
cursor = conn.cursor()

# Define the query with a placeholder for PLATCOMBO
query = """
Select Distinct 
    RevObjId AS lrsn,
    TRIM(PIN) AS PIN, 
    TRIM(AIN) AS AIN, 
    CAST(LEFT(Prop_Class_Descr,3) AS INT) AS PCC,
    TRIM(Prop_Class_Descr) AS Prop_Class_Descr,
    Acres, 
    Cat19AC, 
    CASE WHEN ACRES >= 1 THEN 1 ELSE ACRES - Cat19Ac END AS SITE, 
    CASE WHEN ACRES > 1 THEN ACRES - 1 - CAT19AC ELSE 0 END AS REMACRES 

From 
    KC_MAP_PlatReportBase_v 
Where 
    EffStatus = 'A' 
    AND PIN like ? 
    AND AIN NOT IN ({','.join(['?' for _ in AIN_Exclude])})

Order by 
    PIN ASC
"""
logging.info("SQL_Query")

    ## For testing purposes, 
    # PIN: KC-DGW = AIN: 345134
    # PIN: KC-DAS = AIN: 348586
    # Plat for testing 0L806
    # Plat for testing AL719
    # Inactive AIN for testing 351782
    # AL7190010260 520
    # C17700010290 343
    # C82780020020 421
    # 0L81400000J0 515
    # B0999003006B 520
    # TEST LOCATION IN SCRIPT

# Execute the query with PLATCOMBO as a parameter
params = [PLATCOMBO + '%'] + AIN_Exclude
rows = execute_query(cursor, query, params)


# Initialize a flag to identify the first AIN
first_ain_processed = False

# Iterate through each row in the results
for idx, row in enumerate(rows):
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break

    DBLRSN = row[0] 
    DBPIN = row[1]  
    DBAIN = row[2]  
    DBPCC = row[3]
    DBPCCDESCR = row [4]
    DBACRE = row[5] 
    DBCat19AC = row[6] 
    DBSITE = row[7] 
    DBREMACRES = row[8]


# SQL Results
logging.info(f"LRSN: {DBLRSN}")
logging.info(f"PIN: {DBPIN}")
logging.info(f"AIN: {DBAIN}")
logging.info(f"PCC_CODE: {DBPCC}")
logging.info(f"PCC_DESCR: {DBPCCDESCR}")
logging.info(f"Acres: {DBACRE}")
logging.info(f"Cat19AC: {DBCat19AC}")
logging.info(f"SITE: {DBSITE}")
logging.info(f"REMACRES: {DBREMACRES}")


*/


