import { PrismaClient } from '@prisma/client';
import { clearCacheByPattern } from '../config/redis';

const basePrisma = new PrismaClient();

export const prisma = basePrisma.$extends({
  query: {
    property: {
      async create({ args, query }) {
        const result = await query(args);
        await clearCacheByPattern('search:properties:*');
        return result;
      },
      async update({ args, query }) {
        const result = await query(args);
        await clearCacheByPattern('search:properties:*');
        return result;
      },
      async delete({ args, query }) {
        const result = await query(args);
        await clearCacheByPattern('search:properties:*');
        return result;
      },
      async updateMany({ args, query }) {
        const result = await query(args);
        await clearCacheByPattern('search:properties:*');
        return result;
      },
      async deleteMany({ args, query }) {
        const result = await query(args);
        await clearCacheByPattern('search:properties:*');
        return result;
      },
      async upsert({ args, query }) {
        const result = await query(args);
        await clearCacheByPattern('search:properties:*');
        return result;
      },
    },
  },
});
