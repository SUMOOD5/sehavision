// Test setup file
const path = require('path');
const fs = require('fs');

// Create test directories if they don't exist
const testDirs = [
    path.join(__dirname, '..', 'uploads'),
    path.join(__dirname, '..', 'uploads', 'scans'),
    path.join(__dirname, '..', 'uploads', 'medicines'),
    path.join(__dirname, '..', 'assets'),
    path.join(__dirname, '..', 'assets', 'samples'),
    path.join(__dirname, '..', 'database')
];

testDirs.forEach(dir => {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
});

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_key';

// Initialize test database
const db = require('../config/database');

// Create tables only, don't insert sample data
const initTestDatabase = () => {
    return new Promise((resolve, reject) => {
        db.serialize(() => {
            // Create tables
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

// Run database initialization for tests
initTestDatabase();
