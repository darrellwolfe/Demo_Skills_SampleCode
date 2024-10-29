
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
from PIL import Image, ImageGrab  # For working with image data
import cv2  # For image processing and computer vision tasks (OpenCV library)
import ctypes  # For interacting with C data types and Windows API functions
from tkcalendar import DateEntry  # For adding a calendar widget to Tkinter GUIs
import logging  # For logging events, errors, and information during script execution
from datetime import datetime # For handling dates and times
import re # The import re statement in Python imports the regular expressions (regex) module, which provides a powerful way to search, match, and manipulate strings based on patterns.
import sys # Contains basic Python commands regarding runtime and formatting; used for exiting code
import pygetwindow as gw # Instead, you should use the pygetwindow library, which provides the getWindowsWithTitle method.



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

mylog_filename = 'C:/Users/dwolfe/Documents/Kootenai_County_Assessor_CodeBase-1/Working_Darrell\Logs_Darrell/PlatMappingPacketsAutomation.log'
#mylog_filename = 'S:/Common/Comptroller Tech/Reports/Python/Auto_Mapping_Packet/PlatMappingPacketsAutomation.log'

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


def check_stop_script():
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        sys.exit("Script terminated")


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
PLATCOMBO = ""

the_month = datetime.now().month
the_day = datetime.now().day
the_year = datetime.now().year


# Get today's date in mm/dd/yyyy format
today_date = datetime.now().strftime("%m/%d/%Y")
# You can then use `today_date` in your code wherever you need the formatted date
logging.info(f"Today's date is: {today_date}")

def calculate_for_year():
    current_date = datetime.now()
    if current_date.month > 4 or (current_date.month == 4 and current_date.day >= 16):
        return current_date.year + 1
    else:
        return current_date.year

