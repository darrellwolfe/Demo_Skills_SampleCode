import os
import re
import sys
import csv
import time
import psutil
import logging
import textwrap
import win32gui
import win32con
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

# Setup Config
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
        config = create_default_config()
        with open(config_path, 'w') as configfile:
            config.write(configfile)
        logging.info(f"Created default configuration file: {config_path}")
    else:
        config = configparser.ConfigParser()
        config.read(config_path)

    return config

CONFIG = load_config()

def setup_logging():
    today = datetime.now().strftime("%Y%m%d")
    log_dir = os.path.expandvars(rf'C:\Users\%USERNAME%\CertificateOfOccupancy\Extracts\{today}')
    os.makedirs(log_dir, exist_ok=True)
    log_file = os.path.join(log_dir, f'CertificateOfOccupancy_{today}.log')
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file, mode='a'),
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
    subject_match = re.search(r'CO has been issued for: (.+)', subject)
    if subject_match:
        return subject_match.group(1).strip()
    
    body_match = re.search(r'ADDRESS:\s*(.+)', body)
    if body_match:
        return body_match.group(1).strip()
    
    alt_subject_match = re.search(r'^(.+?)(?:Com|Res)', subject)
    if alt_subject_match:
        return alt_subject_match.group(1).strip()
    
    return None

def extract_permit_number(subject, body):
    body_match = re.search(r'PERMIT INFORMATION:.*?(\w{2}\d{2}-\d{4})', body, re.DOTALL)
    if body_match:
        return body_match.group(1)
    
    subject_match = re.search(r'(?:Com|Res).*?(\w{2}\d{2}-\d{4})$', subject)
    if subject_match:
        return subject_match.group(1)
    
    return None

def extract_permit_type(subject, body):
    body_match = re.search(r'PROJECT TYPE:\s*(.+)', body)
    if body_match:
        return body_match.group(1).strip()
    
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
    root.protocol("WM_DELETE_WINDOW", root.quit)
    frame = ttk.Frame(root, padding="10")
    frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
    ttk.Label(frame, text=message).grid(column=0, row=0, pady=5)
    for i, option in enumerate(options):
        ttk.Button(frame, text=option, command=lambda x=option: on_button_click(x)).grid(column=0, row=i+1, padx=2, pady=2, sticky='ew')
    root.mainloop()
    root.destroy()
    return result[0]

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

    # Display record data
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
    y_offset = (permit_number - 1) * 22
    return base_x, base_y + y_offset

def update_email_status(message, success=True, skip=False):
    """
    Update the status of individual emails for the Hayden Certificate of Occupancy workflow.
    This function is tailored for the 'kcasr permits' mailbox and should not be used for general email processing.
    """
    try:
        message.UnRead = False
        
        categories = message.Categories.split(", ") if message.Categories else []
        if "ProcessedCheckmark" not in categories:
            categories.append("ProcessedCheckmark")
        message.Categories = ", ".join(categories)
        
        if success:
            message.FlagStatus = 1
            cos_folder = get_cos_folder()
            if cos_folder:
                message.Move(cos_folder)
        elif skip:
            message.FlagStatus = 4
        
        message.Save()
        logging.info(f"{'Successfully processed' if success else 'Flagged for next week review' if skip else 'Marked as processed'} email: {message.Subject}")
        return True
    except Exception as e:
        logging.error(f"Error updating email status: {message.Subject}. Error: {str(e)}")
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

def focus_and_maximize_proval():
    try:
        hwnd = win32gui.FindWindow(None, "ProVal")
        if hwnd == 0:
            logging.error("ProVal window not found")
            return False
        
        win32gui.SetForegroundWindow(hwnd)
        win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
        
        logging.info("ProVal window focused and maximized")
        return True
    except Exception as e:
        logging.error(f"Error focusing and maximizing ProVal window: {str(e)}")
        return False

