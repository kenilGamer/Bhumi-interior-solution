#!/bin/bash
# Complete Backup Script for Migration
# This script creates a comprehensive backup of the entire application

set -e

echo "================================================"
echo "🚀 Bhumi Interior Solution - Complete Backup"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_BASE_DIR="/var/backups/bhumi-interior"
MIGRATION_DIR="${BACKUP_BASE_DIR}/migration-${DATE}"
PROJECT_DIR="/var/www/bhumi-interior"

# Create backup directory
echo "📁 Creating backup directory..."
mkdir -p "${MIGRATION_DIR}"/{database,uploads,config,source}

echo -e "${GREEN}✓ Backup directory created: ${MIGRATION_DIR}${NC}"
echo ""

# Load environment variables if exists
if [ -f "${PROJECT_DIR}/.env.production" ]; then
    export $(cat ${PROJECT_DIR}/.env.production | grep -v '^#' | xargs)
fi

# ========================================
# 1. Backup Database
# ========================================
echo "🗄️  Step 1/5: Backing up database..."

# Check if using MongoDB Atlas or local MongoDB
if [ ! -z "${MONGO_URI}" ] && [[ "${MONGO_URI}" == *"mongodb+srv"* ]]; then
    echo "   Using MongoDB Atlas (Cloud Database)"
    echo "   Note: MongoDB Atlas handles backups automatically."
    echo "   Exporting current database snapshot..."
    
    # Export current database structure and sample data
    if command -v mongodump &> /dev/null; then
        mongodump --uri="${MONGO_URI}" --out="${MIGRATION_DIR}/database/atlas-export" --gzip
        echo -e "${GREEN}✓ Database exported${NC}"
    else
        echo -e "${YELLOW}⚠ mongodump not installed. Skipping database export.${NC}"
        echo "   Your data is safe in MongoDB Atlas."
    fi
else
    # Local MongoDB backup
    MONGO_CONTAINER="bhumi-interior-mongodb"
    
    if docker ps | grep -q ${MONGO_CONTAINER}; then
        echo "   Using Local MongoDB (Docker)"
        MONGO_USER="${MONGO_ROOT_USERNAME:-admin}"
        MONGO_PASS="${MONGO_ROOT_PASSWORD:-password123}"
        MONGO_DB="${MONGO_DATABASE:-bhumi-interior}"
        
        docker exec ${MONGO_CONTAINER} mongodump \
            --username="${MONGO_USER}" \
            --password="${MONGO_PASS}" \
            --authenticationDatabase=admin \
            --db="${MONGO_DB}" \
            --gzip \
            --out="/backups/db-${DATE}"
        
        # Copy from container to backup directory
        docker cp ${MONGO_CONTAINER}:/backups/db-${DATE} "${MIGRATION_DIR}/database/"
        
        # Create compressed archive
        cd "${MIGRATION_DIR}/database"
        tar -czf database-backup.tar.gz db-${DATE}/
        rm -rf db-${DATE}/
        
        DB_SIZE=$(du -h database-backup.tar.gz | cut -f1)
        echo -e "${GREEN}✓ Database backed up (${DB_SIZE})${NC}"
    else
        echo -e "${YELLOW}⚠ MongoDB container not running. Skipping database backup.${NC}"
    fi
fi

echo ""

# ========================================
# 2. Backup Uploaded Files
# ========================================
echo "📸 Step 2/5: Backing up uploaded files..."

if [ -d "${PROJECT_DIR}/backend/uploads" ]; then
    cd "${PROJECT_DIR}"
    tar -czf "${MIGRATION_DIR}/uploads/uploads-backup.tar.gz" backend/uploads/
    
    UPLOADS_SIZE=$(du -h "${MIGRATION_DIR}/uploads/uploads-backup.tar.gz" | cut -f1)
    UPLOADS_COUNT=$(find backend/uploads -type f | wc -l)
    
    echo -e "${GREEN}✓ Uploaded files backed up${NC}"
    echo "   Files: ${UPLOADS_COUNT}"
    echo "   Size: ${UPLOADS_SIZE}"
else
    echo -e "${YELLOW}⚠ No uploads directory found${NC}"
fi

