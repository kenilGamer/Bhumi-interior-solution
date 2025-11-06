# 🧰 Migration Toolkit - Complete Resource Map

Visual guide to your complete migration toolkit.

---

## 📁 File Structure Overview

```
/var/www/bhumi-interior/
│
├── 📖 MIGRATION DOCUMENTATION
│   ├── README-MIGRATION.md          ⭐ START HERE - Quick overview
│   ├── MIGRATION-QUICK-START.md     🚀 5-step quick guide (1-2 hours)
│   ├── MIGRATION-GUIDE.md           📋 Complete detailed guide (2-3 hours)
│   ├── MIGRATION-INDEX.md           📚 Resource index & navigation
│   ├── MIGRATION-TOOLKIT.md         🧰 This file - visual resource map
│   └── DEPLOYMENT.md                🚢 Production deployment reference
│
├── 🛠️ MIGRATION SCRIPTS
│   ├── scripts/complete-backup.sh         ⬆️  Backup everything
│   ├── scripts/restore-from-backup.sh     ⬇️  Restore on new server
│   ├── scripts/mongodb-backup.sh          🗄️  Database backup only
│   ├── scripts/mongodb-restore.sh         🗄️  Database restore only
│   ├── scripts/setup-ssl.sh               🔒 SSL certificate setup
│   ├── scripts/setup-cron-backup.sh       ⏰ Automated backups
│   ├── scripts/deploy-atlas.sh            ☁️  Deploy with Atlas
│   └── scripts/deploy.sh                  🐳 Deploy with local MongoDB
│
├── ⚙️  CONFIGURATION FILES
│   ├── .env.production                    🔧 Main configuration
│   ├── docker-compose.yml                 🐳 Docker with local MongoDB
│   ├── docker-compose.atlas.yml           ☁️  Docker with MongoDB Atlas
│   ├── docker-compose.dev.yml             💻 Development setup
│   └── env.production.example             📝 Configuration template
│
├── 🎨 APPLICATION CODE
│   ├── frontend/                          ⚛️  React.js application
│   ├── backend/                           🟢 Node.js API
│   ├── nginx/                             🌐 Nginx reverse proxy
│   └── scripts/                           🔧 Utility scripts
│
└── 💾 BACKUP STORAGE
    └── backups/                           📦 Local backup storage
        └── migration-YYYYMMDD_HHMMSS/     📁 Migration backup
            ├── database/                   🗄️  Database dumps
            ├── uploads/                    📸 Uploaded files
            ├── config/                     ⚙️  Configuration backups
            ├── source/                     💻 Source code archive
            └── README.md                   📖 Backup instructions
```

---

