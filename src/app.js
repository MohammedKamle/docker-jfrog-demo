const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || '1.0.0'
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Docker + JFrog Artifactory Demo',
    endpoints: {
      health: '/health',
      info: '/info'
    }
  });
});

// Info endpoint
app.get('/info', (req, res) => {
  res.json({
    app: 'docker-artifactory-demo',
    version: process.env.APP_VERSION || '1.0.0',
    node_version: process.version,
    environment: process.env.NODE_ENV || 'development'
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
