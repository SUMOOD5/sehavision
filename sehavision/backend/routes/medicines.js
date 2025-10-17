const express = require('express');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { validateRequest, schemas } = require('../middleware/validation');

const router = express.Router();

// Get all medicines
router.get('/', (req, res) => {
    const { search, limit = 50, offset = 0 } = req.query;

    let query = 'SELECT * FROM medicines';
    let params = [];

    if (search) {
        query += ' WHERE name LIKE ? OR brand LIKE ? OR barcode LIKE ?';
        const searchTerm = `%${search}%`;
        params = [searchTerm, searchTerm, searchTerm];
    }

    query += ' ORDER BY name LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    db.all(query, params, (err, rows) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        // Parse JSON fields
        const medicines = rows.map(row => ({
            ...row,
            interactions: row.interactions ? JSON.parse(row.interactions) : null,
            image_paths: row.image_paths ? JSON.parse(row.image_paths) : []
        }));

        res.json({ medicines });
    });
});

// Get medicine by ID
router.get('/:id', (req, res) => {
    const { id } = req.params;

    db.get('SELECT * FROM medicines WHERE id = ?', [id], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!row) {
            return res.status(404).json({ error: 'Medicine not found' });
        }

        // Parse JSON fields
        const medicine = {
            ...row,
            interactions: row.interactions ? JSON.parse(row.interactions) : null,
            image_paths: row.image_paths ? JSON.parse(row.image_paths) : []
        };

        res.json({ medicine });
    });
});

// Create medicine
router.post('/', authenticateToken, validateRequest(schemas.medicine), (req, res) => {
    const {
        name, brand, barcode, dosage, instructions, warnings,
        interactions, expiry_date, image_paths
    } = req.body;

    // Check if barcode already exists
    if (barcode) {
        db.get('SELECT id FROM medicines WHERE barcode = ?', [barcode], (err, row) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (row) {
                return res.status(400).json({ error: 'Medicine with this barcode already exists' });
            }

            createMedicine();
        });
    } else {
        createMedicine();
    }

    function createMedicine() {
        const interactionsJson = interactions ? JSON.stringify(interactions) : null;
        const imagePathsJson = image_paths ? JSON.stringify(image_paths) : null;

        db.run(
            `INSERT INTO medicines (name, brand, barcode, dosage, instructions, warnings, interactions, expiry_date, image_paths)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [name, brand || null, barcode || null, dosage || null, instructions || null,
                warnings || null, interactionsJson, expiry_date || null, imagePathsJson],
            function (err) {
                if (err) {
                    return res.status(500).json({ error: 'Failed to create medicine' });
                }

                res.status(201).json({
                    message: 'Medicine created successfully',
                    medicine: {
                        id: this.lastID,
                        name, brand, barcode, dosage, instructions, warnings,
                        interactions, expiry_date, image_paths
                    }
                });
            }
        );
    }
});

// Update medicine
router.put('/:id', authenticateToken, validateRequest(schemas.medicine), (req, res) => {
    const { id } = req.params;
    const {
        name, brand, barcode, dosage, instructions, warnings,
        interactions, expiry_date, image_paths
    } = req.body;

    // Check if medicine exists
    db.get('SELECT id FROM medicines WHERE id = ?', [id], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!row) {
            return res.status(404).json({ error: 'Medicine not found' });
        }

        // Check if barcode already exists (excluding current medicine)
        if (barcode) {
            db.get('SELECT id FROM medicines WHERE barcode = ? AND id != ?', [barcode, id], (err, row) => {
                if (err) {
                    return res.status(500).json({ error: 'Database error' });
                }

                if (row) {
                    return res.status(400).json({ error: 'Medicine with this barcode already exists' });
                }

                updateMedicine();
            });
        } else {
            updateMedicine();
        }

        function updateMedicine() {
            const interactionsJson = interactions ? JSON.stringify(interactions) : null;
            const imagePathsJson = image_paths ? JSON.stringify(image_paths) : null;

            db.run(
                `UPDATE medicines SET 
         name = ?, brand = ?, barcode = ?, dosage = ?, instructions = ?, 
         warnings = ?, interactions = ?, expiry_date = ?, image_paths = ?, 
         updated_at = CURRENT_TIMESTAMP
         WHERE id = ?`,
                [name, brand || null, barcode || null, dosage || null, instructions || null,
                    warnings || null, interactionsJson, expiry_date || null, imagePathsJson, id],
                function (err) {
                    if (err) {
                        return res.status(500).json({ error: 'Failed to update medicine' });
                    }

                    res.json({
                        message: 'Medicine updated successfully',
                        medicine: {
                            id: parseInt(id),
                            name, brand, barcode, dosage, instructions, warnings,
                            interactions, expiry_date, image_paths
                        }
                    });
                }
            );
        }
    });
});

// Delete medicine
router.delete('/:id', authenticateToken, (req, res) => {
    const { id } = req.params;

    db.get('SELECT id FROM medicines WHERE id = ?', [id], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!row) {
            return res.status(404).json({ error: 'Medicine not found' });
        }

        db.run('DELETE FROM medicines WHERE id = ?', [id], function (err) {
            if (err) {
                return res.status(500).json({ error: 'Failed to delete medicine' });
            }

            res.json({ message: 'Medicine deleted successfully' });
        });
    });
});

module.exports = router;
