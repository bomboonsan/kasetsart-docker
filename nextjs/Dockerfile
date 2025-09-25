# Next.js build → standalone
FROM node:20-alpine AS base

# deps
FROM base AS deps
RUN apk add --no-cache libc6-compat git
RUN npm i -g pnpm
WORKDIR /app
RUN git clone https://github.com/bomboonsan/kasetsart-nextjs.git .
RUN pnpm install --frozen-lockfile

# build
FROM base AS builder
RUN npm i -g pnpm
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app .
ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm run build

# run
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs \
 && adduser --system --uid 1001 nextjs

# public assets
COPY --from=builder /app/public ./public

# .next/standalone server
RUN mkdir .next && chown nextjs:nodejs .next
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

# server.js ถูกสร้างโดย Next.js standalone
CMD ["node", "server.js"]