echo ""

# ========================================
# 3. Backup Configuration Files
# ========================================
echo "⚙️  Step 3/5: Backing up configuration files..."

cd "${PROJECT_DIR}"

# Backup environment files
if [ -f .env.production ]; then
    cp .env.production "${MIGRATION_DIR}/config/"
    echo "   ✓ .env.production"
fi

if [ -f frontend/.env.production ]; then
    cp frontend/.env.production "${MIGRATION_DIR}/config/frontend.env.production"
    echo "   ✓ frontend/.env.production"
fi

if [ -f backend/.env ]; then
    cp backend/.env "${MIGRATION_DIR}/config/backend.env"
    echo "   ✓ backend/.env"
fi

# Backup Docker configurations
cp docker-compose.yml "${MIGRATION_DIR}/config/" 2>/dev/null || true
cp docker-compose.atlas.yml "${MIGRATION_DIR}/config/" 2>/dev/null || true
cp docker-compose.dev.yml "${MIGRATION_DIR}/config/" 2>/dev/null || true
echo "   ✓ Docker Compose files"

# Backup Nginx configurations
if [ -d nginx/conf.d ]; then
    cp -r nginx/conf.d "${MIGRATION_DIR}/config/"
    echo "   ✓ Nginx configurations"
fi

# Backup package.json files
cp package.json "${MIGRATION_DIR}/config/root-package.json" 2>/dev/null || true
cp backend/package.json "${MIGRATION_DIR}/config/backend-package.json" 2>/dev/null || true
cp frontend/package.json "${MIGRATION_DIR}/config/frontend-package.json" 2>/dev/null || true
echo "   ✓ Package.json files"

echo -e "${GREEN}✓ Configuration files backed up${NC}"
echo ""

# ========================================
# 4. Backup Source Code
# ========================================
echo "💻 Step 4/5: Backing up source code..."

cd /var/www

# Create source code backup (excluding node_modules and build artifacts)
tar -czf "${MIGRATION_DIR}/source/source-code.tar.gz" \
    --exclude='bhumi-interior/node_modules' \
    --exclude='bhumi-interior/backend/node_modules' \
    --exclude='bhumi-interior/frontend/node_modules' \
    --exclude='bhumi-interior/frontend/dist' \
    --exclude='bhumi-interior/frontend/build' \
    --exclude='bhumi-interior/backend/uploads' \
    --exclude='bhumi-interior/backups' \
    --exclude='bhumi-interior/.git' \
    --exclude='bhumi-interior/certbot' \
    --exclude='bhumi-interior/nginx/logs' \
    bhumi-interior/

SOURCE_SIZE=$(du -h "${MIGRATION_DIR}/source/source-code.tar.gz" | cut -f1)
echo -e "${GREEN}✓ Source code backed up (${SOURCE_SIZE})${NC}"
echo ""

# ========================================
# 5. Create Migration Instructions
# ========================================
echo "📝 Step 5/5: Creating migration instructions..."

cat > "${MIGRATION_DIR}/README.md" << 'EOF'
# Bhumi Interior Solution - Migration Backup

This backup was created for migrating to a new hosting provider.

## 📦 Backup Contents

```
migration-YYYYMMDD_HHMMSS/
├── database/           # Database backup
│   └── database-backup.tar.gz (or atlas-export/)
├── uploads/            # All uploaded files
│   └── uploads-backup.tar.gz
├── config/             # Configuration files
│   ├── .env.production
│   ├── frontend.env.production
│   ├── backend.env
│   ├── docker-compose*.yml
│   ├── conf.d/        # Nginx configs
│   └── *-package.json
├── source/             # Source code
│   └── source-code.tar.gz
└── README.md          # This file
```

## 🚀 How to Restore on New Server

### Quick Start

```bash
# 1. Upload this entire directory to new server
scp -r migration-YYYYMMDD_HHMMSS/ root@NEW_SERVER_IP:/var/www/bhumi-interior/backups/

# 2. On new server, run restore script
cd /var/www/bhumi-interior
sudo ./scripts/restore-from-backup.sh backups/migration-YYYYMMDD_HHMMSS/

# 3. Follow the on-screen instructions
```

