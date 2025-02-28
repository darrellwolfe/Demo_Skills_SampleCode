import subprocess
import sys

# Ensure all required packages are installed
required_packages = [
    'pyautogui',
    'pyodbc',
    'numpy',
    'keyboard',
    'pytesseract',
    'opencv-python',
    'pygetwindow',
    'Pillow',
    'pywinauto',
    'tkcalendar',
    'configparser',
    'logging',
    'ctypes',
    'regex',
    'fuzzywuzzy',
    'sqlalchemy'
]

def install_packages(packages):
    for package in packages:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])

install_packages(required_packages)

# Standard Library Imports
import os  # For interacting with the operating system, such as reading/writing files
import sys  # Contains basic Python commands regarding runtime and formatting; used for exiting code
import time  # For adding delays and managing time-related functions
import logging  # For logging events, errors, and information during script execution
import configparser  # For handling configuration files (.ini)
import threading  # For running background tasks and creating concurrent threads
import ctypes  # For interacting with C data types and Windows API functions
import re  # For regular expressions, provides a powerful way to search, match, and manipulate strings based on patterns
from datetime import datetime, date  # For handling dates and times

# Third-Party Library Imports
import pyautogui  # For automating GUI interactions like mouse movements and clicks
import pyodbc  # For establishing database connections and executing SQL queries
import numpy as np  # For numerical operations and handling arrays/matrices
import keyboard  # For detecting and handling keyboard key presses
import pytesseract  # For OCR (Optical Character Recognition) to read text from images
import cv2  # From the OpenCV library, used for image processing and computer vision tasks
import pygetwindow as gw  # For interacting with window properties, such as getting window titles or bringing windows to the foreground
from PIL import Image, ImageGrab  # For working with image files and capturing screenshots
from pywinauto import Application  # For automating Windows GUI interactions, providing more advanced desktop app control

# Tkinter and Related Imports
import tkinter as tk  # For creating basic GUI elements in Python applications
from tkinter import ttk, messagebox, scrolledtext  # For advanced Tkinter widgets, dialog boxes, and scrollable text widgets
from tkcalendar import DateEntry, Calendar  # For adding calendar widgets to Tkinter GUIs