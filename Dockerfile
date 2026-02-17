# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first for better layer caching
COPY src/package*.json ./

# Install dependencies (use npm install if no lock file exists)
RUN npm install --only=production

# Stage 2: Production
FROM node:20-alpine AS production

# Add labels for better image management
LABEL maintainer="your-team@example.com"
LABEL org.opencontainers.image.source="https://github.com/your-org/docker-artifactory-demo"
LABEL org.opencontainers.image.description="Docker + JFrog Artifactory Demo"

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application code
COPY src/ ./

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start application
CMD ["node", "app.js"]
