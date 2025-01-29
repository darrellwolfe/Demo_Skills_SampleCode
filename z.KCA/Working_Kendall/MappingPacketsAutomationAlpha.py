import os
import sys
import cv2
import time
import pyodbc
import ctypes
import logging
import keyboard
import threading
import pyautogui
import webbrowser
import pytesseract
import numpy as np
import tkinter as tk
from PIL import Image
from pathlib import Path
import pygetwindow as gw
from datetime import datetime
from tkinter import ttk, messagebox

def setup_logging():
    home_dir = os.path.expanduser("~")
    log_dir = os.path.join(home_dir, "MappingPackets")
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
    log_file = os.path.join(log_dir, "MappingPackets.log")

    logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
    )

    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    console.setFormatter(formatter)
    logging.getLogger().addHandler(console)

class KillScriptException(Exception):
    pass

def monitor_kill_key():
    logging.info("Kill key monitor started. Press 'esc' to stop the script.")
    keyboard.wait('esc')
    logging.info("Kill key pressed. Stopping the script...")
    raise KillScriptException("Script terminated by user")

kill_key_thread = threading.Thread(target=monitor_kill_key)
kill_key_thread.daemon = True
kill_key_thread.start()

db_connection_string = (
    "Driver={SQL Server};"
    "Server=astxdbprod;"
    "Database=GRM_Main;"
    "Trusted_Connection=yes;"
)

def connect_to_database(connection_string):
    return pyodbc.connect(connection_string)

def execute_query(cursor, query):
    cursor.execute(query)
    return cursor.fetchall()

MemoTXT = ""
PDESC = ""

def on_submit():
    ensure_capslock_off()
    global AINLIST, AINFROM, AINTO, PDESC, PFILE, PNUMBER, TREVIEW, MappingPacketType, Initials, MemoTXT, ForYear
    AINFROM = [ain.strip() for ain in entry_ainfrom.get().strip().upper().split(",")]
    AINTO = [ain.strip() for ain in entry_ainto.get().strip().upper().split(",")]
    combined_ain_list = list(set(AINFROM + AINTO))
    AINLIST = combined_ain_list
    PFILE = entry_pfile.get().strip().upper()
    PNUMBER = entry_pnumber.get().strip().upper()
    TREVIEW = entry_treview.get().strip().upper()
    MappingPacketType = combobox_mappingpackettype.get().strip().upper()
    Initials = entry_initials.get().strip().upper()
    ForYear = for_year_combobox.get().strip()
    if ForYear == "Select year":
        messagebox.showerror("Input Error", "Please select a year.")
        return
    the_month = datetime.now().month
    the_year = datetime.now().year
    AINFROM_str = ', '.join(AINFROM)
    AINTO_str = ', '.join(AINTO)
    MemoTXT = f"{Initials}-{the_month}/{str(the_year)[-2:]} {MappingPacketType} from {AINFROM_str} into {AINTO_str} for {ForYear}"
    logging.info(f"Generated MemoTXT: {MemoTXT}")
    PDESC = f"{MappingPacketType} for {ForYear}"
    if not AINLIST or not PFILE or not PNUMBER or not TREVIEW or not MappingPacketType or not Initials or not MemoTXT or not PDESC:
        messagebox.showerror("Input Error", "All input fields are required.")
        return
    root.destroy()

def setup_gui():
    root = tk.Tk()
    root.title("User Input Form")
    setup_widgets(root)
    return root

def validate_initials(action, value_if_allowed):
    if action == '1':
        value_if_allowed = value_if_allowed.upper()
        if len(value_if_allowed) > 3:
            return False
        return value_if_allowed.isalpha()
    return True

def validate_yn(action, value_if_allowed):
    if action == '1':
        if value_if_allowed == '':
            return True
        value_if_allowed = value_if_allowed.upper()
        if len(value_if_allowed) > 1:
            return False
        return value_if_allowed in ['Y', 'N']
    return True

