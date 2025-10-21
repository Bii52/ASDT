import express from 'express';
import { userRouter } from './user.router.js';
import { categoryRouter } from './category.router.js';
import { productRouter } from './product.router.js';

const router = express.Router();

router.use('/users', userRouter);
router.use('/categories', categoryRouter);
router.use('/products', productRouter);

export default router;