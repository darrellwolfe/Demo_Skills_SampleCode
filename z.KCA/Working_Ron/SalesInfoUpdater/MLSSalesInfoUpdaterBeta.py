import os
import sys
import time
import queue
import psutil
import ctypes
import logging
import datetime
import keyboard
import threading
import subprocess
import pandas as pd
import tkinter as tk
from tkinter import ttk
import pyautogui as pag
import pygetwindow as gw
from datetime import datetime
from tkinter import filedialog
from tkinter import messagebox
from pynput import keyboard as pynput_keyboard

def setup_logging():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    log_file = os.path.join(script_dir, "SalesInfoUpdater.log")
    
    # Define the log format
    log_format = '%(asctime)s - %(levelname)s - %(message)s'
    date_format = '%H:%M:%S'

    try:
        logging.basicConfig(
            filename=log_file,
            level=logging.INFO,  # Changed from DEBUG to INFO
            format=log_format,
            datefmt=date_format
        )
        logging.info(f"Logging to file set up successfully: {log_file}")
    except Exception as e:
        print(f"Failed to set up file logging: {e}")
    
    # Set up console logging
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)  # Changed from DEBUG to INFO
    console_formatter = logging.Formatter(log_format, datefmt=date_format)
    console_handler.setFormatter(console_formatter)
    logging.getLogger().addHandler(console_handler)

    logging.info("Logging setup completed")

setup_logging()

logging.info("Script initialization started")

PROVAL_PATH = "C:/Program Files (x86)/Thomson Reuters/ProVal/ProVal.exe"
proval_maximized = False
halt_event = threading.Event()
block_input = False
initial_caps_lock_state = ctypes.windll.user32.GetKeyState(0x14) & 1

def log_time(message):
    logging.info(message)

def get_proval_pid():
    """Get the PID of the ProVal process, or start it if not running."""
    logging.info("Checking for ProVal process")
    for proc in psutil.process_iter(['pid', 'name', 'exe']):
        try:
            if proc.info['exe'] and os.path.normpath(proc.info['exe']) == os.path.normpath(PROVAL_PATH):
                return proc.info['pid']
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass

    # ProVal is not running, attempt to start it
    logging.info("ProVal process not found, attempting to start it.")
    try:
        subprocess.Popen(PROVAL_PATH)
        logging.info("ProVal started successfully.")
        # Wait for ProVal to start
        while True:
            for proc in psutil.process_iter(['pid', 'name', 'exe']):
                try:
                    if proc.info['exe'] and os.path.normpath(proc.info['exe']) == os.path.normpath(PROVAL_PATH):
                        return proc.info['pid']
                except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                    pass
    except Exception as e:
        logging.error(f"Error starting ProVal: {e}")
        return None

def focus_proval_window(window_title):
    """Focus a specific ProVal window by its title."""
    logging.info(f"Attempting to focus ProVal window with title '{window_title}'")
    try:
        proval_pid = get_proval_pid()
        if not proval_pid:
            logging.error("ProVal process not found.")
            return False

        proval_window = gw.getWindowsWithTitle(window_title)[0]
        if proval_window:
            if proval_window.isMinimized:
                proval_window.maximize()  # Maximize if minimized
            proval_window.activate()
            logging.info(f"ProVal window '{window_title}' is confirmed as active.")
            return True
        else:
            logging.error(f"ProVal window '{window_title}' not found.")
            return False
    except Exception as e:
        logging.error(f"Error focusing ProVal window: {e}")
        return False