## 🗺️ Migration Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      CURRENT SERVER                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Step 1: Backup Everything                                 │ │
│  │  $ sudo ./scripts/complete-backup.sh                       │ │
│  │                                                             │ │
│  │  Creates:                                                   │ │
│  │  📦 /var/backups/bhumi-interior/migration-YYYYMMDD_HHMMSS/ │ │
│  │     ├── 🗄️  Database backup                                │ │
│  │     ├── 📸 Uploaded files                                   │ │
│  │     ├── ⚙️  Configuration files                             │ │
│  │     └── 💻 Source code                                      │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ⬇️  Download
┌─────────────────────────────────────────────────────────────────┐
│                      LOCAL MACHINE                               │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Step 2: Download Backup                                   │ │
│  │  $ scp -r root@CURRENT_IP:/var/backups/... ./backup/       │ │
│  │                                                             │ │
│  │  Local Storage: ~/bhumi-migration-backup/                  │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ⬇️  Upload
┌─────────────────────────────────────────────────────────────────┐
│                       NEW SERVER                                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Step 3: Setup Server                                      │ │
│  │  • Install Docker                                          │ │
│  │  • Install Docker Compose                                  │ │
│  │  • Install Node.js                                         │ │
│  │  • Configure Firewall                                      │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ⬇️                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Step 4: Restore & Deploy                                  │ │
│  │  $ sudo ./scripts/restore-from-backup.sh /tmp/backup/      │ │
│  │                                                             │ │
│  │  This automatically:                                        │ │
│  │  1. Extracts source code                                   │ │
│  │  2. Restores configuration                                 │ │
│  │  3. Restores uploaded files                                │ │
│  │  4. Builds frontend                                        │ │
│  │  5. Starts Docker containers                               │ │
│  │  6. Tests deployment                                       │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ⬇️                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Step 5: Setup SSL                                         │ │
│  │  $ sudo ./scripts/setup-ssl.sh                             │ │
│  │                                                             │ │
│  │  Configures HTTPS with Let's Encrypt                       │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ⬇️                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  ✅ Application Running                                     │ │
│  │  • Frontend: http://NEW_SERVER_IP                          │ │
│  │  • Backend: http://NEW_SERVER_IP:5000                      │ │
│  │  • HTTPS: https://domain.com (after DNS)                   │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ⬇️  Update DNS
┌─────────────────────────────────────────────────────────────────┐
│                    DOMAIN REGISTRAR                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Step 6: Update DNS Records                                │ │
│  │                                                             │ │
│  │  A     @      NEW_SERVER_IP     300                        │ │
│  │  A     www    NEW_SERVER_IP     300                        │ │
│  │  A     api    NEW_SERVER_IP     300                        │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ⬇️  Wait 5-60 minutes
┌─────────────────────────────────────────────────────────────────┐
│                      🎉 MIGRATION COMPLETE                       │
│                                                                  │
│  ✅ Application running on new server                            │
│  ✅ HTTPS enabled                                                │
│  ✅ All data migrated                                            │
│  ✅ Users accessing new server                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 Documentation Quick Reference

### 1️⃣ README-MIGRATION.md
**Purpose**: First document to read  
**Length**: 5 minutes  
**Content**:
- Overview of all resources
- Fastest migration path
- Quick help section
- Next steps guidance

**When to use**: Starting point for everyone

---

### 2️⃣ MIGRATION-QUICK-START.md
**Purpose**: Fast track migration  
**Length**: 10 minutes to read, 1-2 hours to execute  
**Content**:
- 5 simple steps
- Copy-paste commands
- Minimal explanations
- Quick troubleshooting

**When to use**: You want to migrate quickly

---

### 3️⃣ MIGRATION-GUIDE.md
**Purpose**: Comprehensive migration guide  
**Length**: 30 minutes to read, 2-3 hours to execute  
**Content**:
- Detailed explanations
- Multiple options (automated/manual)
- Pre-migration checklist
- DNS migration strategies
- Complete troubleshooting
- Rollback procedures

**When to use**: You want full understanding and control

---

### 4️⃣ MIGRATION-INDEX.md
**Purpose**: Navigate all resources  
**Length**: 10 minutes  
**Content**:
- Overview of all documentation
- Script descriptions
- Choose your path guide
- Quick reference section

**When to use**: Looking for specific information

---

### 5️⃣ MIGRATION-TOOLKIT.md
**Purpose**: Visual resource map (this file)  
**Length**: 5 minutes  
**Content**:
- Visual file structure
- Flow diagrams
- Quick reference
- Command cheat sheet

**When to use**: Need visual overview or quick commands

---

### 6️⃣ DEPLOYMENT.md
**Purpose**: Production deployment reference  
**Length**: 20 minutes  
**Content**:
- Fresh deployment from scratch
- MongoDB Atlas setup
- Docker configuration
- SSL setup
- Maintenance procedures

**When to use**: Setting up from scratch or reference

---

## 🛠️ Script Reference

### Primary Scripts

#### complete-backup.sh
```bash
Location: scripts/complete-backup.sh
Purpose:  Create comprehensive backup
Usage:    sudo ./scripts/complete-backup.sh
Time:     5-10 minutes
Output:   /var/backups/bhumi-interior/migration-YYYYMMDD_HHMMSS/
```

**What it backs up:**
- ✅ MongoDB database (local or Atlas export)
- ✅ All uploaded files (backend/uploads/)
- ✅ All configuration files (.env, docker-compose, nginx)
- ✅ Complete source code (excluding node_modules)

