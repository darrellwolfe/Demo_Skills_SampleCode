
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
from tkinter import simpledialog
import pytesseract  # For OCR (Optical Character Recognition) to read text from images
from PIL import Image, ImageGrab  # For working with image data
import cv2  # For image processing and computer vision tasks (OpenCV library)
import ctypes  # For interacting with C data types and Windows API functions
from tkcalendar import DateEntry  # For adding a calendar widget to Tkinter GUIs
import logging  # For logging events, errors, and information during script execution
from datetime import datetime # For handling dates and times
import re # The import re statement in Python imports the regular expressions (regex) module, which provides a powerful way to search, match, and manipulate strings based on patterns.
import sys # Contains basic Python commands regarding runtime and formatting; used for exiting code
import pygetwindow as gw
import pandas as pd
import time
import os
import logging

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



"""
# GLOBAL LOGICS - CONNECTIONS
"""



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


# Just call this in your final script
# stop_script 

# Or this
# if stop_script:
#     logging.info("Script stopping due to kill key press.")
#     stop_script


user_home_dir = os.environ.get('USERPROFILE') or os.environ.get('HOME')

# Define the log directory and file based on the user's home directory
log_dir = os.path.join(str(user_home_dir), 'MPPV_Assett_Handler')
log_file = os.path.join(log_dir, 'MPPV_Assett_Handler.log')

# Ensure the log directory exists
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

logging.basicConfig(
    filename=log_file,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)



# Call this in script
#logging.info("Whatever I write here will print outinto the log.")
#logging.info(f"Place an f in front of text in double quots and variable in cruly brackets {DBAIN}} to have that variable output show up in the log.")


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
    log_processor = AINLogProcessor(log_file)

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



# Businses Personal Property One Off Selections

BPP_MPPV_AssetsInput_Category = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_AssetsInput_Category.PNG'
BPP_MPPV_AssetsInput_New = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_AssetsInput_New.PNG'
BPP_MPPV_AssetsInput_Save = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_AssetsInput_Save.PNG'
BPP_MPPV_EFFDate = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_EFFDate.PNG'
BPP_MPPV_SearchBy = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_SearchBy.PNG'
BPP_MPPV_AssetsInput_Deactivate = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_AssetsInput_Deactivate.PNG'

# Businses Personal Property IF Logic for PopUp windows
BPP_MPPV_IFLogic_AnnualFileBlank = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_AnnualFileBlank.PNG'
BPP_MPPV_IFLogic_AnnualFileBlank_YES = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_AnnualFileBlank_YES.PNG'
BPP_MPPV_IFLogic_SaveAssetChanges = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_SaveAssetChanges.PNG'
BPP_MPPV_IFLogic_SaveAssetChanges_YES = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_SaveAssetChanges_YES.PNG'
BPP_MPPV_IFLogic_ValueUpdate = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_ValueUpdate.PNG'
BPP_MPPV_IFLogic_ValueUpdate_YES = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_ValueUpdate_YES.PNG'
BPP_MPPV_IFLogic_ErrorSaveAsset = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_ErrorSaveAsset.PNG'
BPP_MPPV_IFLogic_ObjectClosed = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_ObjectClosed.PNG'






BPP_MPPV_Tab_AssetsTab = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_Tab_Assets_Unseleted.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_Tab_Assets_Seleted.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_Tab_Assets_Seleted_2.PNG'
]


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
        time.sleep(0.25)
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
    time.sleep(0.25)


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







class AssetInactivator:
    def __init__(self):
        self.num_iterations = 0

    def get_number_of_iterations(self):
        # Create a simple dialog to get the number of iterations from the user
        root = tk.Tk()
        root.withdraw()  # Hide the root window
        self.num_iterations = simpledialog.askinteger("Input", "How many times should the asset inactivator run?")
        root.destroy()  # Destroy the root window after getting input


    def asset_inactivator_logic(self):


        # Click De-Activate button
        if click_image_single(BPP_MPPV_AssetsInput_Deactivate, direction='center', confidence=0.75):
            logging.info("Clicked successfully BPP_MPPV_AssetsInput_Deactivate.")
            time.sleep(0.25)
            check_stop_script()

            press_key_multiple_times(['tab'], 2)
            time.sleep(0.25)
            logging.info("Press Tab.")
            check_stop_script()

            pyautogui.press('down')
            time.sleep(0.25)
            logging.info("Press Down.")
            check_stop_script()

        else:
            sys.exit("Script terminated De-Activate Button not found")
            check_stop_script()


    def run(self):
        self.get_number_of_iterations()
        if self.num_iterations is None:
            logging.info("No input provided. Exiting the function.")
            return

        for _ in range(self.num_iterations):
            self.asset_inactivator_logic()
            time.sleep(0.25)
            self.check_check_stop_script()()  # Ensure to check if the script should stop

    def check_stop_script(self):
        # Placeholder for stop script logic
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            sys.exit("Script terminated")

    

