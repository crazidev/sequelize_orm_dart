#!/bin/bash

# Setup script for Sequelize Dart bridge server
# Installs dependencies and builds the unified bridge bundle

# Exit on error
set -e

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to root directory
cd "$ROOT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BRIDGE_DIR="$ROOT_DIR/packages/sequelize_orm/js"

# Default values
PACKAGE_MANAGER="bun"
SKIP_INSTALL=false
SKIP_CLEANUP=false
ONLY_CLEANUP=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-install)
      SKIP_INSTALL=true
      shift
      ;;
    --skip-cleanup)
      SKIP_CLEANUP=true
      shift
      ;;
    --only-cleanup)
      ONLY_CLEANUP=true
      shift
      ;;
    bun|pnpm|npm)
      PACKAGE_MANAGER="$1"
      shift
      ;;
    *)
      # Assume any other argument is an attempt to specify package manager (for validation error)
      PACKAGE_MANAGER="$1"
      shift
      ;;
  esac
done

# Validate package manager
case "$PACKAGE_MANAGER" in
    bun|pnpm|npm)
        ;;
    *)
        echo -e "${RED}Error: Invalid package manager '$PACKAGE_MANAGER'${NC}"
        echo -e "${YELLOW}Usage: $0 [bun|pnpm|npm] [--skip-install] [--skip-cleanup] [--only-cleanup]${NC}"
        echo -e "${YELLOW}Default: bun${NC}"
        exit 1
        ;;
esac

# Check if package manager is available
if ! command -v "$PACKAGE_MANAGER" &> /dev/null; then
    echo -e "${RED}Error: $PACKAGE_MANAGER is not installed${NC}"
    echo -e "${YELLOW}Please install $PACKAGE_MANAGER or use a different package manager${NC}"
    exit 1
fi

# Check if bridge directory exists
if [ ! -d "$BRIDGE_DIR" ]; then
    echo -e "${RED}Error: Bridge directory not found at $BRIDGE_DIR${NC}"
    exit 1
fi

cd "$BRIDGE_DIR"

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: package.json not found${NC}"
    exit 1
fi

# Handle --only-cleanup
if [ "$ONLY_CLEANUP" = true ]; then
    if [ -d "node_modules" ]; then
        echo -e "${BLUE}Cleaning up node_modules...${NC}"
        rm -rf node_modules
        echo -e "${GREEN}✓ node_modules removed${NC}"
    else
        echo -e "${YELLOW}node_modules not found, nothing to clean.${NC}"
    fi
    exit 0
fi

# Check if node_modules exists when skipping install
if [ "$SKIP_INSTALL" = true ] && [ ! -d "node_modules" ]; then
    echo -e "${RED}Error: Cannot skip install because node_modules is missing.${NC}"
    echo -e "${YELLOW}Please run without --skip-install first.${NC}"
    exit 1
fi

# Install dependencies
if [ "$SKIP_INSTALL" = false ]; then
    echo -e "${BLUE}Installing bridge server dependencies using $PACKAGE_MANAGER...${NC}"
    case "$PACKAGE_MANAGER" in
        bun)
            bun install
            ;;
        pnpm)
            pnpm install
            ;;
        npm)
            npm install
            ;;
    esac

    echo -e "${GREEN}✓ Dependencies installed successfully!${NC}"
else
    echo -e "${YELLOW}Skipping dependencies installation...${NC}"
fi

# Build unified bundle
echo -e "${BLUE}Building bridge server bundle (minified)...${NC}"
case "$PACKAGE_MANAGER" in
    bun)
        bun run build
        ;;
    pnpm)
        pnpm run build
        ;;
    npm)
        npm run build
        ;;
esac

# Check bundle
BUNDLE="../lib/src/bridge/bridge_server.bundle.js"

if [ -f "$BUNDLE" ]; then
    BUNDLE_SIZE=$(du -h "$BUNDLE" | cut -f1)
    
    echo -e "${GREEN}✓ Bridge server bundle built successfully!${NC}"
    echo ""
    echo -e "${GREEN}  unified bundle: $BUNDLE_SIZE - $BUNDLE${NC}"
    
    # Remove node_modules after successful build
    # Rule: 
    # 1. If --skip-cleanup is passed, NEVER clean.
    # 2. If --skip-install is passed (and no skip-cleanup), DO NOT clean (assume user wants to keep env).
    # 3. Default: Clean up.
    
    SHOULD_CLEANUP=true
    if [ "$SKIP_CLEANUP" = true ] || [ "$SKIP_INSTALL" = true ]; then
        SHOULD_CLEANUP=false
    fi

    if [ "$SHOULD_CLEANUP" = true ] && [ -d "node_modules" ]; then
        echo -e "${BLUE}Cleaning up node_modules...${NC}"
        rm -rf node_modules
        echo -e "${GREEN}✓ node_modules removed${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}Setup complete! The bridge server is ready to use.${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  ${BLUE}Dart VM:${NC}   Uses stdio mode (bridge_server.bundle.js) via Process.start()"
    echo -e "  ${BLUE}dart2js:${NC}   Uses worker mode (bridge_server.bundle.js) via Worker Threads"
else
    echo -e "${RED}Error: bridge bundle not created${NC}"
    exit 1
fi
