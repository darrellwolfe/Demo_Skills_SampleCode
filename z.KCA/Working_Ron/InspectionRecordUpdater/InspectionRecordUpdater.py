import os
import re
import cv2
import time
import ctypes
import psutil
import pyodbc
import logging
import pyautogui
import pytesseract
import numpy as np
import configparser
import tkinter as tk
import pygetwindow as gw
from tkcalendar import Calendar
from pywinauto import Application
from datetime import datetime, date
from tkinter import ttk, messagebox, scrolledtext

conn_str = (
    "DRIVER={SQL Server};"
    "SERVER=AsTxDBProd;"
    "DATABASE=GRM_Main;"
    "Trusted_Connection=yes;"
)

user_home_dir = os.environ.get('USERPROFILE') or os.environ.get('HOME')

# Define the log directory and file based on the user's home directory
log_dir = os.path.join(str(user_home_dir), 'InspectionRecordUpdater')
log_file = os.path.join(log_dir, 'InspectionRecordUpdater.log')

# Ensure the log directory exists
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

logging.basicConfig(
    filename=log_file,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

roaming_dir = os.path.join(os.environ.get('APPDATA', ''), 'InspectionRecordUpdater')
if not os.path.exists(roaming_dir):
    os.makedirs(roaming_dir)

CONFIG_FILE = os.path.join(roaming_dir, 'config.ini')
DEFAULT_PROVAL_PATH = "C:/Program Files (x86)/Thomson Reuters/ProVal/ProVal.exe"
pytesseract.pytesseract.tesseract_cmd = r'C:\Users\rmason\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'

def create_default_config():
    config = configparser.ConfigParser()
    config['ProVal'] = {'executable_path': DEFAULT_PROVAL_PATH}
    with open(CONFIG_FILE, 'w') as configfile:
        config.write(configfile)
    logging.info(f"Created default configuration file at {CONFIG_FILE}")

config = configparser.ConfigParser()
if not os.path.exists(CONFIG_FILE):
    logging.warning(f"Configuration file {CONFIG_FILE} not found. Creating a default one.")
    create_default_config()

try:
    config.read(CONFIG_FILE)
    PROVAL_PATH = config.get('ProVal', 'executable_path')
except (configparser.NoSectionError, configparser.NoOptionError, FileNotFoundError) as e:
    logging.error(f"Configuration error: {e}")
    PROVAL_PATH = DEFAULT_PROVAL_PATH

class ProValUpdater:
    def __init__(self, root):
        self.root = root
        self.proval_path = PROVAL_PATH
        self.proval_window_handle = None
        self.pin_ain_var = tk.StringVar(value="PIN")
        self.previous_selection = None
        self.memo_area = None  # Will be set in set_memo_area method
        self.status_window = None
        self.setup_ui()
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        
        # Set the window to be always on top by default
        self.root.attributes('-topmost', True)
        self.is_topmost = True

    def create_status_window(self):
        if self.status_window is None or not self.status_window.winfo_exists():
            self.status_window = tk.Toplevel(self.root)
            self.status_window.title("Processing Status")
            self.status_window.geometry("300x100")
            self.status_label = ttk.Label(self.status_window, text="", justify=tk.LEFT)
            self.status_label.pack(pady=20, padx=10, fill=tk.BOTH, expand=True)
            self.status_window.attributes('-topmost', self.is_topmost)
            self.status_window.withdraw()  # Hide the window initially

    def position_status_window(self):
        if self.status_window:
            select_memo_window = gw.getWindowsWithTitle('Select Memo')
            if select_memo_window:
                x = select_memo_window[0].left + select_memo_window[0].width
                y = select_memo_window[0].top
                self.status_window.geometry(f"+{x}+{y}")

    def get_proval_pid(self):
        """Get the PID of the ProVal process."""
        for proc in psutil.process_iter(['pid', 'name', 'exe']):
            try:
                if proc.info['exe'] and os.path.normpath(proc.info['exe']) == os.path.normpath(self.proval_path):
                    return proc.info['pid']
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass
        return None

    def focus_proval(self):
        logging.debug("Attempting to focus ProVal window...")
        try:
            proval_pid = self.get_proval_pid()
            if not proval_pid:
                logging.debug("ProVal process not found.")
                return False

            app = Application().connect(process=proval_pid)
            proval_windows = app.windows(title_re='ProVal', found_index=0)
            if proval_windows:
                self.proval_window_handle = proval_windows[0]
                logging.debug(f"Found ProVal window: {self.proval_window_handle}")
                self.proval_window_handle.set_focus()
                time.sleep(0.5)
                if self.proval_window_handle.has_focus():
                    logging.debug("ProVal window is confirmed as active.")
                    return True
                else:
                    logging.debug("Failed to activate ProVal window.")
                    return False
            else:
                logging.debug("ProVal window not found.")
                return False
        except Exception as e:
            logging.error(f"Error focusing ProVal window: {e}")
            return False

    def validate_initials(self, action, value_if_allowed):
        if action == '1':
            if len(value_if_allowed) > 3:
                return False
            return value_if_allowed.isupper() and value_if_allowed.isalpha()
        return True

    def validate_initials_on_submit(self):
        initials = self.initials_entry.get()
        if len(initials) != 3 or not initials.isupper() or not initials.isalpha():
            messagebox.showerror("Invalid Input", "Initials must be exactly three uppercase letters.")
            return False
        return True

    def validate_dates(self):
        today = date.today()
        try:
            inspection_date = datetime.strptime(self.inspection_cal.get_date(), '%m/%d/%Y').date()
            appraisal_date = datetime.strptime(self.appraisal_cal.get_date(), '%m/%d/%Y').date()
        except ValueError as e:
            logging.error(f"Date parsing error: {e}")
            messagebox.showerror("Invalid Date Format", "Please enter a valid date.")
            return False

        if inspection_date > today:
            messagebox.showerror("Invalid Date", "Inspection date cannot be in the future.")
            return False
        if appraisal_date > today:
            messagebox.showerror("Invalid Date", "Appraisal date cannot be in the future.")
            return False
        return True

    def setup_ui(self):
        self.root.title("Inspection Record Updater")
        vcmd = (self.root.register(self.validate_initials), '%d', '%P')

        ttk.Label(self.root, text="Select Input Type:").grid(row=0, column=0, padx=10, pady=5, sticky="w")
        ttk.Radiobutton(self.root, text="AIN", variable=self.pin_ain_var, value="AIN").grid(row=0, column=1, padx=10, pady=5, sticky="w")
        ttk.Radiobutton(self.root, text="PIN", variable=self.pin_ain_var, value="PIN").grid(row=0, column=2, padx=10, pady=5, sticky="w")
        self.pin_ain_var.set("AIN")

        ttk.Label(self.root, text="Initials:").grid(row=1, column=0, padx=10, pady=5, sticky="w")
        self.initials_entry = ttk.Entry(self.root, validate='key', validatecommand=vcmd)
        self.initials_entry.grid(row=1, column=1, columnspan=2, padx=10, pady=5, sticky="w")

        ttk.Label(self.root, text="Inspection Date:").grid(row=2, column=0, padx=10, pady=5, sticky="w")
        self.inspection_cal = Calendar(self.root, date_pattern='mm/dd/yyyy')
        self.inspection_cal.grid(row=2, column=1, columnspan=2, padx=10, pady=5)

        self.null_inspection_date_var = tk.BooleanVar()
        self.inspection_null_checkbox = ttk.Checkbutton(self.root, text="NULL Inspection Date", variable=self.null_inspection_date_var, command=self.toggle_inspection_entry)
        self.inspection_null_checkbox.grid(row=3, column=0, columnspan=3, padx=10, pady=5, sticky="w")

        ttk.Label(self.root, text="Appraisal Date:").grid(row=4, column=0, padx=10, pady=5, sticky="w")
        self.appraisal_cal = Calendar(self.root, date_pattern='mm/dd/yyyy')
        self.appraisal_cal.grid(row=4, column=1, columnspan=2, padx=10, pady=5)

        self.null_appraisal_date_var = tk.BooleanVar()
        self.appraisal_null_checkbox = ttk.Checkbutton(self.root, text="NULL Appraisal Date", variable=self.null_appraisal_date_var, command=self.toggle_appraisal_entry)
        self.appraisal_null_checkbox.grid(row=5, column=0, columnspan=3, padx=10, pady=5, sticky="w")

        ttk.Label(self.root, text="Data Source:").grid(row=6, column=0, padx=10, pady=5, sticky="w")
        self.data_source_var = tk.StringVar()
        self.data_source_dropdown = ttk.Combobox(self.root, textvariable=self.data_source_var, state='readonly')
        self.data_source_dropdown['values'] = ('Exterior Field Inspect', 'Builder - Contractor', 'Complete Refusal', 'Estimated', 'Gate Closed', 'Interior Inspected', 'Mobile Home', 'Owner Information', 'Posted No Tresspassing', 'Sale / Listing Information', 'Tenant Information', 'Vacant')
        self.data_source_dropdown.current(0)
        self.data_source_dropdown.grid(row=6, column=1, columnspan=2, padx=10, pady=5, sticky="w")

        ttk.Label(self.root, text="Select Parcel Set ID:").grid(row=7, column=0, padx=10, pady=5, sticky="w")
        self.parcel_set_id_var = tk.StringVar()
        self.parcel_set_dropdown = ttk.Combobox(self.root, textvariable=self.parcel_set_id_var, state='readonly')
        self.parcel_set_dropdown.grid(row=7, column=1, columnspan=2, padx=10, pady=5, sticky="w")
        self.populate_parcel_set_dropdown()
        self.parcel_set_dropdown.bind("<<ComboboxSelected>>", self.on_parcel_set_selected)

        ttk.Label(self.root, text="Records (one per line):").grid(row=8, column=0, columnspan=3, padx=10, pady=5, sticky="w")
        self.records_text = scrolledtext.ScrolledText(self.root, width=40, height=10)
        self.records_text.grid(row=9, column=0, columnspan=3, padx=10, pady=5)

        self.update_button = ttk.Button(self.root, text="Update Records", command=self.update_records_batch)
        self.update_button.grid(row=10, column=0, columnspan=3, padx=10, pady=5)

        # Add the toggle button for always on top
        self.topmost_button = ttk.Button(self.root, text="Disable Always on Top", command=self.toggle_topmost)
        self.topmost_button.grid(row=11, column=0, columnspan=3, padx=10, pady=5)

    def populate_parcel_set_dropdown(self):
        try:
            connection = pyodbc.connect(conn_str)
            cursor = connection.cursor()
            cursor.execute("SELECT DISTINCT set_id FROM Parcel_set")
            parcel_set_ids = [row[0] for row in cursor.fetchall()]
            self.parcel_set_dropdown['values'] = parcel_set_ids
        except Exception as e:
            logging.error(f"Error populating Parcel Set dropdown: {e}")
            messagebox.showerror("Database Error", f"Could not retrieve Parcel Set IDs: {e}")
        finally:
            if connection:
                connection.close()

    def on_parcel_set_selected(self, event=None):
        selected_id = self.parcel_set_id_var.get()
        self.fetch_lrsns_and_ains(selected_id)

    def fetch_lrsns_and_ains(self, parcel_set_id):
        try:
            connection = pyodbc.connect(conn_str)
            cursor = connection.cursor()
            cursor.execute("""
                SELECT TRIM(pm.AIN) AS AIN
                FROM parcel_set AS ps
                JOIN TSBv_PARCELMASTER AS pm ON ps.LRSN = pm.LRSN
                WHERE pm.EffStatus = 'A' AND ps.set_id = ?
                ORDER BY pm.AIN
            """, (parcel_set_id,))
            ains = cursor.fetchall()
            self.display_lrsns_ains(ains)
        except Exception as e:
            logging.error(f"Error fetching AINs: {e}")
            messagebox.showerror("Database Error", f"Could not retrieve AINs: {e}")
        finally:
            if connection:
                connection.close()

    def display_lrsns_ains(self, records):
        self.records_text.delete("1.0", tk.END)
        for ain in records:
            self.records_text.insert(tk.END, f"{ain[0]}\n")

    def toggle_inspection_entry(self):
        if self.null_inspection_date_var.get():
            self.inspection_cal.config(state=tk.DISABLED)
        else:
            self.inspection_cal.config(state=tk.NORMAL)

    def toggle_appraisal_entry(self):
        if self.null_appraisal_date_var.get():
            self.appraisal_cal.config(state=tk.DISABLED)
        else:
            self.appraisal_cal.config(state=tk.NORMAL)

    def toggle_topmost(self):
        self.is_topmost = not self.is_topmost
        self.root.attributes('-topmost', self.is_topmost)
        if self.status_window:
            self.status_window.attributes('-topmost', self.is_topmost)
        self.topmost_button.config(text="Disable Always on Top" if self.is_topmost else "Enable Always on Top")

    def update_records_batch(self):
        if not self.validate_initials_on_submit():
            return
        if not self.validate_dates():
            return

        records = self.records_text.get("1.0", tk.END).strip().split('\n')
        records = [record.strip() for record in records if record.strip()]
        if not records:
            messagebox.showerror("Invalid Input", "Please enter at least one PIN or AIN.")
            return

        try:
            self.root.grab_set()
            self.create_status_window()
            self.position_status_window()
            self.status_window.deiconify()

            logging.debug("Starting batch update...")
            caps_lock_on = ctypes.WinDLL("User32.dll").GetKeyState(0x14) & 0x0001
            if caps_lock_on:
                logging.debug("Caps Lock is on. Turning it off.")
                pyautogui.press('capslock')

            total_records = len(records)
            successful_updates = 0
            for index, record in enumerate(records, 1):
                self.status_label.config(text=f"Processing record {index} of {total_records}\n"
                                              f"Current record: {record}\n"
                                              f"Completed: {successful_updates}")
                self.status_window.update()
                try:
                    self.update_single_record(record)
                    successful_updates += 1
                except Exception as e:
                    logging.error(f"Error processing record {record}: {str(e)}")
                    messagebox.showerror("Error", f"Error processing record {record}: {str(e)}")
                    if messagebox.askyesno("Continue?", "An error occurred. Do you want to continue with the next record?"):
                        continue
                    else:
                        break

            messagebox.showinfo("Batch Update Complete", f"Processed {total_records} records.\n"
                                                         f"Successful updates: {successful_updates}\n"
                                                         f"Failed updates: {total_records - successful_updates}")
            logging.info(f"Batch update completed. Processed {total_records} records. "
                         f"Successful: {successful_updates}, Failed: {total_records - successful_updates}")
        except Exception as e:
            logging.error(f"Error in batch update: {e}")
            messagebox.showerror("Error", f"An error occurred during batch update: {e}")
        finally:
            if caps_lock_on:
                logging.debug("Turning Caps Lock back on.")
                pyautogui.press('capslock')
            if self.status_window and self.status_window.winfo_exists():
                self.status_window.withdraw()
            self.root.grab_release()

    def create_new_memo(self):
        logging.debug("Attempting to create new memo.")
        
        # Ensure the 'Select Memo' window is active
        select_memo_window = gw.getWindowsWithTitle('Select Memo')
        if select_memo_window:
            select_memo_window[0].activate()
            time.sleep(0.5)  # Wait for the window to become active
        else:
            logging.error("'Select Memo' window not found.")
            return

        # Navigate to the top of the list
        pyautogui.press('up', presses=20, interval=0.05)
        time.sleep(0.1)

        # Press enter to open the Memo ID window
        pyautogui.press('enter')
        time.sleep(0.1)

        # Ensure the 'Memo ID' window is active
        memo_id_window = gw.getWindowsWithTitle('Memo ID')
        if memo_id_window:
            memo_id_window[0].activate()
            time.sleep(0.5)  # Wait for the window to become active
        else:
            logging.error("'Memo ID' window not found.")
            return

        # Navigate to the first RY memo option
        pyautogui.press('r')
        time.sleep(0.5)
        
        # Move the New Memo window up
        new_memo_window = tk.Toplevel(self.root)
        new_memo_window.title("New Memo")
        new_memo_window.geometry("300x100")
        new_memo_window.attributes('-topmost', True)

        memo_id_window = gw.getWindowsWithTitle('Memo ID')
        if memo_id_window:
            x = memo_id_window[0].left
            y = memo_id_window[0].top - 150  # Move up by 150 pixels
            new_memo_window.geometry(f"+{x}+{y}")

        ttk.Label(new_memo_window, text="Create the new memo content in ProVal.").pack(pady=10)
        ttk.Button(new_memo_window, text="Done", command=new_memo_window.destroy).pack()

        self.root.wait_window(new_memo_window)

        # Allow user to create the memo content
        user_response = messagebox.askyesno("New Memo", "Create the new memo content in ProVal. Did you create a new memo?")
        
        if user_response:
            # Save and close the memo
            pyautogui.hotkey('ctrl', 's')
            time.sleep(0.5)
            pyautogui.hotkey('alt', 'f4')
            time.sleep(0.5)
            logging.debug("New memo created and saved.")
        else:
            logging.debug("User indicated no new memo was created.")
            # Close the memo window without saving
            pyautogui.hotkey('alt', 'f4')
            time.sleep(0.5)
            # Handle any "Do you want to save changes?" prompt
            save_prompt = gw.getWindowsWithTitle('ProVal')
            if save_prompt and "save changes" in save_prompt[0].title.lower():
                pyautogui.press('n')  # Press 'No' to discard changes
                time.sleep(0.5)

        logging.debug("Exiting create_new_memo function.")

    def open_existing_memo(self, selected_memo, memo_index):
        logging.debug(f"Opening existing memo: {selected_memo} at index {memo_index}")

        try:
            # Ensure the 'Select Memo' window is active
            select_memo_window = gw.getWindowsWithTitle('Select Memo')
            if select_memo_window:
                select_memo_window[0].activate()
                time.sleep(0.6)  # Wait for the window to become active
            else:
                logging.error("'Select Memo' window not found.")
                return
            
            # Navigate to the correct memo
            pyautogui.press('r')  # Jump to the top of the RY memos
            time.sleep(0.1)
            
            # Move down to the correct memo index
            for _ in range(memo_index):
                pyautogui.press('down')
                time.sleep(0.2)
            
            # Select the memo
            pyautogui.press('enter')
            time.sleep(0.5)
            
            # Find the 'Update Memo' window
            update_memo_window = gw.getWindowsWithTitle('Update Memo')
            if not update_memo_window:
                logging.error("'Update Memo' window not found.")
                return

            # Get the position and size of the 'Update Memo' window
            update_memo_rect = update_memo_window[0].box

            # Create and position the 'Edit Memo' window
            edit_memo_window = tk.Toplevel(self.root)
            edit_memo_window.title("Edit Memo")
            edit_memo_window.geometry(f"300x100+{update_memo_rect.left}+{update_memo_rect.top - 150}")
            edit_memo_window.attributes('-topmost', True)
            edit_memo_window.resizable(False, False)  # Disable resizing

            frame = ttk.Frame(edit_memo_window, padding="10 10 10 10")
            frame.pack(fill=tk.BOTH, expand=True)

            ttk.Label(frame, text=f"Append to the memo '{selected_memo}' in ProVal.").pack(pady=(0, 10))
            ttk.Button(frame, text="Done", command=edit_memo_window.destroy).pack()

            # Wait for the user to close the 'Edit Memo' window
            self.root.wait_window(edit_memo_window)

            logging.debug(f"User closed the Edit Memo window for {selected_memo}")

            # Ensure the 'Update Memo' window is active
            update_memo_window = gw.getWindowsWithTitle('Update Memo')
            if update_memo_window:
                update_memo_window[0].activate()
                time.sleep(0.5)  # Wait for the window to become active
            else:
                logging.debug(f"'Update Memo' window not found after editing. Assuming memo {selected_memo} was successfully edited and closed.")
                return
            
            pyautogui.hotkey('ctrl', 's')
            time.sleep(0.5)        
            pyautogui.hotkey('alt', 'f4')
            time.sleep(0.5)

            logging.debug(f"Successfully edited and saved memo: {selected_memo}")

        except Exception as e:
            logging.error(f"Error while editing memo {selected_memo}: {str(e)}")
            # Don't re-raise the exception, allow the process to continue with the next memo

    def on_closing(self):
        if self.status_window:
            self.status_window.destroy()
        self.root.destroy()

    def update_single_record(self, record):
        logging.debug(f"Processing record: {record}")
        if not self.focus_proval():
            raise Exception("ProVal window not found or could not be focused.")
        
        logging.debug("Pressing Ctrl+O to open Parcel Selection screen.")
        pyautogui.hotkey('ctrl', 'o')
        time.sleep(1)

        proval_windows = gw.getWindowsWithTitle('Parcel Selection')
        if proval_windows:
            proval_windows[0].activate()
            logging.debug("Parcel Selection screen is active.")
        else:
            raise Exception("Parcel Selection screen not found.")

        current_selection = self.pin_ain_var.get()
        logging.debug(f"Navigating for {'PIN' if current_selection == 'PIN' else 'AIN'} input.")
        
        if current_selection == "PIN":
            if self.previous_selection != "PIN":
                logging.debug("Ensuring we start from the PIN by pressing up 11 times.")
                pyautogui.press('up', presses=11, interval=0.05)
            pyautogui.press('tab')
            pyautogui.write(record)
            pyautogui.press('tab', presses=6, interval=0.05)
        else:  # AIN
            if self.previous_selection != "AIN":
                logging.debug("Navigating to AIN field.")
                pyautogui.press('up', presses=11, interval=0.05)
                pyautogui.press('down', presses=4, interval=0.05)
            pyautogui.press('tab')
            pyautogui.write(record)
            pyautogui.press('tab', presses=5, interval=0.05)

        pyautogui.press('enter')
        time.sleep(1)
        self.previous_selection = current_selection

        not_found_window = gw.getWindowsWithTitle('ProVal')
        if not_found_window and "no data returned" in not_found_window[0].title.lower():
            logging.warning(f"No data returned for record: {record}")
            pyautogui.press('enter')
            return

        logging.debug("Opening Property Records.")
        pyautogui.hotkey('alt', 'p', 'i')
        time.sleep(1)

        logging.debug("Updating fields.")
        pyautogui.press('tab')
        if self.null_inspection_date_var.get():
            pyautogui.press('tab', presses=2, interval=0.05)
        else:
            pyautogui.write(self.inspection_cal.get_date())
            pyautogui.press('tab')
            pyautogui.write(self.initials_entry.get())
            pyautogui.press('tab')
        if self.null_appraisal_date_var.get():
            pyautogui.press('tab', presses=2, interval=0.05)
        else:
            pyautogui.write(self.appraisal_cal.get_date())
            pyautogui.press('tab')
            pyautogui.write(self.initials_entry.get())
            pyautogui.press('tab')
        data_source = self.data_source_var.get()
        if data_source == 'Exterior Field Inspect':
            pyautogui.press('down', presses=1, interval=0.05)
        elif data_source == 'Builder - Contractor':
            pyautogui.press('down', presses=2, interval=0.05)
        elif data_source == 'Complete Refusal':
            pyautogui.press('down', presses=3, interval=0.05)
        elif data_source == 'Estimated':
            pyautogui.press('down', presses=4, interval=0.05)
        elif data_source == 'Gate Closed':
            pyautogui.press('down', presses=5, interval=0.05)
        elif data_source == 'Interior Inspected':
            pyautogui.press('down', presses=6, interval=0.05)
        elif data_source == 'Mobile Home':
            pyautogui.press('down', presses=7, interval=0.05)
        elif data_source == 'Owner Information':
            pyautogui.press('down', presses=8, interval=0.05)
        elif data_source == 'Posted No Trespassing':
            pyautogui.press('down', presses=9, interval=0.05)
        elif data_source == 'Sale / Listing Information':
            pyautogui.press('down', presses=10, interval=0.05)
        elif data_source == 'Tenant Information':
            pyautogui.press('down', presses=11, interval=0.05)
        elif data_source == 'Vacant':
            pyautogui.press('down', presses=12, interval=0.05)
        pyautogui.press('tab', presses=5, interval=0.05)
        pyautogui.press('enter')
        pyautogui.press('tab', presses=1, interval=0.05)
        pyautogui.press('enter')

        logging.debug("Saving changes.")
        pyautogui.hotkey('ctrl', 's')
        time.sleep(1)

        # Call open_memos after saving changes
        self.open_memos(record)

    def open_memos(self, record):
        logging.debug(f"Handling memos for record: {record}")
        logging.debug("Opening memo menu.")
        pyautogui.hotkey('ctrl', 'shift', 'm')
        time.sleep(1)

        # Bring the Select Memo window to focus
        select_memo_window = gw.getWindowsWithTitle('Select Memo')[0]
        select_memo_window.activate()
        time.sleep(0.5)

        # Press 'r' to jump to the top of the RY memos
        pyautogui.press('r')
        time.sleep(0.5)

        # Set the memo area for OCR
        self.set_memo_area()

        # Iterate through memos and get the list of RY memos
        ry_memos = self.iterate_through_memos()

        if ry_memos:
            # Prompt user to select a memo or create a new one
            selected_memo = self.prompt_user_for_memo_selection(ry_memos)
            
            if selected_memo is None:
                logging.debug("User closed the selection window. Returning to ProVal Select Memo window.")
                return  # This will allow the process to continue without creating or editing a memo
            
            if selected_memo == "(New Memo)":
                self.create_new_memo()
            else:
                memo_index = ry_memos.index(selected_memo)
                self.open_existing_memo(selected_memo, memo_index)
        else:
            logging.debug("No RY memos found. Creating a new memo.")
            self.create_new_memo()

        # After creating or editing a memo, return to the ProVal Select Memo window
        select_memo_window = gw.getWindowsWithTitle('Select Memo')
        if select_memo_window:
            select_memo_window[0].activate()
            time.sleep(0.5)

    def set_memo_area(self):
        # Adjust these coordinates to focus more tightly on the RY memo text
        left = 840
        top = 475
        width = 35
        height = 18
        
        self.memo_area = (left, top, width, height)
        logging.debug(f"Memo area set to: {self.memo_area}")

    def perform_ocr(self):
        try:
            if self.memo_area is None:
                logging.error("Memo area not set. Call set_memo_area() first.")
                return ""
            
            screenshot = pyautogui.screenshot(region=self.memo_area)
            
            # Save the original screenshot for debugging
            debug_dir = os.path.join(os.path.dirname(__file__), 'debug_screenshots')
            os.makedirs(debug_dir, exist_ok=True)
            original_screenshot_path = os.path.join(debug_dir, f'original_memo_area_{time.time()}.png')
            screenshot.save(original_screenshot_path)
            logging.debug(f"Saved original screenshot: {original_screenshot_path}")
            
            # Convert the image to grayscale
            gray = cv2.cvtColor(np.array(screenshot), cv2.COLOR_RGB2GRAY)
            
            # Apply thresholding
            _, thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)
            
            # Invert the image (black text on white background)
            thresh = cv2.bitwise_not(thresh)
            
            # Save the thresholded image for debugging
            thresh_path = os.path.join(debug_dir, f'thresholded_memo_area_{time.time()}.png')
            cv2.imwrite(thresh_path, thresh)
            logging.debug(f"Saved thresholded image: {thresh_path}")
            
            # Use pytesseract to do OCR on the preprocessed image
            # Adjust the configuration to improve accuracy for RY memos
            text = pytesseract.image_to_string(thresh, config='--psm 7 -c tessedit_char_whitelist=RY0123456789 --oem 3')
            
            # Clean up the OCR result
            text = text.strip()
            
            logging.debug(f"OCR Result: '{text}'")
            
            return text
        except Exception as e:
            logging.error(f"Error in perform_ocr: {str(e)}")
            return ""

    def process_ocr_result(self, ocr_result):
        logging.debug(f"Processing OCR result: {ocr_result}")
        
        # Remove any non-alphanumeric characters
        ocr_result = re.sub(r'[^RY0-9]', '', ocr_result)
        logging.debug(f"After removing non-alphanumeric: {ocr_result}")

        # Replace common OCR mistakes
        ocr_result = ocr_result.replace('O', '0').replace('I', '1').replace('S', '5')
        ocr_result = ocr_result.replace('U', '0').replace('T', '1')
        logging.debug(f"After replacing common mistakes: {ocr_result}")

        # Look for RY followed by any number of digits, ignoring anything before RY
        match = re.search(r'RY\d+', ocr_result)
        if match:
            result = match.group()
            # If the result is RY1, RY2, ..., RY9, add a leading zero
            if len(result) == 3:
                result = result[:2] + '0' + result[2]
            logging.debug(f"Valid RY memo found: {result}")
            return result
        
        logging.debug("No valid RY memo found")
        return None

    def iterate_through_memos(self):
        ry_memos = []
        max_attempts = 25  # Maximum number of RY memos
        consecutive_invalid = 0
        max_consecutive_invalid = 1

        for attempt in range(max_attempts):
            ocr_result = self.perform_ocr()
            processed_result = self.process_ocr_result(ocr_result)
            
            logging.debug(f"Attempt {attempt + 1}: OCR result: '{ocr_result}', Processed: {processed_result}")
            
            if processed_result:
                if processed_result not in ry_memos:
                    ry_memos.append(processed_result)
                    logging.debug(f"Found valid RY memo: {processed_result}")
                consecutive_invalid = 0
            else:
                consecutive_invalid += 1
                if consecutive_invalid >= max_consecutive_invalid:
                    logging.debug(f"Stopping after {max_consecutive_invalid} consecutive invalid results")
                    break
            
            pyautogui.press('down')
            time.sleep(0.5)  # Wait for the screen to update after pressing down

        logging.debug(f"Total valid RY memos found: {len(ry_memos)}")
        return ry_memos

    def prompt_user_for_memo_selection(self, ry_memos):
        select_window = SelectOrCreateMemoWindow(self.root, ry_memos)
        self.root.wait_window(select_window)
        return select_window.selected_memo

    def create_new_memo(self):
        logging.debug("Attempting to create new memo.")
        
        # Ensure the 'Select Memo' window is active
        select_memo_window = gw.getWindowsWithTitle('Select Memo')
        if select_memo_window:
            select_memo_window[0].activate()
            time.sleep(0.5)  # Wait for the window to become active
        else:
            logging.error("'Select Memo' window not found.")
            return

        # Navigate to the top of the list
        pyautogui.press('up', presses=20, interval=0.05)
        time.sleep(0.1)

        # Press enter to open the Memo ID window
        pyautogui.press('enter')
        time.sleep(0.1)

        # Ensure the 'Memo ID' window is active
        memo_id_window = gw.getWindowsWithTitle('Memo ID')
        if memo_id_window:
            memo_id_window[0].activate()
            time.sleep(0.5)  # Wait for the window to become active
        else:
            logging.error("'Memo ID' window not found.")
            return

        # Navigate to the first RY memo option
        pyautogui.press('r')
        time.sleep(0.5)
        
        # Allow user to create the memo content
        user_response = messagebox.askyesno("New Memo", "Create the new memo content in ProVal. Did you create a new memo?")
        
        if user_response:
            # Save and close the memo
            pyautogui.hotkey('ctrl', 's')
            time.sleep(0.5)
            pyautogui.hotkey('alt', 'f4')
            time.sleep(0.5)
            logging.debug("New memo created and saved.")
        else:
            logging.debug("User indicated no new memo was created.")
            # Close the memo window without saving
            pyautogui.hotkey('alt', 'f4')
            time.sleep(0.5)
            # Handle any "Do you want to save changes?" prompt
            save_prompt = gw.getWindowsWithTitle('ProVal')
            if save_prompt and "save changes" in save_prompt[0].title.lower():
                pyautogui.press('n')  # Press 'No' to discard changes
                time.sleep(0.5)

        logging.debug("Exiting create_new_memo function.")

    def open_existing_memo(self, selected_memo, memo_index):
        logging.debug(f"Opening existing memo: {selected_memo} at index {memo_index}")

        try:
            # Ensure the 'Select Memo' window is active
            select_memo_window = gw.getWindowsWithTitle('Select Memo')
            if select_memo_window:
                select_memo_window[0].activate()
                time.sleep(0.6)  # Wait for the window to become active
            else:
                logging.error("'Select Memo' window not found.")
                return
            
            # Navigate to the correct memo
            pyautogui.press('r')  # Jump to the top of the RY memos
            time.sleep(0.1)
            
            # Move down to the correct memo index
            for _ in range(memo_index):
                pyautogui.press('down')
                time.sleep(0.2)
            
            # Select the memo
            pyautogui.press('enter')
            time.sleep(0.5)
            
            # Find the 'Update Memo' window
            update_memo_window = gw.getWindowsWithTitle('Update Memo')
            if not update_memo_window:
                logging.error("'Update Memo' window not found.")
                return

            # Get the position and size of the 'Update Memo' window
            update_memo_rect = update_memo_window[0].box

            # Create and position the 'Edit Memo' window
            edit_memo_window = tk.Toplevel(self.root)
            edit_memo_window.title("Edit Memo")
            edit_memo_window.geometry(f"300x100+{update_memo_rect.left}+{update_memo_rect.top - 150}")
            edit_memo_window.attributes('-topmost', True)
            edit_memo_window.resizable(False, False)  # Disable resizing

            frame = ttk.Frame(edit_memo_window, padding="10 10 10 10")
            frame.pack(fill=tk.BOTH, expand=True)

            ttk.Label(frame, text=f"Append to the memo '{selected_memo}' in ProVal.").pack(pady=(0, 10))
            ttk.Button(frame, text="Done", command=edit_memo_window.destroy).pack()

            # Wait for the user to close the 'Edit Memo' window
            self.root.wait_window(edit_memo_window)

            logging.debug(f"User closed the Edit Memo window for {selected_memo}")

            # Ensure the 'Update Memo' window is active
            update_memo_window = gw.getWindowsWithTitle('Update Memo')
            if update_memo_window:
                update_memo_window[0].activate()
                time.sleep(0.5)  # Wait for the window to become active
            else:
                logging.debug(f"'Update Memo' window not found after editing. Assuming memo {selected_memo} was successfully edited and closed.")
                return
            
            pyautogui.hotkey('ctrl', 's')
            time.sleep(0.5)        
            pyautogui.hotkey('alt', 'f4')
            time.sleep(0.5)

            logging.debug(f"Successfully edited and saved memo: {selected_memo}")

        except Exception as e:
            logging.error(f"Error while editing memo {selected_memo}: {str(e)}")
            # Don't re-raise the exception, allow the process to continue with the next memo

