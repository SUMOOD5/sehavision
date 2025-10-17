const request = require('supertest');
const app = require('../server');
const db = require('../config/database');

describe('Medicines Routes', () => {
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
            email: 'admin@example.com',
            password: 'password123',
            name: 'Admin User'
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
            console.log('Login failed in medicines test:', loginResponse.body);
        }
    });

    afterAll((done) => {
        db.close(done);
    });

    describe('GET /api/medicines', () => {
        beforeEach(async () => {
            // Insert test medicines
            const medicines = [
                {
                    name: 'Paracetamol',
                    brand: 'Panadol',
                    barcode: '1234567890123',
                    dosage: '500mg'
                },
                {
                    name: 'Ibuprofen',
                    brand: 'Advil',
                    barcode: '2345678901234',
                    dosage: '400mg'
                }
            ];

            for (const medicine of medicines) {
                const response = await request(app)
                    .post('/api/medicines')
                    .set('Authorization', `Bearer ${authToken}`)
                    .send(medicine);

                if (response.status !== 201) {
                    console.log('Failed to create medicine:', response.body);
                }
            }
        });

        it('should get all medicines', async () => {
            const response = await request(app)
                .get('/api/medicines')
                .expect(200);

            expect(response.body).toHaveProperty('medicines');
            expect(response.body.medicines).toHaveLength(2);
        });

        it('should search medicines by name', async () => {
            const response = await request(app)
                .get('/api/medicines?search=Paracetamol')
                .expect(200);

            expect(response.body.medicines).toHaveLength(1);
            expect(response.body.medicines[0].name).toBe('Paracetamol');
        });

        it('should limit results', async () => {
            const response = await request(app)
                .get('/api/medicines?limit=1')
                .expect(200);

            expect(response.body.medicines).toHaveLength(1);
        });
    });

    describe('GET /api/medicines/:id', () => {
        let medicineId;

        beforeEach(async () => {
            const medicineData = {
                name: 'Test Medicine',
                brand: 'Test Brand',
                barcode: '1234567890123',
                dosage: '500mg'
            };

            const response = await request(app)
                .post('/api/medicines')
                .set('Authorization', `Bearer ${authToken}`)
                .send(medicineData);

            if (response.status === 201 && response.body.medicine) {
                medicineId = response.body.medicine.id;
            } else {
                console.log('Failed to create medicine:', response.body);
            }
        });

        it('should get medicine by id', async () => {
            const response = await request(app)
                .get(`/api/medicines/${medicineId}`)
                .expect(200);

            expect(response.body).toHaveProperty('medicine');
            expect(response.body.medicine.id).toBe(medicineId);
            expect(response.body.medicine.name).toBe('Test Medicine');
        });

        it('should return 404 for non-existent medicine', async () => {
            const response = await request(app)
                .get('/api/medicines/99999')
                .expect(404);

            expect(response.body).toHaveProperty('error', 'Medicine not found');
        });
    });

    describe('POST /api/medicines', () => {
        it('should create a new medicine', async () => {
            const medicineData = {
                name: 'New Medicine',
                brand: 'New Brand',
                barcode: '9876543210987',
                dosage: '250mg',
                instructions: 'Take with food',
                warnings: 'May cause drowsiness'
            };

            const response = await request(app)
                .post('/api/medicines')
                .set('Authorization', `Bearer ${authToken}`)
                .send(medicineData)
                .expect(201);

            expect(response.body).toHaveProperty('message', 'Medicine created successfully');
            expect(response.body).toHaveProperty('medicine');
            expect(response.body.medicine.name).toBe(medicineData.name);
        });

        it('should not create medicine with duplicate barcode', async () => {
            const medicineData = {
                name: 'First Medicine',
                barcode: '1234567890123'
            };

            // Create first medicine
            await request(app)
                .post('/api/medicines')
                .set('Authorization', `Bearer ${authToken}`)
                .send(medicineData);

            // Try to create second medicine with same barcode
            const response = await request(app)
                .post('/api/medicines')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    name: 'Second Medicine',
                    barcode: '1234567890123'
                })
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Medicine with this barcode already exists');
        });

        it('should validate required fields', async () => {
            const response = await request(app)
                .post('/api/medicines')
                .set('Authorization', `Bearer ${authToken}`)
                .send({})
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Validation error');
        });
    });

    describe('PUT /api/medicines/:id', () => {
        let medicineId;

        beforeEach(async () => {
            const medicineData = {
                name: 'Original Medicine',
                brand: 'Original Brand',
                dosage: '500mg'
            };

            const response = await request(app)
                .post('/api/medicines')
                .set('Authorization', `Bearer ${authToken}`)
                .send(medicineData);

            if (response.status === 201 && response.body.medicine) {
                medicineId = response.body.medicine.id;
            } else {
                console.log('Failed to create medicine:', response.body);
            }
        });

        it('should update medicine', async () => {
            const updateData = {
                name: 'Updated Medicine',
                brand: 'Updated Brand',
                dosage: '750mg'
            };

            const response = await request(app)
                .put(`/api/medicines/${medicineId}`)
                .set('Authorization', `Bearer ${authToken}`)
                .send(updateData)
                .expect(200);

            expect(response.body).toHaveProperty('message', 'Medicine updated successfully');
            expect(response.body.medicine.name).toBe(updateData.name);
        });

        it('should return 404 for non-existent medicine', async () => {
            const response = await request(app)
                .put('/api/medicines/99999')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ name: 'Updated' })
                .expect(404);

            expect(response.body).toHaveProperty('error', 'Medicine not found');
        });
    });

    describe('DELETE /api/medicines/:id', () => {
        let medicineId;

        beforeEach(async () => {
            const medicineData = {
                name: 'Medicine to Delete',
                brand: 'Delete Brand'
            };

            const response = await request(app)
                .post('/api/medicines')
                .set('Authorization', `Bearer ${authToken}`)
                .send(medicineData);

            if (response.status === 201 && response.body.medicine) {
                medicineId = response.body.medicine.id;
            } else {
                console.log('Failed to create medicine:', response.body);
            }
        });

        it('should delete medicine', async () => {
            const response = await request(app)
                .delete(`/api/medicines/${medicineId}`)
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).toHaveProperty('message', 'Medicine deleted successfully');
        });

        it('should return 404 for non-existent medicine', async () => {
            const response = await request(app)
                .delete('/api/medicines/99999')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(404);

            expect(response.body).toHaveProperty('error', 'Medicine not found');
        });
    });
});
