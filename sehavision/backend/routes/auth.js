const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../config/database');
const { generateToken } = require('../middleware/auth');
const { validateRequest, schemas } = require('../middleware/validation');

const router = express.Router();

// Register
router.post('/register', validateRequest(schemas.register), (req, res) => {
    const { email, password, name, phone } = req.body;

    // Check if user already exists
    db.get('SELECT id FROM users WHERE email = ?', [email], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (row) {
            return res.status(400).json({ error: 'User already exists' });
        }

        // Hash password
        bcrypt.hash(password, 10, (err, hash) => {
            if (err) {
                return res.status(500).json({ error: 'Password hashing error' });
            }

            // Insert user
            db.run(
                'INSERT INTO users (email, password_hash, name, phone) VALUES (?, ?, ?, ?)',
                [email, hash, name, phone || null],
                function (err) {
                    if (err) {
                        console.error('Database error creating user:', err);
                        return res.status(500).json({ error: 'Failed to create user' });
                    }

                    const token = generateToken({ id: this.lastID, email });

                    res.status(201).json({
                        message: 'User created successfully',
                        token,
                        user: {
                            id: this.lastID,
                            email,
                            name,
                            phone
                        }
                    });
                }
            );
        });
    });
});

// Login
router.post('/login', validateRequest(schemas.login), (req, res) => {
    const { email, password } = req.body;

    db.get('SELECT * FROM users WHERE email = ?', [email], (err, user) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        bcrypt.compare(password, user.password_hash, (err, isMatch) => {
            if (err) {
                return res.status(500).json({ error: 'Password comparison error' });
            }

            if (!isMatch) {
                return res.status(401).json({ error: 'Invalid credentials' });
            }

            const token = generateToken({ id: user.id, email: user.email });

            res.json({
                message: 'Login successful',
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    phone: user.phone
                }
            });
        });
    });
});

// Get current user profile
router.get('/profile', require('../middleware/auth').authenticateToken, (req, res) => {
    res.json({
        user: req.user
    });
});

module.exports = router;
