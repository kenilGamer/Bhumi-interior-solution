#!/bin/bash
# SSL Certificate Setup Script using Let's Encrypt (Certbot)
# This script obtains and configures SSL certificates for your domain

set -e

echo "🔒 SSL Certificate Setup - Let's Encrypt"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root or with sudo${NC}"
   exit 1
fi

# Change to project directory
PROJECT_DIR="/var/www/bhumi-interior"
cd "${PROJECT_DIR}"

# Load environment variables
if [ ! -f ".env.production" ]; then
    echo -e "${RED}❌ Error: .env.production file not found${NC}"
    exit 1
fi

export $(cat .env.production | grep -v '^#' | xargs)

DOMAIN="${DOMAIN:-bhumiinteriorsolution.in}"
API_SUBDOMAIN="${API_SUBDOMAIN:-api.bhumiinteriorsolution.in}"
WWW_DOMAIN="${WWW_DOMAIN:-www.bhumiinteriorsolution.in}"
SSL_EMAIL="${SSL_EMAIL:-bhumiinteriorsolution@gmail.com}"

echo "📋 SSL Certificate Configuration:"
echo "  Main Domain: ${DOMAIN}"
echo "  WWW Domain: ${WWW_DOMAIN}"
echo "  API Subdomain: ${API_SUBDOMAIN}"
echo "  Email: ${SSL_EMAIL}"
echo ""

# Check if containers are running
if ! docker ps | grep -q "bhumi-interior-nginx"; then
    echo -e "${RED}❌ Nginx container is not running${NC}"
    echo "Please run ./scripts/deploy.sh first"
    exit 1
fi

# Check DNS records
echo "🔍 Checking DNS records..."
echo ""

check_dns() {
    local domain=$1
    echo -n "  Checking ${domain}... "
    if host "${domain}" > /dev/null 2>&1; then
        IP=$(host "${domain}" | grep "has address" | head -1 | awk '{print $4}')
        echo -e "${GREEN}✅ Resolves to ${IP}${NC}"
        return 0
    else
        echo -e "${RED}❌ Not found${NC}"
        return 1
    fi
}

DNS_OK=true
check_dns "${DOMAIN}" || DNS_OK=false
check_dns "${WWW_DOMAIN}" || DNS_OK=false
check_dns "${API_SUBDOMAIN}" || DNS_OK=false
echo ""

if [ "${DNS_OK}" = false ]; then
    echo -e "${YELLOW}⚠️  Warning: Some domains do not resolve properly${NC}"
    echo "Please ensure your DNS records are configured:"
    echo "  A record: ${DOMAIN} → Your server IP"
    echo "  A record: ${WWW_DOMAIN} → Your server IP"
    echo "  A record: ${API_SUBDOMAIN} → Your server IP"
    echo ""
    read -p "Continue anyway? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "❌ SSL setup cancelled"
        exit 1
    fi
fi

# Request SSL certificates
echo "📜 Requesting SSL certificates from Let's Encrypt..."
echo ""

# Stop certbot container if running
docker-compose stop certbot 2>/dev/null || true

# Request certificate for all domains
docker-compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email "${SSL_EMAIL}" \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d "${DOMAIN}" \
    -d "${WWW_DOMAIN}" \
    -d "${API_SUBDOMAIN}"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to obtain SSL certificates${NC}"
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Ensure your domains point to this server's IP"
    echo "  2. Check if port 80 is accessible from the internet"
    echo "  3. Check nginx logs: docker-compose logs nginx"
    exit 1
fi

echo -e "${GREEN}✅ SSL certificates obtained successfully${NC}"
echo ""

# Switch to SSL nginx configuration
echo "🔄 Switching to SSL-enabled Nginx configuration..."

if [ -f "nginx/conf.d/default.conf" ]; then
    rm nginx/conf.d/default.conf
fi

if [ -f "nginx/conf.d/bhumi-interior.conf.ssl" ]; then
    mv nginx/conf.d/bhumi-interior.conf.ssl nginx/conf.d/bhumi-interior.conf
fi

# Reload nginx
docker-compose restart nginx

echo -e "${GREEN}✅ Nginx reloaded with SSL configuration${NC}"
echo ""

# Start certbot for auto-renewal
docker-compose up -d certbot

echo "✨ SSL Setup Complete!"
echo ""
echo "🌐 Your site is now accessible via HTTPS:"
echo "  Main: https://${DOMAIN}"
echo "  WWW: https://${WWW_DOMAIN}"
echo "  API: https://${API_SUBDOMAIN}"
echo ""
echo "🔄 Certificates will auto-renew every 12 hours"
echo ""

# Test SSL configuration
echo "🧪 Testing SSL configuration..."
sleep 5

if curl -sfI "https://${DOMAIN}" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ HTTPS is working correctly!${NC}"
else
    echo -e "${YELLOW}⚠️  HTTPS test failed, but certificates are installed${NC}"
    echo "Please check nginx logs: docker-compose logs nginx"
fi

echo ""
echo "🔒 SSL Setup Complete!"
