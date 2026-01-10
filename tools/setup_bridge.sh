#!/bin/bash

# Setup script for Sequelize Dart bridge server
# Installs dependencies and builds both the stdio and worker thread bundles

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

BRIDGE_DIR="$ROOT_DIR/packages/sequelize_dart/js"

# Parse package manager argument (default: bun)
PACKAGE_MANAGER="${1:-bun}"

# Validate package manager
case "$PACKAGE_MANAGER" in
    bun|pnpm|npm)
        ;;
    *)
        echo -e "${RED}Error: Invalid package manager '$PACKAGE_MANAGER'${NC}"
        echo -e "${YELLOW}Usage: $0 [bun|pnpm|npm]${NC}"
        echo -e "${YELLOW}Default: npm${NC}"
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

# Install dependencies
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

# Build both bundles
echo -e "${BLUE}Building bridge server bundles (minified)...${NC}"
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

# Check both bundles
STDIO_BUNDLE="bridge_server.bundle.js"
WORKER_BUNDLE="bridge_server_worker.bundle.js"

if [ -f "$STDIO_BUNDLE" ] && [ -f "$WORKER_BUNDLE" ]; then
    STDIO_SIZE=$(du -h "$STDIO_BUNDLE" | cut -f1)
    WORKER_SIZE=$(du -h "$WORKER_BUNDLE" | cut -f1)
    
    echo -e "${GREEN}✓ Bridge server bundles built successfully!${NC}"
    echo ""
    echo -e "${GREEN}  stdio bundle (Dart VM):    $STDIO_SIZE - $BRIDGE_DIR/$STDIO_BUNDLE${NC}"
    echo -e "${GREEN}  worker bundle (dart2js):   $WORKER_SIZE - $BRIDGE_DIR/$WORKER_BUNDLE${NC}"
    
    # Remove node_modules after successful build
    if [ -d "node_modules" ]; then
        echo -e "${BLUE}Cleaning up node_modules...${NC}"
        rm -rf node_modules
        echo -e "${GREEN}✓ node_modules removed${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}Setup complete! The bridge servers are ready to use.${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  ${BLUE}Dart VM:${NC}   Uses stdio bridge (bridge_server.bundle.js) via Process.start()"
    echo -e "  ${BLUE}dart2js:${NC}   Uses worker bridge (bridge_server_worker.bundle.js) via Worker Threads"
else
    if [ ! -f "$STDIO_BUNDLE" ]; then
        echo -e "${RED}Error: stdio bundle not created${NC}"
    fi
    if [ ! -f "$WORKER_BUNDLE" ]; then
        echo -e "${RED}Error: worker bundle not created${NC}"
    fi
    exit 1
fi