def setup_widgets(root):
    global entry_ainfrom, entry_ainto, entry_pfile, entry_pnumber, entry_treview, combobox_mappingpackettype, entry_initials, for_year_combobox
    current_year = datetime.now().year
    next_year = current_year + 1
    ttk.Label(root, text="List AINs FROM (separated by comma):").grid(column=0, row=0, padx=10, pady=5)
    entry_ainfrom = ttk.Entry(root, width=50)
    entry_ainfrom.grid(column=1, row=0, padx=10, pady=5)
    ttk.Label(root, text="List AINs TO (separated by comma):").grid(column=0, row=1, padx=10, pady=5)
    entry_ainto = ttk.Entry(root, width=50)
    entry_ainto.grid(column=1, row=1, padx=10, pady=5)
    ttk.Label(root, text="Mapping packet FOR what year?:").grid(column=0, row=2, padx=10, pady=5)
    for_year_combobox = ttk.Combobox(root, values=["Select year", str(current_year), str(next_year)], width=47)
    for_year_combobox.grid(column=1, row=2, padx=10, pady=5)
    for_year_combobox.set("Select year")
    ttk.Label(root, text="Filing Date (Top Date):").grid(column=0, row=3, padx=10, pady=5)
    entry_pfile = ttk.Entry(root, width=50)
    entry_pfile.grid(column=1, row=3, padx=10, pady=5)
    ttk.Label(root, text="Permit Number (Bottom Date):").grid(column=0, row=4, padx=10, pady=5)
    entry_pnumber = ttk.Entry(root, width=50)
    entry_pnumber.grid(column=1, row=4, padx=10, pady=5)
    ttk.Label(root, text="Timber or AG review? Y/N:").grid(column=0, row=5, padx=10, pady=5)
    vcmd_yn = (root.register(validate_yn), '%d', '%P')
    entry_treview = ttk.Entry(root, width=50, validate='key', validatecommand=vcmd_yn)
    entry_treview.grid(column=1, row=5, padx=10, pady=5)
    ttk.Label(root, text="Select Mapping Packet Type:").grid(column=0, row=6, padx=10, pady=5)
    mapping_packet_types = [
        "MERGE", "SPLIT", "BLA", "LLA", "RW VACATION", "RW SPLIT", "REDESCRIBE",
        "RW AUDIT", "RW Cat19", "AIRPORT LEASE NEW PARCEL", "PLAT VACATION",
        "PARCEL DELETED", "ACERAGE AUDIT", "NEW PLAT"
    ]
    combobox_mappingpackettype = ttk.Combobox(root, values=mapping_packet_types, width=47)
    combobox_mappingpackettype.grid(column=1, row=6, padx=10, pady=5)
    combobox_mappingpackettype.current(0)
    vcmd = (root.register(validate_initials), '%d', '%P')
    ttk.Label(root, text="Enter Your Initials:").grid(column=0, row=7, padx=10, pady=5)
    entry_initials = ttk.Entry(root, width=50, validate='key', validatecommand=vcmd)
    entry_initials.grid(column=1, row=7, padx=10, pady=5)
    submit_button = ttk.Button(root, text="Submit", command=on_submit)
    submit_button.grid(column=0, row=8, columnspan=2, pady=20)

root = setup_gui()

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

def set_focus_and_type(window_title, keys):
    window = gw.getWindowsWithTitle(window_title)
    if window:
        window[0].activate()
        pyautogui.typewrite(keys)

def press_key_with_modifier_multiple_times(modifier, key, times):
    for _ in range(times):
        try:
            pyautogui.hotkey(modifier, key)
        except KillScriptException:
            logging.info("Script stopping due to kill key press.")
            raise

def press_key_multiple_times(key, times):
    for _ in range(times):
        try:
            pyautogui.press(key)
        except KillScriptException:
            logging.info("Script stopping due to kill key press.")
            raise

def get_tesseract_path():
    home_dir = str(Path.home())
    if sys.platform.startswith('win'):
        tesseract_path = os.path.join(home_dir, 'AppData', 'Local', 'Programs', 'Tesseract-OCR', 'tesseract.exe')
    elif sys.platform.startswith('darwin'):
        tesseract_path = '/usr/local/bin/tesseract'
    else:
        tesseract_path = '/usr/bin/tesseract'
    return tesseract_path

def download_and_install_tesseract():
    print("Tesseract not found. Please install it manually.")
    print("Opening the Tesseract download page in your default web browser...")
    webbrowser.open("https://github.com/UB-Mannheim/tesseract/wiki")
    print("\nPlease follow these steps:")
    print("1. Download the appropriate Tesseract installer for your system.")
    print("2. Run the installer and follow the installation instructions.")
    print("3. Make sure to note the installation path.")
    print("4. After installation, restart this script.")
    input("Press Enter when you have completed the installation...")

if not os.path.exists(get_tesseract_path()):
    download_and_install_tesseract()

pytesseract.pytesseract.tesseract_cmd = get_tesseract_path()

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

