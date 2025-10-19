import express from 'express';
import { userController } from '~/controllers/user.controller';
import { verifyToken, verifyAdmin, verifyRole } from '~/middlewares/authMiddleware';

import validate from '~/middlewares/validationMiddleware';
import { registerSchema, loginSchema } from '~/validations/authValidation';

const router = express.Router();

router.post('/register', validate(registerSchema), userController.register)
router.post('/login', validate(loginSchema), userController.login)
router.post('/logout', verifyToken, userController.logout)
router.post('/request-token', userController.requestToken)
router.post('/verify-email', userController.verifyEmail)
// --- Password Management ---
router.post('/forgot-password', userController.sendPasswordResetOTP)
router.post('/reset-password', userController.resetPassword)
router.put('/change-password', verifyToken, userController.changePassword)

// I will also add back the other routes that were there before, in case the user deleted them by mistake
router.post('/verify-registration', userController.verifyRegistration);
router.get('/oauth/callback', userController.oAuthLoginCallback);
router.get('/admin/test', verifyToken, verifyAdmin, userController.adminTest);
router.get('/doctor/test', verifyToken, verifyRole(['doctor']), userController.doctorTest);


export const userRouter = router;