**What it excludes:**
- ❌ node_modules (will be reinstalled)
- ❌ Build artifacts (will be rebuilt)
- ❌ Log files
- ❌ Temporary files

---

#### restore-from-backup.sh
```bash
Location: scripts/restore-from-backup.sh
Purpose:  Restore application on new server
Usage:    sudo ./scripts/restore-from-backup.sh /path/to/backup/
Time:     15-20 minutes
```

**What it does:**
1. ✅ Backs up current installation (if exists)
2. ✅ Extracts source code
3. ✅ Restores configuration files
4. ✅ Restores uploaded files
5. ✅ Installs Docker (if needed)
6. ✅ Installs Node.js (if needed)
7. ✅ Builds frontend
8. ✅ Deploys with Docker
9. ✅ Optionally restores database

---

### Supporting Scripts

#### mongodb-backup.sh
```bash
Location: scripts/mongodb-backup.sh
Purpose:  Backup MongoDB database only
Usage:    ./scripts/mongodb-backup.sh
Output:   /var/backups/bhumi-interior/bhumi-interior-backup-YYYYMMDD_HHMMSS.tar.gz
```

---

#### mongodb-restore.sh
```bash
Location: scripts/mongodb-restore.sh
Purpose:  Restore MongoDB database
Usage:    ./scripts/mongodb-restore.sh backup-file.tar.gz
```

---

#### setup-ssl.sh
```bash
Location: scripts/setup-ssl.sh
Purpose:  Setup SSL certificates with Let's Encrypt
Usage:    sudo ./scripts/setup-ssl.sh
Requires: DNS must point to server first
```

---

#### setup-cron-backup.sh
```bash
Location: scripts/setup-cron-backup.sh
Purpose:  Setup automated daily backups
Usage:    sudo ./scripts/setup-cron-backup.sh
Schedule: Daily at 2:00 AM
```

---

## 💻 Command Cheat Sheet

### Backup Phase (Current Server)

```bash
# Full backup
cd /var/www/bhumi-interior
sudo ./scripts/complete-backup.sh

# List backups
ls -lh /var/backups/bhumi-interior/

# Download to local machine (from local)
scp -r root@CURRENT_IP:/var/backups/bhumi-interior/migration-* ./backup/
```

---

### New Server Setup

```bash
# Quick setup script (run all at once)
apt update && apt upgrade -y && \
apt install -y curl git wget nano ufw htop && \
ufw allow 22 && ufw allow 80 && ufw allow 443 && ufw --force enable && \
curl -fsSL https://get.docker.com | sh && \
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose && \
curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
apt-get install -y nodejs
```

---

### Deployment Phase (New Server)

```bash
# Upload backup (from local machine)
scp -r ./backup/migration-* root@NEW_IP:/tmp/

# On new server - restore
mkdir -p /var/www/bhumi-interior
cd /var/www/bhumi-interior
# Get restore script from GitHub or backup
./restore-from-backup.sh /tmp/migration-YYYYMMDD_HHMMSS/
```

---

### Post-Deployment Commands

```bash
# Check status
docker ps
docker-compose -f docker-compose.atlas.yml ps

# View logs
docker-compose -f docker-compose.atlas.yml logs -f

# Restart services
docker-compose -f docker-compose.atlas.yml restart

# Setup SSL (after DNS updated)
sudo ./scripts/setup-ssl.sh

# Setup automated backups
sudo ./scripts/setup-cron-backup.sh
```

---

### Troubleshooting Commands

```bash
# Check if services are running
docker ps

# View all logs
docker-compose -f docker-compose.atlas.yml logs

# View specific service logs
docker-compose -f docker-compose.atlas.yml logs backend
docker-compose -f docker-compose.atlas.yml logs nginx

# Test backend
curl http://localhost:5000/

# Test database connection
docker exec bhumi-interior-backend node -e "const mongoose = require('mongoose'); mongoose.connect(process.env.MONGO_URI).then(() => console.log('✅ Connected')).catch(err => console.log('❌ Error:', err.message))"

# Check disk space
df -h

# Check memory
free -h

# Check firewall
ufw status

# Check DNS
dig bhumiinteriorsolution.in

# Restart everything
docker-compose -f docker-compose.atlas.yml down
docker-compose -f docker-compose.atlas.yml up -d
```

