#!/usr/bin/env bash

# This script changes your OpenClaw setup to allow direct IP access
# and prints out your secure tokens and clickable login links.

set -euo pipefail

ENV_FILE="/etc/openclaw/stack.env"
STACK_DIR="$HOME/op-and-chloe"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE not found. Please run sudo ./setup.sh first."
    exit 1
fi

echo "➡️ Changing bind addresses to 0.0.0.0 for direct public access..."
sudo sed -i "s/^GATEWAY_HOST=.*/GATEWAY_HOST=0.0.0.0/" "$ENV_FILE"
sudo sed -i "s/^GUARD_GATEWAY_HOST=.*/GUARD_GATEWAY_HOST=0.0.0.0/" "$ENV_FILE"
sudo sed -i "s/^NOVNC_HOST=.*/NOVNC_HOST=0.0.0.0/" "$ENV_FILE"

echo "➡️ Restarting OpenClaw to apply changes..."
cd "$STACK_DIR" || exit 1
sudo ./start.sh > /dev/null 2>&1

# Get tokens
WORKER_TOKEN=$(grep -E "^OPENCLAW_GATEWAY_TOKEN=" "$ENV_FILE" | cut -d= -f2- | tr -d '"')
GUARD_TOKEN=$(grep -E "^OPENCLAW_GUARD_GATEWAY_TOKEN=" "$ENV_FILE" | cut -d= -f2- | tr -d '"')

# Try to get public IP
PUBLIC_IP=$(curl -s ifconfig.me || echo "YOUR_SERVER_IP")

echo "====================================================="
echo "✅ Setup Complete! Your panels are now live."
echo "====================================================="
echo "⚠️  WARNING: Your panels are exposed to the internet."
echo "Do not share these links with anyone."
echo ""
echo "🐯 Chloe (Daily Assistant):"
echo "http://$PUBLIC_IP:18789/#token=$WORKER_TOKEN"
echo ""
echo "🐕 Op (Admin Assistant):"
echo "http://$PUBLIC_IP:18790/#token=$GUARD_TOKEN"
echo ""
echo "🖥️  Webtop Browser:"
echo "http://$PUBLIC_IP:6080"
echo "====================================================="
