# DEPLOYMENT GUIDE

**Application:** Lingola Travel Backend  
**Target Platform:** Linux Server / VPS / Cloud Hosting

---

## 📋 PRE-DEPLOYMENT CHECKLIST

### 1. Server Requirements
- [ ] Ubuntu 20.04+ or CentOS 8+
- [ ] Node.js 18+ installed
- [ ] MySQL 8.0+ installed
- [ ] Minimum 2GB RAM
- [ ] Minimum 20GB disk space
- [ ] Root or sudo access

### 2. Domain & SSL
- [ ] Domain name configured (e.g., api.lingolatravel.com)
- [ ] DNS A record pointing to server IP
- [ ] SSL certificate obtained (Let's Encrypt or commercial)

### 3. Security
- [ ] Firewall configured (UFW or firewalld)
- [ ] SSH key authentication enabled
- [ ] Root login disabled
- [ ] Fail2ban installed

---

## 🚀 DEPLOYMENT STEPS

### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install MySQL
sudo apt install -y mysql-server

# Secure MySQL installation
sudo mysql_secure_installation

# Install Nginx (reverse proxy)
sudo apt install -y nginx

# Install PM2 (process manager)
sudo npm install -g pm2
```

### Step 2: Create Application User

```bash
# Create dedicated user
sudo adduser lingola --disabled-password

# Grant sudo privileges (optional)
sudo usermod -aG sudo lingola

# Switch to app user
su - lingola
```

### Step 3: Clone Repository

```bash
cd /home/lingola
git clone <your-repository-url> lingola-backend
cd lingola-backend/backend
```

### Step 4: Install Dependencies

```bash
npm install --production
```

### Step 5: Configure Environment

```bash
cp .env.example .env
nano .env
```

**Critical Production Values:**
```bash
NODE_ENV=production
PORT=3000

# Database (local or remote)
DB_HOST=localhost
DB_PORT=3306
DB_NAME=lingola_travel
DB_USER=lingola_app
DB_PASSWORD=STRONG_PASSWORD_HERE

# Generate secure secrets
JWT_SECRET=<generate-with-crypto>
JWT_REFRESH_SECRET=<generate-with-crypto>

# CORS (your app domains only)
CORS_ORIGINS=https://app.lingolatravel.com,https://www.lingolatravel.com

# Social Auth (production keys)
GOOGLE_CLIENT_ID_IOS=...
GOOGLE_CLIENT_ID_ANDROID=...
# ... etc
```

Generate secrets:
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

### Step 6: Database Setup

```bash
# Create database
mysql -u root -p
```

```sql
CREATE DATABASE lingola_travel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create application user (least privilege)
CREATE USER 'lingola_app'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD';
GRANT SELECT, INSERT, UPDATE, DELETE ON lingola_travel.* TO 'lingola_app'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```bash
# Run migrations
node src/utils/migrate.js
```

### Step 7: Configure PM2

```bash
# Create PM2 ecosystem file
nano ecosystem.config.js
```

```javascript
module.exports = {
  apps: [{
    name: 'lingola-backend',
    script: './src/server.js',
    instances: 2, // Use 2 CPU cores
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '500M'
  }]
};
```

```bash
# Create logs directory
mkdir -p logs

# Start application
pm2 start ecosystem.config.js

# Save PM2 process list
pm2 save

# Enable PM2 startup on boot
pm2 startup
# Follow the printed command
```

### Step 8: Configure Nginx Reverse Proxy

```bash
sudo nano /etc/nginx/sites-available/lingola-backend
```

```nginx
server {
    listen 80;
    server_name api.lingolatravel.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.lingolatravel.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/api.lingolatravel.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.lingolatravel.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Proxy to Node.js backend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 60s;
    }

    # Health check (bypass for monitoring)
    location /health {
        access_log off;
        proxy_pass http://localhost:3000/health;
    }

    # Limit request size
    client_max_body_size 10M;
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/lingola-backend /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### Step 9: SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d api.lingolatravel.com

# Test auto-renewal
sudo certbot renew --dry-run
```

### Step 10: Configure Firewall

```bash
# Enable UFW
sudo ufw enable

# Allow SSH
sudo ufw allow OpenSSH

# Allow HTTP/HTTPS
sudo ufw allow 'Nginx Full'

# Block MySQL from external access
sudo ufw deny 3306

# Check status
sudo ufw status
```

---

## 🔒 POST-DEPLOYMENT SECURITY

### 1. Harden MySQL
```sql
-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Remove remote root
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1');

-- Secure root password
ALTER USER 'root'@'localhost' IDENTIFIED BY 'VERY_STRONG_PASSWORD';

FLUSH PRIVILEGES;
```

### 2. Configure Automated Backups

```bash
# Create backup script
sudo nano /home/lingola/backup-db.sh
```

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/lingola/backups"
DB_NAME="lingola_travel"

mkdir -p $BACKUP_DIR

mysqldump -u lingola_app -p'PASSWORD' $DB_NAME | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Keep only last 30 days
find $BACKUP_DIR -name "db_*.sql.gz" -mtime +30 -delete
```

```bash
chmod +x /home/lingola/backup-db.sh

# Schedule daily backup (2 AM)
crontab -e
```

```
0 2 * * * /home/lingola/backup-db.sh >> /home/lingola/logs/backup.log 2>&1
```

### 3. Setup Monitoring

```bash
# PM2 monitoring
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7

# View logs
pm2 logs lingola-backend --lines 100

# Monitor processes
pm2 monit
```

---

## 📊 HEALTH CHECKS

```bash
# Test health endpoint
curl https://api.lingolatravel.com/health

# Expected response:
{
  "status": "OK",
  "timestamp": "2026-02-08T12:00:00.000Z",
  "version": "v1",
  "environment": "production"
}

# Test authentication endpoint
curl -X POST https://api.lingolatravel.com/api/v1/auth/anonymous \
  -H "Content-Type: application/json" \
  -d '{"deviceId":"test-device-123"}'
```

---

## 🔄 UPDATES & MAINTENANCE

### Deploying Updates

```bash
# Pull latest code
cd /home/lingola/lingola-backend/backend
git pull origin main

# Install new dependencies
npm install --production

# Restart app (zero-downtime with PM2 cluster mode)
pm2 reload ecosystem.config.js

# Check logs
pm2 logs lingola-backend --lines 50
```

### Database Migrations

```bash
# Backup before migration
/home/lingola/backup-db.sh

# Run new migrations
node src/utils/migrate.js

# Restart app if needed
pm2 restart lingola-backend
```

---

## 🚨 TROUBLESHOOTING

### App Won't Start
```bash
# Check logs
pm2 logs lingola-backend

# Check database connection
mysql -u lingola_app -p lingola_travel

# Check environment variables
cat .env | grep -v PASSWORD
```

### High Memory Usage
```bash
# Check PM2 status
pm2 status

# Restart app
pm2 restart lingola-backend
```

### 502 Bad Gateway
```bash
# Check if app is running
pm2 status

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log

# Restart services
pm2 restart lingola-backend
sudo systemctl restart nginx
```

---

## 📈 SCALING

### Horizontal Scaling (Multiple Servers)
- Use PM2 cluster mode (already configured)
- Add load balancer (Nginx, HAProxy, or cloud LB)
- Configure database replication (master-slave)

### Vertical Scaling
- Increase server RAM
- Upgrade to more CPU cores
- Optimize database indexes

---

## 🎯 PRODUCTION READY CHECKLIST

- [x] NODE_ENV=production
- [x] Secure JWT secrets generated
- [x] Database user with least privilege
- [x] HTTPS/SSL configured
- [x] CORS restricted to app domains
- [x] Firewall enabled
- [x] PM2 process manager
- [x] Nginx reverse proxy
- [x] Automated backups
- [x] Log rotation
- [ ] Monitoring/alerting setup (TODO: Sentry, Datadog)
- [ ] CDN for static assets (TODO)
- [ ] Rate limiting tested under load

---

**Support:** devops@lingolatravel.com  
**Last Updated:** February 8, 2026
