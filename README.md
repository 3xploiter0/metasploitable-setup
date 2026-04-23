# Metasploitable3 Docker Setup on Kali Linux

A comprehensive guide to setting up Metasploitable3 using Docker for red team practice labs on Kali Linux.

## ⚠️ IMPORTANT SECURITY WARNINGS

**CRITICAL**: Metasploitable3 is an intentionally vulnerable virtual machine designed for security training. NEVER deploy it on a network accessible from the internet or on production systems.

1. **Isolate the lab environment** - Use a separate network or VLAN
2. **Run only on dedicated hardware** - Never on production machines
3. **Disable network sharing** - Ensure the VM cannot access your main network
4. **Use strong passwords** - Even for training environments
5. **Destroy after use** - Remove all containers and images when not in use

## Prerequisites

### System Requirements
- Kali Linux (tested on Kali 2026.1)
- Docker installed and running
- Minimum 4GB RAM (8GB recommended)
- 20GB free disk space
- Virtualization enabled in BIOS

### Software Requirements
- Docker Engine 20.10+
- Docker Compose (optional but recommended)
- Git for cloning repositories

## Step 1: Install Docker (if not already installed)

```bash
# Update package list
sudo apt update

# Install Docker dependencies
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group (to run without sudo)
sudo usermod -aG docker $USER

# Apply group changes (requires logout/login or new terminal)
newgrp docker

# Verify Docker installation
docker --version
```

## 🎯 Recommended Approach: Docker Compose Setup (Proven Method)

This approach uses Docker Compose to create a complete lab environment with both attacker (Kali) and victim (Metasploitable3) containers on an isolated network.

### Step 2: Create Lab Directory and Files

```bash
# Create lab directory
mkdir -p ~/metasploitable-lab
cd ~/metasploitable-lab

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
```

### Step 3: Start the Lab

```bash
# Start both containers
docker compose up -d

# Check status
docker compose ps
```

### Step 4: Access Kali Attacker Container

```bash
# Open shell in Kali container
docker exec -it kali_attacker bash
```

### Step 5: Install Basic Tools in Kali

```bash
# Update and install essential tools
apt update && apt install -y iputils-ping nmap curl net-tools
```

### Step 6: Verify Lab Connectivity

From inside the Kali container:

```bash
# Test connectivity to victim
ping -c 3 victim

# Scan common ports
nmap -p 80,3306 victim

# Test web server
curl -I http://victim
```

## 🔧 Alternative: Single Container Setup

If you prefer a simpler setup with just Metasploitable3:

### Step 2: Pull Metasploitable3 Image

```bash
# Pull the community image
docker pull kirscht/metasploitable3-ub1404
```

### Step 3: Run with Custom Entrypoint

```bash
# Run container with proper startup
docker run -d \
  --name metasploitable3 \
  --hostname victim \
  -p 80:80 \
  -p 22:22 \
  -p 21:21 \
  -p 23:23 \
  -p 25:25 \
  -p 110:110 \
  -p 139:139 \
  -p 445:445 \
  -p 3306:3306 \
  -p 3389:3389 \
  -p 5432:5432 \
  --entrypoint /bin/bash \
  kirscht/metasploitable3-ub1404 \
  -c "rm -rf /var/lock && mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 && service apache2 start && service mysql start && tail -f /dev/null"

# Verify container is running
docker ps | grep metasploitable3
```

## Step 7: Complete Lab Verification

### For Docker Compose Setup:

```bash
# From your host machine
docker compose ps

# Check victim container logs
docker logs victim

# Check Kali container logs
docker logs kali_attacker

# Test from Kali container
docker exec -it kali_attacker bash
ping -c 3 victim
nmap -p 80,3306 victim
curl -I http://victim
```

### For Single Container Setup:

```bash
# Get container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' metasploitable3

# Test connectivity
ping -c 4 <container-ip>

# Test web services
curl -I http://<container-ip>
curl -I https://<container-ip> -k
```

## Step 8: Install Additional Tools in Kali Container

From inside the Kali container (`docker exec -it kali_attacker bash`):

```bash
# Update package list
apt update

# Install essential penetration testing tools
apt install -y \
  metasploit-framework \
  hydra \
  john \
  sqlmap \
  gobuster \
  dirb \
  nikto \
  wpscan \
  wordlists

# Configure Metasploit database
service postgresql start
msfdb init

# Install additional wordlists
apt install -y seclists
```

## Step 9: Basic Security Scans

From inside Kali container:

```bash
# Full Nmap scan
nmap -sV -sC -O -p- victim -oN /tmp/metasploitable3-scan.txt

# Nikto web vulnerability scan
nikto -h http://victim -o /tmp/nikto-scan.txt

# Directory brute force
gobuster dir -u http://victim -w /usr/share/wordlists/dirb/common.txt -o /tmp/gobuster-scan.txt

# Check for WordPress (if installed)
wpscan --url http://victim/wordpress --enumerate vp,vt,tt,u --no-update
```

## Step 9: Common Vulnerabilities to Test

Metasploitable3 includes these intentionally vulnerable services:

