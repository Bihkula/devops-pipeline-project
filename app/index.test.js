const request = require('supertest');
const app = require('./index');

describe('GET /', () => {
  it('responds with a welcome message', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toContain('Hello');
  });
});

describe('GET /healthz', () => {
  it('responds with status ok', async () => {
    const res = await request(app).get('/healthz');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});
