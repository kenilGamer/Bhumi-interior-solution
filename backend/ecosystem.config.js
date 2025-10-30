module.exports = {
  apps: [{
    name: 'bhumi-backend',
    script: './app.js',
    instances: 1,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 5001
    },
    env_file: '.env',
    watch: false,
    max_memory_restart: '500M',
    error_file: '/var/log/pm2/bhumi-backend-error.log',
    out_file: '/var/log/pm2/bhumi-backend-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true
  }]
};

