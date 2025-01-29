import sys
import logging
import getpass
import argparse
import subprocess
from pathlib import Path

def setup_logging(log_dir):
    """Setup logging configuration"""
    log_dir = Path(log_dir)
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / 'signing_log.txt'
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler(sys.stdout)
        ]
    )

def find_executable(path, pattern):
    """Find executable matching the pattern"""
    try:
        path = Path(path)
        if path.is_file():
            return path
        
        exe_files = list(path.glob(pattern))
        if not exe_files:
            raise FileNotFoundError(f"No executable found matching pattern: {pattern}")
        
        if len(exe_files) > 1:
            print("\nMultiple executables found:")
            for i, exe in enumerate(exe_files, 1):
                print(f"{i}. {exe.name}")
            
            while True:
                try:
                    choice = int(input("\nSelect executable number: ")) - 1
                    if 0 <= choice < len(exe_files):
                        return exe_files[choice]
                except ValueError:
                    pass
                print("Invalid selection. Please try again.")
        
        return exe_files[0]
    except Exception as e:
        logging.error(f"Error finding executable: {e}")
        raise

def sign_executable(exe_path, cert_path, password, description=None):
    """Sign the executable using signtool"""
    try:
        cmd = [
            'signtool', 'sign',
            '/f', str(cert_path),
            '/p', password,
            '/fd', 'sha256',
            '/tr', 'http://timestamp.digicert.com',
            '/td', 'sha256',
            '/v'
        ]
        
        if description:
            cmd.extend(['/d', description])
        
        cmd.append(str(exe_path))
        
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

def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description='Code Signing Tool for KC Applications')
    
    parser.add_argument(
        '--exe',
        help='Path to executable or directory containing executable(s)',
        required=True
    )
    
    parser.add_argument(
        '--cert',
        help='Path to certificate file (.pfx)',
        required=True
    )
    
    parser.add_argument(
        '--pattern',
        help='Executable search pattern (e.g., "TimeTracker*.exe")',
        default='*.exe'
    )
    
    parser.add_argument(
        '--desc',
        help='Description to embed in signature',
        default=None
    )
    
    parser.add_argument(
        '--log-dir',
        help='Directory for log files',
        default=Path(__file__).parent / 'logs'
    )
    
    return parser.parse_args()

def check_signtool():
    """Check if signtool is available and provide guidance if it's not"""
    try:
        result = subprocess.run(['signtool', '/?'], 
                              capture_output=True, 
                              text=True)
        return True
    except FileNotFoundError:
        logging.error("signtool.exe not found. Windows SDK needs to be installed.")
        print("\nError: signtool.exe not found!")
        print("\nTo fix this:")
        print("1. Install Windows SDK from:")
        print("   https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/")
        print("\n2. During installation, ensure 'Windows SDK Signing Tools' is selected")
        print("\n3. After installation, add the signtool path to your system PATH:")
        print("   Usually found in: C:\\Program Files (x86)\\Windows Kits\\10\\bin\\<version>\\x64")
        return False

def main():
    """Main signing process"""
    try:
        args = parse_arguments()
        
        # Setup logging
        setup_logging(args.log_dir)
        logging.info("Starting code signing process")
        
        # Convert paths
        cert_path = Path(args.cert)
        exe_path = Path(args.exe)
        
        # Check paths
        if not cert_path.exists():
            raise FileNotFoundError(f"Certificate not found: {cert_path}")
        if not exe_path.exists():
            raise FileNotFoundError(f"Executable path not found: {exe_path}")
        
        # Find executable
        exe_path = find_executable(exe_path, args.pattern)
        logging.info(f"Found executable: {exe_path}")
        
        # Get certificate password
        password = getpass.getpass("Enter certificate password: ")
        
        # Check signtool
        if not check_signtool():
            return 1
        
        # Sign executable
        logging.info("Signing executable...")
        sign_executable(exe_path, cert_path, password, args.desc)
        
        # Verify signature
        logging.info("Verifying signature...")
        verify_signature(exe_path)
        
        logging.info("Signing process completed successfully!")
        print(f"\nSuccess! {exe_path.name} has been signed and verified.")
        
    except Exception as e:
        logging.error(f"Signing process failed: {e}")
        print(f"\nError: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())