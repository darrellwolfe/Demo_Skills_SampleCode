import os
import sys
import time
import queue
import psutil
import ctypes
import logging
import keyboard
import threading
import subprocess
import pandas as pd
import tkinter as tk
from tkinter import ttk
import pyautogui as pag
import pygetwindow as gw
from tkinter import filedialog
from tkinter import messagebox
from pynput import keyboard as pynput_keyboard

def setup_logging():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    log_file = os.path.join(script_dir, "SalesInfoUpdater.log")
    log_format = '%(asctime)s - %(levelname)s - %(message)s'
    date_format = '%H:%M:%S'

    try:
        logging.basicConfig(
            filename=log_file,
            level=logging.INFO,
            format=log_format,
            datefmt=date_format
        )
        logging.info(f"Logging to file set up successfully: {log_file}")
    except Exception as e:
        print(f"Failed to set up file logging: {e}")
    
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
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

    logging.info("ProVal process not found, attempting to start it.")
    try:
        subprocess.Popen(PROVAL_PATH)
        logging.info("ProVal started successfully.")
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
                proval_window.maximize()
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
    batch_size = None
    root = tk.Tk()
    root.title("Select Batch Size")
    root.attributes('-topmost', True)
    root.focus_force()

    label = tk.Label(root, text="Select batch size (0-100, 0 for all records):")
    label.pack(pady=10)

    scale = tk.Scale(root, from_=0, to=100, orient=tk.HORIZONTAL, length=300, tickinterval=10, resolution=1)
    scale.set(25)
    scale.pack(pady=20)

    def on_ok():
        global block_input
        nonlocal batch_size
        batch_size = scale.get()
        block_input = False
        root.destroy()

    ok_button = tk.Button(root, text="OK", command=on_ok)
    ok_button.pack(pady=10)

    root.bind('<Return>', lambda event: on_ok())

    def on_closing():
        logging.warning("Batch size selection window closed without selection.")
        global block_input
        block_input = False
        root.destroy()

    root.protocol("WM_DELETE_WINDOW", on_closing)

    root.mainloop()

    if not block_input:
        return batch_size
    else:
        logging.error("Batch size selection was cancelled.")
        return None

def get_line_of_sale():
    """Get the line of sale selection using Tkinter GUI with a skip option."""
    logging.info("Prompting for line of sale")
    global block_input
    block_input = True

    if not focus_proval_window('ProVal'):
        logging.error("Could not focus ProVal window before line of sale selection.")
        block_input = False
        return None

    result_queue = queue.Queue()

    def create_window():
        root = tk.Tk()
        root.title("Line of Sale")
        root.attributes('-topmost', True)

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

    threading.Thread(target=create_window).start()

    result = result_queue.get()
    block_input = False

    if result in ['skip', 'exit']:
        if focus_proval_window('Update Sales Transaction Information'):
            pag.hotkey('alt', 'f4')
        focus_proval_window('ProVal')
        if result == 'skip':
            logging.info("Record skipped by user.")
        else:
            logging.info("User exited line of sale selection.")
        return None

    if not focus_proval_window('Update Sales Transaction Information'):
        logging.error("Could not focus 'Update Sales Transaction Information' window after line selection.")
        return None

    return result

def select_file(title, filetypes):
    """Open a file dialog to select a file."""
    root = tk.Tk()
    root.withdraw()
    root.attributes('-topmost', True)
    root.focus_force()

    def on_closing():
        logging.warning("File selection window closed without selection.")
        root.destroy()

    root.protocol("WM_DELETE_WINDOW", on_closing)

    file_path = filedialog.askopenfilename(title=title, filetypes=filetypes)

    if not file_path:
        logging.error("File selection was cancelled.")
        return None

    root.destroy()
    return file_path


def save_file(title, filetypes):
    """Open a file dialog to specify a save location."""
    root = tk.Tk()
    root.withdraw()
    root.attributes('-topmost', True)
    root.focus_force()
 
    def on_closing():
        logging.warning("File selection window closed without selection.")
        root.destroy()

    root.protocol("WM_DELETE_WINDOW", on_closing)

    file_path = filedialog.asksaveasfilename(title=title, filetypes=filetypes, defaultextension=".xlsx")

    if not file_path:
        logging.error("File selection was cancelled.")
        return None

    root.destroy()
    return file_path

def monitor_hotkeys(df, output_path):
    """Monitor for the halt hotkey to stop the script and save progress."""
    def on_halt():
        logging.info("Halt hotkey pressed. Saving progress and stopping script.")
        save_progress(df, output_path)
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
        ctypes.windll.user32.keybd_event(0x14, 0, 0, 0)
        ctypes.windll.user32.keybd_event(0x14, 0, 0x0002, 0)

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
            for _ in range(30):
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

def is_valid_excel(file_path):
    try:
        pd.read_excel(file_path, engine='openpyxl')
        return True
    except Exception as e:
        logging.error(f"Invalid Excel file: {e}")
        return False

