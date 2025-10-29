import Joi from 'joi'

const updateUser = {
  params: Joi.object().keys({
    userId: Joi.string().required().hex().length(24)
  }),
  body: Joi.object().keys({
    fullName: Joi.string().optional().trim().min(2).max(100),
    email: Joi.string().optional().email().trim().lowercase(),
    phoneNumber: Joi.string().optional().trim(),
    role: Joi.string().optional().valid('user', 'doctor', 'pharmacist', 'admin'),
    emailVerified: Joi.boolean().optional(),
    phoneVerified: Joi.boolean().optional(),
    specialty: Joi.string().optional().trim(),
    bio: Joi.string().optional().trim().max(500),
    licenseNumber: Joi.string().optional().trim(),
    pharmacyName: Joi.string().optional().trim(),
    pharmacyLicense: Joi.string().optional().trim(),
    pharmacyAddress: Joi.string().optional().trim()
  }).min(1)
}

const lockUser = {
  params: Joi.object().keys({
    userId: Joi.string().required().hex().length(24)
  }),
  body: Joi.object().keys({
    reason: Joi.string().required().trim().min(5).max(200)
  })
}

const approveDoctor = {
  params: Joi.object().keys({
    doctorId: Joi.string().required().hex().length(24)
  }),
  body: Joi.object().keys({
    approvedBy: Joi.string().required().hex().length(24),
    notes: Joi.string().optional().trim().max(500)
  })
}

const rejectDoctor = {
  params: Joi.object().keys({
    doctorId: Joi.string().required().hex().length(24)
  }),
  body: Joi.object().keys({
    reason: Joi.string().required().trim().min(5).max(200)
  })
}

const rejectProduct = {
  params: Joi.object().keys({
    productId: Joi.string().required().hex().length(24)
  }),
  body: Joi.object().keys({
    reason: Joi.string().required().trim().min(5).max(200)
  })
}

const createDoctor = {
  body: Joi.object().keys({
    fullName: Joi.string().required().trim().min(2).max(100),
    email: Joi.string().required().email().trim().lowercase(),
    password: Joi.string().required().min(8),
    specialty: Joi.string().required().trim(),
    bio: Joi.string().optional().trim().max(500),
    licenseNumber: Joi.string().required().trim()
  })
}

const createArticle = {
  body: Joi.object().keys({
    title: Joi.string().required().trim().min(5).max(200),
    content: Joi.string().required().trim().min(50),
    summary: Joi.string().optional().trim().max(300),
    category: Joi.string().required().trim(),
    tags: Joi.array().items(Joi.string().trim()).optional(),
    featuredImage: Joi.string().optional().uri(),
    isPublished: Joi.boolean().optional().default(true)
  })
}

const updateArticle = {
  params: Joi.object().keys({
    articleId: Joi.string().required()
  }),
  body: Joi.object().keys({
    title: Joi.string().optional().trim().min(5).max(200),
    content: Joi.string().optional().trim().min(50),
    summary: Joi.string().optional().trim().max(300),
    category: Joi.string().optional().trim(),
    tags: Joi.array().items(Joi.string().trim()).optional(),
    featuredImage: Joi.string().optional().uri(),
    isPublished: Joi.boolean().optional()
  }).min(1)
}

const handleReport = {
  params: Joi.object().keys({
    reportId: Joi.string().required()
  }),
  body: Joi.object().keys({
    action: Joi.string().required().valid('dismiss', 'warn', 'suspend', 'ban'),
    notes: Joi.string().optional().trim().max(500),
    severity: Joi.string().optional().valid('low', 'medium', 'high', 'critical')
  })
}

const updateSystemConfig = {
  body: Joi.object().keys({
    siteName: Joi.string().optional().trim().min(2).max(100),
    siteDescription: Joi.string().optional().trim().max(500),
    contactEmail: Joi.string().optional().email().trim().lowercase(),
    contactPhone: Joi.string().optional().trim(),
    maintenanceMode: Joi.boolean().optional(),
    allowRegistration: Joi.boolean().optional(),
    requireEmailVerification: Joi.boolean().optional(),
    maxFileSize: Joi.number().optional().min(1048576).max(104857600), // 1MB to 100MB
    allowedFileTypes: Joi.array().items(Joi.string().trim()).optional(),
    systemRoles: Joi.array().items(Joi.string().trim()).optional()
  }).min(1)
}

const updateRolePermissions = {
  params: Joi.object().keys({
    roleId: Joi.string().required()
  }),
  body: Joi.object().keys({
    permissions: Joi.array().items(Joi.string().trim()).required()
  })
}

export const adminValidation = {
  updateUser,
  lockUser,
  approveDoctor,
  rejectDoctor,
  rejectProduct,
  createDoctor,
  createArticle,
  updateArticle,
  handleReport,
  updateSystemConfig,
  updateRolePermissions
}
