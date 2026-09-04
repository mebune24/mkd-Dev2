import crypto from 'crypto';

const ALGORITHM = 'aes-256-gcm';
// In a real app, this should be a 32-byte key stored securely in KMS or env
// For this demo, we derive a 32-byte key from the JWT_SECRET
const getEncryptionKey = (): Buffer => {
  const secret = process.env.JWT_SECRET || 'fallback-secret-for-dev-only';
  return crypto.createHash('sha256').update(secret).digest();
};

export class EncryptionService {
  /**
   * Encrypts a buffer using AES-256-GCM.
   * Returns a buffer containing: IV (16 bytes) + AuthTag (16 bytes) + CipherText
   */
  encryptBuffer(buffer: Buffer): Buffer {
    const iv = crypto.randomBytes(16);
    const key = getEncryptionKey();
    const cipher = crypto.createCipheriv(ALGORITHM, key, iv);

    const encrypted = Buffer.concat([cipher.update(buffer), cipher.final()]);
    const authTag = cipher.getAuthTag();

    // Format: IV (16) + AuthTag (16) + EncryptedData
    return Buffer.concat([iv, authTag, encrypted]);
  }

  /**
   * Decrypts a buffer that was encrypted with encryptBuffer.
   */
  decryptBuffer(encryptedBuffer: Buffer): Buffer {
    const iv = encryptedBuffer.subarray(0, 16);
    const authTag = encryptedBuffer.subarray(16, 32);
    const cipherText = encryptedBuffer.subarray(32);

    const key = getEncryptionKey();
    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(authTag);

    return Buffer.concat([decipher.update(cipherText), decipher.final()]);
  }
}

export const encryptionService = new EncryptionService();
