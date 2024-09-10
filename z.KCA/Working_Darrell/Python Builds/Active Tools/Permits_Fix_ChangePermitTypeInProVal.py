import pyautogui
import time

# Define the region of interest where "Permit Type:" is expected to appear
# The coordinates are based on your provided screen region
roi = (364, 563, 766, 565)  # left, top, width, height

# Function to find the image within the specified region
def find_image_in_roi(image_path, roi, confidence=0.8):
    try:
        return pyautogui.locateCenterOnScreen(image_path, region=roi, confidence=confidence)
    except:
        return None

# Main automation function
def automate_proval_interaction():
    r = 0
    while r < 1:
        r += 1
        time.sleep(1)
        pyautogui.getWindowsWithTitle("ProVal")[0].activate()
        time.sleep(1.5)
        
        # Find the image and click to the right of it within the defined region
        image_position = find_image_in_roi('S:/Common/Comptroller Tech/Reports/Python/py_images/Proval_PermitType.bmp', roi, 0.8)
        if image_position is not None:
            pyautogui.moveTo(image_position.x + 10, image_position.y)
            pyautogui.click()
            time.sleep(1)
            pyautogui.press('up', presses=20)
            time.sleep(1)
            pyautogui.press('tab')
            time.sleep(1)
            pyautogui.press('f3')
            time.sleep(1)
            pyautogui.press('enter')
            time.sleep(1)
        else:
            print("Image not found. Exiting loop.")
            break

# Run the automation function
automate_proval_interaction()
