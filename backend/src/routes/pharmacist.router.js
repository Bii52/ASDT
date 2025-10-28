import express from 'express'
import { pharmacistController } from '~/controllers/pharmacist.controller.js'
import { verifyToken } from '~/middlewares/authMiddleware.js'
import validationMiddleware from '~/middlewares/validationMiddleware.js'
import { pharmacistValidation } from '~/validations/pharmacist.validation.js'

const router = express.Router()

// Middleware để kiểm tra quyền pharmacist
const requirePharmacist = (req, res, next) => {
  if (req.user.role !== 'pharmacist') {
    return res.status(403).json({
      success: false,
      message: 'Chỉ dược sĩ mới có quyền truy cập'
    })
  }
  next()
}

// Apply authentication middleware to all routes
router.use(verifyToken)
router.use(requirePharmacist)

// Dashboard
router.get('/dashboard', pharmacistController.getDashboard)

// Category Management Routes
router.post('/categories',
  validationMiddleware(pharmacistValidation.createCategory),
  pharmacistController.createCategory
)

router.get('/categories', pharmacistController.getCategories)

router.put('/categories/:id',
  validationMiddleware(pharmacistValidation.updateCategory),
  pharmacistController.updateCategory
)

router.delete('/categories/:id', pharmacistController.deleteCategory)

// Product Management Routes
router.post('/products',
  validationMiddleware(pharmacistValidation.createProduct),
  pharmacistController.createProduct
)

router.get('/products', pharmacistController.getProducts)

router.put('/products/:id',
  validationMiddleware(pharmacistValidation.updateProduct),
  pharmacistController.updateProduct
)

router.delete('/products/:id', pharmacistController.deleteProduct)

// QR Code Validation
router.post('/validate-qr',
  validationMiddleware(pharmacistValidation.validateQR),
  pharmacistController.validateQRCode
)

// Data Synchronization
router.post('/sync-data',
  validationMiddleware(pharmacistValidation.syncData),
  pharmacistController.syncDrugData
)

// Inventory Management
router.put('/products/:id/inventory',
  validationMiddleware(pharmacistValidation.updateInventory),
  pharmacistController.updateInventory
)

// Statistics
router.get('/stats/bestselling', pharmacistController.getBestsellingStats)

export default router
