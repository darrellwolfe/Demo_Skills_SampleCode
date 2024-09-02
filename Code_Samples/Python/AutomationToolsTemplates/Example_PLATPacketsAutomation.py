
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
def set_focus_and_type(window_title, keys):
    window = pyautogui.getWindowsWithTitle(window_title)
    if window:
        window[0].activate()
        pyautogui.typewrite(keys)

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


#### Image Paths - Active and Inactive
land_tab_images = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_tab.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_tab_active.PNG'
]
land_base_tab_images = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_base_tab.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_base_tab_active.PNG'
]
permits_tab_images = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_tab.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_tab_active.PNG'
]

permits_add_permit_button = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_permit_button.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_permit_button_active.PNG'
]

land_detail_image = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_detail_.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_land_detail_active.PNG'
]


#### Image Paths - Single Images Only
duplicate_memo_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memo_duplicate.PNG'
add_field_visit_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_fieldvisit_button.PNG'
aggregate_land_type_add_button = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_aggregate_land_type_add_button.PNG'
farm_total_acres_image = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_farm_total_acres.PNG'
permit_description = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permit_description.PNG'
active_parcels_only_needchecked = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_open_active_parcels_only.PNG'
active_parcels_only_checked = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_open_active_parcels_only_checked.PNG'
# Allocations
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
    screenshot = pyautogui.screenshot()

    # Convert the screenshot to a numpy array, then to BGR, and finally to greyscale
    screenshot_np = np.array(screenshot)
    screenshot_np = cv2.cvtColor(screenshot_np, cv2.COLOR_RGB2BGR)
    grey_screenshot = cv2.cvtColor(screenshot_np, cv2.COLOR_BGR2GRAY)

    return grey_screenshot
# 2 CLICK USING A REFERENCE GREYSCALE SCREENSHOT TO A STORED GREYSCALE IMAGE INCLUDES ABILITY TO CLICK RELATIVE POSITION
def click_on_image(image_path, direction='center', offset=10, inset=7, confidence=0.8):
    grey_screenshot = capture_and_convert_screenshot()

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
        click_x, click_y = click_positions[direction]

        # Perform the click
        pyautogui.click(click_x, click_y)
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
def click_images_multiple(paths, direction='center', offset=50, inset=7, confidence=0.75, clicks=1):
    for image_path in paths:
        logging.info(f"Trying to click {direction} on image: {image_path} with {clicks} click(s).")
        if click_on_image(image_path, direction=direction, offset=offset, inset=inset, confidence=confidence):
            for _ in range(clicks):
                pyautogui.click()  # Perform the click(s)
                time.sleep(0.1)  # Add a slight delay between clicks if double-clicking
            logging.info(f"Successfully clicked {direction} of {image_path} {clicks} time(s).")
            return True
        else:
            logging.warning(f"Failed to click {direction} of {image_path}.")
    return False

def click_image_single(image_path, direction='center', offset=50, inset=7, confidence=0.75, clicks=1):
    logging.info(f"Trying to click {direction} on image: {image_path} with {clicks} click(s).")
    if click_on_image(image_path, direction=direction, offset=offset, inset=inset, confidence=confidence):
        for _ in range(clicks):
            pyautogui.click()  # Perform the click(s)
            time.sleep(0.1)  # Add a slight delay between clicks if double-clicking
        logging.info(f"Successfully clicked {direction} of {image_path} {clicks} time(s).")
        return True
    else:
        logging.warning(f"Failed to click {direction} of {image_path}.")
    return False

    """
    # How to use these click_images_multiple & click_image_single functions in script
 
    # Click below all specified images
    if click_images_multiple(multiple_image_path_name_here, direction='below', offset=100, confidence=0.8):
        logging.info("Clicked successfully.")

    # Click at the center of a single image
    if click_image_single(single_image_path_name_here, direction='center', confidence=0.8):
        logging.info("Clicked successfully.")

    # Click at the bottom right corner of a single image
    if click_image_single(single_image_path_name_here, direction='bottom_right_corner', inset=10, confidence=0.8):
        logging.info("Clicked successfully.")
    
    # Click to right of permit_description, by calling offset=5 it was just barely below the image, which is what I wanted
    if click_image_single(permit_description, direction='below', offset=5, confidence=0.8):
        logging.info("Clicked successfully permit_description.")
    time.sleep(1)

    if click_image_single(permit_description, direction='below', offset=5, confidence=0.8):
    logging.info("Clicked successfully on permit_description.")

    if click_image_single(permit_description, direction='below', offset=5, confidence=0.8, clicks=2):
        logging.info("Double-clicked successfully on permit_description.")

    image_paths = ["image1.png", "image2.png", "image3.png"]
    if click_images_multiple(image_paths, direction='center', offset=50, confidence=0.75):
        logging.info("Successfully clicked one of the images.")

    image_paths = ["image1.png", "image2.png", "image3.png"]
    if click_images_multiple(image_paths, direction='center', offset=50, confidence=0.75, clicks=2):
        logging.info("Successfully double-clicked on one of the images.")

    """


