#!/bin/bash
# MongoDB Backup Script
# This script creates a backup of the MongoDB database

set -e

# Load environment variables
if [ -f .env.production ]; then
    export $(cat .env.production | grep -v '^#' | xargs)
fi

# Configuration
BACKUP_DIR="${BACKUP_PATH:-/var/backups/bhumi-interior}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="bhumi-interior-backup-${DATE}"
MONGO_CONTAINER="bhumi-interior-mongodb"
MONGO_USER="${MONGO_ROOT_USERNAME:-admin}"
MONGO_PASS="${MONGO_ROOT_PASSWORD:-password123}"
MONGO_DB="${MONGO_DATABASE:-bhumi-interior}"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

echo "🔄 Starting MongoDB backup..."
echo "📅 Date: $(date)"
echo "🗄️  Database: ${MONGO_DB}"

# Create backup using mongodump
docker exec ${MONGO_CONTAINER} mongodump \
    --username="${MONGO_USER}" \
    --password="${MONGO_PASS}" \
    --authenticationDatabase=admin \
    --db="${MONGO_DB}" \
    --out="/backups/${BACKUP_NAME}"

# Compress backup
cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"

# Get backup size
BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)

echo "✅ Backup completed successfully!"
echo "📦 Backup file: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo "💾 Size: ${BACKUP_SIZE}"

# Remove backups older than 30 days
echo "🧹 Cleaning old backups (older than 30 days)..."
find "${BACKUP_DIR}" -name "bhumi-interior-backup-*.tar.gz" -mtime +30 -delete

# Count remaining backups
BACKUP_COUNT=$(find "${BACKUP_DIR}" -name "bhumi-interior-backup-*.tar.gz" | wc -l)
echo "📊 Total backups: ${BACKUP_COUNT}"

echo "✨ Backup process complete!"
