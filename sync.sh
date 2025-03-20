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

# Check if .git is missing but files exist
if [ ! -d "/app/data/.git" ]; then
  if [ -n "$(ls -A /app/data 2>/dev/null)" ]; then
    echo "WARNING: Files exist in /app/data but .git is missing!"
    
    # Clone repo into a temporary location
    git clone --branch "$GIT_BRANCH" "$GIT_REPO" /tmp/repo || {
      echo "Failed to clone repository!"
      exit 1
    }
    
    # Merge existing files into the cloned repo
    cp -r /app/data/* /tmp/repo/ 2>/dev/null || true
    
    # Move the .git directory into /app/data/
    mv /tmp/repo/.git /app/data/
    
    # Clean up temp repo
    rm -rf /tmp/repo

    echo "Merged existing files with the repository."
  else
    # No files exist, safe to clone directly
    git clone --branch "$GIT_BRANCH" "$GIT_REPO" /app/data || {
      echo "Failed to clone repository!"
      exit 1
    }
  fi
fi

# Ensure repository is clean and up-to-date
cd /app/data || exit 1
git fetch origin
git reset --hard origin/"$GIT_BRANCH"
git pull origin "$GIT_BRANCH"

# Set up cron job to sync every X minutes
echo "$CRON_SCHEDULE /app/git-push.sh && /app/rsync-to-nas.sh" > /var/spool/cron/crontabs/root
chmod 600 /var/spool/cron/crontabs/root

echo "Git sync + Rsync service started. Schedule: $CRON_SCHEDULE"

# Start cron in the foreground
exec busybox crond -f -l 2