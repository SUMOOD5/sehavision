const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { validateRequest, schemas } = require('../middleware/validation');

// Check drug interactions
router.post('/check', authenticateToken, validateRequest(schemas.interactionCheck), async (req, res) => {
    try {
        const { medicine_ids } = req.body;

        if (!Array.isArray(medicine_ids) || medicine_ids.length < 2) {
            return res.status(400).json({
                error: 'At least 2 medicines required for interaction check'
            });
        }

        // Get medicines by IDs
        const placeholders = medicine_ids.map(() => '?').join(',');
        const medicines = await new Promise((resolve, reject) => {
            db.all(`
                SELECT id, name, brand, interactions
                FROM medicines
                WHERE id IN (${placeholders})
            `, medicine_ids, (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });

        if (medicines.length !== medicine_ids.length) {
            return res.status(400).json({
                error: 'One or more medicines not found'
            });
        }

        // Parse interactions for each medicine
        const medicineInteractions = medicines.map(medicine => ({
            ...medicine,
            interactions: JSON.parse(medicine.interactions || '[]')
        }));

        // Check for interactions
        const interactions = [];
        const warnings = [];

        // Simple interaction checking logic
        // In a real application, this would use a comprehensive drug interaction database
        for (let i = 0; i < medicineInteractions.length; i++) {
            for (let j = i + 1; j < medicineInteractions.length; j++) {
                const med1 = medicineInteractions[i];
                const med2 = medicineInteractions[j];

                // Check if med1 lists med2 as an interaction
                const med1InteractsWithMed2 = med1.interactions.some(interaction =>
                    interaction.toLowerCase().includes(med2.name.toLowerCase()) ||
                    (med2.brand && interaction.toLowerCase().includes(med2.brand.toLowerCase()))
                );

                // Check if med2 lists med1 as an interaction
                const med2InteractsWithMed1 = med2.interactions.some(interaction =>
                    interaction.toLowerCase().includes(med1.name.toLowerCase()) ||
                    (med1.brand && interaction.toLowerCase().includes(med1.brand.toLowerCase()))
                );

                if (med1InteractsWithMed1 || med2InteractsWithMed1) {
                    const interaction = {
                        medicine1: {
                            id: med1.id,
                            name: med1.name,
                            brand: med1.brand
                        },
                        medicine2: {
                            id: med2.id,
                            name: med2.name,
                            brand: med2.brand
                        },
                        severity: 'moderate', // Could be low, moderate, high, severe
                        description: `Potential interaction between ${med1.name} and ${med2.name}`,
                        recommendation: 'Consult with your healthcare provider before taking these medicines together'
                    };

                    interactions.push(interaction);

                    // Add warning
                    warnings.push({
                        type: 'interaction',
                        message: `Warning: ${med1.name} and ${med2.name} may interact`,
                        severity: 'moderate'
                    });
                }
            }
        }

        // Check for common drug interactions (hardcoded examples)
        const commonInteractions = [
            {
                medicines: ['aspirin', 'warfarin'],
                severity: 'high',
                description: 'Increased bleeding risk',
                recommendation: 'Monitor bleeding time and INR levels closely'
            },
            {
                medicines: ['digoxin', 'furosemide'],
                severity: 'moderate',
                description: 'Risk of digoxin toxicity',
                recommendation: 'Monitor digoxin levels and kidney function'
            },
            {
                medicines: ['metformin', 'contrast'],
                severity: 'high',
                description: 'Risk of lactic acidosis',
                recommendation: 'Discontinue metformin before contrast procedures'
            }
        ];

        // Check against common interactions
        for (const commonInteraction of commonInteractions) {
            const foundMedicines = medicines.filter(med =>
                commonInteraction.medicines.some(commonMed =>
                    med.name.toLowerCase().includes(commonMed.toLowerCase())
                )
            );

            if (foundMedicines.length >= 2) {
                const interaction = {
                    medicine1: {
                        id: foundMedicines[0].id,
                        name: foundMedicines[0].name,
                        brand: foundMedicines[0].brand
                    },
                    medicine2: {
                        id: foundMedicines[1].id,
                        name: foundMedicines[1].name,
                        brand: foundMedicines[1].brand
                    },
                    severity: commonInteraction.severity,
                    description: commonInteraction.description,
                    recommendation: commonInteraction.recommendation
                };

                // Check if this interaction is already in the list
                const exists = interactions.some(existing =>
                    (existing.medicine1.id === interaction.medicine1.id && existing.medicine2.id === interaction.medicine2.id) ||
                    (existing.medicine1.id === interaction.medicine2.id && existing.medicine2.id === interaction.medicine1.id)
                );

                if (!exists) {
                    interactions.push(interaction);

                    warnings.push({
                        type: 'interaction',
                        message: `Warning: ${interaction.medicine1.name} and ${interaction.medicine2.name} - ${interaction.description}`,
                        severity: commonInteraction.severity
                    });
                }
            }
        }

        // Determine overall risk level
        let overallRisk = 'low';
        if (interactions.some(i => i.severity === 'severe')) {
            overallRisk = 'severe';
        } else if (interactions.some(i => i.severity === 'high')) {
            overallRisk = 'high';
        } else if (interactions.some(i => i.severity === 'moderate')) {
            overallRisk = 'moderate';
        }

        res.json({
            has_interactions: interactions.length > 0,
            interactions,
            warnings,
            overall_risk: overallRisk,
            checked_at: new Date().toISOString()
        });
    } catch (error) {
        console.error('Check interactions error:', error);
        res.status(500).json({
            error: 'Failed to check drug interactions'
        });
    }
});

// Get interactions for a specific medicine
router.get('/medicine/:id', authenticateToken, (req, res) => {
    const { id } = req.params;

    db.get('SELECT * FROM medicines WHERE id = ?', [id], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!row) {
            return res.status(404).json({ error: 'Medicine not found' });
        }

        const medicine = {
            ...row,
            interactions: row.interactions ? JSON.parse(row.interactions) : []
        };

        res.json({
            medicine,
            interactions: medicine.interactions
        });
    });
});

// Add new interaction
router.post('/', authenticateToken, validateRequest(schemas.interaction), (req, res) => {
    const { medicine1_id, medicine2_id, interaction_type, severity, description } = req.body;


    if (medicine1_id === medicine2_id) {
        return res.status(400).json({ error: 'Medicine cannot interact with itself' });
    }

    // Check if interaction already exists
    db.get('SELECT id FROM medicine_interactions WHERE (medicine1_id = ? AND medicine2_id = ?) OR (medicine1_id = ? AND medicine2_id = ?)',
        [medicine1_id, medicine2_id, medicine2_id, medicine1_id], (err, row) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (row) {
                return res.status(400).json({ error: 'Interaction already exists' });
            }

            // Insert new interaction
            db.run('INSERT INTO medicine_interactions (medicine1_id, medicine2_id, interaction_type, severity, description) VALUES (?, ?, ?, ?, ?)',
                [medicine1_id, medicine2_id, interaction_type, severity, description || null], function (err) {
                    if (err) {
                        return res.status(500).json({ error: 'Failed to add interaction' });
                    }

                    res.status(201).json({
                        message: 'Interaction added successfully',
                        interaction: {
                            id: this.lastID,
                            medicine1_id,
                            medicine2_id,
                            interaction_type,
                            severity,
                            description
                        }
                    });
                });
        });
});


module.exports = router;