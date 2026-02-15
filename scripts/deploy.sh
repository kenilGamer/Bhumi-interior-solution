#!/bin/bash
# Production Deployment Script for Bhumi Interior Solution
# This script handles the complete deployment process

set -e

echo "🚀 Bhumi Interior Solution - Production Deployment"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root or with sudo${NC}"
   exit 1
fi

# Change to project directory
PROJECT_DIR="/var/www/bhumi-interior"
cd "${PROJECT_DIR}"

echo "📁 Working directory: ${PROJECT_DIR}"
echo ""

# Check if .env.production exists
if [ ! -f ".env.production" ]; then
    echo -e "${RED}❌ Error: .env.production file not found${NC}"
    echo "Please create .env.production file with your configuration"
    echo "You can copy from env.production.example:"
    echo "  cp env.production.example .env.production"
    exit 1
fi

# Load environment variables
export $(cat .env.production | grep -v '^#' | xargs)

echo "🔧 Configuration:"
echo "  Domain: ${DOMAIN}"
echo "  API Subdomain: ${API_SUBDOMAIN}"
echo "  MongoDB Database: ${MONGO_DATABASE}"
echo ""

# Step 1: Update system packages
echo "📦 Step 1: Updating system packages..."
apt-get update -qq
echo -e "${GREEN}✅ System packages updated${NC}"
echo ""

# Step 2: Install Docker and Docker Compose if not installed
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}✅ Docker installed${NC}"
else
    echo -e "${GREEN}✅ Docker already installed${NC}"
fi

if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✅ Docker Compose already installed${NC}"
fi
echo ""

# Step 3: Create necessary directories
echo "📂 Step 3: Creating directories..."
mkdir -p nginx/conf.d nginx/logs backend/logs backend/uploads certbot/conf certbot/www backups
chmod 755 nginx backend/uploads backups
echo -e "${GREEN}✅ Directories created${NC}"
echo ""

# Step 4: Build and start containers (without SSL first)
echo "🏗️  Step 4: Building and starting containers..."

# Use initial nginx config (without SSL)
if [ -f "nginx/conf.d/bhumi-interior.conf" ]; then
    mv nginx/conf.d/bhumi-interior.conf nginx/conf.d/bhumi-interior.conf.ssl
fi
cp nginx/conf.d/bhumi-interior-initial.conf nginx/conf.d/default.conf

# Build and start containers
docker-compose down 2>/dev/null || true
docker-compose build --no-cache
docker-compose up -d mongodb backend nginx

echo -e "${YELLOW}⏳ Waiting for services to start (30 seconds)...${NC}"
sleep 30

# Check if services are running
if ! docker ps | grep -q "bhumi-interior-mongodb"; then
    echo -e "${RED}❌ MongoDB container failed to start${NC}"
    docker-compose logs mongodb
    exit 1
fi

if ! docker ps | grep -q "bhumi-interior-backend"; then
    echo -e "${RED}❌ Backend container failed to start${NC}"
    docker-compose logs backend
    exit 1
fi

if ! docker ps | grep -q "bhumi-interior-nginx"; then
    echo -e "${RED}❌ Nginx container failed to start${NC}"
    docker-compose logs nginx
    exit 1
fi

echo -e "${GREEN}✅ Containers started successfully${NC}"
echo ""

# Step 5: Display next steps
echo "✨ Deployment Complete!"
echo ""
echo "📋 Next Steps:"
echo "  1. Setup SSL certificates:"
echo "     sudo ./scripts/setup-ssl.sh"
echo ""
echo "  2. Create admin user:"
echo "     curl -X POST https://${DOMAIN}/api/register \\"
echo "       -H 'Content-Type: application/json' \\"
echo "       -d '{\"name\":\"Admin\",\"email\":\"admin@${DOMAIN}\",\"phone\":\"+91 92281 04285\",\"password\":\"YourSecurePassword\",\"role\":\"admin\"}'"
echo ""
echo "  3. Setup automatic backups:"
echo "     sudo ./scripts/setup-cron-backup.sh"
echo ""
echo "🌐 Your site should be accessible at:"
echo "  Main: http://${DOMAIN}"
echo "  API: http://${API_SUBDOMAIN}"
echo ""
echo "⚠️  Note: HTTPS will be available after SSL setup"
echo ""
