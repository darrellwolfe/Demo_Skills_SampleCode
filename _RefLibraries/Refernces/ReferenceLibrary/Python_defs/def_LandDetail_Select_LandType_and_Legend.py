#### Legend Press Down Key Function
def press_legend_key(LEGENDTYPE):

    # Convert LEGENDTYPE to an integer if it's not already
    try:
        LEGENDTYPE = int(LEGENDTYPE)
    except ValueError:
        logging.info(f"Invalid LEGENDTYPE: {LEGENDTYPE}. It must be an integer.")
        return

    # Define the mapping of LEGENDTYPE to the number of DOWN key presses
    legend_key_mapping = {
        1: 5,
        2: 6,
        3: 7,
        4: 8,
        5: 9,
        6: 10,
        7: 11,
        8: 12,
        9: 13,
        10: 14,
        11: 15,
        12: 16,
        13: 17,
        # Logic breaks here but this is how ProVal was built
        14: 20,
        15: 21,
        16: 22,
        17: 23,
        18: 24,
        19: 25,
        # Logic breaks here but this is how ProVal was built
        20: 18,
        21: 19
    }

    # Get the number of DOWN key presses corresponding to LEGENDTYPE
    presses = legend_key_mapping.get(LEGENDTYPE)

    if presses:
        # Press the DOWN key the specified number of times
        pyautogui.press('down', presses)
    else:
        logging.info(f"LEGENDTYPE {LEGENDTYPE} not found in mapping.")
        logging.info(f"LEGENDTYPE value: {LEGENDTYPE}, type: {type(LEGENDTYPE)}")

    # Example usage:
    # LEGENDTYPE = 1
    # press_legend_key(LEGENDTYPE)




def determine_land_type(pcc_code):
    # Mapping of PCC codes to Land Types
    land_type_mapping = {

        # No Land
        546: "NoLand",
        546: "NoLand",
        548: "NoLand",
        549: "NoLand",
        555: "NoLand",
        550: "NoLand",
        561: "NoLand",

        # The logic broke on 681s and 667s, but the majority are in commercial
        # Therefore, the automation will choose commercial, and the appraiser can change it if needed.
        667: "COMMERCIAL",
        681: "COMMERCIAL",

        # Residential
        520: "RES_URBAN", 541: "RES_HOMESITE",


        # Temporary Adjustment for HL891
        #520: "RES_URBAN", 541: "CA_COMMON_AREAS_CONDOS",

        515: "RES_RURAL", 537: "RES_HOMESITE",
        512: "RES_RURAL", 534: "RES_HOMESITE",
        411: "RES_RURAL",
        525: "C_CAREA",
        526: "CA_COMMON_AREAS_CONDOS",
        
        # Commercial
        441: "COMMERCIAL_CITY_LIMITS",
        451: "COMMERCIAL_CITY_LIMITS",
        461: "COMMERCIAL_CITY_LIMITS",



        421: "COMMERCIAL_CITY_LIMITS", 442: "COMMERCIAL_CITY_LIMITS",
        416: "COMMERCIAL_RURAL_SUBDIVISION", 438: "COMMERCIAL_RURAL_SUBDIVISION",
        413: "COMMERCIAL_RURAL_TRACT", 435: "COMMERCIAL_RURAL_TRACT",
        527: "CA_COMMON_AREAS_CONDOS",
        
        # Industrial
        322: "INDUSTRIAL_CITY_LIMITS", 343: "INDUSTRIAL_CITY_LIMITS",
        317: "INDUSTRIAL_RURAL_SUBDIVISION", 339: "INDUSTRIAL_RURAL_SUBDIVISION",
        314: "INDUSTRIAL_RURAL_TRACT", 336: "INDUSTRIAL_RURAL_TRACT"

    }
    
    # Return the Land Type based on the PCC code
    return land_type_mapping.get(pcc_code, "UNKNOWN")


