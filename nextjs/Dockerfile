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
ARG NEXT_PUBLIC_API_BASE_URL
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_STRAPI_GRAPHQL_API_URL
ENV NEXT_PUBLIC_API_BASE_URL=$NEXT_PUBLIC_API_BASE_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_STRAPI_GRAPHQL_API_URL=$NEXT_PUBLIC_STRAPI_GRAPHQL_API_URL

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

COPY --from=builder /app/public ./public
RUN mkdir .next && chown nextjs:nodejs .next
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
CMD ["node", "server.js"]