def get_batch_size():
    """Get the batch size using a Tkinter GUI with a slider."""
    logging.info("Prompting for batch size")
    global block_input
    block_input = True
    batch_size = None  # Initialize batch_size
    root = tk.Tk()
    root.title("Select Batch Size")
    root.attributes('-topmost', True)  # Keep the window on top
    root.focus_force()  # Bring the window to the front

    # Create a label
    label = tk.Label(root, text="Select batch size (0-100, 0 for all records):")
    label.pack(pady=10)

    # Create a scale (slider) for batch size selection
    scale = tk.Scale(root, from_=0, to=100, orient=tk.HORIZONTAL, length=300, tickinterval=10, resolution=1)
    scale.set(25)  # Set default value to 25
    scale.pack(pady=20)

    # Create an OK button to confirm the selection
    def on_ok():
        global block_input
        nonlocal batch_size  # Declare batch_size as nonlocal to access it
        batch_size = scale.get()  # Get the selected batch size
        block_input = False  # Reset block_input
        root.destroy()  # Close the dialog

    ok_button = tk.Button(root, text="OK", command=on_ok)
    ok_button.pack(pady=10)

    # Bind the Enter key to the OK button
    root.bind('<Return>', lambda event: on_ok())  # Bind Enter key

    # Handle window close event
    def on_closing():
        logging.warning("Batch size selection window closed without selection.")
        global block_input
        block_input = False  # Reset block_input
        root.destroy()  # Close the dialog

    root.protocol("WM_DELETE_WINDOW", on_closing)  # Bind the close event

    root.mainloop()  # Show the GUI

    # Check if the window was closed without selection
    if not block_input:  # Only access scale if the window was not closed without selection
        return batch_size  # Return the selected batch size
    else:
        logging.error("Batch size selection was cancelled.")
        return None  # Return None or handle as needed

def get_line_of_sale():
    """Get the line of sale selection using Tkinter GUI with a skip option."""
    logging.info("Prompting for line of sale")
    global block_input
    block_input = True

    # Ensure ProVal is in focus before showing the line of sale window
    if not focus_proval_window('ProVal'):
        logging.error("Could not focus ProVal window before line of sale selection.")
        block_input = False
        return None

    result_queue = queue.Queue()

    def create_window():
        root = tk.Tk()
        root.title("Line of Sale")
        root.attributes('-topmost', True)  # Keep the window on top

        def set_value(value):
            result_queue.put(value)
            root.quit()

        def on_closing():
            set_value('exit')

        tk.Button(root, text="Line 1", command=lambda: set_value(1)).pack(fill=tk.X)
        tk.Button(root, text="Line 2", command=lambda: set_value(2)).pack(fill=tk.X)
        tk.Button(root, text="Line 3", command=lambda: set_value(3)).pack(fill=tk.X)
        tk.Button(root, text="Line 4", command=lambda: set_value(4)).pack(fill=tk.X)
        tk.Button(root, text="Skip", command=lambda: set_value('skip')).pack(fill=tk.X)

        root.protocol("WM_DELETE_WINDOW", on_closing)
        root.mainloop()
        root.destroy()

    # Run Tkinter on the main thread
    threading.Thread(target=create_window).start()

    # Wait for the result
    result = result_queue.get()
    block_input = False

    if result in ['skip', 'exit']:
        # Close the Update Sales Transaction Information window
        if focus_proval_window('Update Sales Transaction Information'):
            pag.hotkey('alt', 'f4')
        # Refocus the main ProVal window
        focus_proval_window('ProVal')
        if result == 'skip':
            logging.info("Record skipped by user.")
        else:
            logging.info("User exited line of sale selection.")
        return None

    # If a valid line of sale was selected, ensure we're back on the correct window
    if not focus_proval_window('Update Sales Transaction Information'):
        logging.error("Could not focus 'Update Sales Transaction Information' window after line selection.")
        return None

    return result

def select_file(title, filetypes):
    """Open a file dialog to select a file."""
    root = tk.Tk()
    root.withdraw()  # Hide the root window
    root.attributes('-topmost', True)  # Keep the dialog on top
    root.focus_force()  # Bring the dialog to the front

   # Handle window close event
    def on_closing():
        logging.warning("File selection window closed without selection.")
        root.destroy()  # Close the dialog

    root.protocol("WM_DELETE_WINDOW", on_closing)  # Bind the close event

    file_path = filedialog.askopenfilename(title=title, filetypes=filetypes)

    # Check if the user canceled the file selection
    if not file_path:
        logging.error("File selection was cancelled.")
        return None  # Return None or handle as needed

    root.destroy()
    return file_path