---

## 🎯 Three Migration Paths

### Path A: Express (1-2 hours) ⚡
```
1. Run: complete-backup.sh
2. Download backup
3. Setup new server (basic)
4. Run: restore-from-backup.sh
5. Update DNS
✅ Done!
```

**Docs**: README-MIGRATION.md + MIGRATION-QUICK-START.md

---

### Path B: Standard (2-3 hours) 🎓
```
1. Read: MIGRATION-GUIDE.md
2. Pre-migration checklist
3. Run: complete-backup.sh
4. Setup new server (detailed)
5. Run: restore-from-backup.sh
6. Review configuration
7. Setup SSL
8. Update DNS with monitoring
9. Post-migration tasks
✅ Done!
```

**Docs**: MIGRATION-GUIDE.md

---

### Path C: Manual (3-4 hours) 🔧
```
1. Read: MIGRATION-GUIDE.md + DEPLOYMENT.md
2. Manual backup (each component)
3. Custom server setup
4. Manual deployment
5. Manual configuration
6. Custom SSL setup
7. Gradual DNS migration
8. Custom monitoring
✅ Done!
```

**Docs**: MIGRATION-GUIDE.md + DEPLOYMENT.md

---

## 📋 Success Checklist

After migration, verify these:

### Application
- [ ] Frontend loads without errors
- [ ] Backend API responds
- [ ] User login works
- [ ] Image uploads work
- [ ] Gallery displays images
- [ ] All pages accessible

### Infrastructure
- [ ] All Docker containers running
- [ ] No errors in logs
- [ ] HTTPS enabled (after DNS)
- [ ] SSL certificate valid
- [ ] Database connected
- [ ] Email sending works

### Security
- [ ] Firewall configured
- [ ] New JWT_SECRET generated
- [ ] Strong passwords set
- [ ] MongoDB access restricted
- [ ] SSH secured

### Monitoring
- [ ] Automated backups configured
- [ ] Logs accessible
- [ ] Monitoring tools installed
- [ ] Disk space sufficient
- [ ] Memory usage normal

---

## 🆘 Emergency Contacts

### Documentation Issues
Check: MIGRATION-INDEX.md for navigation

### Script Issues
Check: MIGRATION-GUIDE.md → Troubleshooting section

### Application Issues
Check: DEPLOYMENT.md → Troubleshooting section

### Support
- Email: bhumiinteriorsolution@gmail.com
- Phone: +91 92281 04285
- GitHub: https://github.com/kenilGamer/Bhumi-interior-solution/issues

---

## 📊 Resource Summary

### Documentation Files: 6
- README-MIGRATION.md (9.7K)
- MIGRATION-QUICK-START.md (11K)
- MIGRATION-GUIDE.md (19K)
- MIGRATION-INDEX.md (11K)
- MIGRATION-TOOLKIT.md (this file)
- DEPLOYMENT.md (existing, 20K)

### Script Files: 7
- complete-backup.sh (11K) ⭐
- restore-from-backup.sh (11K) ⭐
- mongodb-backup.sh (existing)
- mongodb-restore.sh (existing)
- setup-ssl.sh (existing)
- setup-cron-backup.sh (existing)
- deploy-atlas.sh (existing)

### Total Migration Toolkit Size: ~90KB
### Estimated Reading Time: 60-90 minutes
### Estimated Execution Time: 1-4 hours (depending on path)

---

**You're fully equipped for a successful migration!** 🚀

Choose your path, follow the guide, and you'll be up and running on your new server in no time.

*Questions? Start with README-MIGRATION.md*

---

**Created**: November 6, 2025  
**Version**: 1.0  
**Status**: ✅ Complete and Ready

