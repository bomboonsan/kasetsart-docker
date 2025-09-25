FROM node:22-alpine
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev git curl

ARG NODE_ENV=production
ARG PUBLIC_URL
ENV NODE_ENV=${NODE_ENV}
ENV PUBLIC_URL=${PUBLIC_URL}

WORKDIR /opt/app
RUN git clone https://github.com/bomboonsan/kasetsart-strapi.git . \
 && npm ci \
 && npm run build

RUN chown -R node:node /opt/app/public/uploads || true
USER node

EXPOSE 1337
CMD ["npm", "run", "start"]