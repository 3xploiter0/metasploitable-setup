#!/bin/bash
# One-line Metasploitable3 + Kali Docker Lab Setup
# Run: bash one-line-setup.sh

echo "🚀 Setting up Metasploitable3 + Kali Docker Lab..."
LAB_DIR="$HOME/metasploitable-lab"
mkdir -p "$LAB_DIR" && cd "$LAB_DIR"

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

echo "📦 Pulling images and starting containers..."
docker compose up -d

echo "⏳ Waiting for containers to start..."
sleep 10

echo "✅ Lab setup complete!"
echo ""
echo "🔗 Access Kali:    docker exec -it kali_attacker bash"
echo "🔗 Access victim:  docker exec -it victim bash"
echo ""
echo "📡 Lab Network:"
echo "   Kali:    172.23.0.2 (kali_attacker)"
echo "   Victim:  172.23.0.3 (victim)"
echo ""
echo "🛑 To stop lab: docker compose down"
echo "🔄 To restart:  docker compose restart"
echo ""
echo "🎯 Quick test from Kali:"
echo "   docker exec kali_attacker bash -c 'apt update && apt install -y iputils-ping curl && ping -c 2 victim && curl -I http://victim'"