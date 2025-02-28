

SELECT TRIM(pm.AIN), pm.LegalAcres 
FROM TSBv_Parcelmaster AS pm 
--WHERE pm.AIN IN ({','.join(AINLIST)})


/*

"""
Connect to the database, 
pull a simple SQL query with two columns,
then the  for row in rows assigns those columns as variables 
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

    #SQL Query
    logging.info(f"DBAIN: {DBAIN}")
    logging.info(f"DBACRE: {DBACRE}")

    
*/