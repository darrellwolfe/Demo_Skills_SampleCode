import pandas as pd
import logging
import os

# Set up logging
logging.basicConfig(
    filename='CDA_PermitCleaning.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

# Define the path to your input CSV file
input_file = r'S:\Common\Comptroller Tech\Reports\Permits\CDA\Permit_Issued_2024_6.csv'

# Define the path to the output directory
output_dir = r'S:\Common\Comptroller Tech\Reports\Permits'

# Define the column letters to keep
columns_to_keep = ["A", "B", "C", "E", "F", "G", "H", "I", "J", "R"]

# Function to convert column letters to indices (0-based)
def column_letter_to_index(letter):
    index = 0
    for i, char in enumerate(reversed(letter)):
        index += (ord(char) - ord('A') + 1) * (26 ** i)
    return index - 1

try:
    # Load the CSV file
    logging.info(f"Loading CSV file from {input_file}")
    df = pd.read_csv(input_file)

    # Convert column letters to indices
    columns_to_keep_indices = [column_letter_to_index(col) for col in columns_to_keep]

    # Keep only the specified columns by indices
    df = df.iloc[:, columns_to_keep_indices]
    logging.info(f"Columns retained: {columns_to_keep}")

    # 1. Concatenate columns F, G, H, and I
    try:
        df['Combined Address'] = df.iloc[:, 4:8].apply(lambda x: ' '.join(x.dropna().astype(str)), axis=1)
        logging.info("Created 'Combined Address' column")
    except Exception as e:
        logging.error(f"Error creating 'Combined Address' column: {e}")

    # 2. Add 'Permit_Type' column
    try:
        def get_permit_type(permit_number):
            if pd.isna(permit_number):
                return ''
            if str(permit_number).endswith('D'):
                return '6'
            elif str(permit_number).endswith('M1'):
                return '9'
            return ''

        df['Permit_Type'] = df['Permit Number'].apply(get_permit_type)
        logging.info("Created 'Permit_Type' column")
    except Exception as e:
        logging.error(f"Error creating 'Permit_Type' column: {e}")

    # 3. Read SQL query from Excel and merge
    try:
        sql_query_path = r"S:\Common\Comptroller Tech\Reports\!Appraisal Reports\Parcel_Selection.xlsx"
        sql_query_df = pd.read_excel(sql_query_path)

        if 'Situs_Address' in sql_query_df.columns:
            sql_query_df = sql_query_df.dropna(subset=['Situs_Address', 'PIN', 'AIN'])
            logging.info("Filtered Parcel Selection data to remove rows with null 'Situs_Address', 'PIN', or 'AIN'")

            merged_df = df.merge(sql_query_df[['Situs_Address', 'PIN', 'AIN']], right_on='Situs_Address', left_on='Combined Address', how='left')
            logging.info("Merged data with Parcel Selection.xlsx on 'Combined Address' and 'Situs_Address'")
        else:
            logging.warning("'Situs_Address' column not found in Parcel Selection.xlsx")
            merged_df = df  # If no merge, keep the original DataFrame
    except Exception as e:
        logging.error(f"Error reading SQL query from Excel or merging data: {e}")
        merged_df = df  # Use original DataFrame if there's an error

    # Format 'issuedDate' as a short date
    if 'issuedDate' in merged_df.columns:
        try:
            merged_df['issuedDate'] = pd.to_datetime(merged_df['issuedDate'], errors='coerce').dt.strftime('%Y-%m-%d')
            logging.info("Formatted 'issuedDate' to short date format")
        except Exception as e:
            logging.error(f"Error formatting 'issuedDate': {e}")
    else:
        logging.warning("'issuedDate' column not found in the data")

    # Reorder and add columns to fit the exact order specified
    final_columns = [
        'PIN', 'Permit Number', 'project_valuation', 'Total SQFT', 'issuedDate', 'Callback_Date', 'Inactive_Date', 'Date_Cert_Occ', 'project_description',
        'Permit_Type', 'Permit_Source', 'Phone #', 'permit_char3', 'status_code',
        'permit_char20b', 'permit_int2', 'permit_int3', 'permit_int4', 'Perm_Service_Date', 'Permit_Fee', 'Combined Address'
    ]

    # Add new columns with default values
    new_columns = {
        'Callback_Date': '',
        'Inactive_Date': '', 
        'Date_Cert_Occ': '', 
        'Permit_Source': 'CDA',
        'Phone #': '', 
        'permit_char3': '', 
        'status_code': 'A', 
        'permit_char20b': '',
        'permit_int2': 0, 
        'permit_int3': 0, 
        'permit_int4': 0, 
        'Perm_Service_Date': '', 
        'Permit_Fee': ''
    }

    for col, default_value in new_columns.items():
        if col not in merged_df.columns:
            merged_df[col] = default_value

    # Ensure only the specified columns are kept
    final_df = merged_df.reindex(columns=final_columns)

    # Save the final DataFrame to a new CSV file
    final_output_filename = f'final_{os.path.basename(input_file)}'
    final_output_file = os.path.join(output_dir, final_output_filename)
    final_df.to_csv(final_output_file, index=False)
    logging.info(f"Final CSV file with specified column order has been created: {final_output_file}")
    print(f"Final CSV file with specified column order has been created: {final_output_file}")

except Exception as e:
    logging.error(f"An error occurred: {e}")
    print(f"An error occurred: {e}")