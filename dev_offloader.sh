#!/bin/bash

# Check if the correct number of arguments is passed
if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "Offline system: $0 --generate-signature <package-name> <directory>"
    echo "Online system: $0 --download-packages <signature-file-path> <output-directory>"
    exit 1
fi

# Assign command line arguments to variables
COMMAND=$1
PACKAGE_OR_SIGNATURE=$2
DIRECTORY=$3

case $COMMAND in
    --generate-signature)
        # Generate signature file for the package
        SIGNATURE_FILE="${DIRECTORY}/${PACKAGE_OR_SIGNATURE}.sig"
        mkdir -p "${DIRECTORY}"
        apt-offline set --install-packages "${PACKAGE_OR_SIGNATURE}" "${SIGNATURE_FILE}"
        echo "Generated signature file at ${SIGNATURE_FILE}"
        echo "Transfer this file to an online system and run this script with --download-packages option."
        ;;
    --download-packages)
        # Download packages using the signature file
        BUNDLE_FILE="${DIRECTORY}/offline-packages.zip"
        mkdir -p "${DIRECTORY}"
        apt-offline get "${PACKAGE_OR_SIGNATURE}" --bundle "${BUNDLE_FILE}"
        echo "Downloaded packages are in ${BUNDLE_FILE}"
        echo "Transfer this bundle back to the offline system for installation."
        ;;
    *)
        echo "Invalid command. Please use --generate-signature for offline system or --download-packages for online system."
        exit 1
        ;;
esac
