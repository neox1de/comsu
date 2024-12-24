#!/bin/bash

# Detect OS and set package manager
OS=""
INSTALL_CMD=""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Unable to detect OS."
    exit 1
fi

case "$OS" in
    ubuntu|debian)
        INSTALL_CMD="sudo apt-get update && sudo apt-get install -y jq"
        ;;
    arch)
        INSTALL_CMD="sudo pacman -S --noconfirm jq"
        ;;
    fedora)
        INSTALL_CMD="sudo dnf install -y jq"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Install jq if not already installed
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    eval "$INSTALL_CMD"
else
    echo "jq is already installed."
fi

# Create directory for shared files
SHARE_DIR="/usr/local/share/git-comsu"
if [ ! -d "$SHARE_DIR" ]; then
    sudo mkdir -p "$SHARE_DIR"
fi

# Copy prompt to the shared directory
sudo cp prompt "$SHARE_DIR/"

# Make git-comsu executable and copy to /usr/local/bin
sudo cp git-comsu /usr/local/bin/git-comsu
sudo chmod +x /usr/local/bin/git-comsu

echo
echo "Installation completed. You can now run 'git comsu'."
