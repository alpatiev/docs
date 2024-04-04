#!/bin/bash

# http://mirrors.kernel.org/ubuntu/pool/restricted/b/bcmwl/bcmwl-kernel-source_6.30.223.271+bdcom-0ubuntu8_amd64.deb

PACKAGE_URL="http://mirrors.kernel.org/ubuntu/pool/restricted/b/bcmwl/bcmwl-kernel-source_6.30.223.271+bdcom-0ubuntu8_amd64.deb"
PACKAGE_NAME="bcmwl-kernel-source"
WORK_DIR=$(pwd)

download_packages() {
    # Create a temporary directory for the download process
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Update package lists (optional, comment out if not desired)
    # sudo apt-get update

    # Download the specified package and all its dependencies
    apt-get download "$PACKAGE_URL"
    DEPENDENCIES=$(apt-cache depends "$PACKAGE_NAME" | grep -E 'Depends|Recommends' | cut -d ':' -f2 | tr -d '<>' | xargs)
    for dep in $DEPENDENCIES; do
        apt-get download "$dep"
    done

    # Move all downloaded packages to the specified work directory
    mv *.deb "$WORK_DIR"
    cd "$WORK_DIR"
    rm -rf "$TEMP_DIR"  # Clean up temporary directory
    echo "Downloaded all packages and dependencies to $WORK_DIR"
}

install_packages() {
    # Install all .deb packages in the work directory
    sudo dpkg -i "$WORK_DIR"/*.deb
    # Fix missing dependencies (if any)
    sudo apt-get install -f
    echo "Installation completed."
}

# Check command line argument
case "$1" in
    --download)
        download_packages
        ;;
    --install)
        install_packages
        ;;
    *)
        echo "Usage: $0 --download | --install"
        exit 1
        ;;
esac
