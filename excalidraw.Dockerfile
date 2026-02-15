# ===== BUILD STAGE =====
FROM node:22-alpine AS build

RUN apk add --no-cache git bash

WORKDIR /app

ARG CACHE_INVALIDATOR
ARG VITE_APP_WS_SERVER_URL=https://oss-collab.excalidraw.com
ARG VITE_APP_HTTP_STORAGE_BACKEND_URL
ARG VITE_APP_STORAGE_BACKEND=http
ENV VITE_APP_WS_SERVER_URL=$VITE_APP_WS_SERVER_URL
ENV VITE_APP_HTTP_STORAGE_BACKEND_URL=$VITE_APP_HTTP_STORAGE_BACKEND_URL
ENV VITE_APP_STORAGE_BACKEND=$VITE_APP_STORAGE_BACKEND

RUN git clone --depth 1 https://github.com/excalidraw/excalidraw.git .

RUN yarn --network-timeout 600000
RUN yarn build:app:docker

FROM nginx:1.27-alpine

COPY --from=build /app/excalidraw-app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
