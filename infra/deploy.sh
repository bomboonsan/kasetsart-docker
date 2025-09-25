#!/bin/bash
# Deploy script for Kasetsart App on VPS
# Usage: ./deploy.sh

set -e

echo "🚀 Starting deployment of Kasetsart App..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found! Please create .env file first."
    exit 1
fi

# Load environment variables
source .env

echo "📋 Environment loaded"
echo "   Domain: ${PUBLIC_BASE_URL}"
echo "   Database: ${MYSQL_DATABASE}"

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Remove old images (optional - comment out if you want to keep them)
# echo "🗑️  Removing old images..."
# docker system prune -f

# Build and start services
echo "🔨 Building and starting services..."
docker-compose up --build -d

# Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 30

# Check if services are running
echo "🔍 Checking service status..."
docker-compose ps

# Show logs for debugging
echo "📄 Recent logs:"
docker-compose logs --tail=10

echo "✅ Deployment completed!"
echo "🌐 Your application should be available at: ${PUBLIC_BASE_URL}"
echo "🗃️  phpMyAdmin available at: ${PUBLIC_BASE_URL}/phpmyadmin"
echo "🔧 Strapi Admin available at: ${PUBLIC_BASE_URL}/strapi/admin"

echo ""
echo "📝 Useful commands:"
echo "   View logs: docker-compose logs -f [service_name]"
echo "   Restart service: docker-compose restart [service_name]"
echo "   Stop all: docker-compose down"
echo "   Update and restart: ./deploy.sh"