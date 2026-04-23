# Metasploitable3 Docker Compose Quick Start

## One-Command Setup
```bash
# Make scripts executable and run
chmod +x setup-metasploitable3.sh cleanup-lab.sh
./setup-metasploitable3.sh
```

## Essential Commands

### Docker Compose Setup
```bash
# Start complete lab (Kali + Metasploitable3)
docker compose up -d

# Stop and remove everything
docker compose down

# Restart lab
docker compose restart

# View logs
docker compose logs
docker compose logs victim
docker compose logs kali

# Check status
docker compose ps
```

### Container Access
```bash
# Access Kali attacker
docker exec -it kali_attacker bash

# Access victim container
docker exec -it victim bash

# Access victim as root
docker exec -u 0 -it victim bash
```

### Network Information
```bash
# Get container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' metasploitable3-lab

# Test connectivity
ping -c 4 <container-ip>
```

### Common Scans
Replace `<ip>` with your container IP:

```bash
# Full port scan
nmap -sV -sC -O -p- <ip>

# Quick web scan
nikto -h http://<ip>

# Directory brute force
dirb http://<ip> /usr/share/wordlists/dirb/common.txt

# WordPress scan (if WordPress installed)
wpscan --url http://<ip>/wordpress --enumerate vp,vt,tt,u
```

## Default Credentials (Metasploitable3 Ubuntu)

### SSH/Telnet
- **Username:** `msfadmin`
- **Password:** `msfadmin`

### MySQL
- **Username:** `root`
- **Password:** (blank)

### Web Applications
- **DVWA:** admin/password
- **WordPress:** admin/password (if installed)
- **Mutillidae:** admin/password

### FTP
- **Anonymous login enabled**
- **Username:** `anonymous`
- **Password:** (any email)

### SMB Shares
- **Guest access enabled**
- **Weak passwords on user shares**

## Quick Testing Checklist (from Kali container)

1. **Basic Connectivity**
   ```bash
   # From Kali: docker exec -it kali_attacker bash
   ping victim
   nmap -sV victim
   curl -I http://victim
   ```

2. **Service Enumeration**
   ```bash
   # Full port scan
   nmap -p- -sV victim
   
   # Web enumeration
   gobuster dir -u http://victim -w /usr/share/wordlists/dirb/common.txt
   nikto -h http://victim
   
   # FTP test
   ftp victim
   # Login: anonymous
   
   # SSH brute force
   hydra -l msfadmin -P /usr/share/wordlists/rockyou.txt ssh://victim
   ```

3. **Vulnerability Assessment**
   ```bash
   # Metasploit
   msfconsole
   > search type:exploit name:metasploitable
   > use <exploit>
   > set RHOSTS victim
   > run
   
   # SQL injection test
   sqlmap -u "http://victim/vulnerable-page?id=1" --batch
   ```

## Common Issues & Fixes

### Victim container exits immediately
**Problem:** Missing foreground process.
**Fix:** Use the provided `docker-compose.yml` with custom entrypoint.

### Apache/MySQL not starting in victim
```bash
# Check logs
docker compose logs victim

# Manually start services
docker exec -u 0 victim service apache2 start
docker exec -u 0 victim service mysql start
```

### Kali can't resolve 'victim' hostname
```bash
# Use IP instead
ping 172.23.0.3

# Or restart lab
docker compose restart
```

### Tools missing in Kali
```bash
# Install basics
apt update && apt install -y iputils-ping nmap curl net-tools

# Install pentesting tools
apt install -y metasploit-framework hydra john sqlmap gobuster nikto
```

### Docker permission denied
```bash
sudo usermod -aG docker $USER
newgrp docker
# Log out and back in if needed
```

### Metasploit database issues (in Kali)
```bash
service postgresql start
msfdb init
msfconsole
```

## Safety First!
- ✅ Isolate lab network
- ✅ Use dedicated machine
- ✅ No production data
- ✅ Clean up after use
- ✅ Document findings

## Need Help?
- Check `README.md` for detailed instructions
- Run `bash cleanup-lab.sh` to start fresh
- Review Docker logs: `docker logs metasploitable3-lab`