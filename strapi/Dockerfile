# ---------- build ----------
FROM node:22-alpine AS build
RUN apk add --no-cache python3 make g++ vips-dev libc6-compat
WORKDIR /opt/app

# ติดตั้งแบบแยก dependencies
COPY package.json package-lock.json ./
RUN npm ci

# คัดลอกซอร์ส Strapi (TypeScript)
COPY . .

# build จาก TypeScript → JavaScript
RUN npm run build

# ---------- runtime ----------
FROM node:22-alpine
RUN apk add --no-cache vips-dev
ENV NODE_ENV=production
WORKDIR /opt/app

# คัดลอกไฟล์ที่จำเป็น
COPY --from=build /opt/app/package.json ./
COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/build ./build
COPY --from=build /opt/app/public ./public

# พอร์ตรันไทม์
EXPOSE 1338

CMD ["node", "node_modules/.bin/strapi", "start"]
