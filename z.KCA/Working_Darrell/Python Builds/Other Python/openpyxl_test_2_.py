import openpyxl
import pandas as pd
from pathlib import Path
import logging
from sqlalchemy import create_engine
from fuzzywuzzy import process

# Setup basic configuration for logging
logging.basicConfig(filename='S:/Common/Comptroller Tech/Reports/Permits - Import/Permits_CompTechImports/_Backups/processing_log.txt', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Database connection string
db_connection_string = "mssql+pyodbc://@astxdbprod/GRM_Main?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"

try:
    # Establish a database connection using SQLAlchemy
    engine = create_engine(db_connection_string)
    
    # Define the SQL query
    sql_query = """
    Select Distinct
    pm.lrsn,
    TRIM(pm.pin) AS PIN,
    TRIM(pm.AIN) AS AIN,
    TRIM(pm.SitusAddress) AS SitusAddress,
    TRIM(pm.SitusCity) AS SitusCity,
    pm.EffStatus AS Account_Active_Status,
    pm.Improvement_Status -- <Improved vs Vacant
    From TSBv_PARCELMASTER AS pm
    Where pm.EffStatus = 'A'
    """
    
    # Execute the query and load the data into a DataFrame
    parcelmaster_df = pd.read_sql(sql_query, engine)
    
    # Define the path to the directory containing the CSV files
    csv_directory_path = Path(r'S:/Common/Comptroller Tech/Reports/Permits - Import/Permits_CompTechImports/CDA')

    # Specify the columns you want to load by name
    columns_to_load = ['issuedDate', 'Permit Number', 'project_type', 'project_description', 'permit_type', 'Total SQFT', 'site_address', 'site_directional', 'site_street', 'site_designation', 'permit_ready_fee', 'project_valuation']

    # Read each CSV file with a specified encoding and store them in a list
    df_list = [pd.read_csv(csv_file, usecols=columns_to_load, encoding='ISO-8859-1') for csv_file in csv_directory_path.glob('*.csv')]

    # Concatenate all DataFrames into a single DataFrame
    combined_df = pd.concat(df_list, ignore_index=True)

    # Concatenate address components into a single column, with space separator
    combined_df['Full Address'] = combined_df['site_address'].astype(str) + ' ' + \
                                  combined_df['site_directional'].astype(str) + ' ' + \
                                  combined_df['site_street'].astype(str) + ' ' + \
                                  combined_df['site_designation'].astype(str)

    # Optionally, you can strip any leading/trailing whitespace that might occur due to empty address parts
    combined_df['Full Address'] = combined_df['Full Address'].str.strip()

    # Remove the original address columns
    combined_df.drop(columns=['site_address', 'site_directional', 'site_street', 'site_designation'], inplace=True)

    # Perform fuzzy matching
    def match_address(row, choices, scorer, cutoff):
        result = process.extractOne(row['Full Address'], choices, scorer=scorer, score_cutoff=cutoff)
        if result:
            match, score = result
            matched_row = parcelmaster_df[parcelmaster_df['SitusAddress'] == match].iloc[0]
            return pd.Series([match, matched_row['PIN'], matched_row['AIN']])
        return pd.Series([None, None, None])

    # Apply fuzzy matching to each row in combined_df
    combined_df[['Matched Address', 'PIN', 'AIN']] = combined_df.apply(match_address, axis=1, choices=parcelmaster_df['SitusAddress'], scorer=process.fuzz.token_sort_ratio, cutoff=80)

    # Save the combined DataFrame to an Excel file
    combined_df.to_excel('S:/Common/Comptroller Tech/Reports/Permits - Import/Permits_CompTechImports/_Backups/combined.xlsx', index=False)

    # Display the first 10 rows of the DataFrame
    print("First 10 rows of the DataFrame:")
    print(combined_df.head(10))

except Exception as e:
    logging.error(f"An error occurred: {str(e)}")
    print(f"An error occurred. Check the log file for details.")