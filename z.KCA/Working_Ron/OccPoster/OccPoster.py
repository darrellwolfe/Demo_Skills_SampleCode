import os
import sys
import cv2
import time
import ctypes
import psutil
import logging
import win32gui
import win32con
import pyautogui
import subprocess
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
    username = os.environ.get('USERNAME') or os.environ.get('USER')
    log_dir = os.path.expandvars(r'C:\Users\%USERNAME%\OccPoster\Logs')
    Path(log_dir).mkdir(parents=True, exist_ok=True)
    log_file = os.path.join(log_dir, 'OccPoster.log')
    logging.basicConfig(
        filename=log_file,
        level=logging.INFO,
        format='%(asctime)s:%(levelname)s:%(message)s',
        filemode='a'
    )
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    logging.info(f"\n{'='*50}\nNew session started at {current_time}\n{'='*50}")
    logging.info(f"Logging initialized for user: {username}")

setup_logging()

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

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
    sys.exit("Script terminated by user")

def on_closing(root):
    global stop_script
    stop_script = True
    logging.info("User closed the OccPoster window. Exiting.")
    root.quit()
    sys.exit("Script terminated by user")

def setup_gui():
    root = tk.Tk()
    root.title("OccPoster(1.0)")
    root.geometry("300x150")
    root.protocol("WM_DELETE_WINDOW", lambda: on_closing(root))
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
    global AIN, PDATE, PostingType, MemoTXT
    ensure_capslock_off()
    AIN = [ain.strip() for ain in entry_ain.get().strip().upper().split(",")]
    AIN_str = ', '.join(AIN)
    PDATE = entry_postdate.get().strip().upper()
    PostingType = combobox_postingtype.get().strip().upper()
    MemoTXT = f"POSTED - {PostingType} {PDATE}"

    if not AIN or not PDATE or not PostingType:
        show_messagebox("Input Error", "All input fields are required.", "error")
        return
    
    logging.info(f"Variables Created:")
    logging.info(f"AIN: {AIN}")
    logging.info(f"AIN_str: {AIN_str}")
    logging.info(f"PostingType: {PostingType}")
    logging.info(f"MemoTXT: {MemoTXT}")
    logging.info(f"PDATE: {PDATE}")

    logging.info(f"Generated MemoTXT: {MemoTXT}")
    root.destroy()
    logging.info("Input window closed, continuing with processing")

def show_messagebox(title, message, type="yesno"):
    temp_root = tk.Tk()
    temp_root.withdraw()
    temp_root.attributes('-topmost', True)
    
    if type == "yesno":
        result = messagebox.askyesno(title, message, parent=temp_root)
    elif type == "error":
        result = messagebox.showerror(title, message, parent=temp_root)
    else:
        result = messagebox.showinfo(title, message, parent=temp_root)
    
    temp_root.destroy()
    return result

def check_for_kill():
    if stop_script:
        logging.info("Script stopping due to kill signal.")
        sys.exit("Script terminated by user")

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

def capture_and_convert_screenshot():
    screenshot = pyautogui.screenshot()
    screenshot_np = np.array(screenshot)
    screenshot_np = cv2.cvtColor(screenshot_np, cv2.COLOR_RGB2BGR)
    grey_screenshot = cv2.cvtColor(screenshot_np, cv2.COLOR_BGR2GRAY)
    return grey_screenshot

def click_on_image(image_path, direction='center', offset=10, inset=7, confidence=0.75):
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

def is_image_found(image_path, confidence=0.75):
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

def is_proval_running():
    for proc in psutil.process_iter(['name']):
        if proc.info['name'].lower() == 'proval.exe':
            return True
    return False

def open_proval():
    proval_path = r'C:\Program Files (x86)\Thomson Reuters\ProVal\ProVal.exe'
    if not is_proval_running():
        try:
            subprocess.Popen(proval_path)
            logging.info("Launched ProVal.")
        except Exception as e:
            logging.error(f"Failed to start ProVal: {e}")
            raise
    else:
        logging.info("ProVal is already running.")

def wait_for_proval_window(timeout=30):
    start_time = time.time()
    while time.time() - start_time < timeout:
        windows = pyautogui.getWindowsWithTitle("ProVal")
        if windows and windows[0].visible:
            return True
        time.sleep(1)
    return False

def focus_and_maximize_proval():
    try:
        hwnd = win32gui.FindWindow(None, "ProVal")
        if hwnd == 0:
            logging.error("ProVal window not found")
            return False
        
        win32gui.SetForegroundWindow(hwnd)
        win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
        
        logging.info("ProVal window focused and maximized")
        return True
    except Exception as e:
        logging.error(f"Error focusing and maximizing ProVal window: {str(e)}")
        return False

