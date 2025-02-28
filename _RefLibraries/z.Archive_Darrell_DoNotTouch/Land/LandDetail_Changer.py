
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

mylog_filename = 'C:/Users/dwolfe/Documents/Kootenai_County_Assessor_CodeBase-1/Working_Darrell\Logs_Darrell/LandDetail_Changer.log'
#mylog_filename = 'S:/Common/Comptroller Tech/Reports/Python/Auto_Mapping_Packet/LandDetail_Changer.log'

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

# Get today's date in mm/dd/yyyy format
today_date = datetime.now().strftime("%m/%d/%Y")
# You can then use `today_date` in your code wherever you need the formatted date
logging.info(f"Today's date is: {today_date}")


# Function to handle enabling/disabling entry fields based on checkboxes
def toggle_entry_state():
    # Land Type
    if skip_land_type_var.get():
        combo_land_type.config(state='disabled')
    else:
        combo_land_type.config(state='normal')
    
    # Pricing Method
    if skip_pricing_method_var.get():
        entry_pricing_method.config(state='disabled')
    else:
        entry_pricing_method.config(state='normal')

    # Soil Type
    if skip_soil_type_var.get():
        entry_soil_type.config(state='disabled')
    else:
        entry_soil_type.config(state='normal')

    # Legend Type
    if skip_legend_type_var.get():
        entry_legend_type.config(state='disabled')
    else:
        entry_legend_type.config(state='normal')


# Function to setup the popup window
def setup_gui():
    global entry_parcels, entry_pricing_method, combo_land_type, entry_soil_type, entry_legend_type, skip_land_type_var, skip_pricing_method_var, skip_soil_type_var, skip_legend_type_var

    # Create the main window
    root = tk.Tk()
    root.title("Parcel Processing")

    # Add a label and entry box for the number of parcels
    ttk.Label(root, text="Enter the number of parcels to process (3, 63, 163):").grid(column=0, row=0, padx=10, pady=5)
    entry_parcels = ttk.Entry(root, width=30)
    entry_parcels.grid(column=1, row=0, padx=10, pady=5)

    # Land Type dropdown (Combobox)
    ttk.Label(root, text="Select Land Type:").grid(column=0, row=1, padx=10, pady=5)
    
    # Define the land types (matching keys from land_key_mapping)
    land_types = [
        "9_HOMESITE", "31_RES_RURAL", "32_RES_URBAN", "CA_COMMON_AREAS_CONDOS", "C_CAREA", "11_COMMERCIAL", 
        "82_WASTE", "91_REMAINING_ACRES", "90_WF_Homesite", "93_WF_RecreationLot", 
        "94_WF_VacantBuildable", "95_WF_VacantNonBuildable", "DEFAULT"
    ]
    
    # Combobox for Land Type
    combo_land_type = ttk.Combobox(root, values=land_types, width=30)
    combo_land_type.grid(column=1, row=1, padx=10, pady=5)
    combo_land_type.current(0)  # Set default to first option

    # Add a checkbox to skip the land type
    skip_land_type_var = tk.IntVar()  # 0 means unchecked, 1 means checked
    skip_land_type_checkbox = tk.Checkbutton(root, text="Skip Land Type", variable=skip_land_type_var, command=toggle_entry_state)
    skip_land_type_checkbox.grid(column=2, row=1, padx=10, pady=5)

    # Add a label and entry box for the pricing method
    ttk.Label(root, text="Enter the pricing method (32, 91, etc.):").grid(column=0, row=2, padx=10, pady=5)
    entry_pricing_method = ttk.Entry(root, width=30)
    entry_pricing_method.grid(column=1, row=2, padx=10, pady=5)

    # Add a checkbox to skip the pricing method
    skip_pricing_method_var = tk.IntVar()  # 0 means unchecked, 1 means checked
    skip_pricing_method_checkbox = tk.Checkbutton(root, text="Skip Pricing Method", variable=skip_pricing_method_var, command=toggle_entry_state)
    skip_pricing_method_checkbox.grid(column=2, row=2, padx=10, pady=5)

    # Add a label and entry box for the Soil_Type
    ttk.Label(root, text="Enter the Soil_Type (alphanumeric):").grid(column=0, row=3, padx=10, pady=5)
    entry_soil_type = ttk.Entry(root, width=30)  # New entry field for Soil_Type
    entry_soil_type.grid(column=1, row=3, padx=10, pady=5)

    # Add a checkbox to skip the Soil_Type
    skip_soil_type_var = tk.IntVar()  # 0 means unchecked, 1 means checked
    skip_soil_type_checkbox = tk.Checkbutton(root, text="Skip Soil Type", variable=skip_soil_type_var, command=toggle_entry_state)
    skip_soil_type_checkbox.grid(column=2, row=3, padx=10, pady=5)

    # Add a label and entry box for the Legend_Type
    ttk.Label(root, text="Enter the Legend_Type (1,2,3,19, etc.):").grid(column=0, row=4, padx=10, pady=5)
    entry_legend_type = ttk.Entry(root, width=30)
    entry_legend_type.grid(column=1, row=4, padx=10, pady=5)

    # Add a checkbox to skip the Legend_Type
    skip_legend_type_var = tk.IntVar()  # 0 means unchecked, 1 means checked
    skip_legend_type_checkbox = tk.Checkbutton(root, text="Skip Legend_Type", variable=skip_legend_type_var, command=toggle_entry_state)
    skip_legend_type_checkbox.grid(column=2, row=4, padx=10, pady=5)

    # Add the submit button
    submit_button = ttk.Button(root, text="Submit", command=on_submit)
    submit_button.grid(column=0, row=5, columnspan=2, pady=20)

    return root


