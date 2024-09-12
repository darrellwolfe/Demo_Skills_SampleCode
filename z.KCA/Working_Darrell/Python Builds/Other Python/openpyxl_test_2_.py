import openpyxl
import pandas as pd
from pathlib import Path
import logging

# Setup basic configuration for logging
logging.basicConfig(filename='S:/Common/Comptroller Tech/Reports/Permits - Import/Permits_CompTechImports/_Backups/processing_log.txt', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

try:
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

    # Save the combined DataFrame to an Excel file
    combined_df.to_excel('S:/Common/Comptroller Tech/Reports/Permits - Import/Permits_CompTechImports/_Backups/combined.xlsx', index=False)

    # Display the first 10 rows of the DataFrame
    print("First 10 rows of the DataFrame:")
    print(combined_df.head(10))

except Exception as e:
    print("An error occurred:", e)