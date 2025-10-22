import express from 'express';
import { userRouter } from './user.router.js';
import { categoryRouter } from './category.router.js';
import { productRouter } from './product.router.js';
import { chatRouter } from './chat.router.js';
import appointmentRouter from './appointment.router.js';
const router = express.Router();

router.use('/users', userRouter);
router.use('/categories', categoryRouter);
router.use('/products', productRouter);
router.use('/chat', chatRouter);
router.use('/appointments', appointmentRouter);

export default router;