# Update on_submit function to handle the new combo_land_type selection
def on_submit():
    global total_parcels, selected_pricing_method, selected_land_type, selected_soil_type, skip_land_type, skip_pricing_method, skip_soil_type, skip_legend_type, LEGENDTYPE, LANDTYPE

    # Get the number of parcels from the entry field
    number_of_parcels = entry_parcels.get().strip()

    # Get the skip options (whether to skip land type, pricing method, soil type, and legend type)
    skip_land_type = bool(skip_land_type_var.get())
    skip_pricing_method = bool(skip_pricing_method_var.get())
    skip_soil_type = bool(skip_soil_type_var.get())
    skip_legend_type = bool(skip_legend_type_var.get())

    # Check if the number of parcels is valid (i.e., a positive integer)
    if not number_of_parcels.isdigit() or int(number_of_parcels) <= 0:
        messagebox.showerror("Input Error", "Please enter a valid number of parcels.")
        return

    # Only get land_type if skip option is not selected
    if not skip_land_type:
        land_type = combo_land_type.get().strip()
        if not land_type:
            messagebox.showerror("Input Error", "Please select a valid land type.")
            return
    else:
        land_type = None  # Set to None if skipping

    # Only get pricing_method if skip option is not selected
    if not skip_pricing_method:
        pricing_method = entry_pricing_method.get().strip()
        if not pricing_method.isdigit():
            messagebox.showerror("Input Error", "Please enter a valid pricing method (must be a number).")
            return
    else:
        pricing_method = None  # Set to None if skipping

    # Only get soil_type if skip option is not selected
    if not skip_soil_type:
        soil_type = entry_soil_type.get().strip()
        if not soil_type:
            messagebox.showerror("Input Error", "Please enter a valid soil type (alphanumeric).")
            return
    else:
        soil_type = None  # Set to None if skipping

    # Only get LEGENDTYPE if skip option is not selected
    if not skip_legend_type:
        legend_type = entry_legend_type.get().strip()
        if not legend_type.isdigit():
            messagebox.showerror("Input Error", "Please enter a valid Legend Type (must be a number).")
            return
        LEGENDTYPE = int(legend_type)
    else:
        LEGENDTYPE = None  # Set to None if skipping

    # Convert the inputs to integers and store them in global variables
    total_parcels = int(number_of_parcels)
    selected_pricing_method = int(pricing_method) if pricing_method else None
    selected_land_type = land_type  # Store the land type or None if skipped
    selected_soil_type = soil_type  # Store the soil type or None if skipped
    

    LANDTYPE = selected_land_type

    root.destroy()  # Close the popup

"""
# Setup and start the GUI to get the number of parcels
root = setup_gui()
root.mainloop()
"""


# Function to simulate moving to the next parcel
def go_to_next_parcel():
    pyautogui.press('f3')
    logging.info("Moving to next parcel (F3)...")
    time.sleep(1)  # Simulate delay in moving to the next parcel

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
        # Convert keys to string if it's an integer before typing
        pyautogui.typewrite(str(keys))  # Convert the integer 'keys' to a string

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
        "9_HOMESITE": 13,
        "31_RES_RURAL": 3,
        "32_RES_URBAN": 4,
        "CA_COMMON_AREAS_CONDOS": 22,
        "C_CAREA": 21,
        "11_COMMERCIAL": 1,
        "82_WASTE": 13,
        "91_REMAINING_ACRES": 15,
        "90_WF_Homesite": 14,
        "93_WF_RecreationLot": 16,
        "94_WF_VacantBuildable": 17,
        "95_WF_VacantNonBuildable": 18,
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





"""
# Start the GUI event loop
"""


# Setup and start the GUI
root = setup_gui()
root.mainloop()
stop_script

