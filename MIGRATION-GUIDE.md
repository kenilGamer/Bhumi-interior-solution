# 🚀 Complete Migration Guide - Bhumi Interior Solution

This guide will help you migrate your React.js and Node.js application to a new hosting provider with zero downtime.

---

## 📋 Table of Contents

1. [Pre-Migration Checklist](#pre-migration-checklist)
2. [Backup Your Current System](#backup-your-current-system)
3. [Prepare New Hosting Provider](#prepare-new-hosting-provider)
4. [Deploy to New Server](#deploy-to-new-server)
5. [Verify Deployment](#verify-deployment)
6. [DNS Migration](#dns-migration)
7. [Post-Migration Steps](#post-migration-steps)
8. [Rollback Plan](#rollback-plan)

---

## 🎯 Pre-Migration Checklist

### Information You'll Need

- [ ] **Current Server Access**: SSH credentials for current server
- [ ] **New Server Details**: IP address, SSH credentials
- [ ] **Domain Registrar Access**: To update DNS records
- [ ] **MongoDB Atlas Access**: If using cloud database
- [ ] **Email Credentials**: Gmail app password for notifications
- [ ] **SSL Certificate Email**: For Let's Encrypt certificates

### Required Server Specifications (Minimum)

- **CPU**: 2 cores
- **RAM**: 4GB (2GB minimum)
- **Storage**: 20GB SSD
- **OS**: Ubuntu 20.04+ or Debian 11+
- **Network**: Static IP address

### Estimated Migration Time

- **Backup**: 10-20 minutes
- **Setup New Server**: 30-60 minutes
- **Deployment**: 15-30 minutes
- **DNS Propagation**: 5 minutes - 48 hours
- **Total**: 1-3 hours (excluding DNS propagation)

---

## 💾 Backup Your Current System

### Option A: Automated Complete Backup (Recommended)

We've created an automated script that backs up everything:

```bash
# On your current server
cd /var/www/bhumi-interior

# Make the script executable
chmod +x scripts/complete-backup.sh

# Run complete backup
sudo ./scripts/complete-backup.sh

# This creates:
# - Database backup (MongoDB dump)
# - All uploaded files
# - Environment configurations
# - Source code
# - Docker configurations
```

**Backup Location**: `/var/backups/bhumi-interior/migration-YYYYMMDD_HHMMSS/`

### Option B: Manual Backup Steps

If you prefer manual control:

#### 1. Backup Database

```bash
# For MongoDB Atlas (Cloud)
# Atlas handles backups automatically, but you can export:
mongodump --uri="mongodb+srv://username:password@cluster.mongodb.net/bhumi-interior" --out=/tmp/db-backup

# For Local MongoDB (Docker)
cd /var/www/bhumi-interior
./scripts/mongodb-backup.sh
```

#### 2. Backup Uploaded Files

```bash
# Backup all uploaded files
cd /var/www/bhumi-interior
tar -czf /tmp/uploads-backup.tar.gz backend/uploads/

# Check backup size
ls -lh /tmp/uploads-backup.tar.gz
```

#### 3. Backup Environment Files

```bash
# Backup all environment configurations
cd /var/www/bhumi-interior
tar -czf /tmp/env-backup.tar.gz \
    .env.production \
    frontend/.env.production \
    backend/.env \
    nginx/conf.d/ \
    docker-compose.yml \
    docker-compose.atlas.yml
```

#### 4. Backup Source Code

```bash
# Create complete project backup
cd /var/www
tar -czf /tmp/bhumi-interior-source.tar.gz \
    --exclude='bhumi-interior/node_modules' \
    --exclude='bhumi-interior/backend/node_modules' \
    --exclude='bhumi-interior/frontend/node_modules' \
    --exclude='bhumi-interior/frontend/dist' \
    bhumi-interior/
```

#### 5. Download Backups to Your Local Machine

```bash
# From your local machine, download all backups
scp root@YOUR_CURRENT_SERVER_IP:/var/backups/bhumi-interior/migration-*/* ./migration-backup/

# Or download individual backups
scp root@YOUR_CURRENT_SERVER_IP:/tmp/db-backup.tar.gz ./
scp root@YOUR_CURRENT_SERVER_IP:/tmp/uploads-backup.tar.gz ./
scp root@YOUR_CURRENT_SERVER_IP:/tmp/env-backup.tar.gz ./
scp root@YOUR_CURRENT_SERVER_IP:/tmp/bhumi-interior-source.tar.gz ./
```

### Verify Backups

```bash
# Check all backup files exist and are not empty
ls -lh ./migration-backup/
# or
ls -lh /tmp/*backup.tar.gz

# Test extraction
mkdir -p /tmp/test-restore
tar -tzf /tmp/db-backup.tar.gz | head -10  # List contents
```

---

## 🖥️ Prepare New Hosting Provider

### 1. Choose Your Hosting Provider

Popular options:
- **DigitalOcean**: $12-24/month (Droplet)
- **AWS**: EC2 t3.small (~$15/month)
- **Linode**: $12-24/month
- **Vultr**: $12-24/month
- **Hetzner**: €4-15/month (Europe)
- **Google Cloud**: Compute Engine (~$15/month)

### 2. Create New Server Instance

1. **Create server** with Ubuntu 20.04 or 22.04 LTS
2. **Select region** closest to your users
3. **Add SSH key** for secure access
4. **Note the IP address** (e.g., 203.0.113.45)

### 3. Initial Server Setup

```bash
# Connect to new server
ssh root@NEW_SERVER_IP

# Update system
apt update && apt upgrade -y

# Install basic tools
apt install -y curl git wget nano ufw htop net-tools

# Setup firewall
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable

# Create swap file (if RAM < 4GB)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Verify
free -h
```

### 4. Install Docker & Docker Compose

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Verify installation
docker --version
docker-compose --version
```

---

## 🚢 Deploy to New Server

### Option A: Automated Deployment with Migration Script

```bash
# On new server, create project directory
mkdir -p /var/www/bhumi-interior
cd /var/www/bhumi-interior

# Upload migration backup from your local machine
# From local machine:
scp -r ./migration-backup/* root@NEW_SERVER_IP:/var/www/bhumi-interior/

# On new server, extract and deploy
cd /var/www/bhumi-interior
tar -xzf source-code.tar.gz
chmod +x scripts/restore-from-backup.sh
sudo ./scripts/restore-from-backup.sh /var/www/bhumi-interior/
```

### Option B: Manual Deployment

#### 1. Transfer Project Files

```bash
# From your local machine, upload to new server
scp -r /var/www/bhumi-interior root@NEW_SERVER_IP:/var/www/

# Or clone from Git repository
ssh root@NEW_SERVER_IP
cd /var/www
git clone https://github.com/kenilGamer/Bhumi-interior-solution.git bhumi-interior
cd bhumi-interior
```

#### 2. Upload Backup Files

```bash
# From local machine, upload backups to new server
scp migration-backup/* root@NEW_SERVER_IP:/var/www/bhumi-interior/backups/
```

#### 3. Configure Environment

```bash
# On new server
cd /var/www/bhumi-interior

# Create production environment file
nano .env.production
```

**Update the following values:**

```bash
# Domain Configuration (use NEW server IP initially)
DOMAIN=bhumiinteriorsolution.in
API_SUBDOMAIN=api.bhumiinteriorsolution.in
WWW_DOMAIN=www.bhumiinteriorsolution.in

# MongoDB Configuration (use MongoDB Atlas)
MONGO_URI=mongodb+srv://kenilk677:KgbYiGyRpp7HS4cB@cluster0.lziadv4.mongodb.net/bhumi-interior?retryWrites=true&w=majority&appName=Cluster0

# JWT Secret (MUST change in production!)
JWT_SECRET=<generate-new-secret-with-openssl-rand-hex-32>
JWT_EXPIRES_IN=7d

# Email Configuration
EMAIL_USER=bhumiinteriorsolution@gmail.com
EMAIL_PASS=<your-gmail-app-password>
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587

# SSL Configuration
SSL_EMAIL=bhumiinteriorsolution@gmail.com

# Node Environment
NODE_ENV=production
```

#### 4. Restore Uploaded Files

```bash
# Extract uploaded files backup
cd /var/www/bhumi-interior
mkdir -p backend/uploads
tar -xzf backups/uploads-backup.tar.gz -C backend/
chmod -R 755 backend/uploads
```

#### 5. Build Frontend

```bash
cd /var/www/bhumi-interior/frontend

# Create frontend environment
cat > .env.production << EOF
VITE_API_URL=https://api.bhumiinteriorsolution.in
VITE_APP_NAME=Bhumi Interior Solution
VITE_APP_VERSION=1.0.0
VITE_NODE_ENV=production
EOF

# Install dependencies and build
npm install
npm run build

# Verify build
ls -la dist/
```

#### 6. Deploy with Docker

```bash
cd /var/www/bhumi-interior

# Create necessary directories
mkdir -p nginx/conf.d nginx/logs backend/logs certbot/conf certbot/www backups

# Deploy using Docker Compose (with MongoDB Atlas)
docker-compose -f docker-compose.atlas.yml build --no-cache
docker-compose -f docker-compose.atlas.yml up -d

# Check status
docker-compose -f docker-compose.atlas.yml ps

# View logs
docker-compose -f docker-compose.atlas.yml logs -f
```

#### 7. Restore Database (if not using MongoDB Atlas)

```bash
# If you have a database backup and want to restore it
cd /var/www/bhumi-interior

# Extract database backup
tar -xzf backups/database-backup.tar.gz -C backups/

# Restore to MongoDB Atlas using mongorestore
mongorestore --uri="mongodb+srv://username:password@cluster.mongodb.net/bhumi-interior" backups/db-backup/

# Or if using local MongoDB in Docker
./scripts/mongodb-restore.sh backups/database-backup.tar.gz
```

---

## ✅ Verify Deployment

### 1. Test Backend API

```bash
# On new server, test backend is running
curl http://localhost:5000/
# Should return backend response

# Check from outside
curl http://NEW_SERVER_IP:5000/
```

### 2. Test Frontend

```bash
# Test frontend is accessible
curl http://NEW_SERVER_IP/
# Should return HTML content

# Check in browser
# Open: http://NEW_SERVER_IP
```

### 3. Test Database Connection

```bash
# Test MongoDB connection from backend container
docker exec bhumi-interior-backend node -e "const mongoose = require('mongoose'); mongoose.connect(process.env.MONGO_URI).then(() => console.log('✅ Connected')).catch(err => console.log('❌ Error:', err.message))"
```

### 4. Test File Uploads

1. Open browser: `http://NEW_SERVER_IP`
2. Login with admin credentials
3. Try uploading an image to gallery
4. Verify image appears and is accessible

### 5. Check Docker Containers

```bash
# All containers should be running
docker ps

# Check logs for errors
docker-compose -f docker-compose.atlas.yml logs --tail=50

# Check resource usage
docker stats --no-stream
```

---

## 🌐 DNS Migration

### Strategy: Zero-Downtime Migration

We'll use a gradual DNS migration to ensure zero downtime.

### Step 1: Lower TTL (Time To Live) - 24-48 Hours Before

```bash
# Login to your domain registrar (GoDaddy, Namecheap, etc.)
# Lower TTL to 300 seconds (5 minutes) for these records:
# - A record for @
# - A record for www
# - A record for api

# Wait 24-48 hours for this to propagate
```

### Step 2: Add SSL Certificates to New Server

**IMPORTANT**: Do this BEFORE updating DNS!

```bash
# On new server
cd /var/www/bhumi-interior

# First, temporarily update DNS or use certbot DNS challenge
# Option 1: Use staging certificates for testing
sudo ./scripts/setup-ssl.sh --staging

# Option 2: Get real certificates (only after DNS points to new server)
sudo ./scripts/setup-ssl.sh
```

### Step 3: Update DNS Records

Update these DNS records at your domain registrar:

```
Type    Name    Value                  TTL
A       @       NEW_SERVER_IP          300
A       www     NEW_SERVER_IP          300
A       api     NEW_SERVER_IP          300
```

### Step 4: Monitor DNS Propagation

```bash
# Check DNS from different locations
# From your local machine:
dig bhumiinteriorsolution.in
dig api.bhumiinteriorsolution.in

# Check globally
# Visit: https://www.whatsmydns.net/
# Enter: bhumiinteriorsolution.in
```

### Step 5: Verify New Server Receives Traffic

```bash
# On new server, monitor Nginx access logs
docker-compose -f docker-compose.atlas.yml logs -f nginx

# You should see incoming requests when DNS propagates
```

### Step 6: Keep Old Server Running

```bash
# Keep old server running for 24-48 hours
# This ensures users with cached DNS can still access the site

# After 48 hours, you can safely shut down old server
```

---

## 🎯 Post-Migration Steps

### 1. Setup SSL Certificates (Production)

```bash
# On new server (after DNS fully propagated)
cd /var/www/bhumi-interior
sudo ./scripts/setup-ssl.sh

# Verify HTTPS works
curl -I https://bhumiinteriorsolution.in
curl -I https://api.bhumiinteriorsolution.in
```

### 2. Setup Automated Backups

```bash
# Setup cron job for automated backups
cd /var/www/bhumi-interior
sudo ./scripts/setup-cron-backup.sh

# This creates daily backups at 2 AM
# Backups are stored in /var/backups/bhumi-interior/
```

### 3. Monitor Application

```bash
# Install monitoring tools
apt install -y htop iotop nethogs

# Check system resources
htop

# Monitor Docker containers
docker stats

# Setup log rotation
cat > /etc/logrotate.d/bhumi-interior << EOF
/var/www/bhumi-interior/backend/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 root root
    sharedscripts
}
EOF
```

### 4. Security Hardening

```bash
# Change SSH port (optional but recommended)
nano /etc/ssh/sshd_config
# Change: Port 22 -> Port 2222
# Save and exit
systemctl restart sshd
# Don't forget to update firewall!
ufw allow 2222/tcp

# Disable root login (create user first!)
useradd -m -s /bin/bash admin
usermod -aG sudo admin
passwd admin
# Then in /etc/ssh/sshd_config:
# PermitRootLogin no

# Install fail2ban
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Setup basic fail2ban for SSH
cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600
EOF
systemctl restart fail2ban
```

### 5. Test Everything

```bash
# Run comprehensive tests
# 1. Test website loads
curl -I https://bhumiinteriorsolution.in

# 2. Test API endpoints
curl https://api.bhumiinteriorsolution.in/

# 3. Test login
curl -X POST https://api.bhumiinteriorsolution.in/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"your-email","password":"your-password"}'

# 4. Test file upload (via browser)

# 5. Test password reset email

# 6. Check SSL certificate
openssl s_client -connect bhumiinteriorsolution.in:443 -servername bhumiinteriorsolution.in < /dev/null | grep -A 2 "Verify return code"
```

### 6. Update Documentation

```bash
# Update server IP in documentation
cd /var/www/bhumi-interior
nano DEPLOYMENT.md
# Update with new server IP and any changes
```

### 7. Notify Team/Users (Optional)

If you have users, consider:
- Sending email notification about successful migration
- Posting on social media
- Updating status page

---

## 🔄 Rollback Plan

If something goes wrong, here's how to rollback:

### Immediate Rollback (During DNS Migration)

```bash
# 1. Update DNS records back to old server IP
Type    Name    Value                  TTL
A       @       OLD_SERVER_IP          300
A       www     OLD_SERVER_IP          300
A       api     OLD_SERVER_IP          300

# 2. Wait 5-10 minutes for DNS to propagate
# 3. Old server should start receiving traffic again

# 4. Keep new server running for investigation
```

### Database Rollback

```bash
# If you need to restore old database state
# On old server, create current backup
./scripts/mongodb-backup.sh

# Transfer to new server
scp /var/backups/bhumi-interior/latest-backup.tar.gz root@NEW_SERVER_IP:/tmp/

# On new server, restore
cd /var/www/bhumi-interior
./scripts/mongodb-restore.sh /tmp/latest-backup.tar.gz
```

---

## 📊 Migration Checklist

### Before Migration

- [ ] Run complete backup on current server
- [ ] Download backups to local machine
- [ ] Verify all backups are valid
- [ ] Setup new server instance
- [ ] Install Docker and dependencies on new server
- [ ] Test new server connectivity

### During Migration

- [ ] Deploy application to new server
- [ ] Restore database (if needed)
- [ ] Restore uploaded files
- [ ] Build and test frontend
- [ ] Configure environment variables
- [ ] Start Docker containers
- [ ] Verify all services running
- [ ] Test application functionality

### DNS Migration

- [ ] Lower DNS TTL 24-48 hours before
- [ ] Setup SSL certificates on new server
- [ ] Update DNS records to new server IP
- [ ] Monitor DNS propagation
- [ ] Verify traffic reaching new server
- [ ] Test HTTPS connectivity

### After Migration

- [ ] Setup automated backups
- [ ] Configure monitoring
- [ ] Security hardening
- [ ] Update documentation
- [ ] Monitor for 24-48 hours
- [ ] Decommission old server
- [ ] Increase DNS TTL back to normal

---

## 🆘 Troubleshooting

### Issue: Docker containers won't start

```bash
# Check logs
docker-compose -f docker-compose.atlas.yml logs

# Common causes:
# 1. Port already in use
netstat -tlnp | grep -E '80|443|5000'

# 2. Insufficient memory
free -h

# 3. Environment variables missing
docker-compose -f docker-compose.atlas.yml config
```

### Issue: Database connection fails

```bash
# Test MongoDB Atlas connection
mongo "mongodb+srv://username:password@cluster.mongodb.net/bhumi-interior"

# Check MongoDB Atlas:
# 1. Network Access - whitelist new server IP
# 2. Database Access - verify credentials
# 3. Connection string in .env.production
```

### Issue: SSL certificate fails

```bash
# Verify DNS first
host bhumiinteriorsolution.in
# Should return new server IP

# Check port 80 is accessible
curl -I http://bhumiinteriorsolution.in

# Try manual certificate request
docker-compose -f docker-compose.atlas.yml run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email your@email.com \
  --agree-tos \
  --no-eff-email \
  -d bhumiinteriorsolution.in
```

### Issue: Application not accessible

```bash
# Check firewall
ufw status
# Ensure ports 80, 443 are allowed

# Check cloud provider security groups
# Ensure inbound rules allow HTTP (80) and HTTPS (443)

# Check Nginx is running
docker ps | grep nginx

# Check Nginx logs
docker logs bhumi-interior-nginx
```

---

## 📞 Support Resources

- **Project Repository**: https://github.com/kenilGamer/Bhumi-interior-solution
- **Docker Documentation**: https://docs.docker.com/
- **MongoDB Atlas Support**: https://docs.atlas.mongodb.com/
- **Let's Encrypt Documentation**: https://letsencrypt.org/docs/

---

## 📝 Additional Notes

### Cost Estimation

**Monthly Costs After Migration:**
- VPS/Server: $12-24/month
- Domain: $10-15/year
- MongoDB Atlas: Free (or $9-57/month for paid tiers)
- SSL Certificates: Free (Let's Encrypt)
- **Total**: ~$15-30/month

### Performance Optimization

After migration, consider:
1. **CDN**: CloudFlare for static assets
2. **Caching**: Redis for session/API caching
3. **Image Optimization**: Compress images before upload
4. **Database Indexing**: Review MongoDB indexes
5. **Monitoring**: Setup Uptime Robot or Pingdom

### Backup Strategy

Recommended backup schedule:
- **Daily**: Automated database backups (2 AM)
- **Weekly**: Full system backup
- **Monthly**: Long-term archive backup
- **Retention**: Keep 30 days of daily, 12 weeks of weekly

---

**Made with ❤️ for Bhumi Interior Solution**

*Last Updated: November 6, 2025*

