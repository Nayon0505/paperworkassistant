# Paperwork Assistant

Paperwork Assistant is a Flutter and Node.js monorepo for a mobile document
inbox and its supporting API.

## Repository layout

- `apps/mobile` — Flutter app for Android and iOS.
- `services/api` — Fastify API.
- `packages/contracts` — shared API and document-analysis schemas.

The initial scaffold intentionally contains no document persistence, working
imports, AI integration, or production deployment.

## Prerequisites

- Flutter 3.44 or newer with the Android and/or iOS platform toolchain.
- Node.js 22 or newer and npm 11 or newer.
- Docker, when running the API in a container.

## Install

Install the Node.js workspaces from the repository root:

```sh
npm install
```

Install the mobile dependencies:

```sh
cd apps/mobile
flutter pub get
```

## Run the mobile app

The app is named `Paperwork Assistant` and uses
`de.nayon.paperworkassistant` on Android and iOS.

```sh
cd apps/mobile
flutter run
```

The app follows the device language for German and English. Unsupported device
languages fall back to English.

## Run the API locally

From the repository root:

```sh
npm run api:dev
```

The API listens on port `3000` by default. Override it with the `PORT`
environment variable. Check it with:

```sh
curl http://localhost:3000/health
```

The expected response is `{"status":"ok"}`.

For a production-style local start:

```sh
npm run api:start
```

## Run the API with Docker

Build from the repository root so the shared contracts package is available:

```sh
docker build -f services/api/Dockerfile -t paperwork-assistant-api .
docker run --rm -p 3000:3000 paperwork-assistant-api
```

Then call `http://localhost:3000/health`.

## Analyze, lint, build, and test

Run all Node.js checks from the repository root:

```sh
npm run lint
npm run typecheck
npm test
npm run build
```

Run Flutter analysis and widget tests:

```sh
cd apps/mobile
flutter analyze
flutter test
```
