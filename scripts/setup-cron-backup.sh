#!/bin/bash
# Setup Cron Job for Automatic MongoDB Backups
# This script sets up a daily backup at 2 AM

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="${SCRIPT_DIR}/mongodb-backup.sh"
LOG_DIR="/var/log/bhumi-interior"

# Create log directory
sudo mkdir -p "${LOG_DIR}"
sudo chmod 755 "${LOG_DIR}"

# Make backup script executable
chmod +x "${BACKUP_SCRIPT}"

# Create cron job
CRON_JOB="0 2 * * * ${BACKUP_SCRIPT} >> ${LOG_DIR}/backup.log 2>&1"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "${BACKUP_SCRIPT}"; then
    echo "⚠️  Cron job already exists"
    echo "Current cron jobs:"
    crontab -l | grep "${BACKUP_SCRIPT}"
else
    # Add cron job
    (crontab -l 2>/dev/null; echo "${CRON_JOB}") | crontab -
    echo "✅ Cron job added successfully!"
    echo "📅 Backup will run daily at 2:00 AM"
    echo "📝 Logs: ${LOG_DIR}/backup.log"
fi

echo ""
echo "Current cron jobs:"
crontab -l

echo ""
echo "✨ Backup cron job setup complete!"
