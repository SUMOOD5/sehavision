const db = require('../config/database');
const path = require('path');
const fs = require('fs');

// Sample medicines data
const sampleMedicines = [
    {
        name: 'Paracetamol',
        brand: 'Panadol',
        barcode: '1234567890123',
        dosage: '500mg',
        instructions: 'Take 1-2 tablets every 4-6 hours as needed for pain or fever. Do not exceed 8 tablets in 24 hours.',
        warnings: 'Do not exceed recommended dose. May cause liver damage if taken in excess.',
        interactions: ['Warfarin', 'Alcohol'],
        expiry_date: '2025-12-31',
        image_paths: ['/assets/samples/paracetamol.jpg']
    },
    {
        name: 'Ibuprofen',
        brand: 'Advil',
        barcode: '2345678901234',
        dosage: '400mg',
        instructions: 'Take with food, 1 tablet every 6-8 hours. Do not exceed 6 tablets in 24 hours.',
        warnings: 'May cause stomach upset, heartburn, or ulcers. Take with food.',
        interactions: ['Aspirin', 'Blood thinners', 'ACE inhibitors'],
        expiry_date: '2025-06-30',
        image_paths: ['/assets/samples/ibuprofen.jpg']
    },
    {
        name: 'Amoxicillin',
        brand: 'Amoxil',
        barcode: '3456789012345',
        dosage: '500mg',
        instructions: 'Take 1 capsule every 8 hours for 7 days. Complete full course even if feeling better.',
        warnings: 'May cause diarrhea, nausea, or allergic reactions. Stop if rash develops.',
        interactions: ['Warfarin', 'Methotrexate', 'Birth control pills'],
        expiry_date: '2024-12-31',
        image_paths: ['/assets/samples/amoxicillin.jpg']
    },
    {
        name: 'Aspirin',
        brand: 'Bayer',
        barcode: '4567890123456',
        dosage: '100mg',
        instructions: 'Take 1 tablet daily with food. Do not crush or chew.',
        warnings: 'May cause stomach bleeding. Avoid alcohol. Not for children under 16.',
        interactions: ['Warfarin', 'Ibuprofen', 'Alcohol'],
        expiry_date: '2025-03-31',
        image_paths: ['/assets/samples/aspirin.jpg']
    },
    {
        name: 'Metformin',
        brand: 'Glucophage',
        barcode: '5678901234567',
        dosage: '500mg',
        instructions: 'Take 1 tablet twice daily with meals. Start with lower dose.',
        warnings: 'May cause stomach upset initially. Monitor blood sugar regularly.',
        interactions: ['Alcohol', 'Contrast dye', 'Cimetidine'],
        expiry_date: '2025-09-30',
        image_paths: ['/assets/samples/metformin.jpg']
    }
];

// Sample interactions data
const sampleInteractions = [
    {
        medicine1_id: 1, // Paracetamol
        medicine2_id: 2, // Ibuprofen
        interaction_type: 'additive_effect',
        severity: 'moderate',
        description: 'Both medicines can cause liver damage. Taking together increases risk.'
    },
    {
        medicine1_id: 2, // Ibuprofen
        medicine2_id: 4, // Aspirin
        interaction_type: 'competitive_inhibition',
        severity: 'moderate',
        description: 'Ibuprofen may reduce the cardioprotective effects of aspirin.'
    },
    {
        medicine1_id: 3, // Amoxicillin
        medicine2_id: 5, // Metformin
        interaction_type: 'pharmacokinetic',
        severity: 'mild',
        description: 'Amoxicillin may slightly increase metformin levels in blood.'
    }
];

// Create sample images directory
const createSampleImages = () => {
    const samplesDir = path.join(__dirname, '..', 'assets', 'samples');
    if (!fs.existsSync(samplesDir)) {
        fs.mkdirSync(samplesDir, { recursive: true });
    }

    // Create placeholder image files
    const imageFiles = [
        'paracetamol.jpg',
        'ibuprofen.jpg',
        'amoxicillin.jpg',
        'aspirin.jpg',
        'metformin.jpg'
    ];

    imageFiles.forEach(filename => {
        const filePath = path.join(samplesDir, filename);
        if (!fs.existsSync(filePath)) {
            // Create a simple placeholder file
            fs.writeFileSync(filePath, 'placeholder image data');
        }
    });
};

