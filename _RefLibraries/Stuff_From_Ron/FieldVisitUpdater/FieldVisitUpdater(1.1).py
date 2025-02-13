import os
import sys
import time
import psutil
import logging
import warnings
import win32gui
import win32con
import pyautogui
import traceback
import threading
import subprocess
import pandas as pd
import tkinter as tk
from pathlib import Path
import pygetwindow as gw
from datetime import datetime
from tkinter import ttk, filedialog, messagebox

# Suppress the specific warnings
warnings.filterwarnings("ignore", category=UserWarning, module="pywinauto.application")
warnings.filterwarnings("ignore", category=UserWarning, message="imread_('tab'): can't open/read file: check file path/integrity")

def setup_logging():
    # Get the current user's username
    username = os.environ.get('USERNAME') or os.environ.get('USER')
    
    # Create the log directory path
    log_dir = os.path.expandvars(r'C:\Users\%USERNAME%\FieldVisitUpdater\Logs')
    
    # Create the log directory if it doesn't exist
    Path(log_dir).mkdir(parents=True, exist_ok=True)
    
    # Set up the log file path
    log_file = os.path.join(log_dir, 'FieldVisitUpdater.log')
    
    # Configure logging
    logging.basicConfig(
        filename=log_file,
        level=logging.INFO,
        format='%(asctime)s:%(levelname)s:%(message)s',
        filemode='a'  # 'a' means append (instead of 'w' for write)
    )
    
    # Add a separator with timestamp when a new session starts
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    logging.info(f"\n{'='*50}\nNew session started at {current_time}\n{'='*50}")
    logging.info(f"Logging initialized for user: {username}")

