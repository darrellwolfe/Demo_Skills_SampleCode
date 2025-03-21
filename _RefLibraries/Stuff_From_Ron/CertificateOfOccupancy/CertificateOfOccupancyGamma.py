import os
import re
import sys
import csv
import time
import psutil
import logging
import win32gui
import keyboard
import pyautogui
import subprocess
import configparser
import tkinter as tk
import win32com.client
import pygetwindow as gw
from functools import wraps
from datetime import datetime
from tkinter import ttk, filedialog

def create_default_config():
    config = configparser.ConfigParser()
    config['Logging'] = {
        'log_directory': os.path.join(os.path.expanduser('~'), 'CertificateOfOccupancy', 'Logs')
    }
    config['Paths'] = {
        'proval_executable': r'C:\Program Files (x86)\Thomson Reuters\ProVal\ProVal.exe'
    }
    config['Processing'] = {
        'days_to_process': 30
    }
    config['Output'] = {
        'csv_directory': os.path.join(os.path.expanduser('~'), 'CertificateOfOccupancy')
    }
    config['Coordinates'] = {
        'permit_number_x': '55',
        'permit_number_y': '200',
        'occupancy_checkbox_x': '120',
        'occupancy_checkbox_y': '855',
        'month_certified_x': '140',
        'day_certified_x': '155',
        'year_certified_x': '185',
        'date_certified_y': '855'
    }
    config['Sender'] = {
        'sender': 'noreply@cityofhaydenid.us',
        'mailbox': 'kcasr permits'
    }
    return config

def load_config():
    config_dir = os.path.join(os.path.expanduser('~'), 'CertificateOfOccupancy')
    config_path = os.path.join(config_dir, 'config.ini')

    if not os.path.exists(config_dir):
        os.makedirs(config_dir)
        logging.info(f"Created directory: {config_dir}")

    if not os.path.exists(config_path):
        # Create default config if the ini file does not exist
        config = create_default_config()
        with open(config_path, 'w') as configfile:
            config.write(configfile)
        logging.info(f"Created default configuration file: {config_path}")
    else:
        # Load existing config
        config = configparser.ConfigParser()
        config.read(config_path)

    return config

CONFIG = load_config()

def setup_logging():
    log_directory = CONFIG.get('Logging', 'log_directory')
    os.makedirs(log_directory, exist_ok=True)
    log_file = os.path.join(log_directory, f'CertificateofOccupancy_{datetime.now().strftime("%Y%m%d")}.log')
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()
        ]
    )
    logging.info("Logging setup completed.")

def is_proval_running():
    for proc in psutil.process_iter(['name']):
        if proc.info['name'].lower() == 'proval.exe':
            return True
    return False

def open_proval():
    proval_path = CONFIG.get('Paths', 'proval_executable')
    if not is_proval_running():
        try:
            subprocess.Popen(proval_path)
            logging.info("Launched ProVal.")
        except Exception as e:
            logging.error(f"Failed to start ProVal: {e}")
            raise
    else:
        logging.info("ProVal is already running.")

def wait_for_proval_window(timeout=30):
    start_time = time.time()
    while time.time() - start_time < timeout:
        windows = gw.getWindowsWithTitle("ProVal")
        if windows and windows[0].visible:
            return True
        time.sleep(1)
    return False

def extract_pin(body):
    match = re.search(r'PARCEL #:\s*(\w+)', body)
    return match.group(1) if match else None

def extract_address(subject, body):
    # Try to extract from the subject (new format)
    subject_match = re.search(r'CO has been issued for: (.+)', subject)
    if subject_match:
        return subject_match.group(1).strip()
    
    # Try to extract from the body (old format)
    body_match = re.search(r'ADDRESS:\s*(.+)', body)
    if body_match:
        return body_match.group(1).strip()
    
    # If not found in body, try to extract from subject (alternative new format)
    alt_subject_match = re.search(r'^(.+?)(?:Com|Res)', subject)
    if alt_subject_match:
        return alt_subject_match.group(1).strip()
    
    return None