logging.info(f"Number of AINs to pocess: {total_parcels}")
stop_script
# Now that the popup has closed, proceed with the processing steps
logging.info(f"Processing {total_parcels} parcels...")
stop_script
# Perform steps for each parcel using a loop
current_parcel = 1
while current_parcel <= total_parcels:
    stop_script
    logging.info(f"Processing {current_parcel} of {total_parcels} parcels...")

    # Process each AIN individually
    set_focus_and_type('ProVal', total_parcels)
    time.sleep(1)
    logging.info("set_focus_and_type")
    #Maximize Window
    # Simulate the Windows + Up Arrow key combination to maximize the window
    pyautogui.hotkey('win', 'up')
    logging.info("Maximize Window")
    time.sleep(1)
    stop_script




    # Navigate to Land_Tab
    logging.info(f"Click Land_Tab for parcel {current_parcel}")
    time.sleep(1)
    # Click Land_Tab
    if click_images_multiple(land_tab_images, direction='center', offset=100, confidence=0.8):
        logging.info("Clicked successfully land_tab_images.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    stop_script




    # Navigate to Land_Detail
    logging.info(f"Click Land_Detail for parcel {current_parcel}")
    time.sleep(1)
    # Click Land_Detail_Tab
    if click_images_multiple(land_detail_image, direction='center', offset=100, confidence=0.8):
        logging.info("Clicked successfully land_detail_image.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    stop_script




    # START THE REAL LOOPS

    # SELECT LAND TYPE
    if not skip_land_type:
        logging.info(f"skip_land_type value: {skip_land_type}")
        stop_script

        # Navigate to Land_Type
        logging.info(f"Tab to Land_Type {selected_land_type} for parcel {current_parcel}")
        pyautogui.press('tab')
        time.sleep(1)
        # Set to top default Land_Type
        press_key_multiple_times('up', 25)
        time.sleep(1)
        stop_script

        # Select Land_Type
        logging.info(f"Select to Land_Type {selected_land_type} for parcel {current_parcel}")
        #pyautogui.typewrite(str('32'))
        #pyautogui.typewrite(selected_pricing_method)
        #pyautogui.typewrite(str(selected_land_type))
        press_land_key(LANDTYPE)
        time.sleep(1)
        pyautogui.press('enter')
        time.sleep(1)
        stop_script

        # Navigate to Pricing_Method
        logging.info(f"Tab to Pricing_Method for parcel {current_parcel}")
        pyautogui.press('tab')
        time.sleep(1)
        stop_script

    else:
        press_key_multiple_times('tab', 2)
        time.sleep(1)
        stop_script


    # SELECT PRICING METHOD

    if not skip_pricing_method:
        stop_script

        # Set to top default Pricing_Method
        press_key_multiple_times('up', 25)
        time.sleep(1)

        # Select Pricing_Method
        logging.info(f"Select to Pricing_Method for parcel {current_parcel}")
        #pyautogui.typewrite(str('32'))
        #pyautogui.typewrite(selected_pricing_method)
        pyautogui.typewrite(str(selected_pricing_method))
        time.sleep(1)
        pyautogui.press('enter')
        time.sleep(1)
        press_key_multiple_times('tab', 10)
        time.sleep(1)
        stop_script

    else:
        press_key_multiple_times('tab', 10)
        time.sleep(1)
        stop_script



    # SEELCT SOIL TYPE

    if not skip_soil_type:
        # Set to top
        pyautogui.press(str('4'))
        time.sleep(1)
        pyautogui.press('enter')
        time.sleep(1)
        press_key_multiple_times('up', 1)
        time.sleep(1)

        # Select Soil Type (RSITE for now)
        pyautogui.press(str('r'))
        time.sleep(1)
        pyautogui.press('enter')
        time.sleep(1)
        press_key_multiple_times('down', 3)
        time.sleep(1)
        pyautogui.press('enter')
        time.sleep(1)

        # Tab to Site Rating Legend Type
        press_key_multiple_times('tab', 1)
        time.sleep(1)
        pyautogui.press('enter')
        time.sleep(1)

    else:
        # Tab to Site Rating Legend Type
        press_key_multiple_times('tab', 1)
        time.sleep(1)
        stop_script



    # SELECT LEGEND TYPE

    if not skip_legend_type:
        stop_script
        # Set to top default Site_Rating
        press_key_multiple_times('up', 25)
        time.sleep(1)
        press_legend_key(LEGENDTYPE)
        pyautogui.press('enter')
        time.sleep(1)
    else:
        time.sleep(1)
        stop_script





    stop_script

    # Save Account
    pyautogui.hotkey('ctrl', 's')
    logging.info("Save.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break

    stop_script

    # Simulating time delay for each step
    logging.info(f"Processing {current_parcel} of {total_parcels} parcels...")
    time.sleep(1)
    
    # Move to the next parcel if it's not the last one
    if current_parcel < total_parcels:
        go_to_next_parcel()  # Simulate pressing F3 or other action to go to the next parcel
    
    current_parcel += 1


logging.info(f"Processed {current_parcel} of {total_parcels} parcels...")


logging.info("All parcels processed.")



