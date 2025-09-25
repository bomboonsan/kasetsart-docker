# syntax=docker/dockerfile:1.7

########## Builder: clone + build ##########
FROM node:22-alpine AS builder
WORKDIR /src
RUN apk update && apk add --no-cache git openssh

# เตรียม known_hosts เพื่อไม่ต้องตอบ yes ตอนเชื่อมต่อ
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    ssh-keyscan -H github.com >> /root/.ssh/known_hosts

# ชี้ไปที่ private repo ของคุณ (ใช้ SSH URL เท่านั้น)
ARG REPO=git@github.com:bomboonsan/kasetsart-nextjs.git

# ใช้ BuildKit SSH forwarding: --ssh=default
RUN --mount=type=ssh,id=default git clone --depth 1 "$REPO" app
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
