#!/bin/bash

# Set explicit Python path
PYTHON_PATH="/usr/bin/python3"

echo "Using Python at: $PYTHON_PATH"

# Install required packages if not already installed
$PYTHON_PATH -m pip install --user tqdm pyinstaller

# Simple direct build command
$PYTHON_PATH -m PyInstaller --name RepoBackupMacOSBeta --onefile RepoBackupMacOSBeta.py

echo "Build complete! Executable is in the dist folder." 