def save_file(title, filetypes):
    """Open a file dialog to specify a save location."""
    root = tk.Tk()
    root.withdraw()  # Hide the root window
    root.attributes('-topmost', True)  # Keep the window on top
    root.focus_force()  # Bring the dialog to the front
 
    # Handle window close event
    def on_closing():
        logging.warning("File selection window closed without selection.")
        root.destroy()  # Close the dialog

    root.protocol("WM_DELETE_WINDOW", on_closing)  # Bind the close event

    file_path = filedialog.asksaveasfilename(title=title, filetypes=filetypes, defaultextension=".xlsx")

    # Check if the user canceled the file selection
    if not file_path:
        logging.error("File selection was cancelled.")
        return None  # Return None or handle as needed

    root.destroy()
    return file_path

def monitor_hotkeys():
    """Monitor for the halt and skip hotkeys to stop or skip the script."""
    def on_halt():
        logging.info("Halt hotkey pressed.")
        halt_event.set()

    keyboard.add_hotkey('esc', on_halt)
    while not halt_event.is_set():
        pass
    logging.info("Script halted by user.")
    os._exit(1)

def block_keyboard_input(key):
    """Block keyboard input except for the halt hotkey and input prompts."""
    global block_input
    if block_input:
        return key == pynput_keyboard.Key.esc
    else:
        return key == pynput_keyboard.Key.ctrl_r and key == pynput_keyboard.Key.shift_r and key.char == 'h'

def block_mouse_input(x, y):
    """Block mouse input except during input prompts."""
    global block_input
    if block_input:
        return True
    else:
        return False

def toggle_caps_lock(state):
    """Toggle Caps Lock to the specified state (True for ON, False for OFF)."""
    current_state = ctypes.windll.user32.GetKeyState(0x14) & 1
    if current_state != state:
        ctypes.windll.user32.keybd_event(0x14, 0, 0, 0)  # Press Caps Lock key
        ctypes.windll.user32.keybd_event(0x14, 0, 0x0002, 0)  # Release Caps Lock key

def ensure_proval_ready():
    proval_window = None
    for window in gw.getWindowsWithTitle('ProVal'):
        if 'ProVal' in window.title:
            proval_window = window
            break
    
    if not proval_window:
        logging.info("ProVal window not found. Attempting to start ProVal.")
        try:
            subprocess.Popen(PROVAL_PATH)
            logging.info("ProVal started successfully.")
            # Wait for ProVal to start (adjust the timeout as needed)
            for _ in range(30):  # Wait up to 30 seconds
                time.sleep(1)
                for window in gw.getWindowsWithTitle('ProVal'):
                    if 'ProVal' in window.title:
                        proval_window = window
                        break
                if proval_window:
                    break
            else:
                logging.error("Timeout waiting for ProVal to start.")
                return False
        except Exception as e:
            logging.error(f"Error starting ProVal: {e}")
            return False

    if proval_window:
        if proval_window.isMinimized:
            proval_window.restore()
        proval_window.maximize()
        proval_window.activate()
        logging.info("ProVal window maximized and focused.")
        return True
    else:
        logging.error("ProVal window not found after attempting to start.")
        return False

