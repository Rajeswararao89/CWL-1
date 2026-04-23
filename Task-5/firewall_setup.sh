#!/bin/bash
# firewall_setup.sh - configures UFW for the devops assignment
#
# rules:
#   - SSH only from the trusted host IP (set TRUSTED_SSH_IP below)
#   - HTTP (80) open to anywhere
#   - port 8000 open for the docker app
#   - everything else denied by default
#
# find your trusted IP with: ip route | grep default
# in a Vagrant NAT setup it's usually 10.0.2.2

if [ "$(id -u)" -ne 0 ]; then
    echo "needs to run as root: sudo bash firewall_setup.sh"
    exit 1
fi

TRUSTED_SSH_IP="10.0.2.2"

echo "configuring UFW..."
echo "trusted SSH IP: $TRUSTED_SSH_IP"
echo ""

# install ufw if it's not there already
apt install -y ufw > /dev/null

# start clean - reset any existing rules
ufw --force reset

# deny all incoming by default, allow all outgoing
# this means only the ports we explicitly open below will be reachable
ufw default deny incoming
ufw default allow outgoing

# SSH only from our trusted IP - this blocks everyone else from port 22
ufw allow from "$TRUSTED_SSH_IP" to any port 22 proto tcp
echo "SSH allowed from $TRUSTED_SSH_IP only"

# HTTP - open to anywhere
ufw allow 80/tcp
echo "HTTP (80) open"

# docker app port
ufw allow 8000/tcp
echo "port 8000 open"

# turn it on
ufw --force enable

echo ""
echo "final rules:"
ufw status verbose
