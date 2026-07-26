import { describe, expect, it } from 'vitest';

import { buildServer } from '../src/app.js';

describe('GET /health', () => {
  it('returns a healthy response', async () => {
    const server = buildServer();

    try {
      const response = await server.inject({
        method: 'GET',
        url: '/health',
      });

      expect(response.statusCode).toBe(200);
      expect(response.json()).toEqual({ status: 'ok' });
    } finally {
      await server.close();
    }
  });
});
