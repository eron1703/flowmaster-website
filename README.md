# FlowMaster Official Website

Professional WordPress + Elementor multi-page corporate website for FlowMaster AI Business Process Automation Platform.

## Overview

This is the official FlowMaster website featuring:
- Modern, professional design
- Multi-page structure (Home, Company, Platform, Industries, Careers)
- WordPress CMS with Elementor page builder
- Dockerized for easy deployment
- Hosted on dev server: http://91.99.237.14:8090

## Architecture

```
flowmaster-website/
├── docker-compose.yml          # Docker orchestration
├── uploads.ini                 # PHP configuration
├── wp-content/                 # WordPress themes, plugins, uploads
├── setup-wordpress.sh          # Automated WordPress setup
├── setup-elementor.sh          # Automated Elementor installation
└── deploy-to-server.sh         # Deploy to dev server
```

## Services

- **WordPress**: Port 8090 (Local), Port 8090 (Dev Server)
- **MySQL**: Internal database
- **WP-CLI**: WordPress command line interface

## Quick Start

### Local Development

```bash
# Start Docker containers
docker compose up -d

# Wait for services to initialize (30 seconds)
sleep 30

# Setup WordPress
./setup-wordpress.sh

# Install Elementor and create pages
./setup-elementor.sh

# Access site
open http://localhost:8090
```

### Deploy to Dev Server

```bash
# Deploy to 91.99.237.14
./deploy-to-server.sh
```

## WordPress Admin

- **URL**: http://localhost:8090/wp-admin
- **Username**: flowmaster_admin
- **Password**: FlowMaster2025!Secure

## Database Credentials

- **Host**: db:3306
- **Database**: flowmaster_website
- **User**: flowmaster_wp
- **Password**: flowmaster_wp_secure_2025

## Site Structure

### Home Page
- Hero section with value proposition
- Key features overview
- Platform capabilities
- Industries served
- Call-to-action sections

### Company Page
- About FlowMaster
- Mission and vision
- Team information
- Company values
- Contact information

### Platform Page
- Process Designer features
- AI Agent capabilities
- Integration options
- Technical architecture
- Live demo section

### Industries Page
- Healthcare / Insurance
- Aviation / Air Cargo
- Financial Services
- Custom solutions
- Case studies

### Careers Page
- Open positions
- Company culture
- Benefits
- Application process

## Elementor Templates

All pages built with Elementor Pro using:
- Header template (global)
- Footer template (global)
- Custom page templates
- Responsive design
- Professional color scheme

## Deployment

### Dev Server (91.99.237.14)

```bash
# Clone repository
ssh server "cd /srv/projects && git clone https://github.com/eron1703/flowmaster-website.git"

# Start services
ssh server "cd /srv/projects/flowmaster-website && docker compose up -d"

# Setup WordPress
ssh server "cd /srv/projects/flowmaster-website && ./setup-wordpress.sh"

# Access
open http://91.99.237.14:8090
```

## Backup

```bash
# Backup database
docker compose exec db mysqldump -u flowmaster_wp -pflowmaster_wp_secure_2025 flowmaster_website > backup.sql

# Backup wp-content
tar -czf wp-content-backup.tar.gz wp-content/
```

## Restore

```bash
# Restore database
docker compose exec -T db mysql -u flowmaster_wp -pflowmaster_wp_secure_2025 flowmaster_website < backup.sql

# Restore wp-content
tar -xzf wp-content-backup.tar.gz
```

## Testing

Automated testing with Puppeteer:
```bash
node test-website.js
```

Tests:
- Page load performance
- Responsive design
- Navigation functionality
- Form submissions
- Cross-browser compatibility

## Maintenance

### Update WordPress
```bash
docker compose exec wpcli wp core update
```

### Update Plugins
```bash
docker compose exec wpcli wp plugin update --all
```

### Clear Cache
```bash
docker compose exec wpcli wp cache flush
```

## Support

For issues or questions:
1. Check Docker logs: `docker compose logs -f wordpress`
2. Check database connection: `docker compose exec db mysql -u flowmaster_wp -pflowmaster_wp_secure_2025`
3. Restart services: `docker compose restart`

## Security

- All passwords are strong and unique
- WordPress security hardening enabled
- Regular backups scheduled
- SSL/TLS ready for production

## License

Private - FlowMaster Internal Use Only