# 4 CHECKING IF IMAGE IS PRESENT
def is_image_found(image_path, confidence=0.8):
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
    if is_image_found(image_path_name_here, confidence=0.8):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found
    else:
        logging.info("Image was not found - executing alternative tasks.")
        # Perform alternative tasks

    """


# 5 READ TEXT FROM SCREEN
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












"""
# Start the GUI event loop
"""
root.mainloop()
#not AINLIST or 
if not MemoTXT or not PDESC or not PFILE or not PNUMBER or not TREVIEW:
    logging.error("All input fields are required.")
    exit()

"""
Connect to the database, 
pull a simple SQL query with two columns,
then the  for row in rows assigns those columns as variables 
"""

# Establish the database connection
conn = connect_to_database(db_connection_string)
cursor = conn.cursor()

# Define the query with a placeholder for PLATCOMBO
query = """
Select Distinct 
    RevObjId AS lrsn,
    TRIM(PIN) AS PIN, 
    TRIM(AIN) AS AIN, 
    CAST(LEFT(Prop_Class_Descr,3) AS INT) AS PCC,
    TRIM(Prop_Class_Descr) AS Prop_Class_Descr,
    Acres, 
    Cat19AC, 
    CASE WHEN ACRES >= 1 THEN 1 ELSE ACRES - Cat19Ac END AS SITE, 
    CASE WHEN ACRES > 1 THEN ACRES - 1 - CAT19AC ELSE 0 END AS REMACRES 

From 
    KC_MAP_PlatReportBase_v 
Where 
    EffStatus = 'A' 
    AND PIN like ? 
    AND AIN NOT IN ({','.join(['?' for _ in AIN_Exclude])})

Order by 
    PIN ASC
