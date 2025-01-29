import re
import sys
import cv2
import time
import ctypes
# import pyodbc (Probably unused)
import logging
import keyboard
import threading
import pyautogui
import pytesseract
import numpy as np
import tkinter as tk
# from PIL import Image (Probably unused)
from datetime import datetime
# from tkcalendar import DateEntry (Probably unused)
from tkinter import ttk, messagebox

# Configuration
LOG_FILENAME = 'C:/Users/kmallery/Documents/Kootenai_County_Assessor_CodeBase/Working_Kendall/Logs_Kendall/OccPost.log'
TESSERACT_PATH = r'C:\Users\%USERNAME%\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'
IMAGE_PATH = r'S:\Common\Comptroller Tech\Reports\Python\py_images'

# Global variables
stop_script = False
AIN = []
PDATE = ""
PostingType = ""
MemoTXT = ""

# Configure logging
logging.basicConfig(
    filename=LOG_FILENAME,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

# Set Tesseract path
pytesseract.pytesseract.tesseract_cmd = TESSERACT_PATH

# Image paths
land_tab_images = [
    f'{IMAGE_PATH}/Proval_land_tab.PNG',
    f'{IMAGE_PATH}/Proval_land_tab_active.PNG'
]
land_base_tab_images = [
    f'{IMAGE_PATH}/Proval_land_base_tab.PNG',
    f'{IMAGE_PATH}/Proval_land_base_tab_active.PNG'
]
permits_tab_images = [
    f'{IMAGE_PATH}/Proval_permits_tab.PNG',
    f'{IMAGE_PATH}/Proval_permits_tab_active.PNG'
]
permits_add_permit_button = [
    f'{IMAGE_PATH}/Proval_permits_add_permit_button.PNG',
    f'{IMAGE_PATH}/Proval_permits_add_permit_button_active.PNG'
]
duplicate_memo_image_path = f'{IMAGE_PATH}/Proval_memo_duplicate.PNG'
add_field_visit_image_path = f'{IMAGE_PATH}/Proval_permits_add_fieldvisit_button.PNG'
aggregate_land_type_add_button = f'{IMAGE_PATH}/Proval_aggregate_land_type_add_button.PNG'
farm_total_acres_image = f'{IMAGE_PATH}/Proval_farm_total_acres.PNG'
permit_description = f'{IMAGE_PATH}/Proval_permit_description.PNG'
memos_land_information_ = f'{IMAGE_PATH}/Proval_memos_land_information_.PNG'
pricing_selectall = f'{IMAGE_PATH}/Proval_pricing_selectall.png'
NC24Memo = f'{IMAGE_PATH}/Proval_memo_NC24.png'
history = f'{IMAGE_PATH}/Proval_values_history.png'
summary = f'{IMAGE_PATH}/Proval_values_summary.png'
parcel = f'{IMAGE_PATH}/Proval_parcel_tab.png'

def monitor_kill_key():
    global stop_script
    logging.info("Kill key monitor started. Press 'esc' to stop the script.")
    keyboard.wait('esc')
    stop_script = True
    logging.info("Kill key pressed. Stopping the script...")
    sys.exit("Script terminated")

kill_key_thread = threading.Thread(target=monitor_kill_key)
kill_key_thread.daemon = True
kill_key_thread.start()

def check_for_kill():
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        sys.exit("Script terminated by user")

def is_capslock_on():
    hllDll = ctypes.WinDLL("User32.dll")
    VK_CAPITAL = 0x14
    return bool(hllDll.GetKeyState(VK_CAPITAL) & 1)

def ensure_capslock_off():
    if is_capslock_on():
        pyautogui.press('capslock')
        logging.info("CAPS LOCK was on. It has been turned off.")
    else:
        logging.info("CAPS LOCK is already off.")

def process_log(log_filename):
    unique_ains = set()
    today_date = datetime.now().strftime('%Y-%m-%d')
    pattern = re.compile(r'Sent AIN (\d{6})')
    
    try:
        with open(log_filename, 'r') as log_file:
            for line in log_file:
                if today_date in line:
                    match = pattern.search(line)
                    if match:
                        unique_ains.add(match.group(1))
    except FileNotFoundError:
        logging.error(f"Log file not found: {log_filename}")
    except Exception as e:
        logging.error(f"Error processing log file: {e}")
    
    return sorted(unique_ains)

def print_unique_ains(unique_ains):
    logging.info(f"Unique AINs count for {datetime.now().strftime('%Y-%m-%d')}: {len(unique_ains)}")
    for ain in unique_ains:
        logging.info(ain)

def setup_gui():
    root = tk.Tk()
    root.title("User Input Form")
    
    current_year = datetime.now().year
    ttk.Label(root, text=f"AIN to post (Year: {current_year})").grid(column=0, row=0, padx=10, pady=5)
    entry_ain = ttk.Entry(root, width=50)
    entry_ain.grid(column=1, row=0, padx=10, pady=5)

    ttk.Label(root, text="Posting Date:").grid(column=0, row=3, padx=10, pady=5)
    entry_postdate = ttk.Entry(root, width=50)
    entry_postdate.grid(column=1, row=3, padx=10, pady=5)

    posting_types = ["HOEX", "FV", "CO", "BF", "OWNER", "TRANSFER"]
    ttk.Label(root, text="Posting Type:").grid(column=0, row=6, padx=10, pady=5)
    combobox_postingtype = ttk.Combobox(root, values=posting_types, width=47)
    combobox_postingtype.grid(column=1, row=6, padx=10, pady=5)
    combobox_postingtype.current(0)

    submit_button = ttk.Button(root, text="Submit", command=lambda: on_submit(root, entry_ain, entry_postdate, combobox_postingtype))
    submit_button.grid(column=0, row=8, columnspan=2, pady=20)

    return root

def on_submit(root, entry_ain, entry_postdate, combobox_postingtype):
    global AIN, PDATE, PostingType, MemoTXT
    ensure_capslock_off()
    AIN = [ain.strip() for ain in entry_ain.get().strip().upper().split(",")]
    AIN_str = ', '.join(AIN)
    PDATE = entry_postdate.get().strip().upper()
    PostingType = combobox_postingtype.get().strip().upper()
    MemoTXT = f"POSTED - {PostingType} {PDATE}"

    if not AIN or not PDATE or not PostingType:
        messagebox.showerror("Input Error", "All input fields are required.")
        return
    
    logging.info(f"Variables Created:")
    logging.info(f"AIN: {AIN}")
    logging.info(f"AIN_str: {AIN_str}")
    logging.info(f"PostingType: {PostingType}")
    logging.info(f"MemoTXT: {MemoTXT}")
    logging.info(f"PDATE: {PDATE}")

    logging.info(f"Generated MemoTXT: {MemoTXT}")
    root.destroy()

def set_focus(window_title):
    windows = pyautogui.getWindowsWithTitle(window_title)
    if windows:
        window = windows[0]
        window.activate()
        logging.info(f"Set focus to window: {window_title}")
        return True
    else:
        logging.error(f"Failed to set focus to {window_title} window. Script stopped.")
        sys.exit("Script terminated")

def press_key_multiple_times(key, times):
    for _ in range(times):
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
        pyautogui.press(key)

def press_key_with_modifier_multiple_times(modifier, key, times):
    for _ in range(times):
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
        pyautogui.hotkey(modifier, key)

# Processing OCR Images: Step 1 - Capture Screen in Greyscale
def capture_and_convert_screenshot():
    screenshot = pyautogui.screenshot()
    screenshot_np = np.array(screenshot)
    screenshot_np = cv2.cvtColor(screenshot_np, cv2.COLOR_RGB2BGR)
    grey_screenshot = cv2.cvtColor(screenshot_np, cv2.COLOR_BGR2GRAY)
    return grey_screenshot

# Processing OCR Images: Step 2 - Click using a reference greyscale shot
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

# Processing OCR Images: Step 3 - Using click_on_image function
    #Specific Click Functions Here, See click_on_image for directionals, and image pathes for images
def click_image_single(image_path, direction='center', offset=50, inset=7, confidence=0.75):
    logging.info(f"Trying to click {direction} on image: {image_path}")
    if click_on_image(image_path, direction=direction, offset=offset, inset=inset, confidence=confidence):
        logging.info(f"Successfully clicked {direction} of {image_path}.")
        return True
    else:
        logging.warning(f"Failed to click {direction} of {image_path}.")
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

# Processing OCR Images: Step 4 - Checking if image is present
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

def process_single_ain(ain, is_first_record):
    global PDATE, PostingType, MemoTXT, stop_script
    logging.info(f"Processing AIN: {ain}")

    set_focus("ProVal")
    pyautogui.hotkey('win', 'up')
    logging.info("Maximized ProVal window")
    check_for_kill()

    # Process: Open an AIN in ProVal
    pyautogui.hotkey('ctrl', 'o')
    time.sleep(1)
    check_for_kill()

    if is_first_record:
        press_key_multiple_times('up', 12)
        press_key_multiple_times('down', 4)

    pyautogui.press(['tab', 'delete'])
    ensure_capslock_off()
    pyautogui.typewrite(str(ain))
    pyautogui.press('enter')
    time.sleep(1)
    check_for_kill()

    logging.info(f"Sent AIN {ain}.")
    logging.info(f"Close Pop-Up, Open the {ain}")

    # Prompt user to confirm AIN is open
    prompt_root = tk.Tk()
    prompt_root.withdraw()
    if not messagebox.askyesno("Continue", f"Is AIN {ain} open and ready?", parent=prompt_root):
        stop_script = True
        prompt_root.destroy()
        return
    prompt_root.destroy()
    check_for_kill()

    # Promoting Future Property Records
    prompt_root = tk.Tk()
    prompt_root.withdraw()
    if messagebox.askyesno("Question", "Promote Future Property Records?", parent=prompt_root):
        logging.info("User chose to promote Future Property Records")
        time.sleep(1)
        set_focus("ProVal")
        time.sleep(1)
        pyautogui.hotkey('alt', 'p', 'f')
        time.sleep(1)
        pyautogui.hotkey('p')
        time.sleep(1)
        pyautogui.press('enter')
        time.sleep(1)
        logging.info("Promoted Future Property Records")
    else:
        time.sleep(1)
        logging.info("User chose not to promote Future Property Records")
    prompt_root.destroy()

    check_for_kill()

    # Promoting Future Land Records
    prompt_root = tk.Tk()
    prompt_root.withdraw()
    if messagebox.askyesno("Question", "Promote Future Land Records?", parent=prompt_root):
        logging.info("User chose to promote Future Land Records")
        time.sleep(1)
        set_focus("ProVal")
        time.sleep(1)
        pyautogui.hotkey('alt', 'p', 'f')
        time.sleep(1)
        pyautogui.hotkey('o')
        time.sleep(1)
        pyautogui.press('enter')
        time.sleep(1)
        logging.info("Promoted Future Land Records")
    else:
        time.sleep(1)
        logging.info("User chose not to promote Future Land Records")
    prompt_root.destroy()

    check_for_kill()

    # Open Allocations
    set_focus("ProVal")
    time.sleep(1) 
    pyautogui.hotkey('F9')
    time.sleep(1) 
    logging.info("Allocations opened.")
    check_for_kill()

    # Prompt User: Check Allocations
    prompt_root = tk.Tk()
    prompt_root.withdraw()
    if messagebox.askyesno("Continue", "Allocations window opened. Are allocations good?", parent=prompt_root):
        logging.info("User confirmed Allocations are good")
        time.sleep(1)
        set_focus("Cost Allocations")
        time.sleep(1)
        pyautogui.hotkey('alt', 'n')
        time.sleep(2)
    else:
        stop_script = True
        logging.info("User indicated Allocations are not good. Script stopped.")
        prompt_root.destroy()
        return
    prompt_root.destroy()
    check_for_kill()

    # Process: Key Info
    pyautogui.hotkey('ctrl', 'k')
    time.sleep(1)
    logging.info("Key Information opened.")
    check_for_kill()

    # Prompt User: Check Key Information
    prompt_root = tk.Tk()
    prompt_root.withdraw()
    if messagebox.askyesno("Continue", "Key Information window opened. Is Key Information good?", parent=prompt_root):
        logging.info("User confirmed Key Information is good")
        set_focus("Key Information")
        time.sleep(1)
        pyautogui.press('enter')
        pyautogui.press('esc')
        time.sleep(1)
        check_for_kill()
    else:
        stop_script = True
        logging.info("User indicated Key Information is not good. Script stopped.")
        prompt_root.destroy()
        return
    prompt_root.destroy()
    check_for_kill()

    # Process: Price Parcel
    pyautogui.hotkey('alt', 'v', 'c')
    time.sleep(1)
    logging.info("Opened pricing window.")
    time.sleep(1)
    check_for_kill()

    # Process: Find and Click Select All & OK
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

    # Prompt User: Check value
    prompt_root = tk.Tk()
    prompt_root.withdraw()
    if messagebox.askyesno("Continue", "Is the summary value good?", parent=prompt_root):
        logging.info("User confirmed summary value is good")
        time.sleep(1)
        set_focus("ProVal")
        time.sleep(1)
    else:
        stop_script = True
        logging.info("User indicated summary value is not good. Script stopped.")
        prompt_root.destroy()
        return
    prompt_root.destroy()
    check_for_kill()

    # Process: Open Memos
    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(1)
    logging.info("Opened Memos window")
    check_for_kill()

    # Process: Find and Click NC24 Memo
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
        logging.info(f"Added memo: {MemoTXT}")
        prompt_root = tk.Tk()
        prompt_root.withdraw()
        if not messagebox.askyesno("Question", "Memo entered correctly?", parent=prompt_root):
            stop_script = True
            logging.info("User indicated memo was not entered correctly. Script stopped.")
            prompt_root.destroy()
            return
        prompt_root.destroy()
    else:
        stop_script = True
        logging.warning("Unable to locate NC24 Memo.")
        return
    check_for_kill()

    # Save Account
    time.sleep(1)
    set_focus("ProVal")
    time.sleep(1)
    pyautogui.hotkey('ctrl', 's')
    logging.info("Saved account.")
    time.sleep(1)
    check_for_kill()
    
    # Post Parcel
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
    logging.info(f"Posted parcel with date: {PDATE}")
    time.sleep(1)
    check_for_kill()

    if click_image_single(parcel, direction='center', confidence=0.75):
        time.sleep(2)
        check_for_kill()
    else:
        check_for_kill()
        logging.info("Unable to locate. Script stopped.")
    check_for_kill()

def main():
    global AIN, PDATE, PostingType, MemoTXT, stop_script
    root = tk.Tk()
    root.withdraw()
    
    while True:
        input_window = setup_gui()
        input_window.wait_window()

        if not AIN or not PDATE or not PostingType:
            continue

        for index, ain in enumerate(AIN):
            if stop_script:
                break
            process_single_ain(ain, index == 0)  # Remove the 'root' argument here
            check_for_kill()
            if stop_script:
                break

        if stop_script:
            break

        if not messagebox.askyesno("Continue", "Do you want to process more AINs?", parent=root):
            break

    logging.info("Script completed.")
    unique_ains = process_log(LOG_FILENAME)
    print_unique_ains(unique_ains)
    root.destroy()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logging.error(f"An error occurred: {e}")
    finally:
        logging.info("Script execution finished.")