class SelectOrCreateMemoWindow(tk.Toplevel):
    def __init__(self, master, ry_memos, *args, **kwargs):
        super().__init__(master, *args, **kwargs)
        self.title("Select or Create Memo")
        self.attributes('-topmost', True)
        
        self.window_width = 300
        self.window_height = 200
        self.memo_var = tk.StringVar(value="(New Memo)")
        self.selected_memo = None

        self.create_widgets(ry_memos)
        
        # Position the window below the Select Memo window
        self.position_window()

        # Handle window close event
        self.protocol("WM_DELETE_WINDOW", self.on_close)

        # Set focus to this window
        self.focus_force()
        
        # Grab the focus to make this window modal
        self.grab_set()

        # Bind Enter key to confirm action
        self.bind('<Return>', lambda event: self.on_confirm())

    def position_window(self):
        select_memo_window = gw.getWindowsWithTitle('Select Memo')
        if select_memo_window:
            x = select_memo_window[0].left
            y = select_memo_window[0].top + select_memo_window[0].height
            self.geometry(f"{self.window_width}x{self.window_height}+{x}+{y}")
        else:
            # Fallback positioning if Select Memo window is not found
            self.center_window()

    def center_window(self):
        screen_width = self.winfo_screenwidth()
        screen_height = self.winfo_screenheight()
        x = (screen_width - self.window_width) // 2
        y = (screen_height - self.window_height) // 2
        self.geometry(f"{self.window_width}x{self.window_height}+{x}+{y}")

    def create_widgets(self, ry_memos):
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(0, weight=1)

        main_frame = ttk.Frame(self)
        main_frame.grid(row=0, column=0, sticky="nsew")
        main_frame.grid_columnconfigure(0, weight=1)
        main_frame.grid_rowconfigure(0, weight=1)

        self.canvas = tk.Canvas(main_frame)
        self.scrollbar = ttk.Scrollbar(main_frame, orient="vertical", command=self.canvas.yview)
        self.scrollable_frame = ttk.Frame(self.canvas)

        self.scrollable_frame.bind(
            "<Configure>",
            lambda e: self.canvas.configure(
                scrollregion=self.canvas.bbox("all")
            )
        )

        self.canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")
        self.canvas.configure(yscrollcommand=self.scrollbar.set)

        ttk.Label(self.scrollable_frame, text="Choose an action:").pack(anchor="w", padx=10, pady=5)
        ttk.Radiobutton(self.scrollable_frame, text="Create New Memo", variable=self.memo_var, value="(New Memo)").pack(anchor="w", padx=10)

        for memo in ry_memos:
            ttk.Radiobutton(self.scrollable_frame, text=f"Append to {memo}", variable=self.memo_var, value=memo).pack(anchor="w", padx=10)

        self.canvas.grid(row=0, column=0, sticky="nsew")
        self.scrollbar.grid(row=0, column=1, sticky="ns")

        # Create a separate frame for the confirm button
        button_frame = ttk.Frame(self)
        button_frame.grid(row=1, column=0, sticky="ew", pady=10)
        button_frame.grid_columnconfigure(0, weight=1)

        self.confirm_button = ttk.Button(button_frame, text="Confirm", command=self.on_confirm)
        self.confirm_button.grid(row=0, column=0, pady=5)

    def on_confirm(self):
        self.selected_memo = self.memo_var.get()
        self.destroy()

    def on_close(self):
        self.selected_memo = None
        self.grab_release()  # Release the grab before destroying
        self.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = ProValUpdater(root)
    root.mainloop()
