import pandas as pd
import logging
import os
import unicodedata

# Set up logging
logging.basicConfig(
    filename='PF_PermitCleaning.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

# Define the path to your input CSV file
input_file = r'S:\Common\Comptroller Tech\Reports\Permits\August PF Permits 2024.csv'

# Define the path to the output directory
output_dir = r'S:\Common\Comptroller Tech\Reports\Permits'

# Define the column letters to keep
columns_to_keep = ["A", "B", "E", "J", "P", "Q", "S", "T", "W"]

# Function to convert column letters to indices (0-based)
def column_letter_to_index(letter):
    index = 0
    for i, char in enumerate(reversed(letter)):
        index += (ord(char) - ord('A') + 1) * (26 ** i)
    return index - 1

# Function to remove accents from a string
def remove_accents(input_str):
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    return "".join([c for c in nfkd_form if not unicodedata.combining(c)])

try:
    # Load the CSV file
    logging.info(f"Loading CSV file from {input_file}")
    df = pd.read_csv(input_file)

    # Convert column letters to indices
    columns_to_keep_indices = [column_letter_to_index(col) for col in columns_to_keep]

    # Keep only the specified columns by indices
    df = df.iloc[:, columns_to_keep_indices]
    logging.info(f"Columns retained: {columns_to_keep}")

    # Remove specific strings from the 'Address' column
    if 'Address' in df.columns:
        df['Address'] = df['Address'].str.replace(', POST FALLS, ID 83854', '', regex=False)
        df['Address'] = df['Address'].str.replace(', COEUR D ALENE, ID 83854', '', regex=False)
        logging.info("Removed specific strings from 'Address' column")
    else:
        logging.warning("'Address' column not found in the data")

    # Create a new column 'Permit_Type' with the first 4 characters of column 'Record #'
    if 'Record #' in df.columns:
        df['Permit_Type'] = df['Record #'].astype(str).str[:4]
        logging.info("Created 'Permit_Type' column from the first 4 characters of column 'Record #'")
    else:
        logging.warning("'Record #' column not found in the data")

    # Remove dashes from the 'Mbl' column
    if 'Mbl' in df.columns:
        df['Mbl'] = df['Mbl'].str.replace('-', '', regex=False)
        logging.info("Removed dashes from 'Mbl' column")
    else:
        logging.warning("'Mbl' column not found in the data")

    # Add 'Preliminary Permit_Type' column based on conditions
    def determine_preliminary_permit_type(row):
        permit_type = row['Permit_Type']
        type_of_work = row.get('Type of Work', '')  # Use .get() to handle missing columns gracefully

        if permit_type == 'MECH':
            return '9'
        elif permit_type == 'DEMO':
            return '6'
        elif permit_type == 'BLDC':
            if type_of_work == 'New Construction':
                return '2'
            elif type_of_work in ['Roofing/Siding/Windows', 'Solar']:
                return '9'
            elif type_of_work in ['Alteration/Addition', 'Addition', 'Alteration', 'Tenant Improvement/Alt']:
                return '3'
            elif type_of_work == 'Swimming Pool':
                return '5'
            else:
                return '5'
        elif permit_type == 'BLDR':
            if type_of_work == 'New Construction':
                return '1'
            elif type_of_work in ['Roofing/Siding/Windows', 'Solar']:
                return '9'
            elif type_of_work in ['Alteration/Addition', 'Addition', 'Alteration', 'Tenant Improvement/Alt']:
                return '3'
            elif type_of_work == 'Swimming Pool':
                return '5'
            else:
                return '5'
        return None

    if 'Permit_Type' in df.columns:
        df['Preliminary Permit_Type'] = df.apply(determine_preliminary_permit_type, axis=1)
        logging.info("Added 'Preliminary Permit_Type' column based on specified conditions")
    else:
        logging.warning("'Permit_Type' column not found in the data")

    # Read the SQL query from Excel
    sql_query_path = r"S:\Common\Comptroller Tech\Reports\!Appraisal Reports\Parcel_Selection.xlsx"
    sql_query_df = pd.read_excel(sql_query_path)

    # Filter out rows with null values in 'Situs_Address', 'PIN', or 'AIN' from the Excel data
    if 'Situs_Address' in sql_query_df.columns:
        sql_query_df = sql_query_df.dropna(subset=['Situs_Address', 'PIN', 'AIN'])
        logging.info("Filtered Parcel Selection data to remove rows with null 'Situs_Address', 'PIN', or 'AIN'")

        # Merge the DataFrames on "Address" and "Situs_Address"
        merged_df = df.merge(sql_query_df[['Situs_Address', 'PIN', 'AIN']], right_on='Situs_Address', left_on='Address', how='left')
        logging.info("Merged data with Parcel Selection.xlsx on 'Address' and 'Situs_Address'")
    else:
        logging.warning("'Situs_Address' column not found in Parcel Selection.xlsx")
        merged_df = df  # If no merge, keep the original DataFrame

    # Remove accents from the 'Proposed Description' column
    if 'Proposed Description' in merged_df.columns:
        merged_df['Proposed Description'] = merged_df['Proposed Description'].apply(remove_accents)
        logging.info("Removed accent characters from 'Proposed Description' column")
    else:
        logging.warning("'Proposed Description' column not found in the data")

    # Format 'Permit/License Issued Date' as a short date
    if 'Permit/License Issued Date' in merged_df.columns:
        merged_df['Permit/License Issued Date'] = pd.to_datetime(merged_df['Permit/License Issued Date'], errors='coerce').dt.strftime('%Y-%m-%d')
        logging.info("Formatted 'Permit/License Issued Date' to short date format")
    else:
        logging.warning("'Permit/License Issued Date' column not found in the data")

    # Reorder and add columns to fit the exact order specified
    final_columns = [
        'PIN', 'Record #', 'Valuation', 'Square Footage', 'Permit/License Issued Date',
        'Callback_Date', 'Inactive_Date', 'Date_Cert_Occ', 'Proposed Description',
        'Preliminary Permit_Type', 'Permit_Source', 'Phone #', 'permit_char3', 'status_code',
        'permit_char20b', 'permit_int2', 'permit_int3', 'permit_int4', 'Perm_Service_Date', 'Permit_Fee'
    ]

    # Add new columns with default values
    merged_df['Callback_Date'] = ''
    merged_df['Inactive_Date'] = ''
    merged_df['Date_Cert_Occ'] = ''
    merged_df['Permit_Source'] = 'PF'
    merged_df['Phone #'] = ''
    merged_df['permit_char3'] = ''
    merged_df['status_code'] = 'A'
    merged_df['permit_char20b'] = ''
    merged_df['permit_int2'] = 0
    merged_df['permit_int3'] = 0
    merged_df['permit_int4'] = 0
    merged_df['Perm_Service_Date'] = ''
    merged_df['Permit_Fee'] = ''

    # Ensure only the specified columns are kept
    final_df = merged_df[final_columns]

    # Save the final DataFrame to a new CSV file
    final_output_filename = f'final_{os.path.basename(input_file)}'
    final_output_file = os.path.join(output_dir, final_output_filename)
    final_df.to_csv(final_output_file, index=False)
    logging.info(f"Final CSV file with specified column order has been created: {final_output_file}")
    print(f"Final CSV file with specified column order has been created: {final_output_file}")

except Exception as e:
    logging.error(f"An error occurred: {e}")
    print(f"An error occurred: {e}")