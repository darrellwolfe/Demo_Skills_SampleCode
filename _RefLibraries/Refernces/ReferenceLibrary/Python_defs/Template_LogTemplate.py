import os
import logging

# Determine the user's home directory
user_home_dir = os.environ.get('USERPROFILE') or os.environ.get('HOME')

# Define the log directory and file based on the user's home directory
log_dir = os.path.join(str(user_home_dir), '<YOURAPPNAMEHERE>') # Don't forget to replace your app name
log_file = os.path.join(log_dir, '<YOURAPPNAMEHERE>.log')

# Ensure the log directory exists
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

logging.basicConfig(
    filename=log_file,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)