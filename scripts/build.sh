#!/bin/bash
# Build Docker image locally
# Usage: ./build.sh [tag]

set -e

IMAGE_NAME="${IMAGE_NAME:-docker-artifactory-demo}"
TAG="${1:-latest}"

echo "🔨 Building Docker image: ${IMAGE_NAME}:${TAG}"

docker build \
  --tag "${IMAGE_NAME}:${TAG}" \
  --tag "${IMAGE_NAME}:latest" \
  --build-arg APP_VERSION="${TAG}" \
  --file Dockerfile \
  .

echo "✅ Build complete: ${IMAGE_NAME}:${TAG}"
echo ""
echo "To run locally:"
echo "  docker run -p 3000:3000 ${IMAGE_NAME}:${TAG}"
echo ""
echo "To push to JFrog Artifactory:"
echo "  ./scripts/push.sh ${TAG}"
