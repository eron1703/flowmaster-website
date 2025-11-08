# DNS Configuration for flow-master.tech

## Bluehost DNS Settings

To point your domain **flow-master.tech** to your dev server, you need to configure DNS records in Bluehost.

### Step-by-Step Instructions

#### 1. Access DNS Manager

1. Log in to your Bluehost account
2. Navigate to **Domains** → **flow-master.tech**
3. Click on **DNS** tab (as shown in your screenshot)

#### 2. Add/Update A Records

You need to add the following DNS records:

| Type | Host Record | Points To | TTL |
|------|-------------|-----------|-----|
| A | @ | 91.99.237.14 | 14400 (4 hours) |
| A | www | 91.99.237.14 | 14400 (4 hours) |

**Instructions:**

1. Click **ADD RECORD** button
2. Select **Type**: A
3. **Host Record**: @ (for root domain) or www (for www subdomain)
4. **Points To**: 91.99.237.14
5. **TTL**: 14400 (or leave default)
6. Click **ADD RECORD** to save

#### 3. Remove Conflicting Records (If Any)

If there are existing A records pointing to different IPs:
1. Find the old A records
2. Click the trash icon or delete option
3. Confirm deletion

#### 4. Verify Configuration

After adding the records, wait 24-48 hours for DNS propagation (usually faster).

**Check DNS propagation:**
```bash
# From your terminal
dig flow-master.tech
dig www.flow-master.tech

# Or use online tool
https://www.whatsmydns.net/#A/flow-master.tech
```

Expected result:
```
flow-master.tech.  14400  IN  A  91.99.237.14
www.flow-master.tech.  14400  IN  A  91.99.237.14
```

### Optional: Email Configuration

If you want to keep email services on Bluehost while hosting the website on your server:

Add these MX records:

| Type | Host | Points To | Priority | TTL |
|------|------|-----------|----------|-----|
| MX | @ | mx1.bluehost.com | 10 | 14400 |
| MX | @ | mx2.bluehost.com | 20 | 14400 |

### Complete DNS Record Set

After configuration, your DNS should look like:

```
Type   Host    Points To              TTL     Priority
A      @       91.99.237.14          14400   -
A      www     91.99.237.14          14400   -
MX     @       mx1.bluehost.com      14400   10
MX     @       mx2.bluehost.com      14400   20
```

## Troubleshooting

### DNS not propagating?

1. **Clear local DNS cache:**
   ```bash
   # macOS
   sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

   # Linux
   sudo systemd-resolve --flush-caches
   ```

2. **Check current DNS:**
   ```bash
   nslookup flow-master.tech
   ```

3. **Use different DNS servers to check:**
   ```bash
   dig @8.8.8.8 flow-master.tech  # Google DNS
   dig @1.1.1.1 flow-master.tech  # Cloudflare DNS
   ```

### Still showing old IP?

- Wait longer (DNS can take up to 48 hours)
- Check if nameservers are correct (should be Bluehost nameservers)
- Verify no typos in IP address

### Certificate errors?

If you see SSL certificate errors:
1. Wait for DNS to fully propagate before running SSL setup
2. Make sure both @ and www records point to 91.99.237.14
3. Re-run the SSL certificate command on the server

## After DNS Configuration

Once DNS is pointing correctly:

1. Run the deployment script:
   ```bash
   ./deploy-to-server.sh
   ```

2. The script will:
   - Deploy code to the server
   - Start Docker containers
   - Configure Nginx
   - Install SSL certificate
   - Configure WordPress URLs

3. Access your site:
   - **Website**: https://flow-master.tech
   - **Admin**: https://flow-master.tech/wp-admin

## Security Notes

- SSL certificate auto-renews every 90 days via Certbot
- Always use HTTPS (HTTP redirects to HTTPS automatically)
- Keep WordPress and plugins updated
- Use strong passwords in .env file

## Support

If you encounter issues:
1. Check DNS propagation status
2. Verify server is accessible: `ping 91.99.237.14`
3. Check Nginx logs: `ssh server "sudo tail -f /var/log/nginx/flowmaster-error.log"`
4. Check Docker logs: `ssh server "cd /srv/projects/flowmaster-website && docker compose logs -f"`
