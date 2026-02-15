#!/bin/bash
# Quick Deploy Script - Interactive deployment with minimal input

set -e

clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🏠 Bhumi Interior Solution - Quick Deployment             ║"
echo "║                                                              ║"
echo "║  This script will deploy your site in 5 minutes!            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root or with sudo${NC}"
   exit 1
fi

PROJECT_DIR="/var/www/bhumi-interior"

# Get user inputs
echo -e "${BLUE}📝 Please provide the following information:${NC}"
echo ""

read -p "Domain (press Enter for bhumiinteriorsolution.in): " DOMAIN
DOMAIN=${DOMAIN:-bhumiinteriorsolution.in}

read -p "Gmail address for notifications: " EMAIL_USER
read -sp "Gmail App Password: " EMAIL_PASS
echo ""

read -sp "Admin password (for dashboard login): " ADMIN_PASSWORD
echo ""

echo ""
echo -e "${GREEN}✓ Configuration received${NC}"
echo ""

# Generate JWT secret
JWT_SECRET=$(openssl rand -hex 32)

# Create .env.production
cat > "${PROJECT_DIR}/.env.production" << EOF
DOMAIN=${DOMAIN}
API_SUBDOMAIN=api.${DOMAIN}
WWW_DOMAIN=www.${DOMAIN}

MONGO_URI=mongodb+srv://kenilk677:KgbYiGyRpp7HS4cB@cluster0.lziadv4.mongodb.net/bhumi-interior?retryWrites=true&w=majority&appName=Cluster0

JWT_SECRET=${JWT_SECRET}
JWT_EXPIRES_IN=7d

EMAIL_USER=${EMAIL_USER}
EMAIL_PASS=${EMAIL_PASS}
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587

SSL_EMAIL=${EMAIL_USER}
NODE_ENV=production
EOF

echo -e "${GREEN}✓ Environment configured${NC}"
echo ""

# Run deployment
echo -e "${BLUE}🚀 Starting deployment...${NC}"
echo ""

cd "${PROJECT_DIR}"
chmod +x scripts/*.sh

# Deploy
./scripts/deploy-atlas.sh

echo ""
echo -e "${BLUE}🔒 Setting up SSL...${NC}"
echo ""

# Setup SSL
./scripts/setup-ssl.sh

echo ""
echo -e "${BLUE}👤 Creating admin user...${NC}"
echo ""

# Create admin user
sleep 5
ADMIN_RESPONSE=$(curl -s -X POST "https://${DOMAIN}/api/register" \
  -H 'Content-Type: application/json' \
  -d "{
    \"name\": \"Admin User\",
    \"email\": \"admin@${DOMAIN}\",
    \"phone\": \"+91 92281 04285\",
    \"password\": \"${ADMIN_PASSWORD}\",
    \"role\": \"admin\"
  }" || echo "Failed")

if [[ $ADMIN_RESPONSE == *"Failed"* ]]; then
    echo -e "${YELLOW}⚠️  Could not create admin user automatically${NC}"
    echo "You can create it manually later"
else
    echo -e "${GREEN}✓ Admin user created${NC}"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✨ Deployment Complete! 🎉                                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🌐 Your site is now live at:${NC}"
echo "   Main: https://${DOMAIN}"
echo "   Dashboard: https://${DOMAIN}/dashboard"
echo "   API: https://api.${DOMAIN}"
echo ""
echo -e "${GREEN}🔑 Admin Credentials:${NC}"
echo "   Email: admin@${DOMAIN}"
echo "   Password: ${ADMIN_PASSWORD}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Save these credentials securely!${NC}"
echo ""
echo -e "${BLUE}📋 Useful Commands:${NC}"
echo "   View logs: docker-compose -f docker-compose.atlas.yml logs -f"
echo "   Restart: docker-compose -f docker-compose.atlas.yml restart"
echo "   Stop: docker-compose -f docker-compose.atlas.yml down"
echo ""
echo -e "${GREEN}✨ Thank you for using Bhumi Interior Solution!${NC}"
echo ""
