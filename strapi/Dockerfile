# Strapi Dockerfile
# Repo https://github.com/bomboonsan/kasetsart-strapi.git

FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat git

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/bomboonsan/kasetsart-strapi.git .

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Development stage
FROM base AS development
RUN apk add --no-cache libc6-compat git

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/bomboonsan/kasetsart-strapi.git .

# Install all dependencies including devDependencies
RUN npm ci

# Copy all files
# Build stage
FROM base AS build
WORKDIR /app

# Copy dependencies
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app .

# Build the application
RUN npm run build

# Production stage
FROM base AS production
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Create strapi user
RUN addgroup -g 1001 -S strapi
RUN adduser -S strapi -u 1001

# Copy production dependencies
COPY --from=deps /app/node_modules ./node_modules
# Copy built application
COPY --from=build --chown=strapi:strapi /app/dist ./dist
COPY --from=build --chown=strapi:strapi /app/build ./build
COPY --from=build --chown=strapi:strapi /app/public ./public
COPY --from=build --chown=strapi:strapi /app/package.json ./package.json
COPY --from=build --chown=strapi:strapi /app/database ./database
COPY --from=build --chown=strapi:strapi /app/config ./config
COPY --from=build --chown=strapi:strapi /app/src ./src

# Create uploads directory
RUN mkdir -p public/uploads && chown -R strapi:strapi public/uploads

USER strapi

EXPOSE 1337

ENV NODE_ENV=production

CMD ["npm", "start"]