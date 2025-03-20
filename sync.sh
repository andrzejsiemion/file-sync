#!/bin/sh

# Allow /data as a safe Git directory
git config --global --add safe.directory /app/data

# Ensure SSH directory exists
mkdir -p ~/.ssh

# Check if the SSH key exists
if [ ! -f "/root/.ssh/id_rsa" ]; then
  echo "ERROR: SSH key not found at /root/.ssh/id_rsa. Exiting..."
  exit 1
fi

chmod 600 ~/.ssh/id_rsa
echo "SSH key found and permissions set."

# Ensure GitHub is a known host
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Configure Git
cd /app/data || exit 1
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_NAME"
git config --global --add safe.directory /app/data
git config --global pull.rebase false
git config --global pull.ff only

# Clone repository only if missing
if [ ! -d "/app/data/.git" ]; then
  echo "No Git repository found. Cloning..."
  git clone --branch "$GIT_BRANCH" "$GIT_REPO" /app/data || {
    echo "Failed to clone repository!"
    exit 1
  }
else
  echo "Git repository detected, pulling latest changes..."
  git -C /app/data reset --hard  # Ensure local repo is not corrupted
  git -C /app/data clean -fd      # Remove untracked files but keep remote ones
  git -C /app/data pull --rebase origin "$GIT_BRANCH" || {
    echo "Git pull failed. Exiting..."
    exit 1
  }
fi

# Set up cron job to sync every X minutes
echo "$CRON_SCHEDULE /app/git-push.sh" > /var/spool/cron/crontabs/root
chmod 600 /var/spool/cron/crontabs/root

echo "Git sync service started. Schedule: $CRON_SCHEDULE"

# Start cron in the foreground
exec busybox crond -f -l 2