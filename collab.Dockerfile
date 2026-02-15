# ===== BUILD excalidraw-room from source (ARM64-compatible) =====
FROM node:18-alpine

WORKDIR /excalidraw-room

RUN apk add --no-cache git

# Clone the excalidraw-room source
RUN git clone --depth 1 https://github.com/excalidraw/excalidraw-room.git .

# Install dependencies and build
RUN yarn --network-timeout 600000
RUN yarn build

EXPOSE 80

CMD ["yarn", "start"]
