#!/bin/bash

# Metasploitable3 Lab Cleanup Script
# Run with: bash cleanup-lab.sh

set -e  # Exit on error

echo "========================================="
echo "Metasploitable3 Lab Cleanup"
echo "========================================="
echo ""

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
        echo "⚠️  $1 (may not have existed)"
    fi
}

print_header "1. Stopping Docker Compose Lab"
echo "Stopping and removing all lab containers and networks..."
echo ""

# Check if docker-compose.yml exists
if [ -f "docker-compose.yml" ]; then
    echo "Found docker-compose.yml, stopping lab..."
    docker compose down
    check_success "Docker Compose lab stopped"
else
    echo "⚠️  docker-compose.yml not found, checking for individual containers..."
    
    # Check for victim container
    if docker ps -a --format '{{.Names}}' | grep -q "^victim$"; then
        echo "Stopping victim container..."
        docker stop victim 2>/dev/null || true
        docker rm victim 2>/dev/null || true
        check_success "Victim container removed"
    fi
    
    # Check for kali container
    if docker ps -a --format '{{.Names}}' | grep -q "^kali_attacker$"; then
        echo "Stopping kali_attacker container..."
        docker stop kali_attacker 2>/dev/null || true
        docker rm kali_attacker 2>/dev/null || true
        check_success "Kali container removed"
    fi
    
    # Check for lab_net network
    if docker network ls --format '{{.Name}}' | grep -q "^lab_net$"; then
        echo "Removing lab_net network..."
        docker network rm lab_net 2>/dev/null || true
        check_success "Network removed"
    fi
fi

print_header "3. Optional: Removing Docker Image"
read -p "Remove Metasploitable3 Docker image? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if docker images --format '{{.Repository}}' | grep -q "^metasploitable3$"; then
        echo "Removing image: metasploitable3"
        docker rmi metasploitable3
        check_success "Image removed"
    else
        echo "⚠️  Image 'metasploitable3' not found"
    fi
fi

print_header "4. Cleaning Docker System"
echo "Removing unused Docker resources..."
docker system prune -f
check_success "Docker system cleaned"

print_header "5. Verifying Cleanup"
echo "Checking remaining containers..."
docker ps -a | grep -v "CONTAINER ID" | wc -l | xargs echo "Containers remaining:"

echo "Checking remaining networks..."
docker network ls | grep -v "NETWORK ID" | wc -l | xargs echo "Networks remaining:"

echo "Checking images..."
docker images | grep -v "REPOSITORY" | wc -l | xargs echo "Images remaining:"

print_header "6. Security Check"
echo "⚠️  IMPORTANT: Verify no sensitive data remains:"
echo "   1. Check ~/metasploitable-lab directory for any leftover files"
echo "   2. Clear browser cache and history related to the lab"
echo "   3. Remove any saved credentials or session data"
echo "   4. Consider wiping free space if handling sensitive data"

echo ""
echo "========================================="
echo "✅ Cleanup Complete!"
echo "========================================="
echo ""
echo "All Metasploitable3 lab resources have been removed."
echo ""
echo "To recreate the lab, run: bash setup-metasploitable3.sh"
echo ""