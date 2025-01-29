import os
import sys
import cv2
import time
import ctypes
import logging
import pyautogui
import pytesseract
import numpy as np
import tkinter as tk
from pathlib import Path
from datetime import datetime
from tkinter import ttk, messagebox

# Configuration
LOG_FILE_PATH = os.path.expandvars(r'C:\Users\%USERNAME%\OccPoster\Logs\OccPoster.log')
TESSERACT_PATH = r'C:\Users\%USERNAME%\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'
IMAGE_PATH = r'S:\Common\Comptroller Tech\Reports\Python\py_images'

# Global variables
stop_script = False
AIN = []
PDATE = ""
PostingType = ""
MemoTXT = ""

def setup_logging():
    # Get the current user's username
    username = os.environ.get('USERNAME') or os.environ.get('USER')
    
    # Create the log directory path
    log_dir = os.path.expandvars(r'C:\Users\%USERNAME%\OccPoster\Logs')
    
    # Create the log directory if it doesn't exist
    Path(log_dir).mkdir(parents=True, exist_ok=True)
    
    # Set up the log file path
    log_file = os.path.join(log_dir, 'OccPoster.log')
    
    # Configure logging
    logging.basicConfig(
        filename=log_file,
        level=logging.INFO,
        format='%(asctime)s:%(levelname)s:%(message)s',
        filemode='a'  # 'a' means append (instead of 'w' for write)
    )
    
    # Add a separator with timestamp when a new session starts
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    logging.info(f"\n{'='*50}\nNew session started at {current_time}\n{'='*50}")
    logging.info(f"Logging initialized for user: {username}")

# Call setup_logging at the start of the script
setup_logging()

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

def ensure_capslock_off():
    hllDll = ctypes.WinDLL("User32.dll")
    VK_CAPITAL = 0x14
    if hllDll.GetKeyState(VK_CAPITAL):
        logging.info("Caps Lock was on. Turning it off.")
        ctypes.windll.user32.keybd_event(VK_CAPITAL, 0x45, 0x1, 0)
        ctypes.windll.user32.keybd_event(VK_CAPITAL, 0x45, 0x3, 0)
    else:
        logging.info("Caps Lock is already off.")

def on_escape(event):
    global stop_script
    stop_script = True
    logging.info("Kill key (ESC) pressed. Stopping the script...")
    event.widget.quit()

def on_closing(root):
    global stop_script
    stop_script = True
    logging.info("User closed the OccPoster window. Exiting.")
    root.quit()

def setup_gui():
    root = tk.Tk()
    root.title("OccPoster(1.0)")
    
    # Create the window with its default size
    root.geometry("300x150")
    
    # Add protocol handler for window close event
    root.protocol("WM_DELETE_WINDOW", lambda: on_closing(root))
    
    # Bind the Escape key to the on_escape function
    root.bind('<Escape>', on_escape)
    
    current_year = datetime.now().year
    ttk.Label(root, text=f"AIN to post (Year: {current_year})").grid(column=0, row=0, padx=10, pady=5)
    entry_ain = ttk.Entry(root, width=10)
    entry_ain.grid(column=1, row=0, padx=10, pady=5)

    ttk.Label(root, text="Posting Date:").grid(column=0, row=3, padx=10, pady=5)
    entry_postdate = ttk.Entry(root, width=10)
    entry_postdate.grid(column=1, row=3, padx=10, pady=5)

    posting_types = ["HOEX", "FV", "CO", "BF", "OWNER", "TRANSFER"]
    ttk.Label(root, text="Posting Type:").grid(column=0, row=6, padx=10, pady=5)
    combobox_postingtype = ttk.Combobox(root, values=posting_types, width=10)
    combobox_postingtype.grid(column=1, row=6, padx=10, pady=5)
    combobox_postingtype.current(0)

    submit_button = ttk.Button(root, text="Submit", command=lambda: on_submit(root, entry_ain, entry_postdate, combobox_postingtype))
    submit_button.grid(column=0, row=8, columnspan=2, pady=20)

    return root

