const { Pool } = require('pg');

const connectionString = process.env.DATABASE_URL || process.env.POSTGRES_URL;

if (!connectionString) {
  console.warn('WARNING: DATABASE_URL not set. PostgreSQL connection requires DATABASE_URL in production.');
}

const pool = new Pool({
  connectionString,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

async function initializeDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS posts (
      id SERIAL PRIMARY KEY,
      title TEXT,
      excerpt TEXT,
      date TEXT,
      readTime TEXT,
      category TEXT,
      image TEXT,
      tags JSONB,
      pages JSONB
    );
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS projects (
      id SERIAL PRIMARY KEY,
      title TEXT,
      description TEXT,
      image TEXT,
      stack JSONB,
      github TEXT,
      demo TEXT
    );
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS certifications (
      id SERIAL PRIMARY KEY,
      name TEXT,
      issuer TEXT,
      date TEXT,
      description TEXT,
      image TEXT,
      certificateLink TEXT
    );
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      username TEXT UNIQUE,
      password TEXT
    );
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS testimonials (
      id SERIAL PRIMARY KEY,
      name TEXT,
      role TEXT,
      company TEXT,
      image TEXT,
      rating INTEGER,
      text TEXT,
      project TEXT,
      phone TEXT
    );
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS profile (
      id SERIAL PRIMARY KEY,
      name TEXT,
      title TEXT,
      subtitle TEXT,
      bio TEXT,
      avatar TEXT,
      welcome_message TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `);

  console.log('PostgreSQL tables initialized');
  return pool;
}

module.exports = { pool, initializeDb };
