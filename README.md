# Cloud Attack Machine Scripts

A comprehensive collection of startup scripts for setting up specialized virtual machines for cybersecurity work, including penetration testing, forensic analysis, bug bounty hunting, binary exploitation, web server hosting, and VPN services.

## 🚀 Quick Start

1. Choose the appropriate script for your needs
2. Download and run the setup script on a fresh Ubuntu/Debian system
3. Follow the post-installation instructions
4. Reboot the system to complete setup

```bash
# Example: Setting up a pentesting VM
wget https://raw.githubusercontent.com/DRedDevil04/cloud-attack-machine-scripts/main/scripts/pentesting/setup-pentesting-vm.sh
chmod +x setup-pentesting-vm.sh
sudo ./setup-pentesting-vm.sh
```

## 📁 Repository Structure

```
scripts/
├── pentesting/         # Penetration testing VM setup
├── forensics/          # Digital forensics analysis VM setup  
├── bug-bounty/         # Bug bounty hunting VM setup
├── binary-exploitation/ # Binary exploitation and reverse engineering VM setup
├── webserver/          # Secure web server hosting VM setup
└── vpn/               # VPN server hosting VM setup
```

## 🛡️ Available VM Configurations

### 1. Pentesting VM (`scripts/pentesting/setup-pentesting-vm.sh`)

Sets up a comprehensive penetration testing environment with essential tools and frameworks.

**Installed Tools:**
- **Network Scanning:** nmap, masscan
- **Web Testing:** gobuster, dirb, nikto, sqlmap
- **Password Attacks:** hydra, john, hashcat
- **Network Analysis:** wireshark, tcpdump
- **Frameworks:** Metasploit Framework
- **Additional:** LinPEAS, SecLists, ExploitDB
- **Languages:** Python3 with security libraries

**Key Features:**
- Pre-configured environment variables
- Common wordlists (rockyou, SecLists)
- Useful aliases and shortcuts
- Firewall configuration

### 2. Forensics VM (`scripts/forensics/setup-forensics-vm.sh`)

Creates a digital forensics workstation for incident response and evidence analysis.

**Installed Tools:**
- **GUI Tools:** Autopsy, GHex
- **Command Line:** Sleuthkit, Volatility (2 & 3), Binwalk, Foremost
- **Disk Imaging:** ddrescue, dc3dd, Guymager
- **Timeline Analysis:** log2timeline/plaso
- **Malware Analysis:** YARA, ClamAV
- **Registry Analysis:** RegRipper

**Key Features:**
- Evidence handling guidelines
- Organized directory structure
- Desktop shortcuts for GUI tools
- System optimizations for large files

### 3. Bug Bounty VM (`scripts/bug-bounty/setup-bugbounty-vm.sh`)

Optimized for web application security testing and bug bounty hunting.

**Installed Tools:**
- **Subdomain Enumeration:** subfinder, assetfinder, amass, sublist3r
- **Web Reconnaissance:** httpx, nuclei, waybackurls, gau
- **Content Discovery:** gobuster, dirsearch, feroxbuster
- **Vulnerability Scanning:** nuclei, nikto, sqlmap, dalfox
- **JavaScript Analysis:** JSFinder, LinkFinder
- **GUI Tools:** Burp Suite Community Edition

**Key Features:**
- Automated enumeration scripts
- Latest Go-based tools
- Comprehensive wordlists
- Web scanning automation

### 4. Binary Exploitation VM (`scripts/binary-exploitation/setup-binexp-vm.sh`)

Configured for binary exploitation, reverse engineering, and CTF challenges.

**Installed Tools:**
- **Debuggers:** GDB with GEF/pwndbg, radare2, rizin
- **Disassemblers:** Ghidra, Binary Ninja Community Edition
- **Exploitation:** pwntools, ROPgadget, one_gadget
- **Fuzzing:** AFL++, honggfuzz
- **Analysis:** checksec, LIEF, binwalk

**Key Features:**
- CTF challenge setup automation
- Exploit templates
- Shellcode testing framework
- ASLR disabled for easier exploitation
- 32-bit support enabled

### 5. Web Server VM (`scripts/webserver/setup-webserver-vm.sh`)

Secure web server setup with comprehensive security hardening.

**Installed Components:**
- **Web Servers:** Apache2, Nginx
- **Database:** MySQL
- **Languages:** PHP, Node.js, Python3
- **Security:** Fail2Ban, UFW Firewall, SSL/TLS ready
- **Tools:** Composer, Certbot, PHPMyAdmin

**Security Features:**
- Security headers configured
- PHP security hardening
- Rate limiting
- Intrusion prevention
- SSL certificate automation
- Automated backup system

### 6. VPN Server VM (`scripts/vpn/setup-vpn-vm.sh`)

Complete VPN hosting solution with multiple protocols and management tools.

**VPN Solutions:**
- **OpenVPN:** Traditional VPN with certificate-based auth
- **WireGuard:** Modern, fast VPN protocol

