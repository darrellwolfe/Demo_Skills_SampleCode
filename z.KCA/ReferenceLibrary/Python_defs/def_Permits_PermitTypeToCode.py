def get_permit_type_code(description):
    # Dictionary mapping permit descriptions to their codes
    permit_type_codes = {
        "New Dwelling Permit": 1,
        "New Commercial Permit": 2,
        "Addition/Alt/Remodel Permit": 3,
        "Outbuilding/Garage Permit": 4,
        "Miscellaneous Permit": 5,
        "Mandatory Review": 6,
        "Roof/Siding/Wind/Mech Permit": 9,
        "Agricultural Review": 10,
        "Timber Review": 11,
        "Assessment Review": 12,
        "Seg/Combo": 13,
        "Dock/Boat Slip Permit": 14,
        "PP Review": 15,
        "Mobile Setting Permit": 99,
        "Potential Occupancy": "PO"  # Special case: string instead of a number
    }

    # Return the permit code for the given description, or None if not found
    return permit_type_codes.get(description)

# Example usage
#description = PTYPE
#code = get_permit_type_code(description) # This will be permit type code in ProVal
#print(f"The code for '{description}' is: {code}")