"""
# This script to assist with automating input of the mapping packets into ProVal
"""

"""
# IMPORT LIBRARIES

### Python Libraries Used

import subprocess
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
    "pywinauto",       # For interacting with Windows applications
    "numpy",           # For numerical operations
    "keyboard",        # For detecting key presses
    "threading",       # Already part of the standard library, no need to install
    "tkinter",         # Already part of the standard library, no need to install
    "pytesseract",     # For OCR (Optical Character Recognition)
    "Pillow",          # For image processing related to ImageGrab
    "opencv-python",   # For image processing (cv2)
    "ctypes",          # Already part of the standard library, no need to install
    "tkcalendar",      # For calendar widget in Tkinter
    "logging"          # Already part of the standard library, no need to install
]

# Apply the install_if_missing function to each package
for package in packages:
    install_if_missing(package)
"""

import pyautogui  # For automating GUI interactions like mouse movements and clicks
import pyodbc  # For establishing database connections and executing SQL queries
# from pywinauto import Application  # For interacting with Windows applications programmatically
# pywinauto not used for this script but could be helpful for others, leaving it in the template.
import time  # For adding delays and managing time-related functions
import numpy as np  # For numerical operations and handling arrays/matrices
import keyboard  # For detecting and handling keyboard key presses
import threading  # For running background tasks and creating concurrent threads
import tkinter as tk  # For creating basic GUI elements in Python applications
from tkinter import ttk, messagebox  # For advanced Tkinter widgets and displaying dialog boxes
import pytesseract  # For OCR (Optical Character Recognition) to read text from images
from PIL import ImageGrab  # For capturing screen images and working with image data
import cv2  # For image processing and computer vision tasks (OpenCV library)
import os  # For interacting with the operating system, e.g., file and directory management
from datetime import datetime  # For handling date and time operations
import ctypes  # For interacting with C data types and Windows API functions
from tkcalendar import DateEntry  # For adding a calendar widget to Tkinter GUIs
import logging  # For logging events, errors, and information during script execution


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



### Graphic User Interface (GUI) Logic - START

# Initialize variables to avoid 'NameError', will call them into the final product after variable selections
MemoTXT = ""
PDESC = ""

