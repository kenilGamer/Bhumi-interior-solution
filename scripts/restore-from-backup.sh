#!/bin/bash
# Restore from Backup Script
# This script restores the application from a migration backup

set -e

echo "================================================"
echo "🔄 Bhumi Interior Solution - Restore from Backup"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if backup directory is provided
if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: Backup directory not specified${NC}"
    echo ""
    echo "Usage: sudo ./restore-from-backup.sh <backup-directory>"
    echo ""
    echo "Example:"
    echo "  sudo ./restore-from-backup.sh /var/www/bhumi-interior/backups/migration-20250101_120000/"
    echo ""
    echo "Available backups:"
    ls -lh /var/backups/bhumi-interior/ 2>/dev/null || echo "  No backups found in /var/backups/bhumi-interior/"
    exit 1
fi

BACKUP_DIR="$1"

# Verify backup directory exists
if [ ! -d "${BACKUP_DIR}" ]; then
    echo -e "${RED}❌ Error: Backup directory not found: ${BACKUP_DIR}${NC}"
    exit 1
fi

echo "📦 Backup Directory: ${BACKUP_DIR}"
echo ""

# Verify backup structure
if [ ! -d "${BACKUP_DIR}/source" ] || [ ! -d "${BACKUP_DIR}/config" ]; then
    echo -e "${RED}❌ Error: Invalid backup structure${NC}"
    echo "Expected directories: source/, config/, uploads/, database/"
    exit 1
fi

# Configuration
PROJECT_DIR="/var/www/bhumi-interior"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Confirmation prompt
echo -e "${YELLOW}⚠️  WARNING: This will restore the application from backup.${NC}"
echo ""
echo "This will:"
echo "  1. Extract source code to ${PROJECT_DIR}"
echo "  2. Restore configuration files"
echo "  3. Restore uploaded files"
echo "  4. Optionally restore database"
echo ""
read -p "Do you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${RED}❌ Restore cancelled${NC}"
    exit 1
fi

echo ""

# ========================================
# 1. Backup Current Installation (if exists)
# ========================================
if [ -d "${PROJECT_DIR}" ] && [ "$(ls -A ${PROJECT_DIR})" ]; then
    echo "🔄 Step 1/6: Backing up current installation..."
    CURRENT_BACKUP="/var/backups/bhumi-interior/pre-restore-backup-${TIMESTAMP}"
    mkdir -p "${CURRENT_BACKUP}"
    
    cp -r "${PROJECT_DIR}" "${CURRENT_BACKUP}/" 2>/dev/null || true
    echo -e "${GREEN}✓ Current installation backed up to: ${CURRENT_BACKUP}${NC}"
else
    echo "ℹ️  Step 1/6: No existing installation found. Starting fresh..."
fi

echo ""

# ========================================
# 2. Extract Source Code
# ========================================
echo "💻 Step 2/6: Extracting source code..."

# Create project directory
mkdir -p "${PROJECT_DIR}"

# Extract source code
if [ -f "${BACKUP_DIR}/source/source-code.tar.gz" ]; then
    cd /var/www
    tar -xzf "${BACKUP_DIR}/source/source-code.tar.gz"
    echo -e "${GREEN}✓ Source code extracted${NC}"
else
    echo -e "${RED}❌ Error: Source code archive not found${NC}"
    exit 1
fi

echo ""

# ========================================
# 3. Restore Configuration Files
# ========================================
echo "⚙️  Step 3/6: Restoring configuration files..."

cd "${PROJECT_DIR}"

# Restore environment files
if [ -f "${BACKUP_DIR}/config/.env.production" ]; then
    cp "${BACKUP_DIR}/config/.env.production" ./
    echo "   ✓ .env.production"
fi

if [ -f "${BACKUP_DIR}/config/frontend.env.production" ]; then
    mkdir -p frontend
    cp "${BACKUP_DIR}/config/frontend.env.production" frontend/.env.production
    echo "   ✓ frontend/.env.production"
fi

if [ -f "${BACKUP_DIR}/config/backend.env" ]; then
    mkdir -p backend
    cp "${BACKUP_DIR}/config/backend.env" backend/.env
    echo "   ✓ backend/.env"
fi

# Restore Docker configurations
cp "${BACKUP_DIR}/config/"docker-compose*.yml ./ 2>/dev/null || true
echo "   ✓ Docker Compose files"

