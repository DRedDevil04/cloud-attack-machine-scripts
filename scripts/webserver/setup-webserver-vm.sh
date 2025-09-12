#!/bin/bash

# Web Server VM Setup Script
# This script sets up a secure web server with Apache/Nginx, PHP, MySQL, and security hardening

set -e

echo "=========================================="
echo "Setting up Web Server VM"
echo "=========================================="

# Update system packages
echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install web server stack
echo "[+] Installing LAMP stack..."
sudo apt install -y \
    apache2 \
    nginx \
    mysql-server \
    php \
    php-fpm \
    php-mysql \
    php-cli \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-json \
    php-opcache \
    libapache2-mod-php \
    phpmyadmin

# Install additional web technologies
echo "[+] Installing additional web technologies..."
sudo apt install -y \
    nodejs \
    npm \
    python3 \
    python3-pip \
    certbot \
    python3-certbot-apache \
    python3-certbot-nginx \
    fail2ban \
    ufw \
    htop \
    curl \
    wget \
    git \
    unzip \
    zip

# Install Node.js LTS
echo "[+] Installing Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Secure MySQL installation
echo "[+] Securing MySQL installation..."
sudo mysql_secure_installation <<EOF

y
0
y
y
y
y
EOF

# Configure Apache
echo "[+] Configuring Apache..."
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod headers
sudo a2enmod security2

# Create Apache security configuration
sudo tee /etc/apache2/conf-available/security-hardening.conf > /dev/null << 'EOF'
# Hide Apache version
ServerTokens Prod
ServerSignature Off

# Disable server-info and server-status
<LocationMatch "/(server-info|server-status)">
    Require all denied
</LocationMatch>

# Security headers
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
Header always set X-XSS-Protection "1; mode=block"
Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
Header always set Content-Security-Policy "default-src 'self'"

# Disable unnecessary HTTP methods
<LimitExcept GET POST HEAD>
    Require all denied
</LimitExcept>

# Hide .htaccess files
<Files ~ "^\.ht">
    Require all denied
</Files>

# Prevent access to sensitive files
<FilesMatch "\.(htaccess|htpasswd|ini|log|sh|inc|bak|config)$">
    Require all denied
</FilesMatch>
EOF

sudo a2enconf security-hardening

# Configure Nginx
echo "[+] Configuring Nginx..."
sudo tee /etc/nginx/conf.d/security-hardening.conf > /dev/null << 'EOF'
# Hide Nginx version
server_tokens off;

# Security headers
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";

# Rate limiting
limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
limit_req zone=one burst=5;

# File upload restrictions
client_max_body_size 10M;

# Timeout settings
client_body_timeout 12;
client_header_timeout 12;
keepalive_timeout 15;
send_timeout 10;

# Buffer size limitations
client_body_buffer_size 1k;
client_header_buffer_size 1k;
client_max_body_size 1k;
large_client_header_buffers 2 1k;
EOF

# Configure PHP security
echo "[+] Configuring PHP security..."
sudo tee -a /etc/php/*/apache2/php.ini > /dev/null << 'EOF'

; Security settings
expose_php = Off
display_errors = Off
log_errors = On
allow_url_fopen = Off
allow_url_include = Off
session.cookie_httponly = 1
session.cookie_secure = 1
session.use_strict_mode = 1
post_max_size = 8M
upload_max_filesize = 8M
max_execution_time = 30
memory_limit = 128M
EOF

sudo tee -a /etc/php/*/fpm/php.ini > /dev/null << 'EOF'

; Security settings
expose_php = Off
display_errors = Off
log_errors = On
allow_url_fopen = Off
allow_url_include = Off
session.cookie_httponly = 1
session.cookie_secure = 1
session.use_strict_mode = 1
post_max_size = 8M
upload_max_filesize = 8M
max_execution_time = 30
memory_limit = 128M
EOF

# Configure firewall
echo "[+] Configuring firewall..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Configure Fail2Ban
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

[apache-auth]
enabled = true
port = http,https
logpath = /var/log/apache2/error.log

[apache-badbots]
enabled = true
port = http,https
logpath = /var/log/apache2/access.log
bantime = 86400

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

[nginx-limit-req]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 10
EOF

# Create web directories
echo "[+] Creating web directories..."
sudo mkdir -p /var/www/html/secure
sudo mkdir -p /var/log/webserver-setup
sudo mkdir -p /etc/ssl/private

# Set proper permissions
echo "[+] Setting proper permissions..."
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
sudo chmod -R 750 /var/log/apache2
sudo chmod -R 750 /var/log/nginx

# Create sample secure PHP application
echo "[+] Creating sample secure application..."
sudo tee /var/www/html/index.php > /dev/null << 'EOF'
<?php
// Secure PHP application template
session_start();

// Security headers
header('X-Frame-Options: DENY');
header('X-Content-Type-Options: nosniff');
header('X-XSS-Protection: 1; mode=block');
header('Content-Security-Policy: default-src \'self\'');

