export interface HealthResponse {
  status: 'ok';
}

export const healthResponseSchema = {
  $id: 'HealthResponse',
  type: 'object',
  additionalProperties: false,
  required: ['status'],
  properties: {
    status: { type: 'string', const: 'ok' },
  },
} as const;

export interface DocumentAnalysis {
  documentId: string;
  language: string;
  summary: string;
  dueDate: string | null;
  tags: string[];
}

export const documentAnalysisSchema = {
  $id: 'DocumentAnalysis',
  type: 'object',
  additionalProperties: false,
  required: ['documentId', 'language', 'summary', 'dueDate', 'tags'],
  properties: {
    documentId: { type: 'string', minLength: 1 },
    language: { type: 'string', minLength: 2 },
    summary: { type: 'string' },
    dueDate: {
      anyOf: [
        { type: 'string', format: 'date' },
        { type: 'null' },
      ],
    },
    tags: {
      type: 'array',
      items: { type: 'string' },
    },
  },
} as const;
