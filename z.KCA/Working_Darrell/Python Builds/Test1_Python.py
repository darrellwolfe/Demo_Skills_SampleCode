# Businses Personal Property

BPP_MPPV_AssetsInput_Category = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_AssetsInput_Category.PNG'
BPP_MPPV_AssetsInput_New = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_AssetsInput_New.PNG'
BPP_MPPV_AssetsInput_Save = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_AssetsInput_Save.PNG'
BPP_MPPV_EFFDate = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_EFFDate.PNG'
BPP_MPPV_IFLogic_AnnualFileBlank = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_AnnualFileBlank.PNG'
BPP_MPPV_IFLogic_AnnualFileBlank_YES = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_AnnualFileBlank_YES.PNG'
BPP_MPPV_IFLogic_SaveAssetChanges = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_SaveAssetChanges.PNG'
BPP_MPPV_IFLogic_SaveAssetChanges_YES = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_SaveAssetChanges_YES.PNG'
BPP_MPPV_IFLogic_ValueUpdate = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_ValueUpdate.PNG'
BPP_MPPV_IFLogic_ValueUpdate_YES = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_IFLogic_ValueUpdate_YES.PNG'
BPP_MPPV_SearchBy = r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_SearchBy.PNG'


BPP_MPPV_Tab_AssetsTab = [
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_Tab_Assets_Unseleted.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_Tab_Assets_Seleted.PNG',
    r'S:\Common\Comptroller Tech\Reports\Python\py_images\BPP_MPPV_Tab_Assets_Seleted_2.PNG'
]


    # Check if the image is found and decide based on that
    if is_image_found(xxx, confidence=0.75):
        logging.info("Image was found - executing related tasks.")
        # Perform tasks related to the image being found

        if click_image_single(xxx, direction='right', offset=15, confidence=0.75):
            logging.info("Clicked successfully xxx.")
        time.sleep(1)


    if click_images_multiple(xxx, direction='center', confidence=0.75):
        logging.info("Clicked successfully xxx.")
    else:
       stop_script



