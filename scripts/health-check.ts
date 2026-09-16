import http from 'http';
import { env } from '../src/config/environment.js';

const options: http.RequestOptions = {
  host: '127.0.0.1',
  port: env.PORT,
  path: '/health/ready',
  timeout: 2000,
};

const request = http.request(options, (res) => {
  if (res.statusCode === 200) {
    process.exit(0);
  } else {
    process.exit(1);
  }
});

request.on('error', () => {
  process.exit(1);
});

request.end();
