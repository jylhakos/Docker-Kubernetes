#!/usr/bin/env node

/**
 * Simple Node.js web server for GKE deployment demo
 * Based on Google Cloud's "Deploy, scale, and update your website with GKE" codelab
 */

const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 8080;
const VERSION = process.env.VERSION || '1.0.0';

// Health check endpoint for Kubernetes liveness/readiness probes
app.get('/healthz', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// Readiness check endpoint
app.get('/readyz', (req, res) => {
  res.status(200).json({
    status: 'ready',
    timestamp: new Date().toISOString()
  });
});

// Main application endpoint
app.get('/', (req, res) => {
  const hostname = os.hostname();
  const uptime = process.uptime();
  
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>GKE Demo - Version ${VERSION}</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          max-width: 800px;
          margin: 50px auto;
          padding: 20px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
        }
        .container {
          background: rgba(255, 255, 255, 0.1);
          padding: 40px;
          border-radius: 10px;
          backdrop-filter: blur(10px);
          box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        h1 {
          font-size: 2.5em;
          margin-bottom: 10px;
          text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .info {
          background: rgba(255, 255, 255, 0.2);
          padding: 15px;
          border-radius: 5px;
          margin: 20px 0;
        }
        .info-item {
          margin: 10px 0;
          font-size: 1.1em;
        }
        .label {
          font-weight: bold;
          color: #ffd700;
        }
        .badge {
          display: inline-block;
          padding: 5px 15px;
          background: #4CAF50;
          border-radius: 20px;
          font-size: 0.9em;
        }
        .footer {
          margin-top: 30px;
          text-align: center;
          font-size: 0.9em;
          opacity: 0.8;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>Google Kubernetes Engine Demo</h1>
        <span class="badge">Version ${VERSION}</span>
        
        <div class="info">
          <div class="info-item">
            <span class="label">Pod Hostname:</span> ${hostname}
          </div>
          <div class="info-item">
            <span class="label">Node.js Version:</span> ${process.version}
          </div>
          <div class="info-item">
            <span class="label">Uptime:</span> ${Math.floor(uptime)} seconds
          </div>
          <div class="info-item">
            <span class="label">Timestamp:</span> ${new Date().toISOString()}
          </div>
          <div class="info-item">
            <span class="label">Platform:</span> ${process.platform}
          </div>
        </div>
        
        <div class="footer">
          <p>This application is running on Google Kubernetes Engine</p>
          <p>Deployed and scaled using Kubernetes</p>
        </div>
      </div>
    </body>
    </html>
  `);
});

// Metrics endpoint (optional, for monitoring)
app.get('/metrics', (req, res) => {
  res.json({
    version: VERSION,
    hostname: os.hostname(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpu: process.cpuUsage()
  });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Version: ${VERSION}`);
  console.log(`Hostname: ${os.hostname()}`);
  console.log(`Health check: http://localhost:${PORT}/healthz`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  process.exit(0);
});
