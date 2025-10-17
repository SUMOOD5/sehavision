const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { validateRequest, schemas } = require('../middleware/validation');

// Middleware to check if user is admin
const verifyAdmin = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({
            success: false,
            error: 'Access denied. Admin privileges required.'
        });
    }
    next();
};

// Apply authentication and admin check to all routes
router.use(authenticateToken);
router.use(verifyAdmin);

// Get admin dashboard statistics
router.get('/dashboard', async (req, res) => {
    try {
        const stats = {};

        // Get user statistics
        const userStats = await db.get(`
      SELECT 
        COUNT(*) as total_users,
        COUNT(CASE WHEN created_at >= datetime('now', '-30 days') THEN 1 END) as new_users_30d,
        COUNT(CASE WHEN role = 'admin' THEN 1 END) as admin_users
      FROM users
    `);
        stats.users = userStats;

        // Get medicine statistics
        const medicineStats = await db.get(`
      SELECT 
        COUNT(*) as total_medicines,
        COUNT(CASE WHEN expiry_date < datetime('now') THEN 1 END) as expired_medicines,
        COUNT(CASE WHEN expiry_date BETWEEN datetime('now') AND datetime('now', '+30 days') THEN 1 END) as expiring_soon
      FROM medicines
    `);
        stats.medicines = medicineStats;

        // Get reminder statistics
        const reminderStats = await db.get(`
      SELECT 
        COUNT(*) as total_reminders,
        COUNT(CASE WHEN is_active = 1 THEN 1 END) as active_reminders,
        COUNT(CASE WHEN scheduled_time < datetime('now') THEN 1 END) as overdue_reminders
      FROM reminders
    `);
        stats.reminders = reminderStats;

        // Get recent activity
        const recentUsers = await db.all(`
      SELECT id, name, email, created_at
      FROM users
      ORDER BY created_at DESC
      LIMIT 5
    `);

        const recentMedicines = await db.all(`
      SELECT id, name, brand, created_at
      FROM medicines
      ORDER BY created_at DESC
      LIMIT 5
    `);

        stats.recent_activity = {
            users: recentUsers,
            medicines: recentMedicines
        };

        res.json({
            success: true,
            data: stats
        });
    } catch (error) {
        console.error('Admin dashboard error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch dashboard statistics'
        });
    }
});

// Get all users with pagination
router.get('/users', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const offset = (page - 1) * limit;
        const search = req.query.search || '';

        let query = `
      SELECT id, name, email, phone, role, created_at, updated_at
      FROM users
    `;
        let params = [];

        if (search) {
            query += ` WHERE name LIKE ? OR email LIKE ?`;
            params = [`%${search}%`, `%${search}%`];
        }

        query += ` ORDER BY created_at DESC LIMIT ? OFFSET ?`;
        params.push(limit, offset);

        const users = await db.all(query, params);

        // Get total count
        let countQuery = `SELECT COUNT(*) as total FROM users`;
        let countParams = [];

        if (search) {
            countQuery += ` WHERE name LIKE ? OR email LIKE ?`;
            countParams = [`%${search}%`, `%${search}%`];
        }

        const countResult = await db.get(countQuery, countParams);
        const total = countResult.total;

        res.json({
            success: true,
            data: {
                users,
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get users error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch users'
        });
    }
});

