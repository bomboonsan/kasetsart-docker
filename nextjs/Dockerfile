# syntax=docker/dockerfile:1.7

########## Builder: clone + build ##########
FROM node:22-alpine AS builder
WORKDIR /src
# ไม่จำเป็นต้องใช้ openssh แล้ว
RUN apk update && apk upgrade && apk add --no-cache git

# เปลี่ยนไปใช้ HTTPS URL สำหรับ Public Repository
ARG REPO=https://github.com/bomboonsan/kasetsart-nextjs.git
# ใช้คำสั่ง git clone แบบปกติ
RUN git clone --depth 1 "$REPO" app
WORKDIR /src/app

ENV NEXT_TELEMETRY_DISABLED=1

# ติดตั้งตาม lockfile ที่พบ
RUN if [ -f pnpm-lock.yaml ]; then corepack enable && pnpm i --frozen-lockfile; \
    elif [ -f yarn.lock ]; then corepack enable && yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    else npm i; fi

# แนะนำให้ตั้ง output: "standalone" ใน next.config.js
RUN npm run build

########## Runner: บางเบาและพร้อมรัน ##########
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
EXPOSE 3000

# โหมด standalone (ถ้ามี)
COPY --from=builder /src/app/.next/standalone ./
COPY --from=builder /src/app/.next/static ./.next/static
COPY --from=builder /src/app/public ./public

# Fallback สำหรับโปรเจกต์ที่ไม่ใช้ standalone
COPY --from=builder /src/app/package.json ./package.json
COPY --from=builder /src/app/node_modules ./node_modules
COPY --from=builder /src/app/.next ./.next

# ใช้ node server.js ถ้ามี (standalone) ไม่งั้น npm run start
CMD ["sh","-lc","if [ -f ./server.js ]; then node server.js; else npm run start; fi"]