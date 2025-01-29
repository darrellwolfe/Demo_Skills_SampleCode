import os
import time
import ctypes
import psutil
import pyodbc
import logging
import pyautogui
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

log_dir = os.path.join(str(user_home_dir), 'InspectionRecordUpdater')
log_file = os.path.join(log_dir, 'InspectionRecordUpdater.log')

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
        self.setup_ui()
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
    
    def create_status_window(self):
        self.status_window = tk.Toplevel(self.root)
        self.status_window.title("Processing Status")
        self.status_window.geometry("300x100")
        self.status_label = ttk.Label(self.status_window, text="")
        self.status_label.pack(pady=20)
        self.status_window.withdraw()

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
                connection.close

    def on_parcel_set_selected(self, event=None):
        selected_id = self.parcel_set_id_var.get()
        self.fetch_lrsns_and_ains(selected_id)

    def fetch_lrsns_and_ains(self, parcel_set_id):
        try:
            connection = pyodbc.connect(conn_str)
            cursor = connection.cursor()
            cursor.execute("""
                SELECT 
                    TRIM(pm.AIN) AS AIN
                FROM parcel_set AS ps
                JOIN TSBv_PARCELMASTER AS pm
                    ON ps.LRSN = pm.LRSN
                WHERE pm.EffStatus = 'A'
                AND ps.set_id = ?
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
            if not hasattr(self, 'status_window') or not self.status_window.winfo_exists():
                self.create_status_window()
            self.status_window.deiconify()

            logging.debug("Starting batch update...")
            caps_lock_on = ctypes.WinDLL("User32.dll").GetKeyState(0x14) & 0x0001
            if caps_lock_on:
                logging.debug("Caps Lock is on. Turning it off.")
                pyautogui.press('capslock')

            total_records = len(records)
            for index, record in enumerate(records, 1):
                self.status_label.config(text=f"Processing record {index} of {total_records}")
                self.status_window.update()
                self.update_single_record(record)

            messagebox.showinfo("Success", f"Batch update completed. Processed {total_records} records.")
            logging.info(f"Batch update completed. Processed {total_records} records.")
        except Exception as e:
            logging.error(f"Error in batch update: {e}")
            messagebox.showerror("Error", f"An error occurred during batch update: {e}")
        finally:
            if caps_lock_on:
                logging.debug("Turning Caps Lock back on.")
                pyautogui.press('capslock')
            if hasattr(self, 'status_window') and self.status_window.winfo_exists():
                self.status_window.withdraw()
            self.root.grab_release()
    
    def on_closing(self):
        if hasattr(self, 'status_window'):
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

if __name__ == "__main__":
    root = tk.Tk()
    app = ProValUpdater(root)
    root.mainloop()
