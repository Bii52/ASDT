import express from 'express';
import { verifyToken, verifyAdmin } from '~/middlewares/authMiddleware';
import validate from '~/middlewares/validationMiddleware';
import { productController } from '~/controllers/product.controller';
import { categoryValidation } from '~/validations/category.validation';
import { categoryController } from '~/controllers/category.controller';

const router = express.Router();

router.post('/', verifyToken, verifyAdmin, validate(categoryValidation.createCategory), categoryController.createCategory);
router.get('/', verifyToken, validate(categoryValidation.getCategories), categoryController.getCategories);
router.get('/:categoryId/products', validate(categoryValidation.getCategory), productController.getProductsByCategoryId);
router.get('/:categoryId', verifyToken, validate(categoryValidation.getCategory), categoryController.getCategory);
router.patch('/:categoryId', verifyToken, verifyAdmin, validate(categoryValidation.updateCategory), categoryController.updateCategory);
router.delete('/:categoryId', verifyToken, verifyAdmin, validate(categoryValidation.deleteCategory), categoryController.deleteCategory);

export const categoryRouter = router;
