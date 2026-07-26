import Fastify, { type FastifyInstance } from 'fastify';

import {
  healthResponseSchema,
  type HealthResponse,
} from '@paperwork-assistant/contracts';

export function buildServer(): FastifyInstance {
  const server = Fastify({ logger: false });

  server.get(
    '/health',
    {
      schema: {
        response: {
          200: healthResponseSchema,
        },
      },
    },
    async (): Promise<HealthResponse> => ({ status: 'ok' }),
  );

  return server;
}
