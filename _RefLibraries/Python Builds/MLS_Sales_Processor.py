from fuzzywuzzy import fuzz
import pandas as pd  # For data manipulation and analysis, providing data structures like DataFrames
import glob  # For finding all file paths that match a specific pattern, useful for batch processing files
import os  # For interacting with the operating system, such as reading/writing files, managing directories, and handling file paths
import logging  # For logging events, errors, and information during script execution, helping with debugging and monitoring
import pyodbc  # For establishing database connections and executing SQL queries, enabling interaction with SQL databases
from fuzzywuzzy import process  # For fuzzy matching of strings
from sqlalchemy import create_engine  # For SQLAlchemy database connection



print("Start_SetUp")
logging.info("Start_SetUp")


""" Sets up Dynamic Logging for the user """
# Set up logging
def setup_logging():
    log_folder = os.path.join(os.path.expanduser('~'), 'MLS_Logs')
    if not os.path.exists(log_folder):
        os.makedirs(log_folder)
    log_file = os.path.join(log_folder, 'MLS_Sales_Processor.log')

    logging.basicConfig(
        filename=log_file,
        level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

setup_logging()
#file:///C:/Users/dwolfe/MLS_Logs/MLS_Sales_Processor.log


print("Start_DatabaseConnections")
logging.info("Start_DatabaseConnections")


""" Database Connections """
# Configuration for database connection
db_connection_string = (
    "Driver={SQL Server};"
    "Server=astxdbprod;"
    "Database=GRM_Main;"
    "Trusted_Connection=yes;"
)

# Function to connect to the database
def connect_to_database(connection_string):
    """
    Establishes a connection to the database using the provided connection string.
    
    :param connection_string: The connection string for the database.
    return engine.connect()
    """
    engine = create_engine(f'mssql+pyodbc:///?odbc_connect={connection_string}')
    #return pyodbc.connect(connection_string)
    return engine.connect()

logging.info("Connect to Database")

# Function to execute a SQL query and fetch data
def execute_query(cursor, query, params=None):
    """
    Executes a SQL query and fetches the results.
    
    :param cursor: The database cursor object.
    :param query: The SQL query to execute.
    :param params: Optional parameters for the query.
    :return: The fetched rows from the query.
    """
    if params:
        cursor.execute(query, params)
    else:
        cursor.execute(query)
    return cursor.fetchall()

logging.info("Execute Query on Database")

# Function to convert query results to a DataFrame
def query_to_dataframe(connection, query, params=None):
    """
    Executes a SQL query and converts the results to a pandas DataFrame.
    
    :param connection: The database connection object.
    :param query: The SQL query to execute.
    :param params: Optional parameters for the query.
    :return: A pandas DataFrame containing the query results.
    """
    df = pd.read_sql(query, connection, params=params)
    return df

logging.info("Query > Dataframe")



print("Start_SQLQueiries")

logging.info("Start_SQLQueiries")

# Example usage of the database functions
if __name__ == "__main__":
    # Establish the database connection
    conn = connect_to_database(db_connection_string)

    # Define the first query
    ParcelMaster = """
    --Use PM to ensure MLS data matches a valid parcel
        WITH CTE_ParcelMaster AS (
        Select Distinct
        CASE
        WHEN pm.neighborhood >= 9000 THEN 'Manufactured_Homes'
        WHEN pm.neighborhood >= 6003 THEN 'District_6'
        WHEN pm.neighborhood = 6002 THEN 'Manufactured_Homes'
        WHEN pm.neighborhood = 6001 THEN 'District_6'
        WHEN pm.neighborhood = 6000 THEN 'Manufactured_Homes'
        WHEN pm.neighborhood >= 5003 THEN 'District_5'
        WHEN pm.neighborhood = 5002 THEN 'Manufactured_Homes'
        WHEN pm.neighborhood = 5001 THEN 'District_5'
        WHEN pm.neighborhood = 5000 THEN 'Manufactured_Homes'
        WHEN pm.neighborhood >= 4000 THEN 'District_4'
        WHEN pm.neighborhood >= 3000 THEN 'District_3'
        WHEN pm.neighborhood >= 2000 THEN 'District_2'
        WHEN pm.neighborhood >= 1021 THEN 'District_1'
        WHEN pm.neighborhood = 1020 THEN 'Manufactured_Homes'
        WHEN pm.neighborhood >= 1001 THEN 'District_1'
        WHEN pm.neighborhood = 1000 THEN 'Manufactured_Homes'
        WHEN pm.neighborhood >= 451 THEN 'Commercial'
        WHEN pm.neighborhood = 450 THEN 'Specialized_Cell_Towers'
        WHEN pm.neighborhood >= 1 THEN 'Commercial'
        WHEN pm.neighborhood = 0 THEN 'Other (PP, OP, NA, Error)'
        ELSE NULL
        END AS District
        ,pm.neighborhood AS GEO
        ,TRIM(pm.NeighborHoodName) AS GEO_Name
        ,pm.lrsn
        ,UPPER(TRIM(pm.pin)) AS PIN
        ,UPPER(TRIM(pm.AIN)) AS AIN
        ,UPPER(TRIM(pm.DisplayName)) AS Owner
        ,UPPER(TRIM(pm.DisplayDescr)) AS LegalDescription
        ,UPPER(TRIM(pm.SitusAddress)) AS SitusAddress
        ,UPPER(TRIM(pm.SitusCity)) AS SitusCity
        ,UPPER(TRIM(pm.SitusZip)) AS SitusZip
        ,pm.EffStatus
        From TSBv_PARCELMASTER AS pm
        Where pm.pin NOT LIKE 'E%'
        And pm.pin NOT LIKE 'G%'
        And pm.pin NOT LIKE 'U%'
        AND pm.ClassCD NOT LIKE '070%'
        )
        SELECT
        pmd.District
        ,pmd.GEO
        ,pmd.GEO_Name
        ,pmd.lrsn
        ,pmd.PIN
        ,pmd.AIN
        ,pmd.Owner
        ,pmd.SitusAddress
        ,pmd.SitusCity
        ,pmd.SitusZip
        ,pmd.LegalDescription
        ,pmd.EffStatus
        FROM CTE_ParcelMaster AS pmd
    """

    # Define the second query
    SalesTransfers = """
    --This is for pulling sales from the transfers table
        DECLARE @CurrentDate DATE = GETDATE();
        DECLARE @CurrentYear INT = YEAR(GETDATE());
        DECLARE @Year INT;
        IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
            SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
        ELSE
            SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year
        Declare @EffYearFrom DATE = Cast(@Year-10 as varchar) + '-01-01'; -- Generates '20230101' for the previous year
        Declare @EffYearTo DATE = Cast(@Year as varchar) + '-12-31'; -- Generates '20230101' for the previous year
        SELECT
        t.lrsn,
        UPPER(TRIM(pm.pin)) AS PIN,
        UPPER(TRIM(pm.AIN)) AS AIN,
        CAST(t.pxfer_date AS DATE) AS [TransferDate],
        YEAR(t.pxfer_date) AS PxYear,
        MONTH(t.pxfer_date) AS PxMonth,
        t.AdjustedSalePrice AS [SalesPrice_ProVal],
        t.DocNum,
        t.ConvForm,
        t.SaleDesc,
        t.TfrType,
        t.GrantorName AS [Grantor_Seller],
        t.GranteeName AS [Grantee_Buyer],
        CAST(t.last_update AS DATE) AS [LastUpdated],
        CAST(t.sxfer_date AS DATE) AS [Secondary_Transfer_Date]
        FROM transfer AS t
        JOIN TSBv_PARCELMASTER AS pm ON pm.lrsn = t.lrsn
        WHERE t.status = 'A'
        AND t.GrantorName <> t.GranteeName
        AND t.pxfer_date BETWEEN @EffYearFrom AND @EffYearTo
    """


    # Execute the queries and convert results to DataFrames
    pm = query_to_dataframe(conn, ParcelMaster)
    trnx = query_to_dataframe(conn, SalesTransfers)


    logging.info(f"\n{pm.head(10)}")  # Logs the first 10 rows
    logging.info(f"\n{trnx.head(10)}")  # Logs the first 10 rows


    # Close the connection
    conn.close()

    # Example usage of logging
    if not pm.empty and not trnx.empty:
        logging.info("SQL DataFrames created successfully from database queries.")
    else:
        logging.error("Failed to create SQL DataFrames from database queries.")



print("Start_MLS_CSV_Combine_To_Dataframe")

logging.info("Start_MLS_CSV_Combine_To_Dataframe")


""" Create a single combined dataframe with all the CSVs combined into one table. """
def combine_csv_files(folder_path):
    # Use glob to find all CSV files in the folder
    csv_files = glob.glob(os.path.join(folder_path, '*.csv'))

    # Check if there are any CSV files in the folder
    if not csv_files:
        logging.info("No CSV files found in the folder.")
        return None

    # Create an empty list to store DataFrames
    df_list = []

    # Loop through the list of CSV files and read each into a DataFrame
    for file in csv_files:
        df = pd.read_csv(file, encoding='latin1')
        df_list.append(df)

    # Combine all DataFrames into one
    combined_df = pd.concat(df_list, ignore_index=True)
    return combined_df

# Example usage
folder_path = 'S:/Common/Comptroller Tech/Reports/MLS/MLS_CSVs'  # Replace with your folder path
combined_df = combine_csv_files(folder_path)

# Example usage of logging
if combined_df is not None:
    logging.info("Combined DataFrame from MLS CSV files created successfully.")
else:
    logging.error("No MLS CSV files found in the folder or other issues.")



print("You should now have a MLS Dataframe called: combined_df")

logging.info("You should now have a MLS Dataframe called: combined_df")

logging.info(f"\n{combined_df.head(10)}")  # Logs the first 10 rows







print("Start_CleanedVersion_Of_combined_df")

logging.info("Start_CleanedVersion_Of_combined_df")



""" Create a reference of that combined dataframe with only selected columns and filters  """
""" The cleaned version will also have several transformations to make it easier to process """
if combined_df is not None:
    logging.info("Combined MLS CSV DataFrame created successful.")
    # Select specific columns
    selected_columns = [
        "List Number", "Sold Date", "Sold Price", "Street Number", "Street Direction Pfx", 
        "Street Name", "NO_COMMON_NAME", "Street Direction Sfx", "Street Suffix", "City", 
        "State/Province", "County", "Postal Code", "Parcel Number", "Legal", "AIN/Tax Bill"
    ]
    filtered_df = combined_df[selected_columns]

    # Apply a filter on the 'County' column
    filtered_df = filtered_df[filtered_df['County'] == 'Kootenai']

    # Combine address columns into a single 'Address' column
    filtered_df['Address'] = (
        filtered_df['Street Number'].fillna('') + ' ' +
        filtered_df['Street Direction Pfx'].fillna('') + ' ' +
        filtered_df['Street Name'].fillna('') + ' ' +
        filtered_df['NO_COMMON_NAME'].fillna('') + ' ' +
        filtered_df['Street Direction Sfx'].fillna('') + ' ' +
        filtered_df['Street Suffix'].fillna('')
    ).str.strip()

    # Convert specified columns to uppercase
    columns_to_upper = [
        "List Number", "Address", "City", "State/Province", 
        "Parcel Number", "Postal Code", "Legal", "AIN/Tax Bill"
    ]
    for column in columns_to_upper:
        filtered_df[column] = filtered_df[column].astype(str)
        filtered_df[column] = filtered_df[column].str.upper()

    # Trim whitespace from specified columns
    columns_to_trim = columns_to_upper
    for column in columns_to_trim:
        filtered_df[column] = filtered_df[column].str.strip()

    # Clean specified columns
    columns_to_clean = columns_to_upper
    for column in columns_to_clean:
        filtered_df[column] = filtered_df[column].str.replace(r'\s+', ' ', regex=True)

    # Take first 12 characters of 'Parcel Number'
    filtered_df['Parcel Number'] = filtered_df['Parcel Number'].str[:12]

    # Take first 6 characters of 'AIN/Tax Bill'
    filtered_df['AIN/Tax Bill'] = filtered_df['AIN/Tax Bill'].str[:6]

    # Include 'County' and 'State/Province' in the final dataframe
    filtered_df['County'] = filtered_df['County']
    filtered_df['State'] = filtered_df['State/Province']
    filtered_df['AIN/Tax Bill'] = filtered_df['AIN/Tax Bill'].str[:6]

    # Reorder columns
    reordered_columns = [
        "Parcel Number", "AIN/Tax Bill", "List Number", "Sold Date", "Sold Price", 
        "Address", "City", "State/Province", "Postal Code", "County","Legal"
    ]
    filtered_df = filtered_df[reordered_columns]

    # Insert 'Year' and 'Month' columns
    filtered_df['Year'] = pd.DatetimeIndex(filtered_df['Sold Date']).year
    filtered_df['Month'] = pd.DatetimeIndex(filtered_df['Sold Date']).month


    logging.info("Filtered MLS CSV DataFrame created successful.")
    logging.info(f"\n{filtered_df.head(10)}")  # Logs the first 10 rows

else:
    logging.error("Filtered MLS DataFrame not created or other issues.")


logging.info("You should now have a cleaned from of the dataframe called filtere_df")

# Ensure 'AIN/Tax Bill' column in the combined_df is a string
combined_df['AIN/Tax Bill'] = combined_df['AIN/Tax Bill'].astype(str).str.strip()



print("Start_Matching_DFs_on_ParcelMaster")

logging.info("Start_Matching_DFs_on_ParcelMaster")

logging.info("Start_PM_to_PIN")

""" We begin comparing filtered_df to pm ON PIN """
# Merge filtered_df with pm on 'Parcel Number' and 'PIN' respectively
merged_df = pd.merge(filtered_df, pm[['PIN', 'lrsn', 'AIN']], left_on='Parcel Number', right_on='PIN', how='left')

# DataFrame with matches (inner join equivalent)
matched_df_PIN = merged_df[merged_df['lrsn'].notna()]

# DataFrame with non-matches (left anti join equivalent)
non_matched_df_PIN = merged_df[merged_df['lrsn'].isna()]

# Drop the extra 'PIN' column from matched_df_PIN
matched_df_PIN = matched_df_PIN.drop(columns=['PIN'])

# Example usage of logging
if not matched_df_PIN.empty:
    logging.info("Matched on PIN DataFrame created successfully.")
else:
    logging.error("No PIN matches found in the DataFrame.")


if not non_matched_df_PIN.empty:
    logging.info("Non-matched on PIN DataFrame created successfully.")
else:
    logging.error("All records matched; no non-matches found in the DataFrame.")


logging.info(f"\n{matched_df_PIN.head(10)}")  # Logs the first 10 rows

logging.info(f"\n{non_matched_df_PIN.head(10)}")  # Logs the first 10 rows







print("Start_PM_to_AIN")

logging.info("Start_PM_to_AIN")


""" We begin comparing filtered_df to pm ON AIN """

# Merge non_matched_df_PIN with pm on 'AIN' and 'AIN' respectively
merged_df_AIN = pd.merge(non_matched_df_PIN, pm[['AIN', 'lrsn', 'PIN']], left_on='AIN/Tax Bill', right_on='AIN', how='left')

# DataFrame with matches (inner join equivalent)
matched_df_AIN = merged_df_AIN[merged_df_AIN['lrsn_y'].notna()]

# DataFrame with non-matches (left anti join equivalent)
non_matched_df_AIN = merged_df_AIN[merged_df_AIN['lrsn_y'].isna()]

# Drop the extra 'AIN' column from matched_df_AIN
matched_df_AIN = matched_df_AIN.drop(columns=['AIN_x', 'AIN_y'], errors='ignore')

# Example usage of logging
if not matched_df_AIN.empty:
    logging.info("Matched DataFrame on AIN created successfully.")
else:
    logging.error("No matches found on AIN in the DataFrame.")

if not non_matched_df_AIN.empty:
    logging.info("Non-matched DataFrame on AIN created successfully.")
else:
    logging.error("All records matched on AIN; no non-matches found in the DataFrame.")


logging.info(f"\n{matched_df_AIN.head(10)}")  # Logs the first 10 rows

logging.info(f"\n{non_matched_df_AIN.head(10)}")  #




print("Start_PM_to_Address")

logging.info("Start_PM_to_Address")


""" We begin comparing filtered_df to pm ON Address """

# Function to perform fuzzy matching on addresses
def fuzzy_match_address(row, pm_addresses):
    match, score = process.extractOne(row['Address'], pm_addresses)
    return match if score >= 90 else None

# Extract unique addresses from pm DataFrame
pm_addresses = pm['SitusAddress'].unique()

# Apply fuzzy matching to non_matched_df_AIN
non_matched_df_AIN = non_matched_df_AIN.copy()
non_matched_df_AIN['Matched_Address'] = non_matched_df_AIN.apply(fuzzy_match_address, axis=1, pm_addresses=pm_addresses)

# Merge non_matched_df_AIN with pm on 'Matched_Address' and 'SitusAddress' respectively
merged_df_address = pd.merge(non_matched_df_AIN, pm[['SitusAddress', 'lrsn', 'PIN', 'AIN']], left_on='Matched_Address', right_on='SitusAddress', how='left')

# DataFrame with matches (inner join equivalent)
matched_df_address = merged_df_address[merged_df_address['lrsn'].notna()]

# DataFrame with non-matches (left anti join equivalent)
non_matched_df_address = merged_df_address[merged_df_address['lrsn'].isna()]

# Drop the extra 'SitusAddress' and 'Matched_Address' columns from matched_df_address
matched_df_address = matched_df_address.drop(columns=['SitusAddress', 'Matched_Address'])

# Example usage of logging
if not matched_df_address.empty:
    logging.info("Matched DataFrame on Address created successfully.")
else:
    logging.error("No matches found on Address in the DataFrame.")

if not non_matched_df_address.empty:
    logging.info("Non-matched DataFrame on Address created successfully.")
else:
    logging.error("All records matched on Address; no non-matches found in the DataFrame.")


logging.info(f"\n{matched_df_address.head(10)}")  # Logs the first 10 rows

logging.info(f"\n{non_matched_df_address.head(10)}")  #


print("Start_PM_to_LegalDescription")

logging.info("Start_PM_to_LegalDescription")

""" We begin comparing filtered_df to pm ON LEGAL Description """

# Function to perform fuzzy matching on legal descriptions
def fuzzy_match_legal(row, pm_legals):
    match, score = process.extractOne(row['Legal'], pm_legals)
    return match if score >= 90 else None

# Extract unique legal descriptions from pm DataFrame
pm_legals = pm['LegalDescription'].unique()

non_matched_df_address = non_matched_df_address.copy()
non_matched_df_address['Matched_Legal'] = non_matched_df_address.apply(lambda row: fuzzy_match_legal(row, pm_legals), axis=1)

# Merge non_matched_df_address with pm on 'Matched_Legal' and 'LegalDescription' respectively
merged_df_legal = pd.merge(non_matched_df_address, pm[['LegalDescription', 'lrsn', 'PIN', 'AIN']], left_on='Matched_Legal', right_on='LegalDescription', how='left')

# DataFrame with matches (inner join equivalent)
matched_df_legal = merged_df_legal[merged_df_legal['lrsn'].notna()]

# DataFrame with non-matches (left anti join equivalent)
non_matched_df_legal = merged_df_legal[merged_df_legal['lrsn'].isna()]

# Drop the extra 'LegalDescription' and 'Matched_Legal' columns from matched_df_legal
matched_df_legal = matched_df_legal.drop(columns=['LegalDescription', 'Matched_Legal'])

# Example usage of logging
if not matched_df_legal.empty:
    logging.info("Matched DataFrame on Legal Description created successfully.")
else:
    logging.error("No matches found on Legal Description in the DataFrame.")

if not non_matched_df_legal.empty:
    logging.info("Non-matched DataFrame on Legal Description created successfully.")
else:
    logging.error("All records matched on Legal Description; no non-matches found in the DataFrame.")


logging.info(f"\n{matched_df_legal.head(10)}")  # Logs the first 10 rows

logging.info(f"\n{non_matched_df_legal.head(10)}")  #




print("You now have a cascade of dataframes, each unique, four with matches and one with no matches.")

logging.info("You now havew a cascade of dataframes, each unique, four with matches and one with no matches.")


""" This creates five dataframes to to this point """
""" The four matches are only checking for VALIDITY on the ParcelMaster, we match with Transfer Table next."""
""" We append the four matching into one table, and the final non-matching we send to rejects."""
#matched_df_pin - Matches on PIN.
#matched_df_ain - Matches on AIN.
#matched_df_address - Matches on Address.
#matched_df_legal - Matches on Legal Description.
#non_matched_df_legal - Records that didn't match on any of the above criteria.

# Combine all matched DataFrames into one
mls_matched_pm = pd.concat([matched_df_PIN, matched_df_AIN, matched_df_address, matched_df_legal], ignore_index=True)

# DataFrame for non-matches
mls_did_not_match_pm = non_matched_df_legal

# Example usage of logging
if not mls_matched_pm.empty:
    logging.info("Combined matched DataFrame created successfully.")
else:
    logging.error("No matches found in the combined matched DataFrame.")

if not mls_did_not_match_pm.empty:
    logging.info("Non-matched DataFrame created successfully.")
else:
    logging.error("No non-matches found in the DataFrame.")



logging.info("We now have two dataframes mls_matched_pm and mls_did_not_match_pm.")



logging.info(f"\n{mls_matched_pm.head(10)}")  # Logs the first 10 rows

logging.info(f"\n{mls_did_not_match_pm.head(10)}")  #



print("Start_Checking Against Transfers Table.")

logging.info("Start_Checking Against Transfers Table.")


""" Now we take these two dataframes and start working them against the sales database table """

# Merge mls_matched_pm with trnx on 'PIN', 'Year', and 'Month' respectively
merged_sales_df = pd.merge(mls_matched_pm, trnx, left_on=['Parcel Number', 'Year', 'Month'], right_on=['PIN', 'PxYear', 'PxMonth'], how='left')

# DataFrame with matches (inner join equivalent)
matched_sales_df = merged_sales_df[merged_sales_df['lrsn_y'].notna()]

# DataFrame with non-matches (left anti join equivalent)
non_matched_sales_df = merged_sales_df[merged_sales_df['lrsn_y'].isna()]

# Drop the extra columns from matched_sales_df
matched_sales_df = matched_sales_df.drop(columns=['PIN', 'PxYear', 'PxMonth'])

# Example usage of logging
if not matched_sales_df.empty:
    logging.info("Matched sales DataFrame created successfully.")
else:
    logging.error("No matches found in the sales DataFrame.")

if not non_matched_sales_df.empty:
    logging.info("Non-matched sales DataFrame created successfully.")
else:
    logging.error("All records matched in the sales DataFrame; no non-matches found.")

mls_sale_validPIN_no_transfer_record = non_matched_sales_df
logging.info("mls_sale_validPIN_no_transfer_record = non_matched_sales_df.")


logging.info(f"\n{matched_sales_df.head(10)}")  # Logs the first 10 rows

logging.info(f"\n{non_matched_sales_df.head(10)}")  #

print(f"\n{matched_sales_df.head(10)}")  # Logs the first 10 rows

print(f"\n{non_matched_sales_df.head(10)}")  #






print("Rejects List.")

logging.info("Rejects List.")


""" Rejects List requires Review """
# Combine mls_sale_validPIN_no_transfer_record and mls_did_not_match_pm into 'RejectsList'
RejectsList = pd.concat([mls_sale_validPIN_no_transfer_record, mls_did_not_match_pm], ignore_index=True)

# Example usage of logging
if not RejectsList.empty:
    logging.info("RejectsList DataFrame created successfully.")
else:
    logging.error("No records found in the RejectsList DataFrame.")


logging.info(f"\n{RejectsList.head(10)}")  # Logs the first 10 rows






print("Looking for sales not already entered.")

logging.info("Looking for sales not already entered.")


""" NEW matched_sales_df and re-matching it against the raw trnx table, creating three new dataframes """

# Merge matched_sales_df with trnx on 'PIN', 'Year', 'Month', and 'Sold Price' respectively
merged_sales_OnPrice_df = pd.merge(matched_sales_df, trnx, left_on=['Parcel Number', 'Year', 'Month', 'Sold Price'], right_on=['PIN', 'PxYear', 'PxMonth', 'SalesPrice_ProVal'], how='left')

# DataFrame with matches (inner join equivalent)
matched_sales_OnPrice_df = merged_sales_OnPrice_df[merged_sales_OnPrice_df['lrsn_y'].notna()]

# DataFrame with non-matches (left anti join equivalent)
non_matched_sales_OnPrice_df = merged_sales_OnPrice_df[merged_sales_OnPrice_df['lrsn_y'].isna()]

# Drop the extra columns from matched_sales_OnPrice_df
matched_sales_OnPrice_df = matched_sales_OnPrice_df.drop(columns=['PIN', 'PxYear', 'PxMonth', 'SalesPrice_ProVal'])

# Example usage of logging
if not matched_sales_OnPrice_df.empty:
    logging.info("Matched sales DataFrame created successfully.")
else:
    logging.error("No matches found in the sales DataFrame.")

if not non_matched_sales_OnPrice_df.empty:
    logging.info("Non-matched sales DataFrame created successfully.")
else:
    logging.error("All records matched in the sales DataFrame; no non-matches found.")



logging.info("You have two dataframes, but only need the one for sales to be entered.")


logging.info(f"\n{matched_sales_OnPrice_df.head(10)}")  # Logs the first 10 rows

logging.info(f"\n{non_matched_sales_OnPrice_df.head(10)}")  #






print("Start Sales Review into Buckets.")

logging.info("Start Sales Review into Buckets.")

""" Valid Sales Needing Input """
# Split matched_sales_OnPrice_df into three DataFrames based on SalesPrice_ProVal matching Sold Price
matched_sales_price_df = matched_sales_OnPrice_df[matched_sales_OnPrice_df['SalesPrice_ProVal'] == matched_sales_OnPrice_df['Sold Price']]
non_matched_sales_price_non_zero_df = matched_sales_OnPrice_df[(matched_sales_OnPrice_df['SalesPrice_ProVal'] != matched_sales_OnPrice_df['Sold Price']) & (matched_sales_OnPrice_df['SalesPrice_ProVal'] > 0)]
non_matched_sales_price_zero_df = matched_sales_OnPrice_df[(matched_sales_OnPrice_df['SalesPrice_ProVal'] != matched_sales_OnPrice_df['Sold Price']) & (matched_sales_OnPrice_df['SalesPrice_ProVal'] == 0)]

# Example usage of logging
if not matched_sales_price_df.empty:
    logging.info("Matched sales price DataFrame created successfully.")
else:
    logging.error("No matches found in the sales price DataFrame.")

if not non_matched_sales_price_non_zero_df.empty:
    logging.info("Non-matched sales price (non-zero) DataFrame created successfully.")
else:
    logging.error("No non-matches with non-zero sales price found in the DataFrame.")

if not non_matched_sales_price_zero_df.empty:
    logging.info("Non-matched sales price (zero) DataFrame created successfully.")
else:
    logging.error("No non-matches with zero sales price found in the DataFrame.")



logging.info(f"\n{matched_sales_price_df.head(10)}")  # Logs the first 10 rows

logging.info(f"\n{non_matched_sales_price_non_zero_df.head(10)}")  #

logging.info(f"\n{non_matched_sales_price_zero_df.head(10)}")  #








print("This step should spit out into CSVs but it isn't doing it?")

logging.info("This step should spit out into CSVs but it isn't doing it?")


""" Final Output """
# Save matched_sales_price_df to CSV
matched_sales_price_df.to_csv(r'S:\Common\Comptroller Tech\Reports\MLS\MLS_PythonExports\MLS_Already_Entered.csv', index=False)

# Save non_matched_sales_price_non_zero_df to CSV
non_matched_sales_price_non_zero_df.to_csv(r'S:\Common\Comptroller Tech\Reports\MLS\MLS_PythonExports\TrnxTable_HasPrice_NotMatching_MLS.csv', index=False)

# Save non_matched_sales_price_zero_df to CSV
non_matched_sales_price_zero_df.to_csv(r'S:\Common\Comptroller Tech\Reports\MLS\MLS_PythonExports\ReadyToImport.csv', index=False)

# Save RejectsList to CSV
RejectsList.to_csv(r'S:\Common\Comptroller Tech\Reports\MLS\MLS_PythonExports\MLSNeedsResearch.csv', index=False)












"""" 
This is for testing only

# Example usage of logging
if combined_df is not None:
    logging.info("Filtered DataFrame created successfully.")
else:
    logging.error("Filtered DataFrame not created or other issues.")


if combined_df is not None:
    combined_df.to_csv('C:/Users/darre/OneDrive/Desktop/combined_MLS_CSVs.csv', index=False)
    logging.info(combined_df.head())


    # This only tests Combined DataFrame
    # Save the combined DataFrame to the specified file path
    #output_path = 'C:/Users/darre/OneDrive/Desktop/Test/combined_MLS_CSVs.csv'
    #combined_df.to_csv(output_path, index=False)
    #logging.info(f"Combined CSV saved to {output_path}")

    

    # This only tests Cleaned DataFrame
    # Save the cleaned DataFrame to a new CSV file
    filtered_df.to_csv('C:/Users/darre/OneDrive/Desktop/Test/cleaned_MLS_CSVs.csv', index=False)
    logging.info(filtered_df.head())




"""















