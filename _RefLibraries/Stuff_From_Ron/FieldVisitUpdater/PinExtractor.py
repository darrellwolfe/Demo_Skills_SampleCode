import os
import pandas as pd
import tkinter as tk
from tkinter import filedialog

# Hide the main tkinter window
root = tk.Tk()
root.withdraw()

# Prompt user to select the CSV file
print("Please select the CSV file.")
csv_file_path = filedialog.askopenfilename(
    title="Select CSV File",
    filetypes=[("CSV files", "*.csv"), ("All files", "*.*")]
)

if not csv_file_path:
    print("No file selected. Exiting.")
    exit()

# Specify the output directory and file name
output_dir = r'C:\Users\rmason\Code\Repositories\KCAsrCB\Working_Ron\FieldVisitUpdater'
output_file = 'pins.txt'

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

# Full path for the output file
output_path = os.path.join(output_dir, output_file)

try:
    # Read the CSV file, skipping the header row
    data = pd.read_csv(csv_file_path, header=0)
    
    # Extract column A (first column) as a list
    column_a_data = data.iloc[:, 0].tolist()
    
    # Write the data to the output file
    with open(output_path, 'w') as f:
        for item in column_a_data:
            f.write(f"{item}\n")
    
    print(f"File '{output_file}' has been created/updated in the specified directory.")
except FileNotFoundError:
    print(f"Error: The CSV file '{csv_file_path}' was not found.")
except Exception as e:
    print(f"An error occurred: {str(e)}")

input("Press Enter to exit...")