def on_submit():
    ensure_capslock_off()

    global AINLIST, AINFROM, AINTO, PDESC, PFILE, PNUMBER, TREVIEW, MappingPacketType, Initials, MemoTXT, ForYear

    # Collect inputs for AINFROM and AINTO, and split by commas
    AINFROM = [ain.strip() for ain in entry_ainfrom.get().strip().upper().split(",")]
    AINTO = [ain.strip() for ain in entry_ainto.get().strip().upper().split(",")]

    # Combine the AINFROM and AINTO lists, removing duplicates
    combined_ain_list = list(set(AINFROM + AINTO))

    # Replace AINLIST with the combined list
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

    if not AINLIST or not PFILE or not PNUMBER or not TREVIEW or not MappingPacketType or not Initials or not MemoTXT or not PDESC:
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
    global entry_ainfrom, entry_ainto, entry_pfile, entry_pnumber, entry_treview, combobox_mappingpackettype, entry_initials, for_year_combobox

    # Get the current and next year
    current_year = datetime.now().year
    next_year = current_year + 1

    ttk.Label(root, text="Mapping packet FOR what year?:").grid(column=0, row=1, padx=10, pady=5)
    for_year_combobox = ttk.Combobox(root, values=[current_year, next_year], width=47)
    for_year_combobox.grid(column=1, row=1, padx=10, pady=5)
    for_year_combobox.current(0)  # Set default selection to the current year

    # AINFROM input
    ttk.Label(root, text="List AINs FROM (separated by comma):").grid(column=0, row=0, padx=10, pady=5)
    entry_ainfrom = ttk.Entry(root, width=50)
    entry_ainfrom.grid(column=1, row=0, padx=10, pady=5)

    # AINTO input
    ttk.Label(root, text="List AINs TO (separated by comma):").grid(column=0, row=1, padx=10, pady=5)
    entry_ainto = ttk.Entry(root, width=50)
    entry_ainto.grid(column=1, row=1, padx=10, pady=5)

    # Existing fields continue below...
    ttk.Label(root, text="Mapping packet FOR what year?:").grid(column=0, row=2, padx=10, pady=5)
    for_year_combobox = ttk.Combobox(root, values=[current_year, next_year], width=47)
    for_year_combobox.grid(column=1, row=2, padx=10, pady=5)
    for_year_combobox.current(0)  # Set default selection to the current year

    ttk.Label(root, text="Filing Date (Top Date):").grid(column=0, row=3, padx=10, pady=5)
    entry_pfile = ttk.Entry(root, width=50)
    entry_pfile.grid(column=1, row=3, padx=10, pady=5)

    ttk.Label(root, text="Permit Number (Bottom Date):").grid(column=0, row=4, padx=10, pady=5)
    entry_pnumber = ttk.Entry(root, width=50)
    entry_pnumber.grid(column=1, row=4, padx=10, pady=5)

    ttk.Label(root, text="Timber or AG review? Y/N:").grid(column=0, row=5, padx=10, pady=5)
    entry_treview = ttk.Entry(root, width=50)
    entry_treview.grid(column=1, row=5, padx=10, pady=5)

    ttk.Label(root, text="Select Mapping Packet Type:").grid(column=0, row=6, padx=10, pady=5)
    
    mapping_packet_types = [
        "MERGE", "SPLIT", "BLA", "LLA", "RW VACATION", "RW SPLIT", "REDESCRIBE",
        "RW AUDIT", "RW Cat19", "AIRPORT LEASE NEW PARCEL", "PLAT VACATION",
        "PARCEL DELETED", "ACERAGE AUDIT", "NEW PLAT"
    ]
    combobox_mappingpackettype = ttk.Combobox(root, values=mapping_packet_types, width=47)
    combobox_mappingpackettype.grid(column=1, row=6, padx=10, pady=5)
    combobox_mappingpackettype.current(0)  # Set default selection to the first item

    # Validation for the Initials Entry
    vcmd = (root.register(validate_initials), '%d', '%P')
    
    ttk.Label(root, text="Enter (3) Initials:").grid(column=0, row=7, padx=10, pady=5)
    entry_initials = ttk.Entry(root, width=50, validate='key', validatecommand=vcmd)
    entry_initials.grid(column=1, row=7, padx=10, pady=5)
    entry_initials.insert(0, "DGW")

    submit_button = ttk.Button(root, text="Submit", command=on_submit)
    submit_button.grid(column=0, row=8, columnspan=2, pady=20)


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

def triple_click(x, y):
    pyautogui.click(x, y, clicks=3)



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


#### Image Paths - Single Images Only
duplicate_memo_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memo_duplicate.PNG'
add_field_visit_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_fieldvisit_button.PNG'
aggregate_land_type_add_button = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_aggregate_land_type_add_button.PNG'
farm_total_acres_image = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_farm_total_acres.PNG'
permits_add_permit_button = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_permit_button.PNG'
permit_description = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permit_description.PNG'



"""
# GLOBAL LOGICS - SCREEN READING FUNCTIONS
"""
# read_text_in_region of the screen
def read_text_in_region(region):
    screenshot = pyautogui.screenshot(region=region)
    text = pytesseract.image_to_string(screenshot)
    return text

