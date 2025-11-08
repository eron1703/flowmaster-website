#!/usr/bin/env bash

##
## WordPress Setup Script for FlowMaster Website
## Automates initial WordPress configuration
##

set -e

echo "Starting WordPress setup..."

# Wait for WordPress to be ready
echo "Waiting for WordPress to initialize..."
sleep 15

# Install WordPress
echo "Installing WordPress core..."
docker compose exec -T wpcli wp core install \
    --url="http://localhost:8090" \
    --title="FlowMaster - AI Business Process Automation" \
    --admin_user="flowmaster_admin" \
    --admin_password="FlowMaster2025!Secure" \
    --admin_email="admin@flowmaster.ai" \
    --skip-email

echo "WordPress installed successfully"

# Configure permalinks
echo "Configuring permalinks..."
docker compose exec -T wpcli wp rewrite structure '/%postname%/'

# Set timezone
docker compose exec -T wpcli wp option update timezone_string 'UTC'

# Configure site settings
docker compose exec -T wpcli wp option update blogdescription 'AI-Powered Business Process Automation Platform'

# Disable comments
docker compose exec -T wpcli wp option update default_comment_status 'closed'

# Install and activate Elementor
echo "Installing Elementor..."
docker compose exec -T wpcli wp plugin install elementor --activate

# Install Elementor Pro (if available)
# docker compose exec -T wpcli wp plugin install elementor-pro --activate

# Install essential plugins
echo "Installing essential plugins..."
docker compose exec -T wpcli wp plugin install contact-form-7 --activate
docker compose exec -T wpcli wp plugin install wp-mail-smtp --activate
docker compose exec -T wpcli wp plugin install wordfence --activate

# Install theme (Astra - lightweight and Elementor-compatible)
echo "Installing Astra theme..."
docker compose exec -T wpcli wp theme install astra --activate

# Create homepage
echo "Creating pages..."
docker compose exec -T wpcli wp post create \
    --post_type=page \
    --post_title='Home' \
    --post_status=publish \
    --post_content='<!-- wp:paragraph --><p>Welcome to FlowMaster</p><!-- /wp:paragraph -->'

# Create other pages
docker compose exec -T wpcli wp post create \
    --post_type=page \
    --post_title='Company' \
    --post_status=publish

docker compose exec -T wpcli wp post create \
    --post_type=page \
    --post_title='Platform' \
    --post_status=publish

docker compose exec -T wpcli wp post create \
    --post_type=page \
    --post_title='Industries' \
    --post_status=publish

docker compose exec -T wpcli wp post create \
    --post_type=page \
    --post_title='Careers' \
    --post_status=publish

docker compose exec -T wpcli wp post create \
    --post_type=page \
    --post_title='Contact' \
    --post_status=publish

# Set homepage
HOME_ID=$(docker compose exec -T wpcli wp post list --post_type=page --name=home --field=ID --format=ids)
docker compose exec -T wpcli wp option update show_on_front 'page'
docker compose exec -T wpcli wp option update page_on_front "$HOME_ID"

# Create menu
echo "Creating navigation menu..."
docker compose exec -T wpcli wp menu create "Main Menu"
MENU_ID=$(docker compose exec -T wpcli wp menu list --format=ids)

# Add pages to menu
docker compose exec -T wpcli wp menu item add-post main-menu $(docker compose exec -T wpcli wp post list --post_type=page --name=home --field=ID --format=ids)
docker compose exec -T wpcli wp menu item add-post main-menu $(docker compose exec -T wpcli wp post list --post_type=page --name=company --field=ID --format=ids)
docker compose exec -T wpcli wp menu item add-post main-menu $(docker compose exec -T wpcli wp post list --post_type=page --name=platform --field=ID --format=ids)
docker compose exec -T wpcli wp menu item add-post main-menu $(docker compose exec -T wpcli wp post list --post_type=page --name=industries --field=ID --format=ids)
docker compose exec -T wpcli wp menu item add-post main-menu $(docker compose exec -T wpcli wp post list --post_type=page --name=careers --field=ID --format=ids)
docker compose exec -T wpcli wp menu item add-post main-menu $(docker compose exec -T wpcli wp post list --post_type=page --name=contact --field=ID --format=ids)

# Assign menu to primary location
docker compose exec -T wpcli wp menu location assign main-menu primary

echo ""
echo "Setup complete!"
echo ""
echo "WordPress Admin: http://localhost:8090/wp-admin"
echo "Username: flowmaster_admin"
echo "Password: FlowMaster2025!Secure"
echo ""
echo "Next step: Run ./setup-elementor.sh to configure Elementor pages"
