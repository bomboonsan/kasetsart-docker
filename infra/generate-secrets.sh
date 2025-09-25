#!/bin/bash
# Generate secrets for Strapi deployment
# Usage: ./generate-secrets.sh

echo "🔐 Generating secrets for Strapi deployment..."
echo ""

echo "# Generated secrets for Strapi - $(date)" > secrets.env
echo "# Copy these values to your .env file" >> secrets.env
echo "" >> secrets.env

echo "APP_KEYS=$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32)" >> secrets.env
echo "API_TOKEN_SALT=$(openssl rand -base64 32)" >> secrets.env
echo "ADMIN_JWT_SECRET=$(openssl rand -base64 32)" >> secrets.env
echo "TRANSFER_TOKEN_SALT=$(openssl rand -base64 32)" >> secrets.env
echo "ENCRYPTION_KEY=$(openssl rand -base64 32)" >> secrets.env
echo "JWT_SECRET=$(openssl rand -base64 32)" >> secrets.env
echo "NEXTAUTH_SECRET=$(openssl rand -base64 32)" >> secrets.env

echo "# Database passwords" >> secrets.env
echo "MYSQL_PASSWORD=$(openssl rand -base64 32 | tr -d /=+ | cut -c -25)" >> secrets.env
echo "MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32 | tr -d /=+ | cut -c -25)" >> secrets.env

echo "✅ Secrets generated successfully!"
echo "📄 Check the 'secrets.env' file and copy values to your .env file"
echo ""
echo "⚠️  Important: Delete the 'secrets.env' file after copying the values!"
echo ""
cat secrets.env