def prompt_user_continue_or_skip():
    """Prompt the user to continue, skip, or indicate that sales data has already been entered."""
    global block_input
    block_input = True
    result_queue = queue.Queue()

    def create_window():
        root = tk.Tk()
        root.title("Continue or Skip")
        root.attributes('-topmost', True)

        def set_value(value):
            result_queue.put(value)
            root.quit()

        def on_closing():
            set_value('exit')

        tk.Label(root, text="Do you want to continue entering sales data?").pack(pady=10)
        tk.Button(root, text="Continue", command=lambda: set_value('continue')).pack(fill=tk.X)
        tk.Button(root, text="Already Entered", command=lambda: set_value('already_entered')).pack(fill=tk.X)

        root.protocol("WM_DELETE_WINDOW", on_closing)
        root.mainloop()
        root.destroy()

    threading.Thread(target=create_window).start()

    result = result_queue.get()
    block_input = False
    return result

def save_progress(df, output_path):
    df.to_excel(output_path, index=False, engine='openpyxl')
    logging.info(f"Progress saved to {output_path}")

class StatusWindow:
    def __init__(self, master, total_records, remaining_records, batch_size):
        self.master = master
        master.title("Script Status")
        master.geometry("270x200")
        master.attributes('-topmost', True)

        screen_width = master.winfo_screenwidth()
        master.geometry(f"+{screen_width - 280}+10")

        self.current_batch = tk.StringVar()
        self.remaining_batches = tk.StringVar()
        self.current_record = tk.StringVar()
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

        self.save_flag = False
        self.kill_flag = False
        self.total_records = total_records
        self.remaining_records = remaining_records
        self.records_in_current_batch = 1
        self.current_batch_number = 1
        self.batch_size = batch_size
        self.processed_count = 0
        self.records_in_current_batch = 1
        self.processed_count = 0

        self.update_status("Ready to start processing")

    def save_progress(self):
        self.save_flag = True
        self.update_status("Saving progress...")

    def update_status(self, status):
        remaining_batches = (self.remaining_records + self.batch_size - 1) // self.batch_size
        self.current_batch.set(f"{self.current_batch_number}")
        self.remaining_batches.set(str(remaining_batches))
        self.current_record.set(f"{self.records_in_current_batch}/{min(self.batch_size, self.remaining_records + self.records_in_current_batch - 1)}")
        self.total_processed.set(str(self.processed_count))
        self.total_left.set(str(self.remaining_records))
        self.status.set(status)
        self.master.update()

    def next_batch(self):
        self.current_batch_number += 1
        self.records_in_current_batch = 1
        self.update_status("Starting new batch...")
    
    def increment_processed(self):
        self.processed_count += 1
        self.remaining_records -= 1
        self.update_status("Processing...")

    def kill_script(self):
        self.kill_flag = True
        self.save_flag = True
        self.status.set("Killing script...")
        self.master.update()
        logging.info("Kill script requested by user. Saving.")
        self.save_progress()
        halt_event.set()
        self.master.after(1000, self.master.destroy)