def on_submit():
    ensure_capslock_off()

    global AINFROM, PDESC, PFILE, PNUMBER, TREVIEW, MappingPacketType, Initials, MemoTXT, ForYear, PLATCOMBO, LEGENDTYPE, AIN_Exclude

    # Collect inputs for AINFROM and split by commas
    AINFROM = [ain.strip() for ain in entry_ainfrom.get().strip().upper().split(",")]

    # Collect AIN_Exclude inputs if provided
    AIN_Exclude = [ain.strip() for ain in entry_ainexclude.get().strip().upper().split(",")] if entry_ainexclude.get().strip() else []

    # Combine the AINFROM and AINTO lists, removing duplicates
    AINFROM_str = ', '.join(AINFROM) 
    # Needed for memo

    # Collect PLAT inputs
    PLATCOMBO = entry_platcombo.get().strip().upper()
    #SELECTEDLANDTYPE = combobox_landtype.get().strip().upper()
    LEGENDTYPE = entry_legendtype.get().strip().upper()

    # Collect other inputs
    PFILE = plat_date.get().strip().upper()
    PNUMBER = plat_date.get().strip().upper()
    TREVIEW = entry_treview.get().strip().upper()
    MappingPacketType = combobox_mappingpackettype.get().strip().upper()
    Initials = entry_initials.get().strip().upper()
    ForYear = for_year_combobox.get().strip()  # Get the selected year
    PDESC = f"{MappingPacketType} {PLATCOMBO} for {ForYear}"

    the_month = datetime.now().month
    the_day = datetime.now().day
    the_year = datetime.now().year

    MemoTXT = f"{Initials}-{the_month}/{str(the_year)[-2:]} {MappingPacketType} from {AINFROM_str} into {PLATCOMBO} for {ForYear}"

    logging.info(f"Generated MemoTXT: {MemoTXT}")

    # Check if any required field is empty
    if not PLATCOMBO or not LEGENDTYPE or not PFILE or not PNUMBER or not TREVIEW or not MappingPacketType or not Initials or not ForYear:
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
    global entry_ainfrom, plat_date, entry_treview, combobox_mappingpackettype, entry_initials, for_year_combobox, entry_ainexclude, entry_platcombo, entry_legendtype
    #combobox_landtype

    # Calculate the "FOR" year dynamically
    for_year = calculate_for_year()

    ttk.Label(root, text="Mapping packet FOR what year?:").grid(column=0, row=0, padx=10, pady=5)
    for_year_combobox = ttk.Combobox(root, values=[for_year], width=47)
    for_year_combobox.grid(column=1, row=0, padx=10, pady=5)
    for_year_combobox.current(0)  # Set default selection to the calculated year


    # Mapping Packet TypeNEW PLAT 0L900 for 2025 FOR APPRAISER REVIEW
    ttk.Label(root, text="Select Mapping Packet Type:").grid(column=0, row=1, padx=10, pady=5)
    mapping_packet_types = ["NEW PLAT"]
    combobox_mappingpackettype = ttk.Combobox(root, values=mapping_packet_types, width=47)
    combobox_mappingpackettype.grid(column=1, row=1, padx=10, pady=5)
    combobox_mappingpackettype.current(0)  # Set default selection to the first item


    #ttk.Label(root, text="Enter Land Type (e.g., URBAN, RURAL, CA_COMMON_AREAS_CONDOS, C_CAREA, COMMERCIAL, WASTE):").grid(column=0, row=3, padx=10, pady=5)
    #combobox_landtype = ttk.Combobox(root, values=["RES_URBAN", "RES_RURAL", "CA_COMMON_AREAS_CONDOS", "C_CAREA", "COMMERCIAL"], width=47)
    #combobox_landtype.grid(column=1, row=3, padx=10, pady=5)
    #combobox_landtype.current(0)  # Set default selection to the first item


    # Initials with validation
    vcmd = (root.register(validate_initials), '%d', '%P')
    ttk.Label(root, text="Enter (3) Initials:").grid(column=0, row=2, padx=10, pady=5)
    entry_initials = ttk.Entry(root, width=50, validate='key', validatecommand=vcmd)
    entry_initials.grid(column=1, row=2, padx=10, pady=5)
    entry_initials.insert(0, "DGW")



    # Filing Date
    ttk.Label(root, text="Date on first page of Plat packet:").grid(column=0, row=3, padx=10, pady=5)
    plat_date = ttk.Entry(root, width=50)
    plat_date.grid(column=1, row=3, padx=10, pady=5)




    # AINFROM input
    ttk.Label(root, text="List AINs FROM_PARENTs (separated by comma):").grid(column=0, row=4, padx=10, pady=5)
    entry_ainfrom = ttk.Entry(root, width=50)
    entry_ainfrom.grid(column=1, row=4, padx=10, pady=5)


    # New Input Fields for PLATCOMBO, SELECTEDLANDTYPE, and LEGENDTYPE
    ttk.Label(root, text="Enter the first 5 digits of the PLAT (PLATCOMBO):").grid(column=0, row=5, padx=10, pady=5)
    entry_platcombo = ttk.Entry(root, width=50)
    entry_platcombo.grid(column=1, row=5, padx=10, pady=5)



    ttk.Label(root, text="Enter Legend Type (Just the legend number, e.g., 1 for Legend 1):").grid(column=0, row=6, padx=10, pady=5)
    entry_legendtype = ttk.Entry(root, width=50)
    entry_legendtype.grid(column=1, row=6, padx=10, pady=5)



    # Timber or AG review
    ttk.Label(root, text="Timber or AG review? Y/N:").grid(column=0, row=7, padx=10, pady=5)
    entry_treview = ttk.Entry(root, width=50)
    entry_treview.grid(column=1, row=7, padx=10, pady=5)



    # AIN_Exclude input
    ttk.Label(root, text="Exclude these AINs (separated by comma) [Only use if starting over from the middle]:").grid(column=0, row=8, padx=10, pady=5)
    entry_ainexclude = ttk.Entry(root, width=50)
    entry_ainexclude.grid(column=1, row=8, padx=10, pady=5)


    # Submit Button
    submit_button = ttk.Button(root, text="Submit", command=on_submit)
    submit_button.grid(column=0, row=9, columnspan=2, pady=20)

root = setup_gui()

### Graphic User Interface (GUI) Logic - END




"""
# GLOBAL LOGICS - LOGIC FUNCTIONS
"""

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

#### SET FOCUS
def set_focus(window_title):
    window = gw.getWindowsWithTitle(window_title)
    if window:
        window[0].activate()

#### PRESS & CLICK KEY LOGIC
def press_key_with_modifier_multiple_times(modifier, key, times):
    for _ in range(times):
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
        pyautogui.hotkey(modifier, key)

def press_key_multiple_times(key, times):
    for _ in range(times):
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
        pyautogui.press(key)





#### Legend Press Down Key Function
def press_legend_key(LEGENDTYPE):

    # Convert LEGENDTYPE to an integer if it's not already
    try:
        LEGENDTYPE = int(LEGENDTYPE)
    except ValueError:
        logging.info(f"Invalid LEGENDTYPE: {LEGENDTYPE}. It must be an integer.")
        return

    # Define the mapping of LEGENDTYPE to the number of DOWN key presses
    legend_key_mapping = {
        1: 5,
        2: 6,
        3: 7,
        4: 8,
        5: 9,
        6: 10,
        7: 11,
        8: 12,
        9: 13,
        10: 14,
        11: 15,
        12: 16,
        13: 17,
        # Logic breaks here but this is how ProVal was built
        14: 20,
        15: 21,
        16: 22,
        17: 23,
        18: 24,
        19: 25,
        # Logic breaks here but this is how ProVal was built
        20: 18,
        21: 19
    }

    # Get the number of DOWN key presses corresponding to LEGENDTYPE
    presses = legend_key_mapping.get(LEGENDTYPE)

    if presses:
        # Press the DOWN key the specified number of times
        pyautogui.press('down', presses)
    else:
        logging.info(f"LEGENDTYPE {LEGENDTYPE} not found in mapping.")
        logging.info(f"LEGENDTYPE value: {LEGENDTYPE}, type: {type(LEGENDTYPE)}")

    # Example usage:
    # LEGENDTYPE = 1
    # press_legend_key(LEGENDTYPE)



