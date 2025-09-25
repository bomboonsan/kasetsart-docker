# syntax=docker/dockerfile:1.7

##### Builder #####
FROM node:22-alpine AS builder
WORKDIR /src
# ยังคงต้องใช้ git แต่ไม่จำเป็นต้องใช้ openssh สำหรับการ clone แล้ว
RUN apk update && apk upgrade && apk add --no-cache git build-base python3 make autoconf automake zlib-dev libpng-dev vips-dev

# เปลี่ยนไปใช้ HTTPS URL สำหรับ Public Repository
ARG REPO=https://github.com/bomboonsan/kasetsart-strapi.git
ARG BRANCH=main
# ใช้คำสั่ง git clone แบบปกติ
RUN git clone --depth 1 -b "$BRANCH" "$REPO" app
WORKDIR /src/app

ENV NODE_ENV=production
ENV PORT=1338
ENV HOST=0.0.0.0

# ต้องติดตั้ง dev deps เพื่อ build TS + Admin
RUN if [ -f pnpm-lock.yaml ]; then corepack enable && pnpm i --frozen-lockfile; \
    elif [ -f yarn.lock ]; then corepack enable && yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    else npm i; fi

RUN npm run build

# prune ให้เหลือเฉพาะ prod deps หลัง build เสร็จ
RUN if [ -f pnpm-lock.yaml ]; then pnpm prune --prod; \
    elif [ -f yarn.lock ]; then yarn install --production --ignore-scripts --prefer-offline; \
    else npm prune --omit=dev; fi

##### Runner #####
FROM node:22-alpine AS runner
WORKDIR /opt/app
ENV NODE_ENV=production
ENV PORT=1338
ENV HOST=0.0.0.0

# sharp ใช้ vips ตอนรัน
RUN apk update && apk upgrade && apk add --no-cache vips-dev

COPY --from=builder /src/app /opt/app
RUN chown -R node:node /opt/app
USER node

EXPOSE 1338
CMD ["npm","run","start"]