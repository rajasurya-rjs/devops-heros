# React Hello World - DevOps homework
# Multi-stage build: node compiles the app, nginx serves the static output.

# ---- stage 1: build ----
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build

# ---- stage 2: serve ----
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