**Management Features:**
- Interactive management menu
- Client configuration generators
- QR code generation for mobile clients
- Traffic monitoring and logging
- Firewall integration

## 🔧 System Requirements

- **Operating System:** Ubuntu 18.04+ or Debian 10+
- **RAM:** Minimum 2GB (4GB+ recommended)
- **Storage:** Minimum 20GB free space
- **Network:** Internet connection for downloading tools
- **Privileges:** Root/sudo access required

## 📋 Pre-Installation Checklist

1. **Fresh System:** Start with a clean Ubuntu/Debian installation
2. **Updates:** Ensure system is up to date
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
3. **Internet:** Verify internet connectivity
4. **Space:** Check available disk space
   ```bash
   df -h
   ```

## 🚀 Installation Guide

### Method 1: Direct Download and Execute

```bash
# Download the desired script
wget https://raw.githubusercontent.com/DRedDevil04/cloud-attack-machine-scripts/main/scripts/[category]/setup-[type]-vm.sh

# Make executable
chmod +x setup-[type]-vm.sh

# Run the installation
sudo ./setup-[type]-vm.sh
```

### Method 2: Clone Repository

```bash
# Clone the repository
git clone https://github.com/DRedDevil04/cloud-attack-machine-scripts.git
cd cloud-attack-machine-scripts

# Choose and run a script
sudo ./scripts/pentesting/setup-pentesting-vm.sh
```

## ⚠️ Important Notes

### Security Considerations

1. **Default Passwords:** Change all default passwords after installation
2. **Firewall Rules:** Review and adjust firewall rules for your environment
3. **Updates:** Keep systems and tools updated regularly
4. **Access Control:** Implement proper access controls and monitoring

### Post-Installation Steps

1. **Reboot Required:** Most setups require a system reboot
2. **Configuration:** Review and customize configurations as needed
3. **Testing:** Test all installed tools and services
4. **Documentation:** Document any custom modifications
5. **Backup:** Create system backups of configured VMs

### Network Configuration

- **Cloud Providers:** Configure security groups and network ACLs
- **Firewall Rules:** Adjust rules based on your network topology  
- **VPN Setup:** Configure port forwarding for VPN servers
- **DNS:** Set up proper DNS records for web services

## 🛠️ Customization

Each script is designed to be modular and customizable. You can:

1. **Modify Tool Lists:** Edit scripts to add/remove specific tools
2. **Change Configurations:** Adjust default settings and paths
3. **Add Custom Scripts:** Include your own automation scripts
4. **Environment Variables:** Customize environment setup

## 📚 Usage Examples

### Setting up a Bug Bounty Lab

```bash
# Install bug bounty tools
sudo ./scripts/bug-bounty/setup-bugbounty-vm.sh

# After reboot, run subdomain enumeration
./tools/subdomain-enum.sh target-domain.com

# Run web vulnerability scan
./tools/web-scan.sh https://target-domain.com
```

### Creating a Forensics Workstation

```bash
# Install forensics tools
sudo ./scripts/forensics/setup-forensics-vm.sh

# After reboot, start analysis
autopsy  # Launch GUI tool
# Or use command line tools for automated analysis
```

### Deploying a Secure Web Server

```bash
# Install web server
sudo ./scripts/webserver/setup-webserver-vm.sh

# After setup, generate SSL certificate
sudo generate-ssl.sh yourdomain.com

# Create regular backups
sudo backup-webserver.sh
```

## 🔍 Troubleshooting

### Common Issues

1. **Permission Denied:** Ensure you're running scripts with sudo
2. **Network Timeouts:** Check internet connectivity and DNS
3. **Package Conflicts:** Start with a fresh system installation
4. **Disk Space:** Ensure adequate free space before installation

### Debug Mode

Run scripts with bash debug mode for verbose output:
```bash
sudo bash -x ./setup-script-name.sh
```

### Log Files

Most scripts create logs in `/var/log/` or display real-time output during installation.

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with detailed description

### Guidelines

- **Security First:** Ensure all tools and configurations follow security best practices
- **Documentation:** Document any new features or changes
- **Testing:** Test on clean systems before submitting
- **Compatibility:** Ensure compatibility with Ubuntu/Debian systems

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚖️ Legal Disclaimer

These scripts are intended for educational purposes, authorized security testing, and legitimate system administration. Users are responsible for:

- Obtaining proper authorization before testing
- Complying with applicable laws and regulations  
- Using tools ethically and responsibly
- Respecting others' privacy and property

The authors are not responsible for misuse of these tools.

## 📞 Support

- **Issues:** Report bugs and request features via GitHub Issues
- **Documentation:** Check this README and script comments
- **Community:** Join discussions in GitHub Discussions

## 🔄 Updates

Scripts are regularly updated to include:
- Latest tool versions
- Security patches
- New features and improvements
- Bug fixes and optimizations

Check the repository regularly for updates or watch for notifications.

---

**Happy Hacking!** 🛡️💻