#### Land Type Press Down Function
def press_land_key(LANDTYPE):
    # Define the mapping of LANDTYPE to the number of DOWN key presses
    land_key_mapping = {
        "RES_RURAL": 3,
        "RES_URBAN": 4,
        "RES_HOMESITE" : 14,
        "CA_COMMON_AREAS_CONDOS": 22,
        "C_CAREA": 21,
        "COMMERCIAL": 1,

        "COMMERCIAL_CITY_LIMITS": 1,
        "COMMERCIAL_RURAL_SUBDIVISION": 1,
        "COMMERCIAL_RURAL_TRACT": 1,
         
        "WASTE": 13,
        "REMAINING_ACRES": 16,
        "DEFAULT": 21
    }

    logging.info(f"LANDTYPE value: {LANDTYPE}, type: {type(LANDTYPE)}")

    # Determine the number of DOWN key presses
    # presses = land_key_mapping.get(LANDTYPE, land_key_mapping["DEFAULT"])
    presses = land_key_mapping[LANDTYPE]  # This will raise a KeyError if LANDTYPE is not found

    # Press the DOWN key the specified number of times
    pyautogui.press('down', presses)
    
    # Press ENTER to confirm the selection
    pyautogui.press('enter')

    # Example usage:
    #LANDTYPE = "RURAL"
    #press_land_key(LANDTYPE)


def determine_group_code(pcc_code):
    # Mapping of PCC codes to Land Group Codes
    group_codes = {

        # Residential
        520: "20", 541: "20H",
        515: "15", 537: "15H",
        512: "12", 534: "12H",
        525: "25L",
        526: "26LH",
        
        # Commercial
        421: "21", 442: "21",
        416: "16", 438: "16",
        413: "13", 435: "13",
        527: "27L",

        # Industrial
        322: "22", 343: "22",
        317: "17", 339: "17",
        314: "14", 336: "14",

        # Operating
        667: "67L",

        # Exempt
        681: "81L"
    }
    
    # Return the Land Group Code based on the PCC code
    return group_codes.get(pcc_code, None)

    # Example usage
    #result = determine_group_code(541)
    #result = determine_group_code(DBPCC)
    #print(f"Land Group Code for PCC 541: {result}")



def pressess_allocations(description_code):
    # Extended mapping of descriptions to the number of 'up' key presses required
    key_presses = {
        #"01 Irr (Agriculture)"
        "01": 30,
        #"03 Non-irr (Agriculture)"
        "03": 29,
        #"04 Irr grazing (Agriculture)"
        "04": 28,
        #"05 Dry grazing (Agriculture)"
        "05": 27,
        #"06 Prod forest (Timber Exempt)"
        "06": 26,
        #"07 Bare forest (Timber Exempt)"
        "07": 25,
        #"09 Mineral land"
        "09": 24,
        #"10-Non HO Eligible"
        "10": 23,
        #"10H Homesite"
        "10H": 22,
        #"11 Recreational"
        "11": 21,
        #"12-Non HO Eligible"
        "12": 20,
        #"12H Rural res tract"
        "12H": 19,
        #"13 Rural com tract"
        "13": 18,
        #"14 Rural ind tract"
        "14": 17,
        #"15-Non HO Eligible"
        "15": 16,
        #"15H Rural res sub"
        "15H": 15,
        #"16 Rural com sub"
        "16": 14,
        #"17 Rural ind sub"
        "17": 13,
        #"18 Other land-flooded"
        "18": 12,
        #"19 Public ROW"
        "19": 11,
        #"20-Non HO Eligible"
        "20": 10,
        #"20H City res lot/ac"
        "20H": 9,
        #"21 City com lot/ac"
        "21": 8,
        #"22 City ind lot/ac"
        "22": 7,
        #"25L Common area land"
        "25L": 6,
        #"26LH Res Condo land"
        "26LH": 4,
        #"27L Comm Condo land"
        "27L": 3,
        #"67L Operating prop land"
        "67L": 2,
        #"81L Exempt property land"
        "81L": 1,
        #"98 Non-Allocated Impv"
        "98": 0,  # Assuming it's the same as 99 for now
        #"99 Non-Allocated Land"
        "99": 0
    }
    
    # Return the number of 'up' key presses for the given description code
    return key_presses.get(description_code, 0)  # Return 0 if not found

    # Using this below in script
    #description_code = "15"  # Set the description code based on your scenario
    #description_code = determine_group_code(f"{DBPCC}")  # Set the description code based on your scenario
    #num_presses = pressess_allocations(description_code)
    #press_key_multiple_times('up', num_presses)
