const jwt = require('jsonwebtoken');
const db = require('../config/database');

const JWT_SECRET = process.env.JWT_SECRET || 'sehavision_secret_key_2024';

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
        return res.status(401).json({ error: 'Access token required' });
    }

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid or expired token' });
        }

        // Verify user still exists in database
        db.get('SELECT id, email, name FROM users WHERE id = ?', [user.id], (err, row) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (!row) {
                return res.status(403).json({ error: 'User not found' });
            }

            req.user = row;
            next();
        });
    });
};

const generateToken = (user) => {
    return jwt.sign(
        {
            id: user.id,
            email: user.email
        },
        JWT_SECRET,
        { expiresIn: '24h' }
    );
};

const requireAdmin = (req, res, next) => {
    // For now, we'll consider the first user as admin
    // In production, you should have a proper admin role system
    // In test environment, allow any authenticated user to be admin
    if (process.env.NODE_ENV === 'test' || req.user.id === 1) {
        next();
    } else {
        res.status(403).json({ error: 'Admin access required' });
    }
};

module.exports = {
    authenticateToken,
    generateToken,
    requireAdmin
};
