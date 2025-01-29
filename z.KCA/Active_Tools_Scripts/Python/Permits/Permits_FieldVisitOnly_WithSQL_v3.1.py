import sys
import pyautogui
import pyodbc
import time
import numpy as np
import keyboard
import threading
import tkinter as tk
import pytesseract
from PIL import Image, ImageGrab
import cv2
import ctypes
import logging
import os
from datetime import datetime
import pygetwindow as gw
import tkinter as tk
from tkinter import simpledialog

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
permits_includeinactivecheckbox = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_includeinactivecheckbox.PNG'
permits_click_permit_number_column = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_click_permit_number_column.PNG'



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


# Utility Functions

# Declare today and due_year as global variables
today = datetime.now()
due_year = None  # Initialize due_year globally

# Define get_due_year function
def get_due_year():
    global due_year, today
    current_year = today.year
    # Calculate the due_year based on current month and day
    if today.month > 10 or (today.month == 10 and today.day >= 1):
        due_year = current_year + 1
    else:
        due_year = current_year
    return due_year

# Call get_due_year to update the global due_year
get_due_year()

# You can now access due_year globally
logging.info(f"Today is {today}, and the global due_year is: {due_year}")

def ensure_capslock_off():
    if is_capslock_on():
        pyautogui.press('capslock')
        logging.info("CAPS LOCK was on. It has been turned off.")
    else:
        logging.info("CAPS LOCK is already off.")

def is_capslock_on():
    hllDll = ctypes.WinDLL("User32.dll")
    VK_CAPITAL = 0x14
    return hllDll.GetKeyState(VK_CAPITAL) & 1

def set_focus(window_title):
    window = gw.getWindowsWithTitle(window_title)
    if window:
        window[0].activate()

def press_key_multiple_times(key, times, delay=0.1):
    for _ in range(times):
        pyautogui.press(key)
        time.sleep(delay)

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

stop_lock = threading.Lock()


def check_stop_script():
    with stop_lock:
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            sys.exit("Script terminated")


