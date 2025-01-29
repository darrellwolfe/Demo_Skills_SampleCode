import re
import sys
import cv2
import time
import ctypes
import logging
import keyboard
import threading
import pyautogui
import pytesseract
import numpy as np
import tkinter as tk
from datetime import datetime
from tkinter import ttk, messagebox

mylog_filename = 'C:/Users/kmallery/Documents/Kootenai_County_Assessor_CodeBase/Working_Kendall/Logs_Kendall/OccPost.log'
stop_script = False
MemoTXT = ""

logging.basicConfig(
    filename = mylog_filename,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

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

class AINLogProcessor:
    def __init__(self, log_filename):
        self.log_filename = log_filename
        self.unique_ains = set()
        self.today_date = datetime.now().strftime('%Y-%m-%d')
        self.pattern = re.compile(r'Sent AIN (\d{6})')

    def process_log(self):

        with open(self.log_filename, 'r') as log_file:
            for line in log_file:
                if self.today_date in line:
                    match = self.pattern.search(line)
                    if match:
                        self.unique_ains.add(match.group(1))

    def get_unique_ains(self):
        return sorted(self.unique_ains)

    def print_unique_ains(self):
        unique_ains_list = self.get_unique_ains()
        print(f"Unique AINs count for {self.today_date}: {len(unique_ains_list)}")
        for ain in unique_ains_list:
            print(ain)

if __name__ == "__main__":
    log_processor = AINLogProcessor(mylog_filename)



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

    ttk.Label(root, text=f"AIN to post (Year: {current_year})").grid(column=0, row=0, padx=10, pady=5)
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

pytesseract.pytesseract.tesseract_cmd = r'C:\Users\%USERNAME%\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'

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
memos_land_information_ = r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memos_land_information_.PNG'
pricing_selectall =r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_pricing_selectall.png'
NC24Memo =r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_memo_NC24.png'
history =r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_values_history.png'
summary =r'S:\Common\Comptroller Tech\Reports\Python\py_images\Proval_values_summary.png'

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

root.mainloop()
if  not PDATE or not PostingType or not MemoTXT:
    messagebox.showerror("Input Error", "All input fields are required.")
    sys.exit()

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

set_focus("ProVal")
time.sleep(1)

logging.info("set_focus(ProVal)")
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
ensure_capslock_off()
time.sleep(1)

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
if stop_script:
    logging.info("Script stopping due to kill key press.")
    sys.exit()

pyautogui.hotkey('F9')
time.sleep(1)
logging.info("Allocations opened.")
stop_script

root = tk.Tk()
root.withdraw()
result = messagebox.askquestion("Question", "Do you want to continue?")
if result == 'yes':
    logging.info("User clicked Yes")
    time.sleep(1) 
    set_focus("Cost Allocations")
    time.sleep(1)  
    pyautogui.hotkey('alt','n')
    time.sleep(2)
else:
    stop_script
    logging.info("User pressed no. Script stopped.")
stop_script

pyautogui.hotkey('ctrl','k')
time.sleep(1)
logging.info("Key Information opened.")
stop_script

root = tk.Tk()
root.withdraw()
result = messagebox.askquestion("Question", "Do you want to continue?")
if result == 'yes':
    logging.info("User clicked Yes")
    set_focus("Key Information")
    time.sleep(1)
    pyautogui.press('enter')
    pyautogui.press('esc')
    stop_script
else:
    stop_script
    logging.info("User pressed no. Script stopped.")
stop_script

pyautogui.hotkey('alt','v','c')
time.sleep(1)
logging.info("Opened pricing window.")
stop_script

if click_image_single(pricing_selectall, direction='center', confidence=0.75):
    time.sleep(1)
    press_key_multiple_times('left', 2)
    time.sleep(1)
    pyautogui.press('enter')
    time.sleep(1)
    logging.info("Pricing...")
    time.sleep(4)
    stop_script
else:
    stop_script
    logging.info("Unable to locate. Script stopped.")
stop_script

if click_image_single(summary, direction='center', confidence=0.75):
    time.sleep(4)
    stop_script
else:
    stop_script
    logging.info("Unable to locate. Script stopped.")
stop_script

root = tk.Tk()
root.withdraw()
result = messagebox.askquestion("Question", "Do you want to continue?")
if result == 'yes':
    logging.info("User clicked Yes")
    time.sleep(1)
    set_focus("ProVal")
    time.sleep(1)
    stop_script
else:
    stop_script
    logging.info("User pressed no. Script stopped.")
stop_script

pyautogui.hotkey('ctrl', 'shift', 'm')
time.sleep(1)
stop_script

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
    result = messagebox.askquestion("Question", "Do you want to continue?")
    if result == 'yes':
        logging.info("User clicked Yes")
        stop_script
    else:
        stop_script
        logging.info("User pressed no. Script stopped.")
    stop_script
else:
    stop_script
    logging.info("Unable to locate. Script stopped.")
stop_script

time.sleep(1)
set_focus("ProVal")
time.sleep(1)
pyautogui.hotkey('ctrl', 's')
logging.info("Save.")
time.sleep(1)
stop_script

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
stop_script

logging.info("THE END...")
time.sleep(1)
log_processor.process_log()
log_processor.print_unique_ains()
logging.info("AIN logged")

def process_single_ain(ain):
    global PDATE, PostingType, MemoTXT
    logging.info(f"Processing AIN: {ain}")

    set_focus("ProVal")
    pyautogui.hotkey('ctrl', 'o')
    time.sleep(1)
    press_key_multiple_times('up', 12)
    press_key_multiple_times('down', 4)
    pyautogui.press(['tab', 'delete'])
    ensure_capslock_off()
    pyautogui.typewrite(str(ain))
    pyautogui.press('enter')
    time.sleep(1)

    pyautogui.hotkey('F9')
    time.sleep(1)
    logging.info("Allocations opened.")

    pyautogui.hotkey('ctrl', 'k')
    time.sleep(1)
    logging.info("Key Information opened.")

    pyautogui.hotkey('alt', 'v', 'c')
    time.sleep(1)
    logging.info("Opened pricing window.")
    if click_image_single(pricing_selectall, direction='center', confidence=0.75):
        time.sleep(1)
        press_key_multiple_times('left', 2)
        pyautogui.press('enter')
        time.sleep(4)
        logging.info("Pricing...")
    else:
        logging.warning("Unable to locate pricing select all button.")

    if click_image_single(summary, direction='center', confidence=0.75):
        time.sleep(4)
    else:
        logging.warning("Unable to locate summary tab.")

    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(1)
    if click_image_single(NC24Memo, direction='center', confidence=0.75):
        pyautogui.press('enter')
        pyautogui.hotkey('ctrl', 'a')
        pyautogui.typewrite(MemoTXT)
        pyautogui.press('tab')
        pyautogui.press('enter')
    else:
        logging.warning("Unable to locate NC24 Memo.")

    set_focus("ProVal")
    pyautogui.hotkey('ctrl', 's')
    logging.info("Save.")
    time.sleep(1)

    # Post Parcel
    pyautogui.hotkey('alt', 'v', 'p')
    pyautogui.typewrite("2024")
    pyautogui.press('tab')
    pyautogui.typewrite(PDATE)
    pyautogui.press('tab')
    pyautogui.typewrite("0")
    pyautogui.press('tab')
    pyautogui.press('enter')
    time.sleep(1)
    pyautogui.press('enter')

    logging.info(f"Finished processing AIN: {ain}")

def main():
    global AIN, PDATE, PostingType, MemoTXT
    while True:
        root = setup_gui()
        root.mainloop()
        if not PDATE or not PostingType or not MemoTXT:
            messagebox.showerror("Input Error", "All input fields are required.")
            continue
        for ain in AIN:
            process_single_ain(ain)
            if stop_script:
                break
        if messagebox.askyesno("Continue", "Do you want to process more AINs?"):
            continue
        else:
            break
    logging.info("Script completed.")
    log_processor = AINLogProcessor(mylog_filename)
    log_processor.process_log()
    log_processor.print_unique_ains()

if __name__ == "__main__":
    mylog_filename = 'C:/Users/kmallery/Documents/Kootenai_County_Assessor_CodeBase/Working_Kendall/Logs_Kendall/OccPost.log'
    logging.basicConfig(
        filename=mylog_filename,
        level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG)
    console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
    logging.getLogger().addHandler(console_handler)

    stop_script = False
    kill_key_thread = threading.Thread(target=monitor_kill_key)
    kill_key_thread.daemon = True
    kill_key_thread.start()

    main()