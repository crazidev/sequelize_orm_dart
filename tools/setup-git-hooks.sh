#!/bin/bash

# Setup script to install git hooks
# This copies hooks from the hooks/ directory to .git/hooks/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to root directory
cd "$ROOT_DIR"

echo -e "${BLUE}🔧 Setting up git hooks...${NC}\n"

# Check if .git directory exists
if [ ! -d ".git" ]; then
  echo -e "${RED}❌ Error: .git directory not found. Are you in a git repository?${NC}"
  exit 1
fi

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy hooks from hooks/ directory
if [ -d "hooks" ]; then
  for hook in hooks/*; do
    if [ -f "$hook" ] && [ -x "$hook" ]; then
      hook_name=$(basename "$hook")
      cp "$hook" ".git/hooks/$hook_name"
      chmod +x ".git/hooks/$hook_name"
      echo -e "${GREEN}✅ Installed hook: $hook_name${NC}"
    fi
  done
else
  echo -e "${RED}❌ Error: hooks/ directory not found${NC}"
  exit 1
fi

echo -e "\n${GREEN}✅ Git hooks setup complete!${NC}"
echo -e "${YELLOW}Hooks will now run automatically on commit/push${NC}"

