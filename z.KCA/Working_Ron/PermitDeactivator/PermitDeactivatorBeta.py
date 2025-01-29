import time
import ctypes
import psutil
import pyodbc
import logging
import keyboard
import win32gui
import win32con
import subprocess
import tkinter as tk
import pyautogui as pag
from pathlib import Path
import pygetwindow as gw
from datetime import datetime
from tkinter import ttk, messagebox, scrolledtext

home_dir = Path.home()
log_dir = home_dir / "PermitDeactivator"
log_dir.mkdir(parents=True, exist_ok=True)
ProVal_path = "C:/Program Files (x86)/Thomson Reuters/ProVal/ProVal.exe"

current_time = datetime.now().strftime("%Y%m%d_%H%M%S")
log_file = log_dir / f"PermitDeactivator{current_time}.log"
logging.basicConfig(filename=str(log_file), level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

terminate_script = False

def kill_switch():
    global terminate_script
    terminate_script = True
    print("Kill switch activated. Terminating script...")
    logging.info("Kill switch activated. Terminating script...")

keyboard.add_hotkey('esc', kill_switch)

conn_str = (
    "DRIVER={SQL Server};"
    "SERVER=AsTxDBProd;"
    "DATABASE=GRM_Main;"
    "Trusted_Connection=yes;"
)

user_home_dir = Path.home()
log_dir = user_home_dir / "PermitDeactivator"
log_dir.mkdir(parents=True, exist_ok=True)
ProVal_path = "C:/Program Files (x86)/Thomson Reuters/ProVal/ProVal.exe"

current_time = datetime.now().strftime("%Y%m%d_%H%M%S")
log_file = log_dir / f"PermitDeactivator{current_time}.log"
logging.basicConfig(filename=str(log_file), level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

terminate_script = False

def kill_switch():
    global terminate_script
    terminate_script = True
    print("Kill switch activated. Terminating script...")
    logging.info("Kill switch activated. Terminating script...")

keyboard.add_hotkey('esc', kill_switch)

class PermitDeactivator:
    def __init__(self, root):
        self.root = root
        self.proval_path = ProVal_path
        self.pin_ain_var = tk.StringVar(value="AIN")
        self.previous_selection = None
        self.status_window = None
        self.setup_ui()
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.root.attributes('-topmost', True)
        self.is_topmost = True

    def setup_ui(self):
        self.root.title("Permit Deactivator")

        ttk.Label(self.root, text="Select Input Type:").grid(row=0, column=0, padx=10, pady=5, sticky="w")
        ttk.Radiobutton(self.root, text="AIN", variable=self.pin_ain_var, value="AIN").grid(row=0, column=1, padx=10, pady=5, sticky="w")
        ttk.Radiobutton(self.root, text="PIN", variable=self.pin_ain_var, value="PIN").grid(row=0, column=2, padx=10, pady=5, sticky="w")

        ttk.Label(self.root, text="Select Parcel Set ID:").grid(row=1, column=0, padx=10, pady=5, sticky="w")
        self.parcel_set_id_var = tk.StringVar()
        self.parcel_set_dropdown = ttk.Combobox(self.root, textvariable=self.parcel_set_id_var, state='readonly')
        self.parcel_set_dropdown.grid(row=1, column=1, columnspan=2, padx=10, pady=5, sticky="w")
        self.populate_parcel_set_dropdown()
        self.parcel_set_dropdown.bind("<<ComboboxSelected>>", self.on_parcel_set_selected)

        ttk.Label(self.root, text="Records (one per line):").grid(row=2, column=0, columnspan=3, padx=10, pady=5, sticky="w")
        self.records_text = scrolledtext.ScrolledText(self.root, width=40, height=10)
        self.records_text.grid(row=3, column=0, columnspan=3, padx=10, pady=5)

        self.update_button = ttk.Button(self.root, text="Deactivate Permits", command=self.deactivate_permits_batch)
        self.update_button.grid(row=4, column=0, columnspan=3, padx=10, pady=5)

        self.topmost_button = ttk.Button(self.root, text="Disable Always on Top", command=self.toggle_topmost)
        self.topmost_button.grid(row=5, column=0, columnspan=3, padx=10, pady=5)
    
    def is_proval_running(self):
        for proc in psutil.process_iter(['name']):
            if proc.info['name'].lower() == 'proval.exe':
                return True
        return False

    def open_proval(self):
        if not self.is_proval_running():
            try:
                subprocess.Popen(self.proval_path)
                logging.info("Launched ProVal.")
                time.sleep(20)  # Wait for 20 seconds after launching
            except Exception as e:
                logging.error(f"Failed to start ProVal: {e}")
                raise
        else:
            logging.info("ProVal is already running.")

    def wait_for_proval_window(self, timeout=60):
        start_time = time.time()
        while time.time() - start_time < timeout:
            windows = gw.getWindowsWithTitle("ProVal")
            if windows:
                logging.info(f"Found window with title: {windows[0].title}")
                return True
            
            # Check for login window
            login_window = gw.getWindowsWithTitle("ProVal Login")
            if login_window:
                logging.info("ProVal Login window found. Waiting for user to log in.")
                return True
            
            time.sleep(1)
        logging.error("ProVal window not found within the timeout period.")
        return False
    
    def get_proval_pid(self):
        for proc in psutil.process_iter(['pid', 'name', 'exe']):
            try:
                if proc.info['exe'] and Path(proc.info['exe']).resolve() == Path(self.proval_path).resolve():
                    return proc.info['pid']
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass
        return None

    def focus_and_maximize_proval(self):
        try:
            # Try to find main ProVal window
            hwnd = win32gui.FindWindow(None, "ProVal")
            if hwnd == 0:
                # If main window not found, try to find login window
                hwnd = win32gui.FindWindow(None, "ProVal Login")
            
            if hwnd == 0:
                logging.error("Neither ProVal main window nor login window found")
                return False
            
            win32gui.SetForegroundWindow(hwnd)
            win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
            
            window_title = win32gui.GetWindowText(hwnd)
            logging.info(f"Window '{window_title}' focused and maximized")
            return True
        except Exception as e:
            logging.error(f"Error focusing and maximizing ProVal window: {str(e)}")
            return False

    def focus_proval(self):
        logging.debug("Attempting to focus or open ProVal...")
        try:
            self.open_proval()
            if not self.wait_for_proval_window():
                logging.error("ProVal window did not become visible within the timeout period.")
                return False
            if not self.focus_and_maximize_proval():
                logging.error("Failed to focus and maximize ProVal window.")
                return False
            logging.info("ProVal window activated, focused, and maximized.")
            return True
        except Exception as e:
            logging.error(f"Error focusing ProVal window: {e}")
            messagebox.showerror("Error", f"Error focusing ProVal window: {e}")
            return False

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
        self.fetch_ains(selected_id)

    def fetch_ains(self, parcel_set_id):
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
            self.display_ains(ains)
        except Exception as e:
            logging.error(f"Error fetching AINs: {e}")
            messagebox.showerror("Database Error", f"Could not retrieve AINs: {e}")
        finally:
            if connection:
                connection.close()

    def display_ains(self, records):
        self.records_text.delete("1.0", tk.END)
        for ain in records:
            self.records_text.insert(tk.END, f"{ain[0]}\n")

    def toggle_topmost(self):
        self.is_topmost = not self.is_topmost
        self.root.attributes('-topmost', self.is_topmost)
        if self.status_window:
            self.status_window.attributes('-topmost', self.is_topmost)
        self.topmost_button.config(text="Disable Always on Top" if self.is_topmost else "Enable Always on Top")

    def deactivate_permits_batch(self):
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

            logging.debug("Starting batch deactivation...")
            caps_lock_on = ctypes.WinDLL("User32.dll").GetKeyState(0x14) & 0x0001
            if caps_lock_on:
                logging.debug("Caps Lock is on. Turning it off.")
                pag.press('capslock')

            total_records = len(records)
            successful_deactivations = 0
            for index, record in enumerate(records, 1):
                self.status_label.config(text=f"Processing record {index} of {total_records}\n"
                                              f"Current record: {record}\n"
                                              f"Completed: {successful_deactivations}")
                self.status_window.update()
                try:
                    self.deactivate_single_record(record)
                    successful_deactivations += 1
                except Exception as e:
                    logging.error(f"Error processing record {record}: {str(e)}")
                    messagebox.showerror("Error", f"Error processing record {record}: {str(e)}")
                    if messagebox.askyesno("Continue?", "An error occurred. Do you want to continue with the next record?"):
                        continue
                    else:
                        break

            messagebox.showinfo("Batch Deactivation Complete", f"Processed {total_records} records.\n"
                                                               f"Successful deactivations: {successful_deactivations}\n"
                                                               f"Failed deactivations: {total_records - successful_deactivations}")
            logging.info(f"Batch deactivation completed. Processed {total_records} records. "
                         f"Successful: {successful_deactivations}, Failed: {total_records - successful_deactivations}")
        except Exception as e:
            logging.error(f"Error in batch deactivation: {e}")
            messagebox.showerror("Error", f"An error occurred during batch deactivation: {e}")
        finally:
            if caps_lock_on:
                logging.debug("Turning Caps Lock back on.")
                pag.press('capslock')
            if self.status_window and self.status_window.winfo_exists():
                self.status_window.withdraw()
            self.root.grab_release()

    def deactivate_single_record(self, record):
        logging.debug(f"Processing record: {record}")
        if not self.focus_proval():
            raise Exception("ProVal window not found or could not be focused.")
        
        logging.debug("Pressing Ctrl+O to open Parcel Selection screen.")
        pag.hotkey('ctrl', 'o')
        time.sleep(1)

        proval_windows = win32gui.FindWindow(None, 'Parcel Selection')
        if proval_windows:
            win32gui.SetForegroundWindow(proval_windows)
            logging.debug("Parcel Selection screen is active.")
        else:
            raise Exception("Parcel Selection screen not found.")

        current_selection = self.pin_ain_var.get()
        logging.debug(f"Navigating for {'PIN' if current_selection == 'PIN' else 'AIN'} input.")
        
        if current_selection == "PIN":
            if self.previous_selection != "PIN":
                logging.debug("Ensuring we start from the PIN by pressing up 11 times.")
                pag.press('up', presses=11, interval=0.05)
            pag.press('tab')
            pag.write(record)
            pag.press('tab', presses=6, interval=0.05)
        else:  # AIN
            if self.previous_selection != "AIN":
                logging.debug("Navigating to AIN field.")
                pag.press('up', presses=11, interval=0.05)
                pag.press('down', presses=4, interval=0.05)
            pag.press('tab')
            pag.write(record)
            pag.press('tab', presses=5, interval=0.05)

        pag.press('enter')
        time.sleep(1)
        self.previous_selection = current_selection

        not_found_window = win32gui.FindWindow(None, 'ProVal')
        if not_found_window and "no data returned" in win32gui.GetWindowText(not_found_window).lower():
            logging.warning(f"No data returned for record: {record}")
            pag.press('enter')
            return

        logging.debug("Opening Permits screen.")
        pag.hotkey('alt', 'p', 'e')
        time.sleep(1)

        self.deactivate_all_permits()

        logging.debug("Saving changes.")
        pag.hotkey('ctrl', 's')
        time.sleep(1)

    def deactivate_all_permits(self):
        logging.debug("Deactivating all permits.")
        pag.press('home')
        time.sleep(0.5)

        while True:
            if terminate_script:
                logging.info("Kill switch activated. Stopping permit deactivation.")
                break

            screen_before = pag.screenshot()
            pag.press('down')
            time.sleep(0.5)
            screen_after = pag.screenshot()

            if screen_before.tobytes() == screen_after.tobytes():
                logging.debug("Reached end of permits list.")
                break

            pag.press('tab', presses=3, interval=0.05)
            pag.press('space')
            pag.press('home')
            time.sleep(0.5)

        logging.debug("Finished deactivating permits.")

    def create_status_window(self):
        if self.status_window is None or not self.status_window.winfo_exists():
            self.status_window = tk.Toplevel(self.root)
            self.status_window.title("Processing Status")
            self.status_window.geometry("300x100")
            self.status_label = ttk.Label(self.status_window, text="", justify=tk.LEFT)
            self.status_label.pack(pady=20, padx=10, fill=tk.BOTH, expand=True)
            self.status_window.attributes('-topmost', self.is_topmost)
            self.status_window.withdraw()

    def position_status_window(self):
        if self.status_window:
            root_x = self.root.winfo_x()
            root_y = self.root.winfo_y()
            root_width = self.root.winfo_width()
            self.status_window.geometry(f"+{root_x + root_width + 10}+{root_y}")

    def on_closing(self):
        if self.status_window:
            self.status_window.destroy()
        self.root.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = PermitDeactivator(root)
    root.mainloop()