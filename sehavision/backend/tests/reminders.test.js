const request = require('supertest');
const app = require('../server');
const db = require('../config/database');

describe('Reminders Routes', () => {
    let authToken;
    let medicineId;

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
            console.log('Login failed in reminders test:', loginResponse.body);
        }

        // Insert test medicine
        const medicineData = {
            name: 'Test Medicine',
            brand: 'Test Brand',
            dosage: '500mg'
        };

        const medicineResponse = await request(app)
            .post('/api/medicines')
            .set('Authorization', `Bearer ${authToken}`)
            .send(medicineData);

        if (medicineResponse.status === 201 && medicineResponse.body.medicine) {
            medicineId = medicineResponse.body.medicine.id;
        } else {
            console.log('Failed to create medicine:', medicineResponse.body);
        }
    });

    afterAll((done) => {
        db.close(done);
    });

    describe('POST /api/reminders', () => {
        it('should create a new reminder', async () => {
            const reminderData = {
                medicine_id: medicineId,
                title: 'Take Medicine',
                description: 'Take with food',
                scheduled_time: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // Tomorrow
                frequency: 'daily'
            };

            const response = await request(app)
                .post('/api/reminders')
                .set('Authorization', `Bearer ${authToken}`)
                .send(reminderData)
                .expect(201);

            expect(response.body).toHaveProperty('message', 'Reminder created successfully');
            expect(response.body).toHaveProperty('reminder');
            expect(response.body.reminder.title).toBe(reminderData.title);
            expect(response.body.reminder.medicine_id).toBe(medicineId);
        });

        it('should not create reminder for non-existent medicine', async () => {
            const reminderData = {
                medicine_id: 99999,
                title: 'Take Medicine',
                scheduled_time: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
            };

            const response = await request(app)
                .post('/api/reminders')
                .set('Authorization', `Bearer ${authToken}`)
                .send(reminderData)
                .expect(404);

            expect(response.body).toHaveProperty('error', 'Medicine not found');
        });

        it('should not create reminder with past scheduled time', async () => {
            const reminderData = {
                medicine_id: medicineId,
                title: 'Take Medicine',
                scheduled_time: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString() // Yesterday
            };

            const response = await request(app)
                .post('/api/reminders')
                .set('Authorization', `Bearer ${authToken}`)
                .send(reminderData)
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Scheduled time must be in the future');
        });

        it('should validate required fields', async () => {
            const response = await request(app)
                .post('/api/reminders')
                .set('Authorization', `Bearer ${authToken}`)
                .send({})
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Validation error');
        });
    });

    describe('GET /api/reminders', () => {
        let reminderId;

        beforeEach(async () => {
            const reminderData = {
                medicine_id: medicineId,
                title: 'Test Reminder',
                scheduled_time: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
            };

            const response = await request(app)
                .post('/api/reminders')
                .set('Authorization', `Bearer ${authToken}`)
                .send(reminderData);

            if (response.status === 201 && response.body.reminder) {
                reminderId = response.body.reminder.id;
            } else {
                console.log('Failed to create reminder:', response.body);
            }
        });

        it('should get all reminders for user', async () => {
            const response = await request(app)
                .get('/api/reminders')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).toHaveProperty('reminders');
            expect(response.body.reminders).toHaveLength(1);
            expect(response.body.reminders[0].id).toBe(reminderId);
        });

        it('should filter active reminders only', async () => {
            const response = await request(app)
                .get('/api/reminders?active_only=true')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).toHaveProperty('reminders');
            expect(response.body.reminders).toHaveLength(1);
        });

        it('should limit results', async () => {
            const response = await request(app)
                .get('/api/reminders?limit=1')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body.reminders).toHaveLength(1);
        });
    });

    describe('GET /api/reminders/:id', () => {
        let reminderId;

        beforeEach(async () => {
            const reminderData = {
                medicine_id: medicineId,
                title: 'Test Reminder',
                scheduled_time: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
            };

            const response = await request(app)
                .post('/api/reminders')
                .set('Authorization', `Bearer ${authToken}`)
                .send(reminderData);

            if (response.status === 201 && response.body.reminder) {
                reminderId = response.body.reminder.id;
            } else {
                console.log('Failed to create reminder:', response.body);
            }
        });

        it('should get reminder by id', async () => {
            const response = await request(app)
                .get(`/api/reminders/${reminderId}`)
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).toHaveProperty('reminder');
            expect(response.body.reminder.id).toBe(reminderId);
        });

        it('should return 404 for non-existent reminder', async () => {
            const response = await request(app)
                .get('/api/reminders/99999')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(404);

            expect(response.body).toHaveProperty('error', 'Reminder not found');
        });

        it('should not get other users reminders', async () => {
            // Create another user
            const userData2 = {
                email: 'test2@example.com',
                password: 'password123',
                name: 'Test User 2'
            };

            await request(app)
                .post('/api/auth/register')
                .send(userData2);

            const loginResponse2 = await request(app)
                .post('/api/auth/login')
                .send({
                    email: userData2.email,
                    password: userData2.password
                });

            const authToken2 = loginResponse2.body.token;

            // Try to access first user's reminder with second user's token
            const response = await request(app)
                .get(`/api/reminders/${reminderId}`)
                .set('Authorization', `Bearer ${authToken2}`)
                .expect(404);

            expect(response.body).toHaveProperty('error', 'Reminder not found');
        });
    });

    describe('PUT /api/reminders/:id', () => {
        let reminderId;

        beforeEach(async () => {
            const reminderData = {
                medicine_id: medicineId,
                title: 'Original Reminder',
                scheduled_time: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
            };

            const response = await request(app)
                .post('/api/reminders')
                .set('Authorization', `Bearer ${authToken}`)
                .send(reminderData);

            if (response.status === 201 && response.body.reminder) {
                reminderId = response.body.reminder.id;
            } else {
                console.log('Failed to create reminder:', response.body);
            }
        });

        it('should update reminder', async () => {
            const updateData = {
                medicine_id: medicineId,
                title: 'Updated Reminder',
                scheduled_time: new Date(Date.now() + 48 * 60 * 60 * 1000).toISOString()
            };

            const response = await request(app)
                .put(`/api/reminders/${reminderId}`)
                .set('Authorization', `Bearer ${authToken}`)
                .send(updateData)
                .expect(200);

            expect(response.body).toHaveProperty('message', 'Reminder updated successfully');
            expect(response.body.reminder.title).toBe(updateData.title);
        });

        it('should return 404 for non-existent reminder', async () => {
            const response = await request(app)
                .put('/api/reminders/99999')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ title: 'Updated' })
                .expect(404);

            expect(response.body).toHaveProperty('error', 'Reminder not found');
        });
    });

    describe('DELETE /api/reminders/:id', () => {
        let reminderId;

        beforeEach(async () => {
            const reminderData = {
                medicine_id: medicineId,
                title: 'Reminder to Delete',
                scheduled_time: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
            };

            const response = await request(app)
                .post('/api/reminders')
                .set('Authorization', `Bearer ${authToken}`)
                .send(reminderData);

            if (response.status === 201 && response.body.reminder) {
                reminderId = response.body.reminder.id;
            } else {
                console.log('Failed to create reminder:', response.body);
            }
        });

        it('should delete reminder', async () => {
            const response = await request(app)
                .delete(`/api/reminders/${reminderId}`)
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).toHaveProperty('message', 'Reminder deleted successfully');
        });

        it('should return 404 for non-existent reminder', async () => {
            const response = await request(app)
                .delete('/api/reminders/99999')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(404);

            expect(response.body).toHaveProperty('error', 'Reminder not found');
        });
    });

    describe('PATCH /api/reminders/:id/toggle', () => {
        let reminderId;

        beforeEach(async () => {
            const reminderData = {
                medicine_id: medicineId,
                title: 'Toggle Reminder',
                scheduled_time: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
            };

            const response = await request(app)
                .post('/api/reminders')
                .set('Authorization', `Bearer ${authToken}`)
                .send(reminderData);

            if (response.status === 201 && response.body.reminder) {
                reminderId = response.body.reminder.id;
            } else {
                console.log('Failed to create reminder:', response.body);
            }
        });

        it('should toggle reminder active status', async () => {
            const response = await request(app)
                .patch(`/api/reminders/${reminderId}/toggle`)
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).toHaveProperty('message');
            expect(response.body).toHaveProperty('is_active');
        });

        it('should return 404 for non-existent reminder', async () => {
            const response = await request(app)
                .patch('/api/reminders/99999/toggle')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(404);

            expect(response.body).toHaveProperty('error', 'Reminder not found');
        });
    });

    describe('GET /api/reminders/upcoming/24h', () => {
        it('should get upcoming reminders', async () => {
            const response = await request(app)
                .get('/api/reminders/upcoming/24h')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).toHaveProperty('upcoming_reminders');
            expect(response.body).toHaveProperty('count');
            expect(response.body).toHaveProperty('time_range', '24 hours');
        });
    });
});