def determine_land_type(pcc_code):
    # Mapping of PCC codes to Land Types
    land_type_mapping = {
        # Residential
        520: "RES_URBAN", 541: "RES_HOMESITE",
        # Temporary Adjustment for HL891
        #520: "RES_URBAN", 541: "CA_COMMON_AREAS_CONDOS",

        515: "RES_RURAL", 537: "RES_HOMESITE",
        512: "RES_RURAL", 534: "RES_HOMESITE",
        525: "C_CAREA",
        526: "CA_COMMON_AREAS_CONDOS",
        
        # Commercial
        421: "COMMERCIAL_CITY_LIMITS", 442: "COMMERCIAL_CITY_LIMITS",
        416: "COMMERCIAL_RURAL_SUBDIVISION", 438: "COMMERCIAL_RURAL_SUBDIVISION",
        413: "COMMERCIAL_RURAL_TRACT", 435: "COMMERCIAL_RURAL_TRACT",
        527: "COMMERCIAL_CONDO",
        
        # Industrial
        322: "INDUSTRIAL_CITY_LIMITS", 343: "INDUSTRIAL_CITY_LIMITS",
        317: "INDUSTRIAL_RURAL_SUBDIVISION", 339: "INDUSTRIAL_RURAL_SUBDIVISION",
        314: "INDUSTRIAL_RURAL_TRACT", 336: "INDUSTRIAL_RURAL_TRACT"

    }
    
    # Return the Land Type based on the PCC code
    return land_type_mapping.get(pcc_code, "UNKNOWN")


#### Land Type Press Down Function
def press_land_key(LANDTYPE):
    # Define the mapping of LANDTYPE to the number of DOWN key presses
    land_key_mapping = {
        "RES_RURAL": 3,
        "RES_URBAN": 4,
        "RES_HOMESITE" : 14,
        "CA_COMMON_AREAS_CONDOS": 22,
        "C_CAREA": 21,
        "COMMERCIAL": 1,
        "WASTE": 13,
        "REMAINING_ACRES": 16,
        "DEFAULT": 21
    }

    logging.info(f"LANDTYPE value: {LANDTYPE}, type: {type(LANDTYPE)}")

    # Determine the number of DOWN key presses
    # presses = land_key_mapping.get(LANDTYPE, land_key_mapping["DEFAULT"])
    presses = land_key_mapping[LANDTYPE]  # This will raise a KeyError if LANDTYPE is not found

    # Press the DOWN key the specified number of times
    pyautogui.press('down', presses)
    
    # Press ENTER to confirm the selection
    pyautogui.press('enter')

    # Example usage:
    #LANDTYPE = "RURAL"
    #press_land_key(LANDTYPE)


def determine_group_code(pcc_code):
    # Mapping of PCC codes to Land Group Codes
    group_codes = {

        # Residential
        520: "20", 541: "20H",
        515: "15", 537: "15H",
        512: "12", 534: "12H",
        525: "25L",
        526: "26LH",
        
        # Commercial
        421: "21", 442: "21",
        416: "16", 438: "16",
        413: "13", 435: "13",
        527: "27L",

        # Industrial
        322: "22", 343: "22",
        317: "17", 339: "17",
        314: "14", 336: "14",

        # Operating
        667: "67L",

        # Exempt
        681: "81L"
    }
    
    # Return the Land Group Code based on the PCC code
    return group_codes.get(pcc_code, None)

    # Example usage
    #result = determine_group_code(541)
    #result = determine_group_code(DBPCC)
    #print(f"Land Group Code for PCC 541: {result}")