"""
logging.info("SQL_Query")

    ## For testing purposes, 
    # PIN: KC-DGW = AIN: 345134
    # PIN: KC-DAS = AIN: 348586
    # Plat for testing 0L806
    # Plat for testing AL719
    # Inactive AIN for testing 351782
    # AL7190010260 520
    # C17700010290 343
    # C82780020020 421
    # 0L81400000J0 515
    # B0999003006B 520
    # TEST LOCATION IN SCRIPT

# Execute the query with PLATCOMBO as a parameter
params = [PLATCOMBO + '%'] + AIN_Exclude
rows = execute_query(cursor, query, params)


# Initialize a flag to identify the first AIN
first_ain_processed = False

# Iterate through each row in the results
for idx, row in enumerate(rows):
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break

    DBLRSN = row[0] 
    DBPIN = row[1]  
    DBAIN = row[2]  
    DBPCC = row[3]
    DBPCCDESCR = row [4]
    DBACRE = row[5] 
    DBCat19AC = row[6] 
    DBSITE = row[7] 
    DBREMACRES = row[8]

    try:
        # Set the description code basedon SQL result
        description_code = determine_group_code(DBPCC)  
        
        # Get the number of key presses required for the description
        num_presses = pressess_allocations(description_code)

        # Ensure CAPS LOCK is off
        ensure_capslock_off()

        # SQL Results
        logging.info(f"LRSN: {DBLRSN}")
        logging.info(f"PIN: {DBPIN}")
        logging.info(f"AIN: {DBAIN}")
        logging.info(f"PCC_CODE: {DBPCC}")
        logging.info(f"PCC_DESCR: {DBPCCDESCR}")
        logging.info(f"Acres: {DBACRE}")
        logging.info(f"Cat19AC: {DBCat19AC}")
        logging.info(f"SITE: {DBSITE}")
        logging.info(f"REMACRES: {DBREMACRES}")

        # After on_submit has gathered inputs
        logging.info(f"GROUP_CODE: {description_code}")
        logging.info(f"Presses_Up: {num_presses}")
        logging.info(f"AINLIST: {AINLIST}")
        logging.info(f"AINFROM: {AINFROM}")
        logging.info(f"PLATCOMBO: {PLATCOMBO}")
        logging.info(f"LANDTYPE: {LANDTYPE}")
        logging.info(f"LEGENDTYPE: {LEGENDTYPE}")
        logging.info(f"PFILE: {PFILE}")
        logging.info(f"PNUMBER: {PNUMBER}")
        logging.info(f"TREVIEW: {TREVIEW}")
        logging.info(f"Mapping Packet Type: {MappingPacketType}")
        logging.info(f"Initials: {Initials}")
        logging.info(f"For Year: {ForYear}")
        logging.info(f"MemoTXT: {MemoTXT}")
        logging.info(f"PDESC: {PDESC}")
        logging.info(f"LEGENDTYPE value: {LEGENDTYPE}, type: {type(LEGENDTYPE)}")

    except Exception as e:
        logging.error(f"Error processing row {row}: {e}")


    # Process each AIN individually
    set_focus_and_type('ProVal', PLATCOMBO)
    time.sleep(1)
    logging.info("set_focus_and_type")
    #Maximize Window
    # Simulate the Windows + Up Arrow key combination to maximize the window
    pyautogui.hotkey('win', 'up')

    """
    Officially begins the automation and screen navigation
    """
    

    # Process: Open an AIN in ProVal
    set_focus_and_type('ProVal', PLATCOMBO)
    time.sleep(1)
    logging.info("set_focus_and_type")
    #Maximize Window
    # Simulate the Windows + Up Arrow key combination to maximize the window
    pyautogui.hotkey('win', 'up')

    pyautogui.hotkey('ctrl', 'o')
    time.sleep(1)
    logging.info("hotkey")

    # Should land on PIN
    press_key_multiple_times('up', 12)
    logging.info("press_key_multiple_times")
    
    # Should land on AIN    
    press_key_multiple_times('down', 4)
    logging.info("press_key_multiple_times")
    time.sleep(1)

    pyautogui.press(['tab'])
    logging.info("press")
    
    pyautogui.press(['delete'])
    logging.info("press")
    
    pyautogui.typewrite(f"{DBAIN}%")
    logging.info(f"Sent DBAIN {DBAIN}.")
    time.sleep(1)

    
    # Click Active Only
    if is_image_found(active_parcels_only_checked, confidence=0.95):
        logging.info("Clicked successfully active_parcels_only_checked no further action.")
    else:
        if click_image_single(active_parcels_only_needchecked, direction='left', offset=5, confidence=0.8):
            logging.info("Clicked successfully active_parcels_only_needchecked.")
            pyautogui.press('enter')
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break


    pyautogui.press('tab')
    time.sleep(1)
    pyautogui.press('enter')
    time.sleep(1)
    logging.info(f"Close Pop-Up, Open the {PLATCOMBO}")
    # Close AIN Search Window


    # Set Focus Start Script
    set_focus_and_type('ProVal', PLATCOMBO)
    time.sleep(1)
    logging.info("set_focus_and_type")
    #Maximize Window
    # Simulate the Windows + Up Arrow key combination to maximize the window
    pyautogui.hotkey('win', 'up')

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break


    """## NOW BEGIN AUTOMATION STEPS FOR THIS TOOL"""
 

    # Process: Enter Land Farm Acres
    set_focus_and_type('ProVal', PLATCOMBO)

    # Click Land_Tab
    if click_images_multiple(land_tab_images, direction='center', offset=100, confidence=0.8):
        logging.info("Clicked successfully land_tab_images.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break


    # Click Land_Base_Tab
    if click_images_multiple(land_base_tab_images, direction='center', confidence=0.8):
        logging.info("Clicked successfully land_base_tab_images.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break


    # Check if the image is found and decide based on that
    if is_image_found(farm_total_acres_image, confidence=0.8):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found

        # Click to the right of Farm Acres
        if click_image_single(farm_total_acres_image, direction='right', offset=15, confidence=0.8):
            logging.info("Clicked successfully farm_total_acres_image.")
        time.sleep(1)

        # Delete the contents and send DBACRE
        pyautogui.press('delete')
        time.sleep(1)

        ensure_capslock_off()

        pyautogui.typewrite(str(DBACRE))
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
    else:
        logging.info("farm_total_acres_image Image was not found - executing alternative tasks.")
        # Perform alternative tasks

        # Click to the right of Farm Acres
        if click_on_image(aggregate_land_type_add_button, direction='bottom_right_corner', inset=10, confidence=0.8):
            logging.info("Clicked successfully aggregate_land_type_add_button.")
        time.sleep(1)

        # Send the DBACRE value after clicking the fallback button
        pyautogui.typewrite('f')
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        ensure_capslock_off()

        pyautogui.typewrite(str(DBACRE))
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
    
            

    # Process: Enter Land Details (LD)

    # Click Land_Detail_Tab
    if click_images_multiple(land_detail_image, direction='center', offset=100, confidence=0.8):
        logging.info("Clicked successfully land_detail_image.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break

    # Begin Land Detail
    logging.info(f"Begin Land Detail: {LANDTYPE}")


    # LANDTYPE uses the Land Type selected by user to feed the def press_land_key to determine the dropdown option in ProVal
    # Rural, Urban, CA, C, Commercial will all be selected based on this
    # However, this breaks because Commercial doesn't use Rem Acres... so I need a new logic for Commercial
    # Created an if elif else to handle the case

    if LANDTYPE in ("RES_RURAL", "RES_URBAN", "CA_COMMON_AREAS_CONDOS", "C_CAREA"):
        logging.info(f"Residential: {LANDTYPE}")

        # LD_1 Process: Site Acres (calculated in CASE in the SQL based on Legal Acres - RemAcres - Cat19 Acres)
        if DBSITE > 0:
            logging.info(f"Yes DBSITE: {DBSITE}")

            # Tab to Add Market
            pyautogui.press('tab')
            time.sleep(1)

            # Press Enter to Add Market
            pyautogui.press('enter')
            time.sleep(1)

            # Press Shift+Tab 18 times to land on Land Type Dropdown
            press_key_with_modifier_multiple_times('shift', 'tab', 18)
            time.sleep(1)

            # Select LandType in dropdown using the variable entry plus LandType Press Key press_land_key
            press_land_key(LANDTYPE)
            time.sleep(1)
            logging.info(f"LANDTYPE: {LANDTYPE}")

            # Press enter to select the Land Type
            pyautogui.press('enter')
            time.sleep(1)

            # Tab to Pricing Method
            pyautogui.press('tab')
            time.sleep(1)

            # Down once to whatever is default
            pyautogui.press('down')
            time.sleep(1)

            # Press Enter to Select
            pyautogui.press('enter')
            time.sleep(1)

            # Tab to Acres:
            press_key_multiple_times(['tab'], 3)
            time.sleep(1)

            # Send Site Acres
            pyautogui.typewrite(str(DBSITE))
            logging.info(f"SITE: {DBSITE}")
            # EXPLANATION
            # Assuming DBSITE is a decimal.Decimal object
            # DBSITE = decimal.Decimal('1.234')  # Example value
            # Convert DBSITE to a string and type it out
            # pyautogui.typewrite(str(DBSITE))

            # Tab to Site Rating
            press_key_multiple_times(['tab'], 8)
            time.sleep(1)

            # Press down based on variable input plus Legend Key
            press_legend_key(LEGENDTYPE)
            logging.info(f"LEGENDTYPE: {LEGENDTYPE}")

            # Tab to Add Market just in case for the next if / else
            press_key_multiple_times(['tab'], 6)
            time.sleep(1)
        else:
            logging.info(f"No DBSITE: {DBSITE}")



        # LD_2 Process: Remaining Acres
        if DBREMACRES > 0:
            logging.info(f"Yes DBREMACRES: {DBREMACRES}")

            # Override LANDTYPE to "REMAINING ACREAGE" if DBREMACRES is greater than 0
            # "REMAINING_ACRES": 16,
            LANDTYPE = "REMAINING_ACRES"
            logging.info(f"LANDTYPE overridden to: {LANDTYPE}")

            # Press Enter to Add Market
            pyautogui.press('enter')
            time.sleep(1)

            # Press Shift+Tab 18 times to land on Land Type Dropdown
            press_key_with_modifier_multiple_times('shift', 'tab', 18)
            time.sleep(1)

            # Force selection of REMAINING ACREAGE in the dropdown
            press_land_key(LANDTYPE)
            time.sleep(1)
            logging.info(f"LANDTYPE: {LANDTYPE}")

            # Press enter to select the Land Type
            pyautogui.press('enter')
            time.sleep(1)

            # Tab to Pricing Method
            pyautogui.press('tab')
            time.sleep(1)

            # Down once to whatever is default
            pyautogui.press('down')
            time.sleep(1)

            # Press Enter to Select
            pyautogui.press('enter')
            time.sleep(1)

            # Tab to Acres:
            press_key_multiple_times(['tab'], 3)
            time.sleep(1)

            # Send Site Acres
            pyautogui.typewrite(str(DBREMACRES))
            logging.info(f"DBREMACRES: {DBREMACRES}")

            # Tab to Site Rating
            press_key_multiple_times(['tab'], 8)
            time.sleep(1)

            # No Legend for Rem Acres or Cat19
            # Press down based on variable input plus Legend Key
            #press_legend_key(LEGENDTYPE)
            #logging.info(f"LEGENDTYPE: {LEGENDTYPE}")

            # Tab to Add Market just in case for the next if / else
            press_key_multiple_times(['tab'], 6)
            time.sleep(1)

        else:
            logging.info(f"No DBREMACRES: {DBREMACRES}")



        # LD_3 Process: Cat19 Waste
        if DBCat19AC > 0:
            logging.info(f"Yes Cat19AC: {DBCat19AC}")

            # Override LANDTYPE to "WASTE" if DBCat19AC is greater than 0
            # "WASTE": 13,
            LANDTYPE = "WASTE"
            logging.info(f"LANDTYPE overridden to: {LANDTYPE}")

            # Press Enter to Add Market
            pyautogui.press('enter')
            time.sleep(1)

            # Press Shift+Tab 18 times to land on Land Type Dropdown
            press_key_with_modifier_multiple_times('shift', 'tab', 18)
            time.sleep(1)

            # Force selection of WASTE in the dropdown
            press_land_key(LANDTYPE)
            time.sleep(1)
            logging.info(f"LANDTYPE: {LANDTYPE}")

            # Press enter to select the Land Type
            pyautogui.press('enter')
            time.sleep(1)

            # Tab to Pricing Method
            pyautogui.press('tab')
            time.sleep(1)

            # Down once to whatever is default
            pyautogui.press('down')
            time.sleep(1)

            # Press Enter to Select
            pyautogui.press('enter')
            time.sleep(1)

            # Tab to Acres:
            press_key_multiple_times(['tab'], 3)
            time.sleep(1)

            # Send Site Acres
            pyautogui.typewrite(str(DBCat19AC))
            logging.info(f"DBCat19AC: {DBCat19AC}")

            # Tab to Site Rating
            press_key_multiple_times(['tab'], 8)
            time.sleep(1)

            # No Legend for Rem Acres or Cat19
            # Press down based on variable input plus Legend Key
            #press_legend_key(LEGENDTYPE)
            #logging.info(f"LEGENDTYPE: {LEGENDTYPE}")

            # Tab to Add Market just in case for the next if / else
            press_key_multiple_times(['tab'], 6)
            time.sleep(1)

        else:
            logging.info(f"No Cat19AC: {DBCat19AC}")


    elif LANDTYPE in ("COMMERCIAL"):
        logging.info(f"Commercial: {LANDTYPE}")
        
        # Commercial doesn't use Remaining Acres, but does use Cat19

        # Assuming DBSITE and DBREMACRES are numeric (int or float)
        
        total_acres_not_cat19 = DBSITE + DBREMACRES

        # LD_1 Process: Site Acres (calculated in CASE in the SQL based on Legal Acres - RemAcres - Cat19 Acres)
        if total_acres_not_cat19 > 0:
            logging.info(f"Yes total_acres_not_cat19: {total_acres_not_cat19}")

            # Tab to Add Market
            pyautogui.press('tab')
            time.sleep(1)

            # Press Enter to Add Market
            pyautogui.press('enter')
            time.sleep(1)

            # Press Shift+Tab 18 times to land on Land Type Dropdown
            press_key_with_modifier_multiple_times('shift', 'tab', 18)
            time.sleep(1)

            # Select LandType in dropdown using the variable entry plus LandType Press Key press_land_key
            press_land_key(LANDTYPE)
            time.sleep(1)
            logging.info(f"LANDTYPE: {LANDTYPE}")

            # Press enter to select the Land Type
            pyautogui.press('enter')
            time.sleep(1)

            # Tab to Pricing Method
            pyautogui.press('tab')
            time.sleep(1)

            # Down once to whatever is default
            pyautogui.press('down')
            time.sleep(1)

            # Press Enter to Select
            pyautogui.press('enter')
            time.sleep(1)

            # Tab to Acres:
            press_key_multiple_times(['tab'], 3)
            time.sleep(1)

            # Send Site Acres

            # Commercial doesn't use Remaining Acres, but does use Cat19

            # Assuming DBSITE and DBREMACRES are numeric (int or float)
            
            pyautogui.typewrite(str(total_acres_not_cat19))
            
            # pyautogui.typewrite(str(DBSITE))
            logging.info(f"total_acres_not_cat19: {total_acres_not_cat19}")
            # EXPLANATION
            # Assuming DBSITE is a decimal.Decimal object
            # DBSITE = decimal.Decimal('1.234')  # Example value
            # Convert DBSITE to a string and type it out
            # pyautogui.typewrite(str(DBSITE))

            # Tab to Site Rating
            press_key_multiple_times(['tab'], 8)
            time.sleep(1)

            # Press down based on variable input plus Legend Key
            press_legend_key(LEGENDTYPE)
            logging.info(f"LEGENDTYPE: {LEGENDTYPE}")

            # Tab to Add Market just in case for the next if / else
            press_key_multiple_times(['tab'], 6)
            time.sleep(1)
        else:
            logging.info(f"No DBSITE: {DBSITE}")

        # LD_2 Process: Remaining Acres
        # Commercial doesn't use Remaining Acres, but does use Cat19

        # LD_3 Process: Cat19 Waste
        if DBCat19AC > 0:
            logging.info(f"Yes Cat19AC: {DBCat19AC}")

            # Override LANDTYPE to "WASTE" if DBCat19AC is greater than 0
            # "WASTE": 13,
            LANDTYPE = "WASTE"
            logging.info(f"LANDTYPE overridden to: {LANDTYPE}")

            # Press Enter to Add Market
            pyautogui.press('enter')
            time.sleep(1)

            # Press Shift+Tab 18 times to land on Land Type Dropdown
            press_key_with_modifier_multiple_times('shift', 'tab', 18)
            time.sleep(1)

            # Force selection of WASTE in the dropdown
            press_land_key(LANDTYPE)
            time.sleep(1)
            logging.info(f"LANDTYPE: {LANDTYPE}")

            # Press enter to select the Land Type
            pyautogui.press('enter')
            time.sleep(1)

            # Tab to Pricing Method
            pyautogui.press('tab')
            time.sleep(1)

            # Down once to whatever is default
            pyautogui.press('down')
            time.sleep(1)

            # Press Enter to Select
            pyautogui.press('enter')
            time.sleep(1)

            # Tab to Acres:
            press_key_multiple_times(['tab'], 3)
            time.sleep(1)

            # Send Site Acres
            pyautogui.typewrite(str(DBCat19AC))
            logging.info(f"DBCat19AC: {DBCat19AC}")

            # Tab to Site Rating
            press_key_multiple_times(['tab'], 8)
            time.sleep(1)

            # No Legend for Rem Acres or Cat19
            # Press down based on variable input plus Legend Key
            #press_legend_key(LEGENDTYPE)
            #logging.info(f"LEGENDTYPE: {LEGENDTYPE}")

            # Tab to Add Market just in case for the next if / else
            press_key_multiple_times(['tab'], 6)
            time.sleep(1)

        else:
            logging.info(f"No Cat19AC: {DBCat19AC}")


    else:
        logging.info(f"Invalid Land Type: {LANDTYPE}")






    # Process: Set Allocations
    set_focus_and_type('ProVal', PLATCOMBO)

    # Press F9 to open the Market Allocations pop-up window
    pyautogui.press('F9')
    time.sleep(3)
    logging.info(f"Open Market Allocaitons (F9)")
    time.sleep(1)

    # Process_Allocations: 
    logging.info(f"BEGIN ALLOCATIONS PHASE USING VARIABLES AND FUNCTIONS")
    time.sleep(1)

    # INCLUDING FOR REFERENCE FROM ABOVE IN SCRIPT

    # Set the description code basedon SQL result
    description_code = determine_group_code(DBPCC)  
    
    # Get the number of key presses required for the description
    num_presses = pressess_allocations(description_code)
    logging.info(f"Set_Global_AllocationPresses_Variable_FromPCC_FromSQL")
    time.sleep(1)
    # All Group Codes variable based on PCC except Cat19 WASTE, override on that script
    logging.info(f"PCC_CODE: {DBPCC}")
    logging.info(f"PCC_DESCR: {DBPCCDESCR}")
    logging.info(f"GROUP_CODE: {description_code}")
    logging.info(f"Presses_Up: {num_presses}")
    time.sleep(1)

    # Check for Rural vs Urban
    logging.info(f"CHECK RURAL VS URBAN")
    time.sleep(1)



    # IF RES_RURAL would match the PCC
    # Check if the image is found and decide based on that
    if is_image_found(allocations_31Rural, confidence=0.8):
        logging.info("allocations_31Rural was found - executing related tasks.")
        time.sleep(1)

        #description_code = "15"  # Set the description code based on your scenario
        #num_presses = pressess_allocations(description_code)
        
        # Perform tasks related to the image being found
        # Click at the center of a single image
        if click_image_single(allocations_31Rural, direction='below', offset=5, confidence=0.8, clicks=1):
            logging.info("Clicked successfully allocations_31Rural.")
            time.sleep(2)

           # Select Group Code
            press_key_multiple_times('up', num_presses) # SET BASED ON TWO KEYS BASED ON PCC CODE
            time.sleep(2)
            press_key_multiple_times(['tab'], 2)
            time.sleep(2)
            pyautogui.press('enter')
            time.sleep(2)

    else:
        logging.info("allocations_31Rural was not found - executing alternative tasks.")
        time.sleep(1)

        # If 31Rural not found, check for 32 Urban

        # IF RES_URBAN would match the PCC
        # Check if the image is found and decide based on that
        if is_image_found(allocations_32Urban, confidence=0.8):
            logging.info("allocations_32Urban was found - executing related tasks.")
            time.sleep(1)

            #description_code = "20"  # Set the description code based on your scenario
            #num_presses = pressess_allocations(description_code)

            # Perform tasks related to the image being found
            # Click at the center of a single image
            if click_image_single(allocations_32Urban, direction='below', offset=5, confidence=0.8, clicks=1):
                logging.info("Clicked successfully allocations_32Urban.")
                time.sleep(2)
            
                # Sometimes the Edit Value Allocation pop-up gets behind the Cost Allocations pop-up, set focus
                #set_focus_and_type('Edit Value Allocation', PLATCOMBO)
                #Tab to Group Code
                #press_key_multiple_times(['tab'], 4)
                # Note: By changing to single click, this stopped happening. Leaving code in case I need it later.

                # Select Group Code
                press_key_multiple_times('up', num_presses) # SET BASED ON TWO KEYS BASED ON PCC CODE
                time.sleep(2)
                press_key_multiple_times(['tab'], 2)
                time.sleep(2)
                pyautogui.press('enter')
                time.sleep(2)

        else:
            logging.info("allocations_32Urban was not found - executing alternative tasks.")
            time.sleep(1)

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        time.sleep(1)
        break




    # REMAINING ACRES Matches Urban or Rural would match the PCC
    # Check if the image is found and decide based on that
    if is_image_found(allocations_91RemAcres, confidence=0.8):
        logging.info("allocations_91RemAcres was found - executing related tasks.")
        time.sleep(1)

        # Perform tasks related to the image being found
        # Click at the center of a single image
        if click_image_single(allocations_91RemAcres, direction='below', offset=5, confidence=0.8, clicks=1):
            logging.info("Clicked successfully allocations_91RemAcres.")
            time.sleep(2)

        # Select Group Code
            press_key_multiple_times('up', num_presses) # SET BASED ON TWO KEYS BASED ON PCC CODE
            time.sleep(2)
            press_key_multiple_times(['tab'], 2)
            time.sleep(2)
            pyautogui.press('enter')
            time.sleep(2)

        else:
            logging.info("allocations_91RemAcres was not found - executing alternative tasks.")
        time.sleep(1)

        if stop_script:
            logging.info("Script stopping due to kill key press.")
            time.sleep(1)
        break
    


    # COMMERCIAL would match the PCC
    # Check if the image is found and decide based on that
    if is_image_found(allocations_11Commercial, confidence=0.8):
        logging.info("allocations_11Commercial was found - executing related tasks.")
        time.sleep(1)

        #description_code = "15"  # Set the description code based on your scenario
        #num_presses = pressess_allocations(description_code)

        # Perform tasks related to the image being found
        # Click at the center of a single image
        if click_image_single(allocations_11Commercial, direction='below', offset=5, confidence=0.8, clicks=1):
            logging.info("Clicked successfully allocations_11Commercial.")
            time.sleep(2)

        # Select Group Code
            press_key_multiple_times('up', num_presses) # SET BASED ON TWO KEYS BASED ON PCC CODE
            time.sleep(2)
            press_key_multiple_times(['tab'], 2)
            time.sleep(2)
            pyautogui.press('enter')
            time.sleep(2)
    else:
        logging.info("allocations_11Commercial was not found - executing alternative tasks.")
        time.sleep(1)

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        time.sleep(1)
        break



    # C_CAREA
    # Check if the image is found and decide based on that
    if is_image_found(allocations_C_Carea, confidence=0.8):
        logging.info("allocations_C_Carea was found - executing related tasks.")
        time.sleep(1)

        # Perform tasks related to the image being found
        # Click at the center of a single image
        if click_image_single(allocations_C_Carea, direction='below', offset=5, confidence=0.8, clicks=1):
            logging.info("Clicked successfully allocations_C_Carea.")
            time.sleep(2)

           # Select Group Code
            press_key_multiple_times('up', num_presses) # SET BASED ON TWO KEYS BASED ON PCC CODE
            time.sleep(2)
            press_key_multiple_times(['tab'], 2)
            time.sleep(2)
            pyautogui.press('enter')
            time.sleep(2)
    else:
        logging.info("allocations_C_Carea was not found - executing alternative tasks.")
        time.sleep(1)

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        time.sleep(1)
        break




    # CA_COMMON_AREAS_CONDOS
    # Check if the image is found and decide based on that
    if is_image_found(allocations_CA_CommonAreaCondos, confidence=0.8):
        logging.info("allocations_CA_CommonAreaCondos was found - executing related tasks.")
        time.sleep(1)
        # Perform tasks related to the image being found
        # Click at the center of a single image
        if click_image_single(allocations_CA_CommonAreaCondos, direction='below', offset=5, confidence=0.8, clicks=1):
            logging.info("Clicked successfully allocations_CA_CommonAreaCondos.")
            time.sleep(2)

           # Select Group Code
            press_key_multiple_times('up', num_presses) # SET BASED ON TWO KEYS BASED ON PCC CODE
            time.sleep(2)
            press_key_multiple_times(['tab'], 2)
            time.sleep(2)
            pyautogui.press('enter')
            time.sleep(2)
    else:
        logging.info("allocations_CA_CommonAreaCondos was not found - executing alternative tasks.")
        time.sleep(1)
    
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break




    # All Group Codes variable based on PCC except Cat19 WASTE, override on that script


    # CAT19_WASTE
    # Check if the image is found and decide based on that
    if is_image_found(allocations_82Waste, confidence=0.8):
        logging.info("allocations_82Waste was found - executing related tasks.")
        time.sleep(1)

        description_code = "19"  # Set the description code based on your scenario
        num_presses = pressess_allocations(description_code)
        logging.info(f"Set_Local_AllocationPresses_ForCat19")
        time.sleep(1)
        
        # Perform tasks related to the image being found
        # Click at the center of a single image
        if click_image_single(allocations_82Waste, direction='below', offset=5,  confidence=0.8, clicks=1):
            logging.info("Clicked successfully allocations_82Waste.")
            time.sleep(2)

           # Select Group Code
            press_key_multiple_times('up', num_presses) # SET BASED ON TWO KEYS BASED ON PCC CODE
            time.sleep(2)
            press_key_multiple_times(['tab'], 2)
            time.sleep(2)
            pyautogui.press('enter')
            time.sleep(2)

    else:
        logging.info("allocations_82Waste was not found - executing alternative tasks.")
        time.sleep(1)

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        time.sleep(1)
        break


    # Once all Allocations are processed, close the Cost Allocations pop-up window
    set_focus_and_type('Cost Allocations', PLATCOMBO)
    pyautogui.hotkey('alt', 'n')
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    # Cost Allocations window should close


        


    # Process: Enter Land Memos
        
    # Process: Open Memos
    set_focus_and_type('ProVal', PLATCOMBO)
    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(1)

    # CHECK IF LAND
    # Define the specific text you're looking for
    specific_text = "LAND"
    # Use the variable in your function call and print statements
    if check_for_text_on_screen(specific_text):
        logging.info(f"Found '{specific_text}' on the screen.")
    
        pyautogui.press('l')
        pyautogui.press('enter')
        time.sleep(1)

        ensure_capslock_off()

        pyautogui.typewrite(MemoTXT)
        time.sleep(1)

        pyautogui.press('enter')
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        pyautogui.press('enter')
        time.sleep(1)
    else:
        logging.info(f"Did not find '{specific_text}' on the screen.")
        pyautogui.press('enter')
        time.sleep(1)

        pyautogui.press('l')
        time.sleep(1)

        pyautogui.press('enter')
        time.sleep(1)

        ensure_capslock_off()

        pyautogui.typewrite(MemoTXT)
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        pyautogui.press('enter')
        time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break



    # Process: Update Inspection Records
        
    # Process each AIN individually
    set_focus_and_type('ProVal', PLATCOMBO)
    time.sleep(1)
    logging.info("set_focus_and_type")
    #Maximize Window
    # Simulate the Windows + Up Arrow key combination to maximize the window
    pyautogui.hotkey('win', 'up')

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break

    # Open Inspection Reocrd Maintencance window
    pyautogui.hotkey('alt', 'p', 'i')
    time.sleep(1)
    logging.info(f"Update Inspection Records...")

    # Press Tab
    pyautogui.press('tab')
    logging.info("press")

    # Inspection Record Today's Date
    pyautogui.typewrite(str(today_date))
    logging.info(f"Today's date is: {today_date}")

    # Press Tab
    pyautogui.press('tab')
    logging.info("press")

    # Send Initials
    pyautogui.typewrite(str(Initials))
    logging.info(f"User Initials {Initials}")

    # Press Tab
    pyautogui.press('tab')
    logging.info("press")

    # Inspection Record Today's Date
    pyautogui.typewrite(str(today_date))
    logging.info(f"Today's date is: {today_date}")

    # Press Tab
    pyautogui.press('tab')
    logging.info("press")

    # Send Initials
    pyautogui.typewrite(str(Initials))
    logging.info(f"User Initials {Initials}")

    # Press Tab * to Data Source
    press_key_multiple_times(['tab'], 1)
    time.sleep(1)
    logging.info("press")

    # Select VACANT for all Plats
    press_key_multiple_times('down', 12)
    time.sleep(1)
    logging.info("press")

    # Press Tab * to Apply
    press_key_multiple_times(['tab'], 5)
    time.sleep(1)
    logging.info("press")

    # Press Enter to Apply
    pyautogui.press('enter')
    logging.info("press")

    # Press Tab * to OK
    pyautogui.press('tab')
    logging.info("press")

    # Press Enter to OK and close window
    pyautogui.press('enter')
    logging.info("press")

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break


   
      
    # Save Account
    pyautogui.hotkey('ctrl', 's')
    logging.info("Save.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break


    # END ALL PROCESSESS
    logging.info("End of this row, next row...")
    time.sleep(1)



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
if AIN:
    press_key_multiple_times('down', 4)
elif PIN:
    press_key_multiple_times('down', 0)

    # Check if the image is found and decide based on that
    if is_image_found(image_path_name_here, confidence=0.8):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found
        # Click at the center of a single image
        if click_image_single(single_image_path_name_here, direction='center', confidence=0.8):
            logging.info("Clicked successfully.")

    else:
        logging.info("Image was not found - executing alternative tasks.")


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
# 08/21/2024 NEW PLAT VERSION
    # Plat for testing 0L806
"""