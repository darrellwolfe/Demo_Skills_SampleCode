


def get_permit_type_up_key_pressess(description):
    # Dictionary mapping permit descriptions to their codes
    permit_type_codes = {
        "New Dwelling Permit": 1,
        "Timber Review": 2,
        "Assessment Review": 3,
        "Seg/Combo": 4,
        "Dock/Boat Slip Permit": 5,
        "PP Review": 6,
        "New Commercial Permit": 7,
        "Addition/Alt/Remodel Permit": 8,
        "Outbuilding/Garage Permit": 9,
        "Miscellaneous Permit": 10,
        "Mandatory Review": 11,
        "Roof/Siding/Wind/Mech Permit": 12,
        "Agricultural Review": 13,
        "Mobile Setting Permit": 14,
        "Potential Occupancy": 15  # Special case: string instead of a number
    }

    # Return the permit code for the given description, or None if not found
    return permit_type_codes.get(description)
# Example usage
#description = PTYPE
#code = get_permit_type_up_key_pressess(description) # This will be number of DOWN key pressess
#print(f"The number of down key presssess for '{description}' is: {code}")