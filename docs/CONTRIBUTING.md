# Contributing to Cloud Attack Machine Scripts

Thank you for your interest in contributing! This guide will help you understand how to contribute effectively to this project.

## 🤝 How to Contribute

### Types of Contributions

1. **Bug Reports** - Report issues with existing scripts
2. **Feature Requests** - Suggest new VM types or tools
3. **Code Contributions** - Submit new scripts or improvements
4. **Documentation** - Improve guides and documentation
5. **Testing** - Test scripts on different environments

## 📋 Getting Started

### Prerequisites

- Basic knowledge of Linux/Unix systems
- Familiarity with bash scripting
- Understanding of cybersecurity tools
- Experience with package managers (apt, pip, npm, etc.)

### Development Environment

1. **Fork the repository**
2. **Clone your fork locally**
   ```bash
   git clone https://github.com/yourusername/cloud-attack-machine-scripts.git
   cd cloud-attack-machine-scripts
   ```
3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 🔧 Script Development Guidelines

### Script Structure

All setup scripts should follow this general structure:

```bash
#!/bin/bash

# Script Name VM Setup Script
# Brief description of what this script does

set -e

echo "=========================================="
echo "Setting up [VM Type] VM"
echo "=========================================="

# Update system packages
echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential tools
echo "[+] Installing essential tools..."
# Installation commands here

# Configure tools
echo "[+] Configuring tools..."
# Configuration commands here

# Set up environment
echo "[+] Setting up environment..."
# Environment setup here

echo "=========================================="
echo "[VM Type] VM setup completed!"
echo "=========================================="
```

### Best Practices

#### 1. Error Handling
```bash
# Always use set -e for error handling
set -e

# Check command success when needed
if ! command -v tool &> /dev/null; then
    echo "Failed to install tool"
    exit 1
fi
```

#### 2. Progress Indicators
```bash
# Use clear progress indicators
echo "[+] Installing tools..."
echo "[+] Configuring services..."
echo "[+] Setting up environment..."
```

#### 3. Package Installation
```bash
# Group related packages
sudo apt install -y \
    package1 \
    package2 \
    package3

# Install Python packages to user directory
pip3 install --user package_name
```

#### 4. Directory Creation
```bash
# Create directories with proper permissions
mkdir -p ~/tools
mkdir -p ~/reports
```

#### 5. Service Management
```bash
# Enable and start services
sudo systemctl enable service_name
sudo systemctl start service_name
```

### Security Considerations

1. **Always validate downloads**
2. **Use official repositories when possible**
3. **Implement proper firewall rules**
4. **Follow principle of least privilege**
5. **Document security implications**

### Testing Requirements

Before submitting:

1. **Syntax Check**
   ```bash
   bash -n your-script.sh
   ```

2. **Test on Clean System**
   - Test on fresh Ubuntu/Debian installation
   - Document any prerequisites
   - Verify all tools install correctly

3. **Compatibility Testing**
   - Test on multiple Ubuntu/Debian versions
   - Verify cloud provider compatibility

## 📝 Documentation Standards

### Script Documentation

Each script should include:

```bash
#!/bin/bash

# VM Type Setup Script
# Detailed description of the script's purpose
# Author: Your Name
# Version: 1.0
# Last Updated: YYYY-MM-DD
#
# This script installs and configures:
# - Tool category 1 (tool1, tool2, tool3)
# - Tool category 2 (tool4, tool5)
# - Security configurations
#
# Prerequisites:
# - Ubuntu 20.04+ or Debian 11+
# - 2GB RAM minimum
# - Internet connection
# - Sudo privileges
#
# Usage:
# sudo ./setup-vmtype-vm.sh
```

### README Updates

When adding new scripts:

1. Update main README.md
2. Add to repository structure section
3. Include tool list and key features
4. Update installation examples

## 🧪 Testing Checklist

### Before Submitting a PR

