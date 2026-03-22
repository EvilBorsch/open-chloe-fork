#!/usr/bin/env bash

# WARNING: This script permanently deletes OpenClaw, its configuration, and all stored data.
# It does not uninstall Tailscale or Docker (as they might be used by other applications).

set -euo pipefail

echo "====================================================="
echo "🔴 OpenClaw Complete Uninstaller"
echo "====================================================="
echo "This will stop the containers, delete all volumes,"
echo "remove systemd watchdogs, and delete all OpenClaw data."
echo ""
read -r -p "Are you absolutely sure you want to proceed? [y/N] " confirm
case "$confirm" in
  [yY][eE][sS]|[yY]) 
    echo "Proceeding with uninstallation..."
    ;;
  *)
    echo "Uninstallation cancelled."
    exit 0
    ;;
esac

# 1. Stop and remove Docker containers and volumes
echo "➡️ Stopping and removing Docker containers and volumes..."
if [ -d "$HOME/op-and-chloe" ]; then
    cd "$HOME/op-and-chloe" || true
    if [ -f "compose.yml" ]; then
        docker compose --env-file /etc/openclaw/stack.env down -v 2>/dev/null || docker compose down -v 2>/dev/null || true
    fi
fi

# Fallback: forcefully remove any leftover openclaw containers
docker rm -f op-and-chloe-openclaw-guard op-and-chloe-openclaw-gateway op-and-chloe-browser 2>/dev/null || true

# 2. Disable and remove systemd watchdog
echo "➡️ Removing systemd watchdog service..."
systemctl disable --now openclaw-cdp-watchdog.timer 2>/dev/null || true
rm -f /etc/systemd/system/openclaw-cdp-watchdog.service 2>/dev/null || true
rm -f /etc/systemd/system/openclaw-cdp-watchdog.timer 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true

# 3. Delete config and data folders
echo "➡️ Deleting OpenClaw configuration and data directories..."
rm -rf /etc/openclaw 2>/dev/null || true
rm -rf /var/lib/openclaw 2>/dev/null || true
rm -rf /opt/op-and-chloe 2>/dev/null || true

# 4. Remove the cloned repository
echo "➡️ Removing the cloned repository..."
rm -rf "$HOME/op-and-chloe" 2>/dev/null || true

echo "====================================================="
echo "✅ Uninstallation complete. OpenClaw has been removed."
echo "====================================================="

