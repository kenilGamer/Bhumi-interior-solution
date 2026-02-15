#!/bin/bash
# MongoDB Restore Script
# This script restores a MongoDB backup

set -e

# Load environment variables
if [ -f .env.production ]; then
    export $(cat .env.production | grep -v '^#' | xargs)
fi

# Configuration
BACKUP_DIR="${BACKUP_PATH:-/var/backups/bhumi-interior}"
MONGO_CONTAINER="bhumi-interior-mongodb"
MONGO_USER="${MONGO_ROOT_USERNAME:-admin}"
MONGO_PASS="${MONGO_ROOT_PASSWORD:-password123}"
MONGO_DB="${MONGO_DATABASE:-bhumi-interior}"

# Check if backup file is provided
if [ -z "$1" ]; then
    echo "❌ Error: Backup file not specified"
    echo "Usage: ./mongodb-restore.sh <backup-file.tar.gz>"
    echo ""
    echo "Available backups:"
    ls -lh "${BACKUP_DIR}"/*.tar.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "${BACKUP_FILE}" ]; then
    # Try in backup directory
    if [ -f "${BACKUP_DIR}/${BACKUP_FILE}" ]; then
        BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILE}"
    else
        echo "❌ Error: Backup file not found: ${BACKUP_FILE}"
        exit 1
    fi
fi

echo "⚠️  WARNING: This will restore the database from backup."
echo "📦 Backup file: ${BACKUP_FILE}"
echo "🗄️  Database: ${MONGO_DB}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "❌ Restore cancelled"
    exit 1
fi

# Extract backup
TEMP_DIR="/tmp/mongo-restore-$$"
mkdir -p "${TEMP_DIR}"
echo "📂 Extracting backup..."
tar -xzf "${BACKUP_FILE}" -C "${TEMP_DIR}"

# Find the backup directory
BACKUP_NAME=$(tar -tzf "${BACKUP_FILE}" | head -1 | cut -f1 -d"/")
RESTORE_PATH="${TEMP_DIR}/${BACKUP_NAME}/${MONGO_DB}"

if [ ! -d "${RESTORE_PATH}" ]; then
    echo "❌ Error: Invalid backup structure"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# Copy to docker volume
docker cp "${RESTORE_PATH}" "${MONGO_CONTAINER}:/tmp/restore"

echo "🔄 Restoring database..."
docker exec ${MONGO_CONTAINER} mongorestore \
    --username="${MONGO_USER}" \
    --password="${MONGO_PASS}" \
    --authenticationDatabase=admin \
    --db="${MONGO_DB}" \
    --drop \
    "/tmp/restore"

# Cleanup
docker exec ${MONGO_CONTAINER} rm -rf /tmp/restore
rm -rf "${TEMP_DIR}"

echo "✅ Database restored successfully!"
echo "🗄️  Database: ${MONGO_DB}"
echo "✨ Restore complete!"
