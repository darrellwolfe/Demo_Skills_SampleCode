# After ensuring all packages are installed, you can import them as needed in your script
import os
import pyautogui  # For automating GUI interactions like mouse movements and clicks
import pyodbc  # For establishing database connections and executing SQL queries
import time  # For adding delays and managing time-related functions
import numpy as np  # For numerical operations and handling arrays/matrices
import keyboard  # For detecting and handling keyboard key presses
import threading  # For running background tasks and creating concurrent threads
import tkinter as tk  # For creating basic GUI elements in Python applications
from tkinter import ttk, messagebox, simpledialog  # For advanced Tkinter widgets and displaying dialog boxes
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
import pandas as pd


"""
# GLOBAL LOGICS - LOGGING FUNCTIONS
"""

### Logging Setup
# Determine the user's home directory
user_home_dir = os.environ.get('USERPROFILE') or os.environ.get('HOME')

# Update LogNameHere to your actual log name
log_name = 'ProValAutomation'
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



"""
# GLOBAL LOGICS - LOGIC FUNCTIONS
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


ensure_capslock_off()


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


### Graphic User Interface (GUI) Logic - START

def calculate_for_year():
    current_date = datetime.now()
    if current_date.month > 4 or (current_date.month == 4 and current_date.day >= 16):
        return current_date.year + 1
    else:
        return current_date.year

# Get today's date in mm/dd/yyyy format
today_date = datetime.now().strftime("%m/%d/%Y")
the_month = datetime.now().month
the_day = datetime.now().day
the_year = datetime.now().year
calc_year = calculate_for_year()

# You can then use `today_date` in your code wherever you need the formatted date
logging.info(f"Today's date is: {today_date}, Day {the_day}, Month {the_month}, Year {the_year}, Calculated Year {calc_year}")



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
import pandas as pd
import pyautogui
import time
import tkinter as tk
from tkinter import messagebox

def load_data_from_excel(filepath, sheet_name, header_row):
    """ Load the specified sheet into a DataFrame. """
    df = pd.read_excel(filepath, sheet_name=sheet_name, header=header_row-1)
    return df

def show_item_info(item):
    """ Show a popup with information about the current item from Column A and ask if ready to proceed. """
    # This line initializes Tkinter to use messagebox
    root = tk.Tk()
    root.withdraw()  # Hides the main window

    # Combine the message and the question in one dialog
    message = f"Currently processing: {item}\n. Click in the first box under size, then confirm: Are you ready to start or continue?"
    response = messagebox.askyesno("Confirm", message)
    
    # This line is crucial; it destroys the Tk object after use to prevent memory leaks and multiple open windows.
    root.destroy()
    return response

def send_data_to_application(df):
    """ Send data from DataFrame to an application, tabbing between fields. """
    for index, row in df.iterrows():
        # Display info and ask for confirmation to proceed with the current row
        if not show_item_info(row['val_element']):  # Assuming 'val_element' is the name for column A
            print(f"Stopped by user at row {index + 1}.")
            break  # Exit the loop if the user chooses not to continue

        valid_entries = [
            col for col in df.columns[6:34] 
            if pd.notna(row[col]) and row[col] > 0 and row[col] not in [0, 999999, -999999, -1059999] and isinstance(row[col], (int, float))
        ]

        for i, col in enumerate(valid_entries):
            pyautogui.typewrite(str(row[col]))  # Type the value
            if i < len(valid_entries) - 1:  # Check if it's not the last valid entry
                pyautogui.press('tab')  # Press Tab to move to the next field
            time.sleep(0.1)  # Small delay to allow the UI to update

def main():
    filepath = "S:\\Common\\Comptroller Tech\\Reports\\Python\\ProVal_TablesEngines\\MH_SFRates_Update.xlsx"
    sheet_name = "Mobile_Home_Rates-Adjusted"
    header_row = 9
    df = load_data_from_excel(filepath, sheet_name, header_row)

    if messagebox.askyesno("Confirm", "Start entering data into the application? Select the Improvement ClassModifier & Valuation method, Click 'Update Item Selected', click Yes."):
        send_data_to_application(df)

if __name__ == "__main__":
    main()









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

    press_key_multiple_times('backspace', 12)
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











    # Process: Open Memos
    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(1)





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





# Close the cursor and connection
cursor.close()
logging.info("Cursor Closed")
conn.close()
logging.info("Database Connection Closed")

logging.info("ALL_STOP_NEXT")




 """

    



