#!/usr/bin/env bash
# Development Environment Setup Script
# This script sets up a PostgreSQL database using Docker for development
# Compatible with Linux, macOS, and Windows (Git Bash/WSL)
# Created: 2026-01-30

set -e  # Exit on error

# Configuration
POSTGRES_VERSION="16-alpine"
POSTGRES_DB="sequelize_dev"
POSTGRES_USER="dev_user"
POSTGRES_PASSWORD="dev_password"
POSTGRES_PORT=5432
CONTAINER_NAME="sequelize_postgres_dev"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_info() {
    echo -e "${CYAN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MIGRATIONS_DIR="$PROJECT_ROOT/example/migrations"

print_info "=========================================="
print_info "  Sequelize ORM - Dev Environment Setup"
print_info "=========================================="
echo ""

# Check if Docker is running
print_info "Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    print_error "✗ Docker is not running. Please start Docker and try again."
    exit 1
fi
print_success "✓ Docker is running"

# Stop and remove existing container if it exists
print_info "Checking for existing container..."
if docker ps -a --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    print_warning "Found existing container. Removing..."
    docker stop "$CONTAINER_NAME" > /dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" > /dev/null 2>&1 || true
    print_success "✓ Removed existing container"
fi

# Start PostgreSQL container
print_info "Starting PostgreSQL container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    -e POSTGRES_DB="$POSTGRES_DB" \
    -e POSTGRES_USER="$POSTGRES_USER" \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -p "${POSTGRES_PORT}:5432" \
    "postgres:$POSTGRES_VERSION" > /dev/null

print_success "✓ PostgreSQL container started"

# Wait for PostgreSQL to be ready
print_info "Waiting for PostgreSQL to be ready..."
MAX_ATTEMPTS=30
ATTEMPT=0
READY=false

while [ $ATTEMPT -lt $MAX_ATTEMPTS ] && [ "$READY" = false ]; do
    ATTEMPT=$((ATTEMPT + 1))
    if docker exec "$CONTAINER_NAME" pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1; then
        READY=true
    else
        sleep 1
    fi
done

if [ "$READY" = false ]; then
    print_error "✗ PostgreSQL failed to start within expected time"
    docker logs "$CONTAINER_NAME"
    exit 1
fi
print_success "✓ PostgreSQL is ready"

# Run migrations
print_info "Running database migrations..."
MIGRATION_FILE="$MIGRATIONS_DIR/create_tables_postgres.sql"
if [ ! -f "$MIGRATION_FILE" ]; then
    print_error "✗ Migration file not found: $MIGRATION_FILE"
    exit 1
fi

docker exec -i "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$MIGRATION_FILE" > /dev/null
print_success "✓ Migrations completed"

# Seed database
print_info "Seeding database..."
SEED_FILE="$MIGRATIONS_DIR/seed_data_postgres.sql"
if [ ! -f "$SEED_FILE" ]; then
    print_error "✗ Seed file not found: $SEED_FILE"
    exit 1
fi

docker exec -i "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$SEED_FILE" > /dev/null
print_success "✓ Database seeded"

# Verify data
print_info "Verifying data..."
USER_COUNT=$(docker exec "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -c "SELECT COUNT(*) FROM users;" | tr -d '[:space:]')
POST_COUNT=$(docker exec "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -c "SELECT COUNT(*) FROM posts;" | tr -d '[:space:]')
DETAILS_COUNT=$(docker exec "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -c "SELECT COUNT(*) FROM post_details;" | tr -d '[:space:]')

print_success "✓ Data verification:"
echo "  - Users: $USER_COUNT"
echo "  - Posts: $POST_COUNT"
echo "  - Post Details: $DETAILS_COUNT"

# Print connection information
echo ""
print_info "=========================================="
print_info "  Database Connection Information"
print_info "=========================================="
echo ""

CONNECTION_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_PORT}/${POSTGRES_DB}"

print_warning "Connection URL:"
print_success "  $CONNECTION_URL"
echo ""
print_warning "Connection Details:"
echo "  Host:     localhost"
echo "  Port:     $POSTGRES_PORT"
echo "  Database: $POSTGRES_DB"
echo "  User:     $POSTGRES_USER"
echo "  Password: $POSTGRES_PASSWORD"
echo ""

print_info "=========================================="
print_info "  Useful Commands"
print_info "=========================================="
echo ""
print_warning "Connect to database:"
echo "  docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -d $POSTGRES_DB"
echo ""
print_warning "Stop container:"
echo "  docker stop $CONTAINER_NAME"
echo ""
print_warning "Start container:"
echo "  docker start $CONTAINER_NAME"
echo ""
print_warning "Remove container:"
echo "  docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
echo ""

print_success "✓ Development environment setup complete!"
