import pyautogui
import time


AIN = 'TEST'
INITIALS = 'DGW'
APPEALYEAR = '2025'


# Set focus to ProVal and open Appeals Window
pyautogui.getWindowsWithTitle("ProVal")[0].activate()
pyautogui.press('alt')  # This mimics Press and Release ALT
pyautogui.typewrite('aau')
time.sleep(2)

# Open Appeals
pyautogui.press('alt')
pyautogui.typewrite('u')
time.sleep(1)

# Start New Appeal
pyautogui.typewrite('n')
time.sleep(1)

# Send Appeal Number
pyautogui.typewrite(f'AS52_{APPEALYEAR}_{AIN}')
pyautogui.press('tab')
time.sleep(1)

# Send Year
pyautogui.typewrite(F'{APPEALYEAR}')
time.sleep(1)

# Tab to OK and Click OK
pyautogui.press('tab')
pyautogui.press('enter')
time.sleep(1)


# Lands on "Local Justification" Press Down to Written
pyautogui.press(['down'] * 3)
time.sleep(1)

# Tab to Status Code
pyautogui.press(['tab'] * 5)
time.sleep(1)

# Set Status Code to #3, Pending Outcome
pyautogui.press(['down'] * 3)
time.sleep(1)


# Tab to Assigned To
pyautogui.press(['tab'] * 5)
time.sleep(1)

# Send Appraiser Initials
pyautogui.typewrite(f'{INITIALS}')
time.sleep(1)


# Tab to OK and Click OK
pyautogui.press(['tab'] * 13)
pyautogui.press('enter')
time.sleep(1)