### Web Vulnerabilities
- **WordPress** (http://<container-ip>/wordpress) - XSS, SQLi, outdated plugins
- **DVWA** (http://<container-ip>/dvwa) - Damn Vulnerable Web App
- **Mutillidae** (http://<container-ip>/mutillidae) - OWASP WebGoat PHP

### Service Vulnerabilities
- **FTP** (port 21) - Anonymous login, weak credentials
- **SSH** (port 22) - Weak passwords, outdated version
- **Telnet** (port 23) - Clear text authentication
- **SMB** (ports 139,445) - EternalBlue, weak shares
- **MySQL** (port 3306) - Weak root password
- **PostgreSQL** (port 5432) - Default credentials
- **RDP** (port 3389) - BlueKeep vulnerability

### Database Vulnerabilities
- **SQL Injection** - Multiple instances throughout
- **NoSQL Injection** - MongoDB instances
- **XXE** - XML External Entity attacks

## Step 10: Management Commands

### Docker Compose Setup Management:
```bash
# Start the lab
docker compose up -d

# Stop the lab
docker compose down

# Restart all containers
docker compose restart

# Restart specific container
docker compose restart victim
docker compose restart kali

# View logs
docker compose logs
docker compose logs victim
docker compose logs kali

# View status
docker compose ps

# Rebuild containers
docker compose up -d --build
```

### Single Container Management:
```bash
# Start container
docker start metasploitable3

# Stop container
docker stop metasploitable3

# Restart container
docker restart metasploitable3

# Access container shell
docker exec -it metasploitable3 /bin/bash

# View logs
docker logs metasploitable3

# Remove container
docker rm -f metasploitable3
```

### Access Container Shells:
```bash
# Access Kali attacker shell
docker exec -it kali_attacker bash

# Access victim container shell
docker exec -it victim bash

# Access victim as root
docker exec -u 0 -it victim bash
```

## Step 11: Cleanup and Security

### Docker Compose Cleanup:
```bash
# Stop and remove everything (containers, networks)
docker compose down

# Stop and remove with volumes
docker compose down -v

# Complete cleanup (containers, networks, volumes)
docker compose down -v --rmi all
```

### Single Container Cleanup:
```bash
# Stop and remove container
docker stop metasploitable3
docker rm metasploitable3

# Remove image
docker rmi kirscht/metasploitable3-ub1404

# Clean Docker system
docker system prune -f
```

### Complete Lab Reset:
```bash
# From your lab directory
docker compose down -v --rmi all
docker system prune -af
docker volume prune -f
docker network prune -f
```

## Troubleshooting

### Common Issues and Solutions (Based on Actual Experience)

#### 1. Victim Container Exits Immediately
**Problem:** The Metasploitable3 Ubuntu image doesn't have a default foreground process.
**Solution:** Use the custom entrypoint in `docker-compose.yml` that starts services and keeps container alive.

#### 2. Apache Fails to Start
**Problem:** Missing runtime directories `/var/lock/apache2`, `/var/run/apache2`.
**Solution:** The entrypoint creates these directories and sets correct permissions:
```bash
rm -rf /var/lock
mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2
chown -R www-data:www-data /var/lock/apache2 /var/run/apache2
service apache2 start
```

#### 3. Services Not Started Automatically
**Problem:** In containers, services don't auto-start like in VMs.
**Solution:** Explicitly start services in entrypoint:
```bash
service apache2 start
service mysql start
exec /usr/bin/tail -f /dev/null
```

#### 4. Kali Cannot Resolve Victim Hostname
**Problem:** DNS resolution fails between containers.
**Solution:** Use Docker's internal DNS or static IPs (172.23.0.2 for Kali, 172.23.0.3 for victim).

#### 5. Tools Missing in Kali Container
**Problem:** Minimal Kali image lacks tools.
**Solution:** Install needed tools:
```bash
apt update && apt install -y iputils-ping nmap curl net-tools
```

#### 6. Docker Permission Denied
```bash
sudo usermod -aG docker $USER
newgrp docker
# Log out and back in if needed
```

#### 7. Port Conflicts
```bash
# Check conflicting processes
sudo netstat -tulpn | grep :80
# Use different host ports or stop conflicting service
```

#### 8. Container Won't Start
```bash
# Check logs
docker compose logs victim
docker logs victim

# Check resources
docker system df

# Rebuild
docker compose up -d --build
```

#### 9. Metasploit Database Issues (in Kali)
```bash
service postgresql start
msfdb init
msfconsole
```

## Best Practices for Red Team Labs

### 1. Network Segmentation
- Use Docker's `--network` flag for isolation
- Consider using `docker-compose` for complex setups
- Never bridge to host network unless necessary

### 2. Resource Management
- Limit container resources: `--memory`, `--cpus`
- Use volumes for persistent data
- Regular cleanup of unused containers/images

### 3. Documentation
- Keep notes of vulnerabilities found
- Document attack vectors and mitigations
- Track progress with tools like Dradis or KeepNote

### 4. Legal Compliance
- Only test systems you own or have permission to test
- Use lab environments for training only
- Follow responsible disclosure if finding real vulnerabilities

## Additional Resources

### Official Documentation
- [Metasploitable3 GitHub](https://github.com/rapid7/metasploitable3)
- [Docker Documentation](https://docs.docker.com/)
- [Kali Linux Tools](https://www.kali.org/tools/)

### Learning Resources
- [Metasploit Unleashed](https://www.offensive-security.com/metasploit-unleashed/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [PentesterLab](https://pentesterlab.com/)

### Community
- [Reddit r/netsec](https://www.reddit.com/r/netsec/)
- [StackExchange Security](https://security.stackexchange.com/)
- [Discord Security Communities](https://discord.com/invite/security)

## Disclaimer

This setup is for **EDUCATIONAL PURPOSES ONLY**. Use only in isolated lab environments. The author assumes no responsibility for misuse of this information. Always obtain proper authorization before testing any system.

---

*Last updated: $(date +%Y-%m-%d)*  
*Maintained by: Your Red Team Lab*