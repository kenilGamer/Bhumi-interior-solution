# 🚀 Bhumi Interior Solution - Production Deployment Guide

Complete guide for deploying **Bhumi Interior Solution** to production at **bhumiinteriorsolution.in**

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Server Setup](#server-setup)
3. [MongoDB Atlas Configuration](#mongodb-atlas-configuration)
4. [Environment Configuration](#environment-configuration)
5. [Deployment Steps](#deployment-steps)
6. [SSL Certificate Setup](#ssl-certificate-setup)
7. [Post-Deployment](#post-deployment)
8. [Maintenance & Monitoring](#maintenance--monitoring)
9. [Troubleshooting](#troubleshooting)

---

## 🔧 Prerequisites

### Required Services
- **VPS/Server**: Ubuntu 20.04+ or Debian 11+ (2GB RAM minimum, 4GB recommended)
- **Domain**: bhumiinteriorsolution.in (configured in DNS)
- **MongoDB Atlas**: Cloud MongoDB account
- **Email**: Gmail account for password reset emails

### Domain DNS Configuration
Configure these DNS records at your domain registrar:

```
Type    Name    Value                  TTL
A       @       YOUR_SERVER_IP         300
A       www     YOUR_SERVER_IP         300
A       api     YOUR_SERVER_IP         300
```

**Verify DNS** (wait 5-10 minutes after configuration):
```bash
host bhumiinteriorsolution.in
host www.bhumiinteriorsolution.in
host api.bhumiinteriorsolution.in
```

---

## 🖥️ Server Setup

### 1. Initial Server Configuration

```bash
# Connect to your server
ssh root@YOUR_SERVER_IP

# Update system
apt update && apt upgrade -y

# Install required packages
apt install -y curl git wget nano ufw

# Setup firewall
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable

# Create project directory
mkdir -p /var/www
cd /var/www
```

### 2. Clone Repository

```bash
# If repository is public
git clone https://github.com/kenilGamer/Bhumi-interior-solution.git bhumi-interior

# If repository is private
git clone https://<YOUR_GITHUB_TOKEN>@github.com/kenilGamer/Bhumi-interior-solution.git bhumi-interior

cd bhumi-interior
```

---

## 🗄️ MongoDB Atlas Configuration

### 1. Setup MongoDB Atlas

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create account or sign in
3. Create a new cluster (Free tier works for testing)
4. Click "Connect" → "Connect your application"
5. Copy the connection string

Your connection string:
```
mongodb+srv://kenilk677:KgbYiGyRpp7HS4cB@cluster0.lziadv4.mongodb.net/bhumi-interior?retryWrites=true&w=majority&appName=Cluster0
```

### 2. Configure Network Access

1. In MongoDB Atlas, go to **Network Access**
2. Click **Add IP Address**
3. Add your server's IP address or use `0.0.0.0/0` (all IPs - less secure but easier)

### 3. Create Database User

1. Go to **Database Access**
2. Verify your user `kenilk677` has read/write permissions
3. Note: Password is already in your connection string

---

## ⚙️ Environment Configuration

### 1. Create Production Environment File

```bash
cd /var/www/bhumi-interior

# Copy example and edit
cp env.production.example .env.production
nano .env.production
```

### 2. Configure .env.production

```bash
# Domain Configuration
DOMAIN=bhumiinteriorsolution.in
API_SUBDOMAIN=api.bhumiinteriorsolution.in
WWW_DOMAIN=www.bhumiinteriorsolution.in

# MongoDB Atlas Configuration
MONGO_URI=mongodb+srv://kenilk677:KgbYiGyRpp7HS4cB@cluster0.lziadv4.mongodb.net/bhumi-interior?retryWrites=true&w=majority&appName=Cluster0

# JWT Configuration (IMPORTANT: Change this to a random secure string!)
JWT_SECRET=CHANGE_THIS_TO_A_RANDOM_SECURE_STRING_AT_LEAST_32_CHARACTERS
JWT_EXPIRES_IN=7d

# Email Configuration (for password reset)
EMAIL_USER=bhumiinteriorsolution@gmail.com
EMAIL_PASS=your-gmail-app-password
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587

# SSL Configuration
SSL_EMAIL=bhumiinteriorsolution@gmail.com

# Node Environment
NODE_ENV=production
```

### 3. Generate Secure JWT Secret

```bash
# Generate a random 64-character string
openssl rand -hex 32
```

Copy this value and use it for `JWT_SECRET` in your `.env.production` file.

### 4. Setup Gmail App Password

1. Go to [Google Account](https://myaccount.google.com/)
2. Security → 2-Step Verification (enable if not already)
3. Security → App passwords
4. Generate new app password for "Mail"
5. Copy the 16-character password
6. Use this for `EMAIL_PASS` in `.env.production`

---

## 🚀 Deployment Steps

### Option A: Automated Deployment (Recommended)

```bash
cd /var/www/bhumi-interior

# Make scripts executable (already done)
chmod +x scripts/*.sh

# Run deployment script
sudo ./scripts/deploy-atlas.sh
```

This script will:
- ✅ Install Docker and Docker Compose
- ✅ Build frontend application
- ✅ Build and start Docker containers
- ✅ Configure Nginx reverse proxy
- ✅ Test MongoDB connection

### Option B: Manual Deployment

If you prefer manual control:

#### 1. Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start Docker
systemctl enable docker
systemctl start docker
```

#### 2. Build Frontend

```bash
cd /var/www/bhumi-interior/frontend

# Install dependencies
npm install

# Create production .env
cat > .env.production << EOF
VITE_API_URL=https://api.bhumiinteriorsolution.in
VITE_APP_NAME=Bhumi Interior Solution
VITE_APP_VERSION=1.0.0
VITE_NODE_ENV=production
EOF

# Build
npm run build

cd ..
```

#### 3. Create Directories

```bash
mkdir -p nginx/conf.d nginx/logs backend/logs backend/uploads certbot/conf certbot/www backups
chmod 755 nginx backend/uploads backups
```

#### 4. Setup Initial Nginx Config

```bash
# Use HTTP-only config first (before SSL)
cp nginx/conf.d/bhumi-interior-initial.conf nginx/conf.d/default.conf
```

#### 5. Start Containers

```bash
# Build and start
docker-compose -f docker-compose.atlas.yml build --no-cache
docker-compose -f docker-compose.atlas.yml up -d

# Check status
docker-compose -f docker-compose.atlas.yml ps

# View logs
docker-compose -f docker-compose.atlas.yml logs -f
```

---

## 🔒 SSL Certificate Setup

### 1. Verify Site is Accessible

Before setting up SSL, ensure your site loads over HTTP:

```bash
curl -I http://bhumiinteriorsolution.in
curl -I http://api.bhumiinteriorsolution.in
```

You should see `200 OK` or `301/302` redirect responses.

### 2. Run SSL Setup Script

```bash
cd /var/www/bhumi-interior
sudo ./scripts/setup-ssl.sh
```

This script will:
- ✅ Check DNS records
- ✅ Request SSL certificates from Let's Encrypt
- ✅ Configure Nginx for HTTPS
- ✅ Setup auto-renewal

### 3. Verify HTTPS

```bash
# Test HTTPS
curl -I https://bhumiinteriorsolution.in
curl -I https://api.bhumiinteriorsolution.in

# Check SSL certificate
openssl s_client -connect bhumiinteriorsolution.in:443 -servername bhumiinteriorsolution.in < /dev/null
```

### 4. Manual SSL Setup (if script fails)

```bash
# Stop certbot if running
docker-compose -f docker-compose.atlas.yml stop certbot

# Get certificate
docker-compose -f docker-compose.atlas.yml run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email bhumiinteriorsolution@gmail.com \
  --agree-tos \
  --no-eff-email \
  -d bhumiinteriorsolution.in \
  -d www.bhumiinteriorsolution.in \
  -d api.bhumiinteriorsolution.in

# Switch to SSL config
rm nginx/conf.d/default.conf
cp nginx/conf.d/bhumi-interior.conf nginx/conf.d/default.conf

# Restart nginx
docker-compose -f docker-compose.atlas.yml restart nginx

# Start certbot for auto-renewal
docker-compose -f docker-compose.atlas.yml up -d certbot
```

---

## 🎯 Post-Deployment

### 1. Create Admin User

```bash
curl -X POST https://bhumiinteriorsolution.in/api/register \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Admin User",
    "email": "admin@bhumiinteriorsolution.in",
    "phone": "+91 92281 04285",
    "password": "YourSecurePassword123!",
    "role": "admin"
  }'
```

**Save your admin credentials securely!**

### 2. Test Login

```bash
curl -X POST https://api.bhumiinteriorsolution.in/login \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "admin@bhumiinteriorsolution.in",
    "password": "YourSecurePassword123!"
  }'
```

You should receive a JWT token in the response.

### 3. Test File Upload

1. Open browser: https://bhumiinteriorsolution.in
2. Login with admin credentials
3. Go to dashboard
4. Try uploading an image to gallery

### 4. Setup Monitoring (Optional)

```bash
# Install monitoring tools
apt install -y htop iotop nethogs

# Check system resources
htop

# Monitor Docker containers
docker stats

# Monitor logs
docker-compose -f docker-compose.atlas.yml logs -f --tail=50
```

---

## 🔄 Maintenance & Monitoring

### Container Management

```bash
# View running containers
docker ps

# View logs
docker-compose -f docker-compose.atlas.yml logs -f

# View specific service logs
docker-compose -f docker-compose.atlas.yml logs -f backend
docker-compose -f docker-compose.atlas.yml logs -f nginx

# Restart services
docker-compose -f docker-compose.atlas.yml restart
docker-compose -f docker-compose.atlas.yml restart backend
docker-compose -f docker-compose.atlas.yml restart nginx

# Stop all services
docker-compose -f docker-compose.atlas.yml down

# Start all services
docker-compose -f docker-compose.atlas.yml up -d

# Rebuild and restart
docker-compose -f docker-compose.atlas.yml up -d --build
```

### Update Application

```bash
cd /var/www/bhumi-interior

# Pull latest changes
git pull

# Rebuild frontend
cd frontend
npm install
npm run build
cd ..

# Rebuild and restart backend
docker-compose -f docker-compose.atlas.yml build backend
docker-compose -f docker-compose.atlas.yml up -d backend

# Restart nginx
docker-compose -f docker-compose.atlas.yml restart nginx
```

### Check Application Health

```bash
# Check backend health
curl https://api.bhumiinteriorsolution.in/

# Check frontend
curl https://bhumiinteriorsolution.in/

# Check MongoDB connection (from inside container)
docker exec bhumi-interior-backend node -e "const mongoose = require('mongoose'); mongoose.connect(process.env.MONGO_URI).then(() => console.log('✅ Connected')).catch(err => console.log('❌ Error:', err))"
```

### SSL Certificate Renewal

Certificates auto-renew, but you can manually renew:

```bash
# Manual renewal
docker-compose -f docker-compose.atlas.yml run --rm certbot renew

# Check certificate expiry
echo | openssl s_client -servername bhumiinteriorsolution.in -connect bhumiinteriorsolution.in:443 2>/dev/null | openssl x509 -noout -dates
```

### Backup (MongoDB Atlas handles this, but for local files)

```bash
# Backup uploaded files
tar -czf /var/backups/bhumi-interior-uploads-$(date +%Y%m%d).tar.gz /var/www/bhumi-interior/backend/uploads

# List backups
ls -lh /var/backups/
```

---

## 🐛 Troubleshooting

### Issue: Backend Container Won't Start

```bash
# Check logs
docker-compose -f docker-compose.atlas.yml logs backend

# Common issues:
# 1. MongoDB connection string incorrect
# 2. Missing environment variables
# 3. Port 5000 already in use

# Fix port conflict
netstat -tlnp | grep 5000
kill <PID>

# Restart
docker-compose -f docker-compose.atlas.yml restart backend
```

### Issue: Nginx Shows 502 Bad Gateway

```bash
# Check backend is running
docker ps | grep backend

# Check backend health
docker exec bhumi-interior-backend curl http://localhost:5000/

# Check nginx logs
docker-compose -f docker-compose.atlas.yml logs nginx

# Restart services
docker-compose -f docker-compose.atlas.yml restart
```

### Issue: MongoDB Connection Failed

```bash
# Test connection from host
mongo "mongodb+srv://kenilk677:KgbYiGyRpp7HS4cB@cluster0.lziadv4.mongodb.net/bhumi-interior"

# Check MongoDB Atlas:
# 1. Network Access: Is your server IP whitelisted?
# 2. Database Access: Is user active?
# 3. Connection string: Is it correct in .env.production?

# Test from container
docker exec bhumi-interior-backend env | grep MONGO_URI
```

### Issue: SSL Certificate Failed

```bash
# Check DNS is working
host bhumiinteriorsolution.in

# Check port 80 is accessible
curl -I http://bhumiinteriorsolution.in/.well-known/acme-challenge/test

# Check certbot logs
docker-compose -f docker-compose.atlas.yml logs certbot

# Try manual certificate request
docker-compose -f docker-compose.atlas.yml run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email bhumiinteriorsolution@gmail.com \
  --agree-tos \
  --no-eff-email \
  --force-renewal \
  -d bhumiinteriorsolution.in \
  -d www.bhumiinteriorsolution.in \
  -d api.bhumiinteriorsolution.in
```

### Issue: File Upload Not Working

```bash
# Check uploads directory permissions
ls -la /var/www/bhumi-interior/backend/uploads
chmod 755 /var/www/bhumi-interior/backend/uploads

# Check disk space
df -h

# Check backend logs
docker-compose -f docker-compose.atlas.yml logs backend | grep -i upload
```

### Issue: Frontend Shows Blank Page

```bash
# Check if frontend is built
ls -la /var/www/bhumi-interior/frontend/dist

# Rebuild frontend
cd /var/www/bhumi-interior/frontend
npm run build

# Check nginx is serving files
docker exec bhumi-interior-nginx ls -la /usr/share/nginx/html

# Check browser console for errors (F12)
```

### Common Commands

```bash
# View all logs
docker-compose -f docker-compose.atlas.yml logs -f

# Restart everything
docker-compose -f docker-compose.atlas.yml restart

# Stop everything
docker-compose -f docker-compose.atlas.yml down

# Start fresh
docker-compose -f docker-compose.atlas.yml down
docker-compose -f docker-compose.atlas.yml build --no-cache
docker-compose -f docker-compose.atlas.yml up -d

# Check disk space
df -h

# Check memory
free -h

# Check running processes
htop
```

---

## 📞 Support & Contact

- **Email**: bhumiinteriorsolution@gmail.com
- **Phone**: +91 92281 04285
- **GitHub**: [Bhumi Interior Solution](https://github.com/kenilGamer/Bhumi-interior-solution)

---

## 🔐 Security Checklist

- [ ] Changed default JWT_SECRET
- [ ] Used strong admin password
- [ ] Gmail app password configured
- [ ] Firewall configured (UFW)
- [ ] SSL certificates installed
- [ ] MongoDB Atlas network access restricted
- [ ] Regular backups configured
- [ ] Server kept updated

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [MongoDB Atlas Documentation](https://docs.atlas.mongodb.com/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

---

**Made with ❤️ by Bhumi Interior Solution Team**

*Last Updated: October 8, 2025*
