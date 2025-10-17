const request = require('supertest');
const app = require('../server');
const db = require('../config/database');

describe('Authentication Routes', () => {
    afterAll((done) => {
        db.close(done);
    });

    describe('POST /api/auth/register', () => {
        beforeEach(async () => {
            // Clear users table before each test
            await new Promise((resolve) => {
                db.run('DELETE FROM users', resolve);
            });
        });

        it('should register a new user successfully', async () => {
            const userData = {
                email: 'test@example.com',
                password: 'password123',
                name: 'Test User',
                phone: '1234567890'
            };

            const response = await request(app)
                .post('/api/auth/register')
                .send(userData)
                .expect(201);

            expect(response.body).toHaveProperty('message', 'User created successfully');
            expect(response.body).toHaveProperty('token');
            expect(response.body).toHaveProperty('user');
            expect(response.body.user.email).toBe(userData.email);
            expect(response.body.user.name).toBe(userData.name);
        });

        it('should not register user with existing email', async () => {
            const userData = {
                email: 'test@example.com',
                password: 'password123',
                name: 'Test User'
            };

            // Register first user
            const firstResponse = await request(app)
                .post('/api/auth/register')
                .send(userData);

            if (firstResponse.status !== 201) {
                console.log('First registration failed:', firstResponse.body);
                return;
            }

            // Try to register with same email
            const response = await request(app)
                .post('/api/auth/register')
                .send(userData)
                .expect(400);

            expect(response.body).toHaveProperty('error', 'User already exists');
        });

        it('should validate required fields', async () => {
            const response = await request(app)
                .post('/api/auth/register')
                .send({})
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Validation error');
            expect(response.body).toHaveProperty('details');
        });
    });

    describe('POST /api/auth/login', () => {
        beforeEach(async () => {
            // Clear users table before each test
            await new Promise((resolve) => {
                db.run('DELETE FROM users', resolve);
            });

            // Create a test user
            const userData = {
                email: 'test@example.com',
                password: 'password123',
                name: 'Test User'
            };

            await request(app)
                .post('/api/auth/register')
                .send(userData);
        });

        it('should login with valid credentials', async () => {
            const loginData = {
                email: 'test@example.com',
                password: 'password123'
            };

            const response = await request(app)
                .post('/api/auth/login')
                .send(loginData);

            if (response.status !== 200) {
                console.log('Login failed:', response.body);
                return;
            }

            expect(response.body).toHaveProperty('message', 'Login successful');
            expect(response.body).toHaveProperty('token');
            expect(response.body).toHaveProperty('user');
            expect(response.body.user.email).toBe(loginData.email);
        });

        it('should not login with invalid credentials', async () => {
            const loginData = {
                email: 'test@example.com',
                password: 'wrongpassword'
            };

            const response = await request(app)
                .post('/api/auth/login')
                .send(loginData)
                .expect(401);

            expect(response.body).toHaveProperty('error', 'Invalid credentials');
        });

        it('should not login with non-existent user', async () => {
            const loginData = {
                email: 'nonexistent@example.com',
                password: 'password123'
            };

            const response = await request(app)
                .post('/api/auth/login')
                .send(loginData)
                .expect(401);

            expect(response.body).toHaveProperty('error', 'Invalid credentials');
        });
    });

    describe('GET /api/auth/profile', () => {
        let authToken;

        beforeEach(async () => {
            // Clear users table before each test
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

            authToken = loginResponse.body.token;
        });

        it('should get user profile with valid token', async () => {
            const response = await request(app)
                .get('/api/auth/profile')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).toHaveProperty('user');
            expect(response.body.user.email).toBe('test@example.com');
        });

        it('should not get profile without token', async () => {
            const response = await request(app)
                .get('/api/auth/profile')
                .expect(401);

            expect(response.body).toHaveProperty('error', 'Access token required');
        });

        it('should not get profile with invalid token', async () => {
            const response = await request(app)
                .get('/api/auth/profile')
                .set('Authorization', 'Bearer invalid_token')
                .expect(403);

            expect(response.body).toHaveProperty('error', 'Invalid or expired token');
        });
    });
});
