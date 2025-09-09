#!/bin/bash
# pandoc_installer.sh - Automated Pandoc installation script for WebLaTeX
# This script tries multiple installation methods to ensure Pandoc gets installed

set -e

echo "========================================"
echo "  WebLaTeX Pandoc Installation Script  "
echo "========================================"
echo ""

# Function to check if pandoc is working
check_pandoc() {
    if command -v pandoc &> /dev/null; then
        echo "✅ Pandoc found at: $(which pandoc)"
        echo "📋 Version: $(pandoc --version | head -1)"
        return 0
    else
        return 1
    fi
}

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "🔍 Detected OS: $NAME $VERSION"
        OS=$ID
        VER=$VERSION_ID
    else
        echo "❌ Cannot detect OS version"
        OS="unknown"
    fi
}

# Function to try standard apt installation
try_apt_install() {
    echo ""
    echo "📦 Attempting standard apt installation..."
    
    if sudo apt update &> /tmp/apt_update.log; then
        echo "✅ Package lists updated successfully"
    else
        echo "⚠️  Package update had issues, continuing..."
        cat /tmp/apt_update.log
    fi
    
    if sudo apt install -y pandoc &> /tmp/apt_install.log; then
        echo "✅ Pandoc installed via apt"
        return 0
    else
        echo "❌ Apt installation failed"
        echo "Error details:"
        cat /tmp/apt_install.log
        return 1
    fi
}

# Function to fix GPG keys for Debian/Ubuntu
fix_gpg_keys() {
    echo ""
    echo "🔑 Attempting to fix GPG keys..."
    
    # Common Debian/Ubuntu keys that might be missing
    local keys=("6ED0E7B82643E131" "78DBA3BC47EF2265" "BDE6D2B9216EC7A8" "8E9F831205B4BA95")
    
    for key in "${keys[@]}"; do
        echo "Adding key: $key"
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key 2>/dev/null || \
        sudo apt-key adv --keyserver keys.gnupg.net --recv-keys $key 2>/dev/null || \
        echo "⚠️  Could not add key $key"
    done
    
    echo "🔄 Updating package lists after key fix..."
    sudo apt update &> /tmp/apt_update_after_keys.log
}

# Function to install via direct binary download
install_binary() {
    echo ""
    echo "💾 Attempting binary installation..."
    
    # Get latest version from GitHub API or use a known good version
    PANDOC_VERSION="3.1.11.1"
    local url="https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz"
    
    echo "📥 Downloading Pandoc ${PANDOC_VERSION}..."
    if wget -q --show-progress "$url" -O "/tmp/pandoc.tar.gz"; then
        echo "✅ Download completed"
        
        cd /tmp
        tar xzf pandoc.tar.gz
        
        if [ -f "pandoc-${PANDOC_VERSION}/bin/pandoc" ]; then
            echo "📁 Installing binary to /usr/local/bin..."
            sudo cp "pandoc-${PANDOC_VERSION}/bin/pandoc" /usr/local/bin/
            sudo chmod +x /usr/local/bin/pandoc
            
            # Also install pandoc-lua if available
            if [ -f "pandoc-${PANDOC_VERSION}/bin/pandoc-lua" ]; then
                sudo cp "pandoc-${PANDOC_VERSION}/bin/pandoc-lua" /usr/local/bin/
                sudo chmod +x /usr/local/bin/pandoc-lua
            fi
            
            # Clean up
            rm -rf "/tmp/pandoc.tar.gz" "/tmp/pandoc-${PANDOC_VERSION}/"
            
            echo "✅ Binary installation completed"
            return 0
        else
            echo "❌ Binary not found in downloaded archive"
            return 1
        fi
    else
        echo "❌ Failed to download Pandoc binary"
        return 1
    fi
}

# Function to try snap installation
try_snap_install() {
    echo ""
    echo "📦 Attempting snap installation..."
    
    if command -v snap &> /dev/null; then
        if sudo snap install pandoc; then
            echo "✅ Pandoc installed via snap"
            return 0
        else
            echo "❌ Snap installation failed"
            return 1
        fi
    else
        echo "❌ Snap not available"
        return 1
    fi
}

# Function to install using conda if available
try_conda_install() {
    echo ""
    echo "🐍 Checking for conda/mamba..."
    
    if command -v mamba &> /dev/null; then
        echo "📦 Attempting mamba installation..."
        if mamba install -c conda-forge pandoc -y; then
            echo "✅ Pandoc installed via mamba"
            return 0
        fi
    elif command -v conda &> /dev/null; then
        echo "📦 Attempting conda installation..."
        if conda install -c conda-forge pandoc -y; then
            echo "✅ Pandoc installed via conda"
            return 0
        fi
    else
        echo "❌ Conda/mamba not available"
        return 1
    fi
    
    return 1
}

# Main installation flow
main() {
    echo "🔍 Checking if Pandoc is already installed..."
    if check_pandoc; then
        echo ""
        echo "🎉 Pandoc is already installed and working!"
        exit 0
    fi
    
    echo "❌ Pandoc not found. Starting installation process..."
    detect_os
    
    # Try installation methods in order of preference
    if try_apt_install && check_pandoc; then
        echo ""
        echo "🎉 Successfully installed Pandoc via apt!"
        exit 0
    fi
    
    echo ""
    echo "🔧 Standard apt installation failed. Trying GPG key fix..."
    fix_gpg_keys
    
    if try_apt_install && check_pandoc; then
        echo ""
        echo "🎉 Successfully installed Pandoc via apt after GPG fix!"
        exit 0
    fi
    
    if install_binary && check_pandoc; then
        echo ""
        echo "🎉 Successfully installed Pandoc via binary download!"
        exit 0
    fi
    
    if try_snap_install && check_pandoc; then
        echo ""
        echo "🎉 Successfully installed Pandoc via snap!"
        exit 0
    fi
    
    if try_conda_install && check_pandoc; then
        echo ""
        echo "🎉 Successfully installed Pandoc via conda/mamba!"
        exit 0
    fi
    
    echo ""
    echo "❌ All installation methods failed!"
    echo ""
    echo "🛠️  Manual troubleshooting steps:"
    echo "1. Check your internet connection"
    echo "2. Verify you have sudo privileges"
    echo "3. Try running: sudo apt update && sudo apt upgrade"
    echo "4. Check available disk space: df -h"
    echo "5. For Debian testing issues, manually add GPG keys"
    echo ""
    echo "📚 For more help, see: PANDOC_INSTALLATION.md"
    exit 1
}

# Check if running as root (not recommended)
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  Warning: Running as root. Consider running as a regular user with sudo."
    echo "Press Enter to continue or Ctrl+C to abort..."
    read
fi

# Run main function
main "$@"