duplicate_memo_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memo_duplicate.PNG'
add_field_visit_image_path = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permits_add_fieldvisit_button.PNG'
aggregate_land_type_add_button = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_aggregate_land_type_add_button.PNG'
farm_total_acres_image = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_farm_total_acres.PNG'
permit_description = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_permit_description.PNG'

def capture_and_convert_screenshot():
    screenshot = pyautogui.screenshot()
    screenshot_np = np.array(screenshot)
    screenshot_np = cv2.cvtColor(screenshot_np, cv2.COLOR_RGB2BGR)
    grey_screenshot = cv2.cvtColor(screenshot_np, cv2.COLOR_BGR2GRAY)
    return grey_screenshot

def click_on_image(image_path, direction='center', offset=10, inset=7, confidence=0.8):
    grey_screenshot = capture_and_convert_screenshot()
    ref_image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if ref_image is None:
        logging.error(f"Failed to load reference image from {image_path}")
        return False
    result = cv2.matchTemplate(grey_screenshot, ref_image, cv2.TM_CCOEFF_NORMED)
    _, max_val, _, max_loc = cv2.minMaxLoc(result)
    if max_val >= confidence:
        top_left = max_loc
        h, w = ref_image.shape
        right = top_left[0] + w
        bottom = top_left[1] + h

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

        pyautogui.click(click_x, click_y)
        logging.info(f"Clicked {direction} of the image at ({click_x}, {click_y})")
        return True
    else:
        logging.warning(f"No good match found at the confidence level of {confidence}.")
        return False

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

def is_image_found(image_path, confidence=0.8):
    grey_screenshot = capture_and_convert_screenshot()
    ref_image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if ref_image is None:
        logging.error(f"Failed to load reference image from {image_path}")
        return False
    result = cv2.matchTemplate(grey_screenshot, ref_image, cv2.TM_CCOEFF_NORMED)
    _, max_val, _, _ = cv2.minMaxLoc(result)
    found = max_val >= confidence
    if found:
        logging.info(f"Image found with confidence {max_val}: {image_path}")
    else:
        logging.info(f"Image not found with sufficient confidence {confidence}: {image_path}")
    return found

def check_for_text_on_screen(target_text):
    grey_screenshot = capture_and_convert_screenshot()
    grey_screenshot_pil = Image.fromarray(grey_screenshot)
    screen_text = pytesseract.image_to_string(grey_screenshot_pil)
    return target_text in screen_text

root.mainloop()

if not AINLIST or not MemoTXT or not PDESC or not PFILE or not PNUMBER or not TREVIEW:
    logging.error("All input fields are required.")
    exit()

conn = connect_to_database(db_connection_string)
cursor = conn.cursor()
query = f"SELECT TRIM(pm.AIN), pm.LegalAcres FROM TSBv_Parcelmaster AS pm WHERE pm.AIN IN ({','.join(AINLIST)})"
rows = execute_query(cursor, query)
logging.info("SQL_Query")