class StatusWindow:
    def __init__(self, master, total_records, remaining_records, batch_size, current_batch):
        self.master = master
        master.title("Script Status")
        master.geometry("250x250")
        master.attributes('-topmost', True)
        
        screen_width = master.winfo_screenwidth()
        master.geometry(f"+{screen_width - 260}+10")

        self.current_batch = tk.StringVar()
        self.remaining_batches = tk.StringVar()
        self.current_record = tk.StringVar()
        self.current_batch_number = current_batch
        self.total_processed = tk.StringVar()
        self.total_left = tk.StringVar()
        self.status = tk.StringVar()

        ttk.Label(master, text="Current Batch:").grid(row=0, column=0, sticky="w", padx=5, pady=5)
        ttk.Label(master, textvariable=self.current_batch).grid(row=0, column=1, sticky="w", padx=5, pady=5)

        ttk.Label(master, text="Remaining Batches:").grid(row=1, column=0, sticky="w", padx=5, pady=5)
        ttk.Label(master, textvariable=self.remaining_batches).grid(row=1, column=1, sticky="w", padx=5, pady=5)

        ttk.Label(master, text="Current Record:").grid(row=2, column=0, sticky="w", padx=5, pady=5)
        ttk.Label(master, textvariable=self.current_record).grid(row=2, column=1, sticky="w", padx=5, pady=5)

        ttk.Label(master, text="Total Processed:").grid(row=3, column=0, sticky="w", padx=5, pady=5)
        ttk.Label(master, textvariable=self.total_processed).grid(row=3, column=1, sticky="w", padx=5, pady=5)

        ttk.Label(master, text="Total Left:").grid(row=4, column=0, sticky="w", padx=5, pady=5)
        ttk.Label(master, textvariable=self.total_left).grid(row=4, column=1, sticky="w", padx=5, pady=5)

        ttk.Label(master, text="Status:").grid(row=5, column=0, sticky="w", padx=5, pady=5)
        ttk.Label(master, textvariable=self.status).grid(row=5, column=1, sticky="w", padx=5, pady=5)

        ttk.Button(master, text="Kill Script", command=self.kill_script).grid(row=6, column=0, pady=10)
        ttk.Button(master, text="Save Progress", command=self.save_progress).grid(row=6, column=1, pady=10)

        self.kill_flag = False
        self.save_flag = False
        self.total_records = total_records
        self.remaining_records = remaining_records
        self.batch_size = batch_size
        self.processed_count = 0
        self.current_batch_number = 1
        self.records_in_current_batch = 0

        # Initialize the display
        self.update_status("Ready to start processing")

    def update_status(self, status):
        self.current_batch.set(f"{self.current_batch_number}/{self.total_batches}")
        self.remaining_batches.set(str(self.total_batches - self.current_batch_number + 1))
        self.current_record.set(f"{self.records_in_current_batch + 1}/{self.batch_size}")
        self.total_processed.set(str(self.processed_count))
        self.total_left.set(str(self.remaining_records))
        self.status.set(status)
        self.master.update()
    
    def increment_processed(self):
        self.processed_count += 1
        self.records_in_current_batch += 1  # Add this line
        self.remaining_records -= 1
        self.update_status("Processing...")

    def next_batch(self):
        self.current_batch_number += 1
        self.records_in_current_batch = 0
        self.update_status("Starting new batch...")
    
    def save_progress(self):
        self.save_flag = True
        self.status.set("Saving progress...")
        self.master.update()
        logging.info("Save progress requested by user.")

    def kill_script(self):
        self.kill_flag = True
        self.save_flag = True
        self.status.set("Killing script...")
        self.master.update()
        logging.info("Kill script requested by user.")
        # Signal the main thread to stop
        halt_event.set()
        # Close the status window
        self.master.after(1000, self.master.destroy)  # Give some time for the status to update before closing

def is_valid_excel(file_path):
    try:
        pd.read_excel(file_path, engine='openpyxl')
        return True
    except Exception as e:
        logging.error(f"Invalid Excel file: {e}")
        return False

