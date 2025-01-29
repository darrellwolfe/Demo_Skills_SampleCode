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