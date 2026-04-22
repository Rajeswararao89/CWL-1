#!/bin/bash
# setup_monitor_user.sh - creates the monitor system user and locks down
# the /opt/container-monitor directory so only that user can access it
#
# usage: sudo bash setup_monitor_user.sh

if [ "$(id -u)" -ne 0 ]; then
    echo "needs to run as root: sudo bash setup_monitor_user.sh"
    exit 1
fi

MONITOR_USER="monitor"
MONITOR_DIR="/opt/container-monitor"

echo "setting up $MONITOR_USER user and $MONITOR_DIR..."

# create a system user - no home dir, no login shell
# system accounts get a uid below 1000 and can't be logged into interactively
if id "$MONITOR_USER" &>/dev/null; then
    echo "  user '$MONITOR_USER' already exists, skipping"
else
    useradd \
        --system \
        --no-create-home \
        --shell /sbin/nologin \
        --comment "monitoring service account" \
        "$MONITOR_USER"
    echo "  created user '$MONITOR_USER'"
fi

# create the directory structure
mkdir -p "$MONITOR_DIR/logs"
echo "  created $MONITOR_DIR/logs"

# give the monitor user full ownership
chown -R "$MONITOR_USER":"$MONITOR_USER" "$MONITOR_DIR"
echo "  ownership set to $MONITOR_USER:$MONITOR_USER"

# 700 = owner gets rwx, everyone else gets nothing
chmod 700 "$MONITOR_DIR"
chmod 700 "$MONITOR_DIR/logs"
echo "  permissions set to 700"

# copy monitor.sh if it's in the same directory
if [ -f "monitor.sh" ]; then
    cp monitor.sh "$MONITOR_DIR/monitor.sh"
    chown "$MONITOR_USER":"$MONITOR_USER" "$MONITOR_DIR/monitor.sh"
    chmod 700 "$MONITOR_DIR/monitor.sh"
    echo "  monitor.sh installed"
else
    echo "  monitor.sh not found here - copy it manually from Task-3/"
fi

# monitor needs docker group access to run docker stats
usermod -aG docker "$MONITOR_USER"
echo "  added $MONITOR_USER to docker group"

echo ""
echo "done. verifying..."
echo ""

ls -ld "$MONITOR_DIR"
ls -la "$MONITOR_DIR"
echo ""
id "$MONITOR_USER"
