import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding SpaceRentals database...');

  // ── Users ─────────────────────────────────────────────────────────
  const passwordHash = await bcrypt.hash('Password123!', 10);

  const admin = await prisma.user.upsert({
    where: { email: 'admin@spacerentals.cm' },
    update: {},
    create: {
      email: 'admin@spacerentals.cm',
      passwordHash,
      name: 'Admin SpaceRentals',
      firstName: 'Admin',
      lastName: 'SpaceRentals',
      phone: '+237670000001',
      role: 'admin',
      status: 'active',
    },
  });

  const landlord1 = await prisma.user.upsert({
    where: { email: 'landlord1@spacerentals.cm' },
    update: {},
    create: {
      email: 'landlord1@spacerentals.cm',
      passwordHash,
      name: 'Jean-Pierre Mbarga',
      firstName: 'Jean-Pierre',
      lastName: 'Mbarga',
      phone: '+237677100001',
      role: 'landlord',
      status: 'active',
    },
  });

  const landlord2 = await prisma.user.upsert({
    where: { email: 'landlord2@spacerentals.cm' },
    update: {},
    create: {
      email: 'landlord2@spacerentals.cm',
      passwordHash,
      name: 'Christelle Ngo',
      firstName: 'Christelle',
      lastName: 'Ngo',
      phone: '+237677100002',
      role: 'landlord',
      status: 'active',
    },
  });

  const landlord3 = await prisma.user.upsert({
    where: { email: 'landlord3@spacerentals.cm' },
    update: {},
    create: {
      email: 'landlord3@spacerentals.cm',
      passwordHash,
      name: 'Emmanuel Fonkam',
      firstName: 'Emmanuel',
      lastName: 'Fonkam',
      phone: '+237677100003',
      role: 'landlord',
      status: 'active',
    },
  });

  const tenant1 = await prisma.user.upsert({
    where: { email: 'tenant1@spacerentals.cm' },
    update: {},
    create: {
      email: 'tenant1@spacerentals.cm',
      passwordHash,
      name: 'Marie Claire Ateba',
      firstName: 'Marie Claire',
      lastName: 'Ateba',
      phone: '+237691200001',
      role: 'tenant',
      status: 'active',
    },
  });

  const tenant2 = await prisma.user.upsert({
    where: { email: 'tenant2@spacerentals.cm' },
    update: {},
    create: {
      email: 'tenant2@spacerentals.cm',
      passwordHash,
      name: 'Paul Biya Nkemdirim',
      firstName: 'Paul',
      lastName: 'Nkemdirim',
      phone: '+237691200002',
      role: 'tenant',
      status: 'active',
    },
  });

  const agent = await prisma.user.upsert({
    where: { email: 'agent1@spacerentals.cm' },
    update: {},
    create: {
      email: 'agent1@spacerentals.cm',
      passwordHash,
      name: 'Victor Tagne',
      firstName: 'Victor',
      lastName: 'Tagne',
      phone: '+237655300001',
      role: 'agent',
      status: 'active',
    },
  });

  console.log('✅ Users seeded');

  // ── Properties ────────────────────────────────────────────────────
  const properties = [
    {
      landlordId: landlord1.id,
      title: 'Modern 2-Bedroom Apartment in Bastos',
      description: 'Beautiful modern apartment in the heart of Bastos, Yaoundé. Fully furnished with air conditioning, DSTV, and 24h security. Walking distance to embassies and supermarkets.',
      location: 'Bastos, Yaoundé',
      monthlyRent: 180000,
      deposit: 360000,
      status: 'available',
      category: 'Apartment',
      bedrooms: 2,
      bathrooms: 2,
      areaSqM: 85.0,
      furnished: true,
      hasWater: true,
      hasElectricity: true,
      isFenced: true,
      latitude: 3.8861,
      longitude: 11.5163,
      images: JSON.stringify([
        'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800',
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      ]),
      amenities: JSON.stringify({ wifi: true, parking: true, pool: false, gym: false, security: true }),
    },
    {
      landlordId: landlord1.id,
      title: 'Studio Meublé — Omnisports, Yaoundé',
      description: 'Studio entièrement meublé dans le quartier Omnisports. Idéal pour étudiants ou jeunes professionnels. Accès facile aux transports en commun.',
      location: 'Omnisports, Yaoundé',
      monthlyRent: 65000,
      deposit: 130000,
      status: 'available',
      category: 'Studio',
      bedrooms: 1,
      bathrooms: 1,
      areaSqM: 32.0,
      furnished: true,
      hasWater: true,
      hasElectricity: true,
      isFenced: false,
      latitude: 3.8606,
      longitude: 11.5183,
      images: JSON.stringify([
        'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
      ]),
      amenities: JSON.stringify({ wifi: true, parking: false, pool: false, gym: false, security: false }),
    },
    {
      landlordId: landlord2.id,
      title: 'Luxury 4-Bedroom Villa — Bonamoussadi',
      description: 'Prestigious 4-bedroom villa in Bonamoussadi, Douala. Private garden, swimming pool, covered parking for 3 cars, 24h security guard, backup generator and borehole.',
      location: 'Bonamoussadi, Douala',
      monthlyRent: 450000,
      deposit: 900000,
      status: 'available',
      category: 'Villa',
      bedrooms: 4,
      bathrooms: 3,
      areaSqM: 280.0,
      furnished: true,
      hasWater: true,
      hasElectricity: true,
      isFenced: true,
      latitude: 4.0645,
      longitude: 9.7266,
      images: JSON.stringify([
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
        'https://images.unsplash.com/photo-1416331108676-a22ccb276e35?w=800',
        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
      ]),
      amenities: JSON.stringify({ wifi: true, parking: true, pool: true, gym: false, security: true }),
    },
    {
      landlordId: landlord2.id,
      title: '3-Bedroom Flat — Akwa, Douala',
      description: '3-bedroom apartment on the 4th floor in Akwa. Close to Bonapriso, banks, restaurants and the city center. Good natural light, tiled floors throughout.',
      location: 'Akwa, Douala',
      monthlyRent: 200000,
      deposit: 400000,
      status: 'available',
      category: 'Apartment',
      bedrooms: 3,
      bathrooms: 2,
      areaSqM: 120.0,
      furnished: false,
      hasWater: true,
      hasElectricity: true,
      isFenced: true,
      latitude: 4.0539,
      longitude: 9.6976,
      images: JSON.stringify([
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
      ]),
      amenities: JSON.stringify({ wifi: false, parking: true, pool: false, gym: false, security: true }),
    },
    {
      landlordId: landlord3.id,
      title: 'Commercial Space — Marché Central, Yaoundé',
      description: 'Prime commercial space near Marché Central in Yaoundé. Ground floor with wide display windows, high foot traffic area, ideal for a boutique, pharmacy or office.',
      location: 'Marché Central, Yaoundé',
      monthlyRent: 300000,
      deposit: 600000,
      status: 'available',
      category: 'Commercial',
      bedrooms: 0,
      bathrooms: 1,
      areaSqM: 65.0,
      furnished: false,
      hasWater: true,
      hasElectricity: true,
      isFenced: false,
      latitude: 3.8634,
      longitude: 11.5167,
      images: JSON.stringify([
        'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800',
        'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800',
      ]),
      amenities: JSON.stringify({ wifi: false, parking: true, pool: false, gym: false, security: false }),
    },
    {
      landlordId: landlord3.id,
      title: 'Cozy Studio — University of Buea Area',
      description: 'Perfect studio apartment for students at the University of Buea. Walking distance to the main campus gate. Shared kitchen, private bathroom, secure compound.',
      location: 'Molyko, Buea',
      monthlyRent: 45000,
      deposit: 90000,
      status: 'available',
      category: 'Studio',
      bedrooms: 1,
      bathrooms: 1,
      areaSqM: 25.0,
      furnished: true,
      hasWater: true,
      hasElectricity: true,
      isFenced: true,
      latitude: 4.1537,
      longitude: 9.2403,
      images: JSON.stringify([
        'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800',
      ]),
      amenities: JSON.stringify({ wifi: true, parking: false, pool: false, gym: false, security: false }),
    },
    {
      landlordId: landlord1.id,
      title: '1-Bedroom Apartment — Nlongkak, Yaoundé',
      description: 'Clean and bright 1-bedroom apartment in Nlongkak. Quiet neighborhood, close to Carrefour Nlongkak and several schools. Good for couples or young professionals.',
      location: 'Nlongkak, Yaoundé',
      monthlyRent: 95000,
      deposit: 190000,
      status: 'available',
      category: 'Apartment',
      bedrooms: 1,
      bathrooms: 1,
      areaSqM: 50.0,
      furnished: false,
      hasWater: true,
      hasElectricity: true,
      isFenced: true,
      latitude: 3.8762,
      longitude: 11.5103,
      images: JSON.stringify([
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?w=800',
      ]),
      amenities: JSON.stringify({ wifi: false, parking: false, pool: false, gym: false, security: false }),
    },
    {
      landlordId: landlord2.id,
      title: 'Shared Student Housing — Ngoa-Ekele',
      description: 'Affordable shared accommodation near FMSB (University of Yaoundé 1). Each tenant gets a private room. Shared living room, kitchen and bathrooms.',
      location: 'Ngoa-Ekele, Yaoundé',
      monthlyRent: 35000,
      deposit: 70000,
      status: 'available',
      category: 'Shared Housing',
      bedrooms: 1,
      bathrooms: 1,
      areaSqM: 20.0,
      furnished: true,
      hasWater: true,
      hasElectricity: true,
      isFenced: false,
      latitude: 3.8532,
      longitude: 11.4973,
      images: JSON.stringify([
        'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800',
      ]),
      amenities: JSON.stringify({ wifi: true, parking: false, pool: false, gym: false, security: false }),
    },
    {
      landlordId: landlord3.id,
      title: 'Premium Office Suite — Bonapriso, Douala',
      description: 'Fully furnished premium office suite in Bonapriso. 2 private offices, meeting room, reception area, fast fiber internet and backup power. Ideal for SMEs.',
      location: 'Bonapriso, Douala',
      monthlyRent: 380000,
      deposit: 760000,
      status: 'available',
      category: 'Commercial',
      bedrooms: 0,
      bathrooms: 2,
      areaSqM: 110.0,
      furnished: true,
      hasWater: true,
      hasElectricity: true,
      isFenced: true,
      latitude: 4.0431,
      longitude: 9.6983,
      images: JSON.stringify([
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
        'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
      ]),
      amenities: JSON.stringify({ wifi: true, parking: true, pool: false, gym: false, security: true }),
    },
    {
      landlordId: landlord1.id,
      title: '5-Bedroom Family Villa — Mendong, Yaoundé',
      description: 'Spacious 5-bedroom family villa in the green hills of Mendong. Large garden, children\'s play area, borehole, generator, separate servant quarters. Perfect for families.',
      location: 'Mendong, Yaoundé',
      monthlyRent: 350000,
      deposit: 700000,
      status: 'available',
      category: 'Villa',
      bedrooms: 5,
      bathrooms: 4,
      areaSqM: 320.0,
      furnished: false,
      hasWater: true,
      hasElectricity: true,
      isFenced: true,
      latitude: 3.8206,
      longitude: 11.4854,
      images: JSON.stringify([
        'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
        'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800',
        'https://images.unsplash.com/photo-1449844908441-8829872d2607?w=800',
      ]),
      amenities: JSON.stringify({ wifi: false, parking: true, pool: false, gym: false, security: true }),
    },
  ];

  for (const prop of properties) {
    const existing = await prisma.property.findFirst({
      where: { title: prop.title, landlordId: prop.landlordId },
    });
    if (!existing) {
      const created = await prisma.property.create({ data: prop as any });
      // Add verification record
      await prisma.propertyVerification.upsert({
        where: { propertyId: created.id },
        update: {},
        create: {
          propertyId: created.id,
          status: 'verified',
          level: 2,
          verifiedBy: agent.id,
          notes: 'Verified by SpaceRentals agent',
        },
      });
    }
  }

  console.log('✅ Properties seeded (10 properties across Yaoundé, Douala & Buea)');

  // ── Subscriptions for Landlords ───────────────────────────────────
  for (const landlord of [landlord1, landlord2, landlord3]) {
    await prisma.subscription.upsert({
      where: { id: landlord.id },
      update: {},
      create: {
        id: landlord.id,
        landlordId: landlord.id,
        planId: 'standard',
        status: 'active',
        activeListingCount: 3,
        startedAt: new Date(),
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    });
  }

  console.log('✅ Subscriptions seeded');
  console.log('\n🎉 Database seeded successfully!');
  console.log('\n📧 Test Credentials (password: Password123! for all):');
  console.log('   Admin:     admin@spacerentals.cm');
  console.log('   Landlord1: landlord1@spacerentals.cm');
  console.log('   Landlord2: landlord2@spacerentals.cm');
  console.log('   Landlord3: landlord3@spacerentals.cm');
  console.log('   Tenant1:   tenant1@spacerentals.cm');
  console.log('   Tenant2:   tenant2@spacerentals.cm');
  console.log('   Agent:     agent1@spacerentals.cm');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(async () => { await prisma.$disconnect(); });
