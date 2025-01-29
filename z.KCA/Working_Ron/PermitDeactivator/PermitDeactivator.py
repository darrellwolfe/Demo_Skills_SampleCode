import time
import ctypes
import psutil
import pyodbc
import logging
import keyboard
import win32gui
import win32con
import subprocess
import pandas as pd
import tkinter as tk
import pyautogui as pag
from pathlib import Path
import pygetwindow as gw
from datetime import datetime
from tkinter import ttk, filedialog, messagebox, scrolledtext

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

class PermitDeactivator:
    def __init__(self, root):
        self.root = root
        self.proval_path = ProVal_path
        self.pin_ain_var = tk.StringVar(value="AIN")
        self.previous_selection = None
        self.status_window = None
        self.df = None
        self.setup_ui()
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.root.attributes('-topmost', True)
        self.is_topmost = True

        # Position the window 1/8th of the screen from the right
        self.position_window()

        self.user_dir = Path.home() / "PermitDeactivator"
        self.user_dir.mkdir(parents=True, exist_ok=True)

    def position_window(self):
        # Get screen width and height
        screen_width = self.root.winfo_screenwidth()
        screen_height = self.root.winfo_screenheight()

        # Calculate window width and height
        window_width = 350  # Adjust this value based on your desired window width
        window_height = 590  # Adjust this value based on your desired window height

        # Calculate x position (1/8th of the screen from the right)
        x_position = int(screen_width * 7/8 - window_width)

        # Calculate y position (centered vertically)
        y_position = int((screen_height - window_height) / 2)

        # Set the window's position
        self.root.geometry(f"{window_width}x{window_height}+{x_position}+{y_position}")

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

        # Add a button to load Excel file
        self.load_excel_button = ttk.Button(self.root, text="Load Excel File", command=self.load_excel_file)
        self.load_excel_button.grid(row=6, column=0, columnspan=3, padx=10, pady=5)

        # Add a listbox to display records
        self.records_listbox = tk.Listbox(self.root, width=40, height=10, selectmode=tk.MULTIPLE)
        self.records_listbox.grid(row=7, column=0, columnspan=3, padx=10, pady=5)

        # Add scrollbar to the listbox
        self.records_scrollbar = ttk.Scrollbar(self.root, orient="vertical", command=self.records_listbox.yview)
        self.records_scrollbar.grid(row=7, column=3, sticky="ns")
        self.records_listbox.configure(yscrollcommand=self.records_scrollbar.set)

        # Add a button to process selected records
        self.process_selected_button = ttk.Button(self.root, text="Process Selected Records", command=self.process_selected_records)
        self.process_selected_button.grid(row=8, column=0, columnspan=3, padx=10, pady=5)
    
    def is_proval_running(self):
        for proc in psutil.process_iter(['name']):
            if proc.info['name'].lower() == 'proval.exe':
                return True
        return False
    
    def get_proval_pid(self):
        for proc in psutil.process_iter(['pid', 'name', 'exe']):
            try:
                if proc.info['exe'] and Path(proc.info['exe']).resolve() == Path(self.proval_path).resolve():
                    return proc.info['pid']
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass
        return None

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

    def process_selected_records(self):
        if self.df is None or self.df.empty:
            messagebox.showwarning("No Data", "Please load an Excel file first.")
            return

        # Use all records from the DataFrame instead of just selected ones
        self.deactivate_permits_batch(self.df.to_dict('records'))

    def deactivate_permits_batch(self, records=None):
        if records is None:
            # Use the existing method for processing records from the text area
            records = self.records_text.get("1.0", tk.END).strip().split('\n')
            records = [record.strip() for record in records if record.strip()]
        
        if not records:
            messagebox.showerror("Invalid Input", "No records to process.")
            return

        total_records = len(records)
        successful_deactivations = 0
        skipped_records = 0
        already_worked_records = 0
        processed_records = 0

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

            for index, record in enumerate(records, 1):
                try:
                    record_display = record['AIN'] if isinstance(record, dict) else record
                    self.status_label.config(text=f"Processing record {index} of {total_records}\n"
                                                  f"Current record: {record_display}\n"
                                                  f"Completed: {successful_deactivations}")
                    self.status_window.update()
                except tk.TclError:
                    logging.info("GUI closed by user. Continuing processing without updates.")
                    break

                try:
                    result = self.process_record(record)
                    processed_records += 1
                    if result == True:
                        successful_deactivations += 1
                    elif result == 'skip':
                        logging.info(f"Skipped record: {record}")
                        skipped_records += 1
                    elif result == 'already_worked':
                        logging.info(f"Record already worked: {record}")
                        already_worked_records += 1
                except Exception as e:
                    logging.error(f"Error processing record {record}: {str(e)}")
                    if messagebox.askyesno("Continue?", f"Error processing record {record}: {str(e)}\nDo you want to continue with the next record?"):
                        continue
                    else:
                        break

        except Exception as e:
            logging.error(f"An error occurred during batch processing: {str(e)}")
            messagebox.showerror("Error", f"An error occurred during batch processing: {str(e)}")
        finally:
            if caps_lock_on:
                logging.debug("Turning Caps Lock back on.")
                pag.press('capslock')

            # Log the results
            log_message = (f"Batch deactivation completed or interrupted. Processed {processed_records} out of {total_records} records. "
                           f"Successful: {successful_deactivations}, Skipped: {skipped_records}, "
                           f"Already Worked: {already_worked_records}, "
                           f"Failed: {processed_records - successful_deactivations - skipped_records - already_worked_records}")
            logging.info(log_message)

            try:
                if self.status_window and self.status_window.winfo_exists():
                    self.status_window.withdraw()
                self.root.grab_release()
                messagebox.showinfo("Batch Deactivation Results", log_message)
            except tk.TclError:
                logging.info("Unable to show results in GUI as it has been closed.")

            # After processing, update the Excel file and the listbox
            if self.df is not None:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                output_file = self.user_dir / f"updated_records_{timestamp}.xlsx"
                self.df.to_excel(output_file, index=False)
                self.populate_records_listbox()
                logging.info(f"Updated records saved to: {output_file}")
                messagebox.showinfo("File Saved", f"Updated records saved to:\n{output_file}")

    def process_record(self, record):
        logging.info(f"Processing record: {record}")
        try:
            if not self.focus_proval():
                logging.error("Failed to focus ProVal window.")
                return False

            # Open the search dialog
            pag.hotkey('ctrl', 'o')
            time.sleep(1)

            current_selection = self.pin_ain_var.get()
            
            # Check if this is the first record or if the selection has changed
            if not hasattr(self, 'previous_selection') or self.previous_selection != current_selection:
                # Navigate to ensure we're at the correct position
                for _ in range(11):
                    pag.press('up')
                time.sleep(0.5)
                
                if current_selection == "AIN":
                    for _ in range(4):
                        pag.press('down')
                time.sleep(0.5)

                pag.press('tab')
                
                self.previous_selection = current_selection
            else:
                # For subsequent records with the same selection, just tab to the input field
                pag.press('tab')

            # Input the record value (AIN or PIN)
            if isinstance(record, dict):
                ain_or_pin = record['AIN'] if 'AIN' in record else record['PIN']
                permit_number = record.get('Permit Number')
            else:
                ain_or_pin = record
                permit_number = None

            pag.write(str(ain_or_pin))
            
            # Navigate to and click the OK button
            for _ in range(5):
                pag.press('tab')
            pag.press('enter')
            time.sleep(3)

            # Prepare record data for display
            record_data = {current_selection: ain_or_pin}
            if permit_number:
                record_data['Permit Number'] = permit_number

            # Prompt user for permit selection using GUI
            logging.info("Prompting user for permit selection")
            selected_permit = self.select_permit_gui(record_data)
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
            permit_x, permit_y = self.calculate_permit_coordinates(base_permit_x, base_permit_y, selected_permit)

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

            logging.info(f"Successfully processed record: {record}")
            return True
        except Exception as e:
            logging.error(f"Error processing record {record}: {str(e)}")
            return False

    def calculate_permit_coordinates(self, base_x, base_y, permit_number):
        y_offset = (permit_number - 1) * 22
        return base_x, base_y + y_offset

    def calculate_permit_coordinates(self, base_x, base_y, permit_number):
        y_offset = (permit_number - 1) * 22
        return base_x, base_y + y_offset

    def select_permit_gui(self, record_data):
        result = [None]
        def on_button_click(choice):
            result[0] = choice
            root.quit()

        root = tk.Tk()
        root.title("Select Permit Number")
        root.attributes('-topmost', True)

        frame = ttk.Frame(root, padding=(2, 2, 2, 0))  # Reduced padding
        frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        root.columnconfigure(0, weight=1)
        root.rowconfigure(0, weight=1)

        # Display the record information
        row_counter = 0
        for key, value in record_data.items():
            ttk.Label(frame, text=f"{key}: {value}").grid(column=0, row=row_counter, sticky=tk.W)
            row_counter += 1

        ttk.Label(frame, text="Select the permit number:").grid(column=0, row=row_counter, sticky=tk.W, pady=(2, 0))
        row_counter += 1
        
        button_style = ttk.Style()
        button_style.configure('TButton', padding=0)

        for i in range(1, 12):
            tk.Button(frame, text=str(i), command=lambda x=i: on_button_click(x), 
                      height=1, bd=1, relief=tk.RAISED, font=('TkDefaultFont', 8)).grid(column=0, row=row_counter, sticky='ew')
            row_counter += 1
        
        tk.Button(frame, text="Skip", command=lambda: on_button_click("Skip"), 
                  height=1, bd=1, relief=tk.RAISED, font=('TkDefaultFont', 8)).grid(column=0, row=row_counter, sticky='ew')
        row_counter += 1
        tk.Button(frame, text="Already Worked", command=lambda: on_button_click("Already Worked"), 
                  height=1, bd=1, relief=tk.RAISED, font=('TkDefaultFont', 8)).grid(column=0, row=row_counter, sticky='ew')

        root.update_idletasks()
        
        # Adjust the window position
        window_width = root.winfo_width()
        window_height = root.winfo_height()
        
        x_position = 552
        y_position = 98 if 'Permit Number' in record_data else 118

        root.geometry(f'{window_width}x{window_height}+{x_position}+{y_position}')

        root.mainloop()
        root.destroy()
        return result[0]

    def create_status_window(self):
        if self.status_window is None or not self.status_window.winfo_exists():
            self.status_window = tk.Toplevel(self.root)
            self.status_window.title("Status")
            self.status_window.geometry("185x90")
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

    def load_excel_file(self):
        file_path = filedialog.askopenfilename(
            title="Select Input Excel File",
            filetypes=[("Excel files", "*.xlsx;*.xls"), ("All files", "*.*")]
        )
        if file_path:
            try:
                self.df = pd.read_excel(file_path)
                self.populate_records_listbox()
                messagebox.showinfo("Success", f"Loaded {len(self.df)} records from the Excel file.")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to load Excel file: {str(e)}")

    def populate_records_listbox(self):
        self.records_listbox.delete(0, tk.END)
        for index, row in self.df.iterrows():
            record = f"{row['AIN']} - Permit: {row['Permit Number']}"
            self.records_listbox.insert(tk.END, record)

if __name__ == "__main__":
    root = tk.Tk()
    app = PermitDeactivator(root)
    root.mainloop()