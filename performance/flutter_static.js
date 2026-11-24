import http from 'k6/http';
import { check, sleep } from 'k6';
const base = __ENV.MAKEEN_STATIC_TEST_URL || 'http://127.0.0.1:8000';
if (!/^http:\/\/(localhost|127\.0\.0\.1):\d+$/.test(base)) {
  throw new Error('Performance tests must run on disposable localhost only');
}
export const options = {
  stages: [
    { duration: '10s', target: 1 },
    { duration: '10s', target: 5 },
    { duration: '10s', target: 10 },
    { duration: '10s', target: 20 },
    { duration: '10s', target: 0 }
  ],
  thresholds: { http_req_failed: ['rate<0.01'], http_req_duration: ['p(95)<1000'] }
};
export default function () {
  for (const path of ['/', '/flutter_bootstrap.js']) {
    const response = http.get(base + path, { tags: { path } });
    check(response, { 'HTTP 200': r => r.status === 200 });
  }
  sleep(0.3);
}
