import os
import logging
import subprocess
from pathlib import Path
from datetime import datetime

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def create_7zip_backup(source_dir, backup_dir, archive_name):
    try:
        # Create backup directory with explicit permissions
        Path(backup_dir).mkdir(parents=True, exist_ok=True, mode=0o755)

        # Use 'which' to find 7zz executable
        try:
            seven_zip_path = subprocess.check_output(['which', '7zz']).decode().strip()
        except subprocess.CalledProcessError:
            error_msg = "7zz not found. Please install it using 'brew install sevenzip'"
            logging.error(error_msg)
            return False, error_msg

        archive_path = os.path.join(backup_dir, f"{archive_name}.7z")
        
        # Remove existing archive if it exists
        if os.path.exists(archive_path):
            os.remove(archive_path)

        command = [seven_zip_path, "a", "-t7z", archive_path, source_dir]

        print(f"\nCreating backup for {archive_name}...")
        
        # Run with sudo if needed (you'll need to enter password)
        result = subprocess.run(command, capture_output=True, text=True)

        if result.returncode == 0:
            # Set permissions on the created archive
            os.chmod(archive_path, 0o644)
            logging.info(f"Successfully created backup: {archive_path}")
            return True, archive_path
        else:
            logging.error(f"Failed to create backup: {archive_path}")
            logging.error(f"Error: {result.stderr}")
            return False, result.stderr

    except Exception as e:
        error_msg = f"An error occurred while creating backup for {source_dir}: {str(e)}"
        logging.error(error_msg)
        return False, error_msg

def main():
    directories_to_backup = [
        os.path.expanduser("~/Code/Repositories/KCAsrCB"),
        os.path.expanduser("~/Code/Repositories/Kootenai_County_Assessor_CodeBase")
    ]

    today = datetime.now().strftime("%Y.%m.%d")
    backup_destination = Path(os.path.expanduser("~/Code/Repositories/Codebase Backups")) / today

    all_backups_successful = True
    status_report = []

    for directory in directories_to_backup:
        dir_name = Path(directory).name
        success, result = create_7zip_backup(directory, str(backup_destination), dir_name)
        
        status_report.append({
            'directory': dir_name,
            'success': success,
            'result': result
        })
        
        if not success:
            all_backups_successful = False

    print("\nBackup Status Report:")
    print("=" * 50)
    for status in status_report:
        status_symbol = "✓" if status['success'] else "✗"
        print(f"{status_symbol} {status['directory']}")
        if not status['success']:
            print(f"  Error: {status['result']}")
    print("=" * 50)
    print(f"Overall Status: {'SUCCESS' if all_backups_successful else 'FAILED'}")

if __name__ == "__main__":
    main()