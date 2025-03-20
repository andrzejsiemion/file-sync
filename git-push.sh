#!/bin/sh

cd /app/data || exit 1

# Ensure Git is initialized
if [ ! -d ".git" ]; then
  echo "No Git repository found. Cloning the repository..."
  git clone --branch "$GIT_BRANCH" "$GIT_REPO" /app/data || {
    echo "Failed to clone repository!"
    exit 1
  }
fi

# Move into the repo
cd /app/data || exit 1

# Ensure we are on the correct branch
git checkout "$GIT_BRANCH"

# Pull the latest changes before adding files
git pull origin "$GIT_BRANCH"

# Add all new changes
git add -A

# Check for changes before committing
if git diff-index --quiet HEAD --; then
  echo "No changes to commit."
else
  git commit -m "Automated sync of sensor data"
  git push origin "$GIT_BRANCH"
  echo "Successfully pushed data to remote repository."
fi
