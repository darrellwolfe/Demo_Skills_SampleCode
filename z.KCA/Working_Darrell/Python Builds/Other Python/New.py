"""
Send Land Base Farm Acres variable
"""
set_focus_and_type('ProVal', str(DBACRE))
time.sleep(1)

# Maximize the ProVal window
app = Application(backend="uia").connect(title="ProVal")
window = app.window(title="ProVal")
window.maximize()
time.sleep(1)

# Debugging: Print the screen regions for verification
print(f"Top Half Region: {top_half}")
print(f"Bottom Half Region: {bottom_half}")

# Debugging: Attempt to capture and print the text in the top half region
print("Capturing text in the top half region...")
captured_text = read_text_in_region(region=top_half)
print(f"Captured Text: {captured_text}")

print("Attempting to locate and click on the 'Land' tab...")
if "Land" in captured_text:
    click_element("Land", land_tab_regions)
    print("Clicked on the 'Land' tab.")
    time.sleep(1)
else:
    print("Could not locate the 'Land' element in the captured text.")
    # Retry mechanism: capture text again
    print("Retrying capture and click for 'Land' tab...")
    captured_text = read_text_in_region(region=top_half)
    print(f"Captured Text on Retry: {captured_text}")
    if "Land" in captured_text:
        click_element("Land", land_tab_regions)
        print("Clicked on the 'Land' tab on retry.")
    else:
        print("Failed to locate the 'Land' element after retry.")

# Locate and click on the "Land Base SubTab" tab if it exists
print("Attempting to locate and click on the 'Land Base' sub-tab...")
click_element("Land Base", land_base_regions)
print("Clicked on the 'Land Base' sub-tab.")
time.sleep(1)

# From the Land Base sub-tab, find the Aggregate Land window and click the ADD button below
# Call this function where needed in your script
print("Attempting to click the specific Windows UI button...")
try:
    click_windows_button("WindowsForms10.BUTTON.app.0.13965fa_r8_ad110")
    print("Clicked the specific Windows UI button.")
except Exception as e:
    print(f"Failed to click the specific Windows UI button: {e}")

time.sleep(1)

pyautogui.typewrite(str(DBACRE))
pyautogui.press('tab')
