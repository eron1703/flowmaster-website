#!/usr/bin/env bash

###############################################################################
## FlowMaster Website - Production WordPress Setup
## Installs WordPress with Elementor and required plugins
###############################################################################

set -e

echo "Waiting for WordPress to fully initialize..."
sleep 20

# WordPress installation
echo "Installing WordPress..."
docker compose -f docker-compose.production.yml exec -T wpcli wp core install \
    --url="https://flow-master.tech" \
    --title="FlowMaster - Next-Generation Process Management" \
    --admin_user="flowmaster_admin" \
    --admin_password="FlowMaster2025!Secure" \
    --admin_email="admin@flow-master.tech" \
    --skip-email

echo "✓ WordPress installed"

# Install and activate Elementor
echo "Installing Elementor..."
docker compose -f docker-compose.production.yml exec -T wpcli wp plugin install elementor --activate
echo "✓ Elementor installed"

# Install other required plugins
echo "Installing additional plugins..."
docker compose -f docker-compose.production.yml exec -T wpcli wp plugin install contact-form-7 --activate
docker compose -f docker-compose.production.yml exec -T wpcli wp plugin install wp-mail-smtp --activate
docker compose -f docker-compose.production.yml exec -T wpcli wp plugin install wordfence --activate
echo "✓ Plugins installed"

# Install and activate Astra theme
echo "Installing Astra theme..."
docker compose -f docker-compose.production.yml exec -T wpcli wp theme install astra --activate
echo "✓ Astra theme installed"

# Create pages
echo "Creating pages..."
docker compose -f docker-compose.production.yml exec -T wpcli wp post create --post_type=page --post_status=publish --post_title='Home' --post_content='<!-- wp:paragraph --><p>Welcome to FlowMaster</p><!-- /wp:paragraph -->'
docker compose -f docker-compose.production.yml exec -T wpcli wp post create --post_type=page --post_status=publish --post_title='Company' --post_content='<!-- wp:paragraph --><p>About FlowMaster</p><!-- /wp:paragraph -->'
docker compose -f docker-compose.production.yml exec -T wpcli wp post create --post_type=page --post_status=publish --post_title='Platform' --post_content='<!-- wp:paragraph --><p>FlowMaster Platform</p><!-- /wp:paragraph -->'
docker compose -f docker-compose.production.yml exec -T wpcli wp post create --post_type=page --post_status=publish --post_title='Industries' --post_content='<!-- wp:paragraph --><p>Industries We Serve</p><!-- /wp:paragraph -->'
docker compose -f docker-compose.production.yml exec -T wpcli wp post create --post_type=page --post_status=publish --post_title='Careers' --post_content='<!-- wp:paragraph --><p>Join Our Team</p><!-- /wp:paragraph -->'
docker compose -f docker-compose.production.yml exec -T wpcli wp post create --post_type=page --post_status=publish --post_title='Contact' --post_content='<!-- wp:paragraph --><p>Contact Us</p><!-- /wp:paragraph -->'
echo "✓ Pages created"

# Set Home page as front page
echo "Configuring front page..."
HOME_ID=$(docker compose -f docker-compose.production.yml exec -T wpcli wp post list --post_type=page --post_title="Home" --field=ID --format=csv | tr -d '\r')
docker compose -f docker-compose.production.yml exec -T wpcli wp option update show_on_front page
docker compose -f docker-compose.production.yml exec -T wpcli wp option update page_on_front "$HOME_ID"
echo "✓ Front page configured"

# Create navigation menu
echo "Creating navigation menu..."
docker compose -f docker-compose.production.yml exec -T wpcli wp menu create "Main Menu"
COMPANY_ID=$(docker compose -f docker-compose.production.yml exec -T wpcli wp post list --post_type=page --post_title="Company" --field=ID --format=csv | tr -d '\r')
PLATFORM_ID=$(docker compose -f docker-compose.production.yml exec -T wpcli wp post list --post_type=page --post_title="Platform" --field=ID --format=csv | tr -d '\r')
INDUSTRIES_ID=$(docker compose -f docker-compose.production.yml exec -T wpcli wp post list --post_type=page --post_title="Industries" --field=ID --format=csv | tr -d '\r')
CAREERS_ID=$(docker compose -f docker-compose.production.yml exec -T wpcli wp post list --post_type=page --post_title="Careers" --field=ID --format=csv | tr -d '\r')
CONTACT_ID=$(docker compose -f docker-compose.production.yml exec -T wpcli wp post list --post_type=page --post_title="Contact" --field=ID --format=csv | tr -d '\r')

docker compose -f docker-compose.production.yml exec -T wpcli wp menu item add-post main-menu "$COMPANY_ID"
docker compose -f docker-compose.production.yml exec -T wpcli wp menu item add-post main-menu "$PLATFORM_ID"
docker compose -f docker-compose.production.yml exec -T wpcli wp menu item add-post main-menu "$INDUSTRIES_ID"
docker compose -f docker-compose.production.yml exec -T wpcli wp menu item add-post main-menu "$CAREERS_ID"
docker compose -f docker-compose.production.yml exec -T wpcli wp menu item add-post main-menu "$CONTACT_ID"

docker compose -f docker-compose.production.yml exec -T wpcli wp menu location assign main-menu primary
echo "✓ Navigation menu created"

echo ""
echo "========================================="
echo "WordPress Setup Complete!"
echo "========================================="
echo ""
echo "Admin URL: https://flow-master.tech/wp-admin"
echo "Username: flowmaster_admin"
echo "Password: FlowMaster2025!Secure"
echo ""
echo "Next: Design pages with Elementor at:"
echo "https://flow-master.tech/wp-admin/post.php?post=\$HOME_ID&action=elementor"
echo ""
