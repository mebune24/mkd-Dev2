const sqlite3 = require('sqlite3').verbose();
const { open } = require('sqlite');

async function openDb() {
  return open({
    filename: './database.sqlite',
    driver: sqlite3.Database
  });
}

async function initializeDb() {
  const db = await openDb();
  await db.exec(`
    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      excerpt TEXT,
      date TEXT,
      readTime TEXT,
      category TEXT,
      image TEXT,
      tags TEXT,
      pages TEXT
    );
    CREATE TABLE IF NOT EXISTS projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      image TEXT,
      stack TEXT,
      github TEXT,
      demo TEXT
    );
    CREATE TABLE IF NOT EXISTS certifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      issuer TEXT,
      date TEXT,
      description TEXT,
      image TEXT,
      certificateLink TEXT
    );
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT
    );
    CREATE TABLE IF NOT EXISTS testimonials (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      role TEXT,
      company TEXT,
      image TEXT,
      rating INTEGER,
      text TEXT,
      project TEXT,
      phone TEXT
    );
    CREATE TABLE IF NOT EXISTS profile (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      title TEXT,
      subtitle TEXT,
      bio TEXT,
      avatar TEXT,
      welcome_message TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);
  return db;
}

module.exports = { openDb, initializeDb };
