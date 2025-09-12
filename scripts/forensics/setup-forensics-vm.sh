#!/bin/bash

# Forensics VM Setup Script
# This script sets up a Linux VM for digital forensic analysis

set -e

echo "=========================================="
echo "Setting up Forensics Analysis VM"
echo "=========================================="

# Update system packages
echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential forensics tools
echo "[+] Installing forensics tools..."
sudo apt install -y \
    autopsy \
    sleuthkit \
    binwalk \
    foremost \
    scalpel \
    testdisk \
    photorec \
    ddrescue \
    dc3dd \
    volatility \
    yara \
    exiftool \
    strings \
    hexdump \
    xxd \
    hexedit \
    ghex \
    wireshark \
    tcpdump \
    git \
    python3 \
    python3-pip \
    build-essential \
    cmake \
    libssl-dev \
    libffi-dev \
    unzip \
    zip \
    p7zip-full

# Install Python forensics libraries
echo "[+] Installing Python forensics libraries..."
pip3 install --user \
    volatility3 \
    yara-python \
    pycrypto \
    construct \
    requests \
    python-magic \
    pillow

# Create directories
echo "[+] Creating directories..."
mkdir -p ~/forensics-tools
mkdir -p ~/evidence
mkdir -p ~/case-files
mkdir -p ~/reports
cd ~/forensics-tools

# Install additional forensics tools
echo "[+] Installing additional forensics tools..."

# YARA rules
git clone https://github.com/Yara-Rules/rules.git yara-rules

# Volatility plugins
git clone https://github.com/volatilityfoundation/volatility.git volatility2
git clone https://github.com/volatilityfoundation/volatility3.git volatility3

# RegRipper for Windows registry analysis
git clone https://github.com/keydet89/RegRipper3.0.git regripper

# Log2timeline/plaso for timeline analysis
echo "[+] Installing log2timeline/plaso..."
sudo add-apt-repository -y ppa:gift/stable
sudo apt update
sudo apt install -y plaso-tools

# Install ClamAV for malware scanning
echo "[+] Installing ClamAV..."
sudo apt install -y clamav clamav-daemon
sudo freshclam

# Install additional disk imaging tools
echo "[+] Installing disk imaging tools..."
sudo apt install -y \
    guymager \
    ewf-tools \
    afflib-tools \
    libewf-utils

# Set up environment
echo "[+] Setting up environment..."
echo 'export PATH=$PATH:~/forensics-tools' >> ~/.bashrc
echo 'alias ll="ls -la"' >> ~/.bashrc
echo 'alias ..="cd .."' >> ~/.bashrc
echo 'alias vol2="python2 ~/forensics-tools/volatility2/vol.py"' >> ~/.bashrc
echo 'alias vol3="python3 ~/forensics-tools/volatility3/vol.py"' >> ~/.bashrc

# Create desktop shortcuts
echo "[+] Creating desktop shortcuts..."
mkdir -p ~/Desktop
cat > ~/Desktop/Autopsy.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Autopsy
Comment=Digital Forensics Platform
Exec=autopsy
Icon=autopsy
Terminal=false
StartupNotify=true
Categories=Security;
EOF

# Configure system for forensics work
echo "[+] Configuring system settings..."
# Increase file descriptor limits for large files
echo 'fs.file-max = 2097152' | sudo tee -a /etc/sysctl.conf
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf

# Create evidence handling script
cat > ~/evidence/README.txt << EOF
EVIDENCE HANDLING GUIDELINES
============================

1. Always work on forensic copies, never original evidence
2. Document all actions taken during analysis
3. Use write-blocking devices when possible
4. Maintain chain of custody documentation
5. Verify integrity using hashes (MD5, SHA256)

Common Commands:
- Create image: dd if=/dev/sdX of=evidence.img bs=4M
- Verify hash: md5sum evidence.img
- Mount read-only: sudo mount -o ro,loop evidence.img /mnt/evidence
- Timeline analysis: log2timeline.py timeline.plaso evidence.img
EOF

echo "=========================================="
echo "Forensics VM setup completed!"
echo "=========================================="
echo ""
echo "Installed tools:"
echo "- GUI Tools: Autopsy, GHex"
echo "- Command line: Sleuthkit, Volatility, Binwalk, Foremost"
echo "- Disk imaging: ddrescue, dc3dd, Guymager"
echo "- Timeline analysis: log2timeline/plaso"
echo "- Malware analysis: YARA, ClamAV"
echo "- Registry analysis: RegRipper"
echo ""
echo "Evidence directory: ~/evidence"
echo "Case files directory: ~/case-files"
echo "Reports directory: ~/reports"
echo ""
echo "Please reboot the system to complete the setup."