# 1 CAPTURE SCREEN IN GREYSCALE
def capture_and_convert_screenshot():
    # Capture the screenshot using pyautogui
    # screenshot = pyautogui.screenshot()
    screenshot = ImageGrab.grab(all_screens=True)

    # Log the size of the screenshot
    logging.info(f"Screenshot size: {screenshot.size}")

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
            'within_left': (top_left[0] + inset, top_left[1] + h // 2),  # New option for left within the image
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

def initialize_logging():

    if not hasattr(logging, 'is_configured') or not logging.is_configured:
        user_home_dir = os.environ.get('USERPROFILE') or os.environ.get('HOME')
        log_dir = os.path.join(user_home_dir, 'Documents', 'FieldVisitUpdaterLog')
        if not os.path.exists(log_dir):
            os.makedirs(log_dir)

        log_filename = os.path.join(log_dir, 'FieldVisitUpdater.log')

        logging.basicConfig(
            filename=log_filename,
            level=logging.DEBUG,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        
        # Adding a console handler to also output to the console
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.DEBUG)
        console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
        logging.getLogger().addHandler(console_handler)

        # Log that the logging has been initialized
        logging.info("Logging initialized.")

        logging.is_configured = True

    # Usage within the same script or different scripts
    #if __name__ == "__main__":
    #    initialize_logging()
    #    logging.info("This is a test log message.")


class FieldVisitUpdater:

    def __init__(self, connection_string, query):
        initialize_logging()
        self.connection_string = connection_string
        self.query = query
        self.rows = []  # Initialize rows here to ensure it's always defined
        logging.info("FieldVisitUpdater initialized with connection string and query.")

    def fetch_data(self):
        try:
            with pyodbc.connect(self.connection_string) as conn:
                cursor = conn.cursor()
                cursor.execute(self.query)
                self.rows = cursor.fetchall()
                logging.info(f"Data fetched successfully: {len(self.rows)} records found.")
        except Exception as e:
            logging.error(f"An error occurred while fetching data: {e}")


    def execute_query(self, cursor, query):
        cursor.execute(query)
        return cursor.fetchall()

    def process_single_parcel(self, row):
        retry_count = 3  # Retry up to 3 times
        for attempt in range(retry_count):
            try:
                DBRefNum, DBDescr, DBAIN, DBPIN, DBSitus, DBCity, DBLRSN, DBPermCount = row

                #SQL Query
                logging.info(f"DBRefNum: {DBRefNum}")
                logging.info(f"DBDescr: {DBDescr}")
                logging.info(f"DBAIN: {DBAIN}")
                logging.info(f"DBPIN: {DBPIN}")
                logging.info(f"DBSitus: {DBSitus}")
                logging.info(f"DBCity: {DBCity}")
                logging.info(f"DBLRSN: {DBLRSN}")
                logging.info(f"DBPermCount: {DBPermCount}")
                logging.info(f"Today Date is {today}")
                logging.info(f"Due Date is 12/31/{due_year}")

                ensure_capslock_off()
                logging.info("Begin ProVal AIN LookUp")
                self.ProVal_AIN_LookUp(DBAIN)
                check_stop_script()
                logging.info("Begin Navigate to Permits Tab")
                self.Navigate_PermitsTab()
                check_stop_script()
                logging.info("Begin Add Field Visit")
                self.Permits_AddFieldVisit()
                check_stop_script()
                logging.info("Begin ProVal Save")
                self.ProVal_Save()
                check_stop_script()
                return True
            except Exception as e:
                logging.error(f"Attempt {attempt + 1} failed for single parcel {DBAIN}: {e}")
                time.sleep(0.25)  # Delay before retrying
        logging.error(f"Failed to process single parcel {DBAIN} after {retry_count} attempts.")
        return False



    def process_multiple_parcel(self, row):
        retry_count = 3  # Retry up to 3 times
        for attempt in range(retry_count):
            try:
                DBRefNum, DBDescr, DBAIN, DBPIN, DBSitus, DBCity, DBLRSN, DBPermCount = row
                #SQL Query
                logging.info(f"DBRefNum: {DBRefNum}")
                logging.info(f"DBDescr: {DBDescr}")
                logging.info(f"DBAIN: {DBAIN}")
                logging.info(f"DBPIN: {DBPIN}")
                logging.info(f"DBSitus: {DBSitus}")
                logging.info(f"DBCity: {DBCity}")
                logging.info(f"DBLRSN: {DBLRSN}")
                logging.info(f"DBPermCount: {DBPermCount}")
                logging.info(f"Today Date is {today}")
                logging.info(f"Due Date is 12/31/{due_year}")


                ensure_capslock_off()
                logging.info("Begin ProVal AIN LookUp")
                self.ProVal_AIN_LookUp(DBAIN)
                logging.info("Begin Navigate to Permits Tab")
                time.sleep(0.25)
                check_stop_script()
                self.Navigate_PermitsTab()
                check_stop_script()
                time.sleep(0.25)


                logging.info("Begin Wich Permit Check")
                # Create a pop-up window to ask the user which permit they want to process (1-10)
                self.root = tk.Tk()
                self.root.withdraw()
                check_stop_script()
                time.sleep(0.25)

                try:
                    permit_number = simpledialog.askinteger(
                        "Select Permit",
                        f"Which number is permit {DBRefNum} (1-10)? If you've already clicked on the permit, use 1",
                        minvalue=1,
                        maxvalue=10
                    )
                    
                    if permit_number is not None:
                        # Calculate the number of times to press 'down' based on th 101334
                        #  permit number (0 for permit 1, 1 for permit 2, etc.)
                        num_times_to_press_down = permit_number - 1
                        set_focus("ProVal")
                        time.sleep(0.25)
                        logging.info("set_focus(ProVal)")
                        self.Navigate_PermitsTab()
                        time.sleep(0.25)

                        if click_image_single(permits_click_permit_number_column, direction='center', inset=10, confidence=0.75):
                            logging.info("Clicked successfully permits_click_permit_number_column.")
                            time.sleep(2)

                        check_stop_script()
                        press_key_multiple_times('down', num_times_to_press_down)
                        time.sleep(0.25)
                        logging.info(f"Pressed 'down' key {num_times_to_press_down} times for permit {permit_number}.")
                        time.sleep(0.25)
                    else:
                        logging.warning("User cancelled the permit selection. Stopping the script.")
                        sys.exit("Script terminated by user.")  # Terminate the script immediately if Cancel is pressed
                        time.sleep(0.25)

                except Exception as e:
                    logging.error(f"An error occurred while getting user input: {e}")
                    sys.exit("Script terminated due to an error.")
                    time.sleep(0.25)

                check_stop_script()
                logging.info("Begin Add Field Visit")
                self.Permits_AddFieldVisit()
                time.sleep(0.25)
                check_stop_script()

                logging.info("Begin ProVal Save")
                self.ProVal_Save()
                time.sleep(0.25)
                check_stop_script()

                return True
            except Exception as e:
                logging.error(f"Attempt {attempt + 1} failed for single parcel {DBAIN}: {e}")
                time.sleep(0.25)  # Delay before retrying
        logging.error(f"Failed to process single parcel {DBAIN} after {retry_count} attempts.")
        return False


    def process_parcels(self):
        # Separate rows with DBPermCount == 1 and others
        process_single_parcel = [row for row in self.rows if row[7] == 1]
        process_multiple_parcel = [row for row in self.rows if row[7] > 1]

        # Process rows with DBPermCount == 1 first
        for row in process_single_parcel:
            if not self.process_single_parcel(row):
                logging.warning(f"Processing failed for single permit row: {row}. Continuing to the next row.")
                continue

        # After processing DBPermCount == 1, process the remaining rows
        for row in process_multiple_parcel:
            if not self.process_multiple_parcel(row):
                logging.warning(f"Processing failed for multiple permit row: {row}. Continuing to the next row.")
                continue


    def ProVal_AIN_LookUp(self, DBAIN):
        set_focus("ProVal")
        time.sleep(0.25)
        logging.info("set_focus(ProVal)")
        pyautogui.hotkey('ctrl', 'o')
        logging.info("Press Ctrl+o")
        time.sleep(2)
        press_key_multiple_times('up', 12)
        press_key_multiple_times('down', 4)
        logging.info("Select AltAIN")
        pyautogui.press(['tab'])
        logging.info("Press Tab")
        pyautogui.press(['delete'])
        logging.info("Press Delete")
        ensure_capslock_off()
        time.sleep(0.25)
        pyautogui.typewrite(str(DBAIN))
        logging.info(f"Sent AIN {DBAIN}.")
        time.sleep(0.25)
        pyautogui.press('enter')
        logging.info("Press Enter")
        time.sleep(2)
        set_focus("ProVal")
        logging.info("Select Focus ProVal")
        time.sleep(0.25)
        pyautogui.hotkey('win', 'up')
        logging.info("Press Windows Key + Up Key")

    def Navigate_PermitsTab(self):
        set_focus('ProVal')
        logging.info("set_focus...")
        time.sleep(0.25)
        if click_images_multiple(permits_tab_images, direction='center', inset=10, confidence=0.75):
            logging.info("Clicked successfully permits_tab_images.")
        if click_image_single(permits_includeinactivecheckbox, direction='within_left', inset=10, confidence=0.98):
            logging.info("Clicked successfully permits_includeinactivecheckbox.")
            time.sleep(2)






    def Permits_AddFieldVisit(self):
        if click_image_single(add_field_visit_image_path, direction='center', inset=10, confidence=0.70):
            logging.info("Clicked successfully add_field_visit_image_path.")
            time.sleep(2)
            if click_image_single(permits_workassigneddate, direction='right', offset=5, inset=5, confidence=0.70):
                logging.info("Clicked successfully add_field_visit_image_path.")
                time.sleep(2)
                pyautogui.press('tab')
                logging.info("Press Tab")
                time.sleep(0.25)
                ensure_capslock_off()
                pyautogui.typewrite('p')
                time.sleep(0.25)
                pyautogui.press('tab')
                time.sleep(0.25)
                logging.info("Press Tab")
                pyautogui.press('space')
                time.sleep(0.25)
                logging.info("Press Space")
                pyautogui.press('right')
                time.sleep(0.25)
                logging.info("Press Right Arrow")
                ensure_capslock_off()
                pyautogui.typewrite(f"12/31/{due_year}")
                time.sleep(0.25)
                press_key_multiple_times('tab', 3)
                logging.info("Press tab*3")
                time.sleep(0.25)
                pyautogui.press('space')
                time.sleep(0.25)
                logging.info("Press Space Bar")


    def ProVal_Save(self):
        set_focus("ProVal")
        time.sleep(0.25)
        logging.info("set_focus(ProVal)")
        pyautogui.hotkey('ctrl', 's')
        logging.info("Save.")
        time.sleep(0.25)


# Example usage of the FieldVisitUpdater class
if __name__ == "__main__":

    db_connection_string = (
        "Driver={SQL Server};"
        "Server=astxdbprod;"
        "Database=GRM_Main;"
        "Trusted_Connection=yes;"
    )
    
    query = """
    WITH CTE_CountPermitsActive AS (
        SELECT DISTINCT parcel.lrsn, COUNT(p.permit_ref) AS PermitCount
        FROM KCv_PARCELMASTER1 AS parcel
        JOIN permits AS p ON parcel.lrsn = p.lrsn AND p.status = 'A'
        WHERE parcel.EffStatus = 'A'
        GROUP BY parcel.lrsn
    )
    SELECT DISTINCT
        TRIM(p.permit_ref) AS REFERENCE#,
        TRIM(p.permit_desc) AS DESCRIPTION,
        TRIM(parcel.ain) AS AIN,
        TRIM(parcel.pin) AS PIN,
        TRIM(parcel.SitusAddress) AS SitusAddress,
        TRIM(parcel.SitusCity) AS SitusCity,
        parcel.lrsn,
        counts.PermitCount
    FROM KCv_PARCELMASTER1 AS parcel
    JOIN permits AS p ON parcel.lrsn = p.lrsn AND p.status = 'A'
    LEFT JOIN field_visit AS f ON p.field_number = f.field_number AND f.status = 'A'
    LEFT JOIN codes_table AS c ON c.tbl_element = p.permit_type AND c.tbl_type_code = 'permits' AND c.code_status = 'A'
    LEFT JOIN CTE_CountPermitsActive AS counts ON counts.lrsn = parcel.lrsn
    WHERE parcel.EffStatus = 'A' AND f.field_out IS NULL AND p.permit_type <> '9'
    ORDER BY PermitCount ASC, PIN;
    """


    # Define the log file path
    user_home_dir = os.environ.get('USERPROFILE') or os.environ.get('HOME')
    log_filename = os.path.join(str(user_home_dir), 'Documents', 'FieldVisitUpdaterLog', 'FieldVisitUpdater.log')


    # Create an instance of FieldVisitUpdater
    updater = FieldVisitUpdater(db_connection_string, query)
    
    # Fetch data from the database
    updater.fetch_data()

    # Process the parcels fetched from the database
    updater.process_parcels()

