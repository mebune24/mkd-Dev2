export interface KycVerificationResult {
  status: 'approved' | 'rejected' | 'pending';
  confidenceScore: number;
  reason?: string;
}

export class KycVerificationService {
  /**
   * Mocks a call to a third-party KYC provider (e.g., SmileID or Dojah).
   * In a production environment, this would send the encrypted document buffer
   * or a short-lived signed URL to the third party for OCR and face matching.
   */
  async verifyDocument(documentBuffer: Buffer, documentType: string): Promise<KycVerificationResult> {
    console.log(`[KYC Service] Verifying ${documentType} document of size ${documentBuffer.length} bytes...`);
    
    // Simulate network delay for 3rd party API
    await new Promise(resolve => setTimeout(resolve, 2000));

    // For demonstration, we'll pseudo-randomly approve or reject based on document size
    // In reality, this depends on the third party's OCR and AI checks
    const isBlurry = documentBuffer.length < 50000; // Mock: files under 50KB are rejected as "blurry"
    
    if (isBlurry) {
      return {
        status: 'rejected',
        confidenceScore: 0.3,
        reason: 'Document image quality is too low (blurry). Please upload a higher resolution image.',
      };
    }

    // Default to approved for the mock
    return {
      status: 'approved',
      confidenceScore: 0.95 + (Math.random() * 0.04), // 95% - 99%
    };
  }
}

export const kycVerificationService = new KycVerificationService();
