# Strapi v5 - build from repo
FROM node:20-alpine AS base

# deps stage
FROM base AS deps
RUN apk add --no-cache libc6-compat git
WORKDIR /app
RUN git clone https://github.com/bomboonsan/kasetsart-strapi.git .
# ติดตั้งเฉพาะ prod deps (repo ควรล็อก lockfile)
RUN npm ci --only=production && npm cache clean --force

# build stage
FROM base AS build
RUN apk add --no-cache libc6-compat git
WORKDIR /app
# ใช้ node_modules จาก deps
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app .
# Build Strapi
RUN npm run build

# production runtime
FROM base AS production
RUN apk add --no-cache libc6-compat
WORKDIR /app

# สร้าง user ไม่ใช่ root
RUN addgroup -g 1001 -S strapi && adduser -S strapi -u 1001

# คัดลอกไฟล์ที่ต้องใช้รันจริง
COPY --from=deps /app/package.json ./package.json
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build --chown=strapi:strapi /app/dist ./dist
COPY --from=build --chown=strapi:strapi /app/.strapi ./.strapi
COPY --from=build --chown=strapi:strapi /app/public ./public
COPY --from=build --chown=strapi:strapi /app/config ./config
COPY --from=build --chown=strapi:strapi /app/src ./src
COPY --from=build --chown=strapi:strapi /app/types ./types

# อัปโหลดเก็บใน volume
RUN mkdir -p public/uploads && chown -R strapi:strapi public/uploads

USER strapi
ENV NODE_ENV=production
EXPOSE 1337

CMD ["npm", "start"]