class FieldVisitUpdaterApp(tk.Tk):
    def __init__(self):
        super().__init__()
        setup_logging()  # Call the setup_logging function
        self.title("Field Visit Updater")
        self.geometry("350x420")
        self.minsize(350, 420)
        
        self.data = None
        self.current_index = 0
        self.proval_automation = ProValAutomation()
        self.always_on_top = tk.BooleanVar(value=True)
        self.use_next_year = tk.BooleanVar(value=True)
        
        self.create_widgets()
        self.configure_layout()
        self.attributes('-topmost', self.always_on_top.get())
    
    def create_widgets(self):
        self.info_frame = ttk.Frame(self)
        self.info_frame.pack(pady=10, fill=tk.X)

        self.pin_label = ttk.Label(self.info_frame, text="PIN:")
        self.pin_label.grid(row=0, column=0, padx=5, pady=5, sticky="e")
        self.pin_value = ttk.Label(self.info_frame, text="")
        self.pin_value.grid(row=0, column=1, padx=5, pady=5, sticky="w")

        self.permit_label = ttk.Label(self.info_frame, text="Permit Number:")
        self.permit_label.grid(row=1, column=0, padx=5, pady=5, sticky="e")
        self.permit_value = ttk.Label(self.info_frame, text="")
        self.permit_value.grid(row=1, column=1, padx=5, pady=5, sticky="w")

        self.address_label = ttk.Label(self.info_frame, text="Address:")
        self.address_label.grid(row=2, column=0, padx=5, pady=5, sticky="e")
        self.address_value = ttk.Label(self.info_frame, text="")
        self.address_value.grid(row=2, column=1, padx=5, pady=5, sticky="w")

        self.button_frame = ttk.Frame(self)
        self.button_frame.pack(pady=10)

        # File selection button
        self.file_button = ttk.Button(self.button_frame, text="Select Excel File", command=self.load_excel, width=15)
        self.file_button.grid(row=0, column=0, padx=5, pady=5)

        # Start button
        self.start_button = ttk.Button(self.button_frame, text="Start", command=self.process_current, state=tk.DISABLED, width=15)
        self.start_button.grid(row=0, column=1, padx=5, pady=5)

        # Continue button
        self.continue_button = ttk.Button(self.button_frame, text="Continue", command=self.continue_processing, state=tk.DISABLED, width=15)
        self.continue_button.grid(row=0, column=2, padx=5, pady=5)

        # Skip button
        self.skip_button = ttk.Button(self.button_frame, text="Skip", command=self.skip_current, state=tk.DISABLED, width=15)
        self.skip_button.grid(row=1, column=0, padx=5, pady=5)

        # Already Worked button
        self.already_worked_button = ttk.Button(self.button_frame, text="Already Worked", command=self.mark_already_worked, width=15)
        self.already_worked_button.grid(row=1, column=1, padx=5, pady=5)

        # Terminate button
        self.terminate_button = ttk.Button(self.button_frame, text="Terminate", command=self.terminate_script, width=15)
        self.terminate_button.grid(row=1, column=2, padx=5, pady=5)

        self.log_text = tk.Text(self, height=10, width=50)
        self.log_text.pack(pady=10, padx=10, fill=tk.BOTH, expand=True)

                # Add new frame for checkboxes above the info_frame
        self.settings_frame = ttk.Frame(self)
        self.settings_frame.pack(pady=5, fill=tk.X)

        # Add checkbox for always on top
        self.always_on_top_cb = ttk.Checkbutton(
            self.settings_frame, 
            text="Always on Top",
            variable=self.always_on_top,
            command=self.toggle_always_on_top
        )
        self.always_on_top_cb.pack(side=tk.LEFT, padx=5)

        # Add checkbox for year selection
        self.year_cb = ttk.Checkbutton(
            self.settings_frame,
            text="Use Next Year",
            variable=self.use_next_year
        )
        self.year_cb.pack(side=tk.LEFT, padx=5)

        # Redirect stdout to the log_text widget
        sys.stdout = self

    def toggle_always_on_top(self):
        is_on_top = self.always_on_top.get()
        self.attributes('-topmost', is_on_top)
        logging.info(f"Always on top: {'enabled' if is_on_top else 'disabled'}")

    def configure_layout(self):
        self.columnconfigure(0, weight=1)
        self.rowconfigure(2, weight=1)  # Make the row with log_text expandable
        self.info_frame.columnconfigure(1, weight=1)
    
    def write(self, text):
        self.log_text.insert(tk.END, text)
        self.log_text.see(tk.END)
    
    def flush(self):
        pass
    
    def load_excel(self):
        file_path = filedialog.askopenfilename(filetypes=[("Excel files", "*.xlsx;*.xls")])
        if file_path:
            self.data = pd.read_excel(file_path, usecols=[0, 1, 2], header=0)
            self.data.columns = ['PIN', 'Permit Number', 'Address']
            self.current_index = 0
            self.update_info()
            self.start_button.config(state=tk.NORMAL)
            self.skip_button.config(state=tk.NORMAL)
            threading.Thread(target=self.open_proval, daemon=True).start()
    
    def update_info(self):
        if self.data is not None and not self.data.empty and self.current_index < len(self.data):
            row = self.data.iloc[self.current_index]
            self.pin_value.config(text=row['PIN'])
            self.permit_value.config(text=row['Permit Number'])
            self.address_value.config(text=row['Address'])
            self.start_button.config(state=tk.NORMAL)
            self.skip_button.config(state=tk.NORMAL)
            self.already_worked_button.config(state=tk.NORMAL) 
            self.continue_button.config(state=tk.DISABLED)
        else:
            if self.data is None or self.data.empty:
                messagebox.showinfo("No Data", "No data available or file is empty.")
            else:
                messagebox.showinfo("Completed", "All records processed.")
            self.start_button.config(state=tk.DISABLED)
            self.skip_button.config(state=tk.DISABLED)
            self.already_worked_button.config(state=tk.DISABLED)
            self.continue_button.config(state=tk.DISABLED)
    
    def open_proval(self):
        self.log_message("Opening ProVal...")
        self.proval_automation.open_proval()
        self.log_message("ProVal opened successfully.")
    
    def process_current(self):
        if self.current_index < len(self.data):
            row = self.data.iloc[self.current_index]
            pin = row['PIN']
            permit = row['Permit Number']
            
            self.log_message(f"Opening record for PIN: {pin}, Permit: {permit}")
            self.start_button.config(state=tk.DISABLED)
            self.skip_button.config(state=tk.DISABLED)
            self.already_worked_button.config(state=tk.DISABLED)
            
            # Start a new thread to focus ProVal and open the record
            threading.Thread(target=self.focus_proval_and_open_record, args=(pin,), daemon=True).start()
    
    def focus_proval_and_open_record(self, pin):
        try:
            # First, focus and maximize ProVal
            self.proval_automation.focus_and_maximize_proval()
            time.sleep(1)  # Give a short delay to ensure ProVal is ready

            # Then open the record
            self.proval_automation.open_record(pin, self.data['PIN'].tolist())
            self.after(0, self.enable_continue_and_skip_buttons)
        except Exception as e:
            self.log_message(f"Error focusing ProVal or opening record: {str(e)}")
            self.after(0, self.enable_start_and_skip_buttons)
    
    def enable_continue_and_skip_buttons(self):
        self.continue_button.config(state=tk.NORMAL)
        self.skip_button.config(state=tk.NORMAL)
        self.already_worked_button.config(state=tk.NORMAL)
        self.bring_window_to_front()
    
    def enable_start_and_skip_buttons(self):
        self.start_button.config(state=tk.NORMAL)
        self.skip_button.config(state=tk.NORMAL)
        self.already_worked_button.config(state=tk.NORMAL)
        self.bring_window_to_front()
    
    def continue_processing(self):
        if self.current_index < len(self.data):
            row = self.data.iloc[self.current_index]
            pin = row['PIN']
            permit = row['Permit Number']
            self.log_message(f"Continuing processing for PIN: {pin}, Permit: {permit}")
            self.continue_button.config(state=tk.DISABLED)
            self.skip_button.config(state=tk.DISABLED)
            threading.Thread(target=self.complete_field_visit_thread, args=(pin, permit), daemon=True).start()
    
    def complete_field_visit_thread(self, pin, permit):
        self.proval_automation.complete_field_visit(pin, permit, self.use_next_year.get())
        self.after(0, self.process_next_record)
    
    def process_next_record(self):
        self.current_index += 1
        self.update_info()
        if self.current_index < len(self.data):
            self.process_current()
        else:
            self.log_message("All records processed.")
            self.bring_window_to_front()
    
    def skip_current(self):
        if self.current_index < len(self.data):
            row = self.data.iloc[self.current_index]
            pin = row['PIN']
            permit = row['Permit Number']
            self.log_message(f"Skipped PIN: {pin}, Permit: {permit}")
            self.process_next_record()
    
    def log_message(self, message):
        self.log_text.insert(tk.END, message + "\n")
        self.log_text.see(tk.END)
    
    def bring_window_to_front(self):
        self.lift()
        if not self.always_on_top.get():
            self.attributes('-topmost', True)
            self.after_idle(self.attributes, '-topmost', False)
    
    def terminate_script(self):
        if messagebox.askyesno("Terminate Script", "Are you sure you want to terminate the script?"):
            self.proval_automation.terminate()
            self.destroy()
            sys.exit()
    
    def mark_already_worked(self):
        if self.current_index < len(self.data):
            row = self.data.iloc[self.current_index]
            pin = row['PIN']
            permit = row['Permit Number']
            self.log_message(f"Marked as Already Worked - PIN: {pin}, Permit: {permit}")
            self.process_next_record()

