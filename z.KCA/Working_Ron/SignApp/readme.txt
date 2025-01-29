"""
Kootenai County Code Signing Tool
================================

A utility for signing Windows executables with digital certificates.

Features:
---------
- Sign executables with PFX/P12 certificates
- Verify signatures after signing
- Support for multiple executables
- Pattern matching for executable selection
- Detailed logging
- Interactive mode for multiple matches

Usage:
------
Basic:
    python <<ENTER THE SCRIPT NAME HERE>>.py --exe "path/to/exe" --cert "path/to/cert.pfx"

With Pattern:
    python <<ENTER THE SCRIPT NAME HERE>>.py --exe "path/to/dir" --cert "path/to/cert.pfx" --pattern "App*.exe"

With Description:
    python <<ENTER THE SCRIPT NAME HERE>>.py --exe "path/to/exe" --cert "path/to/cert.pfx" --desc "My Application"

Examples:
---------
1. Sign TimeTracker:
   python CodeSigner.py --exe "../TimeTracker/dist" --cert "../TimeTracker/TimeTrackerCert.pfx" 
   --pattern "TimeTracker*.exe" --desc "Kootenai County TimeTracker"

2. Sign specific executable:
   python CodeSigner.py --exe "C:/Apps/MyApp.exe" --cert "C:/Certs/cert.pfx"

3. Custom log directory:
   python CodeSigner.py --exe "path/to/exe" --cert "path/to/cert.pfx" --log-dir "C:/Logs"

Requirements:
------------
- Windows SDK (for signtool.exe)
- Valid code signing certificate (.pfx file)
- Python 3.6+

Author: Ron Mason III
Version: 1.0.0
"""

import sys
import logging
import getpass
import argparse
import subprocess
from pathlib import Path

def setup_logging(log_dir):
    """
    Configure logging to both file and console.

    Args:
        log_dir (str or Path): Directory where log files will be stored

    Creates:
        - Log directory if it doesn't exist
        - signing_log.txt file in the log directory
    
    Logging Format:
        timestamp - level - message
    """
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
    """
    Locate executable(s) based on path and pattern.

    Args:
        path (str or Path): Directory to search or specific file path
        pattern (str): Glob pattern for matching executables (e.g., "*.exe")

    Returns:
        Path: Selected executable path

    Raises:
        FileNotFoundError: If no matching executables found
        Exception: For other errors during search

    Interactive:
        If multiple executables are found, prompts user to select one
    """
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
    """
    Sign executable using signtool.

    Args:
        exe_path (Path): Path to executable to sign
        cert_path (Path): Path to certificate file (.pfx)
        password (str): Certificate password
        description (str, optional): Description to embed in signature

    Returns:
        bool: True if signing successful

    Raises:
        subprocess.CalledProcessError: If signtool returns error
        Exception: For other signing errors

    Signing Details:
        - SHA256 hashing algorithm
        - Timestamp server: http://timestamp.digicert.com
        - Optional description embedding
    """
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
    """
    Verify executable signature using signtool.

    Args:
        exe_path (Path): Path to signed executable

    Returns:
        bool: True if verification successful

    Raises:
        subprocess.CalledProcessError: If verification fails
        Exception: For other verification errors

    Verification:
        Uses /pa switch for checking signature against root certificate
    """
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
    """
    Parse command line arguments.

    Returns:
        argparse.Namespace: Parsed arguments

    Arguments:
        --exe: Path to executable or directory
        --cert: Path to certificate file
        --pattern: Executable search pattern
        --desc: Signature description
        --log-dir: Log directory path

    Example:
        --exe "dist" --cert "cert.pfx" --pattern "*.exe" --desc "My App" --log-dir "logs"
    """
    parser = argparse.ArgumentParser(
        description='Code Signing Tool for KC Applications',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent('''
            Examples:
            ---------
            1. Sign TimeTracker:
               %(prog)s --exe "../TimeTracker/dist" --cert "../TimeTracker/TimeTrackerCert.pfx" --pattern "TimeTracker*.exe"

            2. Sign specific executable:
               %(prog)s --exe "C:/Apps/MyApp.exe" --cert "C:/Certs/cert.pfx"

            3. Custom log directory:
               %(prog)s --exe "path/to/exe" --cert "path/to/cert.pfx" --log-dir "C:/Logs"
        ''')
    )
    
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

def main():
    """
    Main execution function.

    Process:
        1. Parse command line arguments
        2. Setup logging
        3. Locate executable
        4. Get certificate password
        5. Sign executable
        6. Verify signature

    Returns:
        int: 0 for success, 1 for failure

    Raises:
        Various exceptions handled with logging
    """
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