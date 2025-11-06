# 🚀 Quick Migration Guide - 5 Simple Steps

This is a simplified guide to migrate your Bhumi Interior Solution to a new hosting provider in just 5 steps.

---

## 📌 Overview

**Time Required**: 1-2 hours (excluding DNS propagation)  
**Difficulty**: Intermediate  
**Downtime**: Near-zero (with proper DNS management)

---

## ✅ Step 1: Backup Current Server (10 minutes)

On your **current server**:

```bash
# Connect to current server
ssh root@CURRENT_SERVER_IP

# Navigate to project directory
cd /var/www/bhumi-interior

# Run automated backup script
sudo ./scripts/complete-backup.sh
```

**What this does:**
- Backs up database (MongoDB)
- Backs up all uploaded files (images, documents)
- Backs up all configurations
- Backs up source code
- Creates: `/var/backups/bhumi-interior/migration-YYYYMMDD_HHMMSS/`

**Download backup to your local machine:**

```bash
# From your local machine
scp -r root@CURRENT_SERVER_IP:/var/backups/bhumi-interior/migration-* ./migration-backup/
```

✅ **Verify**: Check that all files downloaded successfully

---

## ✅ Step 2: Setup New Server (30 minutes)

### 2.1 Create New Server

Choose a hosting provider:
- DigitalOcean, AWS, Linode, Vultr, Hetzner, etc.
- Minimum: 2GB RAM, 2 CPU cores, 20GB storage
- OS: Ubuntu 20.04 or 22.04 LTS

### 2.2 Initial Server Configuration

```bash
# Connect to new server
ssh root@NEW_SERVER_IP

# Update system
apt update && apt upgrade -y

# Install essential tools
apt install -y curl git wget nano ufw htop

# Setup firewall
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw --force enable

# Install Docker
curl -fsSL https://get.docker.com | sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Node.js (for building frontend)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Verify installations
docker --version
docker-compose --version
node --version
npm --version
```

✅ **Verify**: All commands complete without errors

---

## ✅ Step 3: Deploy to New Server (20 minutes)

### 3.1 Upload Backup to New Server

From your **local machine**:

```bash
# Upload backup to new server
scp -r ./migration-backup/migration-* root@NEW_SERVER_IP:/tmp/
```

### 3.2 Run Restore Script

On **new server**:

```bash
# Create project directory
mkdir -p /var/www/bhumi-interior
cd /var/www/bhumi-interior

# Download restore script first (if not in backup)
git clone https://github.com/kenilGamer/Bhumi-interior-solution.git temp
cp temp/scripts/restore-from-backup.sh /usr/local/bin/
chmod +x /usr/local/bin/restore-from-backup.sh
rm -rf temp

# Run restore
restore-from-backup.sh /tmp/migration-YYYYMMDD_HHMMSS/
```

### 3.3 Update Configuration

```bash
cd /var/www/bhumi-interior

# Edit production environment file
nano .env.production
```

**Update these values:**

```bash
# Change domain if different
DOMAIN=bhumiinteriorsolution.in

# Keep MongoDB Atlas connection (if using Atlas)
MONGO_URI=mongodb+srv://kenilk677:KgbYiGyRpp7HS4cB@cluster0.lziadv4.mongodb.net/bhumi-interior?retryWrites=true&w=majority&appName=Cluster0

# IMPORTANT: Generate new JWT secret
JWT_SECRET=<run: openssl rand -hex 32>

# Update email settings
EMAIL_USER=bhumiinteriorsolution@gmail.com
EMAIL_PASS=<your-gmail-app-password>
```

Save and exit (Ctrl+X, Y, Enter)

### 3.4 Verify Application is Running

```bash
# Check containers are running
docker ps

# Should see:
# - bhumi-interior-backend
# - bhumi-interior-nginx
# - (bhumi-interior-mongodb if using local DB)

# Check logs
docker-compose -f docker-compose.atlas.yml logs -f

# Test backend (Ctrl+C to exit logs first)
curl http://localhost:5000/

# Test frontend
curl http://localhost/
```

✅ **Verify**: All containers running, no errors in logs

---

## ✅ Step 4: Setup SSL & Test (15 minutes)

### 4.1 Test Without HTTPS First

From your **local machine**:

```bash
# Test backend API
curl http://NEW_SERVER_IP:5000/

# Test frontend (in browser)
http://NEW_SERVER_IP
```

### 4.2 Temporarily Point DNS to New Server

**Important**: We'll do a soft test first without changing main DNS.

**Option A**: Edit your local hosts file (for testing):

```bash
# On your local machine
# Linux/Mac: sudo nano /etc/hosts
# Windows: notepad C:\Windows\System32\drivers\etc\hosts

# Add this line:
NEW_SERVER_IP bhumiinteriorsolution.in api.bhumiinteriorsolution.in www.bhumiinteriorsolution.in
```

Now when you access the domain from your machine, it goes to the new server!

### 4.3 Setup SSL Certificates

On **new server** (only do this after updating actual DNS or using hosts file trick):

```bash
cd /var/www/bhumi-interior

# Setup SSL certificates
sudo ./scripts/setup-ssl.sh

# Follow the prompts
# Enter: bhumiinteriorsolution@gmail.com
# Agree to terms: Y
```

### 4.4 Test HTTPS

```bash
# Test HTTPS works
curl -I https://bhumiinteriorsolution.in

# Should return: HTTP/2 200
```

✅ **Verify**: HTTPS working, no SSL errors

---

## ✅ Step 5: Update DNS & Go Live (5 minutes + propagation time)

### 5.1 Lower TTL (Do This 24 Hours Before)

**If you haven't done this yet**, do it now and wait 24 hours before proceeding.

