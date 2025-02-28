
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
import re # The import re statement in Python imports the regular expressions (regex) module, which provides a powerful way to search, match, and manipulate strings based on patterns.
import sys # Contains basic Python commands regarding runtime and formatting; used for exiting code

#### CAPS LOCK
def is_capslock_on():
    # This will return 1 if CAPS LOCK is on, 0 if it's off
    hllDll = ctypes.WinDLL("User32.dll")
    VK_CAPITAL = 0x14
    return hllDll.GetKeyState(VK_CAPITAL) & 1

def ensure_capslock_off():
    if is_capslock_on():
        pyautogui.press('capslock')
        logging.info("CAPS LOCK was on. It has been turned off.")
    else:
        logging.info("CAPS LOCK is already off.")


"""
# GLOBAL LOGICS - CONNECTIONS
"""


### Logging
#'S:/Common/Comptroller Tech/Reports/Python/Auto_Mapping_Packet/MappingPacketsAutomation.log'

#This log will pull through to my working folder when I push git changes.... 
#'C:/Users/dwolfe/Documents/Kootenai_County_Assessor_CodeBase-1/Working_Darrell\Logs_Darrell/MappingPacketsAutomation.log'

#mylog_filename = 'C:/Users/dwolfe/Documents/Kootenai_County_Assessor_CodeBase-1/Working_Darrell\Logs_Darrell/MappingPacketsAutomation.log'
mylog_filename = 'S:/Common/Comptroller Tech/Reports/Python/Auto_Mapping_Packet/MappingPacketsAutomation.log'

logging.basicConfig(
    filename = mylog_filename,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)


class AINLogProcessor:
    def __init__(self, log_filename):
        self.log_filename = log_filename
        self.unique_ains = set()
        self.today_date = datetime.now().strftime('%Y-%m-%d')
        self.pattern = re.compile(r'Sent AIN (\d{6})')

    def process_log(self):
        # Open and read the log file
        with open(self.log_filename, 'r') as log_file:
            for line in log_file:
                # Check if the line contains today's date
                if self.today_date in line:
                    # Search for the pattern in the line
                    match = self.pattern.search(line)
                    if match:
                        # Add the matched AIN to the set
                        self.unique_ains.add(match.group(1))

    def get_unique_ains(self):
        # Convert the set to a sorted list if needed
        return sorted(self.unique_ains)

    def print_unique_ains(self):
        unique_ains_list = self.get_unique_ains()
        print(f"Unique AINs count for {self.today_date}: {len(unique_ains_list)}")
        for ain in unique_ains_list:
            print(ain)

# Call AINLogProcessor
if __name__ == "__main__":
    # Create an instance of the AINLogProcessor
    log_processor = AINLogProcessor(mylog_filename)

    # Call these where you want the print out in the LOG:
    # Process the log file
    #log_processor.process_log()

    # Print the unique AINs
    #log_processor.print_unique_ains()




### Kill Script

# Global flag to indicate if the script should be stopped
stop_script = False

def monitor_kill_key():
    global stop_script
    logging.info("Kill key monitor started. Press 'esc' to stop the script.")
    keyboard.wait('esc')  # Set 'esc' as the kill key
    stop_script = True
    logging.info("Kill key pressed. Stopping the script...")
    sys.exit("Script terminated")

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
def execute_query(cursor, query, params=None):
    if params:
        cursor.execute(query, params)
    else:
        cursor.execute(query)
    return cursor.fetchall()



### Graphic User Interface (GUI) Logic - START

# Initialize variables to avoid 'NameError', will call them into the final product after variable selections
MemoTXT = ""
PDESC = ""

# Get today's date in mm/dd/yyyy format
today_date = datetime.now().strftime("%m/%d/%Y")
# You can then use `today_date` in your code wherever you need the formatted date
logging.info(f"Today's date is: {today_date}")