// CSRF token generation
if (!isset($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .status { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .info { background-color: #cce7ff; color: #004085; border: 1px solid #b8daff; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔒 Secure Web Server Setup Complete</h1>
        
        <div class="status success">
            <strong>✅ Web Server is Running</strong><br>
            Your secure web server has been successfully configured.
        </div>
        
        <div class="status info">
            <strong>📊 System Information:</strong><br>
            Server Software: <?php echo $_SERVER['SERVER_SOFTWARE']; ?><br>
            PHP Version: <?php echo PHP_VERSION; ?><br>
            Document Root: <?php echo $_SERVER['DOCUMENT_ROOT']; ?><br>
            Server Time: <?php echo date('Y-m-d H:i:s'); ?><br>
        </div>
        
        <h2>Security Features Enabled:</h2>
        <ul>
            <li>✅ Security Headers (X-Frame-Options, CSP, etc.)</li>
            <li>✅ PHP Security Configuration</li>
            <li>✅ Fail2Ban Intrusion Prevention</li>
            <li>✅ UFW Firewall</li>
            <li>✅ SSL/TLS Ready (use Certbot for certificates)</li>
            <li>✅ Rate Limiting</li>
            <li>✅ File Upload Restrictions</li>
        </ul>
        
        <h2>Next Steps:</h2>
        <ol>
            <li>Configure your domain name</li>
            <li>Obtain SSL certificate: <code>sudo certbot --apache -d yourdomain.com</code></li>
            <li>Deploy your web application</li>
            <li>Regular security updates: <code>sudo apt update && sudo apt upgrade</code></li>
        </ol>
        
        <p><strong>CSRF Token:</strong> <code><?php echo $_SESSION['csrf_token']; ?></code></p>
    </div>
</body>
</html>
EOF

# Install Composer for PHP dependency management
echo "[+] Installing Composer..."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Create SSL certificate generation script
echo "[+] Creating SSL certificate script..."
sudo tee /usr/local/bin/generate-ssl.sh > /dev/null << 'EOF'
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <domain>"
    echo "Example: $0 example.com"
    exit 1
fi

domain=$1

echo "Generating SSL certificate for $domain..."
sudo certbot --apache -d $domain --non-interactive --agree-tos --email admin@$domain

# Enable SSL redirect
sudo a2enmod ssl
sudo systemctl reload apache2

echo "SSL certificate generated and Apache configured for $domain"
EOF

sudo chmod +x /usr/local/bin/generate-ssl.sh

# Create backup script
echo "[+] Creating backup script..."
sudo tee /usr/local/bin/backup-webserver.sh > /dev/null << 'EOF'
#!/bin/bash

backup_dir="/var/backups/webserver"
date=$(date +%Y%m%d_%H%M%S)

mkdir -p $backup_dir

echo "Creating web server backup..."

# Backup web files
tar -czf "$backup_dir/webfiles_$date.tar.gz" /var/www/html

# Backup Apache configuration
tar -czf "$backup_dir/apache_config_$date.tar.gz" /etc/apache2

# Backup Nginx configuration
tar -czf "$backup_dir/nginx_config_$date.tar.gz" /etc/nginx

# Backup MySQL databases
mysqldump --all-databases > "$backup_dir/mysql_backup_$date.sql"

# Cleanup old backups (keep 7 days)
find $backup_dir -name "*.tar.gz" -mtime +7 -delete
find $backup_dir -name "*.sql" -mtime +7 -delete

echo "Backup completed: $backup_dir"
EOF

sudo chmod +x /usr/local/bin/backup-webserver.sh

# Start and enable services
echo "[+] Starting and enabling services..."
sudo systemctl enable apache2
sudo systemctl enable nginx
sudo systemctl enable mysql
sudo systemctl enable fail2ban
sudo systemctl enable ufw

sudo systemctl start apache2
sudo systemctl start mysql
sudo systemctl start fail2ban

# Stop nginx by default (user can choose between Apache and Nginx)
sudo systemctl stop nginx

echo "=========================================="
echo "Web Server VM setup completed!"
echo "=========================================="
echo ""
echo "Installed components:"
echo "- Web Servers: Apache2, Nginx"
echo "- Database: MySQL"
echo "- Languages: PHP, Node.js, Python3"
echo "- Security: Fail2Ban, UFW Firewall, SSL/TLS ready"
echo "- Tools: Composer, Certbot, PHPMyAdmin"
echo ""
echo "Security features:"
echo "- Security headers configured"
echo "- PHP security hardening applied"
echo "- Firewall rules configured"
echo "- Intrusion prevention (Fail2Ban)"
echo "- Rate limiting enabled"
echo ""
echo "Useful commands:"
echo "- Generate SSL: sudo generate-ssl.sh yourdomain.com"
echo "- Backup server: sudo backup-webserver.sh"
echo "- Check Apache status: sudo systemctl status apache2"
echo "- Check security logs: sudo fail2ban-client status"
echo ""
echo "Default web root: /var/www/html"
echo "Apache config: /etc/apache2/"
echo "Nginx config: /etc/nginx/"
echo ""
echo "Note: Apache is running by default. To use Nginx instead:"
echo "sudo systemctl stop apache2 && sudo systemctl start nginx"
echo ""
echo "Visit http://your-server-ip to see the status page."