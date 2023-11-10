# Base image
FROM node:18-alpine3.17  AS base
WORKDIR /app

# Copy package.json and lockfile
COPY package.json yarn.lock ./

# Install dependencies
# RUN yarn install --frozen-lockfile --production=true
RUN yarn install --ignore-engines

# Build stage
FROM base AS build
COPY . .

# Get build argument and set environment variable
# ARG VITE_API_URL
# ARG VITE_KG_URL
# ENV VITE_API_URL=$VITE_API_URL
# ENV VITE_KG_URL=$VITE_KG_URL

RUN yarn build
# CMD ["yarn", "run", "dev"]

# Serve stage
# FROM node:16-alpine AS serve
# WORKDIR /app
# COPY --from=build /app/dist ./
# ENV NODE_ENV=production
# CMD ["node", "server.js"]

# -- RELEASE --
FROM nginx:stable-alpine as release

COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
ENV NODE_ENV=production

EXPOSE 3000