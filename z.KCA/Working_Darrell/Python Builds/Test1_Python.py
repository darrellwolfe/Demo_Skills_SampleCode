import pyautogui
import time


AIN = 'TEST'

# Function to wait for a specific image to appear and click at an adjusted position
def find_and_click(image_path, offset_x=0, offset_y=0, window_title=None, confidence=0.7):
    if window_title:
        pyautogui.getWindowsWithTitle(window_title)[0].activate()
    buttons = pyautogui.locateAllOnScreen(image_path, confidence=confidence)
    button_list = list(buttons)
    if button_list:
        x, y = button_list[0].left + offset_x, button_list[0].top + offset_y
        pyautogui.moveTo(x, y)
        pyautogui.click()
        return True
    return False

# Set focus to ProVal and open Appeals Window
pyautogui.getWindowsWithTitle("ProVal")[0].activate()
pyautogui.press('alt')  # This mimics Press and Release ALT
pyautogui.typewrite('aau')
time.sleep(2)

# Find and click the bottom right of image_7
if find_and_click(r'%BMP_DIR%\image_7.bmp', window_title="Future Property Record Exists", confidence=0.7):
    time.sleep(2)
    pyautogui.press('enter')

    # Click "Update Options" to add NEW Appeal AS52 plus AIN for Appeal ID
    pyautogui.getWindowsWithTitle("ProVal, Appeals")[0].activate()
    pyautogui.press('alt')  # This mimics Press and Release ALT
    pyautogui.typewrite('u')
    time.sleep(3)
    pyautogui.typewrite('n')

    time.sleep(2)
    pyautogui.typewrite(f'AS52_{AIN}')
    pyautogui.press('tab')
    time.sleep(2)
    pyautogui.typewrite(the_year)
    time.sleep(2)
    pyautogui.press('tab')
    pyautogui.press('enter')
    pyautogui.press(['down'] * 3)
    time.sleep(2)

    # Set Status Code
    pyautogui.press('tab')
    pyautogui.press('down')
    time.sleep(2)

    # Set Determination Type
    if find_and_click(r'%BMP_DIR%\image_5.bmp', window_title="Appeals", offset_x=10, confidence=0.7):
        pyautogui.typewrite('a')
        pyautogui.press('enter')
        time.sleep(1)
else:
    # Fallback or alternative logic
    pyautogui.press('alt')
    pyautogui.typewrite('u')
    time.sleep(1)
    pyautogui.typewrite('n')
    time.sleep(1)
    pyautogui.typewrite(f'AS52_{AIN}')
    pyautogui.press('tab')
    time.sleep(1)
    pyautogui.typewrite(the_year)
    time.sleep(1)
    pyautogui.press('tab')
    pyautogui.press('enter')
    pyautogui.press(['down'] * 3)
    time.sleep(1)

    pyautogui.press('tab')
    pyautogui.press('down')

    # Set Determination Type
    if find_and_click(r'%BMP_DIR%\image_8.bmp', window_title="Appeals", offset_x=10, confidence=0.7):
        pyautogui.typewrite('a')
        pyautogui.press('enter')