class AssetImporter:
    def __init__(self, file_path):
        self.file_path = file_path

    def run(self):
        logging.info("Running Asset Importer")
        dataframe = self.read_excel_to_dataframe()  # No need to pass self.file_path
        self.enter_data_into_gui(dataframe)

    def read_excel_to_dataframe(self):
        # Define the column names
        column_names = ['MPPV_Category', 'MPPV_Schedule', 'MPPV_AcqDate', 'MPPV_Cost', 'MPPV_Description']
        
        # Read the Excel file, forcing all columns to be treated as strings (i.e., text)
        # and apply custom column names
        return pd.read_excel(self.file_path, skiprows=0, names=column_names, dtype=str)


    def enter_data_into_gui(self, dataframe):

        for index, row in dataframe.iterrows():
            category = row['MPPV_Category']
            schedule = row['MPPV_Schedule']
            acq_date = row['MPPV_AcqDate']
            cost = row['MPPV_Cost']
            description = row['MPPV_Description']

            logging.info(f"Variable Row Detail category {category}.")
            logging.info(f"Variable Row Detail schedule {schedule}.")
            logging.info(f"Variable Row Detail acq_date {acq_date}.")
            logging.info(f"Variable Row Detail cost {cost}.")
            logging.info(f"Variable Row Detail description {description}.")
            check_stop_script()

            set_focus("MPPV.exe (1.9.0.057)")
            time.sleep(0.25)
            logging.info("Set Focus.")
            check_stop_script()

            # Click Assets Tab
            if click_images_multiple(BPP_MPPV_Tab_AssetsTab, direction='center', confidence=0.75):
                logging.info("Clicked successfully BPP_MPPV_Tab_AssetsTab.")
                time.sleep(0.25)
                check_stop_script()
            time.sleep(0.25)

            # Click New
            if click_image_single(BPP_MPPV_AssetsInput_New, direction='center', confidence=0.75):
                logging.info("Clicked successfully BPP_MPPV_AssetsInput_New.")
                time.sleep(0.25)
                check_stop_script()
            time.sleep(0.25)

            # Click to the right of Category
            if click_image_single(BPP_MPPV_AssetsInput_Category, direction='right', offset=15, confidence=0.75):
                logging.info("Clicked successfully BPP_MPPV_AssetsInput_Category.")
                time.sleep(0.25)
                check_stop_script()
            time.sleep(0.25)
            check_stop_script()

            # Enter Category
            pyautogui.write(category)
            time.sleep(0.25)
            logging.info(f"Sent Category {category}")
            check_stop_script()

            # Tab once to Schedule, enter Schedule
            pyautogui.press('tab')
            logging.info("Press Tab.")
            time.sleep(0.25)
    
            pyautogui.write(str(schedule))
            logging.info(f"Sent schedule {schedule}")
            time.sleep(0.25)
            check_stop_script()

            # Tab three times to Acq Date, enter Acq Date
            press_key_multiple_times(['tab'], 3)
            logging.info("Press Tab.")
            pyautogui.write(str(acq_date))
            logging.info(f"Sent acq_date {acq_date}")
            time.sleep(0.25)
            check_stop_script()

            # Tab once to Acq Cost, enter Acq Cost
            pyautogui.press('tab')
            logging.info("Press Tab.")
            pyautogui.write(str(cost))
            logging.info(f"Sent cost {cost}")
            time.sleep(0.25)
            check_stop_script()

            # Tab three times to Description, enter Description
            press_key_multiple_times(['tab'], 3)
            logging.info("Press Tab.")
            pyautogui.write(description)
            logging.info(f"Sent description {description}")
            time.sleep(0.25)
            check_stop_script()

            # Tab to "Update Value"
            pyautogui.press('tab')
            logging.info("Press Tab")
            time.sleep(0.25)
            pyautogui.press('enter')
            logging.info("Press Enter")
            time.sleep(0.25)
            check_stop_script()

            # Click Save
            if click_image_single(BPP_MPPV_AssetsInput_Save, direction='center', confidence=0.75):
                logging.info("Clicked successfully BPP_MPPV_AssetsInput_New.")
                time.sleep(0.25)
                check_stop_script()
            time.sleep(0.25)


            # Logic for PopUps
            if is_image_found(BPP_MPPV_IFLogic_ObjectClosed, confidence=0.75):
                logging.info("Image was found - BPP_MPPV_IFLogic_ObjectClosed.")
                time.sleep(0.25)
                sys.exit("Script terminated BPP_MPPV_IFLogic_ObjectClosed")
                # Perform tasks related to the image being found
            else:
                logging.info("Image was not found - executing alternative tasks.")
                time.sleep(0.25)
                # Perform alternative tasks

            if is_image_found(BPP_MPPV_IFLogic_ValueUpdate, confidence=0.75):
                logging.info("Image was found - executing related tasks.")
                if click_image_single(BPP_MPPV_IFLogic_ValueUpdate_YES, direction='center', confidence=0.75):
                    logging.info("Clicked successfully BPP_MPPV_IFLogic_ValueUpdate_YES.")
                time.sleep(0.25)
                check_stop_script()

            if is_image_found(BPP_MPPV_IFLogic_AnnualFileBlank, confidence=0.75):
                logging.info("Image was found - executing related tasks.")
                if click_image_single(BPP_MPPV_IFLogic_AnnualFileBlank_YES, direction='center', confidence=0.75):
                    logging.info("Clicked successfully BPP_MPPV_IFLogic_AnnualFileBlank_YES.")
                time.sleep(0.25)
                check_stop_script()

            if is_image_found(BPP_MPPV_IFLogic_SaveAssetChanges, confidence=0.75):
                logging.info("Image was found - executing related tasks.")
                if click_image_single(BPP_MPPV_IFLogic_SaveAssetChanges_YES, direction='center', confidence=0.75):
                    logging.info("Clicked successfully BPP_MPPV_IFLogic_SaveAssetChanges_YES.")
                time.sleep(0.25)
                check_stop_script() 

            if is_image_found(BPP_MPPV_IFLogic_ErrorSaveAsset, confidence=0.75):
                logging.info("Image was found - executing related tasks.")  
                time.sleep(0.25)
                pyautogui.press('enter')
                time.sleep(0.25)
                pyautogui.press('esc')
                time.sleep(0.25)
                check_stop_script()

            if is_image_found(BPP_MPPV_IFLogic_ObjectClosed, confidence=0.75):
                logging.info("Image was found - BPP_MPPV_IFLogic_ObjectClosed.")
                time.sleep(0.25)
                sys.exit("Script terminated BPP_MPPV_IFLogic_ObjectClosed")
                # Perform tasks related to the image being found
            else:
                logging.info("Image was not found - executing alternative tasks.")
                time.sleep(0.25)
                # Perform alternative tasks


            # Add a delay to ensure the GUI has time to process each entry
            time.sleep(0.25)

        check_stop_script()
        pass

