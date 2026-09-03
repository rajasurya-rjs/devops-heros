# Node.js Hello World - DevOps homework
FROM node:22-alpine

WORKDIR /app

# copy package.json first so this layer is cached when only the code changes
COPY package.json ./
RUN npm install --omit=dev

COPY server.js ./

EXPOSE 3000
CMD ["node", "server.js"]
