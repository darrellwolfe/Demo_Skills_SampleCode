import os

pdf_path = r'S:/Common/Comptroller Tech/Reports/Permits - Import/Permits_CompTechImports/_Manual_IDL/ERL95S0870A-EncraochmentPermit-2024-10-09.pdf'

if os.path.exists(pdf_path):
    print("Path is correct, file found!")
else:
    print("Error: Path is incorrect or file not found.")
