import { PrismaClient } from '@prisma/client';
import { latLngToCell } from 'h3-js';

const prisma = new PrismaClient();
const H3_RESOLUTION = 7;

async function run() {
  console.log('Starting H3 Index backfill for properties...');
  
  const properties = await prisma.property.findMany({
    where: { latitude: { not: null }, longitude: { not: null }, h3Index: null }
  });

  console.log(`Found ${properties.length} properties needing H3 indexing.`);

  let count = 0;
  for (const property of properties) {
    if (property.latitude && property.longitude) {
      const h3Index = latLngToCell(property.latitude, property.longitude, H3_RESOLUTION);
      await prisma.property.update({
        where: { id: property.id },
        data: { h3Index }
      });
      count++;
    }
  }

  console.log(`Successfully indexed ${count} properties.`);
  process.exit(0);
}

run().catch(e => {
  console.error(e);
  process.exit(1);
});
