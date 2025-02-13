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
from tkinter import ttk
import pygetwindow as gw
from functools import wraps
from datetime import datetime

# Configuration setup
def load_config():
    config = configparser.ConfigParser()
    config_path = os.path.join(os.path.dirname(__file__), 'config.ini')
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Configuration file not found: {config_path}")
    config.read(config_path)
    return config

CONFIG = load_config()

# Set up logging
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

def extract_address(body):
    match = re.search(r'work at (.+?) has been issued', body)
    return match.group(1) if match else None

def extract_permit_number(body):
    match = re.search(r'PERMIT INFORMATION:.*?(\w+)', body)
    return match.group(1) if match else None

def check_for_kill_switch():
    if keyboard.is_pressed('esc'):
        logging.info("Kill switch activated. Exiting program.")
        sys.exit(0)

def intelligent_pause(seconds):
    end_time = time.time() + seconds
    while time.time() < end_time:
        check_for_kill_switch()
        time.sleep(0.1)

def with_kill_switch(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except KeyboardInterrupt:
            logging.info("Program interrupted by user.")
            sys.exit(0)
    return wrapper

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

def user_interaction(message):
    print(message)
    print("Press 'c' to continue to next record, 'r' to retry this record, 'k' to skip this record, or 'e' to exit.")
    while True:
        if keyboard.is_pressed('c'):
            return 'continue'
        elif keyboard.is_pressed('r'):
            return 'retry'
        elif keyboard.is_pressed('k'):
            return 'skip'
        elif keyboard.is_pressed('e'):
            return 'exit'
        time.sleep(0.1)

def manual_pin_entry():
    while True:
        pin = input("Enter the PIN manually (or 'skip' to skip this record): ")
        if pin.lower() == 'skip':
            return None
        if re.match(r'^\w+$', pin):  # Basic validation: non-empty alphanumeric string
            return pin
        print("Invalid PIN format. Please try again.")

def activate_window(window_title):
    try:
        # Find the window
        hwnd = win32gui.FindWindow(None, window_title)
        if hwnd == 0:
            logging.error(f"Window '{window_title}' not found")
            return False

        # Activate the window
        shell = win32com.client.Dispatch("WScript.Shell")
        shell.SendKeys('%')
        win32gui.SetForegroundWindow(hwnd)
        return True
    except Exception as e:
        logging.error(f"Error activating window '{window_title}': {str(e)}")
        return False

def select_permit_gui():
    result = [None]
    
    def on_button_click(choice):
        result[0] = choice
        root.quit()
    
    root = tk.Tk()
    root.title("Select Permit Number")
    root.attributes('-topmost', True)  # Make the window stay on top
    
    frame = ttk.Frame(root, padding="10")
    frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
    
    ttk.Label(frame, text="Select the permit number:").grid(column=0, row=0, pady=5)
    
    for i in range(1, 11):
        ttk.Button(frame, text=str(i), command=lambda x=i: on_button_click(x)).grid(column=0, row=i, padx=2, pady=2, sticky='ew')
    
    ttk.Button(frame, text="Skip", command=lambda: on_button_click('skip')).grid(column=0, row=11, padx=2, pady=2, sticky='ew')
    
    root.mainloop()
    root.destroy()
    
    return result[0]

def calculate_permit_coordinates(base_x, base_y, permit_number):
    y_offset = (permit_number - 1) * 25  # 25 pixels between each permit
    return base_x, base_y + y_offset

def scroll_to_permit(permit_number):
    if permit_number > 9:  # Assuming we need to scroll after the 9th permit
        scroll_amount = (permit_number - 9) * 25
        pyautogui.scroll(-scroll_amount)  # Negative value to scroll down
        time.sleep(0.5)  # Wait for the scroll to complete

def process_email(message):
    try:
        # Mark the message as read
        message.UnRead = False
        
        # Add a category to indicate it's been processed
        if "Processed" not in message.Categories:
            message.Categories += "Processed;"
        
        # Remove any existing flag
        if message.FlagStatus != 0:
            message.FlagStatus = 0
        
        # Add a checkmark category if it doesn't exist
        if "Checkmark" not in message.Categories:
            message.Categories += "Checkmark;"
        
        # Save the changes
        message.Save()
        
        logging.info(f"Processed email: {message.Subject}")
        return True
    except Exception as e:
        logging.error(f"Error processing email: {message.Subject}. Error: {str(e)}")
        return False

def is_processed(message):
    return "Processed" in message.Categories

def mark_as_processed(message):
    if "Processed" not in message.Categories:
        message.Categories += "Processed;"
    if "Checkmark" not in message.Categories:
        message.Categories += "Checkmark;"
    message.UnRead = False
    message.Save()

@with_kill_switch
def update_proval(pin, occupancy_date):
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
        intelligent_pause(2)
        pyautogui.press('up', presses=11)
        pyautogui.press('tab')
        intelligent_pause(1)
        pyautogui.typewrite(pin)
        pyautogui.press('enter')
        logging.info(f"Entered PIN: {pin}")
        intelligent_pause(5)

        # Prompt user for permit selection using GUI
        selected_permit = select_permit_gui()
        if selected_permit == 'skip':
            logging.info("User chose to skip this record.")
            return 'skip'
        elif selected_permit is None:
            logging.info("User cancelled permit selection.")
            return False

        scroll_to_permit(selected_permit)
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
        intelligent_pause(1)

        # Enter the occupancy date
        month, day, year = occupancy_date.split('/')
        
        pyautogui.click(x=month_certified_x, y=date_certified_y)
        pyautogui.typewrite(month)
        intelligent_pause(0.5)
        
        pyautogui.click(x=day_certified_x, y=date_certified_y)
        pyautogui.typewrite(day)
        intelligent_pause(0.5)
        
        pyautogui.click(x=year_certified_x, y=date_certified_y)
        pyautogui.typewrite(year)
        
        logging.info(f"Entered Occupancy Date: {occupancy_date}.")

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

@with_kill_switch
def main():
    setup_logging()
    logging.info("Starting email processing...")
    extracted_data = []
    total_processed = 0
    max_messages = 100  # Set a maximum number of messages to process

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
        messages = inbox_folder.Items
        messages.Sort("[ReceivedTime]", True)
        message = messages.GetFirst()

        while message and total_processed < max_messages:
            if not message.Unread:
                message = messages.GetNext()
                continue

            sender = message.SenderEmailAddress
            subject = message.Subject

            if sender.lower() != "noreply@cityofhaydenid.us":
                logging.info(f"Skipped email from unexpected sender: {sender}")
                mark_as_processed(message)
                message = messages.GetNext()
                continue

            if is_processed(message):
                logging.info(f"Skipped already processed email: {subject}")
                message.UnRead = False
                message.Save()
                message = messages.GetNext()
                continue

            logging.info(f"Processing email from {sender}: {subject}")
            body = message.Body
            received_date = message.ReceivedTime.strftime('%m/%d/%Y')
            pin = extract_pin(body)
            address = extract_address(body)
            permit_number = extract_permit_number(body)

            if not pin:
                logging.warning(f"Could not extract PIN from email: {subject}")
                action = user_interaction("PIN not found. Do you want to enter the PIN manually?")
                if action in ['skip', 'continue']:
                    logging.info(f"Skipped record: {subject}")
                    mark_as_processed(message)
                    message = messages.GetNext()
                    continue
                elif action == 'exit':
                    logging.info("User chose to exit. Stopping processing.")
                    break
                pin = manual_pin_entry()
                if not pin:
                    logging.info(f"Skipped record: {subject}")
                    mark_as_processed(message)
                    message = messages.GetNext()
                    continue

            action = user_interaction(f"PIN found: {pin}\nAddress: {address or 'Not found'}\nPermit Number: {permit_number or 'Not found'}")
            if action == 'skip':
                logging.info(f"Skipped record: {subject}")
                mark_as_processed(message)
                message = messages.GetNext()
                continue
            elif action == 'exit':
                logging.info("User chose to exit. Stopping processing.")
                break

            proval_result = update_proval(pin, received_date)
            if proval_result == 'skip':
                logging.info(f"Skipped record: {subject}")
                mark_as_processed(message)
                message = messages.GetNext()
                continue
            elif proval_result:
                logging.info(f"Successfully updated ProVal for PIN: {pin}")
                email_processed = process_email(message)
                if email_processed:
                    logging.info(f"Successfully processed email: {subject}")
                    total_processed += 1
                    extracted_data.append({
                        'PIN': pin,
                        'Address': address or 'Not available',
                        'Permit Number': permit_number or 'Not available',
                        'Received Date': received_date
                    })
                    action = user_interaction("CO entered correctly. Press 'c' to continue to next record, 'r' to retry, or 'e' to exit.")
                    if action in ['continue', 'skip']:
                        message = messages.GetNext()
                        continue
                    elif action == 'retry':
                        continue
                    elif action == 'exit':
                        break
                else:
                    logging.error(f"Failed to process email: {subject}")
            else:
                logging.error(f"Failed to update ProVal for PIN: {pin}")

            action = user_interaction("Error processing email or updating ProVal. Do you want to retry, skip this record, or exit?")
            if action in ['skip', 'continue']:
                mark_as_processed(message)
                message = messages.GetNext()
                continue
            elif action == 'retry':
                continue
            elif action == 'exit':
                break

            check_for_kill_switch()

        logging.info(f"Email processing completed. Total processed: {total_processed}")
        if extracted_data:
            output_directory = CONFIG.get('Output', 'csv_directory', fallback=None)
            csv_file = create_csv(extracted_data, output_directory)
            print(f"Final CSV file created: {csv_file}")

    except Exception as e:
        logging.error(f"Error during email processing: {e}", exc_info=True)

if __name__ == "__main__":
    main()