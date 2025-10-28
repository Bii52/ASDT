import express from 'express';
import { verifyToken, verifyAdmin } from '~/middlewares/authMiddleware';
import validate from '~/middlewares/validationMiddleware';
import { productValidation } from '~/validations/product.validation';
import { productController } from '~/controllers/product.controller';

const router = express.Router();

router.post('/', verifyToken, verifyAdmin, validate(productValidation.createProduct), productController.createProduct);
router.get('/', verifyToken, validate(productValidation.getProducts), productController.getProducts);
router.get('/test', productController.getProducts); // Test endpoint không cần auth
router.get('/:productId', verifyToken, validate(productValidation.getProduct), productController.getProduct);
router.patch('/:productId', verifyToken, verifyAdmin, validate(productValidation.updateProduct), productController.updateProduct);
router.delete('/:productId', verifyToken, verifyAdmin, validate(productValidation.deleteProduct), productController.deleteProduct);


export const productRouter = router;