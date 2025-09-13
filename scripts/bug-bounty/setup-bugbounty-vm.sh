#!/bin/bash

# Bug Bounty VM Setup Script
# This script sets up a Linux VM for bug bounty hunting and web application security testing

set -e

echo "=========================================="
echo "Setting up Bug Bounty VM"
echo "=========================================="

# Update system packages
echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential tools
echo "[+] Installing essential bug bounty tools..."
sudo apt install -y \
    nmap \
    masscan \
    gobuster \
    dirb \
    nikto \
    sqlmap \
    wfuzz \
    ffuf \
    curl \
    wget \
    jq \
    git \
    vim \
    tmux \
    screen \
    python3 \
    python3-pip \
    nodejs \
    npm \
    ruby \
    gem \
    golang-go \
    build-essential \
    unzip \
    zip \
    chromium-browser \
    firefox

# Install Python tools
echo "[+] Installing Python-based tools..."
pip3 install --user \
    requests \
    beautifulsoup4 \
    paramiko \
    dnspython \
    colorama \
    tqdm \
    aiohttp \
    asyncio

# Install Go (latest version)
echo "[+] Installing Go..."
cd /tmp
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# Create directories
echo "[+] Creating directories..."
mkdir -p ~/tools
mkdir -p ~/wordlists
mkdir -p ~/targets
mkdir -p ~/reports
cd ~/tools

# Install subdomain enumeration tools
echo "[+] Installing subdomain enumeration tools..."

# Subfinder
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Assetfinder
go install github.com/tomnomnom/assetfinder@latest

# Amass
go install -v github.com/owasp-amass/amass/v4/...@master

# Sublist3r
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r && pip3 install -r requirements.txt
cd ~/tools

# Install web reconnaissance tools
echo "[+] Installing web reconnaissance tools..."

# HTTPx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Nuclei
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Waybackurls
go install github.com/tomnomnom/waybackurls@latest

# GAU (Get All URLs)
go install github.com/lc/gau/v2/cmd/gau@latest

# Paramspider
git clone https://github.com/devanshbatham/ParamSpider.git
cd ParamSpider && pip3 install -r requirements.txt
cd ~/tools

# Install content discovery tools
echo "[+] Installing content discovery tools..."

# Dirsearch
git clone https://github.com/maurosoria/dirsearch.git
cd dirsearch && pip3 install -r requirements.txt
cd ~/tools

# Feroxbuster
wget https://github.com/epi052/feroxbuster/releases/latest/download/feroxbuster_amd64.deb
sudo dpkg -i feroxbuster_amd64.deb

# Install vulnerability scanners
echo "[+] Installing vulnerability scanners..."

# Dalfox (XSS scanner)
go install github.com/hahwul/dalfox/v2@latest

# SSRF Hunter
git clone https://github.com/knassar702/ssrf-hunter.git
cd ssrf-hunter && pip3 install -r requirements.txt
cd ~/tools

# Install JavaScript analysis tools
echo "[+] Installing JavaScript analysis tools..."

# JSFinder
git clone https://github.com/Threezh1/JSFinder.git
cd JSFinder && pip3 install -r requirements.txt
cd ~/tools

# Linkfinder
git clone https://github.com/GerbenJavado/LinkFinder.git
cd LinkFinder && pip3 install -r requirements.txt
cd ~/tools

# Download wordlists
echo "[+] Downloading wordlists..."
cd ~/wordlists

# SecLists
git clone https://github.com/danielmiessler/SecLists.git

# Common wordlists
wget https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt
wget https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt

# Install Burp Suite Community Edition
echo "[+] Installing Burp Suite Community Edition..."
cd /tmp
wget "https://portswigger.net/burp/releases/download?product=community&version=2023.10.3.7&type=Linux" -O burpsuite_community_linux.sh
chmod +x burpsuite_community_linux.sh
sudo ./burpsuite_community_linux.sh -q

# Set up environment
echo "[+] Setting up environment..."
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
echo 'alias ll="ls -la"' >> ~/.bashrc
echo 'alias ..="cd .."' >> ~/.bashrc
echo 'alias subfinder="~/go/bin/subfinder"' >> ~/.bashrc
echo 'alias httpx="~/go/bin/httpx"' >> ~/.bashrc
echo 'alias nuclei="~/go/bin/nuclei"' >> ~/.bashrc

# Create useful scripts
echo "[+] Creating utility scripts..."

# Subdomain enumeration script
cat > ~/tools/subdomain-enum.sh << 'EOF'
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain=$1
mkdir -p ~/targets/$domain

echo "[+] Running subfinder..."
subfinder -d $domain -o ~/targets/$domain/subfinder.txt

echo "[+] Running assetfinder..."
assetfinder $domain > ~/targets/$domain/assetfinder.txt

echo "[+] Running sublist3r..."
python3 ~/tools/Sublist3r/sublist3r.py -d $domain -o ~/targets/$domain/sublist3r.txt

echo "[+] Combining results..."
cat ~/targets/$domain/*.txt | sort -u > ~/targets/$domain/all_subdomains.txt

echo "[+] Checking live subdomains..."
httpx -l ~/targets/$domain/all_subdomains.txt -o ~/targets/$domain/live_subdomains.txt

echo "[+] Results saved in ~/targets/$domain/"
EOF

chmod +x ~/tools/subdomain-enum.sh

# Web scanner script
cat > ~/tools/web-scan.sh << 'EOF'
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

url=$1
domain=$(echo $url | sed 's|https\?://||' | cut -d'/' -f1)
mkdir -p ~/targets/$domain

echo "[+] Running nuclei..."
nuclei -u $url -o ~/targets/$domain/nuclei_results.txt

echo "[+] Running nikto..."
nikto -h $url > ~/targets/$domain/nikto_results.txt

echo "[+] Running directory enumeration..."
gobuster dir -u $url -w ~/wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt -o ~/targets/$domain/gobuster_results.txt

echo "[+] Results saved in ~/targets/$domain/"
EOF

chmod +x ~/tools/web-scan.sh

# Update nuclei templates
echo "[+] Updating nuclei templates..."
nuclei -update-templates

echo "=========================================="
echo "Bug Bounty VM setup completed!"
echo "=========================================="
echo ""
echo "Installed tools:"
echo "- Subdomain enumeration: subfinder, assetfinder, amass, sublist3r"
echo "- Web reconnaissance: httpx, nuclei, waybackurls, gau"
echo "- Content discovery: gobuster, dirsearch, feroxbuster"
echo "- Vulnerability scanning: nuclei, nikto, sqlmap, dalfox"
echo "- JavaScript analysis: JSFinder, LinkFinder"
echo "- GUI Tools: Burp Suite Community Edition"
echo ""
echo "Utility scripts:"
echo "- ~/tools/subdomain-enum.sh <domain>"
echo "- ~/tools/web-scan.sh <url>"
echo ""
echo "Directories:"
echo "- Tools: ~/tools"
echo "- Wordlists: ~/wordlists"
echo "- Targets: ~/targets"
echo "- Reports: ~/reports"
echo ""
echo "Please reboot the system to complete the setup."