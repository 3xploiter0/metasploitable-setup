#!/bin/bash
# Test script to verify setup files work correctly

echo "🔍 Testing Metasploitable3 Setup Files"
echo "======================================"
echo ""

# Check if scripts are executable
echo "1. Checking script permissions:"
for script in setup-metasploitable3.sh cleanup-lab.sh one-line-setup.sh; do
    if [ -x "$script" ]; then
        echo "   ✅ $script is executable"
    else
        echo "   ❌ $script is NOT executable"
    fi
done
echo ""

# Check for shebang lines
echo "2. Checking shebang lines:"
for script in setup-metasploitable3.sh cleanup-lab.sh one-line-setup.sh; do
    if head -1 "$script" | grep -q "^#!/bin/bash"; then
        echo "   ✅ $script has correct shebang"
    else
        echo "   ❌ $script missing shebang"
    fi
done
echo ""

# Check for syntax errors
echo "3. Checking bash syntax:"
for script in setup-metasploitable3.sh cleanup-lab.sh one-line-setup.sh; do
    if bash -n "$script" 2>/dev/null; then
        echo "   ✅ $script has valid bash syntax"
    else
        echo "   ❌ $script has syntax errors"
        bash -n "$script"
    fi
done
echo ""

# Check documentation files
echo "4. Checking documentation files:"
for doc in README.md QUICK-START.md; do
    if [ -f "$doc" ]; then
        lines=$(wc -l < "$doc")
        echo "   ✅ $doc exists ($lines lines)"
    else
        echo "   ❌ $doc missing"
    fi
done
echo ""

# Check for redundant files
echo "5. Checking for redundant files:"
if [ -f "docker-compose.yml" ]; then
    echo "   ⚠️  docker-compose.yml exists (redundant - scripts create it)"
else
    echo "   ✅ No redundant docker-compose.yml"
fi
echo ""

# Check directory consistency
echo "6. Checking directory consistency:"
setup_dir1=$(grep "LAB_DIR=" setup-metasploitable3.sh | cut -d'"' -f2)
setup_dir2=$(grep "LAB_DIR=" one-line-setup.sh | cut -d'"' -f2)

echo "   setup-metasploitable3.sh uses: $setup_dir1"
echo "   one-line-setup.sh uses: $setup_dir2"
if [ "$setup_dir1" = "$setup_dir2" ]; then
    echo "   ✅ Directory paths are consistent"
else
    echo "   ❌ Directory paths are inconsistent"
fi
echo ""

echo "📋 Summary:"
echo "All setup files should create lab in: ~/metasploitable-lab"
echo ""
echo "🚀 To use:"
echo "   Quick setup:    bash one-line-setup.sh"
echo "   Full setup:     bash setup-metasploitable3.sh"
echo "   Cleanup:        bash cleanup-lab.sh"
echo "   Documentation:  cat README.md | less"
echo ""