# Main function to execute the tool
# ... existing code ...

class AssetTool:
    def __init__(self):
        self.inactivator = AssetInactivator()
        self.importer = AssetImporter(r'S:\Common\Specialized Appraisal\Personal Property\_AutomationTemplate\AssetImport.xlsx')

    def choose_tool(self):
        root = tk.Tk()
        root.title("Select Tool")

        # Create a label
        label = ttk.Label(root, text="Select a tool to run:")
        label.pack(pady=10)

        # Create a combobox (dropdown)
        tool_choice = tk.StringVar()
        tool_combobox = ttk.Combobox(root, textvariable=tool_choice)
        tool_combobox['values'] = ('Inactivator', 'Importer')
        tool_combobox.pack(pady=10)
        tool_combobox.current(0)  # Set default selection

        # Function to close the window and return the choice
        def on_select():
            root.quit()

        # Create a button to confirm selection
        select_button = ttk.Button(root, text="Select", command=on_select)
        select_button.pack(pady=10)

        root.mainloop()
        root.destroy()
        return tool_choice.get()

    def run(self):
        choice = self.choose_tool()
        if choice == 'Inactivator':
            logging.info("run inactivator.")
            self.inactivator.run()
        elif choice == 'Importer':

            logging.info("run importer.")
            self.importer.run()
        else:
            logging.info("Invalid choice. Exiting.")

# Example usage
if __name__ == "__main__":
    asset_tool = AssetTool()
    asset_tool.run()