### get_screen_regions
# This function returns a dictionary of screen regions:
def get_screen_regions():
    screen_width, screen_height = pyautogui.size()
    return {
        'whole_screen': (0, 0, screen_width, screen_height),
        'top_half': (0, 0, screen_width, screen_height // 2),
        'bottom_half': (0, screen_height // 2, screen_width, screen_height // 2),
        'top_left_quarter': (0, 0, screen_width // 2, screen_height // 2),
        'top_right_quarter': (screen_width // 2, 0, screen_width // 2, screen_height // 2),
        'bottom_left_quarter': (0, screen_height // 2, screen_width // 2, screen_height // 2),
        'bottom_right_quarter': (screen_width // 2, screen_height // 2, screen_width // 2, screen_height // 2)
    }

# First, retrieve all screen regions using get_screen_regions
regions = get_screen_regions()

# Access specific regions
top_half = regions['top_half']
bottom_half = regions['bottom_half']
whole_screen = regions['whole_screen']
top_left_quarter = regions['top_left_quarter']
bottom_right_quarter = regions['bottom_right_quarter']

# Now, you can use these regions in your image detection
"""
# Example 1
handle_image_detection(
    image_path='path_to_image.png',
    on_found=on_image_found,
    on_not_found=on_image_not_found,
    confidence=0.9,
    region=top_half  # Example of using top_half region
)
# Example 2
handle_image_detection(
    image_path='path_to_another_image.png',
    on_found=on_image_found,
    on_not_found=on_image_not_found,
    confidence=0.9,
    region=bottom_right_quarter  # Example of using bottom_right_quarter region
)
"""

### handle_image_detection
# This function searches for an image and calls the provided callback functions based on the search result:
def handle_image_detection(image_path, on_found=None, on_not_found=None, confidence=0.8, region=None):
    # Adjust screenshot area based on the region if provided
    if region:
        screenshot = pyautogui.screenshot(region=region)
    else:
        screenshot = pyautogui.screenshot()

    screenshot = cv2.cvtColor(np.array(screenshot), cv2.COLOR_BGR2GRAY)
    ref_image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    result = cv2.matchTemplate(screenshot, ref_image, cv2.TM_CCOEFF_NORMED)
    _, max_val, _, max_loc = cv2.minMaxLoc(result)

    if max_val >= confidence:
        if on_found:
            ref_image_height, ref_image_width = ref_image.shape[:2]  # Get dimensions of the reference image
            adjusted_location = (max_loc[0] + ref_image_width // 2, max_loc[1] + ref_image_height // 2)
            on_found(adjusted_location)
    else:
        if on_not_found:
            on_not_found()



# Adding this function from v1 as it works better, replaces 
    # The click_image function in v1 is more robust and should replace the separate is_image_on_screen and click_image functions in v2. 
    # This combined function handles both detection and clicking in one step, which is likely why it works more reliably.

def click_image(image_path, confidence=0.8):
    try:
        if not os.path.exists(image_path):
            logging.error(f"Image file not found: {image_path}")
            return False

        ref_image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
        screenshot = pyautogui.screenshot()
        screenshot = cv2.cvtColor(np.array(screenshot), cv2.COLOR_RGB2GRAY)

        result = cv2.matchTemplate(screenshot, ref_image, cv2.TM_CCOEFF_NORMED)
        min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)

        if max_val >= confidence:
            top_left = max_loc
            h, w = ref_image.shape
            center_x, center_y = top_left[0] + w // 2, top_left[1] + h // 2
            pyautogui.moveTo(center_x, center_y)
            pyautogui.click()
            logging.info(f"Clicked on the image: {image_path}")
            return True
        else:
            logging.warning(f"Could not locate the image: {image_path} with confidence {confidence}")
            return False
    except Exception as e:
        logging.error(f"Failed to click the image: {image_path}")
        logging.error(f"Exception: {e}")
        return False






### click_relative
def click_relative(image_path=None, base_location=None, direction='right', offset=50, confidence=0.8, inset=7, vertical_adjustment=-15):
    """
    Function to click relative to a found location with an optional vertical adjustment.

    :param image_path: Path to the image to locate on screen.
    :param base_location: A tuple (x, y) indicating the base location to adjust from.
    :param direction: Direction to move from the base location ('right', 'left', 'above', 'below', etc.).
    :param offset: Pixels to move in the specified direction.
    :param confidence: Confidence level for locating the image.
    :param inset: Pixels to move in for corner clicks.
    :param vertical_adjustment: Adjustment to apply to the y-coordinate to fine-tune click accuracy.
    """
    if image_path:
        location = pyautogui.locateOnScreen(image_path, confidence=confidence)
    elif base_location:
        location = base_location
    else:
        logging.error("Either image_path or base_location must be provided.")
        return False

    if location:
        if isinstance(location, tuple):
            # If location is a tuple, we assume it is (x, y)
            x, y = location
            right = x + offset
            bottom = y + offset
        else:
            # When using image path, calculate the location
            x, y = location.left, location.top
            right = location.left + location.width
            bottom = location.top + location.height

        # Adjust the y-coordinate to fix the misalignment issue
        y += vertical_adjustment

        # Determine click coordinates based on direction
        if direction == 'right':
            click_x, click_y = right + offset, y
        elif direction == 'left':
            click_x, click_y = x - offset, y
        elif direction == 'above':
            click_x, click_y = x, y - offset
        elif direction == 'below':
            click_x, click_y = x, bottom + offset
        elif direction == 'bottom_right_corner':
            click_x, click_y = right - inset, bottom - inset  # Move in by `inset` pixels
        elif direction == 'bottom_left_corner':
            click_x, click_y = x + inset, bottom - inset  # Move in by `inset` pixels
        elif direction == 'top_right_corner':
            click_x, click_y = right - inset, y + inset  # Move in by `inset` pixels
        elif direction == 'top_left_corner':
            click_x, click_y = x + inset, y + inset  # Move in by `inset` pixels
        elif direction == 'bottom_center':
            click_x, click_y = x + (right - x) // 2, bottom - inset  # Center horizontally, move down
        elif direction == 'top_center':
            click_x, click_y = x + (right - x) // 2, y + inset  # Center horizontally, move up
        elif direction == 'center':
            click_x, click_y = x + (right - x) // 2, y + (bottom - y) // 2  # Center of the location

        pyautogui.click(click_x, click_y)
        return True
    else:
        return False


"""
# Issues with this
def handle_duplicate_memo(duplicate_memo_image_path, found_land):
    if click_image(duplicate_memo_image_path):
        pyautogui.press('enter')
        logging.info("Duplicate memo ID found and handled.")
        if found_land:
            pyautogui.press('l')
            pyautogui.press('enter')
            logging.info("Pressed 'l' and 'enter' after handling duplicate memo.")
        else:
            pyautogui.press('enter')
            pyautogui.press('l')
            pyautogui.press('enter')
            logging.info("Pressed 'enter', 'l', and 'enter' after handling duplicate memo.")
    else:
        logging.info("No duplicate memo ID found. Proceeding.")
"""


### Combining Image Functions
def click_tab(tab_name, image_paths, region_key='whole_screen'):
    region = get_screen_regions()[region_key]  # Use the specified region key to select the region

    def on_image_found(location):
        # adjusted_location = (location[0] + location[2] // 2, location[1] + location[3] // 2)
        logging.info(f"Image found at {location}, clicking on the {tab_name} tab...")
        # Directly click on the found location with a small vertical adjustment
        click_relative(base_location=location, direction='center', vertical_adjustment=-15)  # Apply y-coordinate adjustment

    def on_image_not_found():
        logging.warning(f"Failed to find and click on the '{tab_name}' tab.")
        logging.debug(f"Search region used: {region}")
        logging.debug(f"Image paths attempted: {image_paths}")

    for image_path in image_paths:
        logging.info(f"Trying to locate and click on image: {image_path}")
        handle_image_detection(
            image_path=image_path,
            on_found=on_image_found,
            on_not_found=on_image_not_found,
            confidence=0.7,  # Keep the confidence level manageable
            region=region
        )

    # Usage examples:
    #click_tab('Land', land_tab_images, region_key='top_half')
    #click_tab('Land Base', land_base_tab_images, region_key='bottom_half')
    #click_tab('Permits', permits_tab_images, region_key='top_half')


def click_field_visit_button():
    region = get_screen_regions()['whole_screen']  # Assuming the Field Visit button could be anywhere on the screen

    def on_image_found(location):
        adjusted_location = (location[0] + location[2] // 2, location[1] + location[3] // 2)
        logging.info(f"Image found at {adjusted_location}, clicking on the Field Visit button...")
        click_relative(base_location=adjusted_location, direction='center')  # Adjust click direction if needed

    def on_image_not_found():
        logging.warning("Failed to click on the 'Field Visit' button.")

    for image_path in add_field_visit_image_path:
        logging.info(f"Trying to locate and click on image: {image_path}")
        handle_image_detection(
            image_path=image_path,
            on_found=on_image_found,
            on_not_found=on_image_not_found,
            confidence=0.75,
            region=region
        )


def handle_add_permit_button():
    region = get_screen_regions()['whole_screen']  # Assuming the Add Permit button could be anywhere on the screen

    def on_image_found(location):
        # Adjust the location to click in the center of the found image
        adjusted_location = (location[0] + location[2] // 2, location[1] + location[3] // 2)
        logging.info(f"Image found at {adjusted_location}, clicking on the Add Permit button...")
        click_relative(base_location=adjusted_location, direction='center')  # Click on the center of the image

    def on_image_not_found():
        logging.warning("Failed to click on the 'Add Permit' button.")

    logging.info(f"Trying to locate and click on the 'Add Permit' button.")
    handle_image_detection(
        image_path=permits_add_permit_button,  # Use the permits_add_permit_button image path
        on_found=on_image_found,
        on_not_found=on_image_not_found,
        confidence=0.75,
        region=region
    )



def handle_permit_description():
    region = get_screen_regions()['whole_screen']  # Assuming the Permit Description area could be anywhere on the screen

    def on_image_found(location):
        # Adjust the location to click just below the found image
        adjusted_location = (location[0] + location[2] // 2, location[1] + location[3] + 10)  # Adjusting to click slightly below the image
        logging.info(f"Image found at {adjusted_location}, clicking just below the Permit Description area...")
        click_relative(base_location=adjusted_location, direction='center')  # Click below the image

    def on_image_not_found():
        logging.warning("Failed to locate and click below the 'Permit Description' area.")

    logging.info(f"Trying to locate and click below the 'Permit Description' area.")
    handle_image_detection(
        image_path=permit_description,  # Use the permit_description image path
        on_found=on_image_found,
        on_not_found=on_image_not_found,
        confidence=0.75,
        region=region
    )



def handle_farm_acres(image_path, fallback_image_path, DBACRE):
    def handle_dbacre_input():
        pyautogui.press('delete')
        time.sleep(1)
        pyautogui.typewrite(str(DBACRE))
        time.sleep(1)
        pyautogui.press('tab')
        time.sleep(1)

    def on_primary_image_found(location):
        # Adjust the location and click to the right of the found image
        adjusted_location = (location[0] + location[2] // 2, location[1] + location[3] // 2)
        logging.info(f"Image found at {adjusted_location}, clicking to the right...")
        click_relative(adjusted_location, 'right', offset=100)  # Adjust offset as needed
        handle_dbacre_input()

    def on_fallback_image_found(location):
        # Click the bottom right corner of the fallback image
        logging.info(f"Fallback image found, clicking at the bottom right corner...")
        click_relative(location, 'bottom_right_corner')
        pyautogui.typewrite('f')
        time.sleep(1)
        pyautogui.press('tab')
        time.sleep(1)
        pyautogui.typewrite(str(DBACRE))
        time.sleep(1)
        pyautogui.press('tab')
        time.sleep(1)

    def handle_fallback_image():
        logging.info(f"Primary image not found. Attempting to locate fallback image: {fallback_image_path}")
        handle_image_detection(
            image_path=fallback_image_path,
            on_found=on_fallback_image_found,
            on_not_found=lambda: logging.warning("Failed to locate and click the fallback image."),
            confidence=0.8,
            region=get_screen_regions()['whole_screen']
        )

    def locate_and_decide():
        # First attempt to find and act on the primary image
        logging.info(f"Attempting to locate primary image: {image_path}")
        region = get_screen_regions()['whole_screen']  # Adjust region if necessary

        handle_image_detection(
            image_path=image_path,
            on_found=on_primary_image_found,
            on_not_found=handle_fallback_image,
            confidence=0.8,
            region=region
        )

    # Call the core logic from handle_farm_acres
    locate_and_decide()










"""
# Start the GUI event loop
"""
root.mainloop()

if not AINLIST or not MemoTXT or not PDESC or not PFILE or not PNUMBER or not TREVIEW:
    logging.error("All input fields are required.")
    exit()

"""
Connect to the database, 
pull a simple SQL query with two columns,
then the  for row in rows assigns those columns as variables 
"""

conn = connect_to_database(db_connection_string)
cursor = conn.cursor()

# The query should accommodate multiple AINs in a list
query = f"SELECT TRIM(pm.AIN), pm.LegalAcres FROM TSBv_Parcelmaster AS pm WHERE pm.AIN IN ({','.join(AINLIST)})"
rows = execute_query(cursor, query)

# Iterate through each row in the results
for row in rows:
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    DBAIN, DBACRE = row
    ensure_capslock_off()

    # Process each AIN individually
    set_focus_and_type('ProVal', DBAIN)
    time.sleep(1)

    """
    Officially begins the automation and screen navigation
    """

    set_focus_and_type('ProVal', DBAIN)
    time.sleep(1)

    pyautogui.hotkey('ctrl', 'o')
    time.sleep(1)

    press_key_multiple_times('up', 12)
    
    press_key_multiple_times('down', 4)
    
    pyautogui.press(['tab'])
    
    pyautogui.press(['delete'])
    
    pyautogui.typewrite(str(DBAIN))
    logging.info(f"Sent AIN {DBAIN}.")

    time.sleep(1)

    pyautogui.press('enter')
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    """
    ## NOW BEGIN INPUT STEPS
    """

    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(1)

    captured_text = read_text_in_region(region=whole_screen) 

    if "LAND" in captured_text:
        found_land = True
        
        pyautogui.press('l')
        pyautogui.press('enter')
        time.sleep(1)

        pyautogui.typewrite(MemoTXT)
        time.sleep(1)

        pyautogui.press('enter')
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        pyautogui.press('enter')
        time.sleep(1)
    else:
        found_land = False

        pyautogui.press('enter')
        time.sleep(1)

        pyautogui.press('l')
        time.sleep(1)

        pyautogui.press('enter')
        time.sleep(1)

        pyautogui.typewrite(MemoTXT)
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        pyautogui.press('enter')
        time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break

    """
    Send Land Base Farm Acres variable
    """
    set_focus_and_type('ProVal', str(DBACRE))
    time.sleep(1)

    logging.info("Attempting to locate and click on the 'Land' tab...")

    if click_tab('Land', land_tab_images, region_key='whole_screen'):
        time.sleep(1)
        logging.info("Attempting to locate and click on the 'Land Base' sub-tab...")
        if click_tab('Land Base', land_base_tab_images, region_key='whole_screen'):
            time.sleep(1)
            logging.info("Attempting to click the specific Windows UI button...")
            handle_farm_acres(
                image_path=farm_total_acres_image,
                fallback_image_path=aggregate_land_type_add_button,
                DBACRE=DBACRE
            )
            time.sleep(1)

    else:
        logging.warning("Failed to click the 'Land' tab. Skipping subsequent steps.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    """
    # Click on the 'Permits' tab
    """
    logging.info("Attempting to locate and click on the 'Permits' tab...")
    if click_tab('Permits', permits_tab_images, region_key='whole_screen'):
        time.sleep(2)
        logging.info("Successfully clicked on the 'Permits' tab.")
    else:
        logging.warning("Failed to click the 'Permits' tab.")
        time.sleep(1)
        
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break

    """
    # Send Appraiser Permit
    """
    # Click ADD PERMIT button
    handle_add_permit_button()

    pyautogui.typewrite(PNUMBER)
    time.sleep(1)

    pyautogui.press(['tab'])
    time.sleep(1)

    press_key_multiple_times('down', 11)
    time.sleep(1)

    press_key_multiple_times(['tab'], 3)
    time.sleep(1)

    pyautogui.typewrite(PFILE)
    time.sleep(1)

    press_key_multiple_times(['tab'], 3)
    time.sleep(1)

    pyautogui.press('space')
    logging.info("Closing Add Permit pop-up, then waiting to send description")
    time.sleep(3)
    #logging.info("WHERE am I?")

    #press_key_with_modifier_multiple_times('shift', 'tab', 4)
    #logging.info("Pressed Tab, did I land on Description?")
    #time.sleep(1)
    
    # Click below the permit description image
    handle_permit_description()
    time.sleep(1)
    # Send Description
    pyautogui.typewrite(PDESC)
    time.sleep(1)
    logging.info("Send description")
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break

    """
    # Send Add Field Visits
    """

    logging.info("Attempting to locate and click on the 'Permits' tab...")
    if click_field_visit_button():
        time.sleep(2)
        logging.info("Successfully clicked on the 'Permits' tab.")
    else:
        logging.warning("Failed to click the 'Permits' tab.")
        time.sleep(1)

    press_key_with_modifier_multiple_times('shift', 'tab', 6)
    time.sleep(1)

    pyautogui.press('space')
    time.sleep(1)

    pyautogui.press('tab')
    time.sleep(1)

    pyautogui.typewrite('p')
    time.sleep(1)

    pyautogui.press('tab')
    time.sleep(1)

    pyautogui.press('space')
    time.sleep(1)

    pyautogui.press('right')
    time.sleep(1)

    # Permit Due Date
    pyautogui.typewrite(f"04/01/{ForYear}")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    """
    # Send Timber Permit 
    """
    # Timber Review Logic
    if TREVIEW in ["Yes", "YES", "Y", "y"]:
        """
        # Send Appraiser Permit for TIMBER
        """
        # Click ADD PERMIT button
        handle_add_permit_button()

        pyautogui.typewrite(PNUMBER)
        time.sleep(1)

        pyautogui.press(['tab'])
        time.sleep(1)

        press_key_multiple_times('down', 2)
        time.sleep(1)

        press_key_multiple_times(['tab'], 3)
        time.sleep(1)

        pyautogui.typewrite(PFILE)
        time.sleep(1)

        press_key_multiple_times(['tab'], 3)
        time.sleep(1)

        pyautogui.press('space')
        logging.info("Closing Add Permit pop-up, then waiting to send description")
        time.sleep(3)
        #logging.info("WHERE am I?")

        #press_key_with_modifier_multiple_times('shift', 'tab', 4)
        #logging.info("Pressed Tab, did I land on Description?")
        #time.sleep(1)
        
        # Click below the permit description image
        handle_permit_description()
        time.sleep(1)
        # Send Description
        pyautogui.typewrite(f"{PDESC} FOR TIMBER REVIEW")
        time.sleep(1)
        logging.info("Send description")
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
        
        """
        # Send Add Field Visits
        """

        logging.info("Attempting to locate and click on the 'Permits' tab...")
        if click_field_visit_button():
            time.sleep(2)
            logging.info("Successfully clicked on the 'Permits' tab.")
        else:
            logging.warning("Failed to click the 'Permits' tab.")
            time.sleep(1)

        press_key_with_modifier_multiple_times('shift', 'tab', 6)
        time.sleep(1)

        pyautogui.press('space')
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        pyautogui.typewrite('p')
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        pyautogui.press('space')
        time.sleep(1)

        pyautogui.press('right')
        time.sleep(1)

        # Permit Due Date
        pyautogui.typewrite(f"04/01/{ForYear}")
        time.sleep(1)
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
                
    else:
        logging.info("Timber review not required, skipping this step.")
        time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    pyautogui.hotkey('ctrl', 's')
    time.sleep(1)

# Close the database connection
conn.close()

"""
Notes:
if AIN:
    press_key_multiple_times('down', 4)
elif PIN:
    press_key_multiple_times('down', 0)

## For testing purposes, 
# PIN: KC-DGW = AIN: 345134
# PIN: KC-DAS = AIN: 348586
# PIN: KC-ACB = AIN: 345133

345134,348586,345133


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

# 08/15/2024, rebuilding script with more re-usable defined functions for use in future templates. 


"""



