def on_submit():
    ensure_capslock_off()

    global AINLIST, AINFROM, PDESC, PFILE, PNUMBER, TREVIEW, MappingPacketType, Initials, MemoTXT, ForYear, PLATCOMBO, LANDTYPE, LEGENDTYPE, AIN_Exclude

    # Collect inputs for AINFROM and split by commas
    AINFROM = [ain.strip() for ain in entry_ainfrom.get().strip().upper().split(",")]


    # Combine the AINFROM and AINTO lists, removing duplicates
    combined_ain_list = list(set(AINFROM) - set(AIN_Exclude))
    AINLIST = combined_ain_list

    # Creates an exclude list to be either excluded from AINLIST when that is the parameter for SQL query, or from the PLATCOMBO when that is used (see query below)
    AIN_Exclude = [ain.strip() for ain in entry_ainexclude.get().strip().upper().split(",")]


    # Collect PLAT inputs
    PLATCOMBO = entry_platcombo.get().strip().upper()
    LANDTYPE = combobox_landtype.get().strip().upper()
    LEGENDTYPE = entry_legendtype.get().strip().upper()

    # Collect other inputs
    PFILE = entry_pfile.get().strip().upper()
    PNUMBER = entry_pnumber.get().strip().upper()
    TREVIEW = entry_treview.get().strip().upper()
    MappingPacketType = combobox_mappingpackettype.get().strip().upper()
    Initials = entry_initials.get().strip().upper()
    ForYear = for_year_combobox.get().strip()  # Get the selected year

    the_month = datetime.now().month
    the_day = datetime.now().day
    the_year = datetime.now().year


    AINFROM_str = ', '.join(AINFROM)
    PLATCOMBO_str = PLATCOMBO

    if TREVIEW in ["Yes", "YES", "Y", "y"]:
        logging.info("Timber YES.")
        MemoTXT = f"{Initials}-{the_month}/{str(the_year)[-2:]} {MappingPacketType} from {AINFROM_str} into {PLATCOMBO_str} for {ForYear} TIMBER REVIEW REQUIRED"
    else:
        MemoTXT = f"{Initials}-{the_month}/{str(the_year)[-2:]} {MappingPacketType} from {AINFROM_str} into {PLATCOMBO_str} for {ForYear}"

    logging.info(f"Generated MemoTXT: {MemoTXT}")

    PDESC = f"{MappingPacketType} for {ForYear}"

    if not PFILE or not PNUMBER or not TREVIEW or not MappingPacketType or not Initials or not MemoTXT or not PDESC or not PLATCOMBO or not LANDTYPE or not LEGENDTYPE:
        messagebox.showerror("Input Error", "All input fields are required.")
        return
    
    root.destroy()  # Close the GUI

def setup_gui():
    root = tk.Tk()
    root.title("User Input Form")
    setup_widgets(root)
    return root

def validate_initials(action, value_if_allowed):
    # Allow only alphabetic characters and limit to 3 characters
    if action == '1':  # 1 means an insertion operation
        if len(value_if_allowed) > 3:
            return False
        return value_if_allowed.isalpha()
    return True

