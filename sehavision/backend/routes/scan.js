const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Configure multer for image uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = path.join(__dirname, '..', 'uploads', 'scans');
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, 'scan-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB limit
    },
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed'), false);
        }
    }
});

// Simulate AI recognition (replace with actual AI model)
const simulateAIRecognition = async (imagePath) => {
    // This is a dummy implementation
    // In production, you would use TensorFlow Lite, ONNX, or call an AI service

    const sampleMedicines = [
        {
            id: 1,
            name: 'Paracetamol',
            brand: 'Panadol',
            barcode: '1234567890123',
            dosage: '500mg',
            instructions: 'Take 1-2 tablets every 4-6 hours as needed',
            warnings: 'Do not exceed 8 tablets in 24 hours',
            interactions: ['Warfarin', 'Alcohol'],
            confidence: 0.95
        },
        {
            id: 2,
            name: 'Ibuprofen',
            brand: 'Advil',
            barcode: '2345678901234',
            dosage: '400mg',
            instructions: 'Take with food, 1 tablet every 6-8 hours',
            warnings: 'May cause stomach upset',
            interactions: ['Aspirin', 'Blood thinners'],
            confidence: 0.88
        },
        {
            id: 3,
            name: 'Amoxicillin',
            brand: 'Amoxil',
            barcode: '3456789012345',
            dosage: '500mg',
            instructions: 'Take 1 capsule every 8 hours for 7 days',
            warnings: 'Complete full course even if feeling better',
            interactions: ['Warfarin', 'Methotrexate'],
            confidence: 0.92
        }
    ];

    // Simulate processing time
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Return a random medicine with high confidence
    const randomMedicine = sampleMedicines[Math.floor(Math.random() * sampleMedicines.length)];

    return {
        success: true,
        medicine: randomMedicine,
        confidence: randomMedicine.confidence,
        processing_time: 1000
    };
};

// Scan medicine by image
router.post('/image', authenticateToken, upload.single('image'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No image file provided' });
        }

        const imagePath = req.file.path;

        // Process image with Sharp (resize, optimize)
        const processedImagePath = path.join(
            path.dirname(imagePath),
            'processed-' + path.basename(imagePath)
        );

        await sharp(imagePath)
            .resize(800, 600, { fit: 'inside', withoutEnlargement: true })
            .jpeg({ quality: 85 })
            .toFile(processedImagePath);

        // Simulate AI recognition
        const recognitionResult = await simulateAIRecognition(processedImagePath);

        if (recognitionResult.success) {
            // Get full medicine details from database
            db.get('SELECT * FROM medicines WHERE id = ?', [recognitionResult.medicine.id], (err, row) => {
                if (err) {
                    return res.status(500).json({ error: 'Database error' });
                }

                if (row) {
                    const medicine = {
                        ...row,
                        interactions: row.interactions ? JSON.parse(row.interactions) : null,
                        image_paths: row.image_paths ? JSON.parse(row.image_paths) : []
                    };

                    res.json({
                        success: true,
                        medicine,
                        confidence: recognitionResult.confidence,
                        scan_image: `/uploads/scans/${path.basename(processedImagePath)}`,
                        processing_time: recognitionResult.processing_time
                    });
                } else {
                    res.json({
                        success: true,
                        medicine: recognitionResult.medicine,
                        confidence: recognitionResult.confidence,
                        scan_image: `/uploads/scans/${path.basename(processedImagePath)}`,
                        processing_time: recognitionResult.processing_time,
                        note: 'Medicine found by AI but not in database'
                    });
                }
            });
        } else {
            res.status(400).json({
                success: false,
                error: 'Could not recognize medicine in image',
                scan_image: `/uploads/scans/${path.basename(processedImagePath)}`
            });
        }

    } catch (error) {
        console.error('Scan error:', error);
        res.status(500).json({ error: 'Image processing failed' });
    }
});

// Scan medicine by barcode
router.post('/barcode', authenticateToken, (req, res) => {
    const { barcode } = req.body;

    if (!barcode) {
        return res.status(400).json({ error: 'Barcode is required' });
    }

    db.get('SELECT * FROM medicines WHERE barcode = ?', [barcode], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!row) {
            return res.status(404).json({
                success: false,
                error: 'Medicine not found for this barcode'
            });
        }

        const medicine = {
            ...row,
            interactions: row.interactions ? JSON.parse(row.interactions) : null,
            image_paths: row.image_paths ? JSON.parse(row.image_paths) : []
        };

        res.json({
            success: true,
            medicine,
            confidence: 1.0,
            scan_method: 'barcode'
        });
    });
});

// Get scan history for user
router.get('/history', authenticateToken, (req, res) => {
    const { limit = 20, offset = 0 } = req.query;

    // For now, we'll return a simple history
    // In production, you should store scan history in a separate table
    res.json({
        scans: [],
        message: 'Scan history feature coming soon'
    });
});

module.exports = router;
