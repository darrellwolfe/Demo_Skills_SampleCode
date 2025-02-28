"""
This script to assist with automating input of the mapping packets into ProVal
"""

import pyautogui  # For automating GUI interactions
import pyodbc  # For database connections
from pywinauto import Application  # For interacting with Windows applications
import time  # For adding delays
import numpy as np  # For numerical operations
import keyboard  # For detecting key presses
import threading  # For running background tasks
import tkinter as tk  # For creating GUI elements
from tkinter import ttk, messagebox  # For advanced Tkinter widgets and dialogs
import pytesseract  # For OCR (Optical Character Recognition)
from PIL import ImageGrab  # For capturing screen images
import cv2  # For image processing # pip install opencv-python
import os  # For interacting with the operating system
from datetime import datetime
import ctypes
from tkcalendar import DateEntry
import logging

logging.basicConfig(
    filename='S:/Common/Comptroller Tech/Reports/Python/Auto_Mapping_Packet/MappingPacketsAutomation.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

"""
KILL SCRIPT LOGIC
"""

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

"""
CONNECT TO DATABASE
"""
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
OCR REQUIRED TO RUN IMAGE RECOGNITION
"""
# This OCR program is required to work with this script, it is available on GitHub
# Set the tesseract executable path if not in the system path
# Update this path as necessary by user you will need to download and install tesseract from GitHub
# Link https://github.com/tesseract-ocr/tesseract
# Link https://github.com/UB-Mannheim/tesseract/wiki
pytesseract.pytesseract.tesseract_cmd = r'C:\Users\dwolfe\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'

"""
IMAGE PATHS
"""
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
add_field_visit_image_path = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_fieldvisit_button.PNG'
]
duplicate_memo_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memo_duplicate.PNG'

"""
POP-UP WINDOW FORM TO USE FOR VARIABLE INPUT
"""
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

"""
LOGIC FOR POP-UP WINDOW FORM TO USE FOR VARIABLE INPUTs
"""

def get_screen_regions():
    screen_width, screen_height = pyautogui.size()
    
    whole_screen = (0, 0, screen_width, screen_height)  # The entire screen
    top_half = (0, 0, screen_width, screen_height // 2)
    bottom_half = (0, screen_height // 2, screen_width, screen_height // 2)
    top_left_quarter = (0, 0, screen_width // 2, screen_height // 2)
    top_right_quarter = (screen_width // 2, 0, screen_width // 2, screen_height // 2)
    bottom_left_quarter = (0, screen_height // 2, screen_width // 2, screen_height // 2)
    bottom_right_quarter = (screen_width // 2, screen_height // 2, screen_width // 2, screen_height // 2)
    
    return whole_screen, top_half, bottom_half, top_left_quarter, top_right_quarter, bottom_left_quarter, bottom_right_quarter

whole_screen, top_half, bottom_half, top_left_quarter, top_right_quarter, bottom_left_quarter, bottom_right_quarter = get_screen_regions()

land_tab_regions = [top_half]  # Assuming Land tab will be in the top half
land_base_regions = [bottom_half]  # Adjust based on expected location
permits_regions = [top_half]  # Assuming Permits tab will be in the top half

"""
SCREEN READING LOGIC - pytesseract - OCR LOGIC TO READ PROVAL AND THEN APPLY CLICK LOGIC
"""

def read_text_in_region(region):
    screenshot = pyautogui.screenshot(region=region)
    text = pytesseract.image_to_string(screenshot)
    return text

"""
CLICK IMAGE LOGIC - creates is_image_on_screen to be used below
"""

def click_image(image_path, confidence=0.8):
    try:
        if not os.path.exists(image_path):
            logging.error(f"Image file not found: {image_path}")
            return False

        ref_image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

        screenshot = pyautogui.screenshot()
        screenshot = cv2.cvtColor(np.array(screenshot), cv2.COLOR_BGR2GRAY)

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

def is_image_on_screen(image_path, confidence=0.8):
    try:
        if not os.path.exists(image_path):
            logging.error(f"Image file not found: {image_path}")
            return False

        ref_image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

        screenshot = pyautogui.screenshot()
        screenshot = cv2.cvtColor(np.array(screenshot), cv2.COLOR_BGR2GRAY)

        result = cv2.matchTemplate(screenshot, ref_image, cv2.TM_CCOEFF_NORMED)
        min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)

        if max_val >= confidence:
            return True
        else:
            return False
    except Exception as e:
        logging.error(f"Failed to check image: {image_path}")
        logging.error(f"Exception: {e}")
        return False

"""
SET FOCUS LOGIC - can be called to set focus to different screens at different points in the process
"""

def set_focus_and_type(window_title, keys):
    window = pyautogui.getWindowsWithTitle(window_title)
    if window:
        window[0].activate()
        pyautogui.typewrite(keys)

"""
PRESS & CLICK LOGIC -- sets logic for various kinds of click tasks
"""

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

"""
CLICK IMAGE LOGIC
# Check for duplicate memo ID
"""

def handle_duplicate_memo(duplicate_memo_image_path, found_land):
    if is_image_on_screen(duplicate_memo_image_path):
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
CLICK IMAGE LOGIC
"""

def ensure_click_image(image_path, alt_image_path=None, confidence=0.8):
    clicked = click_image(image_path, confidence)
    if not clicked and alt_image_path:
        clicked = click_image(alt_image_path, confidence)
    return clicked

"""
CLICK IMAGE LOGIC
"""

def click_land_tab():
    for image in land_tab_images:
        logging.info(f"Trying to click on image: {image}")
        if ensure_click_image(image, confidence=0.75):
            logging.info("Successfully clicked on the 'Land' tab.")
            return True
    logging.warning("Failed to click on the 'Land' tab.")
    return False

def click_land_base_tab():
    for image in land_base_tab_images:
        logging.info(f"Trying to click on image: {image}")
        if ensure_click_image(image, confidence=0.75):
            logging.info("Successfully clicked on the 'Land Base' tab.")
            return True
    logging.warning("Failed to click on the 'Land Base' tab.")
    return False

def click_permits_tab():
    for image in permits_tab_images:
        logging.info(f"Trying to click on image: {image}")
        if ensure_click_image(image, confidence=0.75):
            logging.info("Successfully clicked on the 'Permits' tab.")
            return True
    logging.warning("Failed to click on the 'Permits' tab.")
    return False

def click_field_visit_button():
    for image in add_field_visit_image_path:
        logging.info(f"Trying to click on image: {image}")
        if ensure_click_image(image, confidence=0.75):
            logging.info("Successfully clicked on the 'Permits' tab.")
            return True
    logging.warning("Failed to click on the 'Permits' tab.")
    return False

"""
CLICK IMAGE LOGIC
"""

button_info = {
    "window_title": "ProVal",
    "class_name": "WindowsForms10.BUTTON.app.0.13965fa_r8_ad19",
    "button_text": "Add",
    "region_title": "Aggregate Land"
}

def click_relative(image_path, direction, offset=50, confidence=0.8, inset=7):
    location = pyautogui.locateOnScreen(image_path, confidence=confidence)
    if location:
        right = location.left + location.width
        bottom = location.top + location.height
        
        if direction == 'right':
            click_x, click_y = right + offset, location.top + location.height // 2
        elif direction == 'left':
            click_x, click_y = location.left - offset, location.top + location.height // 2
        elif direction == 'above':
            click_x, click_y = location.left + location.width // 2, location.top - offset
        elif direction == 'below':
            click_x, click_y = location.left + location.width // 2, bottom + offset
        elif direction == 'bottom_right_corner':
            click_x, click_y = right - inset, bottom - inset  # Move in by `inset` pixels
        elif direction == 'bottom_left_corner':
            click_x, click_y = location.left + inset, bottom - inset  # Move in by `inset` pixels
        elif direction == 'top_right_corner':
            click_x, click_y = right - inset, location.top + inset  # Move in by `inset` pixels
        elif direction == 'top_left_corner':
            click_x, click_y = location.left + inset, location.top + inset  # Move in by `inset` pixels
        elif direction == 'bottom_center':
            click_x, click_y = location.left + location.width // 2, bottom - inset  # Move in by `inset` pixels
        elif direction == 'top_center':
            click_x, click_y = location.left + location.width // 2, location.top + inset  # Move in by `inset` pixels
        elif direction == 'center':
            click_x, click_y = location.left + location.width // 2, location.top + location.height // 2

        pyautogui.click(click_x, click_y)
        return True
    else:
        return False




def locate_and_decide_farm_acres(image_path, fallback_image_path, DBACRE):
    try:
        # Take a screenshot and convert it to grayscale
        screenshot = pyautogui.screenshot()
        screenshot = cv2.cvtColor(np.array(screenshot), cv2.COLOR_BGR2GRAY)
        template = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
        result = cv2.matchTemplate(screenshot, template, cv2.TM_CCOEFF_NORMED)
        min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)

        if max_val >= 0.8:
            # Click to the right of the image
            click_relative(image_path, 'right')
            logging.info(f"Triple clicked to the right of image found at {max_loc}")

            # Delete the contents and send DBACRE
            pyautogui.press('delete')
            time.sleep(1)

            pyautogui.typewrite(str(DBACRE))
            time.sleep(1)

            pyautogui.press('tab')
            time.sleep(1)
        else:
            # Click the bottom right corner of the fallback image (e.g., "Add" button)
            if click_relative(fallback_image_path, direction='bottom_right_corner', confidence=0.8):
                logging.info("Successfully clicked the bottom right corner of the fallback image.")
                
                # Send the DBACRE value after clicking the fallback button
                pyautogui.typewrite('f')
                time.sleep(1)

                pyautogui.press('tab')
                time.sleep(1)

                pyautogui.typewrite(str(DBACRE))
                time.sleep(1)

                pyautogui.press('tab')
                time.sleep(1)
            else:
                logging.warning("Failed to locate and click the fallback image.")
    except Exception as e:
        logging.error(f"Failed to decide action based on image presence: {e}")


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

    # Enter Land Memos
    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(1)

    captured_text = read_text_in_region(region=whole_screen)  # Example using top half region

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

    if click_land_tab():
        time.sleep(1)
        logging.info("Attempting to locate and click on the 'Land Base' sub-tab...")
        if click_land_base_tab():
            time.sleep(1)

            logging.info("Attempting to click the specific Windows UI button...")

            locate_and_decide_farm_acres(
                image_path=r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_farm_total_acres.PNG', 
                fallback_image_path=r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_aggregate_land_type_add_button.PNG', 
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
    if click_permits_tab():
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
    if click_image(r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_permit_button.PNG', confidence=0.8):
        logging.info("Successfully clicked on the 'Add Permit' button.")
        time.sleep(2)
    else:
        logging.warning("Failed to click the 'Add Permit' button.")
        time.sleep(1)

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
    
    # Shift+tab*4 wasn't working, clicking below the image instead.
    click_relative(image_path=r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permit_description.PNG', direction='below', offset=10, confidence=0.8)
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
        if click_image(r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_permit_button.PNG', confidence=0.8):
            logging.info("Successfully clicked on the 'Add Permit' button.")
            time.sleep(2)
        else:
            logging.warning("Failed to click the 'Add Permit' button.")
            time.sleep(1)

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
        
        # Shift+tab*4 wasn't working, clicking below the image instead.
        click_relative(image_path=r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permit_description.PNG', direction='below', offset=10, confidence=0.8)
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
"""