### Manual Restoration

If you prefer manual control, follow these steps:

#### 1. Extract Source Code
```bash
cd /var/www
tar -xzf migration-YYYYMMDD_HHMMSS/source/source-code.tar.gz
cd bhumi-interior
```

#### 2. Restore Configuration
```bash
cp migration-YYYYMMDD_HHMMSS/config/.env.production ./
cp migration-YYYYMMDD_HHMMSS/config/frontend.env.production frontend/.env.production
# Update configuration with new server details
nano .env.production
```

#### 3. Restore Uploads
```bash
tar -xzf migration-YYYYMMDD_HHMMSS/uploads/uploads-backup.tar.gz
chmod -R 755 backend/uploads
```

#### 4. Build and Deploy
```bash
# Build frontend
cd frontend
npm install
npm run build
cd ..

# Deploy with Docker
docker-compose -f docker-compose.atlas.yml build --no-cache
docker-compose -f docker-compose.atlas.yml up -d
```

#### 5. Restore Database (if needed)
```bash
# For MongoDB Atlas, data is already there
# For local MongoDB:
tar -xzf migration-YYYYMMDD_HHMMSS/database/database-backup.tar.gz
./scripts/mongodb-restore.sh migration-YYYYMMDD_HHMMSS/database/database-backup.tar.gz
```

## 📋 Important Notes

1. **Environment Variables**: Update `.env.production` with new server IP/domain
2. **MongoDB Atlas**: If using Atlas, just use the same connection string
3. **SSL Certificates**: Generate new certificates for the new server
4. **DNS**: Update DNS records to point to new server IP
5. **Firewall**: Ensure ports 80, 443 are open on new server

## 🔗 Resources

- Full Migration Guide: `/var/www/bhumi-interior/MIGRATION-GUIDE.md`
- Deployment Guide: `/var/www/bhumi-interior/DEPLOYMENT.md`

## ⚠️ Security

This backup contains sensitive information:
- Database credentials
- JWT secrets
- Email passwords
- API keys

**Keep this backup secure and delete from old server after migration!**

---

Created: $(date)
Server: $(hostname)
IP: $(hostname -I | awk '{print $1}')
EOF

echo -e "${GREEN}✓ Migration instructions created${NC}"
echo ""

# ========================================
# Create Manifest File
# ========================================
cat > "${MIGRATION_DIR}/manifest.txt" << EOF
Bhumi Interior Solution - Migration Backup Manifest
===================================================

Created: ${DATE}
Server: $(hostname)
IP: $(hostname -I | awk '{print $1}')
Backup Location: ${MIGRATION_DIR}

Files Included:
---------------
EOF

cd "${MIGRATION_DIR}"
find . -type f -exec ls -lh {} \; | awk '{print $9, "-", $5}' >> manifest.txt

# ========================================
# Calculate Total Backup Size
# ========================================
TOTAL_SIZE=$(du -sh "${MIGRATION_DIR}" | cut -f1)

# ========================================
# Summary
# ========================================
echo "================================================"
echo -e "${GREEN}✅ Backup Completed Successfully!${NC}"
echo "================================================"
echo ""
echo "📊 Backup Summary:"
echo "   Location: ${MIGRATION_DIR}"
echo "   Total Size: ${TOTAL_SIZE}"
echo "   Date: $(date)"
echo ""
echo "📁 Backup Structure:"
ls -lh "${MIGRATION_DIR}"
echo ""
echo "📋 Next Steps:"
echo "   1. Download backup to your local machine:"
echo "      ${YELLOW}scp -r root@YOUR_SERVER_IP:${MIGRATION_DIR} ./migration-backup/${NC}"
echo ""
echo "   2. Upload to new server:"
echo "      ${YELLOW}scp -r ./migration-backup/ root@NEW_SERVER_IP:/var/www/bhumi-interior/backups/${NC}"
echo ""
echo "   3. Follow the MIGRATION-GUIDE.md for complete instructions"
echo ""
echo "🔒 Security Reminder:"
echo "   This backup contains sensitive data. Keep it secure!"
echo ""
echo -e "${GREEN}✨ All done! Your application is ready to migrate.${NC}"
echo ""

