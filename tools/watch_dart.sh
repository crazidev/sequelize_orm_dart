#!/bin/bash

# Watch script for Dart server
# Monitors Dart files and restarts the server on changes

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
HASH_FILE="/tmp/sequelize_dart_server_watch_hash_$$"
DART_PID=""

# Cleanup on exit
cleanup() {
    echo ""
    echo -e "${RED}Stopping Dart server...${NC}"
    [ -n "$DART_PID" ] && kill $DART_PID 2>/dev/null
    rm -f "$HASH_FILE" "$HASH_FILE.new"
    exit 0
}
trap cleanup EXIT INT TERM

# Get hash of all Dart files
get_files_hash() {
    find $WATCH_DIRS -name "*.dart" -type f 2>/dev/null | sort | xargs cat 2>/dev/null | md5 -q
}

# Start Dart server
start_server() {
    # Kill existing server if running
    if [ -n "$DART_PID" ]; then
        kill $DART_PID 2>/dev/null
        wait $DART_PID 2>/dev/null
    fi

    echo -e "${BLUE}[$(date +%H:%M:%S)] Starting Dart server...${NC}"
    dart run example/lib/main.dart &
    DART_PID=$!
    echo -e "${GREEN}[$(date +%H:%M:%S)] Dart server started (PID: $DART_PID)${NC}"
}

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Dart Server Watch                  ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Store initial hash
get_files_hash > "$HASH_FILE"

# Start server initially
start_server

echo ""
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""
echo -e "${GREEN}[$(date +%H:%M:%S)] Watching for file changes...${NC}"
echo ""

# Polling loop
while true; do
    sleep 1

    # Get current hash
    get_files_hash > "$HASH_FILE.new" 2>/dev/null

    # Compare hashes
    if ! cmp -s "$HASH_FILE" "$HASH_FILE.new" 2>/dev/null; then
        echo ""
        echo -e "${BLUE}[$(date +%H:%M:%S)] File change detected, restarting server...${NC}"
        start_server
        mv "$HASH_FILE.new" "$HASH_FILE" 2>/dev/null
        echo ""
    fi

    # Don't auto-restart on crashes - only restart on file changes
    # This allows users to see errors and fix them before restarting
done

