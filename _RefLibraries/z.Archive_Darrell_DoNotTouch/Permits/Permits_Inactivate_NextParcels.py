
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
    filename='S:/Common/Comptroller Tech/Reports/Python/Auto_Mapping_Packet/InactivateParcel_dgw.log',
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
    PDESC = entry_permit_desc.get().strip().upper()

    logging.info(f"Processing new permit for AINs: {AINLIST}")
    logging.info(f"File Date: {PFILE}, Permit Type: {combobox_permit_type.get()}, Description: {PDESC}")
    
    # Optional: Display success message and/or close GUI
    messagebox.showinfo("Success", "Ready to begin Permit Entry.")
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

    # Permit Number
    ttk.Label(root, text="Permit Reference Number:").grid(column=0, row=1, padx=10, pady=5)
    entry_pnumber = ttk.Entry(root, width=50)
    entry_pnumber.grid(row=1, column=1, padx=10, pady=5)

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

    # File Date Input
    ttk.Label(root, text="File Date:").grid(row=4, column=0, padx=10, pady=5)
    entry_file_date = DateEntry(root, width=47, background='darkblue', foreground='white', borderwidth=2)
    entry_file_date.grid(row=4, column=1, padx=10, pady=5)


    # Submit Button
    submit_button = ttk.Button(root, text="Submit", command=on_submit)
    submit_button.grid(row=5, column=0, columnspan=2, pady=20)

    return root


### Graphic User Interface (GUI) Logic - END


def get_permit_type_code(description):
    # Dictionary mapping permit descriptions to their codes
    permit_type_codes = {
        "New Dwelling Permit": 1,
        "New Commercial Permit": 2,
        "Addition/Alt/Remodel Permit": 3,
        "Outbuilding/Garage Permit": 4,
        "Miscellaneous Permit": 5,
        "Mandatory Review": 6,
        "Roof/Siding/Wind/Mech Permit": 9,
        "Agricultural Review": 10,
        "Timber Review": 11,
        "Assessment Review": 12,
        "Seg/Combo": 13,
        "Dock/Boat Slip Permit": 14,
        "PP Review": 15,
        "Mobile Setting Permit": 99,
        "Potential Occupancy": "PO"  # Special case: string instead of a number
    }

    # Return the permit code for the given description, or None if not found
    return permit_type_codes.get(description)

# Example usage
#description = PTYPE
#code = get_permit_type_code(description) # This will be permit type code in ProVal
#print(f"The code for '{description}' is: {code}")

def get_permit_type_up_key_presses(description):
    # Dictionary mapping permit descriptions to their codes
    permit_type_codes = {
        "New Dwelling Permit": 1,
        "Timber Review": 2,
        "Assessment Review": 3,
        "Seg/Combo": 4,
        "Dock/Boat Slip Permit": 5,
        "PP Review": 6,
        "New Commercial Permit": 7,
        "Addition/Alt/Remodel Permit": 8,
        "Outbuilding/Garage Permit": 9,
        "Miscellaneous Permit": 10,
        "Mandatory Review": 11,
        "Roof/Siding/Wind/Mech Permit": 12,
        "Agricultural Review": 13,
        "Mobile Setting Permit": 14,
        "Potential Occupancy": 15  # Special case: string instead of a number
    }

    # Return the permit code for the given description, or None if not found
    return permit_type_codes.get(description)
# Example usage
#description = PTYPE
#code = get_permit_type_up_key_pressess(description) # This will be number of DOWN key pressess
#print(f"The number of down key presssess for '{description}' is: {code}")


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
def click_on_image(image_path, direction='center', offset=10, inset=7, confidence=0.75):
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

"""
# Function to ask the user for the number of accounts to process
def get_number_of_accounts():
    root = tk.Tk()
    root.withdraw()  # Hide the root window, only show the input dialog
    num_accounts = simpledialog.askinteger("Input", "Enter the number of accounts to process:")
    root.quit()
    return num_accounts


# Get the number of accounts from the user
num_accounts = get_number_of_accounts()

# Check if user input is valid
if num_accounts is None or num_accounts <= 0:
    logging.error("Invalid number of accounts entered. Exiting script.")
    print("Invalid number of accounts entered. Exiting script.")
else:

"""
# Function to show a pop-up asking the user to continue when ready
def wait_for_user_confirmation():
    # Initialize a root window
    root = tk.Tk()
    root.withdraw()  # Hide the root window, we only want the dialog box
    messagebox.showinfo("Continue", "Click OK when you are ready to continue.")
    root.quit()


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

"""
# Start Script
"""



# Start processing accounts
r = 0
while r < 200:
    r += 1
    logging.info(f"Starting process for account {r}")
    
    # Wait for user confirmation
    wait_for_user_confirmation()  # This will display the pop-up, and pause execution until "OK" is pressed
    
    # Activate ProVal window
    pyautogui.getWindowsWithTitle("ProVal")[0].activate()
    time.sleep(1.5)


    # is_image_found + click_image_single
    # How to use the is_image_found function below in script:
    # Check if the image is found and decide based on that
    if is_image_found(permits_inactivatebutton, confidence=0.75):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found
        if click_image_single(permits_inactivatebutton, direction='bottom_right_corner', inset=10, confidence=0.75):
            logging.info("Clicked successfully.")

    else:
        logging.info("Image was not found - executing alternative tasks.")
        # Perform alternative tasks


    pyautogui.hotkey('ctrl', 's')
    time.sleep(1)

    pyautogui.press('f3')
    time.sleep(1)


    # After each account, add a log
    logging.info(f"Completed process for account {r}")

# After all accounts have been processed
logging.info("Finished processing all accounts.")
print("Finished processing all accounts.")