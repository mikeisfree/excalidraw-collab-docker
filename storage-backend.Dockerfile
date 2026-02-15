FROM node:24-bullseye-slim AS build

RUN corepack enable

WORKDIR /home/node/app

RUN apt-get update && \
    apt-get install -y git postgresql-client && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/kitsteam/excalidraw-storage-backend.git .

RUN npm ci
RUN npm run build

FROM node:24-bullseye-slim

RUN corepack enable

RUN apt-get update && \
    apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /home/node/app && \
    chown node:node /home/node/app

ENV NODE_ENV=production

WORKDIR /home/node/app

COPY --from=build /home/node/app/dist ./dist
COPY --from=build /home/node/app/package.json /home/node/app/package-lock.json /home/node/app/entrypoint.sh ./
RUN chmod +x entrypoint.sh

USER node
RUN npm ci

CMD ["./entrypoint.sh"]
