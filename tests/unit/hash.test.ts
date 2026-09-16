import { describe, it, expect } from 'vitest';
import { timingSafeCompare, createSha256Hash, generateDeduplicationHash } from '../../src/utils/hash.js';

describe('Hash & Auth Utilities', () => {
  describe('timingSafeCompare', () => {
    it('returns true for matching secret tokens', () => {
      const secret = 'SUPER_SECRET_BEARER_TOKEN_12345';
      expect(timingSafeCompare(secret, secret)).toBe(true);
    });

    it('returns false for non-matching tokens of equal length', () => {
      expect(timingSafeCompare('TOKEN_ABC1', 'TOKEN_ABC2')).toBe(false);
    });

    it('returns false for tokens of different lengths safely without crashing', () => {
      expect(timingSafeCompare('SHORT', 'VERY_LONG_TOKEN_STRING')).toBe(false);
      expect(timingSafeCompare('', 'TOKEN')).toBe(false);
    });
  });

  describe('createSha256Hash', () => {
    it('generates deterministic SHA-256 hex string', () => {
      const hash1 = createSha256Hash('127.0.0.1');
      const hash2 = createSha256Hash('127.0.0.1');
      expect(hash1).toBe(hash2);
      expect(hash1.length).toBe(64);
    });
  });

  describe('generateDeduplicationHash', () => {
    it('creates stable hash from payload components', () => {
      const payload = {
        packageName: 'com.whatsapp',
        key: 'key123',
        title: 'John',
        text: 'Hello',
        subText: null,
        bigText: 'Hello world',
        time: 1694825600000,
      };

      const hashA = generateDeduplicationHash(payload);
      const hashB = generateDeduplicationHash(payload);
      expect(hashA).toBe(hashB);
      expect(typeof hashA).toBe('string');
      expect(hashA.length).toBe(64);
    });
  });
});
