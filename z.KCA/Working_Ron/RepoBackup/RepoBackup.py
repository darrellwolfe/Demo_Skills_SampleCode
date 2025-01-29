import os
import logging
import subprocess
from pathlib import Path
from datetime import datetime

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def create_7zip_backup(source_dir, backup_dir, archive_name):
    try:
        Path(backup_dir).mkdir(parents=True, exist_ok=True)

        seven_zip_path = r"C:\Users\rmason\Downloads\7-Zip\App\7-Zip\7z.exe"
        if not Path(seven_zip_path).exists():
            error_msg = f"7-Zip executable not found at: {seven_zip_path}"
            logging.error(error_msg)
            return False, error_msg

        archive_path = os.path.join(backup_dir, f"{archive_name}.7z")
        command = [seven_zip_path, "a", "-t7z", archive_path, source_dir]

        print(f"Creating backup for {archive_name}...")
        result = subprocess.run(command, capture_output=True, text=True)

        if result.returncode == 0:
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
        r"C:\Users\rmason\Code\Repositories\KCAsrCB",
        r"C:\Users\rmason\Code\Repositories\Kootenai_County_Assessor_CodeBase"
    ]

    today = datetime.now().strftime("%Y.%m.%d")
    backup_destination = Path(r"C:\Users\rmason\Code\Repositories\Codebase Backups") / today

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