const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = process.env.NODE_ENV === 'test'
  ? path.join(__dirname, '..', 'database', 'sehavision_test.db')
  : path.join(__dirname, '..', 'database', 'sehavision.db');

// Ensure database directory exists
const dbDir = path.dirname(dbPath);
const fs = require('fs');
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database:', err.message);
  } else {
    console.log('Connected to SQLite database');
  }
});

// Enable foreign keys
db.run('PRAGMA foreign_keys = ON');

// Create tables if they don't exist
const createTables = () => {
  return new Promise((resolve, reject) => {
    db.serialize(() => {
      // Users table
      db.run(`
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          name TEXT NOT NULL,
          phone TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      `);

      // Medicines table
      db.run(`
        CREATE TABLE IF NOT EXISTS medicines (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          brand TEXT,
          barcode TEXT UNIQUE,
          dosage TEXT,
          instructions TEXT,
          warnings TEXT,
          interactions TEXT,
          expiry_date DATE,
          image_paths TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      `);

      // Reminders table
      db.run(`
        CREATE TABLE IF NOT EXISTS reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          medicine_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          scheduled_time DATETIME NOT NULL,
          frequency TEXT DEFAULT 'once',
          is_active BOOLEAN DEFAULT 1,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (medicine_id) REFERENCES medicines (id) ON DELETE CASCADE
        )
      `);

      // Medicine interactions table
      db.run(`
        CREATE TABLE IF NOT EXISTS medicine_interactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicine1_id INTEGER NOT NULL,
          medicine2_id INTEGER NOT NULL,
          interaction_type TEXT NOT NULL,
          severity TEXT NOT NULL,
          description TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (medicine1_id) REFERENCES medicines (id) ON DELETE CASCADE,
          FOREIGN KEY (medicine2_id) REFERENCES medicines (id) ON DELETE CASCADE,
          UNIQUE(medicine1_id, medicine2_id)
        )
      `, (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  });
};

// Initialize database
createTables().catch(console.error);

module.exports = db;
