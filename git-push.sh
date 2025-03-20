#!/bin/sh

cd /app/data || exit 1

# Ensure Git is initialized
if [ ! -d ".git" ]; then
  echo "No Git repository found! Cloning again..."
  git clone --branch "$GIT_BRANCH" "$GIT_REPO" /app/data || {
    echo "Failed to clone repository!"
    exit 1
  }
fi

# Move into the repo
cd /app/data || exit 1

# Ensure we are on the correct branch
git checkout "$GIT_BRANCH"

# Stash any local modifications (prevents conflicts)
git stash

# Pull the latest changes before adding new files
git pull --rebase origin "$GIT_BRANCH" || {
  echo "Failed to pull latest changes!"
  exit 1
}

# Apply stashed changes (if any)
git stash pop || echo "No stashed changes to apply."

# Add only new/modified files (do not remove remote ones)
git add -A

# Check for changes before committing
if git diff-index --quiet HEAD --; then
  echo "No changes to commit."
else
  git commit -m "Automated sync of sensor data"
  git push origin "$GIT_BRANCH"
  echo "Successfully pushed data to remote repository."
fi