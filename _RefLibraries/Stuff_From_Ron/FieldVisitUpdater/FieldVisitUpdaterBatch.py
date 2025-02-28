import sys
import time
import subprocess
import keyboard
import logging
import psutil
import pyautogui
from pathlib import Path
from pywinauto import Application
import traceback

# Setup logging
logging.basicConfig(filename='FieldVisitUpdater.log', level=logging.INFO,
                    format='%(asctime)s:%(levelname)s:%(message)s')

proval_process = None
app_path = "C:/Program Files (x86)/Thomson Reuters/ProVal/ProVal.exe"
data_file_path = Path(r"C:\Users\rmason\Documents\Kootenai_County_Assessor_CodeBase\Working_Ron\FieldVisitUpdater\fvb.txt")

# Function to terminate the script
def terminate_script():
    global proval_process
    if proval_process:
        proval_process.terminate()
        logging.info("ProVal process terminated.")
    logging.info("ProVal terminated.")
    sys.exit()

# Register the hotkey
keyboard.add_hotkey('ctrl+shift+h', terminate_script)

class ProValAutomation:
    def __init__(self):
        self.app = None

    def open_proval(self):
        global proval_process
        try:
            # Check if ProVal is already running
            for proc in psutil.process_iter(['name']):
                if proc.info['name'] == 'ProVal.exe':
                    logging.info("ProVal is already running.")
                    self.app = Application().connect(path=app_path)
                    return

            # Start a new instance of ProVal
            proval_process = subprocess.Popen([app_path])
            self.app = Application().connect(process=proval_process.pid)
            logging.info("ProVal started successfully.")
            return proval_process
        except FileNotFoundError:
            logging.error("ProVal executable not found. Please ensure the path is correct.")
            sys.exit()
        except Exception as e:
            logging.error(f"Failed to start ProVal: {e}")
            sys.exit()

    def load_data(self, file_path):
        try:
            with open(file_path, "r") as file:
                lsrns = file.readlines()
                logging.info("Data file loaded successfully.")
                return [lsrn.strip() for lsrn in lsrns]
        except Exception as e:
            logging.error(f"Error loading data file: {e}")
            sys.exit()

    def automate_field_visit(self, lsrn, lsrns):
        try:
            main_window = self.app.window(title="ProVal", class_name='WindowsForms10.Window.8.app.0.13965fa_r8_ad1')
            main_window.set_focus()  # Ensure the ProVal main window is focused
            logging.info("Main window focused.")

            # Open the Parcel Selection window
            logging.info("Sending keyboard commands to open Parcel Selection window.")
            time.sleep(2)
            pyautogui.hotkey("alt", "f")  # Open the File menu
            pyautogui.press("o")  # Select "Open"
            time.sleep(2)  # Wait for the Parcel Selection window to appear

            # Locate the Parcel Selection window
            try:
                parcel_selection_window = self.app.window(title_re=".*Parcel Selection.*")
                parcel_selection_window.wait('exists', timeout=3)
                parcel_selection_window.set_focus()
                logging.info("Parcel Selection window located and focused.")
            except Exception as e:
                logging.error(f"Failed to locate or focus on Parcel Selection window: {e}")
                return

            # Navigate to LSRN selection
            if lsrn == lsrns[0]:  # Check if it's the first LSRN
                pyautogui.press("up", presses=11, interval=0.1)
                pyautogui.press("down", presses=7, interval=0.1)
                pyautogui.press("tab")
            else:
                pyautogui.press("tab")
            time.sleep(2)

            # Type the LSRN and press Enter
            pyautogui.typewrite(lsrn)
            pyautogui.press("enter")

            # Refocus on the main window
            main_window.set_focus()
            logging.info(f"Focused on the main window for LSRN {lsrn}.")

            time.sleep(1)

            # Allow the user to manually select the desired permit
            logging.info("Waiting for user to manually select the desired permit...")
            print("Please select the desired permit and press 'c' to continue...")
            keyboard.wait('c')
            logging.info("User has selected the permit and pressed 'c' to continue.")

            # Click the "Add Field Visit" button (Coordinates example: 340, 840)
            pyautogui.click(340, 840)
            logging.info(f"Clicked on Add Field Visit button for LSRN {lsrn}.")

            time.sleep(1)

            # Select the "Work Assigned Date" checkbox (Coordinates example: 420, 650)
            pyautogui.click(420, 650)
            logging.info(f"Clicked on Work Assigned Date checkbox for LSRN {lsrn}.")

            time.sleep(1)

            # Select the "Work Due Date" checkbox (Coordinates example: 420, 710)
            pyautogui.click(420, 710)
            logging.info(f"Clicked on Work Due Date checkbox for LSRN {lsrn}.")

            time.sleep(1)

            # Set the "Visit Date" (Coordinates example for day field: 340, 320)
            pyautogui.click(440, 710)
            pyautogui.typewrite('12')  # Set month
            pyautogui.click(455, 710)
            pyautogui.typewrite('31')  # Set day
            pyautogui.click(480, 710)
            pyautogui.typewrite('2024')  # Set year
            logging.info(f"Set Visit Date to 12/31/2024 for LSRN {lsrn}.")

            time.sleep(1)

            # Select the "Need to Visit" checkbox (Coordinates example: 320, 320)
            pyautogui.click(310, 810)
            logging.info(f"Clicked on Need to Visit checkbox for LSRN {lsrn}.")

            time.sleep(1)

            # Save the record
            pyautogui.hotkey('alt', 'f')
            pyautogui.press('s')  # Save
            logging.info(f"Field visit record added for LSRN {lsrn}.")
            time.sleep(2)
        
        except Exception as e:
            logging.error(f"Error processing LSRN {lsrn}: {e}")
            logging.error(traceback.format_exc())
            time.sleep(1)
        
def main():
    global proval_process
    try:
        # Initialize ProVal
        proval_automation = ProValAutomation()
        logging.info("Initialized ProValAutomation class.")

        # Open ProVal
        proval_process = proval_automation.open_proval()
        logging.info("ProVal application opened.")
        time.sleep(10)  # Wait for ProVal to load

        # Load the data file
        lsrns = proval_automation.load_data(str(data_file_path))
        logging.info(f"Loaded LSRNs from data file: {lsrns}")

        # Automate field visit setup for each LSRN
        for lsrn in lsrns:
            logging.info(f"Starting automation for LSRN: {lsrn}")
            proval_automation.automate_field_visit(lsrn, lsrns)
            logging.info(f"Completed automation for LSRN: {lsrn}")

    except Exception as e:
        logging.error(f"An error occurred in the main function: {e}")
        logging.error(traceback.format_exc())
    finally:
        # Close ProVal
        terminate_script()

if __name__ == "__main__":
    main()