for row in rows:
    DBAIN, DBACRE = row
    ensure_capslock_off()
    
    set_focus_and_type('ProVal', DBAIN)
    time.sleep(1)
    logging.info("set_focus_and_type")
    pyautogui.hotkey('win', 'up')
    set_focus_and_type('ProVal', DBAIN)
    time.sleep(1)
    logging.info("set_focus_and_type")
    pyautogui.hotkey('ctrl', 'o')
    time.sleep(1)
    logging.info("hotkey")
    press_key_multiple_times('up', 10)
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
    logging.info("Close Pop-Up, Open the {DBAIN}")
    set_focus_and_type('ProVal', DBAIN)
    time.sleep(1)
    logging.info("set_focus_and_type")
    pyautogui.hotkey('win', 'up')
    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(3)
    
    specific_text = "LAND"
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

    if click_images_multiple(land_tab_images, direction='center', offset=100, confidence=0.8):
        logging.info("Clicked successfully land_tab_images.")
        time.sleep(1)      
    if click_images_multiple(land_base_tab_images, direction='center', confidence=0.8):
        logging.info("Clicked successfully land_base_tab_images.")
        time.sleep(1)      
    if is_image_found(farm_total_acres_image, confidence=0.8):
        logging.info("Image was found - executing related tasks.")
        if click_image_single(farm_total_acres_image, direction='right', offset=15, confidence=0.8):
            logging.info("Clicked successfully farm_total_acres_image.")
        time.sleep(1)
        pyautogui.press('delete')
        time.sleep(1)
        ensure_capslock_off()
        pyautogui.typewrite(str(DBACRE))
        time.sleep(1)
        pyautogui.press('tab')
        time.sleep(1)
    else:
        logging.info("farm_total_acres_image Image was not found - executing alternative tasks.")
        if click_image_single(aggregate_land_type_add_button, direction='bottom_right_corner', inset=10, confidence=0.8):
            logging.info("Clicked successfully aggregate_land_type_add_button.")
        time.sleep(1)
        pyautogui.typewrite('f')
        time.sleep(1)
        pyautogui.press('tab')
        time.sleep(1)
        ensure_capslock_off()
        pyautogui.typewrite(str(DBACRE))
        time.sleep(1)
        pyautogui.press('tab')
        time.sleep(1)

    if click_images_multiple(permits_tab_images, direction='center', inset=10, confidence=0.8):
        logging.info("Clicked successfully permits_tab_images.")
    time.sleep(1)
        
    if click_images_multiple(permits_add_permit_button, direction='center', offset=100, confidence=0.8):
        logging.info("Clicked successfully permits_add_permit_button.")
        time.sleep(1)
        ensure_capslock_off()
        pyautogui.typewrite(PNUMBER)
        time.sleep(1)
        pyautogui.press(['tab'])
        time.sleep(1)
        press_key_multiple_times('down', 11)
        time.sleep(1)
        press_key_multiple_times(['tab'], 3)
        time.sleep(1)
        ensure_capslock_off()
        pyautogui.typewrite(PFILE)
        time.sleep(1)
        press_key_multiple_times(['tab'], 3)
        time.sleep(1)
        pyautogui.press('space')
        logging.info("Closing Add Permit pop-up, then waiting to send description")
        time.sleep(3)
    time.sleep(1)
        
    if click_image_single(permit_description, direction='below', offset=5, confidence=0.8):
        logging.info("Clicked successfully permit_description.")
    time.sleep(1)
    ensure_capslock_off()
    pyautogui.typewrite(PDESC)
    time.sleep(1)
    logging.info("Send description")

    if click_image_single(add_field_visit_image_path, direction='center', inset=10, confidence=0.8):
        logging.info("Clicked successfully add_field_visit_image_path.")
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
        pyautogui.typewrite(f"04/01/{ForYear}")
        time.sleep(1)

    if TREVIEW in ["Yes", "YES", "Y", "y"]:
        logging.info("Timber YES.")
        if click_images_multiple(permits_tab_images, direction='center', inset=10, confidence=0.8):
            logging.info("Clicked successfully permits_tab_images.")
        time.sleep(1)
            
        if click_images_multiple(permits_add_permit_button, direction='center', offset=100, confidence=0.8):
            logging.info("Clicked successfully permits_add_permit_button.")
            time.sleep(1)
            ensure_capslock_off()
            pyautogui.typewrite(PNUMBER)
            time.sleep(1)
            pyautogui.press(['tab'])
            time.sleep(1)
            press_key_multiple_times('down', 2)
            time.sleep(1)
            press_key_multiple_times(['tab'], 3)
            time.sleep(1)
            ensure_capslock_off()
            pyautogui.typewrite(PFILE)
            time.sleep(1)
            press_key_multiple_times(['tab'], 3)
            time.sleep(1)
            pyautogui.press('space')
            logging.info("Closing Add Permit pop-up, then waiting to send description")
            time.sleep(3)
        time.sleep(1)
            
        if click_image_single(permit_description, direction='below', offset=5, confidence=0.8):
            logging.info("Clicked successfully permit_description.")
        time.sleep(1)
        ensure_capslock_off()
        pyautogui.typewrite(f"{PDESC} FOR TIMBER REVIEW")
        time.sleep(1)
        logging.info("Send description")
            
        if click_image_single(add_field_visit_image_path, direction='center', inset=10, confidence=0.8):
            logging.info("Clicked successfully add_field_visit_image_path.")
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
            pyautogui.typewrite(f"04/01/{ForYear}")
            time.sleep(1)
    else:
        logging.info("Timber review not required, skipping this step.")
        time.sleep(1)

    pyautogui.hotkey('ctrl', 's')
    logging.info("Save.")
    time.sleep(1)
    logging.info("Script completed successfully!")
    time.sleep(1)

cursor.close()
logging.info("Cursor Closed")
conn.close()
logging.info("Database Connection Closed")