- [ ] Script syntax is valid (`bash -n script.sh`)
- [ ] Tested on clean Ubuntu 20.04/22.04 system
- [ ] Tested on clean Debian 11/12 system
- [ ] All tools install successfully
- [ ] All services start properly
- [ ] Firewall rules are appropriate
- [ ] Documentation is complete
- [ ] No sensitive data in script
- [ ] Proper error handling implemented

### Test Environments

Test your scripts on:

1. **Local VMs** - VirtualBox/VMware
2. **Cloud Instances** - AWS/GCP/Azure/DigitalOcean
3. **Different Architectures** - x86_64, ARM64 (if applicable)

## 📤 Submission Process

### Pull Request Guidelines

1. **Clear Title**: Use descriptive PR titles
   ```
   Add Malware Analysis VM Setup Script
   Fix Bug in Pentesting VM Firewall Configuration
   Update Bug Bounty Tools to Latest Versions
   ```

2. **Detailed Description**: Include:
   - What changes were made
   - Why the changes were needed
   - Testing performed
   - Screenshots if applicable

3. **Commit Messages**: Use clear, descriptive commit messages
   ```
   Add malware analysis VM setup with YARA and Cuckoo Sandbox
   Fix firewall rules in pentesting VM script
   Update nuclei to latest version in bug bounty script
   ```

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Tested on Ubuntu 22.04
- [ ] Tested on Debian 12
- [ ] All tools install successfully
- [ ] Services start properly

## Checklist
- [ ] My code follows the project style guidelines
- [ ] I have performed a self-review
- [ ] I have tested my changes
- [ ] Documentation has been updated
```

## 🐛 Bug Reports

### Information to Include

1. **Environment Details**
   - OS version and architecture
   - Cloud provider (if applicable)
   - Available RAM and disk space

2. **Error Description**
   - What you were trying to do
   - What happened instead
   - Complete error messages

3. **Reproduction Steps**
   - Step-by-step instructions
   - Include commands used
   - Mention any deviations from instructions

### Bug Report Template

```markdown
**Environment:**
- OS: Ubuntu 22.04 x64
- RAM: 4GB
- Disk: 50GB free
- Cloud: AWS t3.medium

**Description:**
Clear description of the issue

**Steps to Reproduce:**
1. Run script with: sudo ./script.sh
2. Error occurs at step X
3. See error message below

**Error Message:**
```
Paste complete error message here
```

**Expected Behavior:**
What should have happened

**Additional Context:**
Any other relevant information
```

## 🚀 Feature Requests

### New VM Types

When suggesting new VM types:

1. **Use Case**: Explain the target audience
2. **Tool List**: Provide comprehensive tool list
3. **Justification**: Why this VM type is needed
4. **Resources**: Links to tool documentation

### Tool Additions

For adding tools to existing VMs:

1. **Tool Description**: What the tool does
2. **Installation Method**: How to install it
3. **Configuration**: Any special configuration needed
4. **Integration**: How it fits with existing tools

## 📜 Code of Conduct

### Our Standards

- Be respectful and inclusive
- Focus on what's best for the community
- Show empathy towards other contributors
- Provide constructive feedback
- Accept criticism gracefully

### Prohibited Behavior

- Harassment or discrimination
- Trolling or inflammatory comments
- Publishing private information
- Promoting illegal activities
- Spamming or off-topic discussions

## 🏷️ Versioning and Releases

### Version Numbers

We use semantic versioning (MAJOR.MINOR.PATCH):
- MAJOR: Breaking changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes, backward compatible

### Release Process

1. Major releases include new VM types
2. Minor releases include tool updates
3. Patch releases include bug fixes

## 💬 Getting Help

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Pull Request Reviews**: Code-specific discussions

### Response Times

- Issues: We aim to respond within 48 hours
- PRs: Initial review within 72 hours
- Complex issues may take longer

## 🙏 Recognition

Contributors will be:
- Listed in project contributors
- Mentioned in release notes
- Given credit in documentation

Thank you for helping make this project better! 🚀