// Initialize database with sample data
const initializeDatabase = () => {
    return new Promise((resolve, reject) => {
        db.serialize(() => {
            // Clear existing data
            db.run('DELETE FROM medicine_interactions');
            db.run('DELETE FROM reminders');
            db.run('DELETE FROM medicines');
            db.run('DELETE FROM users');

            // Insert sample medicines
            const insertMedicine = (medicine) => {
                return new Promise((resolve, reject) => {
                    const interactionsJson = JSON.stringify(medicine.interactions);
                    const imagePathsJson = JSON.stringify(medicine.image_paths);

                    db.run(
                        `INSERT INTO medicines (name, brand, barcode, dosage, instructions, warnings, interactions, expiry_date, image_paths)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                        [
                            medicine.name,
                            medicine.brand,
                            medicine.barcode,
                            medicine.dosage,
                            medicine.instructions,
                            medicine.warnings,
                            interactionsJson,
                            medicine.expiry_date,
                            imagePathsJson
                        ],
                        function (err) {
                            if (err) {
                                reject(err);
                            } else {
                                resolve(this.lastID);
                            }
                        }
                    );
                });
            };

            // Insert sample interactions
            const insertInteraction = (interaction) => {
                return new Promise((resolve, reject) => {
                    db.run(
                        'INSERT INTO medicine_interactions (medicine1_id, medicine2_id, interaction_type, severity, description) VALUES (?, ?, ?, ?, ?)',
                        [
                            interaction.medicine1_id,
                            interaction.medicine2_id,
                            interaction.interaction_type,
                            interaction.severity,
                            interaction.description
                        ],
                        function (err) {
                            if (err) {
                                reject(err);
                            } else {
                                resolve();
                            }
                        }
                    );
                });
            };

            // Process all medicines and store their IDs
            const medicineIds = [];
            Promise.all(sampleMedicines.map(insertMedicine))
                .then((ids) => {
                    medicineIds.push(...ids);
                    console.log('Sample medicines inserted successfully');

                    // Create interactions using actual medicine IDs
                    const actualInteractions = [
                        {
                            medicine1_id: medicineIds[0], // Paracetamol
                            medicine2_id: medicineIds[1], // Ibuprofen
                            interaction_type: 'additive_effect',
                            severity: 'moderate',
                            description: 'Both medicines can cause liver damage. Taking together increases risk.'
                        },
                        {
                            medicine1_id: medicineIds[1], // Ibuprofen
                            medicine2_id: medicineIds[3], // Aspirin
                            interaction_type: 'competitive_inhibition',
                            severity: 'moderate',
                            description: 'Ibuprofen may reduce the cardioprotective effects of aspirin.'
                        },
                        {
                            medicine1_id: medicineIds[2], // Amoxicillin
                            medicine2_id: medicineIds[4], // Metformin
                            interaction_type: 'pharmacokinetic',
                            severity: 'mild',
                            description: 'Amoxicillin may affect metformin absorption.'
                        }
                    ];

                    return Promise.all(actualInteractions.map(insertInteraction));
                })
                .then(() => {
                    console.log('Sample interactions inserted successfully');
                    createSampleImages();
                    console.log('Sample images directory created');
                    resolve();
                })
                .catch(reject);
        });
    });
};

// Run initialization
if (require.main === module) {
    initializeDatabase()
        .then(() => {
            console.log('Database initialized successfully with sample data');
            process.exit(0);
        })
        .catch((err) => {
            console.error('Error initializing database:', err);
            process.exit(1);
        });
}

module.exports = { initializeDatabase, sampleMedicines, sampleInteractions };
