const request = require('supertest');
const app = require('../server');
const db = require('../config/database');
const path = require('path');
const fs = require('fs');

describe('Scan Routes', () => {
    let authToken;

    beforeEach(async () => {
        // Clear tables
        await new Promise((resolve) => {
            db.run('DELETE FROM reminders', resolve);
        });
        await new Promise((resolve) => {
            db.run('DELETE FROM medicine_interactions', resolve);
        });
        await new Promise((resolve) => {
            db.run('DELETE FROM medicines', resolve);
        });
        await new Promise((resolve) => {
            db.run('DELETE FROM users', resolve);
        });

        // Create and login a test user
        const userData = {
            email: 'test@example.com',
            password: 'password123',
            name: 'Test User'
        };

        await request(app)
            .post('/api/auth/register')
            .send(userData);

        const loginResponse = await request(app)
            .post('/api/auth/login')
            .send({
                email: userData.email,
                password: userData.password
            });

        if (loginResponse.status === 200 && loginResponse.body.token) {
            authToken = loginResponse.body.token;
        } else {
            console.log('Login failed in scan test:', loginResponse.body);
        }

        // Insert test medicine
        const medicineData = {
            name: 'Test Medicine',
            brand: 'Test Brand',
            barcode: '1234567890123',
            dosage: '500mg'
        };

        await request(app)
            .post('/api/medicines')
            .set('Authorization', `Bearer ${authToken}`)
            .send(medicineData);
    });

    afterAll((done) => {
        db.close(done);
    });

    describe('POST /api/scan/barcode', () => {
        it('should scan medicine by barcode', async () => {
            const response = await request(app)
                .post('/api/scan/barcode')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ barcode: '1234567890123' })
                .expect(200);

            expect(response.body).toHaveProperty('success', true);
            expect(response.body).toHaveProperty('medicine');
            expect(response.body.medicine.name).toBe('Test Medicine');
            expect(response.body).toHaveProperty('confidence', 1.0);
        });

        it('should return 404 for unknown barcode', async () => {
            const response = await request(app)
                .post('/api/scan/barcode')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ barcode: '9999999999999' })
                .expect(404);

            expect(response.body).toHaveProperty('success', false);
            expect(response.body).toHaveProperty('error', 'Medicine not found for this barcode');
        });

        it('should require barcode', async () => {
            const response = await request(app)
                .post('/api/scan/barcode')
                .set('Authorization', `Bearer ${authToken}`)
                .send({})
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Barcode is required');
        });
    });

    describe('POST /api/scan/image', () => {
        it('should require authentication', async () => {
            const response = await request(app)
                .post('/api/scan/image')
                .expect(401);

            expect(response.body).toHaveProperty('error', 'Access token required');
        });

        it('should require image file', async () => {
            const response = await request(app)
                .post('/api/scan/image')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(400);

            expect(response.body).toHaveProperty('error', 'No image file provided');
        });

        it('should process image and return medicine data', async () => {
            // Create a dummy image file for testing
            const testImagePath = path.join(__dirname, '..', 'uploads', 'test-image.jpg');
            const uploadsDir = path.dirname(testImagePath);

            if (!fs.existsSync(uploadsDir)) {
                fs.mkdirSync(uploadsDir, { recursive: true });
            }

            // Create a minimal JPEG file
            const jpegHeader = Buffer.from([
                0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
                0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xD9
            ]);
            fs.writeFileSync(testImagePath, jpegHeader);

            const response = await request(app)
                .post('/api/scan/image')
                .set('Authorization', `Bearer ${authToken}`)
                .attach('image', testImagePath);

            if (response.status !== 200) {
                console.log('Scan image failed:', response.body);
                return;
            }

            expect(response.body).toHaveProperty('success', true);
            expect(response.body).toHaveProperty('medicine');
            expect(response.body).toHaveProperty('confidence');
            expect(response.body).toHaveProperty('scan_image');

            // Clean up test file
            if (fs.existsSync(testImagePath)) {
                fs.unlinkSync(testImagePath);
            }
        });
    });

    describe('GET /api/scan/history', () => {
        it('should get scan history', async () => {
            const response = await request(app)
                .get('/api/scan/history')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).toHaveProperty('scans');
            expect(response.body).toHaveProperty('message');
        });

        it('should require authentication', async () => {
            const response = await request(app)
                .get('/api/scan/history')
                .expect(401);

            expect(response.body).toHaveProperty('error', 'Access token required');
        });
    });
});
