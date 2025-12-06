#!/bin/bash

# Format script for Sequelize Dart project
# Formats both Dart and JavaScript files

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

echo -e "${BLUE}🔧 Formatting code...${NC}\n"

# Check if prettier is available (via npm/node_modules or globally)
PRETTIER_CMD=""
if [ -f "node_modules/.bin/prettier" ]; then
  PRETTIER_CMD="node_modules/.bin/prettier"
elif command -v npx &> /dev/null; then
  PRETTIER_CMD="npx prettier"
elif command -v prettier &> /dev/null; then
  PRETTIER_CMD="prettier"
fi

if [ -n "$PRETTIER_CMD" ]; then
  echo -e "${YELLOW}Formatting JavaScript/JSON files with Prettier...${NC}"
  $PRETTIER_CMD --write "**/*.{js,json,md}" \
    --ignore-path .prettierignore \
    || echo -e "${RED}⚠️  Prettier formatting had issues${NC}"
else
  echo -e "${YELLOW}⚠️  Prettier not found. Install with: npm install${NC}"
fi

echo -e "\n${YELLOW}Formatting Dart files...${NC}"
dart format . || {
  echo -e "${RED}❌ Dart formatting failed${NC}"
  exit 1
}

echo -e "\n${GREEN}✅ Formatting complete!${NC}"

