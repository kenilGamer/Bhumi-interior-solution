# 📚 Migration Documentation Index

Complete guide to migrating Bhumi Interior Solution to a new hosting provider.

---

## 📖 Available Documentation

### 🚀 Quick Start (Start Here!)
**File**: `MIGRATION-QUICK-START.md`

The fastest way to migrate. Follow 5 simple steps:
1. Backup current server (10 min)
2. Setup new server (30 min)
3. Deploy to new server (20 min)
4. Setup SSL & test (15 min)
5. Update DNS & go live (5 min + propagation)

**Best for**: Users who want a streamlined, step-by-step process.

---

### 📋 Complete Migration Guide
**File**: `MIGRATION-GUIDE.md`

Comprehensive migration guide with detailed explanations:
- Pre-migration checklist
- Complete backup procedures
- New server preparation
- Deployment options (automated & manual)
- DNS migration strategies
- Post-migration tasks
- Rollback procedures
- Troubleshooting

**Best for**: Users who want full control and detailed explanations.

---

### 🚢 Production Deployment Guide
**File**: `DEPLOYMENT.md`

Original deployment guide for setting up from scratch:
- Server requirements
- MongoDB Atlas configuration
- Environment setup
- Docker deployment
- SSL certificates
- Monitoring & maintenance

**Best for**: Reference during deployment or for fresh installations.

---

## 🛠️ Migration Scripts

### Complete Backup Script
**File**: `scripts/complete-backup.sh`

Creates a comprehensive backup including:
- MongoDB database (local or Atlas export)
- All uploaded files (images, documents)
- Configuration files (.env, docker-compose, nginx)
- Source code

**Usage**:
```bash
cd /var/www/bhumi-interior
sudo ./scripts/complete-backup.sh
```

**Output**: `/var/backups/bhumi-interior/migration-YYYYMMDD_HHMMSS/`

---

### Restore from Backup Script
**File**: `scripts/restore-from-backup.sh`

Automated restoration on new server:
- Extracts source code
- Restores configurations
- Restores uploads
- Builds frontend
- Deploys with Docker
- Optional database restore

**Usage**:
```bash
sudo ./scripts/restore-from-backup.sh /path/to/backup/directory/
```

---

### Database Backup/Restore Scripts
**Files**: 
- `scripts/mongodb-backup.sh` - Backup MongoDB
- `scripts/mongodb-restore.sh` - Restore MongoDB

**Usage**:
```bash
# Backup
./scripts/mongodb-backup.sh

# Restore
./scripts/mongodb-restore.sh /path/to/backup.tar.gz
```

---

### SSL Setup Script
**File**: `scripts/setup-ssl.sh`

Automates SSL certificate setup with Let's Encrypt:
- Checks DNS records
- Requests certificates
- Configures Nginx for HTTPS
- Sets up auto-renewal

**Usage**:
```bash
cd /var/www/bhumi-interior
sudo ./scripts/setup-ssl.sh
```

---

### Automated Backup Cron Job
**File**: `scripts/setup-cron-backup.sh`

Sets up daily automated backups (2 AM):
- Creates cron job
- Rotates old backups
- Retains 30 days of backups

**Usage**:
```bash
cd /var/www/bhumi-interior
sudo ./scripts/setup-cron-backup.sh
```

---

## 🎯 Choose Your Path

### Path 1: Quick Migration (Recommended)

**For**: Users who want to migrate quickly with minimal complexity.

```
1. Read: MIGRATION-QUICK-START.md
2. Run: scripts/complete-backup.sh (current server)
3. Download backup to local machine
4. Setup new server (basic setup)
5. Run: scripts/restore-from-backup.sh (new server)
6. Follow remaining steps in MIGRATION-QUICK-START.md
```

**Time**: 1-2 hours + DNS propagation

---

### Path 2: Detailed Migration

**For**: Users who want full understanding and control.

```
1. Read: MIGRATION-GUIDE.md (complete read-through)
2. Follow Pre-Migration Checklist
3. Choose backup method (automated or manual)
4. Prepare new hosting provider
5. Choose deployment method (automated or manual)
6. Follow DNS migration strategy
7. Complete post-migration tasks
```

**Time**: 2-4 hours + DNS propagation

---

### Path 3: Manual Step-by-Step

**For**: Advanced users or those with specific requirements.

```
1. Study: MIGRATION-GUIDE.md + DEPLOYMENT.md
2. Manually backup each component
3. Manually configure new server
4. Manually deploy application
5. Custom DNS migration strategy
6. Custom monitoring setup
```

**Time**: 3-5 hours + DNS propagation

---

## 📊 Migration Timeline

### Recommended Timeline (Zero Downtime)

**T-48 hours**: Lower DNS TTL to 300 seconds

**T-24 hours**: 
- Run complete backup
- Download to local machine
- Verify backup integrity

**T-2 hours**:
- Setup new server
- Deploy application
- Test thoroughly

**T-1 hour**:
- Setup SSL certificates
- Final testing
- Prepare monitoring

**T-0 (Go Live)**:
- Update DNS records
- Monitor both servers
- Watch for issues

**T+48 hours**:
- Verify all traffic on new server
- Decommission old server
- Increase DNS TTL back

---

## ✅ Pre-Migration Requirements

### Information You Need

- [ ] Current server SSH credentials
- [ ] New server IP address and SSH credentials
- [ ] Domain registrar login (for DNS)
- [ ] MongoDB Atlas credentials (if using)
- [ ] Gmail app password (for emails)
- [ ] SSL email address

### Server Requirements

