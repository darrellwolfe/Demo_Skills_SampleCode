


























def CreatePermit():

    # Process: Enter Permit 1/2

    # Click Permits_Tab
    if click_images_multiple(permits_tab_images, direction='center', inset=10, confidence=0.90):
        logging.info("Clicked successfully permits_tab_images.")
        time.sleep(2)

    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        time.sleep(2)
        
    
    # Click Permits_Add_Button
    if click_images_multiple(permits_add_permit_button, direction='center', offset=100, confidence=0.75):
        logging.info("Clicked successfully permits_add_permit_button.")
        time.sleep(2)

        ensure_capslock_off()
        # Send Permit Number
        pyautogui.typewrite(str(PNUMBER))
        logging.info(f"Send {PNUMBER}.")
        time.sleep(1)

        pyautogui.press(['tab'])
        logging.info(f"Press Tab.")
        time.sleep(1)
        

        key_presses = get_permit_type_up_key_presses(PTYPE)

        logging.info(f"The number of down key_presses for '{PTYPE}' is: {get_permit_type_up_key_presses(PTYPE)}")
        logging.info(f"The code for '{PTYPE}' is: {get_permit_type_code(PTYPE)}")

        #Different down to Timber 2 vs Mandatory 11.
        press_key_multiple_times('down', key_presses)
        time.sleep(1)
        logging.info(f"Send {PNUMBER}.")

        press_key_multiple_times(['tab'], 3)
        time.sleep(1)
        logging.info(f"Press Tab.")


        ensure_capslock_off()
        # Send Permit Filing Date
        pyautogui.typewrite(PFILE)
        time.sleep(1)
        logging.info(f"Send {PNUMBER}.")

        press_key_multiple_times(['tab'], 3)
        time.sleep(1)
        logging.info(f"Press Tab.")

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

    

    # Send Permit Description
    ensure_capslock_off()
    pyautogui.typewrite(PDESC)
    time.sleep(1)
    logging.info("Send description")
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        


    # Process: Enter Permit 2/2
    
    # Click FieldVisit_Add_Button
    if click_image_single(add_field_visit_image_path, direction='center', inset=10, confidence=0.70):
        logging.info("Clicked successfully add_field_visit_image_path.")
        time.sleep(2)

        # Click the checkmark next to Work Assigned Date
        if click_image_single(permits_workassigneddate, direction='right', offset=5, inset=5, confidence=0.70):
            logging.info("Clicked successfully add_field_visit_image_path.")
            time.sleep(2)

            #Tab to Visit Type
            pyautogui.press('tab')
            time.sleep(0.25)

            ensure_capslock_off()
            time.sleep(0.25)

            # Set to PE Permit
            pyautogui.typewrite('p')
            time.sleep(0.25)

            # Tab to Work Due Date
            pyautogui.press('tab')
            time.sleep(0.25)

            # Set checkmark next to Work Due Date then send date
            pyautogui.press('space')
            time.sleep(0.25)
            pyautogui.press('right')
            time.sleep(0.25)
            ensure_capslock_off()
            time.sleep(0.25)
            # Permit Due Date
            pyautogui.typewrite(f"06/30/{for_year}")
            time.sleep(0.25)

            # Tab to Need to Visit
            pyautogui.press(['tab'] * 3)
            time.sleep(1)

            # Set Checkmark On
            pyautogui.press('space')
            time.sleep(0.25)


            if stop_script:
                logging.info("Script stopping due to kill key press.")

            # Save Account
            pyautogui.hotkey('ctrl', 's')
            logging.info("Save.")
            time.sleep(0.25)
            
            pyautogui.hotkey('f3')
            logging.info("Hit f3 for next parcel.")
            time.sleep(0.25)
            

        if stop_script:
            logging.info("Script stopping due to kill key press.")

