# JFrog Artifactory Setup Guide

This guide walks you through setting up JFrog Artifactory to host Docker images.

## 1. Create a Docker Repository

### Using JFrog Platform UI

1. Log in to your JFrog Platform at `https://your-instance.jfrog.io`
2. Navigate to **Administration** → **Repositories** → **Repositories**
3. Click **+ Add Repository** → **Local Repository**
4. Select **Docker** as the package type
5. Configure the repository:
   - **Repository Key**: `docker-local` (or your preferred name)
   - **Docker API Version**: `V2`
   - **Max Unique Tags**: Leave default or set as needed
6. Click **Create Local Repository**

### Using JFrog CLI

```bash
# Configure JFrog CLI
jfrog config add --url=https://your-instance.jfrog.io --user=your-username --interactive

# Create a local Docker repository
jfrog rt repo-create docker-local --type=local --package-type=docker
```

## 2. Generate an Access Token

Access tokens are more secure than passwords and can have scoped permissions.

### Using JFrog Platform UI

1. Click on your username (top-right) → **Edit Profile**
2. In the **Authentication Settings** section, find **Access Tokens**
3. Click **+ Generate Token**
4. Configure:
   - **Description**: `Docker CI/CD`
   - **Token Scope**: `User` (or use scoped tokens for better security)
   - **Expiration**: Set based on your security policy
5. Click **Generate**
6. **Copy the token immediately** - it won't be shown again!

### Using JFrog CLI

```bash
# Generate an access token
jfrog rt access-token-create --description="Docker CI/CD" --expiry=31536000
```

## 3. Configure Docker for Artifactory

### Option A: Docker Login (Manual)

```bash
# Login to Artifactory Docker registry
docker login your-instance.jfrog.io

# Enter username and access token when prompted
```

### Option B: Docker Config (Automated)

Create or edit `~/.docker/config.json`:

```json
{
  "auths": {
    "your-instance.jfrog.io": {
      "auth": "BASE64_ENCODED_USERNAME:TOKEN"
    }
  }
}
```

Generate the auth value:
```bash
echo -n "username:token" | base64
```

## 4. Environment Variables

Set these environment variables for the build scripts:

```bash
# Add to ~/.bashrc, ~/.zshrc, or CI/CD secrets
export ARTIFACTORY_URL=your-instance.jfrog.io
export ARTIFACTORY_REPO=docker-local
export ARTIFACTORY_USER=your-username
export ARTIFACTORY_TOKEN=your-access-token
```

## 5. GitHub Actions Secrets

Add these secrets to your GitHub repository:

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret** for each:

| Name | Value |
|------|-------|
| `ARTIFACTORY_URL` | `your-instance.jfrog.io` |
| `ARTIFACTORY_REPO` | `docker-local` |
| `ARTIFACTORY_USER` | `your-username` |
| `ARTIFACTORY_TOKEN` | `your-access-token` |

## 6. Verify Setup

### Test Docker Login

```bash
docker login ${ARTIFACTORY_URL}
# Enter credentials when prompted
# Should see: Login Succeeded
```

### Test Push/Pull

```bash
# Build a test image
docker build -t ${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/test:latest .

# Push to Artifactory
docker push ${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/test:latest

# Remove local image
docker rmi ${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/test:latest

# Pull from Artifactory
docker pull ${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/test:latest
```

## 7. Repository Permissions (Optional)

For production use, configure granular permissions:

1. Navigate to **Administration** → **Identity and Access** → **Permissions**
2. Click **+ New Permission**
3. Add your Docker repository
4. Assign users/groups with appropriate access:
   - **Read**: Pull images
   - **Deploy/Cache**: Push images
   - **Delete**: Remove images
   - **Manage**: Administer repository

## Troubleshooting

### "unauthorized: authentication required"

- Verify token hasn't expired
- Check username is correct
- Ensure token has repository permissions

### "denied: requested access to the resource is denied"

- Verify repository exists
- Check user has push permissions
- Confirm repository path is correct

### "name unknown: repository name not known to registry"

- Verify the repository key matches exactly
- Check for typos in ARTIFACTORY_REPO

## Security Best Practices

1. **Use access tokens** instead of passwords
2. **Set token expiration** appropriate for your use case
3. **Use scoped tokens** with minimal permissions for CI/CD
4. **Rotate tokens regularly**
5. **Never commit tokens** to source control
6. **Use GitHub Secrets** for CI/CD credentials
