# Red Team Analyst Challenges - Metasploitable3

## 🎯 Overview
This document contains practical challenges for Certified Red Team Analyst training using Metasploitable3. Each challenge simulates real-world attack scenarios with increasing difficulty.

## 📊 Challenge Levels
- **🔵 Beginner** - Basic reconnaissance and enumeration
- **🟡 Intermediate** - Service exploitation and privilege escalation  
- **🔴 Advanced** - Lateral movement and persistence
- **⚫ Expert** - Advanced evasion and cleanup

---

## 🔵 BEGINNER CHALLENGES

### Challenge 1: Network Reconnaissance
**Objective:** Perform comprehensive network discovery
**Target:** Victim container (172.23.0.3)
**Tools:** `nmap`, `netdiscover`, `arp-scan`

**Tasks:**
1. Identify all live hosts on the lab network
2. Perform TCP SYN scan on all ports
3. Identify OS and service versions
4. Create a network map of discovered services

**Learning Points:**
- Passive vs active reconnaissance
- Stealth scanning techniques
- Service fingerprinting
- Documentation and reporting

### Challenge 2: Web Application Enumeration
**Objective:** Discover web attack surface
**Target:** HTTP services on victim container
**Tools:** `gobuster`, `dirb`, `nikto`, `whatweb`

**Tasks:**
1. Enumerate web directories and files
2. Identify web technologies and versions
3. Find hidden parameters and endpoints
4. Map the web application architecture

**Learning Points:**
- Directory brute forcing
- Web technology identification
- Information leakage assessment
- Attack surface mapping

### Challenge 3: Service Banner Grabbing
**Objective:** Gather intelligence from service banners
**Target:** All open ports on victim
**Tools:** `netcat`, `telnet`, `nmap`

**Tasks:**
1. Manually connect to each open port
2. Extract version information from banners
3. Identify vulnerable service versions
4. Document potential attack vectors

**Learning Points:**
- Manual service interrogation
- Banner analysis for vulnerabilities
- Protocol understanding
- Intelligence gathering

---

## 🟡 INTERMEDIATE CHALLENGES

### Challenge 4: FTP Exploitation
**Objective:** Gain unauthorized FTP access
**Target:** FTP service (port 21)
**Tools:** `ftp`, `hydra`, `metasploit`

**Tasks:**
1. Test anonymous FTP access
2. Brute force FTP credentials
3. Upload a web shell via FTP
4. Establish command execution

**Learning Points:**
- FTP protocol weaknesses
- Credential brute forcing
- File upload vulnerabilities
- Initial access techniques

### Challenge 5: SSH Brute Force Attack
**Objective:** Compromise SSH service
**Target:** SSH service (port 22)
**Tools:** `hydra`, `medusa`, `patator`

**Tasks:**
1. Identify valid usernames
2. Perform dictionary attack
3. Use password spraying techniques
4. Establish SSH session

**Learning Points:**
- SSH authentication attacks
- Password policy testing
- Session establishment
- Key-based attack vectors

### Challenge 6: MySQL Database Compromise
**Objective:** Exploit database vulnerabilities
**Target:** MySQL service (port 3306)
**Tools:** `mysql`, `sqlmap`, `metasploit`

**Tasks:**
1. Connect with default credentials
2. Enumerate databases and tables
3. Extract sensitive data
4. Execute system commands via database

**Learning Points:**
- Database reconnaissance
- SQL injection exploitation
- Data exfiltration
- Database to system escalation

### Challenge 7: SMB Share Enumeration
**Objective:** Access network shares
**Target:** SMB services (ports 139, 445)
**Tools:** `smbclient`, `enum4linux`, `crackmapexec`

**Tasks:**
1. Enumerate SMB shares
2. Access anonymous shares
3. Brute force share credentials
4. Download sensitive files

**Learning Points:**
- SMB protocol enumeration
- Share permission analysis
- Credential attacks on SMB
- Data harvesting techniques

---

## 🔴 ADVANCED CHALLENGES

### Challenge 8: Web Application Exploitation
**Objective:** Exploit web vulnerabilities
**Target:** DVWA/Mutillidae applications
**Tools:** `sqlmap`, `burpsuite`, `commix`

**Tasks:**
1. SQL injection to extract data
2. Cross-site scripting (XSS) attack
3. File upload vulnerability exploitation
4. Command injection attack

**Learning Points:**
- OWASP Top 10 exploitation
- Web app testing methodology
- Manual vs automated exploitation
- Payload crafting

### Challenge 9: Privilege Escalation
**Objective:** Gain root/system privileges
**Target:** Compromised user account
**Tools:** `linpeas`, `linux-exploit-suggester`, `metasploit`

**Tasks:**
1. Enumerate system information
2. Identify misconfigurations
3. Exploit kernel vulnerabilities
4. Establish persistent root access

