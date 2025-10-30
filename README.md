# 🏠 Bhumi Interior Solution

### _Transforming Spaces with Excellence - Interior Design Management System_

![Node.js](https://img.shields.io/badge/Node.js-18.x-green)
![React](https://img.shields.io/badge/React-18.3-blue)
![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

> A comprehensive full-stack web application for managing interior design projects, showcasing portfolios, and facilitating client interactions. Built with modern technologies to provide a seamless experience for both administrators and clients.

**🌐 Live**: [bhumiinteriorsolution.in](https://bhumiinteriorsolution.in)

---

## 📖 Documentation

- **[Quick Start Guide](./QUICK-START.md)** - Deploy in 5 minutes
- **[Complete Deployment Guide](./DEPLOYMENT.md)** - Detailed production setup
- **[API Documentation](./backend/API.md)** - Backend API reference

---

## ✨ Features

### 🎨 **For Clients**

* **Interactive Gallery**: Browse through stunning interior design projects
* **Service Showcase**: Explore comprehensive interior design services
* **Contact Integration**: Easy communication with design experts
* **Responsive Design**: Optimized for all devices and screen sizes

### 🔧 **For Administrators**

* **Dashboard Management**: Complete control over content and media
* **Gallery Management**: Upload, edit, and organize project images
* **User Authentication**: Secure admin access with JWT tokens
* **File Upload System**: Support for images and videos
* **Real-time Updates**: Instant content updates across the platform

### 🚀 **Technical Features**

* **Modern Stack**: React 18 + Node.js + Express + MongoDB Atlas
* **Fast Development**: Vite for lightning-fast frontend builds
* **File Management**: Multer for efficient file uploads
* **Security**: JWT authentication and secure password handling
* **Responsive UI**: Tailwind CSS for beautiful, mobile-first design
* **Production Ready**: Docker, Nginx, SSL/TLS support

---

## 🏗️ Tech Stack

| Category | Technology |
|----------|------------|
| **Frontend** | React 18, Vite, TailwindCSS, GSAP, Lenis, React Router |
| **Backend** | Node.js, Express.js, JWT, Bcrypt, Nodemailer |
| **Database** | MongoDB Atlas (Cloud) |
| **File Storage** | Multer, Local Storage |
| **Deployment** | Docker, Docker Compose, Nginx |
| **SSL** | Let's Encrypt (Certbot) |
| **Version Control** | Git, GitHub |

---

## 📁 Project Structure

```
bhumi-interior/
├── 📁 backend/                    # Node.js/Express API Server
│   ├── 📁 models/                 # MongoDB Schemas
│   │   ├── UserModel.js          # User authentication model
│   │   └── Gallery.js            # Gallery items model
│   ├── 📁 uploads/               # File storage directory
│   ├── app.js                    # Main server application
│   ├── multer.js                 # File upload configuration
│   ├── Dockerfile                # Backend Docker config
│   └── package.json              # Backend dependencies
│
├── 📁 frontend/                   # React Frontend
│   ├── 📁 src/                    # Source files
│   │   ├── 📁 components/        # React components
│   │   ├── 📁 pages/             # Page components
│   │   ├── 📁 assets/            # Static assets
│   │   └── App.jsx               # Main app component
│   ├── 📁 public/                # Public assets
│   ├── Dockerfile                # Frontend Docker config
│   ├── vite.config.js            # Vite configuration
│   └── package.json              # Frontend dependencies
│
├── 📁 nginx/                      # Nginx Configuration
│   ├── nginx.conf                # Main nginx config
│   └── 📁 conf.d/                # Site configurations
│       ├── bhumi-interior.conf   # Production (with SSL)
│       └── bhumi-interior-initial.conf  # Initial (HTTP only)
│
├── 📁 scripts/                    # Deployment Scripts
│   ├── deploy-atlas.sh           # Main deployment script
│   ├── setup-ssl.sh              # SSL certificate setup
│   ├── quick-deploy.sh           # Interactive quick deploy
│   ├── mongodb-backup.sh         # Backup script
│   └── mongodb-restore.sh        # Restore script
│
├── 📁 certbot/                    # SSL Certificates
│   ├── 📁 conf/                  # Certificate files
│   └── 📁 www/                   # ACME challenge
│
├── docker-compose.yml            # Docker Compose (with MongoDB)
├── docker-compose.atlas.yml      # Docker Compose (MongoDB Atlas)
├── docker-compose.dev.yml        # Development compose
├── .env.production.example       # Production env template
├── DEPLOYMENT.md                 # Deployment documentation
├── QUICK-START.md               # Quick start guide
└── README.md                    # This file
```

---

## 🚀 Quick Start

### Option 1: Automated Deployment (Recommended)

```bash
# Clone repository
cd /var/www
git clone https://github.com/kenilGamer/Bhumi-interior-solution.git bhumi-interior
cd bhumi-interior

# Create environment file
cp env.production.example .env.production
nano .env.production  # Edit with your configuration

# Deploy (installs Docker, builds everything, starts containers)
sudo ./scripts/deploy-atlas.sh

# Setup SSL
sudo ./scripts/setup-ssl.sh
```

### Option 2: Interactive Quick Deploy

```bash
cd /var/www/bhumi-interior
sudo ./scripts/quick-deploy.sh
# Follow the prompts
```

### Option 3: Local Development

```bash
# Backend
cd backend
npm install
npm start

# Frontend (in new terminal)
cd frontend
npm install
npm run dev
```

Visit: http://localhost:5173

---

## 🌐 Production URLs

After deployment, your site will be available at:

- **Main Website**: https://bhumiinteriorsolution.in
- **WWW**: https://www.bhumiinteriorsolution.in
- **API**: https://api.bhumiinteriorsolution.in
- **Admin Dashboard**: https://bhumiinteriorsolution.in/dashboard

---

## 📋 API Endpoints

### Authentication

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/register` | Register new user | No |
| POST | `/login` | User login | No |
| POST | `/forgot-password` | Request password reset | No |
| POST | `/reset-password` | Reset password | No |

### Gallery Management

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/gallery` | Get all gallery items | No |
| GET | `/gallery/:page/:limit` | Get paginated gallery | No |
| POST | `/gallery` | Add gallery item | Yes (Admin) |
| PUT | `/gallery/:id` | Update gallery item | Yes (Admin) |
| DELETE | `/gallery/:id` | Delete gallery item | Yes (Admin) |

### File Management

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/uploads/:filename` | Get uploaded file | No |

---

## 🔧 Configuration

### Environment Variables

Create `.env.production` with:

```bash
# Domain Configuration
DOMAIN=bhumiinteriorsolution.in
API_SUBDOMAIN=api.bhumiinteriorsolution.in
WWW_DOMAIN=www.bhumiinteriorsolution.in

# MongoDB Atlas
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/database

# JWT
JWT_SECRET=your-super-secure-random-string
JWT_EXPIRES_IN=7d

# Email
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# SSL
SSL_EMAIL=your-email@gmail.com

NODE_ENV=production
```

### DNS Configuration

Configure these A records:

```
Type    Name    Value              TTL
A       @       YOUR_SERVER_IP     300
A       www     YOUR_SERVER_IP     300
A       api     YOUR_SERVER_IP     300
```

---

## 🐳 Docker Commands

```bash
# Using MongoDB Atlas (Recommended for Production)
docker-compose -f docker-compose.atlas.yml up -d
docker-compose -f docker-compose.atlas.yml logs -f
docker-compose -f docker-compose.atlas.yml restart
docker-compose -f docker-compose.atlas.yml down

# Using Local MongoDB (Development)
docker-compose up -d
docker-compose logs -f
docker-compose restart
docker-compose down

# Development Mode
docker-compose -f docker-compose.dev.yml up
```

---

## 🛠️ Maintenance

### View Logs

```bash
# All services
docker-compose -f docker-compose.atlas.yml logs -f

# Specific service
docker-compose -f docker-compose.atlas.yml logs -f backend
docker-compose -f docker-compose.atlas.yml logs -f nginx

# Last 100 lines
docker-compose -f docker-compose.atlas.yml logs --tail=100
```

### Restart Services

```bash
# Restart all
docker-compose -f docker-compose.atlas.yml restart

# Restart specific service
docker-compose -f docker-compose.atlas.yml restart backend
```

### Update Application

```bash
cd /var/www/bhumi-interior

# Pull latest code
git pull

# Rebuild and restart
docker-compose -f docker-compose.atlas.yml build --no-cache
docker-compose -f docker-compose.atlas.yml up -d
```

### Backup Files

```bash
# Backup uploads
tar -czf /var/backups/uploads-$(date +%Y%m%d).tar.gz /var/www/bhumi-interior/backend/uploads

# Backup configuration
tar -czf /var/backups/config-$(date +%Y%m%d).tar.gz /var/www/bhumi-interior/.env.production /var/www/bhumi-interior/nginx
```

---

## 🐛 Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose -f docker-compose.atlas.yml logs backend

# Check if port is in use
netstat -tlnp | grep 5000

# Restart Docker
systemctl restart docker
```

### SSL Certificate Issues

```bash
# Check certificate
openssl s_client -connect bhumiinteriorsolution.in:443 -servername bhumiinteriorsolution.in

# Renew certificate
docker-compose -f docker-compose.atlas.yml run --rm certbot renew

# Check expiry
echo | openssl s_client -servername bhumiinteriorsolution.in -connect bhumiinteriorsolution.in:443 2>/dev/null | openssl x509 -noout -dates
```

### MongoDB Connection Issues

```bash
# Test connection
mongo "your-connection-string"

# Check MongoDB Atlas:
# 1. Network Access - whitelist your server IP
# 2. Database Access - verify user permissions
# 3. Connection string - verify it's correct
```

For more troubleshooting, see [DEPLOYMENT.md](./DEPLOYMENT.md)

---

## 📞 Support & Contact

* **Email**: bhumiinteriorsolution@gmail.com
* **Phone**: +91 92281 04285
* **Website**: [bhumiinteriorsolution.in](https://bhumiinteriorsolution.in)
* **GitHub**: [Repository](https://github.com/kenilGamer/Bhumi-interior-solution)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

* **React Team** - For the amazing frontend framework
* **Express.js Team** - For the robust backend framework
* **MongoDB Team** - For the flexible database solution
* **Vite Team** - For the lightning-fast build tool
* **Tailwind CSS Team** - For the utility-first CSS framework
* **Docker Team** - For containerization platform
* **Let's Encrypt** - For free SSL certificates

---

## 🔒 Security

* JWT-based authentication
* Bcrypt password hashing
* Helmet.js security headers
* Rate limiting
* HTTPS/SSL encryption
* CORS protection
* Input validation
* File upload restrictions

---

## 📈 Performance

* CDN-ready static assets
* Gzip compression
* Image optimization
* Lazy loading
* Code splitting
* Browser caching
* HTTP/2 support

---

**🌟 If you found this project helpful, please give it a star! 🌟**

Made with ❤️ by Bhumi Interior Solution Team

---

*Last Updated: October 8, 2025*