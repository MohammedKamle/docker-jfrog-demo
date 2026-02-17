# Docker + JFrog Artifactory Demo

A demonstration project showing how to build Docker images and publish them to JFrog Artifactory container registry, featuring both local development workflow and GitHub Actions CI/CD automation.

## Prerequisites

- Docker Desktop installed and running
- JFrog Artifactory account with a Docker repository
- JFrog access token (see [SETUP.md](SETUP.md) for instructions)
- Node.js 18+ (for local development without Docker)

## Quick Start

### 1. Clone and Build Locally

```bash
# Build the Docker image
./scripts/build.sh 1.0.0

# Run locally
docker run -p 3000:3000 docker-artifactory-demo:1.0.0

# Test the application
curl http://localhost:3000/health
```

### 2. Push to JFrog Artifactory

```bash
# Set environment variables
export ARTIFACTORY_URL=mycompany.jfrog.io
export ARTIFACTORY_REPO=docker-local
export ARTIFACTORY_USER=your-username
export ARTIFACTORY_TOKEN=your-access-token

# Push the image
./scripts/push.sh 1.0.0
```

## GitHub Actions CI/CD

This project includes automated CI/CD using GitHub Actions that:

- **Builds** on every push to `main` and on pull requests
- **Pushes** to JFrog Artifactory on pushes to `main` and tagged releases
- **Tags images** automatically with semantic versions, branch names, and commit SHAs

### Setup GitHub Secrets

Add these secrets to your GitHub repository:

| Secret | Description | Example |
|--------|-------------|---------|
| `ARTIFACTORY_URL` | Your JFrog Artifactory URL | `mycompany.jfrog.io` |
| `ARTIFACTORY_REPO` | Docker repository name | `docker-local` |
| `ARTIFACTORY_USER` | JFrog username | `ci-user@example.com` |
| `ARTIFACTORY_TOKEN` | JFrog access token | `eyJ2ZXIi...` |

### Triggering Builds

```bash
# Automatic build on push to main
git push origin main

# Tagged release (creates versioned image)
git tag v1.0.0
git push origin v1.0.0
```

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /` | Application info and available endpoints |
| `GET /health` | Health check (used by Docker HEALTHCHECK) |
| `GET /info` | Application version and environment details |

## Project Structure

```
docker-artifactory-demo/
├── .github/workflows/     # GitHub Actions CI/CD
│   └── docker-build-push.yml
├── src/                   # Application source code
│   ├── app.js
│   └── package.json
├── scripts/               # Build and push scripts
│   ├── build.sh
│   └── push.sh
├── Dockerfile             # Multi-stage Docker build
├── .dockerignore
├── .gitignore
├── README.md
└── SETUP.md               # JFrog Artifactory setup guide
```

## Docker Image Features

- **Multi-stage build** for minimal image size
- **Non-root user** for security
- **Health check** built into the image
- **Alpine-based** Node.js for smaller footprint

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Application port |
| `NODE_ENV` | `production` | Node.js environment |
| `APP_VERSION` | `1.0.0` | Application version (set at build time) |

## Troubleshooting

### Login Failed
```
Error: unauthorized: authentication required
```
Verify your credentials and ensure the access token has Docker repository permissions.

### Push Failed
```
Error: denied: requested access to the resource is denied
```
Check that:
1. The Docker repository exists in Artifactory
2. Your user has push permissions
3. The repository path is correct

### Image Won't Start
```bash
# Check container logs
docker logs <container-id>

# Run with shell access
docker run -it --entrypoint /bin/sh docker-artifactory-demo:latest
```

## License

MIT
