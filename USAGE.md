# Metasploitable3 Lab - File Usage Guide

## 📁 Files Overview

### Core Setup Files:
1. **`setup-metasploitable3.sh`** - Comprehensive setup script
   - Checks prerequisites
   - Creates lab directory
   - Sets up Docker Compose
   - Verifies installation
   - **Usage:** `bash setup-metasploitable3.sh`

2. **`one-line-setup.sh`** - Ultra-fast setup
   - Minimal prompts
   - Quick installation
   - Basic verification
   - **Usage:** `bash one-line-setup.sh`

3. **`cleanup-lab.sh`** - Complete cleanup
   - Stops and removes containers
   - Cleans Docker resources
   - Security checks
   - **Usage:** `bash cleanup-lab.sh`

### Documentation:
4. **`README.md`** - Complete documentation
   - Detailed setup instructions
   - Troubleshooting guide
   - Security considerations
   - Management commands

5. **`QUICK-START.md`** - Quick reference
   - Essential commands
   - Default credentials
   - Testing checklist
   - Common issues

### Utility:
6. **`test-setup.sh`** - Verification script
   - Tests script functionality
   - Checks consistency
   - **Usage:** `bash test-setup.sh`

## 🔄 How Files Work Together

### Setup Flow:
```
User runs → setup-metasploitable3.sh or one-line-setup.sh
                ↓
        Creates ~/metasploitable-lab/
                ↓
        Creates docker-compose.yml
                ↓
        Starts Docker containers
                ↓
        Verifies installation
```

### Cleanup Flow:
```
User runs → cleanup-lab.sh
                ↓
        Stops containers
                ↓
        Removes resources
                ↓
        Security check
```

## 🎯 Which File to Use When

### For First-Time Setup:
```bash
# Recommended: Comprehensive setup
bash setup-metasploitable3.sh

# Alternative: Quick setup
bash one-line-setup.sh
```

### For Testing/Verification:
```bash
# Check if setup will work
bash test-setup.sh

# Quick reference
cat QUICK-START.md
```

### For Daily Use:
```bash
# Start lab (after initial setup)
cd ~/metasploitable-lab
docker compose up -d

# Access Kali
docker exec -it kali_attacker bash

# Stop lab
docker compose down
```

### For Complete Removal:
```bash
# From lab directory
cd ~/metasploitable-lab
docker compose down -v --rmi all

# Or use cleanup script
bash cleanup-lab.sh
```

## 📍 File Locations After Setup

After running any setup script:
- **Lab directory:** `~/metasploitable-lab/`
- **Docker Compose file:** `~/metasploitable-lab/docker-compose.yml`
- **Containers:** `victim` and `kali_attacker`
- **Network:** `lab_net` (172.23.0.0/24)

## 🔧 Maintenance

### Update Documentation:
- Edit `README.md` for detailed changes
- Edit `QUICK-START.md` for quick reference updates

### Update Scripts:
- All scripts are independent
- Changes to one don't affect others
- Test with `bash test-setup.sh`

### Backup Lab:
```bash
cd ~/metasploitable-lab
tar -czf metasploitable-lab-backup.tar.gz .
```

## ✅ Verification

Run the test script to ensure everything works:
```bash
bash test-setup.sh
```

Expected output: All checks should pass with ✅