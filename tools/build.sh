#!/bin/bash

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

# Check if example directory exists
if [ ! -d "example" ]; then
    echo -e "${RED}Error: example directory not found${NC}"
    exit 1
fi

# Create build directory if it doesn't exist
mkdir -p example/build

# Function to run code generator
run_generator() {
    echo -e "${BLUE}Running code generator...${NC}"
    cd "$ROOT_DIR/example"
    dart run build_runner build --delete-conflicting-outputs
    cd "$ROOT_DIR"
    echo -e "${GREEN}Code generation complete!${NC}"
}

# Function to compile Dart to JS
compile_js() {
    echo -e "${BLUE}Compiling Dart to JS...${NC}"
    dart compile js example/lib/main.dart -o example/build/temp.js
    
    echo -e "${BLUE}Adding Node.js preamble...${NC}"
    cat preamble.js example/build/temp.js > example/build/index.js
    rm example/build/temp.js
    
    echo -e "${GREEN}Build complete: example/build/index.js${NC}"
}

# Function to run the compiled JS
run_js() {
    echo -e "${YELLOW}Running...${NC}"
    echo ""
    node example/build/index.js
}

# Parse arguments
WATCH=false
RUN=false
GENERATE=false

for arg in "$@"; do
    case $arg in
        --watch)
            WATCH=true
            ;;
        --run)
            RUN=true
            ;;
        --generate)
            GENERATE=true
            ;;
        --help)
            echo "Usage: ./tools/build.sh [options]"
            echo ""
            echo "Options:"
            echo "  --generate  Run code generator before building"
            echo "  --run       Run the compiled JS after building"
            echo "  --watch     Watch for file changes and rebuild"
            echo "  --help      Show this help message"
            exit 0
            ;;
    esac
done

# Main build process
if [ "$GENERATE" = true ]; then
    run_generator
fi

compile_js

if [ "$RUN" = true ]; then
    run_js
fi

# Watch mode is handled by VS Code tasks or external watcher
if [ "$WATCH" = true ]; then
    echo -e "${YELLOW}Watch mode is best handled via VS Code tasks.${NC}"
    echo -e "${YELLOW}Run 'Tasks: Run Task' and select 'Watch All' from the command palette.${NC}"
fi
