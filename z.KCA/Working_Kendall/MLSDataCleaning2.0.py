import csv
import os
import logging
from datetime import datetime
import time
import pandas as pd

# Set up logging
logging.basicConfig(
    filename='MLS_Data_Cleaning.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

# Define the path to your input CSV file
input_file = r'S:\Common\Comptroller Tech\Reports\MLS\textexport.csv'

# Define the path to the output directory
output_dir = r'S:\Common\Comptroller Tech\Reports\MLS'

# Define the column letters to keep
columns_to_keep = ["A", "I", "V", "AF", "AK", "AL", "AM", "AN", "AO", "AP", "AU", "AZ", "BD", "BI", "BJ", "BP", "BQ", "BT", "BZ", "CC"]

# Function to convert column letters to indices (0-based)
def column_letter_to_index(letter):
    index = 0
    for i, char in enumerate(reversed(letter)):
        index += (ord(char) - ord('A') + 1) * (26 ** i)
    return index - 1

# Convert column letters to indices
columns_to_keep_indices = [column_letter_to_index(col) for col in columns_to_keep]

# Get the current date for the output filename
current_date = datetime.now().strftime("%Y%m%d")

# Create the output filename
output_filename = f'modified_{current_date}_{os.path.basename(input_file)}'
output_file = os.path.join(output_dir, output_filename)

# Read the input CSV and write the filtered data to a new file
with open(input_file, 'r', newline='') as infile, open(output_file, 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)

    for row in reader:
        # Keep only the columns specified
        filtered_row = [row[index] for index in columns_to_keep_indices]
        writer.writerow(filtered_row)

logging.info(f"Modified CSV file has been created: {output_file}")
print(f"Modified CSV file has been created: {output_file}")

# Wait for the modified file to be created
while not os.path.exists(output_file):
    time.sleep(1)

# Define the columns to concatenate (E to J)
columns_to_concatenate = ["E", "F", "G", "H", "I", "J"]
columns_to_concatenate_indices = [column_letter_to_index(col) for col in columns_to_concatenate]

# Create the final output filenames
final_output_filename = f'final_{current_date}_{os.path.basename(input_file)}'
final_output_file = os.path.join(output_dir, final_output_filename)

# Read the modified CSV and write the concatenated data to a new file
with open(output_file, 'r', newline='') as infile, open(final_output_file, 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)

    header = next(reader)
    new_header = header[:columns_to_concatenate_indices[0]] + ['Address'] + header[columns_to_concatenate_indices[-1]+1:]
    writer.writerow(new_header)

    for row in reader:
        concatenated_values = ' '.join([row[index] for index in range(columns_to_concatenate_indices[0], columns_to_concatenate_indices[-1]+1) if index < len(row)])
        new_row = row[:columns_to_concatenate_indices[0]] + [concatenated_values] + row[columns_to_concatenate_indices[-1]+1:]
        writer.writerow(new_row)

logging.info(f"Final CSV file with concatenated columns has been created: {final_output_file}")
print(f"Final CSV file with concatenated columns has been created: {final_output_file}")

# Read the SQL query from Excel
sql_query_path = r"S:\Common\Comptroller Tech\Reports\!Appraisal Reports\Miscellaneous_ParcelSelection.xlsx"
sql_query_df = pd.read_excel(sql_query_path)

# Read the final CSV file into a DataFrame
final_csv_df = pd.read_csv(final_output_file)

# Merge the DataFrames on "Legal_Description" and "Legal"
merged_df = final_csv_df.merge(sql_query_df[['PIN', 'AIN']], left_on='Parcel Number', right_on='PIN', how='left')
logging.info(f"Loading query...")

# Separate matched and unmatched rows
matched_df = merged_df[merged_df['AIN'].notna()].copy()
unmatched_df = merged_df[merged_df['AIN'].isna()].copy()

# Drop the extra "PIN" column from both DataFrames
matched_df.drop(columns=['PIN'], inplace=True)
unmatched_df.drop(columns=['PIN', 'AIN'], inplace=True)

# Create filenames for matched and unmatched data
matched_filename = f'matched_{current_date}_{os.path.basename(input_file)}'
unmatched_filename = f'unmatched_{current_date}_{os.path.basename(input_file)}'
matched_file = os.path.join(output_dir, matched_filename)
unmatched_file = os.path.join(output_dir, unmatched_filename)

# Write the matched and unmatched DataFrames to separate CSV files
matched_df.to_csv(matched_file, index=False)
unmatched_df.to_csv(unmatched_file, index=False)

logging.info(f"Matched CSV file has been created: {matched_file}")
logging.info(f"Unmatched CSV file has been created: {unmatched_file}")
print(f"Matched CSV file has been created: {matched_file}")
print(f"Unmatched CSV file has been created: {unmatched_file}")

print("Process completed successfully.")