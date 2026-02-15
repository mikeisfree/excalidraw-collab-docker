# ===== BUILD STAGE =====
FROM node:22-alpine AS build

RUN apk add --no-cache git bash

WORKDIR /app

ARG CACHE_INVALIDATOR
ARG VITE_APP_WS_SERVER_URL=https://oss-collab.excalidraw.com
ARG VITE_APP_BACKEND_V2_GET_URL
ARG VITE_APP_BACKEND_V2_POST_URL
ENV VITE_APP_WS_SERVER_URL=$VITE_APP_WS_SERVER_URL
ENV VITE_APP_BACKEND_V2_GET_URL=$VITE_APP_BACKEND_V2_GET_URL
ENV VITE_APP_BACKEND_V2_POST_URL=$VITE_APP_BACKEND_V2_POST_URL

RUN git clone --depth 1 https://github.com/excalidraw/excalidraw.git .

# Remove .env.production to prevent it from overriding our ENV vars during Vite build
# (it hardcodes json.excalidraw.com URLs)
RUN rm -f .env.production

RUN yarn --network-timeout 600000
RUN yarn build:app:docker

FROM nginx:1.27-alpine

COPY --from=build /app/excalidraw-app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
