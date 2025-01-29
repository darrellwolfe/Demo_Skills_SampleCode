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
import sys

#CAPS LOCK
def is_capslock_on():
    hllDll = ctypes.WinDLL("User32.dll")
    VK_CAPITAL = 0x14
    return hllDll.GetKeyState(VK_CAPITAL) & 1

def ensure_capslock_off():
    if is_capslock_on():
        pyautogui.press('capslock')
        logging.info("CAPS LOCK was on. It has been turned off.")
    else:
        logging.info("CAPS LOCK is already off.")

mylog_filename = 'C:/Users/kmallery/Documents/Kootenai_County_Assessor_CodeBase/Working_Kendall/Logs_Kendall/OccPost.log'

logging.basicConfig(
    filename = mylog_filename,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

#AIN LOG PROCESSOR
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

if __name__ == "__main__":
    log_processor = AINLogProcessor(mylog_filename)

# KILL SCRIPT
stop_script = False

def monitor_kill_key():
    global stop_script
    logging.info("Kill key monitor started. Press 'esc' to stop the script.")
    keyboard.wait('esc')  # Set 'esc' as the kill key
    stop_script = True
    logging.info("Kill key pressed. Stopping the script...")

kill_key_thread = threading.Thread(target=monitor_kill_key)
kill_key_thread.daemon = True
kill_key_thread.start()

def check_for_kill():
    if stop_script:
        logging.info("Script terminated due to kill key.")
        sys.exit("Script terminated")

#GRAPHIC USER INTERFACE
MemoTXT = ""

def on_submit():
    ensure_capslock_off()

    global AIN, PDATE, PostingType, MemoTXT, AIN_str

    AIN = [ain.strip() for ain in entry_ain.get().strip().upper().split(",")]
    AIN_str = ', '.join(AIN)

    PDATE = entry_postdate.get().strip().upper()
    PostingType = combobox_postingtype.get().strip().upper()

    MemoTXT = f"POSTED - {PostingType} {PDATE}"
    logging.info(f"Generated MemoTXT: {MemoTXT}")

    if  not PDATE or not PostingType or not MemoTXT:
        messagebox.showerror("Input Error", "All input fields are required.")
        return

    root.destroy()

def setup_gui():
    root = tk.Tk()
    root.title("User Input Form")
    setup_widgets(root)
    return root

def setup_widgets(root):
    global entry_ain, entry_postdate, combobox_postingtype
    current_year = datetime.now().year

    ttk.Label(root, text="AIN to post").grid(column=0, row=0, padx=10, pady=5)
    entry_ain = ttk.Entry(root, width=50)
    entry_ain.grid(column=1, row=0, padx=10, pady=5)

    ttk.Label(root, text="Posting Date:").grid(column=0, row=3, padx=10, pady=5)
    entry_postdate = ttk.Entry(root, width=50)
    entry_postdate.grid(column=1, row=3, padx=10, pady=5)
    posting_types = [
        "HOEX", "FV", "CO", "BF", "OWNER", "TRANSFER"
    ]
    combobox_postingtype = ttk.Combobox(root, values=posting_types, width=47)
    combobox_postingtype.grid(column=1, row=6, padx=10, pady=5)
    combobox_postingtype.current(0)  # Set default selection to the first item

    submit_button = ttk.Button(root, text="Submit", command=on_submit)
    submit_button.grid(column=0, row=8, columnspan=2, pady=20)

root = setup_gui()

#SET FOCUS
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

#PRESS & CLICK KEY LOGIC
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

#OCR / IMAGE RECOGNITION
    ##Link https://github.com/tesseract-ocr/tesseract
    ##Link https://github.com/UB-Mannheim/tesseract/wiki
pytesseract.pytesseract.tesseract_cmd = r'C:\Users\kmallery\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'

##IMAGE PATHS => Images w/ Multiple Variations
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

##IMAGE PATHS => Images w/ Single Variation
duplicate_memo_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memo_duplicate.PNG'
add_field_visit_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_fieldvisit_button.PNG'
aggregate_land_type_add_button = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_aggregate_land_type_add_button.PNG'
farm_total_acres_image = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_farm_total_acres.PNG'
permit_description = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permit_description.PNG'
memos_land_information_ = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memos_land_information_.PNG'
pricing_selectall =r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_pricing_selectall.png'
NC24Memo =r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memo_NC24.png'
history =r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_values_history.png'
summary =r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_values_summary.png'
parcel =r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_parcel_tab.png'

#PROCESSING OCR IMAGES: STEP 1 - CAPTURE SCREEN IN GREYSCALE
def capture_and_convert_screenshot():
    screenshot = pyautogui.screenshot()
    screenshot_np = np.array(screenshot)
    screenshot_np = cv2.cvtColor(screenshot_np, cv2.COLOR_RGB2BGR)
    grey_screenshot = cv2.cvtColor(screenshot_np, cv2.COLOR_BGR2GRAY)
    return grey_screenshot

#PROCESSING OCR IMAGES: STEP 2 - CLICK USING A REFERENCE GREYSCALE SCREENSHOT TO A STORED GREYSCALE IMAGE INCLUDES ABILITY TO CLICK RELATIVE POSITION
def click_on_image(image_path, direction='center', offset=10, inset=7, confidence=0.75):
    grey_screenshot = capture_and_convert_screenshot()
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

#PROCESSING OCR IMAGES: STEP 3 - USING click_on_image FUNCTION
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

# 4 CHECKING IF IMAGE IS PRESENT
def is_image_found(image_path, confidence=0.75):
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
#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#

# Start the GUI event loop
root.mainloop()
if not PDATE or not PostingType or not MemoTXT:
    messagebox.showerror("Input Error", "All input fields are required.")

logging.info(f"Variables Created:")
logging.info(f"AIN: {AIN}")
logging.info(f"AIN: {AIN_str}")
logging.info(f"PostingType: {PostingType}")
logging.info(f"MemoTXT: {MemoTXT}")
logging.info(f"PDATE: {PDATE}")

set_focus("ProVal")
time.sleep(1)
logging.info("set_focus(ProVal)")
pyautogui.hotkey('win', 'up')

check_for_kill()

# Process: Open an AIN in ProVal
set_focus("ProVal")
time.sleep(1)

logging.info("set_focus(ProVal)")
pyautogui.hotkey('ctrl', 'o')
time.sleep(1)

check_for_kill()

logging.info("hotkey")
press_key_multiple_times('up', 12)
logging.info("press_key_multiple_times")
press_key_multiple_times('down', 4)
logging.info("press_key_multiple_times")
pyautogui.press(['tab'])
logging.info("press")
pyautogui.press(['delete'])
logging.info("press")
ensure_capslock_off()
time.sleep(1)

check_for_kill()

pyautogui.typewrite(str(AIN_str))
logging.info(f"Sent AIN {AIN_str}.")
time.sleep(1)

pyautogui.press('enter')
time.sleep(1)

logging.info(f"Close Pop-Up, Open the {AIN_str}")
set_focus("ProVal")
time.sleep(1)
logging.info("set_focus(ProVal)")
pyautogui.hotkey('win', 'up')
time.sleep(2)
check_for_kill()

#Prompt User: Future Property Records
root = tk.Tk()
root.withdraw()
result = messagebox.askquestion("Question", "Promote Future Property Records?")
if result == 'yes':
    logging.info("User clicked Yes")
    time.sleep(1)
    set_focus("ProVal")
    time.sleep(1) 
    pyautogui.hotkey('alt','p','f')
    time.sleep(1)
    pyautogui.hotkey('p')
    time.sleep(1) 
    pyautogui.press('enter')
    time.sleep(1)
else:
    time.sleep(1)

check_for_kill()

#Prompt User: Future Land Records
root = tk.Tk()
root.withdraw()
result = messagebox.askquestion("Question", "Promote Future Land Records?")
if result == 'yes':
    logging.info("User clicked Yes")
    time.sleep(1)
    set_focus("ProVal")
    time.sleep(1) 
    pyautogui.hotkey('alt','p','f')
    time.sleep(1)
    pyautogui.hotkey('o')
    time.sleep(1) 
    pyautogui.press('enter')
    time.sleep(1)
else:
    time.sleep(1)

check_for_kill()

#Open Allocations
set_focus("ProVal")
time.sleep(1) 
pyautogui.hotkey('F9')
time.sleep(1)
logging.info("Allocations opened.")
check_for_kill()

#Prompt User: Check Allocations
root = tk.Tk()
root.withdraw()
result = messagebox.askquestion("Question", "Allocations Good?")
if result == 'yes':
    logging.info("User clicked Yes")
    time.sleep(1) 
    set_focus("Cost Allocations")
    time.sleep(1)  
    pyautogui.hotkey('alt','n')
    time.sleep(2)
else:
    check_for_kill()
    logging.info("User pressed no. Script stopped.")
check_for_kill()

#Process: Key Info
pyautogui.hotkey('ctrl','k')
time.sleep(1)
logging.info("Key Information opened.")
check_for_kill()

#Prompt User: Check Key Information
root = tk.Tk()
root.withdraw()
result = messagebox.askquestion("Question", "Key Information good?")
if result == 'yes':
    logging.info("User clicked Yes")
    set_focus("Key Information")
    time.sleep(1)
    pyautogui.press('enter')
    pyautogui.press('esc')
    time.sleep(1)
    check_for_kill()
else:
    check_for_kill()
    logging.info("User pressed no. Script stopped.")
check_for_kill()

#Process: Price Parcel
pyautogui.hotkey('alt','v','c')
time.sleep(1)
logging.info("Opened pricing window.")
time.sleep(1)
check_for_kill()

#Process: Find and Click Select All & OK
if click_image_single(pricing_selectall, direction='center', confidence=0.75):
    time.sleep(1)
    press_key_multiple_times('left', 2)
    time.sleep(1)
    pyautogui.press('enter')
    time.sleep(1)
    logging.info("Pricing...")
    time.sleep(3)
    check_for_kill()
else:
    check_for_kill()
    logging.info("Unable to locate. Script stopped.")
check_for_kill()

#Process: Find and Click the Values Summary sub-tab
if click_image_single(summary, direction='center', confidence=0.75):
    time.sleep(4)
    check_for_kill()
else:
    check_for_kill()
    logging.info("Unable to locate. Script stopped.")
check_for_kill()

#Prompt User: Check value
root = tk.Tk()
root.withdraw()
result = messagebox.askquestion("Question", "Summary value good?")
if result == 'yes':
    logging.info("User clicked Yes")
    time.sleep(1)
    set_focus("ProVal")
    time.sleep(1)
    check_for_kill()
else:
    check_for_kill()
    logging.info("User pressed no. Script stopped.")
check_for_kill()

#Process: Open Memos
pyautogui.hotkey('ctrl', 'shift', 'm')
time.sleep(1)
check_for_kill()

#Process: Find and Click NC24 Memo
if click_image_single(NC24Memo, direction='center', confidence=0.75):
    time.sleep(1)
    pyautogui.press('enter')
    time.sleep(1)
    pyautogui.hotkey('ctrl', 'a')
    time.sleep(1)
    pyautogui.typewrite(MemoTXT)
    time.sleep(1)
    pyautogui.press('tab')
    time.sleep(1)
    pyautogui.press('enter')
    root = tk.Tk()
    root.withdraw()
    result = messagebox.askquestion("Question", "Memo entered correctly?")
    if result == 'yes':
        logging.info("User clicked Yes")
        check_for_kill()
    else:
        check_for_kill()
        logging.info("User pressed no. Script stopped.")
    check_for_kill()
else:
    check_for_kill()
    logging.info("Unable to locate. Script stopped.")
check_for_kill()

#Process: Save Account
time.sleep(1)
set_focus("ProVal")
time.sleep(1)
pyautogui.hotkey('ctrl', 's')
logging.info("Save.")
time.sleep(1)
check_for_kill()

#Process: Post Parcel
pyautogui.hotkey('alt', 'v', 'p')
logging.info("Posting...")
time.sleep(1)
pyautogui.typewrite("2024")
time.sleep(1)
pyautogui.press('tab')
pyautogui.typewrite(PDATE)
time.sleep(1)
pyautogui.press('tab')
pyautogui.typewrite("0")
time.sleep(1)
pyautogui.press('tab')
pyautogui.press('enter')
logging.info("Posting now.")
time.sleep(1)
pyautogui.press('enter')
time.sleep(1)
check_for_kill()

if click_image_single(parcel, direction='center', confidence=0.75):
    time.sleep(2)
    check_for_kill()
else:
    check_for_kill()
    logging.info("Unable to locate. Script stopped.")
check_for_kill()

# End of Script
logging.info("THE END...")
time.sleep(1)
log_processor.process_log()
log_processor.print_unique_ains()
logging.info("AIN logged")