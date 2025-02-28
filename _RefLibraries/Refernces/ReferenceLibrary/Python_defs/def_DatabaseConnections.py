
"""
Connect to the database, 
pull a simple SQL query with two columns,
then the  for row in rows assigns those columns as variables 
See PlatPackets.sql and PLATPacketsAutomation_FINAL.py for an example of a more complicated query and variable set up using the first five characters of the PIN instead of AINLIST
"""

conn = connect_to_database(db_connection_string)
cursor = conn.cursor()

# The query should accommodate multiple AINs in a list
query = f"SELECT TRIM(pm.AIN), pm.LegalAcres FROM TSBv_Parcelmaster AS pm WHERE pm.AIN IN ({','.join(AINLIST)})"
rows = execute_query(cursor, query)
logging.info("SQL_Query")


# Iterate through each row in the results
for row in rows:
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    DBAIN, DBACRE = row
    ensure_capslock_off()

    stop_script

    logging.info(f"Varaibles Created:")

    #SQL Query
    logging.info(f"DBAIN: {DBAIN}")
    logging.info(f"DBACRE: {DBACRE}")

    #User Input
    logging.info(f"AINLIST: {AINLIST}")
    logging.info(f"AINFROM: {AINFROM}")
    logging.info(f"AINTO: {AINTO}")
    logging.info(f"MappingPacketType: {MappingPacketType}")
    logging.info(f"Initials: {Initials}")
    logging.info(f"ForYear: {ForYear}")
    logging.info(f"MemoTXT: {MemoTXT}")
    logging.info(f"PDESC: {PDESC}")
    logging.info(f"PFILE: {PFILE}")
    logging.info(f"PNUMBER: {PNUMBER}")
    logging.info(f"TREVIEW: {TREVIEW}")


    OR 


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

    try:
        # Set the description code basedon SQL result
        description_code = determine_group_code(DBPCC)  
        
        # Get the number of key presses required for the description
        num_presses = pressess_allocations(description_code)

        # Ensure CAPS LOCK is off
        ensure_capslock_off()

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

        # After on_submit has gathered inputs
        logging.info(f"GROUP_CODE: {description_code}")
        logging.info(f"Presses_Up: {num_presses}")
        logging.info(f"AINLIST: {AINLIST}")
        logging.info(f"AINFROM: {AINFROM}")
        logging.info(f"PLATCOMBO: {PLATCOMBO}")
        logging.info(f"LANDTYPE: {LANDTYPE}")
        logging.info(f"LEGENDTYPE: {LEGENDTYPE}")
        logging.info(f"PFILE: {PFILE}")
        logging.info(f"PNUMBER: {PNUMBER}")
        logging.info(f"TREVIEW: {TREVIEW}")
        logging.info(f"Mapping Packet Type: {MappingPacketType}")
        logging.info(f"Initials: {Initials}")
        logging.info(f"For Year: {ForYear}")
        logging.info(f"MemoTXT: {MemoTXT}")
        logging.info(f"PDESC: {PDESC}")
        logging.info(f"LEGENDTYPE value: {LEGENDTYPE}, type: {type(LEGENDTYPE)}")

    except Exception as e:
        logging.error(f"Error processing row {row}: {e}")