def on_submit(root, entry_ain, entry_postdate, combobox_postingtype):
    global AIN, PDATE, PostingType, MemoTXT, stop_script
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
    stop_script = True
    root.quit()

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
            logging.info("Script stopping due to kill signal.")
            return
        pyautogui.press(key)

def press_key_with_modifier_multiple_times(modifier, key, times):
    for _ in range(times):
        if stop_script:
            logging.info("Script stopping due to kill signal.")
            return
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
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

    # Process: Open an AIN in ProVal
    pyautogui.hotkey('ctrl', 'o')
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

    if is_first_record:
        press_key_multiple_times('up', 12)
        press_key_multiple_times('down', 4)

    pyautogui.press(['tab', 'delete'])
    ensure_capslock_off()
    pyautogui.typewrite(str(ain))
    pyautogui.press('enter')
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

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
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

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

    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

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

    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

    # Open Allocations
    set_focus("ProVal")
    time.sleep(1) 
    pyautogui.hotkey('F9')
    time.sleep(1) 
    logging.info("Allocations opened.")
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

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
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

    # Process: Key Info
    pyautogui.hotkey('ctrl', 'k')
    time.sleep(1)
    logging.info("Key Information opened.")
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

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
        if stop_script:
            logging.info("Script stopping due to kill signal.")
            return
    else:
        stop_script = True
        logging.info("User indicated Key Information is not good. Script stopped.")
        prompt_root.destroy()
        return
    prompt_root.destroy()
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

    # Process: Price Parcel
    pyautogui.hotkey('alt', 'v', 'c')
    time.sleep(1)
    logging.info("Opened pricing window.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

    # Process: Find and Click Select All & OK
    if click_image_single(pricing_selectall, direction='center', confidence=0.75):
        time.sleep(1)
        press_key_multiple_times('left', 2)
        time.sleep(1)
        pyautogui.press('enter')
        time.sleep(1)
        logging.info("Pricing...")
        time.sleep(3)
        if stop_script:
            logging.info("Script stopping due to kill signal.")
            return
    else:
        if stop_script:
            logging.info("Script stopping due to kill signal.")
            return
        logging.info("Unable to locate. Script stopped.")
        return
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

    #Process: Find and Click the Values Summary sub-tab
    if click_image_single(summary, direction='center', confidence=0.75):
        time.sleep(4)
        if stop_script:
            logging.info("Script stopping due to kill signal.")
            return
    else:
        if stop_script:
            logging.info("Script stopping due to kill signal.")
            return
        logging.info("Unable to locate. Script stopped.")
        return
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

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
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

    # Process: Open Memos
    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(1)
    logging.info("Opened Memos window")
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

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
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

    # Save Account
    time.sleep(1)
    set_focus("ProVal")
    time.sleep(1)
    pyautogui.hotkey('ctrl', 's')
    logging.info("Saved account.")
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return
    
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
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

    if click_image_single(parcel, direction='center', confidence=0.75):
        time.sleep(2)
        if stop_script:
            logging.info("Script stopping due to kill signal.")
            return
    else:
        if stop_script:
            logging.info("Script stopping due to kill signal.")
            return
        logging.info("Unable to locate. Script stopped.")
        return
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        return

def main():
    root = setup_gui()
    root.mainloop()
    
    if stop_script:
        sys.exit(0)

if __name__ == "__main__":
    setup_logging()
    try:
        main()
    except Exception as e:
        logging.exception("An error occurred in the main execution:")
        
        # Create a root window
        error_root = tk.Tk()
        error_root.withdraw()  # Hide the main window
        
        # Format the error message
        error_message = f"An error occurred:\n\n{str(e)}\n\nPlease check the log file for more details."
        
        # Show the error message in a messagebox
        messagebox.showerror("Error", error_message)
        
        # Destroy the root window
        error_root.destroy()