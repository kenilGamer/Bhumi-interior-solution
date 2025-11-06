# 📤 How to Upload Files - Complete Guide

This guide covers all file upload scenarios for your Bhumi Interior Solution migration.

---

## 📋 Table of Contents

1. [Uploading Backup Files to New Server](#uploading-backup-files-to-new-server)
2. [Using Cloud Storage for Large Transfers](#using-cloud-storage-for-large-transfers)
3. [Application File Upload Feature](#application-file-upload-feature)
4. [Troubleshooting Upload Issues](#troubleshooting-upload-issues)

---

## 🔄 Uploading Backup Files to New Server

### Method 1: SCP (Secure Copy) - Recommended

**From Local Machine to New Server:**

```bash
# Basic upload
scp -r ./migration-backup/migration-YYYYMMDD_HHMMSS/ root@NEW_SERVER_IP:/tmp/

# With verbose output (shows progress)
scp -rv ./migration-backup/migration-YYYYMMDD_HHMMSS/ root@NEW_SERVER_IP:/tmp/

# With specific SSH port (if you changed default)
scp -P 2222 -r ./migration-backup/ root@NEW_SERVER_IP:/tmp/

# With SSH key authentication
scp -i ~/.ssh/your-private-key.pem -r ./migration-backup/ root@NEW_SERVER_IP:/tmp/

# Upload specific file only
scp ./migration-backup/uploads-backup.tar.gz root@NEW_SERVER_IP:/tmp/
```

**Progress Indication:**

SCP doesn't show detailed progress by default. For better visibility:

```bash
# Use rsync instead (shows progress bar)
rsync -avz --progress ./migration-backup/ root@NEW_SERVER_IP:/tmp/migration-backup/
```

---

### Method 2: RSYNC - Best for Large Files

**Advantages:**
- Shows detailed progress
- Can resume interrupted transfers
- Only transfers changed files
- Better compression

```bash
# Basic rsync upload
rsync -avz --progress ./migration-backup/ root@NEW_SERVER_IP:/tmp/migration-backup/

# With SSH key
rsync -avz --progress -e "ssh -i ~/.ssh/your-key.pem" \
  ./migration-backup/ root@NEW_SERVER_IP:/tmp/migration-backup/

# Resume interrupted transfer (run same command again)
rsync -avz --progress --partial ./migration-backup/ root@NEW_SERVER_IP:/tmp/

# Dry run first (see what will be transferred)
rsync -avz --progress --dry-run ./migration-backup/ root@NEW_SERVER_IP:/tmp/
```

**RSYNC Options Explained:**
- `-a` = archive mode (preserves permissions, timestamps)
- `-v` = verbose (show files being transferred)
- `-z` = compression (faster transfer)
- `--progress` = show progress bar
- `--partial` = keep partially transferred files

---

### Method 3: Direct Server-to-Server Transfer

Transfer directly from old server to new server (no local download):

```bash
# On OLD SERVER
# Upload to new server
scp -r /var/backups/bhumi-interior/migration-20250106_123000/ root@NEW_SERVER_IP:/tmp/

# Or with rsync
rsync -avz --progress /var/backups/bhumi-interior/migration-*/ root@NEW_SERVER_IP:/tmp/

# Check transfer completed
ssh root@NEW_SERVER_IP "ls -lh /tmp/migration-*/"
```

---

### Method 4: Using SFTP (Interactive)

For manual file transfer with GUI-like interface:

```bash
# Connect to new server
sftp root@NEW_SERVER_IP

# SFTP commands:
sftp> cd /tmp                      # Change remote directory
sftp> lcd ./migration-backup       # Change local directory
sftp> put -r migration-*           # Upload directory
sftp> ls -la                       # List remote files
sftp> bye                          # Exit

# Or non-interactive
sftp root@NEW_SERVER_IP:/tmp <<< $'put -r ./migration-backup/*'
```

---

### Method 5: Using WinSCP (Windows Users)

If you're on Windows:

1. Download WinSCP: https://winscp.net/
2. Open WinSCP
3. Connection settings:
   - Host: NEW_SERVER_IP
   - Port: 22
   - Username: root
   - Password: (your password)
4. Click "Login"
5. Drag and drop files from left (local) to right (remote)
6. Navigate to `/tmp/` on remote side
7. Upload your `migration-backup` folder

---

## ☁️ Using Cloud Storage for Large Transfers

If your backup is very large (>1GB) or you have slow internet:

### Option A: Google Drive / Dropbox

**Upload from Old Server:**

```bash
# Install rclone
curl https://rclone.org/install.sh | sudo bash

# Configure Google Drive
rclone config
# Follow prompts to setup Google Drive

# Upload backup
rclone copy /var/backups/bhumi-interior/migration-*/ gdrive:bhumi-backup/ -P

# Download on New Server
rclone copy gdrive:bhumi-backup/ /tmp/migration-backup/ -P
```

---

### Option B: AWS S3 (If Available)

```bash
# On OLD SERVER
# Install AWS CLI
apt-get install awscli

# Configure (need AWS credentials)
aws configure

# Upload to S3
aws s3 cp /var/backups/bhumi-interior/migration-20250106/ \
  s3://your-bucket/migration-backup/ --recursive

# On NEW SERVER
# Download from S3
aws s3 cp s3://your-bucket/migration-backup/ \
  /tmp/migration-backup/ --recursive
```

---

### Option C: Transfer.sh (Quick & Simple)

For quick file sharing (up to 10GB, files deleted after 14 days):

```bash
# On OLD SERVER
# Upload single file
curl --upload-file /var/backups/bhumi-interior/backup.tar.gz \
  https://transfer.sh/backup.tar.gz

# Returns: https://transfer.sh/xxxxx/backup.tar.gz

# On NEW SERVER
# Download
wget https://transfer.sh/xxxxx/backup.tar.gz -O /tmp/backup.tar.gz
```

---

## 📱 Application File Upload Feature

Your application has a built-in file upload feature for images and documents.

### How It Works

1. **Frontend**: Users select files via web interface
2. **Backend**: Receives files at `/api/upload` endpoint
3. **Storage**: Files saved in `backend/uploads/`
4. **Access**: Files served by Nginx at `/uploads/` URL

### File Upload Limits

Current configuration:

```bash
# Check current limits
cat /var/www/bhumi-interior/.env.production | grep MAX_FILE_SIZE

# Default: 10MB (10485760 bytes)
MAX_FILE_SIZE=10485760
```

### To Increase Upload Limit

**1. Update Backend Configuration:**

```bash
# Edit environment file
nano /var/www/bhumi-interior/.env.production

# Change to 50MB
MAX_FILE_SIZE=52428800
```

**2. Update Nginx Configuration:**

```bash
# Edit Nginx config
nano /var/www/bhumi-interior/nginx/conf.d/default.conf

# Add or update in server block:
client_max_body_size 50M;
```

**3. Restart Services:**

```bash
cd /var/www/bhumi-interior
docker-compose -f docker-compose.atlas.yml restart backend
docker-compose -f docker-compose.atlas.yml restart nginx
```

---

## 🔍 Verify Upload Success

### After Uploading to New Server

```bash
# On NEW SERVER
# Check if files arrived
ls -lh /tmp/migration-*/

# Check backup integrity
cd /tmp/migration-20250106_123000/
ls -la database/ uploads/ config/ source/

# Verify file sizes match
du -sh *

# Test extraction (if tar.gz)
tar -tzf uploads/uploads-backup.tar.gz | head -20
```

---

## ⚡ Upload Speed Optimization

### Compression

```bash
# If backup is not compressed, compress first
cd /var/backups/bhumi-interior/
tar -czf migration-20250106.tar.gz migration-20250106_123000/

# Upload compressed file (much faster)
scp migration-20250106.tar.gz root@NEW_SERVER_IP:/tmp/

# Extract on new server
ssh root@NEW_SERVER_IP
cd /tmp
tar -xzf migration-20250106.tar.gz
```

---

### Parallel Uploads (Advanced)

```bash
# Upload multiple files in parallel
cd ./migration-backup/

# Method 1: Using xargs
find . -type f -name "*.tar.gz" | \
  xargs -I {} -P 4 scp {} root@NEW_SERVER_IP:/tmp/

# Method 2: Using GNU parallel (if installed)
ls *.tar.gz | parallel -j4 scp {} root@NEW_SERVER_IP:/tmp/
```

---

## 🚨 Troubleshooting Upload Issues

### Issue 1: Permission Denied

```bash
# Error: Permission denied (publickey)
# Solution 1: Use password authentication
scp -o PreferredAuthentications=password -r ./backup/ root@NEW_SERVER_IP:/tmp/

# Solution 2: Add your SSH key
ssh-copy-id root@NEW_SERVER_IP

# Solution 3: Specify correct SSH key
scp -i ~/.ssh/correct-key.pem -r ./backup/ root@NEW_SERVER_IP:/tmp/
```

---

### Issue 2: Connection Refused

```bash
# Error: Connection refused
# Check if SSH is running on new server
ssh root@NEW_SERVER_IP "systemctl status sshd"

# Check firewall
ssh root@NEW_SERVER_IP "ufw status"

# Allow SSH through firewall
ssh root@NEW_SERVER_IP "ufw allow 22/tcp"
```

---

### Issue 3: Slow Upload Speed

```bash
# Enable compression
scp -C -r ./backup/ root@NEW_SERVER_IP:/tmp/

# Or use rsync with compression
rsync -avz --compress-level=9 ./backup/ root@NEW_SERVER_IP:/tmp/

# Limit bandwidth (if needed)
rsync -avz --bwlimit=5000 ./backup/ root@NEW_SERVER_IP:/tmp/
# (5000 = 5MB/s)
```

---

### Issue 4: Upload Interrupted

```bash
# Resume with rsync (not possible with scp)
rsync -avz --progress --partial ./backup/ root@NEW_SERVER_IP:/tmp/

# This will continue from where it stopped
```

---

### Issue 5: Not Enough Space on Server

```bash
# Check available space on new server
ssh root@NEW_SERVER_IP "df -h"

# Check backup size locally
du -sh ./migration-backup/

# Clean up space on new server
ssh root@NEW_SERVER_IP "apt-get clean && apt-get autoremove -y"

# Or use different directory with more space
scp -r ./backup/ root@NEW_SERVER_IP:/home/backups/
```

---

## 📊 Upload Progress Monitoring

### Real-time Upload Monitoring

**Terminal 1 (Upload):**
```bash
rsync -avz --progress ./backup/ root@NEW_SERVER_IP:/tmp/
```

**Terminal 2 (Monitor on Server):**
```bash
# Watch files arriving
ssh root@NEW_SERVER_IP "watch -n 1 'du -sh /tmp/migration-*'"

# Monitor network usage
ssh root@NEW_SERVER_IP "iftop -i eth0"
```

---

### Estimate Time Remaining

```bash
# Check upload speed and calculate
# If you have 5GB to upload and seeing 10MB/s:
# 5000 MB / 10 MB/s = 500 seconds = ~8 minutes

# With rsync, it shows ETA automatically:
rsync -avz --progress ./backup/ root@NEW_SERVER_IP:/tmp/
# Output shows: 
#   5,120,000,000  48%   10.23MB/s   0:04:20 (4 minutes 20 seconds remaining)
```

---

## 📦 Uploading Specific Components Only

If you only need to upload certain parts:

```bash
# Upload database backup only
scp /var/backups/bhumi-interior/migration-*/database/database-backup.tar.gz \
  root@NEW_SERVER_IP:/tmp/

# Upload uploaded files only
scp /var/backups/bhumi-interior/migration-*/uploads/uploads-backup.tar.gz \
  root@NEW_SERVER_IP:/tmp/

# Upload configuration only
scp -r /var/backups/bhumi-interior/migration-*/config/ \
  root@NEW_SERVER_IP:/tmp/config/

# Upload source code only
scp /var/backups/bhumi-interior/migration-*/source/source-code.tar.gz \
  root@NEW_SERVER_IP:/tmp/
```

---

## 🔐 Security Best Practices

### 1. Secure File Transfer

```bash
# Always use encrypted transfers (SCP, SFTP, RSYNC over SSH)
# NEVER use FTP (unencrypted)

# Verify fingerprint on first connection
# SSH will show:
# "The authenticity of host 'NEW_SERVER_IP' can't be established"
# Verify the fingerprint matches your server
```

### 2. Delete After Migration

```bash
# After successful migration, delete backups from servers

# On OLD SERVER
rm -rf /var/backups/bhumi-interior/migration-*

# On NEW SERVER (after deployment complete)
rm -rf /tmp/migration-*

# On LOCAL MACHINE (keep one copy encrypted if needed)
rm -rf ~/migration-backup/
```

### 3. Encrypt Sensitive Backups

```bash
# If backup contains sensitive data, encrypt before upload

# Encrypt
tar -czf - /var/backups/bhumi-interior/migration-*/ | \
  openssl enc -aes-256-cbc -e -out migration-encrypted.tar.gz.enc

# Upload encrypted
scp migration-encrypted.tar.gz.enc root@NEW_SERVER_IP:/tmp/

# Decrypt on new server
openssl enc -aes-256-cbc -d -in migration-encrypted.tar.gz.enc | \
  tar -xzf - -C /tmp/
```

---

## 💡 Quick Reference Commands

```bash
# Quick upload (most common)
scp -r ./backup/ root@NEW_IP:/tmp/

# Upload with progress
rsync -avz --progress ./backup/ root@NEW_IP:/tmp/

# Resume interrupted
rsync -avz --progress --partial ./backup/ root@NEW_IP:/tmp/

# Verify upload
ssh root@NEW_IP "ls -lh /tmp/migration-*"

# Check upload size
ssh root@NEW_IP "du -sh /tmp/migration-*"
```

---

## 📞 Need Help?

If you encounter issues uploading files:

1. Check network connectivity: `ping NEW_SERVER_IP`
2. Check SSH access: `ssh root@NEW_SERVER_IP`
3. Check disk space: `ssh root@NEW_SERVER_IP "df -h"`
4. Try alternative methods (rsync instead of scp)
5. Consider cloud storage for very large files

---

**Related Guides:**
- MIGRATION-QUICK-START.md - Step-by-step migration
- MIGRATION-GUIDE.md - Complete migration guide
- README-MIGRATION.md - Overview

---

**Last Updated**: November 6, 2025

