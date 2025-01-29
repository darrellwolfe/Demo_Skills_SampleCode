import time
import psutil
import logging
import keyboard
import textwrap
import win32gui
import win32con
import subprocess
import pandas as pd
import tkinter as tk
import win32com.client
import pyautogui as pag
from pathlib import Path
from datetime import datetime
from tkinter import filedialog, ttk

home_dir = Path.home()
log_dir = home_dir / "PermitDeactivator"
log_dir.mkdir(parents=True, exist_ok=True)
ProVal_path = "C:/Program Files (x86)/Thomson Reuters/ProVal/ProVal.exe"

current_time = datetime.now().strftime("%Y%m%d_%H%M%S")
log_file = log_dir / f"PermitDeactivator{current_time}.log"
logging.basicConfig(filename=str(log_file), level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

# Add a global variable to track if the script should be terminated
terminate_script = False

# Add a function to handle the kill switch
def kill_switch():
    global terminate_script
    terminate_script = True
    print("Kill switch activated. Terminating script...")
    logging.info("Kill switch activated. Terminating script...")

# Set up the kill switch listener
keyboard.add_hotkey('esc', kill_switch)

def get_proval_pid():
    logging.info("Checking for ProVal process")
    for proc in psutil.process_iter(['pid', 'name', 'exe']):
        try:
            if proc.info['exe'] and Path(proc.info['exe']).resolve() == Path(ProVal_path).resolve():
                print(f"ProVal process found with PID: {proc.info['pid']}")
                logging.info(f"ProVal process found with PID: {proc.info['pid']}")
                return proc.info['pid']
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    print("ProVal process not found")
    logging.info("ProVal process not found")
    return None

def ensure_proval_ready():
    logging.info("Ensuring ProVal is ready...")
    proval_pid = get_proval_pid()
    if not proval_pid:
        print("ProVal not running. Attempting to start ProVal.")
        logging.info("ProVal not running. Attempting to start ProVal.")
        try:
            subprocess.Popen(ProVal_path)
            print("ProVal started successfully.")
            logging.info("ProVal started successfully.")
            time.sleep(10)  # Wait for ProVal to start
        except Exception as e:
            print(f"Error starting ProVal: {e}")
            logging.error(f"Error starting ProVal: {e}")
            return False
    
    print("Waiting for ProVal window to open...")
    logging.info("Waiting for ProVal window to open...")
    time.sleep(2)  # Add a 2-second delay before attempting to focus

    print("Attempting to focus ProVal window...")
    logging.info("Attempting to focus ProVal window...")
    return focus_proval_window('ProVal')

def focus_proval_window(window_title, max_attempts=10):
    print(f"Attempting to focus ProVal window with title '{window_title}'")
    logging.info(f"Attempting to focus ProVal window with title '{window_title}'")
    
    for attempt in range(max_attempts):
        try:
            proval_pid = get_proval_pid()
            if not proval_pid:
                print("ProVal process not found.")
                logging.error("ProVal process not found.")
                return False

            hwnd = win32gui.FindWindow(None, window_title)
            if hwnd == 0:
                print(f"ProVal window '{window_title}' not found. Attempt {attempt + 1}/{max_attempts}")
                logging.warning(f"ProVal window '{window_title}' not found. Attempt {attempt + 1}/{max_attempts}")
                time.sleep(2)
                continue

            shell = win32com.client.Dispatch("WScript.Shell")
            shell.SendKeys('%')
            win32gui.SetForegroundWindow(hwnd)
            win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)

            print(f"ProVal window '{window_title}' is confirmed as active and maximized.")
            logging.info(f"ProVal window '{window_title}' is confirmed as active and maximized.")
            return True

        except Exception as e:
            print(f"Error focusing ProVal window: {e}")
            logging.error(f"Error focusing ProVal window: {e}")
    
    print(f"Failed to find or activate ProVal window '{window_title}' after {max_attempts} attempts.")
    logging.error(f"Failed to find or activate ProVal window '{window_title}' after {max_attempts} attempts.")
    return False

def select_input_file():
    print("Prompting user to select input file...")
    logging.info("Prompting user to select input file...")
    root = tk.Tk()
    root.withdraw()
    root.attributes('-topmost', True)  # Make the dialog appear on top
    file_path = filedialog.askopenfilename(
        title="Select Input Excel File",
        filetypes=[("Excel files", "*.xlsx;*.xls"), ("All files", "*.*")]
    )
    if file_path:
        print(f"User selected input file: {file_path}")
        logging.info(f"User selected input file: {file_path}")
    else:
        print("User cancelled file selection")
        logging.info("User cancelled file selection")
    return file_path