def ensure_proval_ready():
    global proval_maximized  # Add this line at the beginning of the function
    if proval_maximized:
        return True
    for window in gw.getWindowsWithTitle('ProVal'):
        if 'ProVal' in window.title:
            proval_window = window
            break
    
    if not proval_window:
        logging.info("ProVal window not found. Attempting to start ProVal.")
        try:
            subprocess.Popen(PROVAL_PATH)
            logging.info("ProVal started successfully.")
            # Wait for ProVal to start (adjust the timeout as needed)
            for _ in range(30):  # Wait up to 30 seconds
                time.sleep(1)
                for window in gw.getWindowsWithTitle('ProVal'):
                    if 'ProVal' in window.title:
                        proval_window = window
                        break
                if proval_window:
                    break
            else:
                logging.error("Timeout waiting for ProVal to start.")
                return False
        except Exception as e:
            logging.error(f"Error starting ProVal: {e}")
            return False
    
    if proval_window:
        if proval_window.isMinimized:
            proval_window.restore()
        proval_window.maximize()
        proval_window.activate()
        logging.info("ProVal window maximized and focused.")
        proval_maximized = True
        return True
    else:
        logging.error("ProVal window not found.")
        return False

def prompt_user_continue_or_skip():
    """Prompt the user to continue, skip, or indicate that sales data has already been entered."""
    global block_input
    block_input = True
    result_queue = queue.Queue()

    def create_window():
        root = tk.Tk()
        root.title("Continue or Skip")
        root.attributes('-topmost', True)  # Keep the window on top

        def set_value(value):
            result_queue.put(value)
            root.quit()

        def on_closing():
            set_value('exit')

        tk.Label(root, text="Do you want to continue entering sales data?").pack(pady=10)
        tk.Button(root, text="Continue", command=lambda: set_value('continue')).pack(fill=tk.X)
        tk.Button(root, text="Skip", command=lambda: set_value('skip')).pack(fill=tk.X)
        tk.Button(root, text="Already Entered", command=lambda: set_value('already_entered')).pack(fill=tk.X)

        root.protocol("WM_DELETE_WINDOW", on_closing)
        root.mainloop()
        root.destroy()

    # Run Tkinter on the main thread
    create_window()

    # Wait for the result
    result = result_queue.get()
    block_input = False
    return result

