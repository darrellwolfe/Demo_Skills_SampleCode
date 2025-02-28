def CreatePermit_Timber():

    # May not need seperate timber flow, TBD... 
    
    # Process: CHECK FOR TIMBER
    # Timber Review Logic
    if TREVIEW in ["Yes", "YES", "Y", "y"]:
        logging.info("Timber YES.")

        # Send Appraiser Permit for TIMBER
        # Same as permit process except for two changes. Different down to Timber vs Mandatory. Add to Permit Description.
        # Process: Enter Permit 1/2

        # Click Permits_Tab
        if click_images_multiple(permits_tab_images, direction='center', inset=10, confidence=0.75):
            logging.info("Clicked successfully permits_tab_images.")
        time.sleep(1)
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            
        
        # Click Permits_Add_Button
        if click_images_multiple(permits_add_permit_button, direction='center', offset=100, confidence=0.75):
            logging.info("Clicked successfully permits_add_permit_button.")
            time.sleep(1)

            ensure_capslock_off()

            # Send Permit Number
            pyautogui.typewrite(PNUMBER)
            time.sleep(1)

            pyautogui.press(['tab'])
            time.sleep(1)
            
            #Different down to Timber 2 vs Mandatory 11.
            press_key_multiple_times('down', 2)
            time.sleep(1)

            press_key_multiple_times(['tab'], 3)
            time.sleep(1)

            ensure_capslock_off()

            # Send Permit Filing Date
            pyautogui.typewrite(PFILE)
            time.sleep(1)

            press_key_multiple_times(['tab'], 3)
            time.sleep(1)

            # Close Add Permit Pop-Up Box
            pyautogui.press('space')
            logging.info("Closing Add Permit pop-up, then waiting to send description")
            time.sleep(3)
        time.sleep(1)
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            
        
        # Click to right of permit_description
        if click_image_single(permit_description, direction='below', offset=5, confidence=0.75):
            logging.info("Clicked successfully permit_description.")
        time.sleep(1)

        ensure_capslock_off()

        # Send Permit Description -- Add to Permit Description.
        pyautogui.typewrite(f"{PDESC} FOR TIMBER REVIEW")
        time.sleep(1)
        logging.info("Send description")
        if stop_script:
            logging.info("Script stopping due to kill key press.")
            

        # Process: Enter Permit 2/2
        # Click FieldVisit_Add_Button
        if click_image_single(add_field_visit_image_path, direction='center', inset=10, confidence=0.75):
            logging.info("Clicked successfully add_field_visit_image_path.")

            # If found, complete adding Field Visit process
            press_key_with_modifier_multiple_times('shift', 'tab', 6)
            time.sleep(1)

            pyautogui.press('space')
            time.sleep(1)

            pyautogui.press('tab')
            time.sleep(1)

            pyautogui.typewrite('p')
            time.sleep(1)

            pyautogui.press('tab')
            time.sleep(1)

            pyautogui.press('space')
            time.sleep(1)

            pyautogui.press('right')
            time.sleep(1)

            # Permit Due Date
            pyautogui.typewrite(f"04/01/{for_year}")
            time.sleep(1)
            if stop_script:
                logging.info("Script stopping due to kill key press.")
                

    else:
        logging.info("Timber review not required, skipping this step.")
        time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        
   
   






