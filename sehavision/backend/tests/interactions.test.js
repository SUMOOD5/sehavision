const request = require('supertest');
const app = require('../server');
const db = require('../config/database');

describe('Interactions Routes', () => {
    let authToken;
    let medicine1Id, medicine2Id, medicine3Id;

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
            console.log('Login failed in interactions test:', loginResponse.body);
        }

        // Insert test medicines
        const medicines = [
            {
                name: 'Medicine A',
                brand: 'Brand A',
                interactions: ['Medicine B', 'Medicine C']
            },
            {
                name: 'Medicine B',
                brand: 'Brand B',
                interactions: ['Medicine A']
            },
            {
                name: 'Medicine C',
                brand: 'Brand C',
                interactions: []
            }
        ];

        for (const medicine of medicines) {
            const response = await request(app)
                .post('/api/medicines')
                .set('Authorization', `Bearer ${authToken}`)
                .send(medicine);

            if (response.status === 201 && response.body.medicine) {
                if (medicine.name === 'Medicine A') {
                    medicine1Id = response.body.medicine.id;
                } else if (medicine.name === 'Medicine B') {
                    medicine2Id = response.body.medicine.id;
                } else if (medicine.name === 'Medicine C') {
                    medicine3Id = response.body.medicine.id;
                }
            }
        }
    });

    afterAll((done) => {
        db.close(done);
    });

    describe('POST /api/interactions/check', () => {
        it('should check interactions between medicines', async () => {
            const response = await request(app)
                .post('/api/interactions/check')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ medicine_ids: [medicine1Id, medicine2Id] })
                .expect(200);

            expect(response.body).toHaveProperty('has_interactions');
            expect(response.body).toHaveProperty('interactions');
            expect(response.body).toHaveProperty('medicines_checked');
            expect(response.body).toHaveProperty('summary');
            expect(response.body.medicines_checked).toHaveLength(2);
        });

        it('should require at least 2 medicines', async () => {
            const response = await request(app)
                .post('/api/interactions/check')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ medicine_ids: [medicine1Id] })
                .expect(400);

            expect(response.body).toHaveProperty('error', 'At least 2 medicines required for interaction check');
        });

        it('should validate medicine_ids array', async () => {
            const response = await request(app)
                .post('/api/interactions/check')
                .set('Authorization', `Bearer ${authToken}`)
                .send({})
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Validation error');
        });

        it('should return error for non-existent medicines', async () => {
            const response = await request(app)
                .post('/api/interactions/check')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ medicine_ids: [medicine1Id, 99999] })
                .expect(400);

            expect(response.body).toHaveProperty('error', 'One or more medicines not found');
        });

        it('should detect interactions from medicine data', async () => {
            const response = await request(app)
                .post('/api/interactions/check')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ medicine_ids: [medicine1Id, medicine2Id] });

            // Since Medicine A has Medicine B in its interactions list
            expect(response.body.has_interactions).toBe(true);
            expect(response.body.interactions.length).toBeGreaterThan(0);
        });

        it('should not detect interactions for non-interacting medicines', async () => {
            const response = await request(app)
                .post('/api/interactions/check')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ medicine_ids: [medicine2Id, medicine3Id] });

            // Medicine B and C should not interact
            expect(response.body.has_interactions).toBe(false);
            expect(response.body.interactions).toHaveLength(0);
        });
    });

    describe('GET /api/interactions/medicine/:id', () => {
        it('should get interactions for a specific medicine', async () => {
            const response = await request(app)
                .get(`/api/interactions/medicine/${medicine1Id}`)
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).toHaveProperty('medicine');
            expect(response.body).toHaveProperty('interactions');
            expect(response.body).toHaveProperty('count');
            expect(response.body.medicine.id).toBe(medicine1Id);
            expect(response.body.interactions).toContain('Medicine B');
            expect(response.body.interactions).toContain('Medicine C');
        });

        it('should return 404 for non-existent medicine', async () => {
            const response = await request(app)
                .get('/api/interactions/medicine/99999')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(404);

            expect(response.body).toHaveProperty('error', 'Medicine not found');
        });
    });

    describe('POST /api/interactions', () => {
        it('should add new interaction', async () => {
            const interactionData = {
                medicine1_id: medicine2Id,
                medicine2_id: medicine3Id,
                interaction_type: 'pharmacokinetic',
                severity: 'moderate',
                description: 'Test interaction between Medicine B and C'
            };

            const response = await request(app)
                .post('/api/interactions')
                .set('Authorization', `Bearer ${authToken}`)
                .send(interactionData)
                .expect(201);

            expect(response.body).toHaveProperty('message', 'Interaction added successfully');
            expect(response.body).toHaveProperty('interaction');
            expect(response.body.interaction.medicine1_id).toBe(medicine2Id);
            expect(response.body.interaction.medicine2_id).toBe(medicine3Id);
        });

        it('should not allow medicine to interact with itself', async () => {
            const interactionData = {
                medicine1_id: medicine1Id,
                medicine2_id: medicine1Id,
                interaction_type: 'pharmacokinetic',
                severity: 'moderate'
            };

            const response = await request(app)
                .post('/api/interactions')
                .set('Authorization', `Bearer ${authToken}`)
                .send(interactionData)
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Validation error');
        });

        it('should validate required fields', async () => {
            const response = await request(app)
                .post('/api/interactions')
                .set('Authorization', `Bearer ${authToken}`)
                .send({})
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Validation error');
        });

        it('should not allow duplicate interactions', async () => {
            const interactionData = {
                medicine1_id: medicine1Id,
                medicine2_id: medicine2Id,
                interaction_type: 'pharmacokinetic',
                severity: 'moderate'
            };

            // Add first interaction
            await request(app)
                .post('/api/interactions')
                .set('Authorization', `Bearer ${authToken}`)
                .send(interactionData);

            // Try to add duplicate
            const response = await request(app)
                .post('/api/interactions')
                .set('Authorization', `Bearer ${authToken}`)
                .send(interactionData)
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Interaction already exists');
        });
    });
});
