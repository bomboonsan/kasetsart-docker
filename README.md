# Kasetsart App - VPS Deployment Guide

## 🏗️ Architecture

```
┌─── Caddy (Reverse Proxy & SSL) ──┐
│  fahsai.bus.ku.ac.th             │
├─── / → Next.js (Port 3000) ──────┤
├─── /strapi/* → Strapi (1337) ────┤
├─── /phpmyadmin/* → phpMyAdmin ────┤
└─── MySQL Database (Port 3306) ───┘
```

## 📋 Prerequisites

- Docker & Docker Compose installed on VPS
- Domain pointed to your VPS IP
- Git installed (for cloning repositories)

## 🚀 Quick Deployment

1. **Clone this repository to your VPS:**
   ```bash
   git clone <your-deployment-repo> kasetsart-deploy
   cd kasetsart-deploy/docker/infra
   ```

2. **Copy and configure environment:**
   ```bash
   cp .env.example .env
   nano .env  # Edit with your settings
   ```

3. **Deploy:**
   ```bash
   ./deploy.sh
   ```

## 🔧 Configuration

### Environment Variables (.env)

```bash
# Domain Configuration
PUBLIC_BASE_URL=https://fahsai.bus.ku.ac.th

# MySQL Database
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DATABASE=kasetsart
MYSQL_USER=kasetuser
MYSQL_PASSWORD=your_secure_password
MYSQL_ROOT_PASSWORD=your_root_password

# Strapi Configuration
APP_KEYS=generate_your_app_keys
API_TOKEN_SALT=generate_your_token_salt
ADMIN_JWT_SECRET=generate_your_admin_jwt_secret
TRANSFER_TOKEN_SALT=generate_your_transfer_token_salt
ENCRYPTION_KEY=generate_your_encryption_key
JWT_SECRET=generate_your_jwt_secret

# Next.js Configuration
NEXT_PUBLIC_API_URL=https://fahsai.bus.ku.ac.th/strapi/api
STRAPI_INTERNAL_URL=http://strapi:1337/api
NEXTAUTH_SECRET=generate_your_nextauth_secret
NEXTAUTH_URL=https://fahsai.bus.ku.ac.th
API_BASE=https://fahsai.bus.ku.ac.th

# phpMyAdmin
PMA_ABSOLUTE_URI=https://fahsai.bus.ku.ac.th/phpmyadmin
```

## 🔑 Generate Secrets

สำหรับ Strapi secrets ใช้คำสั่ง:
```bash
openssl rand -base64 32
```

สำหรับ NextAuth secret:
```bash
openssl rand -base64 32
```

## 📊 Services

| Service | Port | URL | Description |
|---------|------|-----|-------------|
| Caddy | 80, 443 | https://fahsai.bus.ku.ac.th | Reverse proxy & SSL |
| Next.js | 3000 | / | Frontend application |
| Strapi | 1337 | /strapi/* | Backend API & Admin |
| MySQL | 3306 | - | Database |
| phpMyAdmin | 8080 | /phpmyadmin/* | Database management |

## 📁 Repository Structure

```
docker/
├── infra/
│   ├── docker-compose.yml    # Main orchestration
│   ├── Caddyfile            # Reverse proxy config
│   ├── .env                 # Environment variables
│   ├── deploy.sh            # Deployment script
│   └── README.md            # This file
├── nextjs/
│   └── Dockerfile           # Next.js container
└── strapi/
    └── Dockerfile           # Strapi container
```

## 🚦 Management Commands

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f nextjs
docker-compose logs -f strapi
docker-compose logs -f mysql
```

### Restart Service
```bash
docker-compose restart nextjs
docker-compose restart strapi
```

### Update and Redeploy
```bash
./deploy.sh
```

### Database Backup
```bash
docker exec kasetsart_mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Database Restore
```bash
docker exec -i kasetsart_mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} < backup_file.sql
```

## 🔍 Monitoring

### Check Container Status
```bash
docker-compose ps
```

### Resource Usage
```bash
docker stats
```

### Container Health
```bash
docker-compose exec strapi wget --spider http://localhost:1337/_health
```

## 🐛 Troubleshooting

### Service Won't Start
1. Check logs: `docker-compose logs [service_name]`
2. Verify environment variables in `.env`
3. Check disk space: `df -h`
4. Check memory usage: `free -h`

### Database Connection Issues
1. Verify MySQL is running: `docker-compose ps mysql`
2. Test connection: `docker-compose exec mysql mysql -u root -p`
3. Check database exists: `SHOW DATABASES;`

### SSL Certificate Issues
1. Check Caddy logs: `docker-compose logs caddy`
2. Verify domain DNS points to server IP
3. Ensure ports 80 and 443 are open

### Performance Issues
1. Check resource usage: `docker stats`
2. Optimize MySQL: Add more memory to `mysql` service
3. Scale services if needed

## 📈 Production Optimizations

### MySQL Optimization
Add to docker-compose.yml under mysql service:
```yaml
command: >
  --default-authentication-plugin=mysql_native_password 
  --character-set-server=utf8mb4 
  --collation-server=utf8mb4_unicode_ci
  --innodb-buffer-pool-size=1G
  --max-connections=200
```

### Resource Limits
```yaml
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '0.5'
```

## 🔐 Security Notes

1. Change all default passwords
2. Use strong, unique secrets
3. Regularly update Docker images
4. Monitor access logs
5. Set up firewall rules
6. Regular database backups

## 📞 Support

For issues related to:
- **Next.js Frontend**: Check repository issues
- **Strapi Backend**: Check repository issues  
- **Deployment**: Check this README and logs

## 🔄 Update Process

1. Pull latest code from repositories (handled by Docker build)
2. Run deployment script: `./deploy.sh`
3. Monitor logs for any issues
4. Test all services are working

---

Made with ❤️ for Kasetsart University