def extract_permit_number(subject, body):
    # Try to extract from the body (old format)
    body_match = re.search(r'PERMIT INFORMATION:.*?(\w{2}\d{2}-\d{4})', body, re.DOTALL)
    if body_match:
        return body_match.group(1)
    
    # Try to extract from the subject (new format)
    subject_match = re.search(r'(?:Com|Res).*?(\w{2}\d{2}-\d{4})$', subject)
    if subject_match:
        return subject_match.group(1)
    
    return None

def extract_permit_type(subject, body):
    # Try to extract from the body (old format)
    body_match = re.search(r'PROJECT TYPE:\s*(.+)', body)
    if body_match:
        return body_match.group(1).strip()
    
    # Try to extract from the subject (new format)
    subject_match = re.search(r'(Com|Res)\s+(\w+)', subject)
    if subject_match:
        return f"{subject_match.group(1)} {subject_match.group(2)}"
    
    return "Unknown"

def check_for_kill_switch():
    if keyboard.is_pressed('esc'):
        logging.info("Kill switch activated. Exiting program.")
        sys.exit(0)

def intelligent_pause(seconds):
    end_time = time.time() + seconds
    while time.time() < end_time:
        check_for_kill_switch()
        time.sleep(0.1)

def create_csv(data, output_directory=None):
    if output_directory is None:
        output_directory = CONFIG.get('Logging', 'log_directory')
    os.makedirs(output_directory, exist_ok=True)
    csv_file = os.path.join(output_directory, f'extracted_data_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv')
    fieldnames = ['PIN', 'Address', 'Permit Number', 'Received Date']
    with open(csv_file, 'w', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        for row in data:
            writer.writerow(row)
    logging.info(f"CSV file created: {csv_file}")
    return csv_file

def gui_prompt(title, message, options):
    result = [None]
    def on_button_click(choice):
        result[0] = choice
        root.quit()
    root = tk.Tk()
    root.title(title)
    root.attributes('-topmost', True)
    frame = ttk.Frame(root, padding="10")
    frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
    ttk.Label(frame, text=message).grid(column=0, row=0, pady=5)
    for i, option in enumerate(options):
        ttk.Button(frame, text=option, command=lambda x=option: on_button_click(x)).grid(column=0, row=i+1, padx=2, pady=2, sticky='ew')
    root.mainloop()
    root.destroy()
    return result[0]

def manual_pin_entry():
    return gui_prompt("Manual PIN Entry", "Enter the PIN manually:", ["Enter PIN", "Skip"])

def activate_window(window_title):
    try:
        hwnd = win32gui.FindWindow(None, window_title)
        if hwnd == 0:
            logging.error(f"Window '{window_title}' not found")
            return False
        shell = win32com.client.Dispatch("WScript.Shell")
        shell.SendKeys('%')
        win32gui.SetForegroundWindow(hwnd)
        return True
    except Exception as e:
        logging.error(f"Error activating window '{window_title}': {str(e)}")
        return False

def select_permit_gui():
    return gui_prompt("Select Permit Number", "Select the permit number:", [str(i) for i in range(1, 11)] + ["Skip"])

def calculate_permit_coordinates(base_x, base_y, permit_number):
    y_offset = (permit_number - 1) * 22  # 22 pixels between each permit
    return base_x, base_y + y_offset

def process_hayden_email(message, success=True, skip=False):
    """
    Process emails specifically for the Hayden Certificate of Occupancy workflow.
    This function is tailored for the 'kcasr permits' mailbox and should not be used for general email processing.
    """
    try:
        message.UnRead = False
        
        # Correctly add the ProcessedCheckmark category
        categories = message.Categories.split(", ") if message.Categories else []
        if "ProcessedCheckmark" not in categories:
            categories.append("ProcessedCheckmark")
        
        if success and "Checkmark" not in categories:
            categories.append("Checkmark")
        
        message.Categories = ", ".join(categories)
        
        if success:
            message.FlagStatus = 0  # Remove any existing flag
            # Move to the ! ENTERED/CO'S folder
            cos_folder = get_cos_folder()
            if cos_folder:
                message.Move(cos_folder)
        elif skip:
            message.FlagStatus = 4  # 4 corresponds to "Next Week"
        
        message.Save()
        logging.info(f"{'Successfully processed' if success else 'Flagged for next week review' if skip else 'Marked as processed'} email: {message.Subject}")
        return True
    except Exception as e:
        logging.error(f"Error processing Hayden email: {message.Subject}. Error: {str(e)}")
        return False

def get_cos_folder():
    try:
        outlook = win32com.client.Dispatch("Outlook.Application").GetNamespace("MAPI")
        kcasr_permits_folder = None
        for folder in outlook.Folders:
            if folder.Name.lower() == 'kcasr permits':
                kcasr_permits_folder = folder
                break
        if kcasr_permits_folder:
            entered_folder = kcasr_permits_folder.Folders['! ENTERED']
            cos_folder = entered_folder.Folders["CO'S"]
            return cos_folder
    except Exception as e:
        logging.error(f"Error getting CO'S folder: {str(e)}")
    return None

def is_processed(message):
    return "Processed" in message.Categories

def mark_as_processed(message):
    if "Processed" not in message.Categories:
        message.Categories += "Processed;"
    if "Checkmark" not in message.Categories:
        message.Categories += "Checkmark;"
    message.UnRead = False
    message.Save()

def with_kill_switch(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except KeyboardInterrupt:
            logging.info("Program interrupted by user.")
            sys.exit(0)
    return wrapper

@with_kill_switch
def update_proval(pin, address, occupancy_date):
    try:
        if not is_proval_running():
            open_proval()
        if not wait_for_proval_window():
            logging.error("ProVal window did not become visible within the timeout period.")
            return False
        if not activate_window("ProVal"):
            logging.error("Failed to activate ProVal window.")
            return False
        logging.info("ProVal window activated.")

        # Navigate to the correct record
        pyautogui.hotkey('ctrl', 'o')
        intelligent_pause(0.5)
        pyautogui.press('up', presses=11)  # Ensure we're at the top of the selection
        
        if pin:
            pyautogui.press('tab')
            intelligent_pause(1)
            pyautogui.typewrite(pin)
        else:
            pyautogui.press('down', presses=3)  # Move to address field
            pyautogui.press('tab')
            intelligent_pause(1)
            pyautogui.typewrite(address)
        
        pyautogui.press('enter')
        logging.info(f"Entered {'PIN' if pin else 'Address'}: {pin or address}")
        intelligent_pause(1)

        # Prompt user for permit selection using GUI
        selected_permit = select_permit_gui()
        if selected_permit == 'Skip':
            logging.info("User chose to skip this record.")
            return 'skip'
        elif selected_permit is None:
            logging.info("User cancelled permit selection.")
            return False

        selected_permit = int(selected_permit)
        # scroll_to_permit(selected_permit)

        base_permit_x = CONFIG.getint('Coordinates', 'permit_number_x')
        base_permit_y = CONFIG.getint('Coordinates', 'permit_number_y')
        permit_x, permit_y = calculate_permit_coordinates(base_permit_x, base_permit_y, selected_permit)

        # Click on the selected permit
        pyautogui.click(x=permit_x, y=permit_y)
        intelligent_pause(1)

        # Update the record
        occupancy_checkbox_x = CONFIG.getint('Coordinates', 'occupancy_checkbox_x')
        occupancy_checkbox_y = CONFIG.getint('Coordinates', 'occupancy_checkbox_y')
        month_certified_x = CONFIG.getint('Coordinates', 'month_certified_x')
        day_certified_x = CONFIG.getint('Coordinates', 'day_certified_x')
        year_certified_x = CONFIG.getint('Coordinates', 'year_certified_x')
        date_certified_y = CONFIG.getint('Coordinates', 'date_certified_y')

        # Check the occupancy checkbox
        pyautogui.click(x=occupancy_checkbox_x, y=occupancy_checkbox_y)
        logging.info("Checked 'Date Certified for Occupancy' box.")
        intelligent_pause(1.5)

        # Enter the occupancy date
        month, day, year = occupancy_date.split('/')
        pyautogui.click(x=month_certified_x, y=date_certified_y)
        pyautogui.typewrite(month)
        intelligent_pause(0.1)
        pyautogui.click(x=day_certified_x, y=date_certified_y)
        pyautogui.typewrite(day)
        intelligent_pause(0.1)
        pyautogui.click(x=year_certified_x, y=date_certified_y)
        pyautogui.typewrite(year)
        logging.info(f"Entered Occupancy Date: {occupancy_date}.")
        intelligent_pause(0.5)
        # Save changes
        pyautogui.hotkey('ctrl', 's')
        intelligent_pause(1)
        logging.info("Record saved successfully.")
        return True
    except pyautogui.FailSafeException:
        logging.error("PyAutoGUI fail-safe triggered. Mouse manually moved to a corner.")
    except Exception as e:
        logging.error(f"Error updating ProVal: {e}", exc_info=True)
    return False

def process_csv(csv_path):
    extracted_data = []  # Store processed CSV data
    with open(csv_path, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            permit_number = row.get('Permit Number')
            address = row.get('Address')
            pin = row.get('Parcel Number')  # Assuming 'Parcel Number' is the column header for PIN
            received_date = row.get('Date Finaled')  # Assuming 'Date Finaled' is the received date

            if not pin and not address:
                logging.warning(f"Skipping row: No PIN or address found for Permit Number {permit_number}")
                continue

            action = gui_prompt("Process Record", 
                                f"Permit Number: {permit_number or 'Not found'}\n"
                                f"PIN: {pin or 'Not found'}\n"
                                f"Address: {address or 'Not found'}\n"
                                f"Received Date: {received_date or 'Not found'}",
                                ["Process", "Skip", "Exit"])

            if action == "Process":
                proval_result = update_proval(pin or address, received_date)
                if proval_result == True:
                    logging.info(f"Successfully updated ProVal for Permit Number: {permit_number}, PIN: {pin}")
                    extracted_data.append({
                        'PIN': pin,
                        'Address': address,
                        'Permit Number': permit_number,
                        'Received Date': received_date
                    })
                elif proval_result == 'skip':
                    logging.info(f"Skipped processing for Permit Number: {permit_number}, PIN: {pin}")
                    continue
                else:
                    logging.error(f"Failed to update ProVal for Permit Number: {permit_number}, PIN: {pin}")
            elif action == "Skip":
                logging.info(f"Skipped record: Permit Number {permit_number}, PIN: {pin or 'N/A'}, Address: {address or 'N/A'}")
                continue
            elif action == "Exit":
                logging.info("User chose to exit. Stopping processing.")
                break

    if extracted_data:
        # Create CSV if there is extracted data
        create_csv(extracted_data)
        logging.info(f"CSV file created for processed records.")

def with_kill_switch(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except KeyboardInterrupt:
            logging.info("Program interrupted by user.")
            sys.exit(0)
    return wrapper

@with_kill_switch
def main():
    setup_logging()
    logging.info("Starting Certificate of Occupancy processing...")

    mode = gui_prompt("Processing Mode", "Choose processing mode:", ["CSV Input", "Hayden Email"])

    if mode == "CSV Input":
        filetypes = [("CSV Files", "*.csv")]  # Define filetypes here
        csv_path = gui_prompt("CSV Input", "Enter the path to the CSV file:", ["Browse"])
        if csv_path == "Browse":
            csv_path = filedialog.askopenfilename(filetypes=filetypes)  # Use the defined filetypes
        if csv_path:
            process_csv(csv_path)
        else:
            logging.error("No CSV path provided.")
    else:
        process_hayden_emails()

def process_hayden_emails():
    extracted_data = []  # Store processed email data
    total_processed = 0
    last_used_pin = True  # Track whether the last record used PIN or address
    
    try:
        outlook = win32com.client.Dispatch("Outlook.Application").GetNamespace("MAPI")
        kcasr_permits_folder = None
        for folder in outlook.Folders:
            if folder.Name.lower() == 'kcasr permits':
                kcasr_permits_folder = folder
                break
        if kcasr_permits_folder is None:
            logging.error("Mailbox 'kcasr permits' not found.")
            return

        inbox_folder = kcasr_permits_folder.Folders['Inbox']
        cos_folder = None
        for folder in kcasr_permits_folder.Folders:
            if folder.Name == "! ENTERED":
                for subfolder in folder.Folders:
                    if subfolder.Name == "CO'S":
                        cos_folder = subfolder
                        break
                break
        if cos_folder is None:
            logging.error("CO's folder not found.")
            return

        while True:
            messages = inbox_folder.Items
            messages.Sort("[ReceivedTime]", True)
            unread_messages = messages.Restrict("[Unread] = True")
            try:
                message = unread_messages.GetFirst()
                if message is None:
                    logging.info("No more unread messages to process.")
                    break
            except Exception as e:
                logging.error(f"Error getting next unread message: {str(e)}")
                break

            sender = message.SenderEmailAddress
            subject = message.Subject
            if sender.lower() != "noreply@cityofhaydenid.us":
                logging.info(f"Skipped email from unexpected sender: {sender}")
                process_hayden_email(message, success=False)
                continue

            logging.info(f"Processing email from {sender}: {subject}")
            body = message.Body
            received_date = message.ReceivedTime.strftime('%m/%d/%Y')
            logging.info(f"Received date: {received_date}")

            address = extract_address(subject, body)
            permit_number = extract_permit_number(subject, body)
            pin = extract_pin(body)
            permit_type = extract_permit_type(subject, body)

            logging.info(f"Extracted data - Address: {address}, PIN: {pin}, Permit Number: {permit_number}, Permit Type: {permit_type}")

            if not pin and not address:
                logging.warning("Both PIN and address are missing. Skipping this email.")
                process_hayden_email(message, success=False)
                continue

            # Determine whether to use PIN or address
            use_pin = bool(pin)
            
            # Adjust ProVal navigation if switching between PIN and address
            if use_pin != last_used_pin:
                if use_pin:
                    pyautogui.press('up', presses=3)
                else:
                    pyautogui.press('down', presses=3)
            
            last_used_pin = use_pin

            action = gui_prompt("Process Record", 
                                f"PIN: {pin or 'Not found'}\n"
                                f"Address: {address or 'Not found'}\n"
                                f"Permit Number: {permit_number or 'Not found'}\n"
                                f"Received Date: {received_date}",
                                ["Process", "Skip", "Exit"])

            if action == "Process":
                proval_result = update_proval(pin, address, received_date)
                if proval_result == True:
                    process_hayden_email(message, success=True)
                    extracted_data.append({
                        'PIN': pin,
                        'Address': address,
                        'Permit Number': permit_number,
                        'Received Date': received_date
                    })
                    total_processed += 1
                    logging.info(f"Successfully processed record for PIN: {pin or 'N/A'}, Address: {address or 'N/A'}")
                elif proval_result == 'skip':
                    logging.info(f"Skipped processing in ProVal for PIN: {pin or 'N/A'}, Address: {address or 'N/A'}")
                    process_hayden_email(message, success=False, skip=True)
                else:
                    process_hayden_email(message, success=False, skip=True)
                    logging.error(f"Failed to process record for PIN: {pin or 'N/A'}, Address: {address or 'N/A'}")
            elif action == "Skip":
                logging.info(f"User chose to skip record for PIN: {pin or 'N/A'}, Address: {address or 'N/A'}")
                process_hayden_email(message, success=False, skip=True)
            elif action == "Exit":
                logging.info("User chose to exit. Stopping processing.")
                break

            # Move to the next email
            message = unread_messages.GetNext()

            if total_processed % 10 == 0:
                create_csv(extracted_data)

    except Exception as e:
        logging.error(f"Error processing Hayden emails: {str(e)}", exc_info=True)
    finally:
        if extracted_data:
            create_csv(extracted_data)
        logging.info(f"Total emails processed: {total_processed}")

if __name__ == "__main__":
    main()