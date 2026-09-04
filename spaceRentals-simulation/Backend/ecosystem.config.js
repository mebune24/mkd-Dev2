module.exports = {
  apps: [
    {
      name: 'space-rentals-api',
      script: 'dist/index.js',
      instances: 'max',       // Utilize all available CPU cores
      exec_mode: 'cluster',   // Run in cluster mode for load balancing
      watch: false,
      env: {
        NODE_ENV: 'production'
      }
    }
  ]
};
