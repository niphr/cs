#!/bin/bash

# CS9 task runner for Airflow Docker containers
# Usage: install_ss_and_run_task.sh <repo_url> <branch> <task>

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <repo_url> <branch> <task>"
  echo "Example: $0 https://github.com/raubreywhite/xxx.git feature/testing clean_data"
  exit 1
fi

REPO_URL=$1
BRANCH=$2  
TASK=$3

echo "=== CS9 TASK RUNNER ==="
echo "Repository: $REPO_URL"
echo "Branch: $BRANCH"
echo "Task: $TASK"
echo "================================="

# Clone repository to /tmp
echo "Cloning repository..."
REPOSITORY=$(basename "$REPO_URL" .git)
git -C /tmp clone -b "$BRANCH" "$REPO_URL"

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to clone repository from $REPO_URL (branch: $BRANCH)"
  exit 1
fi

# Navigate to cloned directory and build R package
echo "Building R package..."
cd "/tmp/${REPOSITORY}"
R CMD build .

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to build R package"
  exit 1
fi

# Find and install the built package
TARBALL=$(ls -t *.tar.gz | head -n 1)
if [ -z "$TARBALL" ]; then
  echo "ERROR: No tarball found after building package"
  exit 1
fi

echo "Installing R package: $TARBALL"
Rscript -e "install.packages('${TARBALL}', repos = NULL, type = 'source')"

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to install R package"
  exit 1
fi

# Run the specified task
echo "Running task: $TASK"
Rscript -e "${REPOSITORY}::global\$ss\$run_task('${TASK}')"

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to run task $TASK"
  exit 1
fi

echo "✅ Task $TASK completed successfully"