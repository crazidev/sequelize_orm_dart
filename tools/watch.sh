#!/bin/bash

# Development watch script
# Runs build_runner watch + JS compilation on file changes

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

# Directories to watch for JS compilation
WATCH_DIRS="example/lib packages"

# File hash storage
HASH_FILE="/tmp/sequelize_orm_watch_hash_$$"

# Cleanup on exit
cleanup() {
    echo ""
    echo -e "${RED}Stopping watchers...${NC}"
    [ -n "$BUILD_RUNNER_PID" ] && kill $BUILD_RUNNER_PID 2>/dev/null
    [ -n "$NODE_PID" ] && kill $NODE_PID 2>/dev/null
    rm -f "$HASH_FILE" "$HASH_FILE.new"
    exit 0
}
trap cleanup EXIT INT

# Get hash of all Dart files
get_files_hash() {
    find $WATCH_DIRS -name "*.dart" -type f 2>/dev/null | sort | xargs cat 2>/dev/null | md5 -q
}

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Sequelize Dart Dev Server          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Start build_runner watch in background
echo -e "${BLUE}Starting build_runner watch...${NC}"
cd example
dart run build_runner watch --delete-conflicting-outputs &
BUILD_RUNNER_PID=$!
cd "$ROOT_DIR"
echo -e "${GREEN}Build runner started (PID: $BUILD_RUNNER_PID)${NC}"

# Wait for build_runner to initialize
sleep 3

# Initial build
echo ""
echo -e "${BLUE}Running initial build...${NC}"
./tools/build.sh
echo ""
echo -e "${GREEN}Initial build complete!${NC}"

# Start node with watch
echo ""
echo -e "${BLUE}Starting Node.js with --watch...${NC}"
node --watch example/build/index.js &
NODE_PID=$!
echo -e "${GREEN}Node.js started (PID: $NODE_PID)${NC}"

echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all watchers${NC}"
echo ""

# Store initial hash
get_files_hash > "$HASH_FILE"

echo -e "${GREEN}[$(date +%H:%M:%S)] Watching for file changes...${NC}"
echo ""

# Polling loop for JS rebuild
while true; do
    sleep 2
    
    # Get current hash
    get_files_hash > "$HASH_FILE.new"
    
    # Compare hashes
    if ! cmp -s "$HASH_FILE" "$HASH_FILE.new"; then
        echo ""
        echo -e "${BLUE}[$(date +%H:%M:%S)] Dart file changed, recompiling JS...${NC}"
        ./tools/build.sh 2>&1 || true
        mv "$HASH_FILE.new" "$HASH_FILE"
        echo -e "${GREEN}[$(date +%H:%M:%S)] Recompilation complete${NC}"
        echo ""
    fi
done