def pressess_allocations(description_code):
    # Extended mapping of descriptions to the number of 'up' key presses required
    key_presses = {
        #"01 Irr (Agriculture)"
        "01": 30,
        #"03 Non-irr (Agriculture)"
        "03": 29,
        #"04 Irr grazing (Agriculture)"
        "04": 28,
        #"05 Dry grazing (Agriculture)"
        "05": 27,
        #"06 Prod forest (Timber Exempt)"
        "06": 26,
        #"07 Bare forest (Timber Exempt)"
        "07": 25,
        #"09 Mineral land"
        "09": 24,
        #"10-Non HO Eligible"
        "10": 23,
        #"10H Homesite"
        "10H": 22,
        #"11 Recreational"
        "11": 21,
        #"12-Non HO Eligible"
        "12": 20,
        #"12H Rural res tract"
        "12H": 19,
        #"13 Rural com tract"
        "13": 18,
        #"14 Rural ind tract"
        "14": 17,
        #"15-Non HO Eligible"
        "15": 16,
        #"15H Rural res sub"
        "15H": 15,
        #"16 Rural com sub"
        "16": 14,
        #"17 Rural ind sub"
        "17": 13,
        #"18 Other land-flooded"
        "18": 12,
        #"19 Public ROW"
        "19": 11,
        #"20-Non HO Eligible"
        "20": 10,
        #"20H City res lot/ac"
        "20H": 9,
        #"21 City com lot/ac"
        "21": 8,
        #"22 City ind lot/ac"
        "22": 7,
        #"25L Common area land"
        "25L": 6,
        #"26LH Res Condo land"
        "26LH": 4,
        #"27L Comm Condo land"
        "27L": 3,
        #"67L Operating prop land"
        "67L": 2,
        #"81L Exempt property land"
        "81L": 1,
        #"98 Non-Allocated Impv"
        "98": 0,  # Assuming it's the same as 99 for now
        #"99 Non-Allocated Land"
        "99": 0
    }
    
    # Return the number of 'up' key presses for the given description code
    return key_presses.get(description_code, 0)  # Return 0 if not found

    # Using this below in script
    #description_code = "15"  # Set the description code based on your scenario
    #description_code = determine_group_code(f"{DBPCC}")  # Set the description code based on your scenario
    #num_presses = pressess_allocations(description_code)
    #press_key_multiple_times('up', num_presses)


"""
# GLOBAL LOGICS - SCREEN HANDLING FUNCTIONS
"""

### Connections: OCR and Image Paths

#### OCR

# This OCR program is required to work with this script, it is available on GitHub
# Set the tesseract executable path if not in the system path
# Update this path as necessary by user you will need to download and install tesseract from GitHub
# Link https://github.com/tesseract-ocr/tesseract
# Link https://github.com/UB-Mannheim/tesseract/wiki
pytesseract.pytesseract.tesseract_cmd = r'C:\Users\dwolfe\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'



#### Image Paths

# Open Account Scr
active_parcels_only_needchecked = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_open_active_parcels_only.PNG'
active_parcels_only_checked = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_open_active_parcels_only_checked.PNG'


# Memos
duplicate_memo_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memo_duplicate.PNG'
memos_land_information_ = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memos_land_information_.PNG'


# Permits
permits_tab_images = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_tab.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_tab_active.PNG'
]

permits_add_permit_button = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_permit_button.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_permit_button_active.PNG'
]

add_field_visit_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_fieldvisit_button.PNG'
permit_description = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permit_description.PNG'
permits_workassigneddate = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_workassigneddate.PNG'
permit_type = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permit_type.PNG'
permits_inactivatebutton = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_inactivatebutton.PNG'


# Land 
land_tab_images = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_tab.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_tab_active.PNG'
]
land_base_tab_images = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_base_tab.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_base_tab_active.PNG'
]
land_detail_image = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_detail_.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_detail_active.PNG'
]

aggregate_land_type_add_button = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_aggregate_land_type_add_button.PNG'
farm_total_acres_image = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_farm_total_acres.PNG'


# Allocations
allocations_9homesite_ = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_9homesite_.PNG'
allocations_31Rural = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_31Rural_.PNG'
allocations_32Urban = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_32Urban_.PNG'
allocations_82Waste = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_82Waste_.PNG'
allocations_91RemAcres = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_91RemAcres_.PNG'
allocations_11Commercial = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_11Commercial_.PNG'
allocations_C_Carea = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_C_Carea_.PNG'
allocations_CA_CommonAreaCondos = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_CA_CommonAreaCondos_.PNG'


# 1 CAPTURE SCREEN IN GREYSCALE
def capture_and_convert_screenshot():
    # Capture the screenshot using pyautogui
    # screenshot = pyautogui.screenshot()
    screenshot = ImageGrab.grab(all_screens=True)

    # Convert the screenshot to a numpy array, then to BGR, and finally to greyscale
    screenshot_np = np.array(screenshot)
    screenshot_np = cv2.cvtColor(screenshot_np, cv2.COLOR_RGB2BGR)
    grey_screenshot = cv2.cvtColor(screenshot_np, cv2.COLOR_BGR2GRAY)

    return grey_screenshot


# 1.5 
def get_window_region(window_title):
    try:
        window = gw.getWindowsWithTitle(window_title)[0]
        left, top, right, bottom = window.left, window.top, window.right, window.bottom
        return (left, top, right, bottom)
    except IndexError:
        logging.error(f"Window with title '{window_title}' not found.")
        return None


