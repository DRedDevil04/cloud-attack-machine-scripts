#!/bin/bash

# VPN Server VM Setup Script
# This script sets up a Linux VM for VPN hosting with OpenVPN and WireGuard

set -e

echo "=========================================="
echo "Setting up VPN Server VM"
echo "=========================================="

# Update system packages
echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
echo "[+] Installing essential packages..."
sudo apt install -y \
    openvpn \
    easy-rsa \
    wireguard \
    wireguard-tools \
    ufw \
    fail2ban \
    iptables \
    iptables-persistent \
    curl \
    wget \
    git \
    unzip \
    zip \
    qrencode \
    htop \
    net-tools \
    dnsutils

# Enable IP forwarding
echo "[+] Enabling IP forwarding..."
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Create directories
echo "[+] Creating directories..."
sudo mkdir -p /etc/openvpn/server
sudo mkdir -p /etc/openvpn/client
sudo mkdir -p /etc/wireguard
sudo mkdir -p /var/log/vpn

# Set up OpenVPN
echo "[+] Setting up OpenVPN..."

# Download OpenVPN installation script
cd /tmp
wget https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh

# Create OpenVPN configuration script
cat > /tmp/openvpn-setup-answers << 'EOF'
1
UDP
1194
1
8.8.8.8
8.8.4.4
n
y
EOF

# Run OpenVPN installation with predefined answers
sudo AUTO_INSTALL=y ./openvpn-install.sh < /tmp/openvpn-setup-answers

# Set up WireGuard
echo "[+] Setting up WireGuard..."

# Generate WireGuard keys
wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key
sudo chmod 600 /etc/wireguard/server_private.key

# Get server private key
server_private_key=$(sudo cat /etc/wireguard/server_private.key)
server_public_key=$(sudo cat /etc/wireguard/server_public.key)

# Create WireGuard server configuration
sudo tee /etc/wireguard/wg0.conf > /dev/null << EOF
[Interface]
Address = 10.66.66.1/24
SaveConfig = true
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 51820
PrivateKey = $server_private_key

EOF

# Create WireGuard client management scripts
echo "[+] Creating WireGuard management scripts..."

# Script to add WireGuard client
sudo tee /usr/local/bin/add-wg-client.sh > /dev/null << 'EOF'
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <client_name>"
    exit 1
fi

client_name=$1
config_dir="/etc/wireguard/clients"
server_public_key=$(cat /etc/wireguard/server_public.key)
server_endpoint="YOUR_SERVER_IP:51820"  # Replace with actual server IP

# Create client directory
mkdir -p $config_dir

# Generate client keys
client_private_key=$(wg genkey)
client_public_key=$(echo $client_private_key | wg pubkey)

# Get next available IP
last_ip=$(wg show wg0 | grep "peer" -A 1 | grep "allowed" | sed 's/.*10\.66\.66\.\([0-9]*\).*/\1/' | sort -n | tail -1)
if [ -z "$last_ip" ]; then
    client_ip="10.66.66.2"
else
    client_ip="10.66.66.$((last_ip + 1))"
fi

# Add client to server configuration
echo "" >> /etc/wireguard/wg0.conf
echo "[Peer]" >> /etc/wireguard/wg0.conf
echo "PublicKey = $client_public_key" >> /etc/wireguard/wg0.conf
echo "AllowedIPs = $client_ip/32" >> /etc/wireguard/wg0.conf

# Create client configuration
cat > "$config_dir/$client_name.conf" << EOL
[Interface]
PrivateKey = $client_private_key
Address = $client_ip/24
DNS = 8.8.8.8, 8.8.4.4

[Peer]
PublicKey = $server_public_key
Endpoint = $server_endpoint
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOL

# Generate QR code for mobile clients
qrencode -t ansiutf8 < "$config_dir/$client_name.conf"
qrencode -t png -o "$config_dir/$client_name.png" < "$config_dir/$client_name.conf"

echo "Client $client_name added!"
echo "Configuration file: $config_dir/$client_name.conf"
echo "QR code saved as: $config_dir/$client_name.png"
echo ""
echo "Restart WireGuard to apply changes: sudo systemctl restart wg-quick@wg0"
EOF

sudo chmod +x /usr/local/bin/add-wg-client.sh

# Script to remove WireGuard client
sudo tee /usr/local/bin/remove-wg-client.sh > /dev/null << 'EOF'
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <client_name>"
    exit 1
