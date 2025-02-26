
"""
import subprocesspip
import pkg_resources
import sys

def install_if_missing(package):
    try:
        pkg_resources.get_distribution(package)
    except pkg_resources.DistributionNotFound:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])

# List of packages you want to ensure are installed
packages = [
    "pyautogui",       # For automating GUI interactions
    "pyodbc",          # For database connections
    "numpy",           # For numerical operations
    "keyboard",        # For detecting key presses
    "pytesseract",     # For OCR (Optical Character Recognition)
    "Pillow",          # For image processing related to Image
    "opencv-python",   # For image processing (cv2)
    "tkcalendar"       # For calendar widget in Tkinter
]

# Apply the install_if_missing function to each package
for package in packages:
    install_if_missing(package)
"""
# After ensuring all packages are installed, you can import them as needed in your script
import pyautogui  # For automating GUI interactions like mouse movements and clicks
import pyodbc  # For establishing database connections and executing SQL queries
import time  # For adding delays and managing time-related functions
import numpy as np  # For numerical operations and handling arrays/matrices
import keyboard  # For detecting and handling keyboard key presses
import threading  # For running background tasks and creating concurrent threads
import tkinter as tk  # For creating basic GUI elements in Python applications
from tkinter import ttk, messagebox  # For advanced Tkinter widgets and displaying dialog boxes
import pytesseract  # For OCR (Optical Character Recognition) to read text from images
from PIL import Image  # For working with image data
import cv2  # For image processing and computer vision tasks (OpenCV library)
import ctypes  # For interacting with C data types and Windows API functions
from tkcalendar import DateEntry  # For adding a calendar widget to Tkinter GUIs
import logging  # For logging events, errors, and information during script execution
from datetime import datetime # For handling dates and times


"""
# GLOBAL LOGICS - CONNECTIONS
"""


### Logging

logging.basicConfig(
    filename='S:/Common/Comptroller Tech/Reports/Python/Auto_Mapping_Packet/MappingPacketsAutomation.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)


### Kill Script

# Global flag to indicate if the script should be stopped
stop_script = False

def monitor_kill_key():
    global stop_script
    logging.info("Kill key monitor started. Press 'esc' to stop the script.")
    keyboard.wait('esc')  # Set 'esc' as the kill key
    stop_script = True
    logging.info("Kill key pressed. Stopping the script...")

# Start the kill key monitoring in a separate thread
kill_key_thread = threading.Thread(target=monitor_kill_key)
kill_key_thread.daemon = True
kill_key_thread.start()


### Connections: Database

# Configuration for database connection
db_connection_string = (
    "Driver={SQL Server};"
    "Server=astxdbprod;"
    "Database=GRM_Main;"
    "Trusted_Connection=yes;"
)

# Function to connect to the database
def connect_to_database(connection_string):
    return pyodbc.connect(connection_string)

# Function to execute a SQL query and fetch data
def execute_query(cursor, query):
    cursor.execute(query)
    return cursor.fetchall()




# Global DateTime
the_month = datetime.now().month
the_day = datetime.now().day
the_year = datetime.now().year

# Get today's date in mm/dd/yyyy format
today_date = datetime.now().strftime("%m/%d/%Y")

# You can then use `today_date` in your code wherever you need the formatted date
logging.info(f"Today's date is: {today_date}")


# Reference Only: MemoTXT = f"{Initials}-{the_month}/{str(the_year)[-2:]} {MappingPacketType} from {AINFROM_str} into {AINTO_str} for {ForYear}"
    # global AINLIST, AINFROM, AINTO, PDESC, PFILE, PNUMBER, TREVIEW, MappingPacketType, Initials, MemoTXT, ForYear




### Graphic User Interface (GUI) Logic - START

# Initialize variables to avoid 'NameError', will call them into the final product after variable selections

# Function to validate the initials input
def validate_initials(action, value_if_allowed):
    if action == '1':  # Insertion
        return len(value_if_allowed) <= 3 and value_if_allowed.isalpha()
    return True

# Handler for the submit button
def on_submit():
    global entry_ains, entry_file_date, combobox_permit_type, entry_permit_desc, entry_pnumber
    global AINLIST, PFILE, PDESC, PTYPE, PNUMBER  # Declare these as global if they're used outside this function

    # Ensure all fields are filled
    if not (entry_ains.get() and entry_file_date.get() and combobox_permit_type.get() and entry_permit_desc.get()):
        messagebox.showerror("Input Error", "All fields are required.")
        return

    # Extract and assign data to global variables
    AINLIST = list(set(entry_ains.get().strip().upper().split(",")))
    PFILE = entry_file_date.get()
    PTYPE = combobox_permit_type.get()
    PNUMBER = entry_pnumber.get().strip().upper()
    PDESC = entry_permit_desc.get()

    logging.info(f"Processing new permit for AINs: {AINLIST}")
    logging.info(f"File Date: {PFILE}, Permit Type: {combobox_permit_type.get()}, Description: {PDESC}")
    
    # Optional: Display success message and/or close GUI
    messagebox.showinfo("Success", "The permit data has been processed successfully.")
    root.destroy()

# Setup the GUI elements
def setup_gui():
    global root, entry_ains, entry_file_date, combobox_permit_type, entry_permit_desc, entry_pnumber
    root = tk.Tk()
    root.title("New Permit Input Form")
    
    # AINs Input
    ttk.Label(root, text="Enter AINs (comma-separated):").grid(row=0, column=0, padx=10, pady=5)
    entry_ains = ttk.Entry(root, width=50)
    entry_ains.grid(row=0, column=1, padx=10, pady=5)

    # File Date Input
    ttk.Label(root, text="File Date:").grid(row=1, column=0, padx=10, pady=5)
    entry_file_date = DateEntry(root, width=47, background='darkblue', foreground='white', borderwidth=2)
    entry_file_date.grid(row=1, column=1, padx=10, pady=5)

    # Permit Number
    ttk.Label(root, text="Permit Reference Number:").grid(column=0, row=4, padx=10, pady=5)
    entry_pnumber = ttk.Entry(root, width=50)
    entry_pnumber.grid(row=3, column=1, padx=10, pady=5)

    # Permit Type Dropdown
    ttk.Label(root, text="Select Permit Type:").grid(row=2, column=0, padx=10, pady=5)
    permit_types = [
        "New Dwelling Permit", "New Commercial Permit", "Addition/Alt/Remodel Permit",
        "Outbuilding/Garage Permit", "Miscellaneous Permit", "Mandatory Review",
        "Roof/Siding/Wind/Mech Permit", "Agricultural Review", "Timber Review",
        "Assessment Review", "Seg/Combo", "Dock/Boat Slip Permit", "PP Review",
        "Mobile Setting Permit", "Potential Occupancy"
    ]
    combobox_permit_type = ttk.Combobox(root, values=permit_types, width=47)
    combobox_permit_type.grid(row=2, column=1, padx=10, pady=5)
    combobox_permit_type.current(0)

    # Permit Description Input
    ttk.Label(root, text="Permit Description:").grid(row=3, column=0, padx=10, pady=5)
    entry_permit_desc = ttk.Entry(root, width=50)
    entry_permit_desc.grid(row=3, column=1, padx=10, pady=5)

    # Submit Button
    submit_button = ttk.Button(root, text="Submit", command=on_submit)
    submit_button.grid(row=4, column=0, columnspan=2, pady=20)

    return root


### Graphic User Interface (GUI) Logic - END