def main_script():
    global initial_caps_lock_state, block_input

    toggle_caps_lock(False)

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

    logging.info("Loading Excel file...")
    df = pd.read_excel(excel_path)
    logging.info(f"Excel file loaded. Total records: {len(df)}")

    df['AIN'] = df['AIN'].astype(str).str.replace('.0', '', regex=False)
    df['AIN/Tax Bill'] = df['AIN/Tax Bill'].astype(str).str.replace('.0', '', regex=False)

    if 'Status' not in df.columns:
        df['Status'] = ''

    records_to_process = df[
        (df['Status'].isna()) | 
        (df['Status'] == 'Skipped or exited by user') | 
        (df['Status'].str.startswith('Error:', na=False))
    ]
    remaining_records = len(records_to_process)
    processed_count = len(df) - remaining_records

    logging.info(f"Total records: {len(df)}, Records to process: {remaining_records}")
    logging.info(f"Initial processed_count: {processed_count}")

    df.to_excel(output_path, index=False, engine='openpyxl')
    logging.info(f"Updated output file saved: {output_path}")

    batch_size = get_batch_size()
    if batch_size is None:
        logging.error("Batch size selection was cancelled.")
        return
    elif batch_size == 0:
        batch_size = remaining_records
    
    root = tk.Tk()
    status_window = StatusWindow(root, len(df), remaining_records, batch_size)
    status_window.update_status("Ready to start processing")

    hotkey_thread = threading.Thread(target=monitor_hotkeys, args=(df, output_path), daemon=True)
    hotkey_thread.start()

    try:
        for batch_start in range(0, len(records_to_process), batch_size):
            batch_end = min(batch_start + batch_size, len(records_to_process))
            current_batch = records_to_process.iloc[batch_start:batch_end]
        
            status_window.update_status(f"Processing batch {status_window.current_batch_number}")
            status_window.records_in_current_batch = 1

            for index, row in current_batch.iterrows():
                if halt_event.is_set() or status_window.kill_flag:
                    raise StopIteration("User requested termination")

                if status_window.save_flag:
                    save_progress(df, output_path)
                    status_window.save_flag = False

                processed_count += 1
                excel_row = df.index.get_loc(index) + 2
                logging.info(f"Starting to process Excel row {excel_row} (Log Record {processed_count})")

                if not focus_proval_window('ProVal'):
                    record_status = "Error: ProVal window not found or could not be focused."
                    df.at[index, 'Status'] = record_status
                    status_window.update_status(record_status)
                    continue

                AIN_value = row.get('AIN', row.get('AIN/Tax Bill', None))
                Sales = row.get('Sold Price', None)
                Comment = "MLS"

                logging.info(f"Record {processed_count}: Processing AIN: {AIN_value}")

                try:
                    pag.hotkey('ctrl', 'o')
                    pag.sleep(1)

                    if processed_count <= 1:
                        pag.press('up', presses=11, interval=0.01)
                        pag.press('down', presses=4, interval=0.01)
                        pag.press('tab')
                    else:
                        pag.press('tab')

                    ain_str = str(int(float(AIN_value))).zfill(6)
                    logging.info(f"Record {processed_count}: About to input AIN: {ain_str}")
                    pag.write(ain_str)
                    logging.info(f"Record {processed_count}: Finished inputting AIN")
                    pag.press('enter')
                    pag.sleep(1)

                    pag.hotkey('alt', 'a', 'p', interval=0.25)

                    line_of_sale = get_line_of_sale()
                    if line_of_sale is None:
                        record_status = "Skipped or exited by user"
                        df.at[index, 'Status'] = record_status
                        status_window.update_status(record_status)
                        continue

                    record_status = input_sales_data(line_of_sale, Sales, Comment, processed_count)
                    logging.info(f"Record {processed_count}: {record_status}")

                except Exception as e:
                    logging.error(f"Record {processed_count}: Error - {e}")
                    record_status = f"Error: {str(e)}"

                finally:
                    df.at[index, 'Status'] = record_status
                    status_window.increment_processed()
                    status_window.records_in_current_batch += 1
                    status_window.update_status(record_status)

            status_window.update_status(f"Completed batch {status_window.current_batch_number}")

            if batch_end < len(records_to_process):
                user_continue = messagebox.askyesno("Batch Complete", f"Batch {status_window.current_batch_number} processing complete. Continue to next batch?")
                if not user_continue:
                    logging.info("User chose to stop after completing a batch.")
                    break

            if not ensure_proval_ready():
                logging.error("Failed to prepare ProVal for next batch. Exiting script.")
                break

            save_progress(df, output_path)
            logging.info(f"Updated output file after processing batch {status_window.current_batch_number}")
            status_window.next_batch()
        else:
            logging.info("All batches completed.")

    except StopIteration as e:
        logging.info(f"Script stopped: {str(e)}")
    except Exception as e:
        logging.error(f"An unexpected error occurred: {str(e)}")
    finally:
        save_progress(df, output_path)

        if 'status_window' in locals() and hasattr(status_window, 'master'):
            status_window.master.destroy()

    toggle_caps_lock(initial_caps_lock_state)

def input_sales_data(line_of_sale, Sales, Comment, processed_count):
    logging.info(f"Inputting sales data for line of sale: {line_of_sale}")
    
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
    else:
        logging.error(f"Invalid line of sale: {line_of_sale}")
        return "Error: Invalid line of sale"

    pag.hotkey('alt', 'e')

    user_choice = prompt_user_continue_or_skip()

    if user_choice == 'already_entered':
        logging.info(f"Record {processed_count}: User indicated sales data already entered.")
        record_status = "Already Entered by user"
        focus_proval_window('Update Sales Transaction Information')
        pag.press('tab', presses=38, interval=0.01)
        pag.press('enter')
        pag.sleep(1)
        pag.press('tab', presses=2)
        pag.press('enter')
        return record_status
    elif user_choice == 'exit':
        logging.info(f"Record {processed_count}: User exited the prompt.")
        return "Exited by user"

    pag.press('tab', presses=17, interval=0.01)
    logging.info(f"Inputting Sales value: {Sales}")
    pag.write(str(Sales))

    pag.press('tab', presses=18, interval=0.01)
    logging.info(f"Inputting Comment: {Comment}")
    pag.write(Comment)
    pag.press('tab', presses=2, interval=0.01)
    pag.press('enter')
    pag.sleep(1)
    pag.press('tab')
    pag.press('enter')
    pag.hotkey('ctrl', 's')
    pag.sleep(1)

    logging.info("Sales data input completed")
    return "Entered Successfully"

if __name__ == "__main__":
    logging.info("Script execution started")
    main_script()
    logging.info("Script execution completed")
    time.sleep(1)