fi

client_name=$1
config_dir="/etc/wireguard/clients"

if [ ! -f "$config_dir/$client_name.conf" ]; then
    echo "Client $client_name not found!"
    exit 1
fi

# Get client public key
client_public_key=$(grep "PublicKey" "$config_dir/$client_name.conf" | cut -d' ' -f3)

# Remove client from server configuration
sed -i "/\[Peer\]/,/PublicKey = $client_public_key/{/PublicKey = $client_public_key/,/^$/d;}" /etc/wireguard/wg0.conf

# Remove client files
rm -f "$config_dir/$client_name.conf"
rm -f "$config_dir/$client_name.png"

echo "Client $client_name removed!"
echo "Restart WireGuard to apply changes: sudo systemctl restart wg-quick@wg0"
EOF

sudo chmod +x /usr/local/bin/remove-wg-client.sh

# Configure firewall
echo "[+] Configuring firewall..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 1194/udp  # OpenVPN
sudo ufw allow 51820/udp # WireGuard

# Configure iptables for VPN traffic
echo "[+] Configuring iptables..."
# Allow VPN traffic forwarding
sudo iptables -A FORWARD -i tun+ -j ACCEPT
sudo iptables -A FORWARD -i wg0 -j ACCEPT
sudo iptables -A FORWARD -o tun+ -j ACCEPT
sudo iptables -A FORWARD -o wg0 -j ACCEPT

# NAT for VPN clients
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.66.66.0/24 -o eth0 -j MASQUERADE

# Save iptables rules
sudo netfilter-persistent save

# Configure Fail2Ban for VPN
echo "[+] Configuring Fail2Ban..."
sudo tee /etc/fail2ban/jail.local > /dev/null << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3

[openvpn]
enabled = true
port = 1194
protocol = udp
logpath = /var/log/openvpn/server.log
maxretry = 3
bantime = 86400
EOF

# Create VPN monitoring script
echo "[+] Creating VPN monitoring script..."
sudo tee /usr/local/bin/vpn-status.sh > /dev/null << 'EOF'
#!/bin/bash

echo "=========================================="
echo "VPN Server Status"
echo "=========================================="

echo ""
echo "OpenVPN Status:"
if systemctl is-active --quiet openvpn-server@server; then
    echo "✅ OpenVPN is running"
    echo "Connected clients:"
    if [ -f /var/log/openvpn/status.log ]; then
        grep "CLIENT_LIST" /var/log/openvn/status.log | awk '{print $2, $3, $4, $5}' | column -t
    fi
else
    echo "❌ OpenVPN is not running"
fi

echo ""
echo "WireGuard Status:"
if systemctl is-active --quiet wg-quick@wg0; then
    echo "✅ WireGuard is running"
    echo "Interface details:"
    sudo wg show
else
    echo "❌ WireGuard is not running"
fi

echo ""
echo "Firewall Status:"
sudo ufw status numbered

echo ""
echo "Network Interface Status:"
ip addr show | grep -E "(tun|wg)" -A 2

echo ""
echo "VPN Traffic Statistics:"
sudo iptables -L FORWARD -v -n | grep -E "(tun|wg)"

echo ""
echo "Active VPN Connections:"
netstat -an | grep -E ":1194|:51820"
EOF

sudo chmod +x /usr/local/bin/vpn-status.sh

# Create client configuration generator for OpenVPN
echo "[+] Creating OpenVPN client generator..."
sudo tee /usr/local/bin/generate-ovpn-client.sh > /dev/null << 'EOF'
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <client_name>"
    exit 1
fi

client_name=$1

# Use the existing OpenVPN script to create client
echo "Creating OpenVPN client: $client_name"
sudo /usr/local/bin/openvpn-install.sh

echo "OpenVPN client configuration created for $client_name"
echo "File location: /root/$client_name.ovpn"
EOF

sudo chmod +x /usr/local/bin/generate-ovpn-client.sh

# Create VPN management menu
echo "[+] Creating VPN management menu..."
sudo tee /usr/local/bin/vpn-menu.sh > /dev/null << 'EOF'
#!/bin/bash

