import sys
import logging
import getpass
import subprocess
from pathlib import Path

def setup_logging():
    """Setup logging configuration"""
    log_file = Path(__file__).parent / 'signing_log.txt'
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler(sys.stdout)
        ]
    )

def find_executable(dist_dir):
    """Find the TimeTracker executable in the dist directory"""
    try:
        exe_files = list(dist_dir.glob('TimeTracker*.exe'))
        if not exe_files:
            raise FileNotFoundError("No TimeTracker executable found")
        return exe_files[0]
    except Exception as e:
        logging.error(f"Error finding executable: {e}")
        raise

def sign_executable(exe_path, cert_path, password):
    """Sign the executable using signtool"""
    try:
        cmd = [
            'signtool', 'sign',
            '/f', str(cert_path),
            '/p', password,
            '/fd', 'sha256',
            '/tr', 'http://timestamp.digicert.com',
            '/td', 'sha256',
            '/v',
            str(exe_path)
        ]
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True
        )
        
        logging.info(f"Signing output:\n{result.stdout}")
        if result.stderr:
            logging.warning(f"Signing warnings:\n{result.stderr}")
            
        return True
    except subprocess.CalledProcessError as e:
        logging.error(f"Signing failed: {e.stdout}\n{e.stderr}")
        raise
    except Exception as e:
        logging.error(f"Unexpected error during signing: {e}")
        raise

def verify_signature(exe_path):
    """Verify the signature using signtool"""
    try:
        cmd = ['signtool', 'verify', '/pa', str(exe_path)]
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True
        )
        
        logging.info(f"Verification output:\n{result.stdout}")
        if result.stderr:
            logging.warning(f"Verification warnings:\n{result.stderr}")
            
        return True
    except subprocess.CalledProcessError as e:
        logging.error(f"Verification failed: {e.stdout}\n{e.stderr}")
        raise
    except Exception as e:
        logging.error(f"Unexpected error during verification: {e}")
        raise

def main():
    """Main signing process"""
    try:
        # Setup logging
        setup_logging()
        logging.info("Starting TimeTracker signing process")
        
        # Get script directory
        script_dir = Path(__file__).parent
        
        # Define paths
        cert_path = script_dir / 'TimeTrackerCert.pfx'
        dist_dir = script_dir / 'dist'
        
        # Check paths
        if not cert_path.exists():
            raise FileNotFoundError(f"Certificate not found: {cert_path}")
        if not dist_dir.exists():
            raise FileNotFoundError(f"Dist directory not found: {dist_dir}")
        
        # Find executable
        exe_path = find_executable(dist_dir)
        logging.info(f"Found executable: {exe_path}")
        
        # Get certificate password
        password = getpass.getpass("Enter certificate password: ")
        
        # Sign executable
        logging.info("Signing executable...")
        sign_executable(exe_path, cert_path, password)
        
        # Verify signature
        logging.info("Verifying signature...")
        verify_signature(exe_path)
        
        logging.info("Signing process completed successfully!")
        print("\nSuccess! TimeTracker has been signed and verified.")
        
    except Exception as e:
        logging.error(f"Signing process failed: {e}")
        print(f"\nError: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())