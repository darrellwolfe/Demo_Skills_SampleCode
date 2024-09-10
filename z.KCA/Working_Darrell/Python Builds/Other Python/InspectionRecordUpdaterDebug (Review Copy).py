
import tkinter as tk
from tkinter import ttk, messagebox
import pyautogui
import time
import pygetwindow as gw
from tkcalendar import Calendar
import logging
import pandas as pd

# Setup logging
logging.basicConfig(filename='BIATechTools_Permit_AS52_New.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')


class ProValUpdater:
    def __init__(self, root):
        self.root = root
        self.proval_path = "C:/Program Files (x86)/Thomson Reuters/ProVal/ProVal.exe"  # Assuming ProVal executable path is set correctly
        self.proval_window_handle = None
        self.setup_ui()

    def focus_proval(self):
        print("Attempting to focus ProVal window...")
        try:
            proval_windows = gw.getWindowsWithTitle('ProVal')
            if proval_windows:
                self.proval_window_handle = proval_windows[0]
                print(f"Found ProVal window: {self.proval_window_handle}")
                if not self.proval_window_handle.isActive:
                    self.proval_window_handle.activate()
                    time.sleep(1)  # Wait for the window to be brought to the foreground
                    print("ProVal window activated.")
                else:
                    print("ProVal window is already active.")
                # Verify if the window is now active
                if self.proval_window_handle.isActive:
                    print("ProVal window is confirmed as active.")
                    return True
                else:
                    print("Failed to activate ProVal window.")
                    return False
            else:
                print("ProVal window not found.")
                return False
        except Exception as e:
            print(f"Error: {e}")
            logging.error(f"Error focusing ProVal window: {e}")
            return False

    def setup_ui(self):
        self.root.title("Property Inspection Record Updater")

        # Create a frame for the input fields and buttons
        frame = ttk.Frame(self.root, padding="22")
        frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Initials input field
        initials_label = ttk.Label(frame, text="Initials:")
        initials_label.grid(row=0, column=0, padx=5, pady=5, sticky=tk.W)
        self.initials_entry = ttk.Entry(frame, width=20)
        self.initials_entry.grid(row=0, column=1, padx=5, pady=5, sticky=(tk.W, tk.E))

        # AIN input field
        ain_label = ttk.Label(frame, text="AIN:")
        ain_label.grid(row=1, column=0, padx=5, pady=5, sticky=tk.W)
        self.ain_entry = ttk.Entry(frame, width=20)
        self.ain_entry.grid(row=1, column=1, padx=5, pady=5, sticky=(tk.W, tk.E))

        # Calendar widget for selecting inspection date
        inspection_date_label = ttk.Label(frame, text="Inspection Date:")
        inspection_date_label.grid(row=2, column=0, padx=5, pady=5, sticky=tk.W)
        self.inspection_cal = Calendar(frame, selectmode="day", date_pattern="mm/dd/yyyy")
        self.inspection_cal.grid(row=2, column=1, padx=5, pady=5, sticky=(tk.W, tk.E))
        self.set_default_inspection_date()  # Set today's date as default for inspection date

        # Checkbox to enable NULL inspection date
        self.null_inspection_date_var = tk.BooleanVar()
        self.null_inspection_date_checkbox = ttk.Checkbutton(frame, text="NULL Inspection Date", variable=self.null_inspection_date_var)
        self.null_inspection_date_checkbox.grid(row=3, column=0, columnspan=2, padx=5, pady=5, sticky=tk.W)

        # Calendar widget for selecting appraisal date
        appraisal_date_label = ttk.Label(frame, text="Appraisal Date:")
        appraisal_date_label.grid(row=4, column=0, padx=5, pady=5, sticky=tk.W)
        self.appraisal_cal = Calendar(frame, selectmode="day", date_pattern="mm/dd/yyyy")
        self.appraisal_cal.grid(row=4, column=1, padx=5, pady=5, sticky=(tk.W, tk.E))
        self.set_default_appraisal_date()  # Set today's date as default for appraisal date

        # Checkbox to enable NULL appraisal date
        self.null_appraisal_date_var = tk.BooleanVar()
        self.null_appraisal_date_checkbox = ttk.Checkbutton(frame, text="NULL Appraisal Date", variable=self.null_appraisal_date_var)
        self.null_appraisal_date_checkbox.grid(row=5, column=0, columnspan=2, padx=5, pady=5, sticky=tk.W)

        # Update button
        update_button = ttk.Button(frame, text="Update Selected Record", command=self.update_records)
        update_button.grid(row=6, column=0, columnspan=2, pady=10)

    def set_default_inspection_date(self):
        self.inspection_cal.selection_set(time.strftime("%m/%d/%Y"))  # Set today's date as default for appraisal date

    def set_default_appraisal_date(self):
        self.appraisal_cal.selection_set(time.strftime("%m/%d/%Y"))  # Set today's date as default for appraisal date

    def navigate_to_ain(self):
        try:
            print("Navigating to AIN...")

            # Focus on the ProVal window
            if not self.focus_proval():
                print("ProVal not in focus, attempting to open ProVal...")
                raise Exception("Could not open or find ProVal.")

            # Simulate pressing keys to navigate to the AIN input field
            time.sleep(1)  # Wait for ProVal to be focused

            # Press Ctrl+O to open the selected record
            pyautogui.hotkey('ctrl', 'o')
            time.sleep(1)

            # Tab to the first "Range" field
            pyautogui.press('tab')
            time.sleep(0.5)

            # Enter the AIN again for the range
            pyautogui.typewrite(self.ain_entry.get())
            time.sleep(0.5)

            # Press Enter to specify the range
            pyautogui.press('enter')
            time.sleep(1)

        except Exception as e:
            logging.error(f"Error navigating to AIN: {e}")
            messagebox.showerror("Error", f"An error occurred: {e}")
            print(f"Error navigating to AIN: {e}")

    def update_records(self):
        try:
            self.root.grab_set()  # Disable user interaction with other windows
            self.navigate_to_ain()

            # Simulate pressing keys to navigate to Property Records > Inspection Record Maintenance
            time.sleep(1)  # Wait for ProVal to be focused

            # Press Alt key to open the menu
            pyautogui.keyDown('alt')
            time.sleep(0.5)

            # Press the key for Property Records
            pyautogui.press('p')
            time.sleep(0.5)

            # Press the key for Inspection Record Maintenance
            pyautogui.press('i')
            time.sleep(0.5)

            # Release the Alt key
            pyautogui.keyUp('alt')
            time.sleep(0.5)

            # Tab to the date field
            pyautogui.press('tab')  # Adjust the number of tabs as needed
            time.sleep(0.5)

            # Enter the inspection date or leave blank if NULL is selected
            if self.null_inspection_date_var.get():
                pyautogui.typewrite("")
                skip_initials = True
            else:
                pyautogui.typewrite(self.inspection_cal.get_date())
                skip_initials = False

            time.sleep(0.5)

            # Tab to the initial field
            pyautogui.press('tab')
            time.sleep(0.5)

            # Enter the initials if not skipping
            initials = self.initials_entry.get()
            if not skip_initials:
                pyautogui.typewrite(initials)
                time.sleep(0.5)

            # Tab to the appraisal date field
            pyautogui.press('tab')
            time.sleep(0.5)

            # Enter the appraisal date or leave blank if NULL is selected
            if self.null_appraisal_date_var.get():
                pyautogui.typewrite("")
                skip_initials = True
            else:
                pyautogui.typewrite(self.appraisal_cal.get_date())
                skip_initials = False

            # Tab to the appraiser initials field
            pyautogui.press('tab')
            time.sleep(0.5)

            # Enter the same initials as used in the inspection date initials field if not skipping
            if not skip_initials:
                pyautogui.typewrite(initials)

            # Tab 7 times to navigate to the save button
            for _ in range(7):
                pyautogui.press('tab')
                time.sleep(0.2)

            # Press Enter to save the record
            pyautogui.press('enter')
            time.sleep(0.5)

            # Show success message
            messagebox.showinfo("Success", "Records updated successfully!")
            print("Records updated successfully!")

        except Exception as e:
            logging.error(f"Error updating records: {e}")
            messagebox.showerror("Error", f"An error occurred: {e}")
            print(f"Error updating records: {e}")
            
if __name__ == "__main__":
    root = tk.Tk()
    app = ProValUpdater(root)
    root.mainloop()
