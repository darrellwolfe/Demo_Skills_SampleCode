import os
import time
import logging
import subprocess
from tqdm import tqdm
from pathlib import Path
from datetime import datetime

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def create_7zip_backup(source_dir, backup_dir, archive_name, total_repos, current_repo):
    try:
        Path(backup_dir).mkdir(parents=True, exist_ok=True)

        # Use 'which' to find 7zz executable
        try:
            seven_zip_path = subprocess.check_output(['which', '7zz']).decode().strip()
        except subprocess.CalledProcessError:
            error_msg = "7zz not found. Please install it using 'brew install sevenzip'"
            logging.error(error_msg)
            return False, error_msg

        archive_path = os.path.join(backup_dir, f"{archive_name}.7z")
        command = [seven_zip_path, "a", "-t7z", archive_path, source_dir]

        print(f"\nBacking up repository {current_repo} of {total_repos}: {archive_name}")
        
        # Start the backup process
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True
        )

        # Create a simple progress bar
        with tqdm(total=100, 
                 desc=f"Progress", 
                 bar_format='{desc}: |{bar}| {percentage:3.0f}%',
                 ncols=75) as pbar:
            last_update = 0
            while True:
                if process.poll() is not None:
                    break
                
                # Update progress bar every second
                if time.time() - last_update >= 1:
                    pbar.update(2)  # Approximate progress
                    last_update = time.time()
                
                time.sleep(0.1)

        stdout, stderr = process.communicate()

        if process.returncode == 0:
            pbar.n = 100  # Ensure bar shows 100% when complete
            pbar.refresh()
            print(f"\n✓ Backup complete: {archive_name}")
            logging.info(f"Successfully created backup: {archive_path}")
            return True, archive_path
        else:
            print(f"\n✗ Backup failed: {archive_name}")
            logging.error(f"Failed to create backup: {archive_path}")
            logging.error(f"Error: {stderr}")
            return False, stderr

    except Exception as e:
        error_msg = f"An error occurred while creating backup for {source_dir}: {str(e)}"
        logging.error(error_msg)
        return False, error_msg

def main():
    directories_to_backup = [
        os.path.expanduser("~/Code/Repositories/KCAsrCB"),
        os.path.expanduser("~/Code/Repositories/Kootenai_County_Assessor_CodeBase")
    ]

    total_repos = len(directories_to_backup)
    today = datetime.now().strftime("%Y.%m.%d")
    backup_destination = Path(os.path.expanduser("~/Code/Repositories/Codebase Backups")) / today

    print("\nStarting Repository Backup Process")
    print("=" * 50)

    all_backups_successful = True
    status_report = []

    for idx, directory in enumerate(directories_to_backup, 1):
        dir_name = Path(directory).name
        success, result = create_7zip_backup(directory, str(backup_destination), dir_name, total_repos, idx)
        
        status_report.append({
            'directory': dir_name,
            'success': success,
            'result': result
        })
        
        if not success:
            all_backups_successful = False

    print("\nBackup Summary:")
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