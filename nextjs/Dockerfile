# Next.js build → standalone, always clone latest from Git
FROM node:20-alpine AS base

# ---------- deps ----------
FROM base AS deps
RUN apk add --no-cache libc6-compat git
RUN npm i -g pnpm

WORKDIR /app
# รับพารามิเตอร์ repo/branch และตัวทำลายแคช
ARG REPO_URL=https://github.com/bomboonsan/kasetsart-nextjs.git
ARG GIT_REF=main
ARG CACHE_BUSTER=0

# ดึงโค้ดใหม่ทุกครั้ง (ใช้ --depth=1 เร็วกว่า)
RUN echo "BUST=$CACHE_BUSTER" \
 && git clone --depth=1 --branch "${GIT_REF}" "${REPO_URL}" . \
 && pnpm install --frozen-lockfile

# ---------- build ----------
FROM base AS builder
RUN npm i -g pnpm
WORKDIR /app

# รับตัวแปร public สำหรับ build-time
ARG NEXT_PUBLIC_API_BASE_URL
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_STRAPI_GRAPHQL_API_URL
ENV NEXT_PUBLIC_API_BASE_URL=$NEXT_PUBLIC_API_BASE_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_STRAPI_GRAPHQL_API_URL=$NEXT_PUBLIC_STRAPI_GRAPHQL_API_URL
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=deps /app ./
RUN pnpm run build

# ---------- run ----------
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs \
 && adduser  --system --uid 1001 nextjs

# static + standalone server
COPY --from=builder /app/public ./public
RUN mkdir .next && chown nextjs:nodejs .next
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
CMD ["node", "server.js"]
