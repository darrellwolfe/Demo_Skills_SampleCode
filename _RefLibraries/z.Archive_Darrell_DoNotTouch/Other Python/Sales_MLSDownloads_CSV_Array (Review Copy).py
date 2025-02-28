import pandas as pd
import os

# Define the directory path containing CSV files
directory_path = "S:/Common/Comptroller Tech/Reporting Tools/Reports (MLS Downloads)/Flex MLS"

# List all non-hidden CSV files in the directory
csv_files = [f for f in os.listdir(directory_path) if not f.startswith('.') and f.endswith('.csv')]

# Read and concatenate all CSV files into one DataFrame, specifying an encoding
df_combined = pd.concat([pd.read_csv(os.path.join(directory_path, file), encoding='ISO-8859-1') for file in csv_files])

# Rename columns and apply transformations as needed
df_combined.rename(columns={
    'Source.Name': 'Source Name',
    # Add other necessary renaming here
}, inplace=True)

# Optionally specify data types for each column
# df_combined = df_combined.astype({
#     'List Number': 'str',
#     'Agency Name': 'str',
#     # Specify other data types as needed
# })

# Save or further process your DataFrame
df_combined.to_csv("C:/Users/dwolfe/Documents/Kootenai_County_Assessor_CodeBase-1/_dataframes/combined_data_MLSDownloads.csv", index=False)