**Learning Points:**
- Linux privilege escalation vectors
- Misconfiguration identification
- Kernel exploit research
- Persistence mechanisms

### Challenge 10: Lateral Movement
**Objective:** Move within the network
**Target:** Multiple system compromise
**Tools:** `psexec`, `wmiexec`, `evil-winrm`

**Tasks:**
1. Credential harvesting
2. Pass-the-hash attack
3. Token impersonation
4. Establish foothold on additional systems

**Learning Points:**
- Credential reuse attacks
- Windows authentication bypass
- Network segmentation testing
- Trust relationship exploitation

---

## ⚫ EXPERT CHALLENGES

### Challenge 11: Advanced Persistence
**Objective:** Maintain long-term access
**Target:** Compromised system
**Tools:** Custom scripts, `metasploit`, `cobalt strike`

**Tasks:**
1. Create multiple backdoors
2. Establish covert channels
3. Implement rootkits
4. Defeat common detection methods

**Learning Points:**
- Advanced persistence techniques
- Anti-forensics methods
- Covert communication channels
- Detection evasion

### Challenge 12: Data Exfiltration
**Objective:** Steal data without detection
**Target:** Sensitive files and databases
**Tools:** `dnscat2`, `iodine`, custom exfiltration tools

**Tasks:**
1. Identify valuable data
2. Establish covert exfiltration channel
3. Encrypt and compress data
4. Exfiltrate without triggering alerts

**Learning Points:**
- Data classification and targeting
- Covert exfiltration methods
- Encryption for evasion
- Log manipulation

### Challenge 13: Cleanup and Anti-Forensics
**Objective:** Remove evidence of compromise
**Target:** All compromised systems
**Tools:** `logcleaner`, `timestomp`, custom scripts

**Tasks:**
1. Remove logs and artifacts
2. Cover tracks in file system
3. Remove persistence mechanisms
4. Leave false trails

**Learning Points:**
- Digital forensics countermeasures
- Log manipulation and deletion
- Artifact removal techniques
- Misdirection tactics

---

## 🎓 LEARNING PATH

### Phase 1: Foundation (Beginner)
1. Complete Challenges 1-3
2. Document all findings
3. Create reconnaissance report

### Phase 2: Exploitation (Intermediate)
1. Complete Challenges 4-7  
2. Practice each exploitation method
3. Document attack chains

### Phase 3: Post-Exploitation (Advanced)
1. Complete Challenges 8-10
2. Chain multiple exploits
3. Create comprehensive attack report

### Phase 4: Advanced Operations (Expert)
1. Complete Challenges 11-13
2. Focus on stealth and evasion
3. Create professional engagement report

---

## 🛠️ TOOL REFERENCE

### Reconnaissance:
- `nmap` - Network scanning
- `gobuster`/`dirb` - Web enumeration
- `nikto` - Web vulnerability scanner
- `enum4linux` - SMB enumeration

### Exploitation:
- `metasploit` - Exploitation framework
- `sqlmap` - SQL injection
- `hydra` - Password brute force
- `smbclient` - SMB exploitation

### Post-Exploitation:
- `linpeas` - Linux privilege escalation
- `mimikatz` - Credential dumping
- `bloodhound` - Active Directory mapping
- `cobalt strike` - Advanced red teaming

### Reporting:
- `dradis` - Collaborative reporting
- `serpico` - Report generation
- `magic tree` - Data organization

---

## 📝 REPORTING TEMPLATE

### Executive Summary
- Brief overview of engagement
- Key findings and risk level
- Recommendations summary

### Technical Findings
- Vulnerability details
- Exploitation steps
- Impact assessment
- Proof of concept

### Attack Narrative
- Timeline of attack
- Techniques used
- Tools employed
- Detection avoidance

### Recommendations
- Immediate fixes
- Long-term improvements
- Security controls
- Monitoring suggestions

---

## 🔐 ETHICAL CONSIDERATIONS

1. **Authorization** - Only test systems you own or have permission to test
2. **Scope** - Stay within defined boundaries
3. **Documentation** - Keep detailed notes of all activities
4. **Responsible Disclosure** - Report findings appropriately
5. **Cleanup** - Remove all testing artifacts when done

---

## 🎯 CERTIFICATION ALIGNMENT

These challenges align with:
- **CRTE** (Certified Red Team Expert)
- **OSCP** (Offensive Security Certified Professional)
- **GPEN** (GIAC Penetration Tester)
- **CPTE** (Certified Penetration Testing Engineer)

---

## 📚 ADDITIONAL RESOURCES

### Practice Platforms:
- Hack The Box
- TryHackMe
- VulnHub
- PentesterLab

### Study Materials:
- The Cyber Mentor YouTube
- IppSec YouTube channel
- 0xdf's blog
- HackTricks

### Books:
- "The Hacker Playbook" series
- "Red Team Field Manual"
- "Advanced Penetration Testing"
- "The Web Application Hacker's Handbook"

---