**Minimum**:
- CPU: 2 cores
- RAM: 2GB (4GB recommended)
- Storage: 20GB SSD
- OS: Ubuntu 20.04+ or Debian 11+

**Recommended**:
- CPU: 2-4 cores
- RAM: 4-8GB
- Storage: 40GB SSD
- OS: Ubuntu 22.04 LTS

---

## 🔒 Security Checklist

- [ ] Generate new JWT_SECRET for new server
- [ ] Use strong passwords for all services
- [ ] Configure firewall (UFW)
- [ ] Setup fail2ban (optional but recommended)
- [ ] Change default SSH port (optional)
- [ ] Create non-root user
- [ ] Keep server updated (apt update && apt upgrade)
- [ ] Setup automated backups
- [ ] MongoDB Atlas network access restricted
- [ ] SSL certificates installed

---

## 📦 What Gets Backed Up

### Automated Backup Script Includes:

✅ **Database**
- All collections
- All documents
- Indexes
- User data

✅ **Uploaded Files**
- All images in gallery
- All uploaded documents
- User avatars
- Any other uploaded assets

✅ **Configuration**
- .env.production
- frontend/.env.production
- backend/.env
- docker-compose.yml files
- Nginx configurations
- package.json files

✅ **Source Code**
- All application code
- Frontend React app
- Backend Node.js app
- Scripts and utilities

❌ **Excluded** (saves space):
- node_modules (reinstalled during deployment)
- Frontend build artifacts (rebuilt)
- Temporary files
- Log files
- Docker volumes
- .git history

---

## 🆘 Need Help?

### Quick Troubleshooting

**Containers won't start**:
```bash
docker-compose -f docker-compose.atlas.yml logs
```

**Database connection fails**:
- Check MongoDB Atlas Network Access
- Verify connection string in .env.production
- Test: `docker exec bhumi-interior-backend node -e "..."`

**SSL certificate fails**:
- Verify DNS points to new server: `dig domain.com`
- Check port 80 is open: `ufw status`
- Manual request: See MIGRATION-GUIDE.md

**Application not accessible**:
- Check firewall: `ufw status`
- Check containers: `docker ps`
- Check cloud provider security groups

### Support Resources

- **Detailed Troubleshooting**: See MIGRATION-GUIDE.md → Troubleshooting section
- **Deployment Issues**: See DEPLOYMENT.md → Troubleshooting section
- **GitHub Repository**: https://github.com/kenilGamer/Bhumi-interior-solution
- **Create Issue**: https://github.com/kenilGamer/Bhumi-interior-solution/issues

---

## 💡 Pro Tips

1. **Test Before Switching**: Fully test new server before changing DNS
2. **Use MongoDB Atlas**: Eliminates database migration complexity
3. **Keep Old Server**: Run for 48 hours after DNS change
4. **Monitor Logs**: Watch logs during transition
5. **Document Everything**: Keep notes of what you change
6. **Have Rollback Plan**: Know how to revert DNS if needed
7. **Backup Current Server**: Before doing anything!
8. **Check Hosting Limits**: Ensure new host allows your traffic/storage

---

## 📈 Cost Estimation

### Hosting Costs (Monthly)

**Budget Tier** ($12-15/month):
- DigitalOcean Basic Droplet: $12
- Linode Nanode: $12
- Vultr Regular: $12

**Recommended Tier** ($20-30/month):
- DigitalOcean Regular: $24
- AWS t3.small: ~$15
- Linode 4GB: $24
- Hetzner CX21: ~€8 (~$10)

**Additional Costs**:
- Domain: $10-15/year
- MongoDB Atlas: Free tier (or $9-57/month)
- SSL: Free (Let's Encrypt)
- Backups: Included in server storage

**Total Estimated**: $15-35/month

---

## 📞 Contact Information

- **Email**: bhumiinteriorsolution@gmail.com
- **Phone**: +91 92281 04285
- **Website**: bhumiinteriorsolution.in

---

## 🗺️ Quick Reference

### Current Setup
- **Server**: Check your hosting provider dashboard
- **Database**: MongoDB Atlas (Cloud) or Local Docker
- **Domain**: bhumiinteriorsolution.in
- **SSL**: Let's Encrypt (auto-renewal)
- **Backend**: Node.js + Express (Port 5000)
- **Frontend**: React.js + Vite (served by Nginx)

### Key Files & Locations
```
/var/www/bhumi-interior/              # Main project directory
├── .env.production                    # Main environment config
├── frontend/                          # React frontend
│   ├── .env.production               # Frontend config
│   └── dist/                         # Built frontend (served by Nginx)
├── backend/                           # Node.js backend
│   ├── app.js                        # Main backend entry
│   └── uploads/                      # Uploaded files
├── nginx/                             # Nginx configuration
│   └── conf.d/                       # Site configurations
├── scripts/                           # Utility scripts
├── certbot/                           # SSL certificates
└── backups/                           # Local backups
```

### Important Commands
```bash
# Check status
docker ps
docker-compose -f docker-compose.atlas.yml ps

# View logs
docker-compose -f docker-compose.atlas.yml logs -f

# Restart services
docker-compose -f docker-compose.atlas.yml restart

# Stop all
docker-compose -f docker-compose.atlas.yml down

# Start all
docker-compose -f docker-compose.atlas.yml up -d

# Rebuild
docker-compose -f docker-compose.atlas.yml up -d --build
```

---

**Version**: 1.0  
**Last Updated**: November 6, 2025  
**Maintained by**: Bhumi Interior Solution Team

---

Good luck with your migration! 🚀

