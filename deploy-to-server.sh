#!/usr/bin/env bash

###############################################################################
## FlowMaster Website - Production Deployment Script
## Deploys WordPress to dev server with SSL and domain configuration
###############################################################################

set -e

# Configuration
SERVER="server"  # SSH alias
SERVER_IP="91.99.237.14"
DOMAIN="flow-master.tech"
PROJECT_PATH="/srv/projects/flowmaster-website"
REPO_URL="https://github.com/eron1703/flowmaster-website.git"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "========================================="
log_info "FlowMaster Website Deployment"
log_info "Domain: $DOMAIN"
log_info "Server: $SERVER_IP"
log_info "========================================="
echo ""

# Step 1: Test SSH connection
log_info "Step 1: Testing SSH connection..."
if ssh $SERVER "echo 'Connected'" > /dev/null 2>&1; then
    log_info "✓ SSH connection successful"
else
    log_error "SSH connection failed. Check your SSH configuration."
    exit 1
fi

# Step 2: Clone/Update repository
log_info "Step 2: Deploying code to server..."
ssh $SERVER "
    if [ -d '$PROJECT_PATH' ]; then
        echo 'Repository exists, pulling latest changes...'
        cd $PROJECT_PATH
        git pull origin main
    else
        echo 'Cloning repository...'
        cd /srv/projects
        git clone $REPO_URL
    fi
"
log_info "✓ Code deployed"

# Step 3: Create environment file
log_info "Step 3: Configuring environment variables..."
ssh $SERVER "
    cd $PROJECT_PATH
    if [ ! -f .env ]; then
        cp .env.production .env
        echo 'Created .env file - IMPORTANT: Update passwords before proceeding!'
        echo 'Edit the file: nano .env'
    else
        echo '.env file already exists'
    fi
"
log_warn "IMPORTANT: Update .env file with secure passwords on the server!"

# Step 4: Start Docker containers
log_info "Step 4: Starting Docker containers..."
ssh $SERVER "
    cd $PROJECT_PATH
    docker compose -f docker-compose.production.yml down
    docker compose -f docker-compose.production.yml up -d
    echo 'Waiting for containers to initialize...'
    sleep 15
    docker compose -f docker-compose.production.yml ps
"
log_info "✓ Docker containers started"

# Step 5: Configure Nginx
log_info "Step 5: Configuring Nginx..."
ssh $SERVER "
    # Copy Nginx config
    sudo cp $PROJECT_PATH/nginx-flowmaster.conf /etc/nginx/sites-available/flow-master.tech

    # Enable site
    sudo ln -sf /etc/nginx/sites-available/flow-master.tech /etc/nginx/sites-enabled/

    # Create certbot directory
    sudo mkdir -p /var/www/certbot

    # Test Nginx configuration
    sudo nginx -t
"
log_info "✓ Nginx configured"

# Step 6: Restart Nginx
log_info "Step 6: Restarting Nginx..."
ssh $SERVER "sudo systemctl reload nginx"
log_info "✓ Nginx reloaded"

# Step 7: Install SSL certificate
log_info "Step 7: Setting up SSL with Let's Encrypt..."
log_warn "Make sure DNS is pointed to $SERVER_IP before continuing!"
read -p "Press Enter when DNS is configured (or Ctrl+C to cancel)..."

ssh $SERVER "
    # Install certbot if not present
    if ! command -v certbot &> /dev/null; then
        echo 'Installing Certbot...'
        sudo apt-get update
        sudo apt-get install -y certbot python3-certbot-nginx
    fi

    # Obtain SSL certificate
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

    # Set up auto-renewal
    sudo systemctl enable certbot.timer
    sudo systemctl start certbot.timer
"
log_info "✓ SSL certificate installed"

# Step 8: Final Nginx reload
log_info "Step 8: Final Nginx reload with SSL..."
ssh $SERVER "sudo systemctl reload nginx"
log_info "✓ Nginx reloaded with SSL"

# Step 9: Configure WordPress URL
log_info "Step 9: Configuring WordPress for production domain..."
ssh $SERVER "
    cd $PROJECT_PATH
    docker compose -f docker-compose.production.yml exec -T wpcli wp option update siteurl 'https://$DOMAIN'
    docker compose -f docker-compose.production.yml exec -T wpcli wp option update home 'https://$DOMAIN'
"
log_info "✓ WordPress URLs configured"

echo ""
log_info "========================================="
log_info "Deployment Complete!"
log_info "========================================="
echo ""
log_info "Your FlowMaster website is now live at:"
echo ""
echo "  🌐 https://$DOMAIN"
echo "  🔒 SSL: Enabled"
echo "  👤 Admin: https://$DOMAIN/wp-admin"
echo ""
log_info "Next steps:"
echo "  1. Update .env with secure passwords"
echo "  2. Complete WordPress setup in browser"
echo "  3. Design pages with Elementor"
echo ""
log_warn "DNS Configuration Required:"
echo "  - Point $DOMAIN to $SERVER_IP"
echo "  - Add A record: @ → $SERVER_IP"
echo "  - Add A record: www → $SERVER_IP"
echo ""
