
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
pytesseract.pytesseract.tesseract_cmd = r'C:\Users\rmason\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'


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

#### Image Paths - Single Images Only
duplicate_memo_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memo_duplicate.PNG'
add_field_visit_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_fieldvisit_button.PNG'
aggregate_land_type_add_button = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_aggregate_land_type_add_button.PNG'
farm_total_acres_image = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_farm_total_acres.PNG'
permit_description = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permit_description.PNG'


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
logging.info("SQL_Query")

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
    logging.info("set_focus_and_type")
    #Maximize Window
    # Simulate the Windows + Up Arrow key combination to maximize the window
    pyautogui.hotkey('win', 'up')

    """
    Officially begins the automation and screen navigation
    """


    # Process: Open an AIN in ProVal
    set_focus_and_type('ProVal', DBAIN)
    time.sleep(1)
    logging.info("set_focus_and_type")

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


    set_focus_and_type('ProVal', DBAIN)
    time.sleep(1)
    logging.info("set_focus_and_type")
    
    #Maximize Window
    # Simulate the Windows + Up Arrow key combination to maximize the window
    pyautogui.hotkey('win', 'up')

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break






    """
    ## NOW BEGIN AUTOMATION STEPS FOR THIS TOOL
    """

    
    # Process: Open Memos
    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(1)



    # Process: Enter Land Memos
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



    # Process: Enter Land Farm Acres

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
        if click_image_single(aggregate_land_type_add_button, direction='bottom_right_corner', inset=10, confidence=0.8):
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





    # Process: Enter Permit 1/2

    # Click Permits_Tab
    if click_images_multiple(permits_tab_images, direction='center', inset=10, confidence=0.8):
        logging.info("Clicked successfully permits_tab_images.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    
    # Click Permits_Add_Button
    if click_images_multiple(permits_add_permit_button, direction='center', offset=100, confidence=0.8):
        logging.info("Clicked successfully permits_add_permit_button.")
        time.sleep(1)

        ensure_capslock_off()

        # Send Permit Number
        pyautogui.typewrite(PNUMBER)
        time.sleep(1)

        pyautogui.press(['tab'])
        time.sleep(1)
        
        #Different down to Timber 2 vs Mandatory 11.
        press_key_multiple_times('down', 11)
        time.sleep(1)

        press_key_multiple_times(['tab'], 3)
        time.sleep(1)

        ensure_capslock_off()

        # Send Permit Filing Date
        pyautogui.typewrite(PFILE)
        time.sleep(1)

        press_key_multiple_times(['tab'], 3)
        time.sleep(1)

        # Close Add Permit Pop-Up Box
        pyautogui.press('space')
        logging.info("Closing Add Permit pop-up, then waiting to send description")
        time.sleep(3)
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break
    
    # Click to right of permit_description
    if click_image_single(permit_description, direction='below', offset=5, confidence=0.8):
        logging.info("Clicked successfully permit_description.")
    time.sleep(1)

    ensure_capslock_off()

    # Send Permit Description
    pyautogui.typewrite(PDESC)
    time.sleep(1)
    logging.info("Send description")
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        break


    # Process: Enter Permit 2/2
    # Click FieldVisit_Add_Button
    if click_image_single(add_field_visit_image_path, direction='center', inset=10, confidence=0.8):
        logging.info("Clicked successfully add_field_visit_image_path.")

        # If found, complete adding Field Visit process
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



    # Process: CHECK FOR TIMBER
    # Timber Review Logic
    if TREVIEW in ["Yes", "YES", "Y", "y"]:
        logging.info("Timber YES.")
        """
        # Send Appraiser Permit for TIMBER

        """
        # Same as permit process except for two changes. Different down to Timber vs Mandatory. Add to Permit Description.
        # Process: Enter Permit 1/2

        # Click Permits_Tab
        if click_images_multiple(permits_tab_images, direction='center', inset=10, confidence=0.8):
            logging.info("Clicked successfully permits_tab_images.")
        time.sleep(1)
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
        
        # Click Permits_Add_Button
        if click_images_multiple(permits_add_permit_button, direction='center', offset=100, confidence=0.8):
            logging.info("Clicked successfully permits_add_permit_button.")
            time.sleep(1)

            ensure_capslock_off()

            # Send Permit Number
            pyautogui.typewrite(PNUMBER)
            time.sleep(1)

            pyautogui.press(['tab'])
            time.sleep(1)
            
            #Different down to Timber 2 vs Mandatory 11.
            press_key_multiple_times('down', 2)
            time.sleep(1)

            press_key_multiple_times(['tab'], 3)
            time.sleep(1)

            ensure_capslock_off()

            # Send Permit Filing Date
            pyautogui.typewrite(PFILE)
            time.sleep(1)

            press_key_multiple_times(['tab'], 3)
            time.sleep(1)

            # Close Add Permit Pop-Up Box
            pyautogui.press('space')
            logging.info("Closing Add Permit pop-up, then waiting to send description")
            time.sleep(3)
        time.sleep(1)
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
        
        # Click to right of permit_description
        if click_image_single(permit_description, direction='below', offset=5, confidence=0.8):
            logging.info("Clicked successfully permit_description.")
        time.sleep(1)

        ensure_capslock_off()

        # Send Permit Description -- Add to Permit Description.
        pyautogui.typewrite(f"{PDESC} FOR TIMBER REVIEW")
        time.sleep(1)
        logging.info("Send description")
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break

        # Process: Enter Permit 2/2
        # Click FieldVisit_Add_Button
        if click_image_single(add_field_visit_image_path, direction='center', inset=10, confidence=0.8):
            logging.info("Clicked successfully add_field_visit_image_path.")

            # If found, complete adding Field Visit process
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
#08/20/2024, entirely new v3, streamlined, simplified, built in re-usable blocks for future templates
    # After much review and many ChatGPT conversations and many tests... v3 is ready to be used as a template for other automations
    # Next ... 
    # Write documenation and instruction manual
    # Save Template Version
    # Write a Plat version
    
"""