// Get user by ID
router.get('/users/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const user = await db.get(`
      SELECT id, name, email, phone, role, created_at, updated_at
      FROM users
      WHERE id = ?
    `, [id]);

        if (!user) {
            return res.status(404).json({
                success: false,
                error: 'User not found'
            });
        }

        // Get user's reminders count
        const reminderCount = await db.get(`
      SELECT COUNT(*) as count FROM reminders WHERE user_id = ?
    `, [id]);

        user.reminders_count = reminderCount.count;

        res.json({
            success: true,
            data: { user }
        });
    } catch (error) {
        console.error('Get user error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch user'
        });
    }
});

// Update user role
router.put('/users/:id/role', async (req, res) => {
    try {
        const { id } = req.params;
        const { role } = req.body;

        if (!['user', 'admin'].includes(role)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid role. Must be "user" or "admin"'
            });
        }

        // Prevent admin from changing their own role
        if (parseInt(id) === req.user.id) {
            return res.status(400).json({
                success: false,
                error: 'Cannot change your own role'
            });
        }

        const result = await db.run(`
      UPDATE users
      SET role = ?, updated_at = datetime('now')
      WHERE id = ?
    `, [role, id]);

        if (result.changes === 0) {
            return res.status(404).json({
                success: false,
                error: 'User not found'
            });
        }

        res.json({
            success: true,
            message: 'User role updated successfully'
        });
    } catch (error) {
        console.error('Update user role error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to update user role'
        });
    }
});

// Delete user
router.delete('/users/:id', async (req, res) => {
    try {
        const { id } = req.params;

        // Prevent admin from deleting themselves
        if (parseInt(id) === req.user.id) {
            return res.status(400).json({
                success: false,
                error: 'Cannot delete your own account'
            });
        }

        // Start transaction
        await db.run('BEGIN TRANSACTION');

        try {
            // Delete user's reminders first
            await db.run('DELETE FROM reminders WHERE user_id = ?', [id]);

            // Delete user
            const result = await db.run('DELETE FROM users WHERE id = ?', [id]);

            if (result.changes === 0) {
                await db.run('ROLLBACK');
                return res.status(404).json({
                    success: false,
                    error: 'User not found'
                });
            }

            await db.run('COMMIT');

            res.json({
                success: true,
                message: 'User deleted successfully'
            });
        } catch (error) {
            await db.run('ROLLBACK');
            throw error;
        }
    } catch (error) {
        console.error('Delete user error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to delete user'
        });
    }
});

// Get all medicines with pagination and filters
router.get('/medicines', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const offset = (page - 1) * limit;
        const search = req.query.search || '';
        const filter = req.query.filter || 'all'; // all, expired, expiring_soon

        let query = `
      SELECT id, name, brand, dosage, barcode, expiry_date, created_at, updated_at
      FROM medicines
    `;
        let params = [];
        let conditions = [];

        if (search) {
            conditions.push(`(name LIKE ? OR brand LIKE ? OR barcode LIKE ?)`);
            params.push(`%${search}%`, `%${search}%`, `%${search}%`);
        }

        if (filter === 'expired') {
            conditions.push(`expiry_date < datetime('now')`);
        } else if (filter === 'expiring_soon') {
            conditions.push(`expiry_date BETWEEN datetime('now') AND datetime('now', '+30 days')`);
        }

        if (conditions.length > 0) {
            query += ` WHERE ${conditions.join(' AND ')}`;
        }

        query += ` ORDER BY created_at DESC LIMIT ? OFFSET ?`;
        params.push(limit, offset);

        const medicines = await db.all(query, params);

        // Get total count
        let countQuery = `SELECT COUNT(*) as total FROM medicines`;
        let countParams = [];

        if (conditions.length > 0) {
            countQuery += ` WHERE ${conditions.join(' AND ')}`;
            countParams = params.slice(0, -2); // Remove limit and offset
        }

        const countResult = await db.get(countQuery, countParams);
        const total = countResult.total;

        res.json({
            success: true,
            data: {
                medicines,
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        console.error('Get medicines error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch medicines'
        });
    }
});

// Create medicine (admin only)
router.post('/medicines', validateRequest(schemas.medicine), async (req, res) => {
    try {
        const {
            name,
            brand,
            dosage,
            instructions,
            warnings,
            interactions,
            barcode,
            expiry_date,
            image_paths
        } = req.body;

        // Check if medicine with same barcode already exists
        if (barcode) {
            const existing = await db.get(
                'SELECT id FROM medicines WHERE barcode = ?',
                [barcode]
            );

            if (existing) {
                return res.status(400).json({
                    success: false,
                    error: 'Medicine with this barcode already exists'
                });
            }
        }

        const result = await db.run(`
      INSERT INTO medicines (
        name, brand, dosage, instructions, warnings, interactions,
        barcode, expiry_date, image_paths, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'))
    `, [
            name,
            brand,
            dosage,
            instructions,
            JSON.stringify(warnings || []),
            JSON.stringify(interactions || []),
            barcode,
            expiry_date,
            JSON.stringify(image_paths || [])
        ]);

        const medicine = await db.get(
            'SELECT * FROM medicines WHERE id = ?',
            [result.lastID]
        );

        // Parse JSON fields
        medicine.warnings = JSON.parse(medicine.warnings || '[]');
        medicine.interactions = JSON.parse(medicine.interactions || '[]');
        medicine.image_paths = JSON.parse(medicine.image_paths || '[]');

        res.status(201).json({
            success: true,
            data: { medicine },
            message: 'Medicine created successfully'
        });
    } catch (error) {
        console.error('Create medicine error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to create medicine'
        });
    }
});

// Update medicine (admin only)
router.put('/medicines/:id', validateRequest(schemas.medicine), async (req, res) => {
    try {
        const { id } = req.params;
        const {
            name,
            brand,
            dosage,
            instructions,
            warnings,
            interactions,
            barcode,
            expiry_date,
            image_paths
        } = req.body;

        // Check if medicine exists
        const existing = await db.get(
            'SELECT id FROM medicines WHERE id = ?',
            [id]
        );

        if (!existing) {
            return res.status(404).json({
                success: false,
                error: 'Medicine not found'
            });
        }

        // Check if barcode is being changed and if it conflicts
        if (barcode) {
            const barcodeConflict = await db.get(
                'SELECT id FROM medicines WHERE barcode = ? AND id != ?',
                [barcode, id]
            );

            if (barcodeConflict) {
                return res.status(400).json({
                    success: false,
                    error: 'Medicine with this barcode already exists'
                });
            }
        }

        await db.run(`
      UPDATE medicines
      SET name = ?, brand = ?, dosage = ?, instructions = ?, warnings = ?,
          interactions = ?, barcode = ?, expiry_date = ?, image_paths = ?,
          updated_at = datetime('now')
      WHERE id = ?
    `, [
            name,
            brand,
            dosage,
            instructions,
            JSON.stringify(warnings || []),
            JSON.stringify(interactions || []),
            barcode,
            expiry_date,
            JSON.stringify(image_paths || []),
            id
        ]);

        const medicine = await db.get(
            'SELECT * FROM medicines WHERE id = ?',
            [id]
        );

        // Parse JSON fields
        medicine.warnings = JSON.parse(medicine.warnings || '[]');
        medicine.interactions = JSON.parse(medicine.interactions || '[]');
        medicine.image_paths = JSON.parse(medicine.image_paths || '[]');

        res.json({
            success: true,
            data: { medicine },
            message: 'Medicine updated successfully'
        });
    } catch (error) {
        console.error('Update medicine error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to update medicine'
        });
    }
});

// Delete medicine (admin only)
router.delete('/medicines/:id', async (req, res) => {
    try {
        const { id } = req.params;

        // Check if medicine exists
        const existing = await db.get(
            'SELECT id FROM medicines WHERE id = ?',
            [id]
        );

        if (!existing) {
            return res.status(404).json({
                success: false,
                error: 'Medicine not found'
            });
        }

        // Start transaction
        await db.run('BEGIN TRANSACTION');

        try {
            // Delete related reminders first
            await db.run('DELETE FROM reminders WHERE medicine_id = ?', [id]);

            // Delete medicine
            await db.run('DELETE FROM medicines WHERE id = ?', [id]);

            await db.run('COMMIT');

            res.json({
                success: true,
                message: 'Medicine deleted successfully'
            });
        } catch (error) {
            await db.run('ROLLBACK');
            throw error;
        }
    } catch (error) {
        console.error('Delete medicine error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to delete medicine'
        });
    }
});

// Get system logs (placeholder - would need logging implementation)
router.get('/logs', async (req, res) => {
    try {
        // This is a placeholder - in a real application, you'd have a logging system
        const logs = [
            {
                id: 1,
                level: 'info',
                message: 'System started',
                timestamp: new Date().toISOString(),
                user_id: null
            },
            {
                id: 2,
                level: 'info',
                message: 'Admin dashboard accessed',
                timestamp: new Date().toISOString(),
                user_id: req.user.id
            }
        ];

        res.json({
            success: true,
            data: { logs }
        });
    } catch (error) {
        console.error('Get logs error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch logs'
        });
    }
});

// Export database (backup)
router.get('/export', async (req, res) => {
    try {
        // This is a simplified export - in production, you'd want proper backup handling
        const medicines = await db.all('SELECT * FROM medicines');
        const users = await db.all('SELECT id, name, email, role, created_at FROM users');
        const reminders = await db.all('SELECT * FROM reminders');

        const exportData = {
            timestamp: new Date().toISOString(),
            medicines,
            users,
            reminders
        };

        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', 'attachment; filename=sehavision-backup.json');
        res.json(exportData);
    } catch (error) {
        console.error('Export error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to export data'
        });
    }
});

module.exports = router;