while true; do
    clear
    echo "=========================================="
    echo "VPN Server Management Menu"
    echo "=========================================="
    echo ""
    echo "1. Show VPN Status"
    echo "2. Add WireGuard Client"
    echo "3. Remove WireGuard Client"
    echo "4. List WireGuard Clients"
    echo "5. Generate OpenVPN Client"
    echo "6. Start/Stop WireGuard"
    echo "7. Start/Stop OpenVPN"
    echo "8. View Logs"
    echo "9. Exit"
    echo ""
    read -p "Choose an option [1-9]: " choice

    case $choice in
        1)
            vpn-status.sh
            read -p "Press Enter to continue..."
            ;;
        2)
            read -p "Enter client name: " client_name
            sudo add-wg-client.sh "$client_name"
            read -p "Press Enter to continue..."
            ;;
        3)
            read -p "Enter client name to remove: " client_name
            sudo remove-wg-client.sh "$client_name"
            read -p "Press Enter to continue..."
            ;;
        4)
            echo "WireGuard clients:"
            ls -1 /etc/wireguard/clients/ 2>/dev/null | grep ".conf" | sed 's/.conf$//' || echo "No clients found"
            read -p "Press Enter to continue..."
            ;;
        5)
            read -p "Enter client name: " client_name
            sudo generate-ovpn-client.sh "$client_name"
            read -p "Press Enter to continue..."
            ;;
        6)
            echo "WireGuard Control:"
            echo "1. Start  2. Stop  3. Restart"
            read -p "Choose: " wg_action
            case $wg_action in
                1) sudo systemctl start wg-quick@wg0 ;;
                2) sudo systemctl stop wg-quick@wg0 ;;
                3) sudo systemctl restart wg-quick@wg0 ;;
            esac
            read -p "Press Enter to continue..."
            ;;
        7)
            echo "OpenVPN Control:"
            echo "1. Start  2. Stop  3. Restart"
            read -p "Choose: " ovpn_action
            case $ovpn_action in
                1) sudo systemctl start openvpn-server@server ;;
                2) sudo systemctl stop openvpn-server@server ;;
                3) sudo systemctl restart openvpn-server@server ;;
            esac
            read -p "Press Enter to continue..."
            ;;
        8)
            echo "Log Options:"
            echo "1. OpenVPN logs  2. WireGuard logs  3. System logs"
            read -p "Choose: " log_choice
            case $log_choice in
                1) sudo tail -f /var/log/openvpn/server.log ;;
                2) sudo journalctl -u wg-quick@wg0 -f ;;
                3) sudo tail -f /var/log/syslog | grep -E "(openvpn|wireguard)" ;;
            esac
            ;;
        9)
            exit 0
            ;;
        *)
            echo "Invalid option!"
            read -p "Press Enter to continue..."
            ;;
    esac
done
EOF

sudo chmod +x /usr/local/bin/vpn-menu.sh

# Enable and start services
echo "[+] Enabling and starting services..."
sudo systemctl enable openvpn-server@server
sudo systemctl enable wg-quick@wg0
sudo systemctl enable fail2ban

sudo systemctl start openvpn-server@server
sudo systemctl start fail2ban

# Note: WireGuard will be started manually by user after configuration

echo "=========================================="
echo "VPN Server VM setup completed!"
echo "=========================================="
echo ""
echo "Installed VPN solutions:"
echo "- OpenVPN (UDP port 1194)"
echo "- WireGuard (UDP port 51820)"
echo ""
echo "Security features:"
echo "- UFW Firewall configured"
echo "- Fail2Ban intrusion prevention"
echo "- IP forwarding enabled"
echo "- NAT configured for VPN traffic"
echo ""
echo "Management commands:"
echo "- VPN status: sudo vpn-status.sh"
echo "- VPN menu: sudo vpn-menu.sh"
echo "- Add WG client: sudo add-wg-client.sh <name>"
echo "- Remove WG client: sudo remove-wg-client.sh <name>"
echo "- OpenVPN client: sudo generate-ovpn-client.sh <name>"
echo ""
echo "Configuration files:"
echo "- OpenVPN: /etc/openvpn/server/"
echo "- WireGuard: /etc/wireguard/"
echo "- WG clients: /etc/wireguard/clients/"
echo ""
echo "Important next steps:"
echo "1. Replace 'YOUR_SERVER_IP' in /usr/local/bin/add-wg-client.sh"
echo "2. Configure your firewall/router to forward VPN ports"
echo "3. Start WireGuard: sudo systemctl start wg-quick@wg0"
echo "4. Create your first VPN clients"
echo ""
echo "Use 'sudo vpn-menu.sh' for easy management!"