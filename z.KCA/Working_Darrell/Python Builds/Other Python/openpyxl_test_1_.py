import csv
import openpyxl
from pathlib import Path

# Create a new Excel workbook and select the active worksheet
wb = openpyxl.Workbook()
ws = wb.active

# Define the path to the directory containing the CSV files
csv_directory_path = Path('S:\Common\Comptroller Tech\Reports\Permits - Import\Permits_CompTechImports\CDA')

# Iterate over each CSV file in the directory
for csv_file in csv_directory_path.glob('*.csv'):
    with csv_file.open('r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file)
        for row in reader:
            ws.append(row)

# Save the workbook to a new Excel file
wb.save('combined.xlsx')