Login to your domain registrar → DNS settings → Lower TTL to 300 seconds (5 minutes)

### 5.2 Update DNS Records

Update these records to point to **NEW_SERVER_IP**:

```
Type    Name    Value           TTL
A       @       NEW_SERVER_IP   300
A       www     NEW_SERVER_IP   300
A       api     NEW_SERVER_IP   300
```

### 5.3 Monitor DNS Propagation

```bash
# Check DNS from different locations
# Visit: https://www.whatsmydns.net/
# Enter: bhumiinteriorsolution.in

# Or from command line:
dig bhumiinteriorsolution.in
```

### 5.4 Monitor New Server

On **new server**:

```bash
# Watch incoming requests
docker-compose -f docker-compose.atlas.yml logs -f nginx

# You should start seeing real user traffic
```

### 5.5 Keep Old Server Running

**Important**: Keep your old server running for 48 hours after DNS change. This ensures users with cached DNS can still access the site.

After 48 hours, you can safely shut down the old server.

✅ **Verify**: Traffic flowing to new server, application working perfectly

---

## 🎯 Post-Migration Tasks

### Setup Automated Backups

```bash
cd /var/www/bhumi-interior
sudo ./scripts/setup-cron-backup.sh
```

### Monitor Application

```bash
# Check system resources
htop

# Check Docker stats
docker stats

# Check disk space
df -h

# Check logs
docker-compose -f docker-compose.atlas.yml logs -f
```

### Security Hardening (Recommended)

```bash
# Install fail2ban
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Change SSH port (optional)
nano /etc/ssh/sshd_config
# Change: Port 22 -> Port 2222
systemctl restart sshd
ufw allow 2222/tcp
ufw delete allow 22/tcp

# Create non-root user
useradd -m -s /bin/bash admin
usermod -aG sudo admin
passwd admin
```

---

## ❓ Troubleshooting

### Problem: Containers won't start

```bash
# Check logs
docker-compose -f docker-compose.atlas.yml logs

# Common fix: Check environment variables
cat .env.production

# Restart containers
docker-compose -f docker-compose.atlas.yml down
docker-compose -f docker-compose.atlas.yml up -d
```

### Problem: Can't connect to database

```bash
# Check MongoDB Atlas network access
# Login to MongoDB Atlas
# Network Access → Add IP Address → Add NEW_SERVER_IP

# Test connection
docker exec bhumi-interior-backend node -e "const mongoose = require('mongoose'); mongoose.connect(process.env.MONGO_URI).then(() => console.log('✅ Connected')).catch(err => console.log('❌ Error:', err.message))"
```

### Problem: SSL certificate fails

```bash
# Verify DNS points to new server
dig bhumiinteriorsolution.in

# Verify port 80 is accessible
curl -I http://bhumiinteriorsolution.in

# Try manual certificate request
docker-compose -f docker-compose.atlas.yml run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email bhumiinteriorsolution@gmail.com \
  --agree-tos \
  --no-eff-email \
  -d bhumiinteriorsolution.in \
  -d www.bhumiinteriorsolution.in \
  -d api.bhumiinteriorsolution.in
```

### Problem: Frontend shows blank page

```bash
# Rebuild frontend
cd /var/www/bhumi-interior/frontend
npm run build

# Restart nginx
docker-compose -f docker-compose.atlas.yml restart nginx
```

---

## 📋 Migration Checklist

Copy this checklist and mark off as you go:

```
PRE-MIGRATION
□ Lower DNS TTL to 300 seconds (24-48 hours before)
□ Notify users about potential brief downtime (optional)
□ Have MongoDB Atlas credentials ready
□ Have Gmail app password ready

BACKUP PHASE
□ Run complete-backup.sh on current server
□ Download backup to local machine
□ Verify backup files are complete

NEW SERVER SETUP
□ Create new server instance
□ Update and install essential packages
□ Install Docker and Docker Compose
□ Install Node.js
□ Configure firewall (UFW)

DEPLOYMENT PHASE
□ Upload backup to new server
□ Run restore-from-backup.sh
□ Update .env.production with new values
□ Generate new JWT secret
□ Verify containers are running
□ Test application locally (http://NEW_SERVER_IP)

SSL & TESTING
□ Test application without SSL first
□ Setup SSL certificates
□ Verify HTTPS works
□ Test all features (login, upload, etc.)

DNS MIGRATION
□ Update DNS A records to new server IP
□ Monitor DNS propagation
□ Watch new server logs for traffic
□ Keep old server running for 48 hours

POST-MIGRATION
□ Setup automated backups
□ Install monitoring tools
□ Security hardening (fail2ban, SSH)
□ Test all application features
□ Verify emails are sending
□ Check MongoDB connections
□ After 48 hours: Decommission old server
□ Increase DNS TTL back to normal (e.g., 3600)
```

---

## 📞 Need Help?

- **Detailed Guide**: See `MIGRATION-GUIDE.md` for comprehensive instructions
- **Deployment Guide**: See `DEPLOYMENT.md` for production setup details
- **GitHub Issues**: https://github.com/kenilGamer/Bhumi-interior-solution/issues

---

## 💡 Pro Tips

1. **Test Everything Twice**: Test on new server before changing DNS
2. **Use MongoDB Atlas**: Makes migration much easier (no database transfer needed)
3. **Keep Old Server**: Run old server for 48 hours after DNS change
4. **Monitor Logs**: Watch logs during DNS transition to catch issues early
5. **Have Rollback Plan**: Keep old server config for quick rollback if needed
6. **Document Changes**: Keep notes of any configuration changes you make

---

**Good luck with your migration! 🚀**

*If you follow this guide carefully, your migration will be smooth and seamless.*

