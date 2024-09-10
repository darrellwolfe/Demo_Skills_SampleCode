


import re # The import re statement in Python imports the regular expressions (regex) module, which provides a powerful way to search, match, and manipulate strings based on patterns.
from datetime import datetime # For handling dates and times


# This will call into both the logging config and the AINLogProcessor config
mylog_filename = 'C:/Users/dwolfe/Documents/Kootenai_County_Assessor_CodeBase-1/Working_Darrell/Logs_Darrell/MappingPacketsAutomation.log'
#mylog_filename = 'S:/Common/Comptroller Tech/Reports/Python/Auto_Mapping_Packet/MappingPacketsAutomation.log'

# After hitting the play button in Visual Studio Code, enter dates in following format when prompted in Terminal
#Enter start date (YYYY-MM-DD): 2024-08-26
#Enter end date (YYYY-MM-DD): 2024-08-30


import re
from datetime import datetime

class AINLogProcessor_Week:
    def __init__(self, log_filename, start_date=None, end_date=None):
        self.log_filename = mylog_filename
        self.unique_ains = set()
        # Set up date range
        self.start_date = datetime.strptime(start_date, '%Y-%m-%d') if start_date else datetime.now()
        self.end_date = datetime.strptime(end_date, '%Y-%m-%d') if end_date else self.start_date
        self.pattern = re.compile(r'(\d{4}-\d{2}-\d{2}) \d{2}:\d{2}:\d{2},\d{3} - INFO - Sent AIN (\d{6})')

    def process_log(self):
        # Open and read the log file
        with open(self.log_filename, 'r') as log_file:
            for line in log_file:
                match = self.pattern.search(line)
                if match:
                    log_date = datetime.strptime(match.group(1), '%Y-%m-%d')
                    # Check if the date in the line is within the specified range
                    if self.start_date <= log_date <= self.end_date:
                        # Add the matched AIN to the set
                        self.unique_ains.add(match.group(2))

    def get_unique_ains(self):
        # Convert the set to a sorted list if needed
        return sorted(self.unique_ains)

    def print_unique_ains(self):
        unique_ains_list = self.get_unique_ains()
        print(f"Unique AINs count from {self.start_date.strftime('%Y-%m-%d')} to {self.end_date.strftime('%Y-%m-%d')}: {len(unique_ains_list)}")
        for ain in unique_ains_list:
            print(ain)

# Usage example with date input
if __name__ == "__main__":
    # Example usage: User inputs dates when running the script
    log_filename = 'path_to_log_file.log'
    start_date = input("Enter start date (YYYY-MM-DD): ")
    end_date = input("Enter end date (YYYY-MM-DD): ")
    
    log_processor = AINLogProcessor_Week(log_filename, start_date, end_date)
    log_processor.process_log()
    log_processor.print_unique_ains()



class AINLogProcessor_Today:
    def __init__(self, log_filename):
        self.log_filename = log_filename
        self.unique_ains = set()
        self.today_date = datetime.now().strftime('%Y-%m-%d')
        self.pattern = re.compile(r'Sent AIN (\d{6})')

    def process_log(self):
        # Open and read the log file
        with open(self.log_filename, 'r') as log_file:
            for line in log_file:
                # Check if the line contains today's date
                if self.today_date in line:
                    # Search for the pattern in the line
                    match = self.pattern.search(line)
                    if match:
                        # Add the matched AIN to the set
                        self.unique_ains.add(match.group(1))

    def get_unique_ains(self):
        # Convert the set to a sorted list if needed
        return sorted(self.unique_ains)

    def print_unique_ains(self):
        unique_ains_list = self.get_unique_ains()
        print(f"Unique AINs count for {self.today_date}: {len(unique_ains_list)}")
        for ain in unique_ains_list:
            print(ain)

# Call AINLogProcessor
if __name__ == "__main__":
    # Create an instance of the AINLogProcessor
    log_processor = AINLogProcessor_Today(mylog_filename)

    # Call these where you want the print out in the LOG:
    # Process the log file
    log_processor.process_log()

    # Print the unique AINs
    log_processor.print_unique_ains()