def process_single_ain(ain, is_first_record):
    global PDATE, PostingType, MemoTXT, stop_script
    logging.info(f"Processing AIN: {ain}")

    if not is_proval_running():
        open_proval()
    
    if not wait_for_proval_window():
        logging.error("ProVal window did not become visible within the timeout period.")
        return False

    if not focus_and_maximize_proval():
        logging.error("Failed to focus and maximize ProVal window.")
        return False

    logging.info("ProVal window activated, focused, and maximized.")

    set_focus("ProVal")
    pyautogui.hotkey('win', 'up')
    logging.info("Maximized ProVal window")
    check_for_kill()

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

    if not show_messagebox("Continue", f"Is AIN {ain} open and ready?"):
        stop_script = True
        return
    check_for_kill()

    if show_messagebox("Question", "Promote Future Property Records?"):
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

    check_for_kill()

    if show_messagebox("Question", "Promote Future Land Records?"):
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

    check_for_kill()

    set_focus("ProVal")
    time.sleep(1) 
    pyautogui.hotkey('F9')
    time.sleep(1) 
    logging.info("Allocations opened.")
    check_for_kill()

    if show_messagebox("Continue", "Allocations window opened. Are allocations good?"):
        logging.info("User confirmed Allocations are good")
        time.sleep(1)
        set_focus("Cost Allocations")
        time.sleep(1)
        pyautogui.hotkey('alt', 'n')
        time.sleep(2)
    else:
        stop_script = True
        logging.info("User indicated Allocations are not good. Script stopped.")
        return
    check_for_kill()

    pyautogui.hotkey('ctrl', 'k')
    time.sleep(1)
    logging.info("Key Information opened.")
    check_for_kill()

    if show_messagebox("Continue", "Key Information window opened. Is Key Information good?"):
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
        return
    check_for_kill()

    pyautogui.hotkey('alt', 'v', 'c')
    time.sleep(1)
    logging.info("Opened pricing window.")
    time.sleep(1)
    check_for_kill()

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
        return
    check_for_kill()

    if click_image_single(summary, direction='center', confidence=0.75):
        time.sleep(4)
        check_for_kill()
    else:
        check_for_kill()
        logging.info("Unable to locate. Script stopped.")
        return
    check_for_kill()

    if show_messagebox("Continue", "Is the summary value good?"):
        logging.info("User confirmed summary value is good")
        time.sleep(1)
        set_focus("ProVal")
        time.sleep(1)
    else:
        stop_script = True
        logging.info("User indicated summary value is not good. Script stopped.")
        return
    check_for_kill()

    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(1)
    logging.info("Opened Memos window")
    check_for_kill()

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
        if not show_messagebox("Question", "Memo entered correctly?"):
            stop_script = True
            logging.info("User indicated memo was not entered correctly. Script stopped.")
            return
    else:
        stop_script = True
        logging.warning("Unable to locate NC24 Memo.")
        return
    check_for_kill()

    time.sleep(1)
    set_focus("ProVal")
    time.sleep(1)
    pyautogui.hotkey('ctrl', 's')
    logging.info("Saved account.")
    time.sleep(1)
    check_for_kill()
    
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
        return
    check_for_kill()

def main():
    global AIN, PDATE, PostingType, MemoTXT, stop_script
    
    while True:
        if stop_script:
            break
        logging.info("Starting new iteration of main loop")
        input_window = setup_gui()
        input_window.mainloop()
        logging.info("Input window mainloop exited")

        if stop_script:
            break

        if not AIN or not PDATE or not PostingType:
            logging.info("Invalid input, restarting loop")
            continue

        logging.info(f"Processing {len(AIN)} AINs")
        for index, ain in enumerate(AIN):
            if stop_script:
                logging.info("Stop script flag set, breaking AIN processing loop")
                break
            logging.info(f"Processing AIN {ain} (index: {index})")
            process_single_ain(ain, index == 0)
            check_for_kill()
            if stop_script:
                logging.info("Stop script flag set after processing AIN")
                break

        if stop_script:
            logging.info("Stop script flag set, breaking main loop")
            break

        if not show_messagebox("Continue", "Do you want to process more AINs?"):
            logging.info("User chose not to continue, breaking main loop")
            break
        logging.info("User chose to continue, restarting main loop")

    logging.info("Script completed.")

if __name__ == "__main__":
    setup_logging()
    try:
        logging.info("Starting main execution")
        main()
    except SystemExit:
        pass
    except Exception as e:
        logging.exception("An error occurred in the main execution:")
        
        error_root = tk.Tk()
        error_root.withdraw()
        
        error_message = f"An error occurred:\n\n{str(e)}\n\nPlease check the log file for more details."
        
        show_messagebox("Error", error_message, "error")
        
        error_root.destroy()
    finally:
        logging.info("Script execution finished.")