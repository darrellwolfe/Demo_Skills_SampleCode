import pyautogui
import pyodbc
import time
import keyboard
import threading
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext

# Configuration for database connection
db_connection_string = (
    "Driver={SQL Server};"
    "Server=astxdbprod;"
    "Database=GRM_Main;"
    "Trusted_Connection=yes;"
)

# Function to handle form submission
def on_submit():
    global AINLIST, MemoTXT, PDESC, PFILE, PNUMBER, TREVIEW
    AINLIST = entry_ainlist.get()
    MemoTXT = entry_memotxt.get()
    PDESC = entry_pdesc.get()
    PFILE = entry_pfile.get()
    PNUMBER = entry_pnumber.get()
    TREVIEW = entry_treview.get().upper()
    
    if not AINLIST or not MemoTXT or not PDESC or not PFILE or not PNUMBER or not TREVIEW:
        messagebox.showerror("Input Error", "All input fields are required.")
        return
    
    root.destroy()  # Close the GUI

# Create the main tkinter window
root = tk.Tk()
root.title("User Input Form")

# Define and place the input fields
ttk.Label(root, text="List all AINs in Mapping Packet (separated by comma):").grid(column=0, row=0, padx=10, pady=5)
entry_ainlist = ttk.Entry(root, width=50)
entry_ainlist.grid(column=1, row=0, padx=10, pady=5)

ttk.Label(root, text="Insert Memo text for mapping packet:").grid(column=0, row=1, padx=10, pady=5)
entry_memotxt = ttk.Entry(root, width=50)
entry_memotxt.grid(column=1, row=1, padx=10, pady=5)

ttk.Label(root, text="Insert Permit Description:").grid(column=0, row=2, padx=10, pady=5)
entry_pdesc = ttk.Entry(root, width=50)
entry_pdesc.grid(column=1, row=2, padx=10, pady=5)

ttk.Label(root, text="Filing Date (Top Date):").grid(column=0, row=3, padx=10, pady=5)
entry_pfile = ttk.Entry(root, width=50)
entry_pfile.grid(column=1, row=3, padx=10, pady=5)

ttk.Label(root, text="Permit Number (Bottom Date):").grid(column=0, row=4, padx=10, pady=5)
entry_pnumber = ttk.Entry(root, width=50)
entry_pnumber.grid(column=1, row=4, padx=10, pady=5)

ttk.Label(root, text="Timber or AG review? Y/N:").grid(column=0, row=5, padx=10, pady=5)
entry_treview = ttk.Entry(root, width=50)
entry_treview.grid(column=1, row=5, padx=10, pady=5)

# Add the submit button
submit_button = ttk.Button(root, text="Submit", command=on_submit)
submit_button.grid(column=0, row=6, columnspan=2, pady=20)

# Start the GUI event loop
root.mainloop()

# Ensure inputs are valid
if not AINLIST or not MemoTXT or not PDESC or not PFILE or not PNUMBER or not TREVIEW:
    print("All input fields are required.")
    exit()

# Connect to the database
conn = pyodbc.connect(db_connection_string)
cursor = conn.cursor()

# Fetch data from the database
query = f"SELECT pm.AIN, pm.LegalAcres FROM TSBv_Parcelmaster AS pm WHERE pm.AIN IN ({AINLIST})"
cursor.execute(query)
rows = cursor.fetchall()

# Global flag to indicate if the script should be stopped
stop_script = False

def set_focus_and_type(window_title, keys):
    window = pyautogui.getWindowsWithTitle(window_title)
    if window:
        window[0].activate()
        pyautogui.typewrite(keys)

def press_key_multiple_times(key, times):
    for _ in range(times):
        if stop_script:
            break
        pyautogui.press(key)

def monitor_kill_key():
    global stop_script
    keyboard.wait('esc')  # Set 'esc' as the kill key
    stop_script = True

# Start the kill key monitoring in a separate thread
kill_key_thread = threading.Thread(target=monitor_kill_key)
kill_key_thread.daemon = True
kill_key_thread.start()

for row in rows:
    if stop_script:
        break
    DBAIN, DBACRE = row
    set_focus_and_type('ProVal', DBAIN)

    ## FIRST LOOK UP EACH AIN
    # Open Parcel Selection and set focus to ProVal window
    pyautogui.hotkey('ctrl', 'o')
    time.sleep(1)
    
    # Navigate to the top radio button on the account lookup pop-up window
    press_key_multiple_times('up', 20)
    time.sleep(1)
    
    # Press down four times to get to the AIN radio button
    press_key_multiple_times('down', 4)
    time.sleep(1)
    
    # Tab to the From field
    pyautogui.press(['tab'])
    time.sleep(1)
    
    # Delete contents
    pyautogui.press(['delete'])
    time.sleep(1)
    
    # Send the first AIN, then iterate through loop
    pyautogui.typewrite(str(DBAIN))
    time.sleep(1)
    
    # Press Enter to complete account look up
    pyautogui.press('enter')
    time.sleep(1)

    ## NOW BEGIN INPUT STEPS
    # Create LAND Memo
    # Open the new memo pop up window
    set_focus_and_type('ProVal', MemoTXT)
    pyautogui.hotkey('ctrl', 'shift', 'm')
    time.sleep(2)

    # Pop Up window should land on (New Memo), Press Enter
    pyautogui.press('enter')
    time.sleep(1)

    # Press l (lower case L) for LAND LAND INFORMATION
    pyautogui.press('l')
    time.sleep(1)

    # To accept LAND as the option, press Enter/OK
    pyautogui.press('enter')
    time.sleep(1)

    # Insert Memo text from the user input
    pyautogui.typewrite(MemoTXT)
    time.sleep(1)

    # Press Tab to the DONE button
    pyautogui.press('tab')
    time.sleep(1)

    # Press Done
    pyautogui.press('enter')
    time.sleep(1)

    # Add Legal Acres
    set_focus_and_type('ProVal', str(DBACRE))
    pyautogui.hotkey('ctrl', 'shift', 'l')
    time.sleep(2)
    pyautogui.typewrite(str(DBACRE))
    pyautogui.press('enter')

    # Add Permit
    set_focus_and_type('ProVal', PNUMBER)
    pyautogui.hotkey('ctrl', 'shift', 'p')
    time.sleep(2)
    pyautogui.typewrite(PNUMBER)
    pyautogui.press('tab')
    pyautogui.typewrite('S')
    pyautogui.press(['tab', 'tab', 'tab'])
    pyautogui.typewrite(PFILE)
    pyautogui.press('tab')
    pyautogui.typewrite(PDESC)
    pyautogui.press('enter')

    if TREVIEW == 'Y':
        # Timber or AG Review
        set_focus_and_type('ProVal', PNUMBER)
        pyautogui.hotkey('ctrl', 'shift', 't')
        time.sleep(2)
        pyautogui.typewrite(PNUMBER)
        pyautogui.press('tab')
        pyautogui.typewrite('T')
        pyautogui.press(['tab', 'tab', 'tab'])
        pyautogui.typewrite(PFILE)
        pyautogui.press('tab')
        pyautogui.typewrite(PDESC)
        pyautogui.press('enter')

    # Save changes
    pyautogui.hotkey('ctrl', 's')
    time.sleep(2)

# Close the database connection
conn.close()

"""
Notes:
if AIN:
    press_key_multiple_times('down', 4)
elif PIN:
    press_key_multiple_times('down', 0)

## For testing purposes, PIN: KC-DGW = AIN: 345134

"""

# Version History
# NEW v1 07/26/2024
# NEW v2 07/26/2024

