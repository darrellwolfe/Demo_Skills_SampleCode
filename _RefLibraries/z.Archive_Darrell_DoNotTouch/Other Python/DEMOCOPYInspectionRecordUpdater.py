
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import pyautogui
import time
import pygetwindow as gw
from tkcalendar import Calendar
import logging
import configparser
import os
from datetime import datetime, date
import ctypes
import psutil
from pywinauto import Application
import pyodbc

# Database connection details
conn_str = (
            "DRIVER={SQL Server};"
            "SERVER=AsTxDBProd;"
            "DATABASE=GRM_Main;"
            "Trusted_Connection=yes;"
        )

# New import to handle windows
logging.basicConfig(
    filename='InspectionRecordUpdater.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

# Determine the path for the roaming directory
roaming_dir = os.path.join(os.getenv('APPDATA'), 'ProValUpdater')
if not os.path.exists(roaming_dir):
    os.makedirs(roaming_dir)

CONFIG_FILE = os.path.join(roaming_dir, 'config.ini')
DEFAULT_PROVAL_PATH = "C:/Program Files (x86)/Thomson Reuters/ProVal/ProVal.exe"

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
        self.setup_ui()

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
                time.sleep(1)
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
        if action == '1':  # Insert
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
        vcmd = (self.root.register(self.validate_initials), '%d', '%P', '%s', '%S', '%v', '%V', '%W')
        self.initials_entry = ttk.Entry(self.root, validate='key', validatecommand=vcmd)
        self.initials_entry.grid(row=1, column=1, columnspan=2, padx=10, pady=5, sticky="w")
        
        # PIN/AIN selection
        ttk.Label(self.root, text="Select Input Type:").grid(row=0, column=0, padx=10, pady=5, sticky="w")
        ttk.Radiobutton(self.root, text="PIN", variable=self.pin_ain_var, value="PIN").grid(row=0, column=1, padx=10, pady=5, sticky="w")
        ttk.Radiobutton(self.root, text="AIN", variable=self.pin_ain_var, value="AIN").grid(row=0, column=2, padx=10, pady=5, sticky="w")

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
        self.data_source_dropdown['values'] = ('Exterior Field Inspect', 'Vacant')
        self.data_source_dropdown.current(0)
        self.data_source_dropdown.grid(row=6, column=1, columnspan=2, padx=10, pady=5, sticky="w")

        # Parcel Set Selection
        ttk.Label(self.root, text="Select Parcel Set ID:").grid(row=10, column=0, padx=10, pady=5, sticky="w")
        self.parcel_set_id_var = tk.StringVar()
        self.parcel_set_dropdown = ttk.Combobox(self.root, textvariable=self.parcel_set_id_var, state='readonly')
        self.parcel_set_dropdown.grid(row=10, column=1, columnspan=2, padx=10, pady=5, sticky="w")
        self.populate_parcel_set_dropdown()
        
        self.parcel_set_dropdown.bind("<<ComboboxSelected>>", self.on_parcel_set_selected)

        ttk.Label(self.root, text="Records (one per line):").grid(row=7, column=0, columnspan=3, padx=10, pady=5, sticky="w")
        self.records_text = scrolledtext.ScrolledText(self.root, width=40, height=10)
        self.records_text.grid(row=8, column=0, columnspan=3, padx=10, pady=5)

        self.update_button = ttk.Button(self.root, text="Update Records", command=self.update_records_batch)
        self.update_button.grid(row=9, column=0, columnspan=3, padx=10, pady=5)
    
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
            cursor.execute("SELECT LRSN FROM Parcel_set WHERE set_id = ?", (parcel_set_id,))
            lrsns_ains = cursor.fetchall()
            self.display_lrsns_ains(lrsns_ains)
        except Exception as e:
            logging.error(f"Error fetching LRSNs and AINs: {e}")
            messagebox.showerror("Database Error", f"Could not retrieve LRSNs and AINs: {e}")
        finally:
            if connection:
                connection.close()

    def display_lrsns_ains(self, records):
        # Clear previous records
        self.records_text.delete("1.0", tk.END)
        for lrsn, ain in records:
            self.records_text.insert(tk.END, f"LRSN: {lrsn}, AIN: {ain}\n")

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
            logging.debug("Starting batch update...")

            caps_lock_on = ctypes.WinDLL("User32.dll").GetKeyState(0x14) & 0x0001
            if caps_lock_on:
                logging.debug("Caps Lock is on. Turning it off.")
                pyautogui.press('capslock')

            for record in records:
                self.update_single_record(record)

            messagebox.showinfo("Success", f"Batch update completed. Processed {len(records)} records.")
            logging.info(f"Batch update completed. Processed {len(records)} records.")
        except Exception as e:
            logging.error(f"Error in batch update: {e}")
            messagebox.showerror("Error", f"An error occurred during batch update: {e}")
        finally:
            if caps_lock_on:
                logging.debug("Turning Caps Lock back on.")
                pyautogui.press('capslock')
            self.root.grab_release()

    def update_single_record(self, record):
        logging.debug(f"Processing record: {record}")
        if not self.focus_proval():
            raise Exception("ProVal window not found or could not be focused.")

        logging.debug("Pressing Ctrl+O to open Parcel Selection screen.")
        pyautogui.hotkey('ctrl', 'o')
        time.sleep(3)

        proval_windows = gw.getWindowsWithTitle('Parcel Selection')
        if proval_windows:
            proval_windows[0].activate()
            logging.debug("Parcel Selection screen is active.")
        else:
            raise Exception("Parcel Selection screen not found.")

        logging.debug(f"Navigating for {'PIN' if self.pin_ain_var.get() == 'PIN' else 'AIN'} input.")
        if self.pin_ain_var.get() == "PIN":
            logging.debug("Ensuring we start from the PIN by pressing up 11 times.")
            pyautogui.press('up', presses=11, interval=0.1)
            pyautogui.press('tab')
            pyautogui.write(record)
            pyautogui.press('tab', presses=6, interval=0.1)
        else:  # AIN
            logging.debug("Navigating to AIN field.")
            pyautogui.press('up', presses=11, interval=0.1)
            pyautogui.press('down', presses=4, interval=0.1)
            pyautogui.press('tab')
            pyautogui.write(record)
            pyautogui.press('tab', presses=5, interval=0.1)

        pyautogui.press('enter')
        time.sleep(2)  # Wait for potential "No data returned" dialog

        # Check for "No data returned" dialog
        not_found_window = gw.getWindowsWithTitle('ProVal')
        if not_found_window and "no data returned" in not_found_window[0].title.lower():
            logging.warning(f"No data returned for record: {record}")
            pyautogui.press('enter')  # Press OK on the dialog
            return  # Skip to the next record

        # If record is found, continue with the update process
        logging.debug("Opening Property Records.")
        pyautogui.hotkey('alt', 'p', 'i')
        time.sleep(5)

        logging.debug("Updating fields.")
        pyautogui.press('tab')
        if self.null_inspection_date_var.get():
            pyautogui.press('tab', presses=2, interval=0.1)
        else:
            pyautogui.write(self.inspection_cal.get_date())
            pyautogui.press('tab')
            pyautogui.write(self.initials_entry.get())
            pyautogui.press('tab')
        if self.null_appraisal_date_var.get():
            pyautogui.press('tab', presses=2, interval=0.1)
        else:
            pyautogui.write(self.appraisal_cal.get_date())
            pyautogui.press('tab')
            pyautogui.write(self.initials_entry.get())
            pyautogui.press('tab')
        data_source = self.data_source_var.get()
        if data_source == 'Exterior Field Inspect':
            pyautogui.press('down', presses=1, interval=0.1)
        elif data_source == 'Vacant':
            pyautogui.press('down', presses=12, interval=0.1)
        pyautogui.press('tab', presses=5, interval=0.1)
        pyautogui.press('enter')
        pyautogui.press('tab', presses=1, interval=0.1)
        pyautogui.press('enter')

        logging.debug("Saving changes.")
        pyautogui.hotkey('ctrl', 's')
        time.sleep(2)

if __name__ == "__main__":
    root = tk.Tk()
    app = ProValUpdater(root)
    root.mainloop()