import express from 'express'
import { adminController } from '~/controllers/admin.controller.js'
import { verifyToken } from '~/middlewares/authMiddleware.js'
import validationMiddleware from '~/middlewares/validationMiddleware.js'
import { adminValidation } from '~/validations/admin.validation.js'
import pick from '~/utils/pick'

const router = express.Router()

// Middleware để kiểm tra quyền admin
const requireAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Chỉ admin mới có quyền truy cập'
    })
  }
  next()
}

// Apply authentication middleware to all routes
router.use(verifyToken)
router.use(requireAdmin)

// Dashboard & Statistics
router.get('/dashboard', adminController.getDashboard)
router.get('/statistics', adminController.getStatistics)

// User Management Routes
router.get('/users', adminController.getUsers)
router.get('/users/:userId', adminController.getUserById)
router.put('/users/:userId',
  validationMiddleware(adminValidation.updateUser),
  adminController.updateUser
)
router.delete('/users/:userId', adminController.deleteUser)
router.put('/users/:userId/lock',
  validationMiddleware(adminValidation.lockUser),
  adminController.lockUser
)
router.put('/users/:userId/unlock', adminController.unlockUser)

// Doctor Approval Routes
router.post('/doctors', validationMiddleware(adminValidation.createDoctor), adminController.createDoctor)
router.get('/doctors/pending', adminController.getPendingDoctors)
router.put('/doctors/:doctorId/approve',
  validationMiddleware(adminValidation.approveDoctor),
  adminController.approveDoctor
)
router.put('/doctors/:doctorId/reject',
  validationMiddleware(adminValidation.rejectDoctor),
  adminController.rejectDoctor
)

// Product Monitoring Routes
router.get('/products', adminController.getProducts)
router.get('/products/review', adminController.getProductsForReview)
router.put('/products/:productId/approve', adminController.approveProduct)
router.put('/products/:productId/reject',
  validationMiddleware(adminValidation.rejectProduct),
  adminController.rejectProduct
)

// Article Management Routes
router.post('/articles',
  validationMiddleware(adminValidation.createArticle),
  adminController.createArticle
)
router.get('/articles', adminController.getArticles)
router.put('/articles/:articleId',
  validationMiddleware(adminValidation.updateArticle),
  adminController.updateArticle
)
router.delete('/articles/:articleId', adminController.deleteArticle)
router.put('/articles/:articleId/toggle', adminController.toggleArticleVisibility)

// Report Management Routes
router.get('/reports', adminController.getReports)
router.put('/reports/:reportId/handle',
  validationMiddleware(adminValidation.handleReport),
  adminController.handleReport
)

// System Configuration Routes
router.get('/config', adminController.getSystemConfig)
router.put('/config',
  validationMiddleware(adminValidation.updateSystemConfig),
  adminController.updateSystemConfig
)
router.get('/roles', adminController.getRoles)
router.put('/roles/:roleId/permissions',
  validationMiddleware(adminValidation.updateRolePermissions),
  adminController.updateRolePermissions
)

export default router
