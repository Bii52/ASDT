import express from 'express';
import { userController } from '~/controllers/user.controller.js';
import { verifyToken, verifyAdmin, verifyRole } from '~/middlewares/authMiddleware.js';

import validate from '~/middlewares/validationMiddleware.js';
import { registerSchema, loginSchema, verifyRegistrationSchema } from '~/validations/authValidation.js';

const router = express.Router();

router.post('/register', validate(registerSchema), userController.register)

router.post('/login', validate(loginSchema), userController.login)

router.post('/logout', verifyToken, userController.logout)
router.post('/request-token', userController.requestToken)

// --- Password Management ---
router.post('/forgot-password', userController.sendPasswordResetOTP)
router.post('/reset-password', userController.resetPassword)
router.put('/change-password', verifyToken, userController.changePassword)

router.get('/me', verifyToken, userController.getProfile);

// I will also add back the other routes that were there before, in case the user deleted them by mistake
router.post('/verify-registration', validate(verifyRegistrationSchema), userController.verifyRegistration);
router.get('/oauth/callback', userController.oAuthLoginCallback);
router.get('/admin/test', verifyToken, verifyAdmin, userController.adminTest);
router.get('/doctor/test', verifyToken, verifyRole(['doctor']), userController.doctorTest);

// --- Get Doctors ---
router.get('/doctors', verifyToken, userController.getDoctors);
router.get('/doctors/online', verifyToken, userController.getOnlineDoctors);
router.get('/debug/online-users', verifyToken, userController.debugOnlineUsers);

// --- Test Endpoints ---
router.post('/test/create-doctor', userController.createTestDoctor);

// --- Admin User Management ---
router.get('/admin/users', verifyToken, verifyAdmin, userController.getUsers);
router.get('/admin/users/:userId', verifyToken, verifyAdmin, userController.getUser);
router.patch('/admin/users/:userId', verifyToken, verifyAdmin, userController.updateUser);
router.delete('/admin/users/:userId', verifyToken, verifyAdmin, userController.deleteUser);



export const userRouter = router;
