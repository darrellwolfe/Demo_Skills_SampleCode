# After ensuring all packages are installed, you can import them as needed in your script
# Standard Library Imports
import os  # For interacting with the operating system, such as reading/writing files
import sys  # Contains basic Python commands regarding runtime and formatting; used for exiting code
import time  # For adding delays and managing time-related functions
import logging  # For logging events, errors, and information during script execution
import configparser  # For handling configuration files (.ini)
import threading  # For running background tasks and creating concurrent threads
import ctypes  # For interacting with C data types and Windows API functions
import re  # For regular expressions, provides a powerful way to search, match, and manipulate strings based on patterns
from datetime import datetime, date  # For handling dates and times

# Third-Party Library Imports
import pyautogui  # For automating GUI interactions like mouse movements and clicks
import pyodbc  # For establishing database connections and executing SQL queries
import numpy as np  # For numerical operations and handling arrays/matrices
import keyboard  # For detecting and handling keyboard key presses
import pytesseract  # For OCR (Optical Character Recognition) to read text from images
import cv2  # From the OpenCV library, used for image processing and computer vision tasks
import pygetwindow as gw  # For interacting with window properties, such as getting window titles or bringing windows to the foreground
from PIL import Image, ImageGrab  # For working with image files and capturing screenshots
from pywinauto import Application  # For automating Windows GUI interactions, providing more advanced desktop app control

# Tkinter and Related Imports
import tkinter as tk  # For creating basic GUI elements in Python applications
from tkinter import ttk, messagebox, scrolledtext  # For advanced Tkinter widgets, dialog boxes, and scrollable text widgets
from tkcalendar import DateEntry, Calendar  # For adding calendar widgets to Tkinter GUIs



"""
# GLOBAL LOGICS - CONNECTIONS
"""


### Logging



### Logging Setup
# Determine the user's home directory
user_home_dir = os.environ.get('USERPROFILE') or os.environ.get('HOME')

# Update LogNameHere to your actual log name
log_name = 'MappingPackets_Segs'
log_dir = os.path.join(user_home_dir, log_name)
log_file = os.path.join(log_dir, f'{log_name}.log')

# Ensure the log directory exists
os.makedirs(log_dir, exist_ok=True)

