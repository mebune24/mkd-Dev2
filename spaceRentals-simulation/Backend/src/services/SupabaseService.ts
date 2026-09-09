import { createClient, SupabaseClient } from '@supabase/supabase-js';
import crypto from 'crypto';

const supabaseUrl = process.env.SUPABASE_URL || '';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

let supabase: SupabaseClient | null = null;
if (supabaseUrl && supabaseKey) {
  supabase = createClient(supabaseUrl, supabaseKey);
}

export const supabaseService = {
  get client() {
    if (!supabase) {
      throw { status: 500, message: 'Supabase is not configured on the server.' };
    }
    return supabase;
  },

  async uploadFile(bucket: string, path: string, fileBuffer: Buffer, mimeType: string) {
    const { data, error } = await this.client.storage
      .from(bucket)
      .upload(path, fileBuffer, { contentType: mimeType, upsert: true });
    
    if (error) {
      throw { status: 500, message: `Failed to upload to Supabase: ${error.message}` };
    }
    return data;
  },

  async getSignedUrl(bucket: string, path: string, expiresIn = 3600) {
    const { data, error } = await this.client.storage
      .from(bucket)
      .createSignedUrl(path, expiresIn);
    
    if (error) {
      throw { status: 500, message: `Failed to generate signed URL: ${error.message}` };
    }
    return data?.signedUrl;
  },

  async downloadFile(bucket: string, path: string): Promise<Buffer> {
    const { data, error } = await this.client.storage
      .from(bucket)
      .download(path);
    
    if (error) {
      throw { status: 500, message: `Failed to download file from Supabase: ${error.message}` };
    }
    const arrayBuffer = await data.arrayBuffer();
    return Buffer.from(arrayBuffer);
  },

  async fileExists(bucket: string, path: string): Promise<boolean> {
    const separator = path.lastIndexOf('/');
    if (separator <= 0 || separator === path.length - 1) return false;
    const folder = path.slice(0, separator);
    const filename = path.slice(separator + 1);
    const { data, error } = await this.client.storage.from(bucket).list(folder, { search: filename });
    if (error) {
      throw { status: 500, message: `Failed to verify uploaded document: ${error.message}` };
    }
    return data?.some((file) => file.name === filename) ?? false;
  },

  async listFiles(bucket: string, folder: string) {
    const { data, error } = await this.client.storage.from(bucket).list(folder, { limit: 1000 });
    if (error) {
      throw { status: 500, message: `Failed to list storage files: ${error.message}` };
    }
    return data ?? [];
  },

  async deleteFile(bucket: string, path: string) {
    const { error } = await this.client.storage
      .from(bucket)
      .remove([path]);
    
    if (error) {
      throw { status: 500, message: `Failed to delete file from Supabase: ${error.message}` };
    }
  },

  generateUniqueFileName(originalName: string): string {
    const ext = originalName.split('.').pop();
    const uniqueId = crypto.randomBytes(16).toString('hex');
    return `${uniqueId}.${ext}`;
  }
};
