#!/bin/bash

# Watch script for Dart files - no external dependencies required
# Uses a polling approach for cross-platform compatibility

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directories to watch
WATCH_DIRS="example/lib packages"

# File hash storage
HASH_FILE="/tmp/sequelize_dart_watch_hash_$$"

# Cleanup on exit
cleanup() {
    rm -f "$HASH_FILE" "$HASH_FILE.new"
    exit 0
}
trap cleanup EXIT INT

# Get hash of all Dart files
get_files_hash() {
    find $WATCH_DIRS -name "*.dart" -type f 2>/dev/null | sort | xargs cat 2>/dev/null | md5 -q
}

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Sequelize Dart File Watcher          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Watching directories: ${WATCH_DIRS}${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Initial build
echo -e "${BLUE}[$(date +%H:%M:%S)] Running initial build...${NC}"
./tools/build.sh
echo ""

# Store initial hash
get_files_hash > "$HASH_FILE"

echo -e "${GREEN}[$(date +%H:%M:%S)] Watching for changes...${NC}"
echo ""

# Polling loop
while true; do
    sleep 1
    
    # Get current hash
    get_files_hash > "$HASH_FILE.new"
    
    # Compare hashes
    if ! cmp -s "$HASH_FILE" "$HASH_FILE.new"; then
        echo ""
        echo -e "${BLUE}[$(date +%H:%M:%S)] Change detected, rebuilding...${NC}"
        ./tools/build.sh 2>&1 || true
        mv "$HASH_FILE.new" "$HASH_FILE"
        echo -e "${GREEN}[$(date +%H:%M:%S)] Ready${NC}"
    fi
done
