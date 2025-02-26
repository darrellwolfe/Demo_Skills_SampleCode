# After ensuring all packages are installed, you can import them as needed in your script
import pyautogui  # For automating GUI interactions like mouse movements and clicks
import pyodbc  # For establishing database connections and executing SQL queries
import time  # For adding delays and managing time-related functions
import numpy as np  # For numerical operations and handling arrays/matrices
import keyboard  # For detecting and handling keyboard key presses
import threading  # For running background tasks and creating concurrent threads
import tkinter as tk  # For creating basic GUI elements in Python applications
from tkinter import ttk, messagebox  # For advanced Tkinter widgets and displaying dialog boxes
import pytesseract  # For OCR (Optical Character Recognition) to read text from images
from PIL import Image  # For working with image data
import cv2  # For image processing and computer vision tasks (OpenCV library)
import ctypes  # For interacting with C data types and Windows API functions
from tkcalendar import DateEntry  # For adding a calendar widget to Tkinter GUIs
import logging  # For logging events, errors, and information during script execution
from datetime import datetime # For handling dates and times
import re # The import re statement in Python imports the regular expressions (regex) module, which provides a powerful way to search, match, and manipulate strings based on patterns.
import sys # Contains basic Python commands regarding runtime and formatting; used for exiting code


#### PRESS & CLICK KEY LOGIC
def press_key_with_modifier_multiple_times(modifier, key, times):
    for _ in range(times):
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
        pyautogui.hotkey(modifier, key)

def press_key_multiple_times(key, times):
    for _ in range(times):
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            break
        pyautogui.press(key)








# Call below in script

    # pyautogui.typewrite()
    pyautogui.typewrite(str(DBACRE))
    pyautogui.typewrite(str(DBAIN))
    pyautogui.typewrite(MemoTXT)
    pyautogui.typewrite(PNUMBER)
    pyautogui.typewrite('f')
    pyautogui.typewrite(f"04/01/{ForYear}")
    pyautogui.typewrite(f"{PDESC} FOR TIMBER REVIEW")
    pyautogui.typewrite('p')

    # pyautogui.hotkey()
    pyautogui.hotkey('ctrl', 'o')
    pyautogui.hotkey('ctrl', 'shift', 'm')

    # pyautogui.press()
    pyautogui.press(['tab'])
    pyautogui.press(['delete'])
    pyautogui.press('enter')
    pyautogui.press('l')
    pyautogui.press('space')
    pyautogui.press('right')

    # press_key_multiple_times
    press_key_multiple_times('up', 12)
    press_key_multiple_times('down', 4)
    press_key_multiple_times(['tab'], 3)

    # press_key_with_modifier_multiple_times
    press_key_with_modifier_multiple_times('shift', 'tab', 6)