def setup_widgets(root):
    global entry_ainfrom, entry_pfile, entry_pnumber, entry_treview, combobox_mappingpackettype, entry_initials, for_year_combobox, entry_ainexclude, entry_platcombo, combobox_landtype, entry_legendtype

    # Get the current and next year
    current_year = datetime.now().year
    next_year = current_year + 1

    # AINFROM input
    ttk.Label(root, text="List AINs FROM_PARENTs (separated by comma):").grid(column=0, row=0, padx=10, pady=5)
    entry_ainfrom = ttk.Entry(root, width=50)
    entry_ainfrom.grid(column=1, row=0, padx=10, pady=5)


    # New Input Fields for PLATCOMBO, LANDTYPE, and LEGENDTYPE
    ttk.Label(root, text="Enter the first 5 digits of the PLAT (PLATCOMBO):").grid(column=0, row=2, padx=10, pady=5)
    entry_platcombo = ttk.Entry(root, width=50)
    entry_platcombo.grid(column=1, row=2, padx=10, pady=5)

    ttk.Label(root, text="Enter Land Type (e.g., URBAN, RURAL, CA_COMMON_AREAS_CONDOS, C_CAREA, COMMERCIAL, WASTE):").grid(column=0, row=3, padx=10, pady=5)
    combobox_landtype = ttk.Combobox(root, values=["RES_URBAN", "RES_RURAL", "CA_COMMON_AREAS_CONDOS", "C_CAREA", "COMMERCIAL"], width=47)
    combobox_landtype.grid(column=1, row=3, padx=10, pady=5)
    combobox_landtype.current(0)  # Set default selection to the first item

    ttk.Label(root, text="Enter Legend Type (Just the legend number, e.g., 1 for Legend 1):").grid(column=0, row=4, padx=10, pady=5)
    entry_legendtype = ttk.Entry(root, width=50)
    entry_legendtype.grid(column=1, row=4, padx=10, pady=5)

    # Mapping packet year selection
    ttk.Label(root, text="Mapping packet FOR what year?:").grid(column=0, row=5, padx=10, pady=5)
    for_year_combobox = ttk.Combobox(root, values=[current_year, next_year], width=47)
    for_year_combobox.grid(column=1, row=5, padx=10, pady=5)
    for_year_combobox.current(0)  # Set default selection to the current year

    # Filing Date
    ttk.Label(root, text="Filing Date (Top Date):").grid(column=0, row=6, padx=10, pady=5)
    entry_pfile = ttk.Entry(root, width=50)
    entry_pfile.grid(column=1, row=6, padx=10, pady=5)

    # Permit Number
    ttk.Label(root, text="Permit Number (Bottom Date):").grid(column=0, row=7, padx=10, pady=5)
    entry_pnumber = ttk.Entry(root, width=50)
    entry_pnumber.grid(column=1, row=7, padx=10, pady=5)

    # Timber or AG review
    ttk.Label(root, text="Timber or AG review? Y/N:").grid(column=0, row=8, padx=10, pady=5)
    entry_treview = ttk.Entry(root, width=50)
    entry_treview.grid(column=1, row=8, padx=10, pady=5)

    # Mapping Packet Type
    ttk.Label(root, text="Select Mapping Packet Type:").grid(column=0, row=9, padx=10, pady=5)
    mapping_packet_types = ["NEW PLAT"]
    combobox_mappingpackettype = ttk.Combobox(root, values=mapping_packet_types, width=47)
    combobox_mappingpackettype.grid(column=1, row=9, padx=10, pady=5)
    combobox_mappingpackettype.current(0)  # Set default selection to the first item

    # Initials with validation
    vcmd = (root.register(validate_initials), '%d', '%P')
    ttk.Label(root, text="Enter (3) Initials:").grid(column=0, row=10, padx=10, pady=5)
    entry_initials = ttk.Entry(root, width=50, validate='key', validatecommand=vcmd)
    entry_initials.grid(column=1, row=10, padx=10, pady=5)
    entry_initials.insert(0, "DGW")


    # AIN_Exclude input
    ttk.Label(root, text="Exclude these AINs (separated by comma) [Only use if starting over from the middle]:").grid(column=0, row=11, padx=10, pady=5)
    entry_ainexclude = ttk.Entry(root, width=50)
    entry_ainexclude.grid(column=1, row=11, padx=10, pady=5)


    # Submit Button
    submit_button = ttk.Button(root, text="Submit", command=on_submit)
    submit_button.grid(column=0, row=12, columnspan=2, pady=20)

root = setup_gui()

### Graphic User Interface (GUI) Logic - END

# Function to count the number of AINs in AINLIST
def count_ains(ain_list):
    return len(ain_list)

# Example usage after collecting AINs in the GUI:
#ain_count = count_ains(AINLIST)
#logging.info(f"Total number of AINs: {ain_count}")
















"""
# Start the GUI event loop
"""
root.mainloop()


........


stop_script

ain_count = count_ains(AINLIST)
logging.info(f"Total number of AINs processed in this packet: {ain_count}")

# Close the cursor and connection
cursor.close()
logging.info("Cursor Closed")
conn.close()
logging.info("Database Connection Closed")

# Call these where you want the print out in the LOG:
# Process the log file
log_processor.process_log()

# Print the unique AINs
log_processor.print_unique_ains()

logging.info("ALL_STOP_NEXT")