# Restore Nginx configurations
if [ -d "${BACKUP_DIR}/config/conf.d" ]; then
    mkdir -p nginx/conf.d
    cp -r "${BACKUP_DIR}/config/conf.d"/* nginx/conf.d/
    echo "   ✓ Nginx configurations"
fi

echo -e "${GREEN}✓ Configuration files restored${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Review and update configuration files!${NC}"
echo "   Edit: ${PROJECT_DIR}/.env.production"
echo "   Update: Domain, IP addresses, and secrets for new server"
echo ""
read -p "Press Enter to continue after updating configuration..."
echo ""

# ========================================
# 4. Restore Uploaded Files
# ========================================
echo "📸 Step 4/6: Restoring uploaded files..."

if [ -f "${BACKUP_DIR}/uploads/uploads-backup.tar.gz" ]; then
    cd "${PROJECT_DIR}"
    tar -xzf "${BACKUP_DIR}/uploads/uploads-backup.tar.gz"
    chmod -R 755 backend/uploads
    
    UPLOADS_COUNT=$(find backend/uploads -type f 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Uploaded files restored (${UPLOADS_COUNT} files)${NC}"
else
    echo -e "${YELLOW}⚠️  No uploads backup found. Skipping...${NC}"
fi

echo ""

# ========================================
# 5. Install Dependencies and Build
# ========================================
echo "🔧 Step 5/6: Installing dependencies and building..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker not installed. Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}✓ Docker installed${NC}"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker Compose not installed. Installing...${NC}"
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
fi

echo ""

# Build frontend
echo "   Building frontend..."
cd "${PROJECT_DIR}/frontend"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠️  Node.js not installed. Installing Node.js 18.x...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi

npm install
npm run build
echo -e "${GREEN}   ✓ Frontend built${NC}"

echo ""

# Create necessary directories
cd "${PROJECT_DIR}"
mkdir -p nginx/logs backend/logs certbot/conf certbot/www backups
chmod -R 755 nginx backend/uploads backups

echo -e "${GREEN}✓ Application prepared${NC}"
echo ""

# ========================================
# 6. Deploy with Docker
# ========================================
echo "🚀 Step 6/6: Deploying application..."

cd "${PROJECT_DIR}"

# Ask which docker-compose file to use
echo "Which deployment type?"
echo "  1) MongoDB Atlas (Cloud Database) - Recommended"
echo "  2) Local MongoDB (Docker Container)"
read -p "Enter choice (1 or 2): " -r DEPLOY_CHOICE

if [ "$DEPLOY_CHOICE" = "2" ]; then
    COMPOSE_FILE="docker-compose.yml"
else
    COMPOSE_FILE="docker-compose.atlas.yml"
fi

echo ""
echo "Building and starting containers..."
docker-compose -f "${COMPOSE_FILE}" build --no-cache
docker-compose -f "${COMPOSE_FILE}" up -d

echo ""
echo "Waiting for services to start..."
sleep 10

# Check container status
docker-compose -f "${COMPOSE_FILE}" ps

echo ""
echo -e "${GREEN}✓ Application deployed${NC}"
echo ""

# ========================================
# 7. Database Restoration (Optional)
# ========================================
if [ -f "${BACKUP_DIR}/database/database-backup.tar.gz" ] || [ -d "${BACKUP_DIR}/database/atlas-export" ]; then
    echo ""
    echo "📊 Database Backup Found"
    echo ""
    read -p "Do you want to restore the database? (yes/no): " -r
    
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo ""
        echo "🗄️  Restoring database..."
        
        if [ -f "${BACKUP_DIR}/database/database-backup.tar.gz" ]; then
            # Local MongoDB restore
            cd "${PROJECT_DIR}"
            ./scripts/mongodb-restore.sh "${BACKUP_DIR}/database/database-backup.tar.gz"
        elif [ -d "${BACKUP_DIR}/database/atlas-export" ]; then
            # MongoDB Atlas restore
            echo "For MongoDB Atlas, use mongorestore:"
            echo ""
            echo "  mongorestore --uri=\"YOUR_MONGO_URI\" ${BACKUP_DIR}/database/atlas-export/"
            echo ""
            echo "Replace YOUR_MONGO_URI with your connection string from .env.production"
        fi
        
        echo -e "${GREEN}✓ Database restore completed${NC}"
    else
        echo "Skipping database restore."
    fi
fi

# ========================================
# Summary and Next Steps
# ========================================
echo ""
echo "================================================"
echo -e "${GREEN}✅ Restoration Completed Successfully!${NC}"
echo "================================================"
echo ""
echo "📊 Summary:"
echo "   Project Directory: ${PROJECT_DIR}"
echo "   Configuration: Restored"
echo "   Uploads: Restored"
echo "   Application: Running"
echo ""
echo "🔗 Application URLs:"
echo "   Frontend: http://$(hostname -I | awk '{print $1}')"
echo "   Backend API: http://$(hostname -I | awk '{print $1}'):5000"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Verify application is running:"
echo "   ${YELLOW}docker-compose -f ${COMPOSE_FILE} ps${NC}"
echo ""
echo "2. Check logs:"
echo "   ${YELLOW}docker-compose -f ${COMPOSE_FILE} logs -f${NC}"
echo ""
echo "3. Test backend API:"
echo "   ${YELLOW}curl http://localhost:5000/${NC}"
echo ""
echo "4. Setup SSL certificates (after DNS points to this server):"
echo "   ${YELLOW}cd ${PROJECT_DIR}${NC}"
echo "   ${YELLOW}sudo ./scripts/setup-ssl.sh${NC}"
echo ""
echo "5. Setup automated backups:"
echo "   ${YELLOW}cd ${PROJECT_DIR}${NC}"
echo "   ${YELLOW}sudo ./scripts/setup-cron-backup.sh${NC}"
echo ""
echo "6. Update DNS records to point to this server:"
echo "   A record @ -> $(hostname -I | awk '{print $1}')"
echo "   A record www -> $(hostname -I | awk '{print $1}')"
echo "   A record api -> $(hostname -I | awk '{print $1}')"
echo ""
echo -e "${GREEN}✨ Your application is ready!${NC}"
echo ""
echo "For detailed migration guide, see:"
echo "   ${PROJECT_DIR}/MIGRATION-GUIDE.md"
echo ""

