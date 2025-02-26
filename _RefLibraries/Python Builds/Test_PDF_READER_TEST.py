import pdfplumber
import pandas as pd
from openpyxl import load_workbook

def extract_data_from_pdf(pdf_path):
    data = []
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            text = page.extract_text()
            if text:
                # Extract relevant fields (e.g., AIN, Reference, SF, Date, Description)
                lines = text.split('\n')
                for line in lines:
                    # Example of pattern matching for lines that contain specific fields
                    # You may need to adjust this based on your PDF format.
                    if 'AIN' in line:
                        # Extracting values from the line
                        fields = line.split()  # Assuming space-separated values
                        data.append(fields)
    return data

# Example usage
pdf_path = 'S:/Common/Comptroller Tech/Reports/Permits - Import/Permits_CompTechImports/_Manual_IDL/ERL95S0870A-EncraochmentPermit-2024-10-09.pdf'
data = extract_data_from_pdf(pdf_path)


print(data)