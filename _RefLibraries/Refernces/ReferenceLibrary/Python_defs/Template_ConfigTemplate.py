import os
import configparser

# Configuration setup
def load_config():
    config = configparser.ConfigParser()
    config_path = os.path.join(os.path.dirname(__file__), 'config.ini')
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Configuration file not found: {config_path}")
    config.read(config_path)
    return config

CONFIG = load_config()

# Create a config.ini file in the script directory with an example of a ProVal path
# coordinates and Email as defined below. Anything that is a dynamic value should be
# defined in the config code file.

"""
[Paths]
proval_executable = 'C:\Program Files (x86)\Thomson Reuters\ProVal\ProVal.exe'

[Coordinates]
permit_number_x = 100
permit_number_y = 200
occupancy_checkbox_x = 150
occupancy_checkbox_y = 250
date_field_x = 200
date_field_y = 300

[Email]
sender = noreply@cityofhaydenid.us
mailbox = kcasr permits
"""