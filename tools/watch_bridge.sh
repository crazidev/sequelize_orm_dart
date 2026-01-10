#!/bin/bash

# Watch and rebuild bridge server bundles

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

# Colors
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BRIDGE_DIR="$ROOT_DIR/packages/sequelize_dart/js"
HASH_FILE="/tmp/sequelize_bridge_watch_hash_$$"

cleanup() {
    echo ""
    echo -e "${RED}Stopping bridge watcher...${NC}"
    rm -f "$HASH_FILE" "$HASH_FILE.new"
    exit 0
}
trap cleanup EXIT INT

get_files_hash() {
    find "$BRIDGE_DIR/src" -name "*.ts" -type f 2>/dev/null | sort | xargs cat 2>/dev/null | md5 -q
}

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Bridge Server Watch                  ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Watching: packages/sequelize_dart/js/src/${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Initial build
echo -e "${BLUE}[$(date +%H:%M:%S)] Running initial build...${NC}"
./tools/setup_bridge.sh 2>&1 || true
echo ""

get_files_hash > "$HASH_FILE"
echo -e "${GREEN}[$(date +%H:%M:%S)] Ready - watching for changes...${NC}"

while true; do
    sleep 1
    get_files_hash > "$HASH_FILE.new"
    
    if ! cmp -s "$HASH_FILE" "$HASH_FILE.new"; then
        echo ""
        echo -e "${BLUE}[$(date +%H:%M:%S)] TypeScript change detected, rebuilding...${NC}"
        ./tools/setup_bridge.sh 2>&1 || true
        mv "$HASH_FILE.new" "$HASH_FILE"
        echo -e "${GREEN}[$(date +%H:%M:%S)] Ready${NC}"
    fi
done
