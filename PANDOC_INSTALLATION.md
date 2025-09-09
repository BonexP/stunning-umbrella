# Pandoc Installation Guide for WebLaTeX Code Spaces

This guide provides multiple methods to install Pandoc in your WebLaTeX code space environment, including solutions for common GPG key issues.

## Quick Installation (Recommended)

For most cases, you can install Pandoc directly using:

```bash
sudo apt update
sudo apt install -y pandoc
```

## If You Encounter GPG Key Errors

If you see errors like `NO_PUBKEY` or "signatures couldn't be verified", follow these steps:

### Method 1: Fix GPG Keys for Debian Testing

If you're on Debian testing and seeing GPG key errors, run this script:

```bash
#!/bin/bash
# Fix Debian GPG keys
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 78DBA3BC47EF2265  
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BDE6D2B9216EC7A8
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8E9F831205B4BA95

# Update package lists
sudo apt update

# Install pandoc
sudo apt install -y pandoc
```

### Method 2: Download Pandoc Binary Directly

If apt still doesn't work, download the latest Pandoc binary:

```bash
#!/bin/bash
# Download latest Pandoc for Linux
PANDOC_VERSION="3.1.11.1"
wget https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz

# Extract and install
tar xvzf pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz
sudo cp pandoc-${PANDOC_VERSION}/bin/pandoc /usr/local/bin/
sudo cp pandoc-${PANDOC_VERSION}/bin/pandoc-lua /usr/local/bin/

# Clean up
rm -rf pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz pandoc-${PANDOC_VERSION}/

# Verify installation
pandoc --version
```

### Method 3: Use Conda/Mamba

If you have conda installed:

```bash
conda install -c conda-forge pandoc
```

Or with mamba:

```bash
mamba install -c conda-forge pandoc
```

### Method 4: Build from Source (Advanced)

If all else fails, build from source:

```bash
#!/bin/bash
# Install Haskell Stack
curl -sSL https://get.haskellstack.org/ | sh

# Clone and build Pandoc
git clone https://github.com/jgm/pandoc.git
cd pandoc
stack install --fast
```

## Troubleshooting

### Check Current Environment

To determine which method to use, check your environment:

```bash
# Check OS version
cat /etc/os-release

# Check current Pandoc installation
which pandoc
pandoc --version 2>/dev/null || echo "Pandoc not installed"

# Check apt sources
ls -la /etc/apt/sources.list.d/
```

### Common Issues

1. **Permission Denied**: Always use `sudo` for system-wide installations
2. **Network Issues**: Try using different mirrors or direct downloads
3. **Space Issues**: Clean up with `sudo apt autoremove` and `sudo apt autoclean`

## Integration with WebLaTeX

Once Pandoc is installed, you can use it for document conversion:

```bash
# Convert Markdown to PDF
pandoc document.md -o document.pdf

# Convert LaTeX to HTML
pandoc document.tex -o document.html

# Convert with custom templates
pandoc document.md --template=template.latex -o document.pdf
```

## Automated Installation Script

For convenience, you can use this automated script that tries multiple methods:

```bash
#!/bin/bash
# pandoc_installer.sh - Automated Pandoc installation script

echo "=== Pandoc Installation Script ==="
echo "Detecting environment..."

# Check if pandoc is already installed
if command -v pandoc &> /dev/null; then
    echo "Pandoc is already installed:"
    pandoc --version
    exit 0
fi

# Try standard installation first
echo "Attempting standard installation..."
if sudo apt update && sudo apt install -y pandoc; then
    echo "Pandoc installed successfully via apt!"
    pandoc --version
    exit 0
fi

# If that fails, try fixing GPG keys
echo "Standard installation failed. Trying GPG key fix..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131 2>/dev/null
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 78DBA3BC47EF2265 2>/dev/null
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BDE6D2B9216EC7A8 2>/dev/null
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8E9F831205B4BA95 2>/dev/null

if sudo apt update && sudo apt install -y pandoc; then
    echo "Pandoc installed successfully after GPG fix!"
    pandoc --version
    exit 0
fi

# If still failing, try binary installation
echo "Apt installation failed. Trying binary installation..."
PANDOC_VERSION="3.1.11.1"
if wget https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz; then
    tar xvzf pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz
    sudo cp pandoc-${PANDOC_VERSION}/bin/pandoc /usr/local/bin/
    sudo chmod +x /usr/local/bin/pandoc
    rm -rf pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz pandoc-${PANDOC_VERSION}/
    
    if command -v pandoc &> /dev/null; then
        echo "Pandoc installed successfully via binary!"
        pandoc --version
        exit 0
    fi
fi

echo "All installation methods failed. Please try manual installation."
exit 1
```

Save this script as `install_pandoc.sh`, make it executable with `chmod +x install_pandoc.sh`, and run it with `./install_pandoc.sh`.