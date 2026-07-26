import { describe, expect, it } from 'vitest';

import {
  documentAnalysisSchema,
  healthResponseSchema,
} from '../src/index.js';

describe('shared contracts', () => {
  it('keeps the health response restricted to the ok status', () => {
    expect(healthResponseSchema.required).toEqual(['status']);
    expect(healthResponseSchema.properties.status.const).toBe('ok');
  });

  it('requires every field in the document analysis envelope', () => {
    expect(documentAnalysisSchema.required).toEqual([
      'documentId',
      'language',
      'summary',
      'dueDate',
      'tags',
    ]);
  });
});
