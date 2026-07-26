FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json tsconfig.base.json ./
COPY packages/contracts/package.json packages/contracts/package.json
COPY services/api/package.json services/api/package.json
RUN npm ci

COPY packages/contracts packages/contracts
COPY services/api services/api
RUN npm run build

FROM node:22-alpine AS runtime

ENV NODE_ENV=production
WORKDIR /app

COPY package.json package-lock.json ./
COPY packages/contracts/package.json packages/contracts/package.json
COPY services/api/package.json services/api/package.json
RUN npm ci --omit=dev

COPY --from=build /app/packages/contracts/dist packages/contracts/dist
COPY --from=build /app/services/api/dist services/api/dist

USER node
EXPOSE 3000
CMD ["node", "services/api/dist/server.js"]