# 2 CLICK USING A REFERENCE GREYSCALE SCREENSHOT TO A STORED GREYSCALE IMAGE INCLUDES ABILITY TO CLICK RELATIVE POSITION
def click_on_image(image_path, direction='center', offset=0, inset=0, confidence=0.75, region=None):

    global click_positions

    # Capture the screenshot using pyautogui
    screenshot = ImageGrab.grab(bbox=region) if region else ImageGrab.grab(all_screens=True)

    # Convert the screenshot to a numpy array, then to BGR, and finally to greyscale
    screenshot_np = np.array(screenshot)
    screenshot_np = cv2.cvtColor(screenshot_np, cv2.COLOR_RGB2BGR)
    grey_screenshot = cv2.cvtColor(screenshot_np, cv2.COLOR_BGR2GRAY)

    # Load the reference image in greyscale
    ref_image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if ref_image is None:
        logging.error(f"Failed to load reference image from {image_path}")
        return False

    # Perform template matching
    result = cv2.matchTemplate(grey_screenshot, ref_image, cv2.TM_CCOEFF_NORMED)
    _, max_val, _, max_loc = cv2.minMaxLoc(result)

    if max_val >= confidence:
        top_left = max_loc
        h, w = ref_image.shape
        right = top_left[0] + w
        bottom = top_left[1] + h

        # Calculate click position based on direction and inset/offset
        click_positions = {
            'right': (right + offset, top_left[1] + h // 2),
            'left': (top_left[0] - offset, top_left[1] + h // 2),
            'above': (top_left[0] + w // 2, top_left[1] - offset),
            'below': (top_left[0] + w // 2, bottom + offset),
            'bottom_right_corner': (right - inset, bottom - inset),
            'bottom_left_corner': (top_left[0] + inset, bottom - inset),
            'top_right_corner': (right - inset, top_left[1] + inset),
            'top_left_corner': (top_left[0] + inset, top_left[1] + inset),
            'bottom_center': (top_left[0] + w // 2, bottom - inset),
            'top_center': (top_left[0] + w // 2, top_left[1] + inset),
            'center': (top_left[0] + w // 2, top_left[1] + h // 2)
        }
    if max_val >= confidence:
        top_left = max_loc
        h, w = ref_image.shape
        right = top_left[0] + w
        bottom = top_left[1] + h

        # Calculate click position based on direction and inset/offset
        click_positions = {
            'right': (right + offset, top_left[1] + h // 2),
            'left': (top_left[0] - offset, top_left[1] + h // 2),
            'above': (top_left[0] + w // 2, top_left[1] - offset),
            'below': (top_left[0] + w // 2, bottom + offset),
            'bottom_right_corner': (right - inset, bottom - inset),
            'bottom_left_corner': (top_left[0] + inset, bottom - inset),
            'top_right_corner': (right - inset, top_left[1] + inset),
            'top_left_corner': (top_left[0] + inset, top_left[1] + inset),
            'bottom_center': (top_left[0] + w // 2, bottom - inset),
            'top_center': (top_left[0] + w // 2, top_left[1] + inset),
            'center': (top_left[0] + w // 2, top_left[1] + h // 2)
        }
        
        # Check if the direction is valid
        if direction not in click_positions:
            logging.error(f"Invalid click direction specified: {direction}")
            return False
    
        # Get the click position
        click_x, click_y = click_positions[direction]

        # Log the mex_val
        logging.info(f"Max value for image match: {max_val}, confidence threshold: {confidence}")


        # Adjust for global screen position if using a region
        if region:
            click_x += region[0]
            click_y += region[1]
            logging.info(f"Region Adjusted Click - Region bounds: {region}, Adjusted Click Position: ({click_x}, {click_y})")
        else:
            logging.info("No region specified - Defaulting to full-screen coordinates.")


        # Perform the click
        time.sleep(0.5)
        pyautogui.click(click_x, click_y, duration=0.1)
        logging.info(f"Clicked {direction} of the image at ({click_x}, {click_y})")
        return True
    
    else:
        logging.warning(f"No good match found at the confidence level of {confidence}.")
        return False
    
        """
        # Ref Function click_on_image in the following functions 3, 4, 5, etc... 
        # These reference functions can be called in the final automation script 
        """

# 3 USING click_on_image FUNCTION
#Specific Click Functions Here, See click_on_image for directionals, and image pathes for images
def click_images_multiple(paths, direction='center', offset=50, inset=7, confidence=0.75):
    for image_path in paths:
        logging.info(f"Trying to click {direction} on image: {image_path}")
        if click_on_image(image_path, direction=direction, offset=offset, inset=inset, confidence=confidence):
            logging.info(f"Successfully clicked {direction} of {image_path}.")
            return True
        else:
            logging.warning(f"Failed to click {direction} of {image_path}.")
    return False

def click_image_single(image_path, direction='center', offset=50, inset=7, confidence=0.75):
    logging.info(f"Trying to click {direction} on image: {image_path}")
    if click_on_image(image_path, direction=direction, offset=offset, inset=inset, confidence=confidence):
        logging.info(f"Successfully clicked {direction} of {image_path}.")
        return True
    else:
        logging.warning(f"Failed to click {direction} of {image_path}.")
    return False

    """
    # How to use these click_images_multiple & click_image_single functions in script
 
    # Click below all specified images
    if click_images_multiple(multiple_image_path_name_here, direction='below', offset=100, confidence=0.75):
        logging.info("Clicked successfully.")

    # Click at the center of a single image
    if click_image_single(single_image_path_name_here, direction='center', confidence=0.75):
        logging.info("Clicked successfully.")

    # Click at the bottom right corner of a single image
    if click_image_single(single_image_path_name_here, direction='bottom_right_corner', inset=10, confidence=0.75):
        logging.info("Clicked successfully.")
    
    # Click to right of permit_description, by calling offset=5 it was just barely below the image, which is what I wanted
    if click_image_single(permit_description, direction='below', offset=5, confidence=0.75):
        logging.info("Clicked successfully permit_description.")
    time.sleep(1)


    """


# 4 CHECKING IF IMAGE IS PRESENT
def is_image_found(image_path, confidence=0.75):
    """
    Check if an image is present on the screen with a specified confidence level.
    :param image_path: Path to the image file to be checked.
    :param confidence: The confidence level for the image matching.
    :return: bool - True if image is found, False otherwise.
    """
    # Use the existing function to capture and convert the screenshot
    grey_screenshot = capture_and_convert_screenshot()

    # Load the reference image in greyscale
    ref_image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if ref_image is None:
        logging.error(f"Failed to load reference image from {image_path}")
        return False

    # Perform template matching
    result = cv2.matchTemplate(grey_screenshot, ref_image, cv2.TM_CCOEFF_NORMED)
    _, max_val, _, _ = cv2.minMaxLoc(result)

    found = max_val >= confidence
    if found:
        logging.info(f"Image found with confidence {max_val}: {image_path}")
    else:
        logging.info(f"Image not found with sufficient confidence {confidence}: {image_path}")
    
    return found

    """
    # How to use the is_image_found function below in script:

    # Check if the image is found and decide based on that
    if is_image_found(image_path_name_here, confidence=0.75):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found
    else:
        logging.info("Image was not found - executing alternative tasks.")
        # Perform alternative tasks

    """


# 5a READ TEXT FROM SCREEN
# This failed but keeping in for now as reference for later, ucing OCR image reference instead
def check_for_text_on_screen(target_text):
    """
    Captures the screen, converts it to greyscale, performs OCR, and checks for the specified text.
    
    :param target_text: Text to search for in the OCR results.
    :return: True if the text is found, False otherwise.
    """
    grey_screenshot = capture_and_convert_screenshot()
    grey_screenshot_pil = Image.fromarray(grey_screenshot)  # Convert numpy array back to a PIL Image
    screen_text = pytesseract.image_to_string(grey_screenshot_pil)
    return target_text in screen_text



    """
    # How to use the check_for_text_on_screen function below in script:

    # Define the specific text you're looking for
    specific_text = "text_you_want_to_check_here"

    # Use the variable in your function call and print statements
    if check_for_text_on_screen(specific_text):
        logging.info(f"Found '{specific_text}' on the screen.")
    else:
        logging.info(f"Did not find '{specific_text}' on the screen.")
    """

# 5b READ TEXT FROM SCREEN
# This failed but keeping in for now as reference for later, ucing OCR image reference instead

class ScreenReader:
    def __init__(self):
        # You can add any initialization here if needed
        pass

    def capture_and_convert_screenshot(self):
        screenshot = pyautogui.screenshot()
        return screenshot

    def find_text_on_screen(self, text_to_find):
        screenshot = self.capture_and_convert_screenshot()
        screenshot_np = np.array(screenshot)
        gray_screenshot = cv2.cvtColor(screenshot_np, cv2.COLOR_RGB2GRAY)
        
        # Perform OCR on the screenshot
        ocr_result = pytesseract.image_to_string(gray_screenshot)
        
        # Check if the text is found in the OCR result
        if text_to_find.lower() in ocr_result.lower():
            logging.info(f"Found '{text_to_find}' on the screen.")
            return True
        else:
            logging.info(f"Did not find '{text_to_find}' on the screen.")
            return False

"""
# Create an instance of the ScreenReader class
screen_reader = ScreenReader()

# Use the methods
screenshot = screen_reader.capture_and_convert_screenshot()

# Check for text on the screen
if screen_reader.find_text_on_screen("LAND"):
    print("Found 'LAND' on the screen")
else:
    print("Did not find 'LAND' on the screen")
"""






















"""
# Start the GUI event loop
"""
root.mainloop()

stop_script

check_stop_script()












"""
Connect to the database, 
pull a simple SQL query with two columns,
then the  for row in rows assigns those columns as variables 
See PlatPackets.sql and PLATPacketsAutomation_FINAL.py for an example of a more complicated query and variable set up using the first five characters of the PIN instead of AINLIST
"""

conn = connect_to_database(db_connection_string)
cursor = conn.cursor()

# The query should accommodate multiple AINs in a list
query = f"SELECT TRIM(pm.AIN), pm.LegalAcres FROM TSBv_Parcelmaster AS pm WHERE pm.AIN IN ({','.join(AINLIST)})"
rows = execute_query(cursor, query)
logging.info("SQL_Query")


# Iterate through each row in the results
for row in rows:
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    DBAIN, DBACRE = row
    ensure_capslock_off()

    stop_script

    logging.info(f"Varaibles Created:")

    #SQL Query
    logging.info(f"DBAIN: {DBAIN}")
    logging.info(f"DBACRE: {DBACRE}")

    #User Input
    logging.info(f"AINLIST: {AINLIST}")
    logging.info(f"AINFROM: {AINFROM}")
    logging.info(f"AINTO: {AINTO}")
    logging.info(f"MappingPacketType: {MappingPacketType}")
    logging.info(f"Initials: {Initials}")
    logging.info(f"ForYear: {ForYear}")
    logging.info(f"MemoTXT: {MemoTXT}")
    logging.info(f"PDESC: {PDESC}")
    logging.info(f"PFILE: {PFILE}")
    logging.info(f"PNUMBER: {PNUMBER}")
    logging.info(f"TREVIEW: {TREVIEW}")



    stop_script
    # Process each AIN individually
    set_focus("ProVal")
    time.sleep(1)
    logging.info("set_focus(ProVal)")
    stop_script

    #Maximize Window
    # Simulate the Windows + Up Arrow key combination to maximize the window
    pyautogui.hotkey('win', 'up')
    stop_script

    """
    Officially begins the automation and screen navigation
    """


    # Process: Open an AIN in ProVal
    set_focus("ProVal")
    time.sleep(1)
    logging.info("set_focus(ProVal)")
    stop_script

    pyautogui.hotkey('ctrl', 'o')
    time.sleep(1)
    logging.info("hotkey")
    stop_script

    press_key_multiple_times('up', 12)
    logging.info("press_key_multiple_times")
    stop_script
    
    press_key_multiple_times('down', 4)
    logging.info("press_key_multiple_times")
    stop_script
    
    pyautogui.press(['tab'])
    logging.info("press")
    stop_script
    
    pyautogui.press(['delete'])
    logging.info("press")
    stop_script

    ensure_capslock_off()
    time.sleep(1)
    stop_script

    pyautogui.typewrite(str(DBAIN))
    logging.info(f"Sent AIN {DBAIN}.")
    time.sleep(1)
    stop_script

    pyautogui.press('enter')
    time.sleep(1)
    logging.info("Close Pop-Up, Open the {DBAIN}}")
    stop_script
    
    set_focus("ProVal")
    time.sleep(1)
    logging.info("set_focus(ProVal)")
    stop_script

    #Maximize Window
    # Simulate the Windows + Up Arrow key combination to maximize the window
    pyautogui.hotkey('win', 'up')
    stop_script

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        stop_script











    """
    ## NOW BEGIN AUTOMATION STEPS FOR THIS TOOL
    """

    # Process: Open Memos
    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(1)




    """
    ## START EXAMPLE EXECUTIONS TO BE REPLACE BY YOUR ACTUAL SCRIPT
    IF
    IF ELSE
    IF ELIF ELSE
    IF ELIF ELIF ELIF ELIF ELSE
    DEPENDS ON HOW MANY CONDITIONS YOU WANT
    BELOW ARE ONLY EXAMPLES
    """


    # is_image_found
    # How to use the is_image_found function below in script:
    # Check if the image is found and decide based on that
    if is_image_found(image_path_name_here, confidence=0.75):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found
        
    else:
        logging.info("Image was not found - executing alternative tasks.")
        # Perform alternative tasks




    # is_image_found + click_images_multiple
    # How to use the is_image_found function below in script:
    # Check if the image is found and decide based on that
    if is_image_found(image_path_name_here, confidence=0.75):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found
        if click_images_multiple(multiple_image_path_name_here, direction='below', offset=100, confidence=0.75):
            logging.info("Clicked successfully.")


    else:
        logging.info("Image was not found - executing alternative tasks.")
        # Perform alternative tasks




    # is_image_found + click_image_single
    # How to use the is_image_found function below in script:
    # Check if the image is found and decide based on that
    if is_image_found(image_path_name_here, confidence=0.75):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found
        if click_image_single(single_image_path_name_here, direction='bottom_right_corner', inset=10, confidence=0.75):
            logging.info("Clicked successfully.")

    else:
        logging.info("Image was not found - executing alternative tasks.")
        # Perform alternative tasks





    # click_images_multiple
    # How to use these click_images_multiple & click_image_single functions in script
    # Click below all specified images
    if click_images_multiple(multiple_image_path_name_here, direction='below', offset=100, confidence=0.75):
        logging.info("Clicked successfully.")

    # Click at the center of a single image
    if click_image_single(single_image_path_name_here, direction='center', confidence=0.75):
        logging.info("Clicked successfully.")



    # Click at the bottom right corner of a single image
    if click_image_single(single_image_path_name_here, direction='bottom_right_corner', inset=10, confidence=0.75):
        logging.info("Clicked successfully.")
        logging.info("IF_CONDITION.")
        time.sleep(1)

    elif click_image_single(permit_description, direction='below', offset=5, confidence=0.75):
        logging.info("ELIF_CONDITION.")
        time.sleep(1)

    else:
        logging.info("ELSE_CONDITION.")
        time.sleep(1)

    time.sleep(1)





    # Click to right of permit_description, by calling offset=5 it was just barely below the image, which is what I wanted
    if click_image_single(permit_description, direction='below', offset=5, confidence=0.75):
        logging.info("Clicked successfully permit_description.")
        logging.info("IF_CONDITION.")
        time.sleep(1)

    elif click_image_single(permit_description, direction='below', offset=5, confidence=0.75):
        logging.info("ELIF_CONDITION.")
        time.sleep(1)

    elif click_image_single(permit_description, direction='below', offset=5, confidence=0.75):
        logging.info("ELIF_CONDITION.")
        time.sleep(1)

    elif click_image_single(permit_description, direction='below', offset=5, confidence=0.75):
        logging.info("ELIF_CONDITION.")
        time.sleep(1)

    else:
        logging.info("ELSE_CONDITION.")
        time.sleep(1)

    time.sleep(1)





    # pyautogui.typewrite()
    pyautogui.typewrite(str(DBACRE))
    pyautogui.typewrite(str(DBAIN))
    pyautogui.typewrite(MemoTXT)
    pyautogui.typewrite(PNUMBER)
    pyautogui.typewrite('f')
    pyautogui.typewrite(f"04/01/{ForYear}")
    pyautogui.typewrite(f"{PDESC} FOR TIMBER REVIEW")
    pyautogui.typewrite('p')

    # pyautogui.hotkey()
    pyautogui.hotkey('ctrl', 'o')
    pyautogui.hotkey('ctrl', 'shift', 'm')

    # pyautogui.press()
    pyautogui.press(['tab'])
    pyautogui.press(['delete'])
    pyautogui.press('enter')
    pyautogui.press('l')
    pyautogui.press('space')
    pyautogui.press('right')

    # press_key_multiple_times
    press_key_multiple_times('up', 12)
    press_key_multiple_times('down', 4)
    press_key_multiple_times(['tab'], 3)

    # press_key_with_modifier_multiple_times
    press_key_with_modifier_multiple_times('shift', 'tab', 6)

    """
    ## END EXAMPLE EXECUTIONS TO BE REPLACE BY YOUR ACTUAL SCRIPT
    """




    









   
    # Save Account
    pyautogui.hotkey('ctrl', 's')
    logging.info("Save.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break


    # END ALL PROCESSESS
    logging.info("THE END...")
    time.sleep(1)



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



"""
Notes:


    logging.info("TEST START.")

    logging.info("TEST END.")

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break

    # TEST TEST TEST
    time.sleep(1000000)


    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break




## For testing purposes, 
# PIN: KC-DGW = AIN: 345134
# PIN: KC-DAS = AIN: 348586

345134,348586

DGW-08/24 SEG ...
SEG PACKET
01/01/2024
01/01/2025


### LEFT OFF HERE NEEDS MORE DIRECTION
    time.sleep(1000)

# Version History
# NEW v1 07/26/2024
# 07/30/2024, I give up for now, I'll circle back to this when I'm done training Pat.
# 08/07/2024, successfully used the OCR to read and nagivate several screens in ProVal. 
    # One huge key was to shift the screenshot reading to Greyscale and then actually change the stored images to Greyscale as well.
#08/13/2024, updated to include the capacity to click around images found, to the left of, right of, bottom corner of, etc. 
    # Added multiple functionalities 
    # Possibly ready for testing?
    # Added logging and tweaks to inputs
    # After running through one live mapping packet, realized the MemoTXT was including brackets and literals
    # Updated to remove these and make the MemoTXT clean
    # Should be ready to test on another nmapping packet tomorrow.
#08/20/2024, entirely new v3, streamlined, simplified, built in re-usable blocks for future templates
    # After much review and many ChatGPT conversations and many tests... v3 is ready to be used as a template for other automations
    # Next ... 
    # Write documenation and instruction manual
    # Save Template Version
    # Write a Plat version
#08/26/2024 -- Screen Text Reading is inconsistent even for basic reading. Moved to OCR for ALL if/elif/else decisions.
"""