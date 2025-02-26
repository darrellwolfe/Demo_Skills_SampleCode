def LandBase():

    # Click Land_Tab
    if click_images_multiple(land_tab_images, direction='center', offset=100, confidence=0.75):
        logging.info("Clicked successfully land_tab_images.")
    else:
       stop_script
    check_stop_script()
    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        stop_script
    check_stop_script()
    # Click Land_Base_Tab
    if click_images_multiple(land_base_tab_images, direction='center', confidence=0.75):
        logging.info("Clicked successfully land_base_tab_images.")
    else:
       stop_script

    time.sleep(1)
    if stop_script:
        logging.info("Script stopping due to kill key press.")
        stop_script
    
    check_stop_script()
    
    # Check if the image is found and decide based on that
    if is_image_found(farm_total_acres_image, confidence=0.75):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found

        # Click to the right of Farm Acres
        if click_image_single(farm_total_acres_image, direction='right', offset=15, confidence=0.75):
            logging.info("Clicked successfully farm_total_acres_image.")
        time.sleep(1)

        # Delete the contents and send DBACRE
        pyautogui.press('delete')
        time.sleep(1)

        ensure_capslock_off()
        time.sleep(1)

        pyautogui.typewrite(str(DBLEGALACRES))
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        if stop_script:
            logging.info("Script stopping due to kill key press.")
            stop_script
            check_stop_script()
        logging.info("farm_total_acres_image Image was not found - executing alternative tasks.")
        # Perform alternative tasks
        check_stop_script()
    # Click to the right of Farm Acres
    elif click_image_single(aggregate_land_type_add_button, direction='bottom_right_corner', inset=10, confidence=0.75):
        logging.info("Clicked successfully aggregate_land_type_add_button.")
        time.sleep(1)

        ensure_capslock_off()
        time.sleep(1)

        # Send the DBACRE value after clicking the fallback button
        pyautogui.typewrite('f')
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

        ensure_capslock_off()
        time.sleep(1)

        pyautogui.typewrite(str(DBLEGALACRES))
        time.sleep(1)

        pyautogui.press('tab')
        time.sleep(1)

    else:
       stop_script

    if stop_script:
        logging.info("Script stopping due to kill key press.")
        stop_script
        

        check_stop_script()

    check_stop_script()

