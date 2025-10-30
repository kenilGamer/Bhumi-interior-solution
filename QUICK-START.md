# 🚀 Quick Start Guide - Bhumi Interior Solution

**Deploy in 5 minutes!** This is the fastest way to get your site live at **bhumiinteriorsolution.in**

---

## ⚡ Prerequisites

- Ubuntu/Debian server with root access
- Domain: bhumiinteriorsolution.in pointing to your server IP
- MongoDB Atlas connection string (already provided)

---

## 🎯 Step-by-Step Deployment

### Step 1: Connect to Server

```bash
ssh root@YOUR_SERVER_IP
```

### Step 2: Clone Repository

```bash
cd /var/www
git clone https://github.com/kenilGamer/Bhumi-interior-solution.git bhumi-interior
cd bhumi-interior
```

### Step 3: Configure Environment

```bash
# Create production environment file
cat > .env.production << 'EOF'
DOMAIN=bhumiinteriorsolution.in
API_SUBDOMAIN=api.bhumiinteriorsolution.in
WWW_DOMAIN=www.bhumiinteriorsolution.in

MONGO_URI=mongodb+srv://kenilk677:KgbYiGyRpp7HS4cB@cluster0.lziadv4.mongodb.net/bhumi-interior?retryWrites=true&w=majority&appName=Cluster0

JWT_SECRET=$(openssl rand -hex 32)
JWT_EXPIRES_IN=7d

EMAIL_USER=bhumiinteriorsolution@gmail.com
EMAIL_PASS=YOUR_GMAIL_APP_PASSWORD
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587

SSL_EMAIL=bhumiinteriorsolution@gmail.com
NODE_ENV=production
EOF

# IMPORTANT: Edit the EMAIL_PASS
nano .env.production
```

**Replace `YOUR_GMAIL_APP_PASSWORD`** with your actual Gmail app password.

### Step 4: Deploy

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run deployment
sudo ./scripts/deploy-atlas.sh
```

Wait 2-3 minutes for deployment to complete.

### Step 5: Setup SSL

```bash
sudo ./scripts/setup-ssl.sh
```

### Step 6: Create Admin User

```bash
curl -X POST https://bhumiinteriorsolution.in/api/register \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Admin User",
    "email": "admin@bhumiinteriorsolution.in",
    "phone": "+91 92281 04285",
    "password": "Admin@123!",
    "role": "admin"
  }'
```

**Save your password!**

---

## ✅ Verify Deployment

```bash
# Check containers are running
docker ps

# You should see:
# - bhumi-interior-backend
# - bhumi-interior-nginx
# - bhumi-interior-certbot

# Test your site
curl -I https://bhumiinteriorsolution.in
curl -I https://api.bhumiinteriorsolution.in
```

---

## 🌐 Access Your Site

- **Main Site**: https://bhumiinteriorsolution.in
- **Admin Dashboard**: https://bhumiinteriorsolution.in/dashboard
- **API**: https://api.bhumiinteriorsolution.in

**Login Credentials:**
- Email: admin@bhumiinteriorsolution.in
- Password: (the one you set above)

---

## 🔧 Common Commands

```bash
# View logs
docker-compose -f docker-compose.atlas.yml logs -f

# Restart services
docker-compose -f docker-compose.atlas.yml restart

# Stop everything
docker-compose -f docker-compose.atlas.yml down

# Start everything
docker-compose -f docker-compose.atlas.yml up -d
```

---

## ❓ Need Help?

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed documentation.

**Support:**
- Email: bhumiinteriorsolution@gmail.com
- Phone: +91 92281 04285

---

**That's it! Your site is live! 🎉**
