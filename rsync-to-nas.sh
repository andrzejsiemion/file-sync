#!/bin/sh

# Define source and destination
SOURCE_DIR="/app/data/"  # Sync Git repo folder
NAS_USER="nasuser"       # Synology NAS username
NAS_IP="192.168.1.100"   # Synology NAS IP
NAS_PATH="/volume1/backup/data"  # NAS target directory

# Use SSH key authentication to connect to NAS
rsync -avzP --ignore-existing --no-perms -e "ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no" "$SOURCE_DIR" "$NAS_USER@$NAS_IP:$NAS_PATH"

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "✅ Rsync to NAS completed successfully!"
else
    echo "❌ Rsync failed. Check logs."
    exit 1
fi