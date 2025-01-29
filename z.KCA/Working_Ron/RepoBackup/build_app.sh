#!/bin/bash

# Set explicit Python path
PYTHON_PATH="/usr/bin/python3"

echo "Using Python at: $PYTHON_PATH"

# Install required packages if not already installed
$PYTHON_PATH -m pip install --user tqdm pyinstaller

# Get PyInstaller path
PYINSTALLER_PATH="/Users/klymacks/Library/Python/3.9/bin/pyinstaller"

# Create the executable
$PYINSTALLER_PATH --onefile \
            --name RepoBackupMacOSBeta \
            RepoBackupMacOSBeta.py

echo "Build complete! Executable is in the dist folder." 