@with_kill_switch
def update_proval(pin, address, occupancy_date, permit_number):
    try:
        if not is_proval_running():
            open_proval()
        if not wait_for_proval_window():
            logging.error("ProVal window did not become visible within the timeout period.")
            return False
        if not focus_and_maximize_proval():
            logging.error("Failed to focus and maximize ProVal window.")
            return False
        logging.info("ProVal window activated, focused, and maximized.")

        pyautogui.hotkey('ctrl', 'o')
        intelligent_pause(0.5)
        pyautogui.press('up', presses=11)
        
        if pin:
            pyautogui.press('tab')
            intelligent_pause(1)
            pyautogui.typewrite(pin)
        else:
            pyautogui.press('down', presses=3)
            pyautogui.press('tab')
            intelligent_pause(1)
            pyautogui.typewrite(address)
        
        pyautogui.press('enter')
        logging.info(f"Entered {'PIN' if pin else 'Address'}: {pin or address}")
        intelligent_pause(1)

        record_data = {
            "PIN": pin or "Not available",
            "Address": address or "Not available",
            "Occupancy Date": occupancy_date,
            "Permit Number": permit_number or "Not available"
        }

        selected_permit = select_permit_gui(record_data)
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

        base_permit_x = CONFIG.getint('Coordinates', 'permit_number_x')
        base_permit_y = CONFIG.getint('Coordinates', 'permit_number_y')
        permit_x, permit_y = calculate_permit_coordinates(base_permit_x, base_permit_y, selected_permit)

        pyautogui.click(x=permit_x, y=permit_y)
        intelligent_pause(1)

        occupancy_checkbox_x = CONFIG.getint('Coordinates', 'occupancy_checkbox_x')
        occupancy_checkbox_y = CONFIG.getint('Coordinates', 'occupancy_checkbox_y')
        month_certified_x = CONFIG.getint('Coordinates', 'month_certified_x')
        day_certified_x = CONFIG.getint('Coordinates', 'day_certified_x')
        year_certified_x = CONFIG.getint('Coordinates', 'year_certified_x')
        date_certified_y = CONFIG.getint('Coordinates', 'date_certified_y')

        pyautogui.click(x=occupancy_checkbox_x, y=occupancy_checkbox_y)
        logging.info("Checked 'Date Certified for Occupancy' box.")
        intelligent_pause(1.5)

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
    processed_count = 0
    skipped_count = 0
    error_count = 0
    already_worked_count = 0
    
    try:
        with open(csv_path, 'r') as infile:
            reader = csv.DictReader(infile)
            rows = list(reader)
        
        fieldnames = reader.fieldnames
        if 'ProcessingStatus' not in fieldnames:
            fieldnames.append('ProcessingStatus')
        
        for i, row in enumerate(rows):
            permit_number = row.get('Permit Number')
            address = row.get('Address')
            pin = row.get('Parcel Number')
            received_date = row.get('Date Finaled')
            status = row.get('ProcessingStatus', '').strip()

            identifier = pin if pin else address

            if status == 'Completed':
                logging.info(f"Skipping already completed record: Permit Number {permit_number}, Identifier: {identifier}")
                already_worked_count += 1
                continue

            proval_result = update_proval(pin, address, received_date, permit_number)
            if proval_result is None:
                logging.info("User closed the Select Permit window. Concluding script.")
                break
            elif proval_result == True:
                row['ProcessingStatus'] = 'Completed'
                logging.info(f"Successfully updated ProVal for Permit Number: {permit_number}, Identifier: {identifier}")
                processed_count += 1
            elif proval_result == 'skip':
                row['ProcessingStatus'] = 'Skipped'
                logging.info(f"Skipped processing for Permit Number: {permit_number}, Identifier: {identifier}")
                skipped_count += 1
            elif proval_result == 'already_worked':
                row['ProcessingStatus'] = 'Completed'
                logging.info(f"Record already worked: Permit Number {permit_number}, Identifier: {identifier}")
                already_worked_count += 1
            else:
                row['ProcessingStatus'] = 'Failed'
                logging.error(f"Failed to update ProVal for Permit Number: {permit_number}, Identifier: {identifier}")
                error_count += 1
            
            rows[i] = row

        with open(csv_path, 'w', newline='') as outfile:
            writer = csv.DictWriter(outfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(rows)

        logging.info(f"Updated CSV file: {csv_path}")

    except Exception as e:
        logging.error(f"Error processing CSV: {e}", exc_info=True)
    
    today = datetime.now().strftime("%Y%m%d")
    timestamp = datetime.now().strftime("%H%M%S")
    
    extract_dir = os.path.expandvars(rf'C:\Users\%USERNAME%\CertificateOfOccupancy\Extracts\{today}')
    os.makedirs(extract_dir, exist_ok=True)
    
    report_path = os.path.join(extract_dir, f'processing_summary_{timestamp}.txt')
    
    with open(report_path, 'w') as report_file:
        report_file.write(f"CSV Processing Summary\n")
        report_file.write(f"Timestamp: {today}_{timestamp}\n")
        report_file.write(f"CSV File: {csv_path}\n")
        report_file.write(f"Records Processed: {processed_count}\n")
        report_file.write(f"Records Skipped: {skipped_count}\n")
        report_file.write(f"Records Already Worked: {already_worked_count}\n")
        report_file.write(f"Records with Errors: {error_count}\n")
    
    logging.info(f"Processing summary saved to: {report_path}")

    return processed_count, skipped_count, already_worked_count, error_count

@with_kill_switch
def main():
    setup_logging()
    logging.info("Starting Certificate of Occupancy processing...")

    root = tk.Tk()
    root.withdraw()
    root.attributes('-alpha', 0)
    root.attributes('-topmost', True)
    root.overrideredirect(True)

    mode = gui_prompt("Processing Mode", "Choose processing mode:", ["CSV Input", "Hayden Email"])

    if mode is None:
        logging.info("User closed the selection window. Exiting gracefully.")
        root.destroy()
        return

    if mode == "CSV Input":
        filetypes = [("CSV Files", "*.csv")]
        csv_path = filedialog.askopenfilename(parent=root, filetypes=filetypes)
        if csv_path:
            root.destroy()
            processed, skipped, already_worked, errors = process_csv(csv_path)
            logging.info(f"Processing completed. Processed: {processed}, Skipped: {skipped}, Already Worked: {already_worked}, Errors: {errors}")
        else:
            logging.info("No CSV file selected. Exiting gracefully.")
            root.destroy()
    elif mode == "Hayden Email":
        root.destroy()
        process_hayden_emails()
    else:
        logging.error(f"Unexpected mode selected: {mode}")
        root.destroy()

def find_folder(parent_folder, target_name):
    """Recursively search for a folder by name"""
    for folder in parent_folder.Folders:
        if folder.Name == target_name:
            return folder
        subfolder = find_folder(folder, target_name)
        if subfolder:
            return subfolder
    return None

def process_hayden_emails():
    extracted_data = []
    total_processed = 0
    
    try:
        logging.info("Starting process_hayden_emails function")
        outlook = win32com.client.Dispatch("Outlook.Application").GetNamespace("MAPI")
        logging.info("Outlook namespace obtained")
        
        kcasr_permits_folder = None
        for folder in outlook.Folders:
            if folder.Name.lower() == 'kcasr permits':
                kcasr_permits_folder = folder
                break
        if kcasr_permits_folder is None:
            logging.error("Mailbox 'kcasr permits' not found.")
            return

        logging.info("'kcasr permits' folder found")
        inbox_folder = kcasr_permits_folder.Folders['Inbox']
        logging.info("Inbox folder found")

        messages = inbox_folder.Items
        logging.info(f"Total messages in folder: {len(messages)}")
        
        messages.Sort("[ReceivedTime]", True)
        logging.info("Messages sorted")

        unread_messages = messages.Restrict("[Unread] = True")
        logging.info(f"Unread messages: {len(unread_messages)}")

        message_count = 0
        for message in unread_messages:
            try:
                message_count += 1
                logging.info(f"Processing message {message_count}")

                sender = message.SenderEmailAddress
                if sender.lower() != "noreply@cityofhaydenid.us":
                    logging.debug(f"Skipping message from {sender}")
                    continue

                subject = message.Subject
                logging.info(f"Processing email from {sender}: {subject}")
                
                body = message.Body
                logging.info("Email body retrieved")
                received_date = message.ReceivedTime.strftime('%m/%d/%Y')
                logging.info(f"Received date: {received_date}")

                logging.info("Extracting address")
                address = extract_address(subject, body)
                logging.info("Extracting permit number")
                permit_number = extract_permit_number(subject, body)
                logging.info("Extracting PIN")
                pin = extract_pin(body)
                logging.info("Extracting permit type")
                permit_type = extract_permit_type(subject, body)

                logging.info(f"Extracted data - Address: {address}, PIN: {pin}, Permit Number: {permit_number}, Permit Type: {permit_type}")

                if not pin and not address:
                    logging.warning("Both PIN and address are missing. Skipping this email.")
                    continue

                logging.info("Updating ProVal")
                proval_result = update_proval(pin, address, received_date, permit_number)
                logging.info(f"ProVal update result: {proval_result}")

                if proval_result == True:
                    update_email_status(message, success=True)
                    extracted_data.append({
                        'PIN': pin,
                        'Address': address,
                        'Permit Number': permit_number,
                        'Received Date': received_date
                    })
                    total_processed += 1
                    logging.info(f"Successfully processed record for PIN: {pin or 'N/A'}, Address: {address or 'N/A'}")
                elif proval_result == 'skip':
                    update_email_status(message, success=False, skip=True)
                    logging.info(f"Skipped processing in ProVal for PIN: {pin or 'N/A'}, Address: {address or 'N/A'}")
                elif proval_result == 'already_worked':
                    update_email_status(message, success=True)
                    logging.info(f"Record already worked for PIN: {pin or 'N/A'}, Address: {address or 'N/A'}")
                else:
                    update_email_status(message, success=False)
                    logging.error(f"Failed to process record for PIN: {pin or 'N/A'}, Address: {address or 'N/A'}")

                if total_processed % 10 == 0:
                    create_csv(extracted_data)

            except Exception as e:
                logging.error(f"Error processing message {message_count}: {str(e)}", exc_info=True)

        logging.info(f"Processed {message_count} messages")

    except Exception as e:
        logging.error(f"Error in process_hayden_emails: {str(e)}", exc_info=True)
    finally:
        if extracted_data:
            create_csv(extracted_data)
        logging.info(f"Total emails processed: {total_processed}")

if __name__ == "__main__":
    main()