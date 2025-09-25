# syntax=docker/dockerfile:1.7

##### Builder #####
FROM node:22-alpine AS builder
WORKDIR /src
RUN apk update && apk add --no-cache git openssh build-base python3 make autoconf automake zlib-dev libpng-dev vips-dev
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && ssh-keyscan -H github.com >> /root/.ssh/known_hosts

ARG REPO=git@github.com:bomboonsan/kasetsart-strapi.git
ARG BRANCH=main
RUN --mount=type=ssh,id=default git clone --depth 1 -b "$BRANCH" "$REPO" app
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
RUN apk update && apk add --no-cache vips-dev

COPY --from=builder /src/app /opt/app
RUN chown -R node:node /opt/app
USER node

EXPOSE 1338
CMD ["npm","run","start"]
