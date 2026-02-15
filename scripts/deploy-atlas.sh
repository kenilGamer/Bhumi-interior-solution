#!/bin/bash
# Production Deployment Script for Bhumi Interior Solution (MongoDB Atlas Version)
# This script handles deployment when using MongoDB Atlas cloud database

set -e

echo "🚀 Bhumi Interior Solution - Production Deployment (MongoDB Atlas)"
echo "=================================================================="
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

# Validate MongoDB URI
if [ -z "${MONGO_URI}" ]; then
    echo -e "${RED}❌ Error: MONGO_URI not set in .env.production${NC}"
    exit 1
fi

if [[ ! "${MONGO_URI}" =~ ^mongodb\+srv:// ]]; then
    echo -e "${YELLOW}⚠️  Warning: MONGO_URI doesn't look like a MongoDB Atlas connection string${NC}"
    read -p "Continue anyway? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        exit 1
    fi
fi

echo "🔧 Configuration:"
echo "  Domain: ${DOMAIN}"
echo "  API Subdomain: ${API_SUBDOMAIN}"
echo "  MongoDB: MongoDB Atlas (Cloud)"
echo "  Database: $(echo ${MONGO_URI} | grep -oP '/\K[^?]+')"
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

# Step 4: Build frontend
echo "🏗️  Step 4: Building frontend..."
cd frontend
if [ ! -d "node_modules" ]; then
    npm install
fi

# Create production .env for frontend
cat > .env.production << EOF
VITE_API_URL=https://${API_SUBDOMAIN}
VITE_APP_NAME=Bhumi Interior Solution
VITE_APP_VERSION=1.0.0
VITE_NODE_ENV=production
EOF

npm run build
cd ..
echo -e "${GREEN}✅ Frontend built successfully${NC}"
echo ""

# Step 5: Build and start containers
echo "🏗️  Step 5: Building and starting containers..."

# Use initial nginx config (without SSL)
if [ -f "nginx/conf.d/bhumi-interior.conf" ]; then
    mv nginx/conf.d/bhumi-interior.conf nginx/conf.d/bhumi-interior.conf.ssl
fi
cp nginx/conf.d/bhumi-interior-initial.conf nginx/conf.d/default.conf

# Build and start containers using Atlas compose file
docker-compose -f docker-compose.atlas.yml down 2>/dev/null || true
docker-compose -f docker-compose.atlas.yml build --no-cache
docker-compose -f docker-compose.atlas.yml up -d backend nginx

echo -e "${YELLOW}⏳ Waiting for services to start (30 seconds)...${NC}"
sleep 30

# Check if services are running
if ! docker ps | grep -q "bhumi-interior-backend"; then
    echo -e "${RED}❌ Backend container failed to start${NC}"
    docker-compose -f docker-compose.atlas.yml logs backend
    exit 1
fi

if ! docker ps | grep -q "bhumi-interior-nginx"; then
    echo -e "${RED}❌ Nginx container failed to start${NC}"
    docker-compose -f docker-compose.atlas.yml logs nginx
    exit 1
fi

echo -e "${GREEN}✅ Containers started successfully${NC}"
echo ""

# Test MongoDB connection
echo "🔍 Testing MongoDB Atlas connection..."
if docker exec bhumi-interior-backend node -e "const mongoose = require('mongoose'); mongoose.connect('${MONGO_URI}').then(() => { console.log('Connected'); process.exit(0); }).catch(() => process.exit(1));" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MongoDB Atlas connection successful${NC}"
else
    echo -e "${YELLOW}⚠️  Could not verify MongoDB connection (this is normal if mongoose isn't in package.json)${NC}"
fi
echo ""

# Step 6: Display next steps
echo "✨ Deployment Complete!"
echo ""
echo "📋 Next Steps:"
echo "  1. Setup SSL certificates:"
echo "     sudo ./scripts/setup-ssl.sh"
echo ""
echo "  2. Create admin user:"
echo "     curl -X POST http://${DOMAIN}/register \\"
echo "       -H 'Content-Type: application/json' \\"
echo "       -d '{\"name\":\"Admin User\",\"email\":\"admin@${DOMAIN}\",\"phone\":\"+91 92281 04285\",\"password\":\"YourSecurePassword\",\"role\":\"admin\"}'"
echo ""
echo "🌐 Your site should be accessible at:"
echo "  Main: http://${DOMAIN}"
echo "  API: http://${API_SUBDOMAIN}"
echo ""
echo "⚠️  Note: HTTPS will be available after SSL setup"
echo ""
echo "💡 To manage containers:"
echo "  View logs: docker-compose -f docker-compose.atlas.yml logs -f"
echo "  Stop: docker-compose -f docker-compose.atlas.yml down"
echo "  Restart: docker-compose -f docker-compose.atlas.yml restart"
echo ""
