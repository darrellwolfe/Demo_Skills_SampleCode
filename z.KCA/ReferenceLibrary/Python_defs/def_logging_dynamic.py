import os
import logging
import configparser
import time
from datetime import datetime, date
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
from tkcalendar import Calendar
import pyautogui
import pygetwindow as gw
from pywinauto import Application
import pyodbc

### Logging Setup
# Determine the user's home directory
user_home_dir = os.environ.get('USERPROFILE') or os.environ.get('HOME')

# Update LogNameHere to your actual log name
log_name = 'ProValAutomation'
log_dir = os.path.join(user_home_dir, log_name)
log_file = os.path.join(log_dir, f'{log_name}.log')

# Ensure the log directory exists
os.makedirs(log_dir, exist_ok=True)

logging.basicConfig(
    filename=log_file,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

# Roaming Directory for Configurations
roaming_dir = os.path.join(os.environ.get('APPDATA', ''), log_name)
os.makedirs(roaming_dir, exist_ok=True)

CONFIG_FILE = os.path.join(roaming_dir, 'config.ini')
DEFAULT_PROVAL_PATH = "C:/Program Files (x86)/Thomson Reuters/ProVal/ProVal.exe"

# Sample Variable
# variable_here = "I Am A Variable"

# Logging Examples
logging.info("Starting the ProVal Automation Script")
logging.info(f"Using the default ProVal path: {DEFAULT_PROVAL_PATH}")
# logging.info(f"Variable value: {variable_here}")