logging.basicConfig(
    filename=log_file,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

# Roaming Directory for Configurations
roaming_dir = os.path.join(os.environ.get('APPDATA', ''), log_name)
os.makedirs(roaming_dir, exist_ok=True)

CONFIG_FILE = os.path.join(roaming_dir, 'config.ini')
DEFAULT_PROVAL_PATH = "C:/Program Files (x86)/Thomson Reuters/ProVal/ProVal.exe"

# Sample Variable
# variable_here = "I Am A Variable"

# Logging Examples
logging.info("Starting the ProVal Automation Script")
logging.info(f"Using the default ProVal path: {DEFAULT_PROVAL_PATH}")
# logging.info(f"Variable value: {variable_here}")



# This counts the AINs sent within your log, makes a unique list, and counts the list to show you how many you did today
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
    log_processor = AINLogProcessor(log_name)

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

# To use in script
# ensure_capslock_off()




# Just call this in your final script
# stop_script 

# Or this
# if stop_script:
#     logging.info("Script stopping due to kill key press.")
#     stop_script




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


### Graphic User Interface (GUI) Logic - START

# Initialize variables to avoid 'NameError', will call them into the final product after variable selections
MemoTXT = ""
PDESC = ""
the_month = datetime.now().month
the_day = datetime.now().day
the_year = datetime.now().year

def calculate_for_year():
    current_date = datetime.now()
    if current_date.month > 4 or (current_date.month == 4 and current_date.day >= 16):
        return current_date.year + 1
    else:
        return current_date.year

def on_submit():
    ensure_capslock_off()

    global AINLIST, AINFROM, AINTO, PDESC, PFILE, PNUMBER, TREVIEW, MappingPacketType, Initials, MemoTXT, ForYear

    # Collect inputs for AINFROM and AINTO, and split by commas
    AINFROM = [ain.strip() for ain in entry_ainfrom.get().strip().upper().split(",")]
    AINTO = [ain.strip() for ain in entry_ainto.get().strip().upper().split(",")]

    # Creates an exclude list to be either excluded from AINLIST when that is the parameter for SQL query, or from the PLATCOMBO when that is used (see query below)
    AIN_Exclude = [ain.strip() for ain in entry_ainexclude.get().strip().upper().split(",")]

    # Combine the AINFROM and AINTO lists, removing duplicates
    combined_ain_list = list(set(AINFROM + AINTO) - set(AIN_Exclude))

    # Combine the AINFROM and AINTO lists, removing duplicates
    AINLIST = combined_ain_list


    PFILE = entry_pfile.get().strip().upper()
    PNUMBER = entry_pnumber.get().strip().upper()
    TREVIEW = entry_treview.get().strip().upper()
    MappingPacketType = combobox_mappingpackettype.get().strip().upper()
    Initials = entry_initials.get().strip().upper()
    ForYear = for_year_combobox.get().strip()  # Get the selected year

    the_month = datetime.now().month
    the_day = datetime.now().day
    the_year = datetime.now().year
    
    #the_month = datetime.datetime.now().month
    #the_day = datetime.datetime.now().day
    #the_year = datetime.datetime.now().year


    AINFROM_str = ', '.join(AINFROM)
    AINTO_str = ', '.join(AINTO)
    MemoTXT = f"{Initials}-{the_month}/{str(the_year)[-2:]} {MappingPacketType} from {AINFROM_str} into {AINTO_str} for {ForYear}"
    logging.info(f"Generated MemoTXT: {MemoTXT}")

    PDESC = f"{MappingPacketType} for {ForYear}"

    if not AINFROM or not AINTO or not PFILE or not PNUMBER or not TREVIEW or not MappingPacketType or not Initials or not PDESC:
        # Does not need to include AIN_Exclude
        messagebox.showerror("Input Error", "All input fields are required.")
        stop_script

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
    global entry_ainfrom, entry_ainto, entry_pfile, entry_pnumber, entry_treview, combobox_mappingpackettype, entry_initials, for_year_combobox, entry_ainexclude

    # Calculate the "FOR" year dynamically
    for_year = calculate_for_year()

    ttk.Label(root, text="Mapping packet FOR what year?:").grid(column=0, row=0, padx=10, pady=5)
    for_year_combobox = ttk.Combobox(root, values=[for_year], width=47)
    for_year_combobox.grid(column=1, row=0, padx=10, pady=5)
    for_year_combobox.current(0)  # Set default selection to the calculated year


    # Validation for the Initials Entry
    vcmd = (root.register(validate_initials), '%d', '%P')
    
    ttk.Label(root, text="Enter (3) Initials:").grid(column=0, row=1, padx=10, pady=5)
    entry_initials = ttk.Entry(root, width=50, validate='key', validatecommand=vcmd)
    entry_initials.grid(column=1, row=1, padx=10, pady=5)
    entry_initials.insert(0, "DGW")



    ttk.Label(root, text="Select Mapping Packet Type:").grid(column=0, row=2, padx=10, pady=5)
    
    mapping_packet_types = [
        "MERGE", "SPLIT", "BLA", "LLA", "RW VACATION", "RW SPLIT", "REDESCRIBE",
        "RW AUDIT", "RW Cat19", "AIRPORT LEASE NEW PARCEL", "PLAT VACATION",
        "PARCEL DELETED", "ACERAGE AUDIT", "NEW PLAT"
    ]
    combobox_mappingpackettype = ttk.Combobox(root, values=mapping_packet_types, width=47)
    combobox_mappingpackettype.grid(column=1, row=2, padx=10, pady=5)
    combobox_mappingpackettype.current(0)  # Set default selection to the first item




    ttk.Label(root, text="Filing Date (Top Date):").grid(column=0, row=3, padx=10, pady=5)
    entry_pfile = ttk.Entry(root, width=50)
    entry_pfile.grid(column=1, row=3, padx=10, pady=5)

    ttk.Label(root, text="Permit Number (Bottom Date):").grid(column=0, row=4, padx=10, pady=5)
    entry_pnumber = ttk.Entry(root, width=50)
    entry_pnumber.grid(column=1, row=4, padx=10, pady=5)




    # AINFROM input
    ttk.Label(root, text="List AINs FROM (separated by comma):").grid(column=0, row=5, padx=10, pady=5)
    entry_ainfrom = ttk.Entry(root, width=50)
    entry_ainfrom.grid(column=1, row=5, padx=10, pady=5)

    # AINTO input
    ttk.Label(root, text="List AINs TO (separated by comma):").grid(column=0, row=6, padx=10, pady=5)
    entry_ainto = ttk.Entry(root, width=50)
    entry_ainto.grid(column=1, row=6, padx=10, pady=5)



    ttk.Label(root, text="Timber or AG review? Y/N:").grid(column=0, row=7, padx=10, pady=5)
    entry_treview = ttk.Entry(root, width=50)
    entry_treview.grid(column=1, row=7, padx=10, pady=5)




    # AIN_Exclude input
    ttk.Label(root, text="Exclude these AINs (separated by comma) [Only use if starting over from the middle]:").grid(column=0, row=8, padx=10, pady=5)
    entry_ainexclude = ttk.Entry(root, width=50)
    entry_ainexclude.grid(column=1, row=8, padx=10, pady=5)

    submit_button = ttk.Button(root, text="Submit", command=on_submit)
    submit_button.grid(column=0, row=9, columnspan=2, pady=20)

root = setup_gui()

### Graphic User Interface (GUI) Logic - END


# Function to count the number of AINs in AINLIST
def count_ains(ain_list):
    return len(ain_list)

# Example usage after collecting AINs in the GUI:
#ain_count = count_ains(AINLIST)
#logging.info(f"Total number of AINs: {ain_count}")


"""
# GLOBAL LOGICS - LOGIC FUNCTIONS
"""

#### SET FOCUS
def set_focus(window_title):
    windows = pyautogui.getWindowsWithTitle(window_title)
    if windows:
        window = windows[0]
        window.activate()
        logging.info(f"Set focus to window: {window_title}")
        return True
    else:
        logging.warning(f"Window not found: {window_title}")
        return False





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

#### Land Type Press Down Function
def press_land_key(LANDTYPE):
    # Define the mapping of LANDTYPE to the number of DOWN key presses
    land_key_mapping = {
        "RES_RURAL": 3,
        "RES_URBAN": 4,
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
        520: "20", 541: "20",
        515: "15", 537: "15",
        512: "12", 534: "12",
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
permits_feildperson = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_feildperson.PNG'


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
allocations_31Rural = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_31Rural_.PNG'
allocations_32Urban = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_32Urban_.PNG'
allocations_82Waste = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_82Waste_.PNG'
allocations_91RemAcres = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_91RemAcres_.PNG'
allocations_11Commercial = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_11Commercial_.PNG'
allocations_C_Carea = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_C_Carea_.PNG'
allocations_CA_CommonAreaCondos = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_allocations_CA_CommonAreaCondos_.PNG'


#PopUps
popup_Error_LandDetailError_MissingLine = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_popup_Error_LandDetailError_MissingLine.PNG'






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



def ProValAinLookUp():
    # Process: Open an AIN in ProVal
    set_focus("ProVal")
    time.sleep(1)
    logging.info("set_focus")

    pyautogui.hotkey('ctrl', 'o')
    time.sleep(1)
    logging.info("hotkey")

    press_key_multiple_times('up', 12)
    logging.info("press_key_multiple_times")
    
    press_key_multiple_times('down', 4)
    logging.info("press_key_multiple_times")
    
    pyautogui.press(['tab'])
    logging.info("press")
    
    pyautogui.press(['delete'])
    logging.info("press")
    
    pyautogui.typewrite(str(DBAIN))
    logging.info(f"Sent AIN {DBAIN}.")
    time.sleep(1)

    pyautogui.press('enter')
    time.sleep(1)
    logging.info("Close Pop-Up, Open the {DBAIN}}")


    set_focus("ProVal")
    time.sleep(1)
    logging.info("set_focus")
    
    #Maximize Window
    # Simulate the Windows + Up Arrow key combination to maximize the window
    pyautogui.hotkey('win', 'up')

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        

    ensure_capslock_off()
    logging.info("ensure_capslock_off.")


def LandBaseer():

    # Click Land_Tab
    if click_images_multiple(land_tab_images, direction='center', offset=100, confidence=0.75):
        logging.info("Clicked successfully land_tab_images.")
    else:
       stop_script
    check_stop_script()
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        stop_script
    check_stop_script()
    # Click Land_Base_Tab
    if click_images_multiple(land_base_tab_images, direction='center', confidence=0.75):
        logging.info("Clicked successfully land_base_tab_images.")
    else:
       stop_script

    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        stop_script
    
    check_stop_script()
    
    # Check if the image is found and decide based on that
    if is_image_found(farm_total_acres_image, confidence=0.75):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found

        # Click to the right of Farm Acres
        if click_image_single(farm_total_acres_image, direction='right', offset=15, confidence=0.75):
            logging.info("Clicked successfully farm_total_acres_image.")
        time.sleep(1)

        # Delete the contents and send DBACRE
        pyautogui.press('delete')
        time.sleep(1)

        ensure_capslock_off()
        time.sleep(1)

        pyautogui.typewrite(str(DBLEGALACRES))
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        if stop_script:
            logging.info("Script stopping due to kill key press.")
            stop_script
            check_stop_script()
        logging.info("farm_total_acres_image Image was not found - executing alternative tasks.")
        # Perform alternative tasks
        check_stop_script()
    # Click to the right of Farm Acres
    elif click_image_single(aggregate_land_type_add_button, direction='bottom_right_corner', inset=10, confidence=0.75):
        logging.info("Clicked successfully aggregate_land_type_add_button.")
        time.sleep(1)

        ensure_capslock_off()
        time.sleep(1)

        # Send the DBACRE value after clicking the fallback button
        pyautogui.typewrite('f')
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        ensure_capslock_off()
        time.sleep(1)

        pyautogui.typewrite(str(DBLEGALACRES))
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

    else:
       stop_script

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        stop_script
        
        check_stop_script()
        # Save Account
        pyautogui.hotkey('ctrl', 's')
        logging.info("Save.")
        time.sleep(2)

        check_stop_script()

    check_stop_script()


def LandDetailErrorCheck():

    # Check if the image is found and decide based on that
    if is_image_found(popup_Error_LandDetailError_MissingLine, confidence=0.75):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found

        set_focus("Land Detail Error")
        time.sleep(1)
        logging.info("set_focus")

        # Press Alt + N for No
        pyautogui.hotkey('alt', 'n')

        set_focus("ProVal")
        time.sleep(1)
        logging.info("set_focus")
    
        response = messagebox.askyesno("Fix Error", "Have you fixed the error? Do you want to continue?")
        if response:
            logging.info("User clicked Yes")
        else:
            logging.info("User clicked No")


    else:
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            stop_script
            check_stop_script()
        
        check_stop_script()





global DBLRSN, DBAIN, DBLEGALACRES, DBLANDBASE, DBLANDBASETYPE

# Declare globals at the module level (outside any function)
DBLRSN = None
DBAIN = None
DBLEGALACRES = None
DBLANDBASE = None
DBLANDBASETYPE = None

# Your database connection code
conn = connect_to_database(db_connection_string)
cursor = conn.cursor()
check_stop_script()

# The query should accommodate multiple AINs in a list
query = f"""
WITH CTE_ParcelMaster AS (
Select Distinct
pm.lrsn,
TRIM(pm.AIN) AS AIN,
pm.LegalAcres
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
),

CTE_LandBaseChecker AS (
Select Distinct
lh.RevObjId AS lrsn,
--ag.AggregateSize,
ag.AggregateType,
COUNT(lh.RevObjId) AS Instances
FROM LandHeader AS lh  
JOIN LBAggregateSize AS ag 
    ON lh.Id=ag.LandHeaderId 
    AND ag.EffStatus='A'
    AND ag.PostingSource='A'
WHERE lh.EffStatus='A' 
    AND lh.PostingSource='A'
    --CTE ParcelMaster already filtered for 'A'
GROUP BY ag.AggregateType, lh.RevObjId
)


SELECT DISTINCT
pmd.lrsn
,pmd.AIN
,pmd.LegalAcres
,ag.AggregateSize
,ag.AggregateType

FROM CTE_ParcelMaster AS pmd

LEFT JOIN LandHeader AS lh  
    ON lh.RevObjId=pmd.lrsn

    LEFT JOIN LBAggregateSize AS ag 
        ON lh.Id=ag.LandHeaderId 
        AND ag.EffStatus='A'
        AND ag.PostingSource='A'

LEFT JOIN CTE_LandBaseChecker AS checker
    ON checker.lrsn = pmd.lrsn


WHERE lh.EffStatus='A' 
    AND lh.PostingSource='A'
    --CTE ParcelMaster already filtered for 'A'
    AND ((ag.AggregateSize = 0
        OR ag.AggregateSize IS NULL)
        OR pmd.LegalAcres <> ag.AggregateSize)
    AND pmd.LegalAcres <> 0
    AND checker.Instances IS NULL

ORDER BY ag.AggregateSize DESC, pmd.LegalAcres DESC;

"""
rows = execute_query(cursor, query)
logging.info("SQL_Query")

check_stop_script()

for row in rows:
    DBLRSN, DBAIN, DBLEGALACRES, DBLANDBASE, DBLANDBASETYPE = row

    check_stop_script()

    stop_script

    logging.info(f"SQL GRM_Main Varaibles Created:")

    #SQL Query
    logging.info(f"DBAIN: {DBLRSN}")
    logging.info(f"DBACRE: {DBAIN}")
    logging.info(f"AINLIST: {DBLEGALACRES}")
    logging.info(f"AINFROM: {DBLANDBASE}")
    logging.info(f"AINTO: {DBLANDBASETYPE}")

    check_stop_script()



    # LookUp AINs
    ProValAinLookUp()
    check_stop_script()
    time.sleep(1)



    LandBaseer()
    check_stop_script()
    time.sleep(1)


    check_stop_script()
    # Save Account
    pyautogui.hotkey('ctrl', 's')
    logging.info("Save.")
    time.sleep(2)

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        stop_script
        
    check_stop_script()



    LandDetailErrorCheck()


    check_stop_script()
    # Save Account
    pyautogui.hotkey('ctrl', 's')
    logging.info("Save.")
    time.sleep(2)

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        stop_script
        
    check_stop_script()




    # END ALL PROCESSESS
    logging.info("THE END...")
    time.sleep(1)

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        stop_script
        
    check_stop_script()


set_focus("Visual Studio Code")
logging.info("Visual Studio Code")


# Close the cursor and connection
cursor.close()
logging.info("Cursor Closed")
conn.close()
logging.info("Database Connection Closed")
