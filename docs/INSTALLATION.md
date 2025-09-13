# Installation Guide

This guide provides detailed instructions for installing and configuring each type of VM setup script.

## Prerequisites

### System Requirements
- **OS:** Ubuntu 20.04 LTS or newer, Debian 11 or newer
- **RAM:** Minimum 2GB, recommended 4GB+
- **Storage:** 20GB+ free disk space
- **Network:** Stable internet connection
- **Access:** sudo/root privileges

### Pre-installation Steps

1. **Update the system:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install required dependencies:**
   ```bash
   sudo apt install -y curl wget git unzip
   ```

3. **Check available disk space:**
   ```bash
   df -h
   ```

## Installation Methods

### Method 1: Direct Script Execution

```bash
# Download and execute in one command
curl -fsSL https://raw.githubusercontent.com/DRedDevil04/cloud-attack-machine-scripts/main/scripts/pentesting/setup-pentesting-vm.sh | sudo bash
```

### Method 2: Download and Review

```bash
# Download script
wget https://raw.githubusercontent.com/DRedDevil04/cloud-attack-machine-scripts/main/scripts/pentesting/setup-pentesting-vm.sh

# Review the script (recommended)
less setup-pentesting-vm.sh

# Make executable and run
chmod +x setup-pentesting-vm.sh
sudo ./setup-pentesting-vm.sh
```

### Method 3: Clone Repository

```bash
# Clone the entire repository
git clone https://github.com/DRedDevil04/cloud-attack-machine-scripts.git
cd cloud-attack-machine-scripts

# Run desired script
sudo ./scripts/pentesting/setup-pentesting-vm.sh
```

## Script-Specific Installation

### Pentesting VM

**Installation time:** ~30-45 minutes

```bash
sudo ./scripts/pentesting/setup-pentesting-vm.sh
```

**Post-installation:**
- Reboot required: Yes
- Manual steps: None
- First run: `source ~/.bashrc`

### Forensics VM

**Installation time:** ~45-60 minutes

```bash
sudo ./scripts/forensics/setup-forensics-vm.sh
```

**Post-installation:**
- Reboot required: Yes
- Manual steps: Configure Autopsy database
- First run: Launch Autopsy from desktop

### Bug Bounty VM

**Installation time:** ~60-90 minutes

```bash
sudo ./scripts/bug-bounty/setup-bugbounty-vm.sh
```

**Post-installation:**
- Reboot required: Yes
- Manual steps: Update nuclei templates
- First run: `nuclei -update-templates`

### Binary Exploitation VM

**Installation time:** ~45-75 minutes

```bash
sudo ./scripts/binary-exploitation/setup-binexp-vm.sh
```

**Post-installation:**
- Reboot required: Yes
- Manual steps: Configure debugger preferences
- First run: Test GEF with `gdb`

### Web Server VM

**Installation time:** ~30-45 minutes

```bash
sudo ./scripts/webserver/setup-webserver-vm.sh
```

**Post-installation:**
- Reboot required: No (services restart)
- Manual steps: Configure domain name and SSL
- First run: Visit http://server-ip

### VPN Server VM

**Installation time:** ~20-30 minutes

```bash
sudo ./scripts/vpn/setup-vpn-vm.sh
```

**Post-installation:**
- Reboot required: No
- Manual steps: Update server IP in WireGuard config
- First run: `sudo vpn-menu.sh`

## Cloud Provider Specific Notes

### AWS EC2

1. **Security Groups:** Open required ports
2. **Instance Type:** t3.medium or larger recommended
3. **Storage:** Use gp3 volumes for better performance
4. **AMI:** Use Ubuntu 22.04 LTS

### Google Cloud Platform

1. **Firewall Rules:** Configure VPC firewall
2. **Machine Type:** e2-standard-2 or larger
3. **Disk:** Use SSD persistent disks
4. **Image:** Ubuntu 22.04 LTS

### Microsoft Azure

1. **Network Security Groups:** Configure inbound rules
2. **VM Size:** Standard_B2s or larger
3. **Disk:** Premium SSD recommended
4. **Image:** Ubuntu Server 22.04 LTS

### DigitalOcean

1. **Droplet Size:** 2GB RAM minimum
2. **Firewall:** Configure cloud firewall
3. **Image:** Ubuntu 22.04 x64

## Troubleshooting Installation Issues

### Common Problems

**1. Permission Denied**
```bash
# Solution: Run with sudo
sudo ./script-name.sh
```

**2. Package Not Found**
```bash
# Solution: Update package lists
sudo apt update
```

**3. Network Timeouts**
```bash
# Solution: Check internet connectivity
ping -c 4 8.8.8.8
```

**4. Disk Space Issues**
```bash
# Solution: Clean up space
sudo apt autoremove -y
sudo apt autoclean
```

**5. GPG Key Errors**
```bash
# Solution: Update keyring
sudo apt-key update
```

### Debug Mode

Run scripts in debug mode for verbose output:
```bash
sudo bash -x ./script-name.sh
```

### Manual Recovery

If installation fails midway:

1. **Check logs:**
   ```bash
   sudo journalctl -xe
   ```

2. **Clean package cache:**
   ```bash
   sudo apt clean
   sudo apt autoremove
   ```

3. **Restart services:**
   ```bash
   sudo systemctl daemon-reload
   ```

## Validation Steps

After installation, validate the setup:

### General Validation
```bash
# Check script completion
echo "Installation completed successfully"

# Verify key tools
which nmap
which python3
which git
```

### Service Validation
```bash
# Check running services
sudo systemctl status apache2  # Web server
sudo systemctl status mysql    # Database
sudo systemctl status fail2ban # Security
```

### Network Validation
```bash
# Check open ports
sudo netstat -tulpn

# Verify firewall
sudo ufw status
```

## Performance Optimization

### System Tuning
```bash
# Increase file descriptor limits
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf

# Optimize kernel parameters
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```

### Tool-Specific Optimization
```bash
# Nuclei template updates
nuclei -update-templates

# Update vulnerability databases
sudo freshclam  # ClamAV
sudo updatedb   # locate database
```

## Backup and Snapshot

After successful installation:

1. **Create system snapshot** (cloud provider specific)
2. **Export configuration files**
3. **Document custom modifications**

This ensures you can quickly restore or replicate the setup.