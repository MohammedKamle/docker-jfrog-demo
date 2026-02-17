#!/bin/bash
# Push Docker image to JFrog Artifactory
# Usage: ./push.sh [tag]
#
# Required environment variables:
#   ARTIFACTORY_URL   - JFrog Artifactory URL (e.g., mycompany.jfrog.io)
#   ARTIFACTORY_REPO  - Docker repository name (e.g., docker-local)
#   ARTIFACTORY_USER  - JFrog username or email
#   ARTIFACTORY_TOKEN - JFrog access token or API key

set -e

# Configuration
IMAGE_NAME="${IMAGE_NAME:-docker-artifactory-demo}"
TAG="${1:-latest}"

# Validate required environment variables
if [[ -z "${ARTIFACTORY_URL}" ]]; then
  echo "❌ Error: ARTIFACTORY_URL is not set"
  echo "   Example: export ARTIFACTORY_URL=mycompany.jfrog.io"
  exit 1
fi

if [[ -z "${ARTIFACTORY_REPO}" ]]; then
  echo "❌ Error: ARTIFACTORY_REPO is not set"
  echo "   Example: export ARTIFACTORY_REPO=docker-local"
  exit 1
fi

if [[ -z "${ARTIFACTORY_USER}" ]]; then
  echo "❌ Error: ARTIFACTORY_USER is not set"
  exit 1
fi

if [[ -z "${ARTIFACTORY_TOKEN}" ]]; then
  echo "❌ Error: ARTIFACTORY_TOKEN is not set"
  echo "   Generate a token at: https://${ARTIFACTORY_URL}/ui/admin/artifactory/user_profile"
  exit 1
fi

# Full image path in Artifactory
FULL_IMAGE="${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/${IMAGE_NAME}"

echo "🔐 Logging into JFrog Artifactory..."
echo "${ARTIFACTORY_TOKEN}" | docker login "${ARTIFACTORY_URL}" -u "${ARTIFACTORY_USER}" --password-stdin

echo "🏷️  Tagging image for Artifactory..."
docker tag "${IMAGE_NAME}:${TAG}" "${FULL_IMAGE}:${TAG}"
docker tag "${IMAGE_NAME}:latest" "${FULL_IMAGE}:latest"

echo "📤 Pushing to JFrog Artifactory..."
docker push "${FULL_IMAGE}:${TAG}"
docker push "${FULL_IMAGE}:latest"

echo ""
echo "✅ Successfully pushed to JFrog Artifactory!"
echo "   Image: ${FULL_IMAGE}:${TAG}"
echo ""
echo "To pull this image:"
echo "   docker pull ${FULL_IMAGE}:${TAG}"
