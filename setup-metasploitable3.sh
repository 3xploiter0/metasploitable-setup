#!/bin/bash

# Metasploitable3 Docker Setup Script for Kali Linux
# Run with: bash setup-metasploitable3.sh

set -e  # Exit on error

echo "========================================="
echo "Metasploitable3 Docker Setup for Kali Linux"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "⚠️  Warning: Running as root. Consider running as regular user."
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Function to print section headers
print_header() {
    echo ""
    echo "=== $1 ==="
    echo ""
}

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo "✅ $1"
    else
        echo "❌ $1 failed"
        exit 1
    fi
}

print_header "1. Checking Prerequisites"

# Check Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker is installed"
    docker --version
else
    echo "❌ Docker not found. Please install Docker first."
    echo "Refer to README.md for installation instructions."
    exit 1
fi

# Check Docker daemon
if docker info &> /dev/null; then
    echo "✅ Docker daemon is running"
else
    echo "❌ Docker daemon not running. Start with: sudo systemctl start docker"
    exit 1
fi

print_header "2. Creating Lab Directory"
LAB_DIR="$HOME/metasploitable-lab"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"
check_success "Created lab directory: $LAB_DIR"

print_header "3. Cloning Metasploitable3 Repository"
if [ -d "metasploitable3" ]; then
    echo "⚠️  Metasploitable3 directory already exists. Skipping clone."
    cd metasploitable3
else
    git clone https://github.com/rapid7/metasploitable3.git
    check_success "Cloned Metasploitable3 repository"
    cd metasploitable3
fi

print_header "4. Setting Up Docker Compose Lab"
echo "Creating complete lab with Kali attacker and Metasploitable3 victim..."
echo ""

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:
  victim:
    image: kirscht/metasploitable3-ub1404
    container_name: victim
    hostname: victim
    entrypoint:
      - /bin/bash
      - -lc
      - |
        rm -rf /var/lock
        mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2
        chown -R www-data:www-data /var/lock/apache2 /var/run/apache2
        service apache2 start
        service mysql start
        exec /usr/bin/tail -f /dev/null
    networks:
      lab_net:
        ipv4_address: 172.23.0.3
    restart: unless-stopped

  kali:
    image: kalilinux/kali-rolling
    container_name: kali_attacker
    hostname: kali_attacker
    tty: true
    stdin_open: true
    command: ["/bin/bash"]
    networks:
      lab_net:
        ipv4_address: 172.23.0.2
    restart: unless-stopped

networks:
  lab_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.23.0.0/24
EOF

check_success "Created docker-compose.yml"

print_header "5. Starting Lab Containers"
echo "Pulling images and starting containers..."
docker compose up -d

check_success "Lab containers started"

print_header "6. Verifying Setup"
echo "Checking container status..."
sleep 5  # Give containers time to start

if docker compose ps | grep -q "Up"; then
    echo "✅ Containers are running"
    
    # Check victim container
    if docker compose logs victim 2>/dev/null | grep -q "apache2"; then
        echo "✅ Apache service started in victim"
    else
        echo "⚠️  Apache may not be running in victim"
    fi
    
    echo ""
    echo "📋 Lab Information:"
    echo "   Victim Container: victim (172.23.0.3)"
    echo "   Kali Container: kali_attacker (172.23.0.2)"
    echo "   Network: lab_net (172.23.0.0/24)"
    
    echo ""
    echo "🔍 Useful commands:"
    echo "   Access Kali: docker exec -it kali_attacker bash"
    echo "   Access victim: docker exec -it victim bash"
    echo "   View logs: docker compose logs"
    echo "   Stop lab: docker compose down"
    echo "   Restart: docker compose restart"
    
else
    echo "❌ Containers failed to start. Check logs: docker compose logs"
    exit 1
fi

print_header "7. Quick Test from Kali"
echo "Opening Kali container to test connectivity..."
echo ""

# Run a quick test from Kali
docker exec kali_attacker bash -c "
    echo 'Installing basic tools...'
    apt update > /dev/null 2>&1 && apt install -y iputils-ping curl > /dev/null 2>&1
    echo 'Testing connectivity to victim...'
    if ping -c 2 victim > /dev/null 2>&1; then
        echo '✅ Network connectivity: OK'
        echo 'Testing web server...'
        if curl -I http://victim 2>/dev/null | grep -q '200 OK'; then
            echo '✅ Web server: Responding'
        else
            echo '⚠️  Web server: May not be fully started'
        fi
    else
        echo '⚠️  Network connectivity: Failed (waiting for startup)'
    fi
    echo ''
    echo 'To access Kali container: docker exec -it kali_attacker bash'
    echo 'Then run: ping victim && curl -I http://victim'
"

print_header "8. Security Checklist"
echo "⚠️  IMPORTANT: Before starting penetration testing:"
echo "   1. Ensure lab is isolated from production network"
echo "   2. Verify no sensitive data is on the testing machine"
echo "   3. Use strong passwords for any services you configure"
echo "   4. Document all tests and findings"
echo "   5. Clean up thoroughly after testing"

print_header "9. Next Steps"
echo "🎯 Recommended first scans:"
echo "   1. nmap -sV -sC $CONTAINER_IP"
echo "   2. nikto -h http://$CONTAINER_IP"
echo "   3. dirb http://$CONTAINER_IP"
echo ""
echo "📚 Refer to README.md for detailed testing procedures"

echo ""
echo "========================================="
echo "✅ Setup Complete!"
echo "========================================="
echo ""
echo "Metasploitable3 is ready for testing at:"
echo "   HTTP: http://$CONTAINER_IP"
echo "   HTTPS: https://$CONTAINER_IP (self-signed cert)"
echo ""
echo "Happy hacking! 🎯"
echo ""