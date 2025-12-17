#!/bin/bash

# Watch script for Dart server debugging
# Monitors Dart files and signals when to restart (for use with VS Code debugger)

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
HASH_FILE="/tmp/sequelize_dart_debug_watch_hash_$$"
SIGNAL_FILE="/tmp/sequelize_dart_debug_restart_signal_$$"

# Cleanup on exit
cleanup() {
    rm -f "$HASH_FILE" "$HASH_FILE.new" "$SIGNAL_FILE"
    exit 0
}
trap cleanup EXIT INT TERM

# Get hash of all Dart files
get_files_hash() {
    find $WATCH_DIRS -name "*.dart" -type f 2>/dev/null | sort | xargs cat 2>/dev/null | md5 -q
}

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Dart Debug File Watcher               ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Store initial hash
get_files_hash > "$HASH_FILE"

echo -e "${GREEN}[$(date +%H:%M:%S)] Watching for file changes...${NC}"
echo -e "${YELLOW}Tip: Press ⇧⌘F5 (Shift+Cmd+F5) or click 'Restart' in debug toolbar to restart${NC}"
echo ""

# Polling loop
while true; do
    sleep 1

    # Get current hash
    get_files_hash > "$HASH_FILE.new" 2>/dev/null

    # Compare hashes
    if ! cmp -s "$HASH_FILE" "$HASH_FILE.new" 2>/dev/null; then
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}  ${YELLOW}⚡ File change detected at $(date +%H:%M:%S)${NC}             ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${GREEN}→ Press ⇧⌘F5 to restart debug session${NC}           ${CYAN}║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
        echo ""

        # Create signal file for potential automation
        touch "$SIGNAL_FILE"

        mv "$HASH_FILE.new" "$HASH_FILE" 2>/dev/null
    fi
done