class ProValAutomation:
    def __init__(self):
        self.app = None
        self.proval_path = r'C:\Program Files (x86)\Thomson Reuters\ProVal\ProVal.exe'

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
        
        self.wait_for_proval_window()
        self.focus_and_maximize_proval()

    def is_proval_running(self):
        for proc in psutil.process_iter(['name']):
            if proc.info['name'].lower() == 'proval.exe':
                return True
        return False

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

    def open_record(self, pin, pins):
        try:
            # Open the Parcel Selection window
            logging.info("Sending keyboard commands to open Parcel Selection window.")
            pyautogui.hotkey("alt", "f")  # Open the File menu
            pyautogui.press("o")  # Select "Open"
            time.sleep(1)  # Wait for the Parcel Selection window to appear

            # Navigate to pin selection
            if pin == pins[0]:  # Check if it's the first PIN
                pyautogui.press("up", presses=11, interval=0.1)
                pyautogui.press("tab")
            else:
                pyautogui.press("tab")
            time.sleep(0.1)

            # Type the pin and press Enter
            pyautogui.typewrite(str(pin))
            pyautogui.press("enter")

            time.sleep(0.2)
            logging.info(f"Opened record for PIN: {pin}")
        except Exception as e:
            logging.error(f"Error opening record for PIN {pin}: {e}")
            logging.error(traceback.format_exc())
            raise

    def complete_field_visit(self, pin, permit, use_next_year=True):
        try:
            # Click the "Add Field Visit" button
            pyautogui.click(340, 840)
            logging.info(f"Clicked on Add Field Visit button for PIN {pin}.")
            time.sleep(1)

            # Select the "Work Assigned Date" checkbox
            pyautogui.click(420, 650)
            logging.info(f"Clicked on Work Assigned Date checkbox for PIN {pin}.")
            time.sleep(0.1)

            # Select the "Work Due Date" checkbox
            pyautogui.click(420, 710)
            logging.info(f"Clicked on Work Due Date checkbox for PIN {pin}.")
            time.sleep(0.1)

            # Set the "Visit Date"
            current_year = datetime.now().year
            visit_year = current_year + 1 if use_next_year else current_year
            
            pyautogui.click(440, 710)
            pyautogui.typewrite('12')  # Set month
            pyautogui.click(455, 710)
            pyautogui.typewrite('31')  # Set day
            pyautogui.click(480, 710)
            pyautogui.typewrite(str(visit_year))  # Set dynamic year
            logging.info(f"Set Visit Date to 12/31/{visit_year} for PIN {pin}.")
            time.sleep(0.5)

            # Select the "Need to Visit" checkbox
            pyautogui.click(310, 810)
            logging.info(f"Clicked on Need to Visit checkbox for PIN {pin}.")
            time.sleep(1)

            # Select Visit Type (Permit)
            pyautogui.click(505, 685)
            time.sleep(1)
            pyautogui.click(505, 755)
            pyautogui.press('tab')
            time.sleep(1.5)

            # Save the record 
            pyautogui.hotkey('ctrl', 's')
            logging.info(f"Field visit record added for PIN {pin}.")
            time.sleep(1.5)
        
        except Exception as e:
            logging.error(f"Error processing PIN {pin} with permit {permit}: {e}")
            logging.error(traceback.format_exc())
            time.sleep(1)

    def terminate(self):
        try:
            # Close ProVal
            pyautogui.hotkey('alt', 'f4')
            time.sleep(1)
            pyautogui.press('n')  # Select 'No' if asked to save changes
            logging.info("ProVal automation terminated.")
        except Exception as e:
            logging.error(f"Error terminating ProVal: {e}")
            logging.error(traceback.format_exc())

    def check_if_already_worked(self, pin):
        try:
            # Ensure the main window is focused
            main_window = self.app.window(title="ProVal", class_name='WindowsForms10.Window.8.app.0.13965fa_r8_ad1')
            main_window.set_focus()

            # Navigate to the Field Visit tab
            pyautogui.hotkey('ctrl', 'tab')
            time.sleep(0.5)

            # Check for the presence of a field visit record
            # This is a placeholder - you'll need to adjust the coordinates based on your screen
            field_visit_color = pyautogui.pixel(500, 500)  # Adjust these coordinates

            # If the pixel color indicates a field visit record exists, consider it already worked
            if field_visit_color == (255, 255, 255):  # Adjust this color as needed
                logging.info(f"PIN {pin} has already been worked.")
                return True
            else:
                logging.info(f"PIN {pin} has not been worked yet.")
                return False

        except Exception as e:
            logging.error(f"Error checking if PIN {pin} has been worked: {e}")
            logging.error(traceback.format_exc())
            return False  # Assume not worked in case of error

def main():
    setup_logging()  # Call setup_logging before creating the app
    app = FieldVisitUpdaterApp()
    app.mainloop()

if __name__ == "__main__":
    main()