def main_script():
    global initial_caps_lock_state, block_input

    toggle_caps_lock(False)

    # Try to ensure ProVal is ready up to 3 times
    for attempt in range(3):
        if ensure_proval_ready():
            break
        else:
            logging.warning(f"Attempt {attempt + 1} to prepare ProVal failed. Retrying...")
    else:
        logging.error("Failed to prepare ProVal after 3 attempts. Exiting script.")
        return

    if not ensure_proval_ready():
        logging.error("Failed to prepare ProVal. Exiting script.")
        return

    excel_path = select_file("Select Input Excel File", [("Excel files", "*.xlsx *.xls")])
    if not excel_path:
        logging.error("No input file selected.")
        return
    
    output_path = save_file("Select Output File Location", [("Excel files", "*.xlsx")])
    if not output_path:
        logging.error("No output file selected.")
        return

    logging.info("Loading Excel file- this might take awhile...")
    with pd.ExcelFile(excel_path) as xlsx:
        df = pd.read_excel(xlsx, sheet_name=0)
    
    logging.info(f"Excel file loaded. Total records: {len(df)}")

    # Convert AIN and AIN/Tax Bill columns to strings and remove trailing .0
    df['AIN'] = df['AIN'].astype(str).str.replace('.0', '', regex=False)
    df['AIN/Tax Bill'] = df['AIN/Tax Bill'].astype(str).str.replace('.0', '', regex=False)

    # If you need to add a Status column
    if 'Status' not in df.columns:
        df['Status'] = ''

    # Load existing output file if it exists
    if os.path.exists(output_path) and is_valid_excel(output_path):
        with pd.ExcelFile(output_path) as xlsx:
            existing_df = pd.read_excel(xlsx, sheet_name=0)
        logging.info(f"Loaded existing output file with {len(existing_df)} records.")
        
        # Update status for existing records
        existing_df['AIN'] = existing_df['AIN'].astype(str)
        df['AIN'] = df['AIN'].astype(str)
        
        # Create a dictionary of existing statuses, using a list for multiple entries
        existing_statuses = existing_df.groupby('AIN')['Status'].apply(list).to_dict()
        
        # Update statuses in the current DataFrame
        def update_status(row):
            ain = row['AIN']
            if ain in existing_statuses:
                statuses = existing_statuses[ain]
                if len(statuses) > 0:
                    return statuses.pop(0)  # Take and remove the first status
            return row['Status']
        
        df['Status'] = df.apply(update_status, axis=1)
        
        logging.info(f"Updated statuses from existing file. DataFrame size: {len(df)}")
    else:
        logging.info(f"No existing output file found. Will create a new one.")
    # Calculate total records and remaining records
    total_records = len(df)
    records_to_process = df[
        (df['Status'].isna()) | 
        (df['Status'] == 'Skipped or exited by user') | 
        (df['Status'].str.startswith('Error:', na=False))
    ]
    remaining_records = len(records_to_process)

    logging.info(f"Final DataFrame size: {total_records}")
    logging.info(f"Final status counts:\n{df['Status'].value_counts(dropna=False)}")
    logging.info(f"Total records: {total_records}, Records to process: {remaining_records}")

    # Save the updated DataFrame to the output file
    df.to_excel(output_path, index=False, engine='openpyxl')
    logging.info(f"Updated output file saved: {output_path}")

    batch_size = get_batch_size()
    if batch_size is None:
        logging.error("Batch size selection was cancelled.")
        return
    elif batch_size == 0:
        batch_size = remaining_records  # Process all records
        total_batches = 1
    else:
        total_batches = (remaining_records + batch_size - 1) // batch_size

    current_batch = 1
    
    root = tk.Tk()
    status_window = StatusWindow(root, total_records, remaining_records, batch_size, current_batch)
    
    # Add this line to ensure the initial state is correct
    status_window.update_status("Ready to start processing")

    def save_progress():
        df.to_excel(output_path, index=False, engine='openpyxl')
        logging.info(f"Progress saved to {output_path}")
        status_window.update_status("Progress saved")

    # Process only records that need processing
    for j, (index, row) in enumerate(records_to_process.iterrows()):
        if halt_event.is_set() or status_window.kill_flag:
            logging.info("Script termination requested. Stopping processing.")
            break

        if status_window.save_flag:
            save_progress()
            status_window.save_flag = False

        record_number = j + 1
        excel_row = index + 2
        logging.info(f"Starting to process Excel row {excel_row} (Log Record {record_number})")

        # Use j + 1 to log the record number starting from 1
        record_number = j + 1  # This will be used for logging
        excel_row = index + 2  # This reflects the actual Excel row
        logging.info(f"Starting to process Excel row {excel_row} (Log Record {record_number})")

        # Ensure ProVal is in focus before processing the record
        if not focus_proval_window('ProVal'):
            logging.error(f"Record {record_number}: ProVal window not found or could not be focused.")
            record_status = "Error: ProVal window not found or could not be focused."
            df.at[index, 'Status'] = record_status
            status_window.update_status(record_status)
            continue

        AIN_value = row.get('AIN', row.get('AIN/Tax Bill', None))
        Sales = row.get('Sold Price', None)
        Comment = "MLS"
        record_status = "Not Processed"

        logging.info(f"Record {record_number}: Processing AIN: {AIN_value}")

        try:
            if pd.isna(AIN_value):
                logging.info(f"Record {record_number}: AIN is NaN, skipping this record.")
                record_status = "Error: AIN is NaN"
                df.at[index, 'Status'] = record_status
                continue

            # Convert AIN_value to string and pad to 6 digits
            ain_str = str(int(AIN_value)).zfill(6)  # Convert to int to remove .0, then to str
            logging.info(f"Record {record_number}: AIN after conversion and padding = {ain_str}")

            if not ain_str.isdigit() or len(ain_str) != 6:
                logging.error(f"Record {record_number}: AIN '{ain_str}' is not 6 digits.")
                record_status = "Error: AIN is not 6 digits"
                df.at[index, 'Status'] = record_status
                continue

            AIN = ain_str
            logging.info(f"Record {record_number}: Final processed AIN = {AIN}")

            pag.hotkey('ctrl', 'o')
            pag.sleep(1)

            if record_number == 1:
                pag.press('up', presses=11, interval=0.01)
                pag.press('down', presses=4, interval=0.01)
                pag.press('tab')
            else:
                pag.press('tab')

            logging.info(f"Record {record_number}: About to input AIN: {AIN}")
            pag.write(AIN)
            logging.info(f"Record {record_number}: Finished inputting AIN")
            pag.press('enter')
            pag.sleep(2)

            pag.hotkey('alt', 'a', 'p', interval=0.25)

            line_of_sale = get_line_of_sale()
            if line_of_sale is None:
                logging.info(f"Record {record_number}: User skipped or exited the record.")
                record_status = "Skipped or exited by user"
                df.at[index, 'Status'] = record_status
                continue

            # Select the appropriate line of sale
            if line_of_sale == 1:
                pag.press('tab')
                pag.press('space')
            elif line_of_sale == 2:
                pag.press('tab')
                pag.press('down', presses=4, interval=0.01)
                pag.press('space')
            elif line_of_sale == 3:
                pag.press('tab')
                pag.press('down', presses=7, interval=0.01)
                pag.press('space')
            elif line_of_sale == 4:
                pag.press('tab')
                pag.press('down', presses=10, interval=0.01)
                pag.press('space')

            pag.hotkey('alt', 'e')

            # Prompt the user to continue or skip
            user_choice = prompt_user_continue_or_skip()
            if user_choice == 'skip':
                logging.info(f"Record {record_number}: User chose to skip.")
                record_status = "Skipped by user"
                focus_proval_window('Update Sales Transaction Information')
                # Navigate past the MLS comment field
                pag.press('tab', presses=38, interval=0.01)
                pag.press('enter')
                pag.sleep(1)
                pag.press('tab')
                pag.press('enter')
                continue
            elif user_choice == 'already_entered':
                logging.info(f"Record {record_number}: User indicated sales data already entered.")
                record_status = "Already Entered by user"
                focus_proval_window('Update Sales Transaction Information')
                # Navigate past the MLS comment field
                pag.press('tab', presses=38, interval=0.01)
                pag.press('enter')
                pag.sleep(1)
                pag.press('tab', presses=2)
                pag.press('enter')
                continue
            elif user_choice == 'exit':
                logging.info(f"Record {record_number}: User exited the prompt.")
                record_status = "Exited by user"
                halt_event.set()
                break

            # Continue with normal processing if user chose to continue
            pag.press('tab', presses=17, interval=0.01)
            logging.info(f"Record {record_number}: About to input Sales value: {Sales}")
            pag.write(str(Sales))
            logging.info(f"Record {record_number}: Finished inputting Sales value")
            pag.press('tab', presses=18, interval=0.01)
            logging.info(f"Record {record_number}: About to input Comment: {Comment}")
            pag.write(Comment)
            logging.info(f"Record {record_number}: Finished inputting Comment")
            pag.press('tab', presses=2, interval=0.01)
            pag.press('enter')
            pag.sleep(1)
            pag.press('tab')
            pag.press('enter')
            pag.hotkey('ctrl', 's')
            pag.sleep(1)
            record_status = "Entered Successfully"
            logging.info(f"Record {record_number}: Entered Successfully")

        except Exception as e:
            logging.error(f"Record {record_number}: Error - {e}")
            record_status = f"Error: {str(e)}"

        finally:
            df.at[index, 'Status'] = record_status
            status_window.increment_processed()
            status_window.update_status(record_status)
            logging.debug(f"Records in current batch: {status_window.records_in_current_batch}, Batch size: {batch_size}")

        # Check if we've completed a batch or reached the end of records
            save_progress()
            logging.info(f"Updated output file after processing batch {status_window.current_batch_number}")
            status_window.update_status(f"Completed batch {current_batch}")

            if j < len(records_to_process) - 1:  # If there are more records to process
                user_continue = messagebox.askyesno("Batch Complete", f"Batch {current_batch} processing complete. Continue to next batch?")
                if not user_continue:
                    logging.info("User chose to stop after completing a batch.")
                    break
                current_batch += 1
                status_window.next_batch()

            # Reset ProVal and ensure it's ready for the next batch
            if not ensure_proval_ready():
                logging.error("Failed to prepare ProVal for next batch. Exiting script.")
                break

    # After the loop, handle the termination
    if halt_event.is_set() or status_window.kill_flag:
        logging.info("Script terminated by user request.")
        save_progress()
        logging.info("Saved progress before termination.")
    else:
        # Normal termination code
        # Final save after processing all records
        save_progress()
        logging.info("Updated output file after processing all records")

        failed_records = df[df['Status'].str.contains('Error', na=False)].index.tolist()
        failed_output_path = os.path.join(os.path.dirname(output_path), "FailedRecords.xlsx")
        if failed_records:
            failed_df = df.iloc[failed_records].copy()
            
            logging.info(f"Processing failed records file: {failed_output_path}")
            if os.path.exists(failed_output_path):
                existing_failed_df = pd.read_excel(failed_output_path)
                combined_failed_df = pd.concat([existing_failed_df, failed_df], ignore_index=True)
                combined_failed_df.to_excel(failed_output_path, index=False)
                logging.info(f"Appended to existing failed records file: {failed_output_path}")
            else:
                failed_df.to_excel(failed_output_path, index=False)
                logging.info(f"Created new failed records file: {failed_output_path}")
        else:
            logging.info("No failed records in this run.")

        current_date = datetime.now()
        month_year = current_date.strftime("%m%y")
        sales_dir = os.path.join(os.path.expanduser("~"), "Documents", "Sales", month_year)
        os.makedirs(sales_dir, exist_ok=True)
        copy_path = os.path.join(sales_dir, "UpdatedSalesInfo.xlsx")

        logging.info(f"Saving/Appending to file in user's folder: {copy_path}")
        
        if os.path.exists(copy_path):
            existing_df = pd.read_excel(copy_path)
            combined_df = pd.concat([existing_df, df], ignore_index=True)
            combined_df.to_excel(copy_path, index=False)
            logging.info(f"Appended data to existing file: {copy_path}")
        else:
            df.to_excel(copy_path, index=False)
            logging.info(f"Created new file: {copy_path}")

        logging.info(f"Script completed. Final remaining records count: {status_window.remaining_records}")
        logging.info(f"Task completed! Updated file saved at {output_path}")
        if failed_records:
            logging.info(f"Failed records processed at {failed_output_path}")
        print("Task completed!")

    root.quit()  # Ensure the Tkinter event loop stops
    logging.info("Script execution completed.")

    toggle_caps_lock(initial_caps_lock_state)

if __name__ == "__main__":
    logging.info("Script execution started")
    hotkey_thread = threading.Thread(target=monitor_hotkeys, daemon=True)
    hotkey_thread.start()
    try:
        main_script()
    except Exception as e:
        logging.error(f"Unhandled exception in main script: {e}")
    finally:
        halt_event.set()  # Ensure the halt event is set
        logging.info("Script execution completed")
        # Give some time for threads to clean up
        time.sleep(2)
        # Force exit to ensure all threads are terminated
        os._exit(0)
