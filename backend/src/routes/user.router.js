import express from 'express';
import { userController } from '~/controllers/user.controller';
import { verifyToken, verifyAdmin, verifyRole } from '~/middlewares/authMiddleware';

import validate from '~/middlewares/validationMiddleware';
import { registerSchema, loginSchema } from '~/validations/authValidation';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Authentication
 *   description: User registration and login
 */

/**
 * @swagger
 * /users/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Authentication]
 *     description: Creates a new user account. An OTP will be sent to the provided email for verification.
 *     security: [] # Override global security for this public endpoint
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - fullName
 *               - email
 *               - password
 *             properties:
 *               fullName:
 *                 type: string
 *                 example: "John Doe"
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "john.doe@example.com"
 *               password:
 *                 type: string
 *                 format: password
 *                 example: "password123"
 *     responses:
 *       '201':
 *         description: Registration successful. OTP sent to email.
 *       '409':
 *         description: Email already exists.
 *       '422':
 *         description: Validation error.
 */
router.post('/register', validate(registerSchema), userController.register)

/**
 * @swagger
 * /users/login:
 *   post:
 *     summary: Log in a user
 *     tags: [Authentication]
 *     description: Authenticates a user and returns an access token and refresh token.
 *     security: [] # Override global security for this public endpoint
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "john.doe@example.com"
 *               password:
 *                 type: string
 *                 format: password
 *                 example: "password123"
 *     responses:
 *       '200':
 *         description: Login successful.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 user:
 *                   type: object
 *                 accessToken:
 *                   type: string
 *                 refreshToken:
 *                   type: string
 *       '401':
 *         description: Invalid email or password.
 */
router.post('/login', validate(loginSchema), userController.login)

router.post('/logout', verifyToken, userController.logout)
router.post('/request-token', userController.requestToken)
router.post('/verify-email', userController.verifyEmail)
// --- Password Management ---
router.post('/forgot-password', userController.sendPasswordResetOTP)
router.post('/reset-password', userController.resetPassword)
router.put('/change-password', verifyToken, userController.changePassword)

/**
 * @swagger
 * /users/profile:
 *   get:
 *     summary: Get user profile
 *     tags: [Users]
 *     description: Retrieves the profile information of the currently authenticated user.
 *     security:
 *       - bearerAuth: [] # This endpoint requires a JWT token
 *     responses:
 *       '200':
 *         description: User profile retrieved successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 user:
 *                   type: object
 *       '401':
 *         description: Unauthorized, token is missing or invalid.
 */
router.get('/profile', verifyToken, userController.getProfile);

// I will also add back the other routes that were there before, in case the user deleted them by mistake
router.post('/verify-registration', userController.verifyRegistration);
router.get('/oauth/callback', userController.oAuthLoginCallback);
router.get('/admin/test', verifyToken, verifyAdmin, userController.adminTest);
router.get('/doctor/test', verifyToken, verifyRole(['doctor']), userController.doctorTest);


export const userRouter = router;