def select_permit_gui(record_data):
    result = [None]
    def on_button_click(choice):
        result[0] = choice
        root.quit()

    root = tk.Tk()
    root.title("Select Permit Number")
    root.attributes('-topmost', True)

    frame = ttk.Frame(root, padding="10")
    frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
    root.columnconfigure(0, weight=1)
    root.rowconfigure(0, weight=1)

    for i, (key, value) in enumerate(record_data.items()):
        if key == "Address" and len(value) > 50:
            wrapped_value = textwrap.fill(value, width=50)
            ttk.Label(frame, text=f"{key}:").grid(column=0, row=i, sticky=tk.W)
            ttk.Label(frame, text=wrapped_value, wraplength=350).grid(column=0, row=i+1, sticky=tk.W, padx=(20, 0))
        else:
            ttk.Label(frame, text=f"{key}: {value}").grid(column=0, row=i, sticky=tk.W)

    ttk.Label(frame, text="\nSelect the permit number:").grid(column=0, row=len(record_data), sticky=tk.W, pady=(10, 5))
    
    for i in range(1, 11):
        ttk.Button(frame, text=str(i), command=lambda x=i: on_button_click(x)).grid(column=0, row=len(record_data)+i, padx=2, pady=2, sticky='ew')
    
    ttk.Button(frame, text="Skip", command=lambda: on_button_click("Skip")).grid(column=0, row=len(record_data)+11, padx=2, pady=2, sticky='ew')
    ttk.Button(frame, text="Already Worked", command=lambda: on_button_click("Already Worked")).grid(column=0, row=len(record_data)+12, padx=2, pady=2, sticky='ew')

    root.update_idletasks()
    window_width = root.winfo_reqwidth()
    window_height = root.winfo_reqheight()
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    x = (screen_width // 2) - (window_width // 2)
    y = (screen_height // 2) - (window_height // 2)
    root.geometry(f'+{x}+{y}')

    root.mainloop()
    root.destroy()
    return result[0]

def calculate_permit_coordinates(base_x, base_y, permit_number):
    y_offset = (permit_number - 1) * 22  # 22 pixels between each permit
    return base_x, base_y + y_offset

def load_excel_data(file_path):
    logging.info(f"Attempting to load Excel data from {file_path}")
    try:
        df = pd.read_excel(file_path)
        logging.info(f"Successfully loaded data from {file_path}")
        return df
    except Exception as e:
        logging.error(f"Error loading Excel file: {str(e)}")
        return None

def deactivate_records(df, deactivate_column):
    try:
        df[deactivate_column] = 0
        logging.info(f"Deactivated {len(df)} records")
        return df
    except Exception as e:
        logging.error(f"Error deactivating records: {str(e)}")
        return None

def save_excel_data(df, output_file):
    logging.info(f"Attempting to save Excel data to {output_file}")
    try:
        df.to_excel(output_file, index=False)
        logging.info(f"Successfully saved deactivated records to {output_file}")
    except Exception as e:
        logging.error(f"Error saving Excel file: {str(e)}")

def process_record(ain, permit_number):
    logging.info(f"Processing record with AIN: {ain}, Permit Number: {permit_number}")
    if not ensure_proval_ready():
        logging.error("Failed to prepare ProVal. Skipping record.")
        return False

    try:        
        logging.info("Sending Ctrl+O hotkey")
        pag.hotkey('ctrl', 'o')
        time.sleep(1)
        logging.info("Pressing Tab key")
        pag.press('tab')
        ain_str = str(int(float(ain))).zfill(6)
        logging.info(f"About to input AIN: {ain_str}")
        pag.write(ain_str)
        pag.press('enter')
        time.sleep(3)
        
        # Prepare record data for display
        record_data = {
            "AIN": ain_str,
            "Permit Number": permit_number
        }

        # Prompt user for permit selection using GUI
        logging.info("Prompting user for permit selection")
        selected_permit = select_permit_gui(record_data)
        logging.info(f"User selected: {selected_permit}")

        if selected_permit == 'Skip':
            logging.info("User chose to skip this record.")
            return 'skip'
        elif selected_permit == 'Already Worked':
            logging.info("User indicated this record has already been worked.")
            return 'already_worked'
        elif selected_permit is None:
            logging.info("User cancelled permit selection.")
            return False

        selected_permit = int(selected_permit)

        # Calculate coordinates for the selected permit
        base_permit_x = 135  # Adjust these values based on your screen
        base_permit_y = 200  # Adjust these values based on your screen
        permit_x, permit_y = calculate_permit_coordinates(base_permit_x, base_permit_y, selected_permit)

        # Click on the selected permit
        pag.click(x=permit_x, y=permit_y)
        time.sleep(1)
        
        # Click to deactivate the highlighted permit
        logging.info("Clicking to deactivate permit")
        pag.click(x=135, y=920)
        time.sleep(1)  # Wait for the click to register

        # Save the record
        logging.info("Saving the record")
        pag.hotkey('ctrl', 's')
        time.sleep(1)  # Wait for the save operation to complete

        logging.info(f"Successfully processed AIN: {ain_str}")
        return True
    except Exception as e:
        logging.error(f"Error processing AIN {ain}: {str(e)}")
        return False

def main():
    print("Starting record deactivation process")
    logging.info("Starting record deactivation process")
    print(f"Log directory: {log_dir}")
    print(f"Log file: {log_file}")
    logging.info(f"Log directory: {log_dir}")
    logging.info(f"Log file: {log_file}")

    print("Ensuring ProVal is ready...")
    if not ensure_proval_ready():
        print("Failed to prepare ProVal. Exiting script.")
        logging.error("Failed to prepare ProVal. Exiting script.")
        return

    print("Selecting input file...")
    input_file = select_input_file()
    if not input_file:
        print("No input file selected. Exiting.")
        logging.error("No input file selected. Exiting.")
        return

    output_file = log_dir / f'Records_Deactivated_{current_time}.xlsx'
    deactivate_column = 'Active'  # Replace with your actual column name for active/inactive status

    print("Loading Excel data...")
    df = load_excel_data(input_file)
    if df is None:
        print("Failed to load Excel data. Exiting.")
        logging.error("Failed to load Excel data. Exiting.")
        return

    print("Available columns in the Excel file:")
    print(df.columns.tolist())
    logging.info(f"Available columns: {df.columns.tolist()}")

    # Check if required columns exist
    required_columns = ['AIN', 'Permit Number']
    missing_columns = [col for col in required_columns if col not in df.columns]
    if missing_columns:
        print(f"Error: The following required columns are missing: {missing_columns}")
        logging.error(f"Missing required columns: {missing_columns}")
        return

    print("Processing records...")
    logging.info("Processing records...")
    processed_count = 0
    skipped_count = 0
    already_worked_count = 0
    error_count = 0
    for index, row in df.iterrows():
        if terminate_script:
            print("Script terminated by user.")
            logging.info("Script terminated by user.")
            break
        ain = row['AIN']
        permit_number = row['Permit Number']
        active_status = row[deactivate_column]
        
        print(f"Processing record {index + 1}/{len(df)}")
        logging.info(f"Processing record {index + 1}/{len(df)} - AIN: {ain}, Permit Number: {permit_number}, Active Status: {active_status}")
        
        if active_status == 0:
            skipped_count += 1
            print(f"Automatically skipped AIN: {ain} (Already inactive)")
            logging.info(f"Automatically skipped AIN: {ain} (Already inactive)")
            continue
        
        result = process_record(ain, permit_number)
        if result == True:
            df.at[index, deactivate_column] = 0
            processed_count += 1
            print(f"Successfully processed AIN: {ain}")
            logging.info(f"Successfully processed AIN: {ain}")
        elif result == 'skip':
            skipped_count += 1
            print(f"User chose to skip AIN: {ain}")
            logging.info(f"User chose to skip AIN: {ain}")
        elif result == 'already_worked':
            already_worked_count += 1
            df.at[index, deactivate_column] = 0
            print(f"AIN: {ain} has already been worked")
            logging.info(f"AIN: {ain} marked as already worked")
        else:
            print(f"Failed to process AIN: {ain}")
            logging.warning(f"Failed to process AIN: {ain}")
            error_count += 1
    
    print("Finished processing records")
    logging.info("Finished processing records")
    print(f"Processed: {processed_count}, Skipped: {skipped_count}, Already Worked: {already_worked_count}, Errors: {error_count}")
    logging.info(f"Processed: {processed_count}, Skipped: {skipped_count}, Already Worked: {already_worked_count}, Errors: {error_count}")

    if processed_count > 0:
        save_excel_data(df, str(output_file))
    
    print("Record deactivation process completed")
    logging.info("Record deactivation process completed")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        logging.exception("An unexpected error occurred")
    finally:
        print("Script execution finished. Check the log file for details.")
        logging.info("Script execution finished")